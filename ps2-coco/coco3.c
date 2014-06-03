#include "coco3.h"
#include "keyboard.h"


kbd_matrix ALL_CLEAR;


//------------------------------------------------------------------------------------------
// intialize the coco3 matrix hardware
//------------------------------------------------------------------------------------------
void coco3_init(void)
{
	ALL_CLEAR.asc = 0xff;
	ALL_CLEAR.msb = 0xff;
	ALL_CLEAR.lsb = 0xff;

	// disable the USART
	UCSR0B = 0;

	// setup Timer0:
	// CTC (Clear Timer on Compare Match mode)
	// TOP set by OCR0A register
	TCCR0A |= (1<<WGM01);
	// clocked from CLK/1024
	// which is 14745600/1024, or 14400 increments per second
	TCCR0B |= (1<<CS02) | (1<<CS00);
	// set TOP to 143
	// because it counts 0, 1, 2, ... 142, 143, 0, 1, 2 ...
	// so 0 through 143 equals 144 events
	OCR0A = 143;

	// signal all pins of matrix data port as output
	COCO3_MATRIX_DDR = 0xFF;

	// set all data bits high
	COCO3_MATRIX_PORT = 0xFF;

	// set the msb, lsb and strobe bits as output
	COCO3_CTRL_DDR |= _BV(COCO3_CTRL_MSB_BIT) | _BV(COCO3_CTRL_LSB_BIT) | _BV(COCO3_CTRL_ENABLE);

	// set the msb, lsb and strobe bits as high
	COCO3_CTRL_PORT |= _BV(COCO3_CTRL_MSB_BIT) | _BV(COCO3_CTRL_LSB_BIT) | _BV(COCO3_CTRL_ENABLE);

	// disable the matrix
	COCO3_MSB_LOW;
	COCO3_LSB_LOW;
	COCO3_MTX_OFF;
}

//------------------------------------------------------------------------------------------
// this timer just turns off the matrix
//------------------------------------------------------------------------------------------
SIGNAL(SIG_OUTPUT_COMPARE0A)
{
	counter--;
	if (counter > 0)
		return;

	COCO3_MTX_OFF;
	TIMSK0 &= ~(1<<OCIE0A); // turn off timer
}

//------------------------------------------------------------------------------------------
// maps a scan code to a coco3 lookup table and writes the keystroke to the coco hardware
//------------------------------------------------------------------------------------------
void coco3_keystroke (uint8_t scancode, uint16_t status)
{
	kbd_matrix matrix;

	// call the map function to map the scancode to a keyboard matrix value
	uint8_t match = coco3_map_scancode (scancode, status, &matrix);
	if (0xff == match)
	{
		matrix.msb = 0xff;
		matrix.lsb = 0xff;
		matrix.asc = 0xff;
		return;
	}

	//
	// set additional status values
	//

	if (status & KBD_SHIFT)
	{
		matrix.lsb &= 0x7F;
		matrix.msb &= 0x7F;
	}

	if (status & KBD_CTRL)
	{
		matrix.lsb &= 0x7F;
		matrix.msb &= 0xEF;
	}

	if (status & KBD_ALT)
	{
		matrix.lsb &= 0x7F;
		matrix.msb &= 0xF7;
	}

	// send matrix to keyboard
	coco3_write_matrix (matrix);
}

//------------------------------------------------------------------------------------------
// sends the break key press to the coco3
//------------------------------------------------------------------------------------------
void coco3_break ()
{
	kbd_matrix matrix;
	matrix.msb = 0xFB;	// 1111 1011 = pin 11 low
	matrix.lsb = 0x7F;	// 0111 1111 = pin 8 low
	matrix.asc = '^';
	coco3_write_matrix (matrix);
}

//------------------------------------------------------------------------------------------
// sends the caps lock key press to the coco3
//------------------------------------------------------------------------------------------
void coco3_capslock ()
{
	kbd_matrix matrix;
	matrix.msb = 0x7E;
	matrix.lsb = 0x7E;
	matrix.asc = '@';
	coco3_write_matrix (matrix);
}

//------------------------------------------------------------------------------------------
// writes a matrix value to the coco3 keyboad matrix hardware
//------------------------------------------------------------------------------------------
void coco3_write_matrix (kbd_matrix matrix)
{
	// disable the matrix latch circuits so we don't send partial values
	COCO3_MTX_OFF;			// disable chip output by setting OE = 1 (active low)

	// select the high-order latch and write the msb value.
	COCO3_MATRIX_PORT = matrix.msb;
	COCO3_MSB_HIGH;
	COCO3_MSB_LOW;

	// select the low-order latch and write the lsb value.
	COCO3_MATRIX_PORT = matrix.lsb;
	COCO3_LSB_HIGH;
	COCO3_LSB_LOW;

	// enable latch output to simulate coco3 key stroke, for 50ms
	COCO3_MTX_ON;

	counter = 5;
	TIMSK0 |= (1<<OCIE0A); // turn on timer
}

