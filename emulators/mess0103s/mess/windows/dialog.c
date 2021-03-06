//============================================================
//
//	dialog.h - Win32 MESS dialog handling
//
//============================================================

#include <windows.h>
#include <commctrl.h>
#include <tchar.h>

#include "dialog.h"
#include "mame.h"
#include "../windows/window.h"
#include "ui_text.h"
#include "inputx.h"
#include "utils.h"
#include "strconv.h"
#include "mscommon.h"
#include "pool.h"
#include "winutils.h"

#ifdef UNDER_CE
#include "invokegx.h"
#endif


//============================================================
//	These defines are necessary because the MinGW headers do
//	not have the latest definitions
//============================================================

#ifndef _WIN64
#ifndef GetWindowLongPtr
#define GetWindowLongPtr(hwnd, idx)			((LONG_PTR) GetWindowLong((hwnd), (idx)))
#endif

#ifndef SetWindowLongPtr
#define SetWindowLongPtr(hwnd, idx, val)	((LONG_PTR) SetWindowLong((hwnd), (idx), (val)))
#endif

#ifndef GWLP_USERDATA
#define GWLP_USERDATA						GWL_USERDATA
#endif

#ifndef GWLP_WNDPROC
#define GWLP_WNDPROC						GWL_WNDPROC
#endif
#endif // _WIN64

//============================================================

enum
{
	TRIGGER_INITDIALOG	= 1,
	TRIGGER_APPLY		= 2,
	TRIGGER_CHANGED		= 4
};

typedef LRESULT (*trigger_function)(dialog_box *dialog, HWND dlgwnd, UINT message, WPARAM wparam, LPARAM lparam);

struct dialog_info_trigger
{
	struct dialog_info_trigger *next;
	WORD dialog_item;
	WORD trigger_flags;
	UINT message;
	WPARAM wparam;
	LPARAM lparam;
	void (*storeval)(void *param, int val);
	void *storeval_param;
	trigger_function trigger_proc;
};

struct dialog_object_pool
{
	HGDIOBJ objects[16];
};

struct _dialog_box
{
	HGLOBAL handle;
	size_t handle_size;
	struct dialog_info_trigger *trigger_first;
	struct dialog_info_trigger *trigger_last;
	WORD item_count;
	WORD size_x, size_y;
	WORD pos_x, pos_y;
	WORD cursize_x, cursize_y;
	WORD home_y;
	DWORD style;
	int combo_string_count;
	int combo_default_value;
	memory_pool mempool;
	struct dialog_object_pool *objpool;
	const struct dialog_layout *layout;

	// singular notification callback; hack
	UINT notify_code;
	dialog_notification notify_callback;
	void *notify_param;
};

// this is the structure that gets associated with each input_seq edit box
struct seqselect_stuff
{
	WNDPROC oldwndproc;
	input_seq *code;		// pointer to the input_seq
	input_seq newcode;	// the new input_seq; committed to *code when we are done
	UINT_PTR timer;
	WORD pos;
	BOOL is_analog;
	int record_first_insert; 
};



//============================================================
//	IMPORTS
//============================================================

// from input.c
extern void win_poll_input(void);


//============================================================
//	PARAMETERS
//============================================================

#define DIM_VERTICAL_SPACING	3
#define DIM_HORIZONTAL_SPACING	5
#define DIM_NORMAL_ROW_HEIGHT	10
#define DIM_COMBO_ROW_HEIGHT	12
#define DIM_SLIDER_ROW_HEIGHT	18
#define DIM_BUTTON_ROW_HEIGHT	12
#define DIM_EDIT_WIDTH			120
#define DIM_BUTTON_WIDTH		50
#define DIM_ADJUSTER_SCR_WIDTH	12
#define DIM_ADJUSTER_HEIGHT		12
#define DIM_SCROLLBAR_WIDTH		10
#define DIM_BOX_VERTSKEW		-3

#define WNDLONG_DIALOG			GWLP_USERDATA

#define DLGITEM_BUTTON			((const WCHAR *) dlgitem_button)
#define DLGITEM_EDIT			((const WCHAR *) dlgitem_edit)
#define DLGITEM_STATIC			((const WCHAR *) dlgitem_static)
#define DLGITEM_LISTBOX			((const WCHAR *) dlgitem_listbox)
#define DLGITEM_SCROLLBAR		((const WCHAR *) dlgitem_scrollbar)
#define DLGITEM_COMBOBOX		((const WCHAR *) dlgitem_combobox)

#define DLGTEXT_OK				ui_getstring(UI_OK)
#define DLGTEXT_APPLY			"Apply"
#define DLGTEXT_CANCEL			"Cancel"

#define FONT_SIZE				8
#define FONT_FACE				L"Arial"

#define TIMER_ID				0xdeadbeef

#define SCROLL_DELTA_LINE		10
#define SCROLL_DELTA_PAGE		100

#define LOG_WINMSGS				1
#define DIALOG_STYLE			WS_POPUP | WS_BORDER | WS_SYSMENU | DS_MODALFRAME | WS_CAPTION | DS_SETFONT
#define MAX_DIALOG_HEIGHT		200



//============================================================
//	LOCAL VARIABLES
//============================================================

static double pixels_to_xdlgunits;
static double pixels_to_ydlgunits;

static const struct dialog_layout default_layout = { 80, 140 };
static const WORD dlgitem_button[] =	{ 0xFFFF, 0x0080 };
static const WORD dlgitem_edit[] =		{ 0xFFFF, 0x0081 };
static const WORD dlgitem_static[] =	{ 0xFFFF, 0x0082 };
static const WORD dlgitem_listbox[] =	{ 0xFFFF, 0x0083 };
static const WORD dlgitem_scrollbar[] =	{ 0xFFFF, 0x0084 };
static const WORD dlgitem_combobox[] =	{ 0xFFFF, 0x0085 };


//============================================================
//	PROTOTYPES
//============================================================

static void dialog_prime(dialog_box *di);
static int dialog_write_item(dialog_box *di, DWORD style, short x, short y,
	 short width, short height, const WCHAR *str, const WCHAR *class_name, WORD *id);



//============================================================
//	call_windowproc
//============================================================

static LRESULT call_windowproc(WNDPROC wndproc, HWND hwnd, UINT msg,
	WPARAM wparam, LPARAM lparam)
{
	LRESULT rc;
	if (IsWindowUnicode(hwnd))
		rc = CallWindowProcW(wndproc, hwnd, msg, wparam, lparam);
	else
		rc = CallWindowProcA(wndproc, hwnd, msg, wparam, lparam);
	return rc;
}



//============================================================
//	compute_dlgunits_multiple
//============================================================

static void calc_dlgunits_multiple(void)
{
	dialog_box *dialog = NULL;
	short offset_x = 2048;
	short offset_y = 2048;
	const char *wnd_title = "Foo";
	WORD id;
	HWND dlg_window = NULL;
	HWND child_window;
	RECT r;

	if ((pixels_to_xdlgunits == 0) || (pixels_to_ydlgunits == 0))
	{
		// create a bogus dialog
		dialog = win_dialog_init(NULL, NULL);
		if (!dialog)
			goto done;

		if (dialog_write_item(dialog, WS_CHILD | WS_VISIBLE | SS_LEFT,
				0, 0, offset_x, offset_y, A2W(wnd_title), DLGITEM_STATIC, &id))
			goto done;

		dialog_prime(dialog);
		dlg_window = CreateDialogIndirectParam(NULL, dialog->handle, NULL, NULL, 0);
		child_window = GetDlgItem(dlg_window, id);

		GetWindowRect(child_window, &r);
		pixels_to_xdlgunits = (double)(r.right - r.left) / offset_x;
		pixels_to_ydlgunits = (double)(r.bottom - r.top) / offset_y;

done:
		if (dialog)
			win_dialog_exit(dialog);
		if (dlg_window)
			DestroyWindow(dlg_window);
	}
}



//============================================================
//	unicode_from_mamechar
//
//	This function converts a character from the MAME code page
//	(defined by the UI font in src/usrintrf.c) to a Unicode
//	char
//============================================================

static WCHAR unicode_from_mamechar(char c)
{
	WCHAR wc;
	static const WCHAR specialchars[] =
	{
		// 0x00 - 0x1F
		'\0',	' ',	' ',	' ',	' ',	' ',	' ',	' ',
		' ',	' ',	0x25CF,	0x25CB,	0x25A0,	0x25A1,	0x25CF,	0x25CF,
		0x25BA,	0x25CF,	0x2195,	0x203C,	0x25CF,	0x25CF,	0x25CF,	0x266B,
		0x2191,	0x2193,	0x2192,	0x2190,	' ',	0x2194,	0x25B2,	0x25BC,

		// 0x80 - 0x9F
		' ',	' ',	0x201A,	0x0192,	0x201E,	0x2026,	0x2020,	0x2021,
		'^',	0x2030,	0x0160,	'<',	0x0152,	' ',	' ',	' ',
		' ',	0x2018,	0x2019,	0x201C,	0x201D,	0x25CF,	0x2013,	0x2014,
		'~',	0x2122, 0x0161,	'>',	0x0153,	' ',	' ',	0x0178
	};

	if (c & 0x60)
	{
		// chars 0x20-0x7F and 0xA0-0xFF match their Unicode equivalents
		wc = c;
	}
	else
	{
		// chars 0x00-0x1F and 0x80-0x9F are special
		wc = specialchars[(c & 0x1F) | ((c & 0x80) ? 0x20 : 0x00)];
	}
	return wc;
}



//============================================================
//	dialog_trigger
//============================================================

static void dialog_trigger(HWND dlgwnd, WORD trigger_flags)
{
	LRESULT result;
	HWND dialog_item;
	struct _dialog_box *di;
	struct dialog_info_trigger *trigger;
	LONG l;

	l = GetWindowLongPtr(dlgwnd, WNDLONG_DIALOG);
	di = (struct _dialog_box *) l;
	assert(di);
	for (trigger = di->trigger_first; trigger; trigger = trigger->next)
	{
		if (trigger->trigger_flags & trigger_flags)
		{
			if (trigger->dialog_item)
				dialog_item = GetDlgItem(dlgwnd, trigger->dialog_item);
			else
				dialog_item = dlgwnd;
			assert(dialog_item);
			result = 0;

			if (trigger->message)
				result = SendMessage(dialog_item, trigger->message, trigger->wparam, trigger->lparam);
			if (trigger->trigger_proc)
				result = trigger->trigger_proc(di, dialog_item, trigger->message, trigger->wparam, trigger->lparam);

			if (trigger->storeval)
				trigger->storeval(trigger->storeval_param, result);
		}
	}
}

//============================================================
//	dialog_proc
//============================================================

static INT_PTR CALLBACK dialog_proc(HWND dlgwnd, UINT msg, WPARAM wparam, LPARAM lparam)
{
	INT_PTR handled = TRUE;
	TCHAR buf[32];
	const char *str;
	WORD command;

	if (LOG_WINMSGS)
	{
		logerror("dialog_proc(): dlgwnd=0x%08x msg=0x%08x wparam=0x%08x lparam=0x%08x\n",
			(unsigned int) dlgwnd, (unsigned int) msg, (unsigned int) wparam, (unsigned int) lparam);
	}

	switch(msg) {
	case WM_INITDIALOG:
		SetWindowLongPtr(dlgwnd, WNDLONG_DIALOG, (LONG_PTR) lparam);
		dialog_trigger(dlgwnd, TRIGGER_INITDIALOG);
		break;

	case WM_COMMAND:
		command = LOWORD(wparam);

		GetWindowText((HWND) lparam, buf, sizeof(buf) / sizeof(buf[0]));
		str = T2A(buf);
		if (!strcmp(str, DLGTEXT_OK))
			command = IDOK;
		else if (!strcmp(str, DLGTEXT_CANCEL))
			command = IDCANCEL;
		else
			command = 0;

		switch(command) {
		case IDOK:
			dialog_trigger(dlgwnd, TRIGGER_APPLY);
			// fall through

		case IDCANCEL:
			EndDialog(dlgwnd, 0);
			break;

		default:
			handled = FALSE;
			break;
		}
		break;

	case WM_SYSCOMMAND:
		if (wparam == SC_CLOSE)
		{
			EndDialog(dlgwnd, 0);
		}
		else
		{
			handled = FALSE;
		}
		break;

	case WM_VSCROLL:
		if (lparam)
		{
			// this scroll message came from an actual scroll bar window;
			// pass it on
			SendMessage((HWND) lparam, msg, wparam, lparam);
		}
		else
		{
			// scroll the dialog
			win_scroll_window(dlgwnd, wparam, SB_VERT, SCROLL_DELTA_LINE);
		}
		break;

	default:
		handled = FALSE;
		break;
	}
	return handled;
}



//============================================================
//	dialog_write
//============================================================