//------------------------------------------------------------------------------------------
// maps the scan code to a coco3 keyboard matrix.  returns the char code for the key, or 0 if nothing found.
//------------------------------------------------------------------------------------------
uint8_t coco3_map_scancode (uint8_t scancode, uint16_t status, kbd_matrix * matrix)
{
	// make sure we have a valid pointer
	if (0 == matrix)
		return 0xFF;

	matrix->msb = 0xFF;
	matrix->lsb = 0xFF;
	matrix->asc = 0xFF;

	// check group3...
	if (status & KBD_EXTENDED)
	{
		switch (scancode)
		{
			case 0x11:		// RALT
				matrix->msb = 0xF7;
				matrix->lsb = 0x7F;
				matrix->asc = 0x11;
			break;
			case 0x14:		// RCTRL
				matrix->msb = 0xEF;
				matrix->lsb = 0x7F;
				matrix->asc = 0x14;
			break;
			case 0x4A:		// KP/
				matrix->msb = 0x7F;
				matrix->lsb = 0xBF;
				matrix->asc = 0x4A;
			break;
			case 0x6B:		// LARROW
				matrix->msb = 0xDF;
				matrix->lsb = 0xEF;
				matrix->asc = 0x6B;
			break;
			case 0x72:		// DARROW
				matrix->msb = 0xEF;
				matrix->lsb = 0xEF;
				matrix->asc = 0x72;
			break;
			case 0x74:		// RARROW
				matrix->msb = 0xBF;
				matrix->lsb = 0xEF;
				matrix->asc = 0x74;
			break;
			case 0x75:		// RARROW
				matrix->msb = 0xF7;
				matrix->lsb = 0xEF;
				matrix->asc = 0x75;
			break;
		}
	}
	else if (status & KBD_SHIFT)
	{
		// check group2...
		switch (scancode)
		{
		case 0x16:		// !
			matrix->msb = 0x7D;
			matrix->lsb = 0x5F;
			matrix->asc = '!';
			break;
		case 0x25:		// $
			matrix->msb = 0x6F;
			matrix->lsb = 0x5F;
			matrix->asc = '$';
			break;
		case 0x26:		// #
			matrix->msb = 0x77;
			matrix->lsb = 0x5F;
			matrix->asc = '#';
			break;
		case 0x41:		// <
			matrix->msb = 0xEF;
			matrix->lsb = 0xBF;
			matrix->asc = '<';
			break;
		case 0x45:		// )
			matrix->msb = 0xFD;
			matrix->lsb = 0xBF;
			matrix->asc = ')';
			break;
		case 0x46:		// (
			matrix->msb = 0xFE;
			matrix->lsb = 0xBF;
			matrix->asc = '(';
			break;
		case 0x49:		// >
			matrix->msb = 0xBF;
			matrix->lsb = 0xBF;
			matrix->asc = '>';
			break;
		case 0x52:		// "
			matrix->msb = 0x7B;
			matrix->lsb = 0x5F;
			matrix->asc = '"';
			break;
		case 0x55:		// +
			matrix->msb = 0xF7;
			matrix->lsb = 0xBF;
			matrix->asc = '+';
			break;
		case 0x1E:		// @
			matrix->msb = 0xFE;
			matrix->lsb = 0xFE;
			matrix->asc = '@';
			break;
		case 0x2E:		// %
			matrix->msb = 0x5F;
			matrix->lsb = 0x5F;
			matrix->asc = '%';
			break;
		case 0x3D:		// &
			matrix->msb = 0x3F;
			matrix->lsb = 0x5F;
			matrix->asc = '&';
			break;
		case 0x3E:		// *
			matrix->msb = 0x7B;
			matrix->lsb = 0x3F;
			matrix->asc = '*';
			break;
		case 0x4A:		// ?
			matrix->msb = 0x7F;
			matrix->lsb = 0xBF;
			matrix->asc = '?';
			break;
		case 0x4C:		// :
			matrix->msb = 0xFB;
			matrix->lsb = 0xBF;
			matrix->asc = ':';
			break;
		}
	}
	
	if (0xff == matrix->asc)
	{
		// check group1...
		switch (scancode)
		{
		case 0x11:		// LALT
			matrix->msb = 0xF7;
			matrix->lsb = 0x7F;
			matrix->asc = '0';
			break;
		case 0x12:		// LSHFT
			matrix->msb = 0x7F;
			matrix->lsb = 0x7F;
			matrix->asc = '0';
			break;
		case 0x14:		// LCTRL
			matrix->msb = 0xEF;
			matrix->lsb = 0x7F;
			matrix->asc = '0';
			break;
		case 0x15:		// Q
			matrix->msb = 0xFD;
			matrix->lsb = 0xF7;
			matrix->asc = 'Q';
			break;
		case 0x16:		// 1
			matrix->msb = 0xFD;
			matrix->lsb = 0xDF;
			matrix->asc = '1';
			break;
		case 0x21:		// C
			matrix->msb = 0xF7;
			matrix->lsb = 0xFE;
			matrix->asc = 'C';
			break;
		case 0x22:		// X
			matrix->msb = 0xFE;
			matrix->lsb = 0xEF;
			matrix->asc = 'X';
			break;
		case 0x23:		// D
			matrix->msb = 0xEF;
			matrix->lsb = 0xFE;
			matrix->asc = 'D';
			break;
		case 0x24:		// E
			matrix->msb = 0xDF;
			matrix->lsb = 0xFE;
			matrix->asc = 'E';
			break;
		case 0x25:		// 4
			matrix->msb = 0xEF;
			matrix->lsb = 0xDF;
			matrix->asc = '4';
			break;
		case 0x26:		// 3
			matrix->msb = 0xF7;
			matrix->lsb = 0xDF;
			matrix->asc = '3';
			break;
		case 0x29:		// SPACE
			matrix->msb = 0x7F;
			matrix->lsb = 0xEF;
			matrix->asc = ' ';
			break;
		case 0x31:		// N
			matrix->msb = 0xBF;
			matrix->lsb = 0xFD;
			matrix->asc = 'N';
			break;
		case 0x33:		// H
			matrix->msb = 0xFE;
			matrix->lsb = 0xFD;
			matrix->asc = 'H';
			break;
		case 0x34:		// G
			matrix->msb = 0x7F;
			matrix->lsb = 0xFE;
			matrix->asc = 'G';
			break;
		case 0x35:		// Y
			matrix->msb = 0xFD;
			matrix->lsb = 0xEF;
			matrix->asc = 'Y';
			break;
		case 0x36:		// 6
			matrix->msb = 0xBF;
			matrix->lsb = 0xDF;
			matrix->asc = '6';
			break;
		case 0x41:		// ,
			matrix->msb = 0xEF;
			matrix->lsb = 0xBF;
			matrix->asc = ',';
			break;
		case 0x42:		// K
			matrix->msb = 0xF7;
			matrix->lsb = 0xFD;
			matrix->asc = 'K';
			break;
		case 0x43:		// I
			matrix->msb = 0xFD;
			matrix->lsb = 0xFD;
			matrix->asc = 'I';
			break;
		case 0x44:		// O
			matrix->msb = 0x7F;
			matrix->lsb = 0xFD;
			matrix->asc = 'O';
			break;
		case 0x45:		// 0
			matrix->msb = 0xFE;
			matrix->lsb = 0xDF;
			matrix->asc = '0';
			break;
		case 0x46:		// 9
			matrix->msb = 0xFD;
			matrix->lsb = 0xBF;
			matrix->asc = '9';
			break;
		case 0x49:		// .
			matrix->msb = 0xBF;
			matrix->lsb = 0xBF;
			matrix->asc = '.';
			break;
		case 0x52:		// '
			matrix->msb = 0x7F;
			matrix->lsb = 0x5F;
			matrix->asc = '\'';
			break;
		case 0x55:		// =
			matrix->msb = 0xDF;
			matrix->lsb = 0xBF;
			matrix->asc = '=';
			break;
		case 0x58:		// CAPS
			matrix->msb = 0x7E;
			matrix->lsb = 0x7E;
			matrix->asc = '0';
			break;
		case 0x59:		// RSHFT
			matrix->msb = 0x7F;
			matrix->lsb = 0x7F;
			matrix->asc = '0';
			break;
		case 0x69:		// KP1
			matrix->msb = 0xFD;
			matrix->lsb = 0xDF;
			matrix->asc = '1';
			break;
		case 0x70:		// KP0
			matrix->msb = 0xFE;
			matrix->lsb = 0xDF;
			matrix->asc = '0';
			break;
		case 0x71:		// KP.
			matrix->msb = 0xBF;
			matrix->lsb = 0xBF;
			matrix->asc = '.';
			break;
		case 0x72:		// KP2
			matrix->msb = 0xFB;
			matrix->lsb = 0xDF;
			matrix->asc = '2';
			break;
		case 0x73:		// KP5
			matrix->msb = 0xDF;
			matrix->lsb = 0xDF;
			matrix->asc = '5';
			break;
		case 0x74:		// KP6
			matrix->msb = 0xBF;
			matrix->lsb = 0xDF;
			matrix->asc = '6';
			break;
		case 0x75:		// KP8
			matrix->msb = 0xFE;
			matrix->lsb = 0xBF;
			matrix->asc = '8';
			break;
		case 0x76:		// ESC
			matrix->msb = 0xFD;
			matrix->lsb = 0x7F;
			matrix->asc = '0';
			break;
		case 0x79:		// KP+
			matrix->msb = 0xF7;
			matrix->lsb = 0xBF;
			matrix->asc = '+';
			break;
		case 0x05:		// F1
			matrix->msb = 0xDF;
			matrix->lsb = 0x7F;
			matrix->asc = '0';
			break;
		case 0x06:		// F2
			matrix->msb = 0xBF;
			matrix->lsb = 0x7F;
			matrix->asc = '0';
			break;
		case 0x1A:		// Z
			matrix->msb = 0xFB;
			matrix->lsb = 0xEF;
			matrix->asc = 'Z';
			break;
		case 0x1B:		// S
			matrix->msb = 0xF7;
			matrix->lsb = 0xF7;
			matrix->asc = 'S';
			break;
		case 0x1C:		// A
			matrix->msb = 0xFD;
			matrix->lsb = 0xFE;
			matrix->asc = 'A';
			break;
		case 0x1D:		// W
			matrix->msb = 0x7F;
			matrix->lsb = 0xF7;
			matrix->asc = 'W';
			break;
		case 0x1E:		// 2
			matrix->msb = 0xFB;
			matrix->lsb = 0xDF;
			matrix->asc = '2';
			break;
		case 0x2A:		// V
			matrix->msb = 0xBF;
			matrix->lsb = 0xF7;
			matrix->asc = 'V';
			break;
		case 0x2B:		// F
			matrix->msb = 0xBF;
			matrix->lsb = 0xFE;
			matrix->asc = 'F';
			break;
		case 0x2C:		// T
			matrix->msb = 0xEF;
			matrix->lsb = 0xF7;
			matrix->asc = 'T';
			break;
		case 0x2D:		// R
			matrix->msb = 0xFB;
			matrix->lsb = 0xF7;
			matrix->asc = 'R';
			break;
		case 0x2E:		// 5
			matrix->msb = 0xDF;
			matrix->lsb = 0xDF;
			matrix->asc = '5';
			break;
		case 0x32:		// B
			matrix->msb = 0xFB;
			matrix->lsb = 0xFE;
			matrix->asc = 'B';
			break;
		case 0x3A:		// M
			matrix->msb = 0xDF;
			matrix->lsb = 0xFD;
			matrix->asc = 'M';
			break;
		case 0x3B:		// J
			matrix->msb = 0xFB;
			matrix->lsb = 0xFD;
			matrix->asc = 'J';
			break;
		case 0x3C:		// U
			matrix->msb = 0xDF;
			matrix->lsb = 0xF7;
			matrix->asc = 'U';
			break;
		case 0x3D:		// 7
			matrix->msb = 0x7F;
			matrix->lsb = 0xDF;
			matrix->asc = '7';
			break;
		case 0x3E:		// 8
			matrix->msb = 0xFE;
			matrix->lsb = 0xBF;
			matrix->asc = '8';
			break;
		case 0x4A:		// /
			matrix->msb = 0x7F;
			matrix->lsb = 0xBF;
			matrix->asc = '/';
			break;
		case 0x4B:		// L
			matrix->msb = 0xEF;
			matrix->lsb = 0xFD;
			matrix->asc = 'L';
			break;
		case 0x4C:		// ;
			matrix->msb = 0xF7;
			matrix->lsb = 0xBF;
			matrix->asc = ';';
			break;
		case 0x4D:		// P
			matrix->msb = 0xFE;
			matrix->lsb = 0xF7;
			matrix->asc = 'P';
			break;
		case 0x4E:		// -
			matrix->msb = 0xDF;
			matrix->lsb = 0xBF;
			matrix->asc = '-';
			break;
		case 0x5A:		// ENTER
			matrix->msb = 0xFE;
			matrix->lsb = 0x7F;
			matrix->asc = '\n';
			break;
		case 0x6B:		// KP4
			matrix->msb = 0xEF;
			matrix->lsb = 0xDF;
			matrix->asc = '4';
			break;
		case 0x6C:		// KP7
			matrix->msb = 0x7F;
			matrix->lsb = 0xDF;
			matrix->asc = '7';
			break;
		case 0x7A:		// KP3
			matrix->msb = 0xF7;
			matrix->lsb = 0xDF;
			matrix->asc = '3';
			break;
		case 0x7B:		// KP-
			matrix->msb = 0xDF;
			matrix->lsb = 0xBF;
			matrix->asc = '-';
			break;
		case 0x7C:		// KP*
			matrix->msb = 0x7B;
			matrix->lsb = 0x3F;
			matrix->asc = '*';
			break;
		case 0x7D:		// KP9
			matrix->msb = 0xFD;
			matrix->lsb = 0xBF;
			matrix->asc = '9';
			break;
		}
	}

	// return the ascii code that we found...
	return matrix->asc;
}