static int dialog_write(struct _dialog_box *di, const void *ptr, size_t sz, int align)
{
	HGLOBAL newhandle;
	size_t base;
	UINT8 *mem;
	UINT8 *mem2;

	if (!di->handle)
	{
		newhandle = GlobalAlloc(GMEM_ZEROINIT, sz);
		base = 0;
	}
	else
	{
		base = di->handle_size;
		base += align - 1;
		base -= base % align;
		newhandle = GlobalReAlloc(di->handle, base + sz, GMEM_ZEROINIT);
		if (!newhandle)
		{
			newhandle = GlobalAlloc(GMEM_ZEROINIT, base + sz);
			if (newhandle)
			{
				mem = GlobalLock(di->handle);
				mem2 = GlobalLock(newhandle);
				memcpy(mem2, mem, base);
				GlobalUnlock(di->handle);
				GlobalUnlock(newhandle);
				GlobalFree(di->handle);
			}
		}
	}
	if (!newhandle)
		return 1;

	mem = GlobalLock(newhandle);
	memcpy(mem + base, ptr, sz);
	GlobalUnlock(newhandle);
	di->handle = newhandle;
	di->handle_size = base + sz;
	return 0;
}


//============================================================
//	dialog_write_string
//============================================================

static int dialog_write_string(dialog_box *di, const WCHAR *str)
{
	if (!str)
		str = L"";
	return dialog_write(di, str, (wcslen(str) + 1) * sizeof(WCHAR), 2);
}



//============================================================
//	dialog_write_item
//============================================================

static int dialog_write_item(dialog_box *di, DWORD style, short x, short y,
	 short width, short height, const WCHAR *str, const WCHAR *class_name, WORD *id)
{
	DLGITEMTEMPLATE item_template;
	UINT class_name_length;
	WORD w;

	memset(&item_template, 0, sizeof(item_template));
	item_template.style = style;
	item_template.x = x;
	item_template.y = y;
	item_template.cx = width;
	item_template.cy = height;
	item_template.id = di->item_count + 1;

	if (dialog_write(di, &item_template, sizeof(item_template), 4))
		return 1;

	if (*class_name == 0xffff)
		class_name_length = 4;
	else
		class_name_length = (wcslen(class_name) + 1) * sizeof(WCHAR);
	if (dialog_write(di, class_name, class_name_length, 2))
		return 1;

	if (dialog_write_string(di, str))
		return 1;

	w = 0;
	if (dialog_write(di, &w, sizeof(w), 2))
		return 1;

	di->item_count++;

	if (id)
		*id = di->item_count;
	return 0;
}



//============================================================
//	dialog_add_trigger
//============================================================

static int dialog_add_trigger(struct _dialog_box *di, WORD dialog_item,
	WORD trigger_flags, UINT message, trigger_function trigger_proc,
	WPARAM wparam, LPARAM lparam,
	void (*storeval)(void *param, int val), void *storeval_param)
{
	struct dialog_info_trigger *trigger;

	assert(di);
	assert(trigger_flags);

	trigger = (struct dialog_info_trigger *) pool_malloc(&di->mempool, sizeof(struct dialog_info_trigger));
	if (!trigger)
		return 1;

	trigger->next = NULL;
	trigger->trigger_flags = trigger_flags;
	trigger->dialog_item = dialog_item;
	trigger->message = message;
	trigger->trigger_proc = trigger_proc;
	trigger->wparam = wparam;
	trigger->lparam = lparam;
	trigger->storeval = storeval;
	trigger->storeval_param = storeval_param;

	if (di->trigger_last)
		di->trigger_last->next = trigger;
	else
		di->trigger_first = trigger;
	di->trigger_last = trigger;
	return 0;
}

//============================================================
//	dialog_add_object
//============================================================

static int dialog_add_object(dialog_box *di, HGDIOBJ obj)
{
	int i;
	struct dialog_object_pool *objpool;

	objpool = di->objpool;

	if (!di->objpool)
	{
		objpool = pool_malloc(&di->mempool, sizeof(struct dialog_object_pool));
		if (!objpool)
			return 1;
		memset(objpool, 0, sizeof(struct dialog_object_pool));
		di->objpool = objpool;
	}


	for (i = 0; i < sizeof(objpool->objects) / sizeof(objpool->objects[0]); i++)
	{
		if (!objpool->objects[i])
			break;
	}
	if (i >= sizeof(objpool->objects) / sizeof(objpool->objects[0]))
		return 1;

	objpool->objects[i] = obj;
	return 0;
}



//============================================================
//	dialog_scrollbar_init
//============================================================

static LRESULT dialog_scrollbar_init(dialog_box *dialog, HWND dlgwnd, UINT message, WPARAM wparam, LPARAM lparam)
{
	SCROLLINFO si;

	calc_dlgunits_multiple();

	memset(&si, 0, sizeof(si));
	si.cbSize = sizeof(si);
	si.nMin  = pixels_to_ydlgunits * 0;
	si.nMax  = pixels_to_ydlgunits * dialog->size_y;
	si.nPage = pixels_to_ydlgunits * MAX_DIALOG_HEIGHT;
	si.fMask = SIF_PAGE | SIF_RANGE;

	SetScrollInfo(dlgwnd, SB_VERT, &si, TRUE);
	return 0;
}



//============================================================
//	dialog_add_scrollbar
//============================================================

static int dialog_add_scrollbar(dialog_box *dialog)
{
	if (dialog_add_trigger(dialog, 0, TRIGGER_INITDIALOG, 0, dialog_scrollbar_init, 0, 0, NULL, NULL))
		return 1;

	dialog->style |= WS_VSCROLL;
	return 0;
}



//============================================================
//	dialog_prime
//============================================================

static void dialog_prime(dialog_box *di)
{
	DLGTEMPLATE *dlg_template;

	if (di->size_y > MAX_DIALOG_HEIGHT)
	{
		di->size_x += DIM_SCROLLBAR_WIDTH;
		dialog_add_scrollbar(di);
	}

	dlg_template = (DLGTEMPLATE *) GlobalLock(di->handle);
	dlg_template->cdit = di->item_count;
	dlg_template->cx = di->size_x;
	dlg_template->cy = (di->size_y > MAX_DIALOG_HEIGHT) ? MAX_DIALOG_HEIGHT : di->size_y;
	dlg_template->style = di->style;
	GlobalUnlock(di->handle);
}



//============================================================
//	dialog_get_combo_value
//============================================================

static LRESULT dialog_get_combo_value(dialog_box *dialog, HWND dialog_item, UINT message, WPARAM wparam, LPARAM lparam)
{
	int idx;
	idx = SendMessage(dialog_item, CB_GETCURSEL, 0, 0);
	if (idx == CB_ERR)
		return 0;
	return SendMessage(dialog_item, CB_GETITEMDATA, idx, 0);
}



//============================================================
//	dialog_get_adjuster_value
//============================================================

static LRESULT dialog_get_adjuster_value(dialog_box *dialog, HWND dialog_item, UINT message, WPARAM wparam, LPARAM lparam)
{
	TCHAR buf[32];
	GetWindowText(dialog_item, buf, sizeof(buf) / sizeof(buf[0]));
	return _ttoi(buf);
}



//============================================================
//	dialog_get_slider_value
//============================================================

static LRESULT dialog_get_slider_value(dialog_box *dialog, HWND dialog_item, UINT message, WPARAM wparam, LPARAM lparam)
{
	return SendMessage(dialog_item, TBM_GETPOS, 0, 0);
}



//============================================================
//	win_dialog_init
//============================================================

dialog_box *win_dialog_init(const char *title, const struct dialog_layout *layout)
{
	struct _dialog_box *di;
	DLGTEMPLATE dlg_template;
	WORD w[2];

	// use default layout if not specified
	if (!layout)
		layout = &default_layout;

	// create the dialog structure
	di = malloc(sizeof(struct _dialog_box));
	if (!di)
		goto error;
	memset(di, 0, sizeof(*di));

	di->layout = layout;
	pool_init(&di->mempool);

	memset(&dlg_template, 0, sizeof(dlg_template));
	dlg_template.style = di->style = DIALOG_STYLE;
	dlg_template.x = 10;
	dlg_template.y = 10;
	if (dialog_write(di, &dlg_template, sizeof(dlg_template), 4))
		goto error;

	w[0] = 0;
	w[1] = 0;
	if (dialog_write(di, w, sizeof(w), 2))
		goto error;

	if (dialog_write_string(di, A2W(title)))
		goto error;

	// set the font, if necessary
	if (di->style & DS_SETFONT)
	{
		w[0] = FONT_SIZE;
		if (dialog_write(di, w, sizeof(w[0]), 2))
			goto error;
		if (dialog_write_string(di, FONT_FACE))
			goto error;
	}

	return di;

error:
	if (di)
		win_dialog_exit(di);
	return NULL;
}



//============================================================
//	dialog_new_control
//============================================================

static void dialog_new_control(struct _dialog_box *di, short *x, short *y)
{
	*x = di->pos_x + DIM_HORIZONTAL_SPACING;
	*y = di->pos_y + DIM_VERTICAL_SPACING;
}



//============================================================
//	dialog_finish_control
//============================================================

static void dialog_finish_control(struct _dialog_box *di, short x, short y)
{
	di->pos_y = y;

	// update dialog size
	if (x > di->size_x)
		di->size_x = x;
	if (y > di->size_y)
		di->size_y = y;
	if (x > di->cursize_x)
		di->cursize_x = x;
	if (y > di->cursize_y)
		di->cursize_y = y;
}



//============================================================
//	dialog_combo_changed
//============================================================

static LRESULT dialog_combo_changed(dialog_box *dialog, HWND dlgitem, UINT message, WPARAM wparam, LPARAM lparam)
{
	dialog_itemchangedproc changed = (dialog_itemchangedproc) wparam;
	changed(dialog, dlgitem, (void *) lparam);
	return 0;
}



//============================================================
//	win_dialog_add_active_combobox
//============================================================

int win_dialog_add_active_combobox(dialog_box *dialog, const char *item_label, int default_value,
	dialog_itemstoreval storeval, void *storeval_param,
	dialog_itemchangedproc changed, void *changed_param)
{
	short x;
	short y;

	dialog_new_control(dialog, &x, &y);

	if (dialog_write_item(dialog, WS_CHILD | WS_VISIBLE | SS_LEFT,
			x, y, dialog->layout->label_width, DIM_COMBO_ROW_HEIGHT, A2W(item_label), DLGITEM_STATIC, NULL))
		goto error;

	y += DIM_BOX_VERTSKEW;

	x += dialog->layout->label_width + DIM_HORIZONTAL_SPACING;
	if (dialog_write_item(dialog, WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_TABSTOP | CBS_DROPDOWNLIST,
			x, y, dialog->layout->combo_width, DIM_COMBO_ROW_HEIGHT * 8, NULL, DLGITEM_COMBOBOX, NULL))
		goto error;
	dialog->combo_string_count = 0;
	dialog->combo_default_value = default_value;

	// add the trigger invoked when the apply button is pressed
	if (dialog_add_trigger(dialog, dialog->item_count, TRIGGER_APPLY, 0, dialog_get_combo_value, 0, 0, storeval, storeval_param))
		goto error;

	// if appropriate, add the optional changed trigger
	if (changed)
	{
		if (dialog_add_trigger(dialog, dialog->item_count, TRIGGER_INITDIALOG | TRIGGER_CHANGED, 0, dialog_combo_changed, (WPARAM) changed, (LPARAM) changed_param, NULL, NULL))
			goto error;
	}

	x += dialog->layout->combo_width + DIM_HORIZONTAL_SPACING;
	y += DIM_COMBO_ROW_HEIGHT + DIM_VERTICAL_SPACING * 2;

	dialog_finish_control(dialog, x, y);
	return 0;

error:
	return 1;
}



//============================================================
//	win_dialog_add_combobox
//============================================================

int win_dialog_add_combobox(dialog_box *dialog, const char *item_label, int default_value,
	void (*storeval)(void *param, int val), void *storeval_param)
{
	return win_dialog_add_active_combobox(dialog, item_label, default_value,
		storeval, storeval_param, NULL, NULL);
}



//============================================================
//	win_dialog_add_combobox_item
//============================================================

int win_dialog_add_combobox_item(dialog_box *dialog, const char *item_label, int item_data)
{
	// create our own copy of the string
	if (item_label)
	{
		item_label = pool_strdup(&dialog->mempool, item_label);
		if (!item_label)
			return 1;
	}

	if (dialog_add_trigger(dialog, dialog->item_count, TRIGGER_INITDIALOG, CB_ADDSTRING, NULL, 0, (LPARAM) item_label, NULL, NULL))
		return 1;
	dialog->combo_string_count++;
	if (dialog_add_trigger(dialog, dialog->item_count, TRIGGER_INITDIALOG, CB_SETITEMDATA, NULL, dialog->combo_string_count-1, (LPARAM) item_data, NULL, NULL))
		return 1;
	if (item_data == dialog->combo_default_value)
	{
		if (dialog_add_trigger(dialog, dialog->item_count, TRIGGER_INITDIALOG, CB_SETCURSEL, NULL, dialog->combo_string_count-1, 0, NULL, NULL))
			return 1;
	}
	return 0;
}



//============================================================
//	adjuster_sb_wndproc
//============================================================

struct adjuster_sb_stuff
{
	WNDPROC oldwndproc;
	int min_value;
	int max_value;
};

static INT_PTR CALLBACK adjuster_sb_wndproc(HWND sbwnd, UINT msg, WPARAM wparam, LPARAM lparam)
{
	INT_PTR result;
	struct adjuster_sb_stuff *stuff;
	TCHAR buf[64];
	HWND dlgwnd, editwnd;
	int value, id;
	LONG_PTR l;
	
	l = GetWindowLongPtr(sbwnd, GWLP_USERDATA);
	stuff = (struct adjuster_sb_stuff *) l;

	if (msg == WM_VSCROLL)
	{
		id = GetWindowLong(sbwnd, GWL_ID);
		dlgwnd = GetParent(sbwnd);
		editwnd = GetDlgItem(dlgwnd, id - 1);
		GetWindowText(editwnd, buf, sizeof(buf) / sizeof(buf[0]));
		value = _ttoi(buf);

		switch(wparam)
		{
			case SB_LINEDOWN:
			case SB_PAGEDOWN:
				value--;
				break;

			case SB_LINEUP:
			case SB_PAGEUP:
				value++;
				break;
		}

		if (value < stuff->min_value)
			value = stuff->min_value;
		else if (value > stuff->max_value)
			value = stuff->max_value;
		_sntprintf(buf, sizeof(buf) / sizeof(buf[0]), TEXT("%d"), value);
		SetWindowText(editwnd, buf);
		result = 0;
	}
	else
	{
		result = call_windowproc(stuff->oldwndproc, sbwnd, msg, wparam, lparam);
	}
	return result;
}



//============================================================
//	adjuster_sb_setup
//============================================================

static LRESULT adjuster_sb_setup(dialog_box *dialog, HWND sbwnd, UINT message, WPARAM wparam, LPARAM lparam)
{
	struct adjuster_sb_stuff *stuff;
	LONG_PTR l;

	stuff = (struct adjuster_sb_stuff *) win_dialog_malloc(dialog, sizeof(struct adjuster_sb_stuff));
	if (!stuff)
		return 1;
	stuff->min_value = (WORD) (lparam >> 0);
	stuff->max_value = (WORD) (lparam >> 16);

	l = (LONG_PTR) stuff;
	SetWindowLongPtr(sbwnd, GWLP_USERDATA, l);
	l = (LONG_PTR) adjuster_sb_wndproc;
	l = SetWindowLongPtr(sbwnd, GWLP_WNDPROC, l);
	stuff->oldwndproc = (WNDPROC) l;
	return 0;
}



//============================================================
//	win_dialog_add_adjuster
//============================================================

int win_dialog_add_adjuster(dialog_box *dialog, const char *item_label, int default_value,
	int min_value, int max_value, BOOL is_percentage,
	dialog_itemstoreval storeval, void *storeval_param)
{
	short x;
	short y;
	TCHAR buf[32];
	TCHAR *s;

	dialog_new_control(dialog, &x, &y);

	if (dialog_write_item(dialog, WS_CHILD | WS_VISIBLE | SS_LEFT,
			x, y, dialog->layout->label_width, DIM_ADJUSTER_HEIGHT, A2W(item_label), DLGITEM_STATIC, NULL))
		goto error;
	x += dialog->layout->label_width + DIM_HORIZONTAL_SPACING;

	y += DIM_BOX_VERTSKEW;

	if (dialog_write_item(dialog, WS_CHILD | WS_VISIBLE | WS_TABSTOP | WS_BORDER | ES_NUMBER,
			x, y, dialog->layout->combo_width - DIM_ADJUSTER_SCR_WIDTH, DIM_ADJUSTER_HEIGHT, NULL, DLGITEM_EDIT, NULL))
		goto error;
	x += dialog->layout->combo_width - DIM_ADJUSTER_SCR_WIDTH;

	_snprintf(buf, sizeof(buf) / sizeof(buf[0]),
		is_percentage ? TEXT("%d%%") : TEXT("%d"),
		default_value);
	s = win_dialog_tcsdup(dialog, buf);
	if (!s)
		return 1;
	if (dialog_add_trigger(dialog, dialog->item_count, TRIGGER_INITDIALOG, WM_SETTEXT, NULL,
			0, (LPARAM) s, NULL, NULL))
		goto error;

	// add the trigger invoked when the apply button is pressed
	if (dialog_add_trigger(dialog, dialog->item_count, TRIGGER_APPLY, 0, dialog_get_adjuster_value, 0, 0, storeval, storeval_param))
		goto error;

	if (dialog_write_item(dialog, WS_CHILD | WS_VISIBLE | WS_TABSTOP | SBS_VERT,
			x, y, DIM_ADJUSTER_SCR_WIDTH, DIM_ADJUSTER_HEIGHT, NULL, DLGITEM_SCROLLBAR, NULL))
		goto error;
	x += DIM_ADJUSTER_SCR_WIDTH + DIM_HORIZONTAL_SPACING;

	if (dialog_add_trigger(dialog, dialog->item_count, TRIGGER_INITDIALOG, 0, adjuster_sb_setup,
			0, MAKELONG(min_value, max_value), NULL, NULL))
		return 1;

	y += DIM_COMBO_ROW_HEIGHT + DIM_VERTICAL_SPACING * 2;

	dialog_finish_control(dialog, x, y);
	return 0;

error:
	return 1;
}



//============================================================
//	win_dialog_add_slider
//============================================================

int win_dialog_add_slider(dialog_box *dialog, const char *item_label, int default_value,
	int min_value, int max_value,
	dialog_itemstoreval storeval, void *storeval_param)
{
	short x;
	short y;

	dialog_new_control(dialog, &x, &y);

	if (dialog_write_item(dialog, WS_CHILD | WS_VISIBLE | SS_LEFT,
			x, y, dialog->layout->label_width, DIM_SLIDER_ROW_HEIGHT, A2W(item_label), DLGITEM_STATIC, NULL))
		goto error;

	y += DIM_BOX_VERTSKEW;

	x += dialog->layout->label_width + DIM_HORIZONTAL_SPACING;
	if (dialog_write_item(dialog, WS_CHILD | WS_VISIBLE | WS_TABSTOP | TBS_NOTICKS | TBS_HORZ | TBS_BOTH,
			x, y, dialog->layout->combo_width, DIM_SLIDER_ROW_HEIGHT, NULL, TRACKBAR_CLASSW, NULL))
		goto error;

	x += dialog->layout->combo_width + DIM_HORIZONTAL_SPACING;
	y += DIM_SLIDER_ROW_HEIGHT + DIM_VERTICAL_SPACING * 2;

	if (dialog_add_trigger(dialog, dialog->item_count, TRIGGER_INITDIALOG, TBM_SETRANGE, NULL, 0,
			(LPARAM) MAKELONG(min_value, max_value), NULL, NULL))
		goto error;

	if (dialog_add_trigger(dialog, dialog->item_count, TRIGGER_INITDIALOG, TBM_SETPOS, NULL, 0,
			(LPARAM) default_value, NULL, NULL))
		goto error;

	// add the trigger invoked when the apply button is pressed
	if (dialog_add_trigger(dialog, dialog->item_count, TRIGGER_APPLY, 0, dialog_get_slider_value, 0, 0, storeval, storeval_param))
		goto error;

	dialog_finish_control(dialog, x, y);
	return 0;

error:
	return 1;
}



//============================================================
//	seqselect_settext
//============================================================

static void seqselect_settext(HWND editwnd)
{
	struct seqselect_stuff *stuff;
	LONG_PTR lp;
	char buf[512];

	lp = GetWindowLongPtr(editwnd, GWLP_USERDATA);
	stuff = (struct seqselect_stuff *) lp;
	seq_name(&stuff->newcode, buf, sizeof(buf) / sizeof(buf[0]));
	SetWindowText(editwnd, A2T(buf));

	if (GetFocus() == editwnd)
		SendMessage(editwnd, EM_SETSEL, 0, -1);
}



//============================================================
//	seqselect_wndproc
//============================================================

static INT_PTR CALLBACK seqselect_wndproc(HWND editwnd, UINT msg, WPARAM wparam, LPARAM lparam)
{
	struct seqselect_stuff *stuff;
	INT_PTR result = 0;
	LONG_PTR lp;
	BOOL call_baseclass = TRUE;
	int ret;

	lp = GetWindowLongPtr(editwnd, GWLP_USERDATA);
	stuff = (struct seqselect_stuff *) lp;

	switch(msg) {
	case WM_KEYDOWN:
	case WM_SYSKEYDOWN:
	case WM_CHAR:
	case WM_KEYUP:
	case WM_SYSKEYUP:
		result = 1;
		call_baseclass = FALSE;
		break;

	case WM_TIMER:
		if (wparam == TIMER_ID)
		{
			// we are in the middle of selecting a seq; we need to poll
			win_poll_input();

			ret = seq_read_async(&stuff->newcode, stuff->record_first_insert);
			if (ret >= 0)
			{
				stuff->record_first_insert = ret != 0;
				seqselect_settext(editwnd);
				seq_read_async_start(stuff->is_analog);
			}
			result = 0;
			call_baseclass = FALSE;
		}
		break;

	case WM_SETFOCUS:
	case WM_KILLFOCUS:
		// unselect the current seq; if appropriate
		if (stuff->timer)
		{
			KillTimer(editwnd, stuff->timer);
			stuff->timer = 0;
		}

		if (msg == WM_SETFOCUS)
		{
			// we are selecting a seq; begin a timer
			seq_read_async_start(stuff->is_analog);
			stuff->record_first_insert = 1;
			stuff->timer = SetTimer(editwnd, TIMER_ID, 100, (TIMERPROC) NULL);
		}
		break;

	case WM_LBUTTONDOWN:
	case WM_RBUTTONDOWN:
		SetFocus(editwnd);
		SendMessage(editwnd, EM_SETSEL, 0, -1);
		call_baseclass = FALSE;
		result = 0;
		break;
	}

	if (call_baseclass)
		result = call_windowproc(stuff->oldwndproc, editwnd, msg, wparam, lparam);
	return result;
}



//============================================================
//	seqselect_setup
//============================================================

static LRESULT seqselect_setup(dialog_box *dialog, HWND editwnd, UINT message, WPARAM wparam, LPARAM lparam)
{
	struct seqselect_stuff *stuff = (struct seqselect_stuff *) lparam;
	LONG_PTR lp;

	memcpy(&stuff->newcode, stuff->code, sizeof(stuff->newcode));
	lp = SetWindowLongPtr(editwnd, GWLP_WNDPROC, (LONG_PTR) seqselect_wndproc);
	stuff->oldwndproc = (WNDPROC) lp;
	SetWindowLongPtr(editwnd, GWLP_USERDATA, lparam);
	seqselect_settext(editwnd);
	return 0;
}



//============================================================
//	seqselect_apply
//============================================================

static LRESULT seqselect_apply(dialog_box *dialog, HWND editwnd, UINT message, WPARAM wparam, LPARAM lparam)
{
	struct seqselect_stuff *stuff;
	LONG_PTR lp;

	lp = GetWindowLongPtr(editwnd, GWLP_USERDATA);
	stuff = (struct seqselect_stuff *) lp;
	memcpy(stuff->code, &stuff->newcode, sizeof(*(stuff->code)));
	return 0;
}

//============================================================
//	dialog_add_single_seqselect
//============================================================

static int dialog_add_single_seqselect(struct _dialog_box *di, short x, short y,
	short cx, short cy, input_port_entry *port, int is_analog, int seq)
{
	struct seqselect_stuff *stuff;
	input_seq *code;

	code = input_port_seq(port, seq);

	if (dialog_write_item(di, WS_CHILD | WS_VISIBLE | SS_ENDELLIPSIS | ES_CENTER | SS_SUNKEN,
			x, y, cx, cy, NULL, DLGITEM_EDIT, NULL))
		return 1;
	stuff = (struct seqselect_stuff *) pool_malloc(&di->mempool, sizeof(struct seqselect_stuff));
	if (!stuff)
		return 1;
	memset(stuff, 0, sizeof(*stuff));
	stuff->code = code;
	stuff->pos = di->item_count;
	stuff->timer = 0;
	stuff->is_analog = is_analog;
	if (dialog_add_trigger(di, di->item_count, TRIGGER_INITDIALOG, 0, seqselect_setup, di->item_count, (LPARAM) stuff, NULL, NULL))
		return 1;
	if (dialog_add_trigger(di, di->item_count, TRIGGER_APPLY, 0, seqselect_apply, 0, 0, NULL, NULL))
		return 1;
	return 0;
}



//============================================================
//	win_dialog_add_seqselect
//============================================================

int win_dialog_add_portselect(dialog_box *dialog, input_port_entry *port, const RECT *r)
{
	dialog_box *di = dialog;
	short x;
	short y;
	short height;
	short width;
	const char *port_name;
	const WCHAR *this_port_name;
	WCHAR *s;
	int seq;
	int seq_count = 0;
	const WCHAR *port_suffix[3];
	int seq_types[3];
	int is_analog[3];
	int len, i;

	port_name = input_port_name(port);
	assert(port_name);
	
	if (port_type_is_analog(port->type))
	{
		seq_types[seq_count] = SEQ_TYPE_STANDARD;
		port_suffix[seq_count] = L" Analog";
		is_analog[seq_count] = TRUE;
		seq_count++;

		seq_types[seq_count] = SEQ_TYPE_DECREMENT;
		port_suffix[seq_count] = L" Dec";
		is_analog[seq_count] = FALSE;
		seq_count++;

		seq_types[seq_count] = SEQ_TYPE_INCREMENT;
		port_suffix[seq_count] = L" Inc";
		is_analog[seq_count] = FALSE;
		seq_count++;
	}
	else
	{
		seq_types[seq_count] = SEQ_TYPE_STANDARD;
		port_suffix[seq_count] = NULL;
		is_analog[seq_count] = FALSE;
		seq_count++;
	}

	for (seq = 0; seq < seq_count; seq++)
	{
		// create our local name for this entry; also convert from
		// MAME strings to wide strings
		len = strlen(port_name);
		s = (WCHAR *) alloca((len + (port_suffix[seq] ? wcslen(port_suffix[seq])
			: 0) + 1) * sizeof(WCHAR));
		for (i = 0; i < len; i++)
			s[i] = unicode_from_mamechar(port_name[i]);
		s[len] = '\0';

		if (port_suffix[seq])
			wcscpy(s + len, port_suffix[seq]);
		this_port_name = s;

		if (!r)
		{
			// no positions specified
			dialog_new_control(di, &x, &y);

			if (dialog_write_item(di, WS_CHILD | WS_VISIBLE | SS_LEFT | SS_NOPREFIX, x, y, 
					dialog->layout->label_width, DIM_NORMAL_ROW_HEIGHT, this_port_name, DLGITEM_STATIC, NULL))
				return 1;
			x += dialog->layout->label_width + DIM_HORIZONTAL_SPACING;

			if (dialog_add_single_seqselect(di, x, y, DIM_EDIT_WIDTH, DIM_NORMAL_ROW_HEIGHT,
					port, is_analog[seq], seq_types[seq]))
				return 1;
			y += DIM_VERTICAL_SPACING + DIM_NORMAL_ROW_HEIGHT;
			x += DIM_EDIT_WIDTH + DIM_HORIZONTAL_SPACING;

			dialog_finish_control(di, x, y);
		}
		else
		{
			// positions specified
			x = r[seq].left;
			y = r[seq].top;
			width = r[seq].right - r[seq].left;
			height = r[seq].bottom - r[seq].top;

			calc_dlgunits_multiple();
			x		/= pixels_to_xdlgunits;
			y		/= pixels_to_ydlgunits;
			width	/= pixels_to_xdlgunits;
			height	/= pixels_to_ydlgunits;

			if (dialog_add_single_seqselect(di, x, y, width, height, 
					port, is_analog[seq], seq_types[seq]))
				return 1;
		}
	}
	return 0;
}



//============================================================
//	win_dialog_add_notification
//============================================================

int win_dialog_add_notification(dialog_box *dialog, UINT notification,
	dialog_notification callback, void *param)
{
	// hack
	assert(!dialog->notify_callback);
	dialog->notify_code = notification;
	dialog->notify_callback = callback;
	dialog->notify_param = param;
	return 0;
}



//============================================================
//	win_dialog_add_standard_buttons
//============================================================

int win_dialog_add_standard_buttons(dialog_box *dialog)
{
	dialog_box *di = dialog;
	short x;
	short y;

	x = di->size_x - DIM_HORIZONTAL_SPACING - DIM_BUTTON_WIDTH;
	y = di->size_y + DIM_VERTICAL_SPACING;

	if (dialog_write_item(di, WS_CHILD | WS_VISIBLE | SS_LEFT,
			x, y, DIM_BUTTON_WIDTH, DIM_BUTTON_ROW_HEIGHT, A2W(DLGTEXT_CANCEL), DLGITEM_BUTTON, NULL))
		return 1;

	x -= DIM_HORIZONTAL_SPACING + DIM_BUTTON_WIDTH;
	if (dialog_write_item(di, WS_CHILD | WS_VISIBLE | SS_LEFT,
			x, y, DIM_BUTTON_WIDTH, DIM_BUTTON_ROW_HEIGHT, A2W(DLGTEXT_OK), DLGITEM_BUTTON, NULL))
		return 1;
	di->size_y += DIM_BUTTON_ROW_HEIGHT + DIM_VERTICAL_SPACING * 2;
	return 0;
}



//============================================================
//	create_png_bitmap
//============================================================

static HBITMAP create_png_bitmap(const png_info *png)
{
	HBITMAP bitmap;
	BITMAPINFOHEADER bitmap_header;
	UINT8 *bitmap_data;
	UINT8 *src;
	UINT8 *dst;
	int x, y;
	HDC dc;
		
	memset(&bitmap_header, 0, sizeof(bitmap_header));
	bitmap_header.biSize = sizeof(BITMAPINFOHEADER);
	bitmap_header.biWidth = png->width;
	bitmap_header.biHeight = -png->height;
	bitmap_header.biPlanes = 1;
	bitmap_header.biBitCount = 24;
	bitmap_header.biCompression = BI_RGB;

	bitmap_data = alloca(png->width * png->height * 3);
	src = png->image;
	dst = bitmap_data;
	for (y = 0; y < png->height; y++)
	{
		for (x = 0; x < png->width; x++)
		{
			switch(png->color_type) {
			case 0:		// 8bpp grayscale case
				dst[2] = src[0];
				dst[1] = src[0];
				dst[0] = src[0];
				src++;
				break;

			case 2:		// 32bpp non-alpha case
				dst[2] = src[0];
				dst[1] = src[1];
				dst[0] = src[2];
				src += 3;
				break;

			case 3:		// 8bpp palettized case
				assert(png->palette);
				dst[2] = png->palette[*src * 3 + 0];
				dst[1] = png->palette[*src * 3 + 1];
				dst[0] = png->palette[*src * 3 + 2];
				src++;
				break;
			}
			dst += 3;
		}
	}

	dc = GetDC(NULL);
	bitmap = CreateDIBitmap(dc, &bitmap_header, CBM_INIT, bitmap_data, (BITMAPINFO *) &bitmap_header, DIB_RGB_COLORS);
	ReleaseDC(NULL, dc);
	return bitmap;
}

//============================================================
//	win_dialog_add_image
//============================================================

int win_dialog_add_image(dialog_box *dialog, const png_info *png)
{
	WORD id;
	HBITMAP bitmap;
	short x, y;
	short width, height;

	calc_dlgunits_multiple();
	width = png->width / pixels_to_xdlgunits;
	height = png->height / pixels_to_ydlgunits;

	bitmap = create_png_bitmap(png);
	if (!bitmap)
		return 1;

	dialog_new_control(dialog, &x, &y);
	if (dialog_write_item(dialog, WS_CHILD | WS_VISIBLE | SS_LEFT | SS_BITMAP,
			x, y, width, height, NULL, DLGITEM_STATIC, &id))
		return 1;
	if (dialog_add_trigger(dialog, id, TRIGGER_INITDIALOG, STM_SETIMAGE, NULL, (WPARAM)IMAGE_BITMAP, (LPARAM) bitmap, NULL, NULL))
		return 1;
	if (dialog_add_object(dialog, bitmap))
		return 1;
	x += width;
	y += height;
	dialog_finish_control(dialog, x, y);
	return 0;
}

//============================================================
//	win_dialog_add_separator
//============================================================

int win_dialog_add_separator(dialog_box *dialog)
{
	dialog->home_y = dialog->cursize_y;
	dialog->cursize_x = 0;
	return 0;
}

//============================================================
//	win_dialog_exit
//============================================================

void win_dialog_exit(dialog_box *dialog)
{
	int i;
	struct dialog_object_pool *objpool;

	assert(dialog);

	objpool = dialog->objpool;
	if (objpool)
	{
		for (i = 0; i < sizeof(objpool->objects) / sizeof(objpool->objects[0]); i++)
			DeleteObject(objpool->objects[i]);
	}

	if (dialog->handle)
		GlobalFree(dialog->handle);
	pool_exit(&dialog->mempool);
	free(dialog);
}



//============================================================
//	win_dialog_malloc
//============================================================

void *win_dialog_malloc(dialog_box *dialog, size_t size)
{
	return pool_malloc(&dialog->mempool, size);
}



//============================================================
//	win_dialog_strdup
//============================================================

char *win_dialog_strdup(dialog_box *dialog, const char *s)
{
	return pool_strdup(&dialog->mempool, s);
}



//============================================================
//	before_display_dialog
//============================================================

static void before_display_dialog(void)
{
	extern void win_timer_enable(int enabled);

#ifdef UNDER_CE
	// on WinCE, suspend GAPI
	gx_suspend();
#else
	// on Windows, suspend DirectX
	extern int win_suspend_directx;
	win_suspend_directx = 1;
#endif

	// disable sound while in the dialog
	osd_sound_enable(0);

	// disable the timer while in the dialog
	win_timer_enable(0);
}



//============================================================
//	after_display_dialog
//============================================================

static void after_display_dialog(void)
{
	extern void win_timer_enable(int enabled);

#ifdef UNDER_CE
	// on WinCE, resume GAPI
	gx_resume();
#else
	// on Windows, suspend DirectX
	extern int win_suspend_directx;
	win_suspend_directx = 0;
#endif

	// reenable timer
	win_timer_enable(1);

	// reenable sound
	osd_sound_enable(1);
}



//============================================================
//	win_dialog_runmodal
//============================================================

void win_dialog_runmodal(dialog_box *dialog)
{
	struct _dialog_box *di;
	
	di = (struct _dialog_box *) dialog;
	assert(di);

	// finishing touches on the dialog
	dialog_prime(di);

	// show the dialog
	before_display_dialog();
	if (GetVersion() & 0x80000000)
		DialogBoxIndirectParamA(NULL, di->handle, win_video_window, dialog_proc, (LPARAM) di);
	else
		DialogBoxIndirectParamW(NULL, di->handle, win_video_window, dialog_proc, (LPARAM) di);
	after_display_dialog();
}



//============================================================
//	file_dialog_hook
//============================================================

static UINT_PTR CALLBACK file_dialog_hook(HWND dlgwnd, UINT message, WPARAM wparam, LPARAM lparam)
{
	OPENFILENAME *ofn;
	dialog_box *dialog;
	UINT_PTR rc = 0;
	LPNMHDR notify;
	LONG_PTR l;

	switch(message) {
	case WM_INITDIALOG:
		ofn = (OPENFILENAME *) lparam;
		dialog = (dialog_box *) ofn->lCustData;

		SetWindowLongPtr(dlgwnd, WNDLONG_DIALOG, (LONG_PTR) dialog);
		dialog_trigger(dlgwnd, TRIGGER_INITDIALOG);
		rc = 1;

		// hack
		if (dialog->notify_callback && (dialog->notify_code == CDN_TYPECHANGE))
			dialog->notify_callback(dialog, dlgwnd, NULL, dialog->notify_param);
		break;

	case WM_NOTIFY:
		notify = (LPNMHDR) lparam;
		switch(notify->code) {
		case CDN_FILEOK:
			dialog_trigger(dlgwnd, TRIGGER_APPLY);
			break;
		}

		// hack
		l = GetWindowLongPtr(dlgwnd, WNDLONG_DIALOG);
		dialog = (dialog_box *) l;
		if (dialog->notify_callback && (notify->code == dialog->notify_code))
			dialog->notify_callback(dialog, dlgwnd, notify, dialog->notify_param);
		break;

	case WM_COMMAND:
		switch(HIWORD(wparam)) {
		case CBN_SELCHANGE:
			dialog_trigger(dlgwnd, TRIGGER_CHANGED);
			break;
		}
		break;
	}
	return rc;
}



//============================================================
//	win_file_dialog
//============================================================

BOOL win_file_dialog(HWND parent, enum file_dialog_type dlgtype, dialog_box *custom_dialog, const char *filter,
	const char *initial_dir, char *filename, size_t filename_len)
{
	OPENFILENAME ofn;
	BOOL result;
#ifdef UNICODE
	WCHAR buf[MAX_PATH];
#endif

	memset(&ofn, 0, sizeof(ofn));
	ofn.lStructSize = sizeof(ofn);
	ofn.hwndOwner = parent;
	ofn.Flags = OFN_EXPLORER | OFN_NOCHANGEDIR | OFN_PATHMUSTEXIST | OFN_HIDEREADONLY;

	if (filter)
		ofn.lpstrFilter = A2T(filter);
	if (initial_dir)
		ofn.lpstrInitialDir = A2T(initial_dir);
	if (dlgtype == FILE_DIALOG_OPEN)
		ofn.Flags |= OFN_FILEMUSTEXIST;

	if (custom_dialog)
	{
		custom_dialog->style = WS_CHILD | WS_CLIPSIBLINGS | DS_3DLOOK | DS_CONTROL | DS_SETFONT;
		dialog_prime(custom_dialog);

		ofn.Flags |= OFN_ENABLETEMPLATEHANDLE | OFN_ENABLEHOOK;
		ofn.hInstance = custom_dialog->handle;
		ofn.lCustData = (LPARAM) custom_dialog;
		ofn.lpfnHook = file_dialog_hook;
	}

#ifdef UNICODE
	mbstowcs(buf, filename, strlen(filename) + 1);
	ofn.nMaxFile = sizeof(buf) / sizeof(buf[0]);
#else
	ofn.lpstrFile = filename;
	ofn.nMaxFile = filename_len;
#endif

	before_display_dialog();

	switch(dlgtype) {
	case FILE_DIALOG_OPEN:
		result = GetOpenFileName(&ofn);
		break;

	case FILE_DIALOG_SAVE:
		result = GetSaveFileName(&ofn);
		break;

	default:
		assert(FALSE);
		result = FALSE;
		break;
	}

	after_display_dialog();

#ifdef UNICODE
	strcpyz(filename, buf, filename_len);
#endif
	return result;
}


