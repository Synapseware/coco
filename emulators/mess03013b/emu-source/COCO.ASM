        TITLE TRS-80 Colour Computer Emulator
        ;Copyright (C) 1993-1995,2001 Jeff Vavasour

;General register maps during execution time:        
; D  -> DX ( A -> DH, B -> DL )
; PC -> SI
; SP -> BP
; X  -> CX
; Y  -> DI

        ASSUME CS:PROG,DS:PROG

CUST_SEG SEGMENT PUBLIC 'B1_MENU'
CUST_DUMMY DB 0
CUST_SEG ENDS

;Stack segment structure

BANK0R  EQU 0                   ;CoCo 32K bank 0 segment for read
BANK0W  EQU 2                   ;CoCo 32K bank 0 segment for write
ROMBANK EQU 4                   ;PC segment for 32K ROM
RAMBANK EQU 6                   ;PC segment for 64K RAM
FRAME   EQU 8                   ;Video mask for debugger
FONT    EQU 4008                ;Character set for text modes and SG4/6
PCFONT  EQU 23208               ;PC's graphics character set (32-255)
CUR_DIR EQU 25256               ;Current directory listing, 500 entries max.
BANK1R  EQU 32768               ;CoCo 32K bank 1 segment for read
BANK1W  EQU 32770               ;CoCo 32K bank 1 segment for write
KEY_LIST EQU 32772              ;PC keyboard layout
ALT_LIST EQU 32968              ;CoCo keyboard layout
CUSTOM_LIST EQU 33164           ;Custom keyboard layout

PROG    SEGMENT PUBLIC 'CODE'

        PUBLIC REGDP,REGU,REGX,REGY,REGF,REGFI,XLTFLAG,UPDFLAG,DBGMSG,DEBUG
        PUBLIC BRKPT,BAD,DRA1_MATRIX,NEW_TOP,NEW_BOTTOM,CHARGEN,LASTKEY
        PUBLIC NEWSET,NEW_WIDTH,NEW_DIV,FONT_128R,FONT_128C,SBWAIT,ADDLF
        PUBLIC FONT_64C,FONT_256R,V_TOP,V_BOTTOM,HANDLE,PATHS,COUNTDOWN
        PUBLIC WR_PROT,DTA,LJOYSTK,RJOYSTK,MOUSE_X,MOUSE_Y,FIRE,SOUND,VOLUME
        PUBLIC PULSE,ARTIFACT,ALERT,BRANCH,SBMASK,REVISE,NEED_REVISE,DELAY
        PUBLIC GAXPOS,GAYPOS,GBXPOS,GBYPOS,QUIT1,DOUBLE_STEP,CART_INT
        PUBLIC PAGE_STATUS,ROM_STATUS,CHANDLE,CAS_BIT,CAS_CYCLE,CASMODE
        PUBLIC REGD,REGPC,REGSP

        EXTRN INST:NEAR,RAMHERE:BYTE,MEM_R8:NEAR,MEM_W8:NEAR,MEM_R16:NEAR
        EXTRN DRB2:BYTE,DRB1:BYTE,CRB1:BYTE,IRQ:NEAR,INITIALIZE:NEAR,CRA1:BYTE
        EXTRN AUX:NEAR,CART_FLAG:BYTE,FIRQ:NEAR,CRB2:BYTE,UpdateSyncLock:NEAR

;Macros

;Read word of CoCo's memory at [DI] into AX

GETWORD MACRO
        CALL MEM_R16
        ENDM

;Read byte of CoCo's memory at [DI] into AL

GETBYTE MACRO
        CALL MEM_R8
        ENDM

;Write byte AL to CoCo's memory at [DI]

PUTBYTE MACRO
        CALL MEM_W8
        ENDM

;Save registers into emulator's data area

SAVEREG MACRO
        MOV REGX,CX
        MOV REGY,DI
        MOV REGSP,BP
        MOV REGD,DX
        MOV REGPC,SI
        ENDM

;Load registers from emulator's data area

LOADREG MACRO
        MOV CX,REGX
        MOV DI,REGY
        MOV DX,REGD
        MOV SI,REGPC
        MOV BP,REGSP
        ENDM

;Keyscan:  Return scancode in AH, ASCII in AL.

KEYSTROKE MACRO
        MOV AH,0
        INT 16H
        ENDM
 
;Turn off cursor, no registers affected

CSROFF  MACRO
        PUSH AX
        PUSH CX
        MOV AH,1
        MOV CX,-1
        INT 10H
        POP CX
        POP AX
        ENDM

;Turn on cursor, no registers affected

CSRON   MACRO
        PUSH AX
        PUSH CX
        MOV AH,1
        MOV CX,15
        INT 10H
        POP CX
        POP AX
        ENDM

;Find AL in LIST of LENGTH characters, return result in CX

FIND    MACRO LIST,LENGTH
        PUSH DI
        MOV CX,LENGTH
        PUSH ES
        PUSH DS
        POP ES
        MOV DI,OFFSET LIST
        REPNZ SCASB
        POP ES
        POP DI
        ENDM

;Clear input buffer addressed by DI, length CX, no registers affected

CLEAR   MACRO
        PUSH AX
        PUSH CX
        PUSH DI
        MOV AL,32
        PUSH ES
        PUSH DS
        POP ES
        REP STOSB
        POP ES
        POP DI
        POP CX
        MOV AX,920H
        PUSH BX
        MOV BX,14
        INT 10H
        POP BX
        POP AX
        ENDM

;Display CoCo character AL at EGA address [DI]

DISPLAY_BYTE MACRO
        MUL TWENTYFIVE
        MOV BX,AX
        ADD BX,SG_MODE
        MOV AL,BYTE PTR SS:FONT[BX]
        NOT AL
        OUT DX,AL
        PUSH DS
        MOV AX,VID_SEG
        MOV DS,AX
        MOV WORD PTR [DI],0
        MOV WORD PTR [DI+80],0
        MOV WORD PTR [DI+160],0
        MOV WORD PTR [DI+240],0
        MOV WORD PTR [DI+320],0
        MOV WORD PTR [DI+400],0
        MOV WORD PTR [DI+480],0
        MOV WORD PTR [DI+560],0
        MOV WORD PTR [DI+640],0
        MOV WORD PTR [DI+720],0
        MOV WORD PTR [DI+800],0
        MOV WORD PTR [DI+880],0
        MOV AL,BYTE PTR SS:FONT[BX]
        OUT DX,AL
        MOV AX,SS:FONT[BX+1]
        MOV [DI],AX
        MOV AX,SS:FONT[BX+3]
        MOV [DI+80],AX
        MOV AX,SS:FONT[BX+5]
        MOV [DI+160],AX
        MOV AX,SS:FONT[BX+7]
        MOV [DI+240],AX
        MOV AX,SS:FONT[BX+9]
        MOV [DI+320],AX
        MOV AX,SS:FONT[BX+11]
        MOV [DI+400],AX
        MOV AX,SS:FONT[BX+13]
        MOV [DI+480],AX
        MOV AX,SS:FONT[BX+15]
        MOV [DI+560],AX
        MOV AX,SS:FONT[BX+17]
        MOV [DI+640],AX
        MOV AX,SS:FONT[BX+19]
        MOV [DI+720],AX
        MOV AX,SS:FONT[BX+21]
        MOV [DI+800],AX
        MOV AX,SS:FONT[BX+23]
        MOV [DI+880],AX
        POP DS
        ENDM

;PC interrupt intercept routines

KEY_INTERCEPT:
        PUSH AX
        PUSH BX
        MOV BX,0
        IN AL,96
        TEST AL,128
        JZ KEY_INT1
        MOV CS:CAS_STEP,1
KEY_INT1:        
        CMP BYTE PTR CS:LASTKEY[BX],0
        JNZ SUPPRESS
        MOV CS:LASTKEY[BX],AL
        MOV BYTE PTR CS:LASTKEY[BX+1],0
        MOV BYTE PTR CS:BRANCH,0
        MOV BYTE PTR CS:INST,0C3H
        JMP KEY_BIOS
SUPPRESS:
        INC BX
        CMP BL,15
        JB KEY_INT1
KEY_BIOS:
        POP BX
        POP AX
        DB 0EAH
KEY_LOW DW 0
KEY_HI  DW 0

        PUBLIC CYCLE_COUNT

CYCLE_COUNT DW 0

CLOCK_INTERCEPT:                ;Dual timer clock interrupt
        PUSH AX                 ;CoCo 60Hz interrupt handler
        MOV CS:PULSE,128        ;Set CoCo's clock IRQ bit on PIA2's CRB
        MOV BYTE PTR CS:BRANCH,OFFSET BRANCH5-OFFSET BRANCH1
                                ;Set branch to IRQ handler
        MOV BYTE PTR CS:INST,0C3H
        MOV AX,CS:CLOCK_PERIOD  
        cmp ax,4DA7H            ;Add cycles for next PAL/NTSC frame
        jz pal_frame
        add cs:cycle_count,262
        jmp frame_updated
pal_frame:
        add cs:cycle_count,314
frame_updated:
        ADD CS:CYCLE,AX         ;Is it time for a PC clock interrupt?
        JA PC_CLOCK             ;Branch if next interrupt is a PC clock
        MOV AL,20H              ;Reset interrupt controller
        OUT 20H,AL
        POP AX
        IRET                    ;Return
PC_CLOCK:                       ;PC clock 18.2Hz interrupt handler
        pop ax
        CMP BYTE PTR CS:BRANCH,0
        JZ PC_CLOCK1            ;If nothing else happening, set screen
                                ;refresh interpreter branch
        MOV BYTE PTR CS:INST,0C3H
        MOV BYTE PTR CS:BRANCH,OFFSET BRANCH2-OFFSET BRANCH1
PC_CLOCK1:                      ;Go to PC clock interrupt handler
        DB 0EAH                 
CLK_LOW DW 0
CLK_HI  DW 0

CYCLE   DW 0            ;Counter for determining which type is next

MOUSE_INTERCEPT:
        TEST BL,1
        JZ MOUSE_FIRE_RELEASE
        CMP CS:LJOYSTK,0
        JNZ NO_LEFT_FIRE
        AND BYTE PTR CS:FIRE,253
NO_LEFT_FIRE:
        CMP CS:RJOYSTK,0
        JNZ NO_MOUSE_FIRE
        AND BYTE PTR CS:FIRE,254
        JMP NO_MOUSE_FIRE
MOUSE_FIRE_RELEASE:
        CMP CS:LJOYSTK,0
        JNZ NO_LEFT_RELEASE
        OR BYTE PTR CS:FIRE,2
NO_LEFT_RELEASE:
        CMP CS:RJOYSTK,0
        JNZ NO_MOUSE_FIRE
        OR BYTE PTR CS:FIRE,1
NO_MOUSE_FIRE:
        MOV AX,CX
        DIV BYTE PTR CS:TEN
        MOV CS:MOUSE_X,AL
        MOV AX,DX
        SHL AX,1
        SHL AX,1
        SHL AX,1
        DIV CS:TWENTYFIVE
        MOV CS:MOUSE_Y,AL
        CMP CS:LASTKEY,0
        JNZ NO_BUTTON_RESPONSE
        TEST BL,6
        JZ NO_BUTTON_RESPONSE
        MOV CS:LASTKEY,3DH
        MOV BYTE PTR CS:BRANCH,0
        MOV BYTE PTR CS:INST,0C3H
        CMP BL,5                        ;Left+middle=snapshot
        JZ NO_BUTTON_RESPONSE
        MOV CS:LASTKEY,3CH
        TEST BL,5                       ;Left+right or middle=virtual disk
        JNZ NO_BUTTON_RESPONSE
        MOV CS:LASTKEY,7EH              ;Right only=options
NO_BUTTON_RESPONSE:
        RETF

MOUSE_LO DW 0
MOUSE_HI DW 0
MOUSE_MK DW 0

MOUSE_X DB 31                   ;Mouse coordinates in 0-63 range
MOUSE_Y DB 31
FIRE    DB -1                   ;Left button is mapped to joystick trigger

BREAK_INTERCEPT:                ;Keep that pesky fatal error and CTRL-C
        IRET                    ;from leaving the program

BREAK_LO DW 0
BREAK_HI DW 0

;Subroutines

;Test for presence of joystick, remap to mouse if none detected

NO_GAME_PORT DB 0

JOYTEST PROC NEAR
        PUSH CX
        MOV DX,201H
        OUT DX,AL
        MOV CX,0
        PUSH AX
        PUSH DX
JOYTEST1:
        IN AL,DX
        TEST AL,15
        LOOPZ JOYTEST1
        JZ JOYTEST3
JOYTEST2:
        IN AL,DX
        NOT AL
        TEST AL,15
        LOOPZ JOYTEST2
        JNZ JOYTEST5
JOYTEST3:        
        MOV NO_GAME_PORT,-1
        CMP BYTE PTR LJOYSTK,0
        JZ JOYTEST4
        MOV BYTE PTR LJOYSTK,6
JOYTEST4:
        CMP BYTE PTR RJOYSTK,0
        JZ JOYTEST5
        MOV BYTE PTR RJOYSTK,6
JOYTEST5:
        POP DX
        POP AX
        POP CX
        RET
JOYTEST ENDP

;Read bit of joystick port as masked in AH, return timing in CX

JOYREAD PROC NEAR
        PUSH AX
        PUSH DX
        MOV CX,0
        CLI
        MOV DX,201H
        OUT DX,AL
JOYREAD1:
        IN AL,DX
        TEST AL,AH
        LOOPNZ JOYREAD1
        STI
        NEG CX
        POP DX
        POP AX
        RET
JOYREAD ENDP

;SoundBlaster code:  Identify and initialise

SBINIT  PROC NEAR
        CLI
        MOV DX,SBPORT
        ADD DX,6
        MOV AL,1
        OUT DX,AL
        MOV CX,10
SBINIT1:
        LOOP SBINIT1
        DEC AL
        OUT DX,AL
        STI
        ADD DX,4
        MOV CX,100
SBINIT2:
        IN AL,DX
        CMP AL,0AAH
        JZ SBINIT3
        LOOP SBINIT2
        RET
SBINIT3:
        MOV BYTE PTR SBMASK,3
        CALL SBWAIT
        MOV AL,0D1H
        OUT DX,AL
        RET
SBINIT  ENDP

;Wait for SoundBlaster command port

SBWAIT  PROC NEAR
        MOV DX,SBPORT
        ADD DX,12
SBWAIT1:
        IN AL,DX
        ROL AL,1
        JB SBWAIT1
        RET
SBWAIT  ENDP

SBPORT  DW 220H

;Fix graphics mode pixel height based on memory allocated

FIX_HEIGHT PROC NEAR
        MOV AX,V_BOTTOM         ;If null size, there will be a /0 error
        SUB AX,V_TOP
        JZ FIXH0
        TEST BYTE PTR DRB2,128  ;If graphics mode, branch
        JNZ FIXH1
        PUSH BX
        DIV BYTE PTR THIRTYTWO  ;Number of semigraphics lines=bytes/32
        MOV BL,AL
        MOV AX,192
        DIV BL                  ;192/lines=scanlines per character
        MOV V_DIV,AL
        MOV AH,80
        MUL AH
        MOV V_HEIGHT,AX         ;EGA characters/line=80*this number
        POP BX
        RET
FIXH1:  PUSH BX                 ;In graphics mode, pixel height=192/
        PUSH DX                 ;  ((V_BOTTOM-V_TOP)/V_DIV)
        MOV DX,0                ;CHARGEN needs 80*this number (80*192=15360)
        MOV BL,V_DIV
        MOV BH,0
        DIV BX
        MOV BX,AX
        MOV DX,0
        MOV AX,15360
        DIV BX
        MOV V_HEIGHT,AX
        POP DX
        POP BX
FIXH0:  RET
FIX_HEIGHT ENDP

;Shift keyboard buffer one byte

SHIFT_KEYS PROC NEAR
        PUSH BX
        MOV BX,0
SHIFT_KEYS1:
        MOV AL,LASTKEY[BX+1]
        MOV LASTKEY[BX],AL
        INC BL
        CMP BL,15
        JB SHIFT_KEYS1
        POP BX
        RET
SHIFT_KEYS ENDP

;Load PC character set

LOAD_PC_SET PROC NEAR
        MOV DI,0
        MOV AX,6
        INT 10H
        MOV AH,11               ;Make text black-on-black.  No need to
        MOV BX,100H             ;clutter the nice screen
        INT 10H
        MOV SI,PCFONT
        PUSH DS
        MOV AX,0B800H
        MOV DS,AX
        MOV AL,0
LPS1:   MOV AH,10
        MOV BX,7
        MOV CX,1
        PUSH SI
        PUSH AX
        INT 10H
        POP AX
        POP SI
        PUSH AX
        MOV AL,BYTE PTR [DI]
        MOV SS:[SI],AL
        MOV AL,BYTE PTR [DI+2000H]
        MOV SS:[SI+1],AL
        MOV AL,BYTE PTR [DI+80]
        MOV SS:[SI+2],AL
        MOV AL,BYTE PTR [DI+2050H]
        MOV SS:[SI+3],AL
        MOV AL,BYTE PTR [DI+160]
        MOV SS:[SI+4],AL
        MOV AL,BYTE PTR [DI+20A0H]
        MOV SS:[SI+5],AL
        MOV AL,BYTE PTR [DI+240]
        MOV SS:[SI+6],AL
        MOV AL,BYTE PTR [DI+20F0H]
        MOV SS:[SI+7],AL
        ADD SI,8
        POP AX
        INC AL
        JNZ LPS1
        POP DS
        RET
LOAD_PC_SET ENDP

;Display CX copies of PC character AL at DX, foreground BL, background BH
;bit 7 of BL = 1 => reverse character

PC_CHAR PROC NEAR
        PUSH DI
        PUSH DX
        PUSH BX
        PUSH AX
        MOV AL,DH
        MOV AH,0
        PUSH DX
        MUL SIXFORTY
        POP DX
        MOV DH,0
        ADD AX,DX
        MOV DI,AX
        POP AX
        PUSH AX
        MOV AH,0
        SHL AX,1
        SHL AX,1
        SHL AX,1
        PUSH ES
        MOV ES,VID_SEG
        PUSH AX
        MOV DX,3C4H
        MOV AL,2
        OUT DX,AL
        INC DX
        MOV AL,BH
        OUT DX,AL
        MOV AH,8
        PUSH DI
PCC1:   PUSH DI                 ;Set background
        PUSH CX
        MOV AL,255
        REP STOSB
        POP CX
        POP DI
        ADD DI,80
        DEC AH
        JNZ PCC1
        POP DI
        MOV AL,BH
        NOT AL
        OUT DX,AL
        MOV AH,8
        PUSH DI
PCC2:   PUSH DI                 ;Clear non-background       
        PUSH CX
        MOV AL,0
        REP STOSB
        POP CX
        POP DI
        ADD DI,80
        DEC AH
        JNZ PCC2
        POP DI
        MOV AL,BL               ;Display character
        AND AL,127
        NOT BH
        AND AL,BH
        OUT DX,AL
        MOV DL,-1
        CMP BL,128
        ADC DL,0                ;DL=-1 if bit 7 of BL set, else DL=0
        POP BX
        MOV AH,8
PCC3:   PUSH DI
        PUSH CX
        MOV AL,SS:PCFONT[BX]
        XOR AL,DL
        REP STOSB
        POP CX
        POP DI
        ADD DI,80
        INC BX
        DEC AH
        JNZ PCC3
        POP ES
        POP AX
        POP BX
        POP DX
        POP DI
        RET
PC_CHAR ENDP

;Display an EGA overlay menu in [DI] (with shadow) at video coord DX, with 
;height BH, width BL.  Menu framework is light cyan on dark blue.
;BH bit 7=1 => draw shadow

MENU    PROC NEAR       
        PUSH DX                 ;Fix bit plane controller
        MOV AL,15
        MOV DX,3C5H
        OUT DX,AL
        POP DX
        PUSH BX
MENU1:  PUSH BX
        MOV AL,[DI]
        INC DI
        MOV CX,1
        MOV BH,MENU_BACK
        MOV BL,BH
        XOR BL,10
        CALL PC_CHAR
        INC DL
        POP BX
        DEC BL
        JNZ MENU1
        POP AX
        PUSH AX
        MOV BL,AL
        SUB DL,AL
        INC DH
        DEC BH
        TEST BH,127
        JNZ MENU1
        POP BX
        SUB DH,BH
        ADD DH,128
        TEST BH,128
        JNZ MENU2
        RET
MENU2:  ADD DL,BL               ;Create shadow
        PUSH DX
        MOV DX,3C4H
        MOV AL,2
        OUT DX,AL
        INC DX
        MOV AL,8
        OUT DX,AL
        POP DX
        INC DH
        MOV AL,DH
        MOV AH,0
        PUSH DX
        MUL SIXFORTY
        POP DX
        MOV DH,0
        ADD AX,DX
        MOV DI,AX
        DEC BH
        SHL BH,1
        SHL BH,1
        SHL BH,1
        PUSH ES
        MOV ES,VID_SEG
MENU3:  MOV BYTE PTR ES:[DI],0
        ADD DI,80
        DEC BH
        JNZ MENU3
        SUB DI,BX
        INC DI
        MOV CX,BX
        MOV BL,8
MENU4:  PUSH DI
        PUSH CX
        MOV AL,0
        REP STOSB
        POP CX
        POP DI
        ADD DI,80
        DEC BL
        JNZ MENU4
        POP ES
        RET
MENU    ENDP

SIXFORTY DW 640
MENU_BACK DB 1                  ;Menu background colour

;Copy the current EGA screen to the alternate page, and freeze display on
;alternate page while main page is updated

FREEZE PROC NEAR
        MOV VID_PAG,1
        MOV VID_SEG,0A400H
        CALL SHOW
        CALL SHOW
        MOV VID_SEG,0A000H
        RET
FREEZE ENDP

;Correct video page registers and display the main screen once more

THAW    PROC NEAR
        MOV VID_PAG,0
        MOV AH,5
        MOV AL,0
        INT 10H
        RET
THAW    ENDP

;Display CoCo character AL at RAM address [DI] on EGA screen

CHARGEN PROC NEAR
        CMP CS:LASTKEY,3BH
        JNZ CHARGEN1
        RET
CHARGEN1:
        TEST BYTE PTR OLD_DRB2,128
        JZ CHARGEN2
        JMP CHARGEN3
CHARGEN2:                       ;Text generation
        PUSH AX
        PUSH BX
        PUSH DX
        PUSH DI
        MOV DI,BX
        CMP BYTE PTR V_DIV,12   ;If page larger than 512 bytes, we're in
        JZ CHARGEN2A            ;semigraphics modes
        JMP SEMI
CHARGEN2A:
        XCHG AX,DI
        SUB AX,V_TOP
        AND AH,7FH
        MOV BX,AX
        DIV THIRTYTWO
        MOV AH,0
        PUSH DX
        MUL NINESIXTY
        POP DX
        AND BX,31
        ADD BX,BX
        ADD AX,BX
        ADD AX,328
        XCHG AX,DI
        MOV DX,3C4H
        PUSH AX
        MOV AL,2
        OUT DX,AL
        POP AX
        INC DX
        DISPLAY_BYTE
        POP DI
        POP DX
        POP BX
        POP AX
        RET
CHARGEN3:                       ;Graphics generation
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        PUSH DI
        PUSH ES
        PUSH AX
        MOV DI,BX
        XCHG AX,DI
        SUB AX,V_TOP
        AND AH,7FH
        DIV V_DIV               ;Divide offset by bytes per line to get line
        MOV DL,AH               ;number in AX, column number in DX
        MOV AH,0
        MOV DH,AH
        PUSH DX
        MUL V_HEIGHT            ;Multiply by EGA bytes per line
        POP DX
        MOV CL,V_WIDTH          ;Multiply column by 2^V_WIDTH to get EGA col.
        SHL DX,CL
        ADD AX,DX               ;Add together and add base offset 328
        ADD AX,328              ;(4th pixel row, 8th character col. of 80)
        XCHG AX,DI
        MOV DX,3C4H
        PUSH AX
        MOV AL,2
        OUT DX,AL
        POP AX
        INC DX
        MOV BX,CHARSET
        MOV CL,[BX]
        POP BX
        PUSH BX
        MOV BH,BL
        MOV ES,VID_SEG
        MOV SI,V_HEIGHT
        MOV CH,1
CHARGEN4:
        MOV BL,0
        ROL BX,CL
        PUSH BX
        MOV BH,0
        ADD BX,BX
        ADD BX,CHARSET
        MOV AX,[BX+1]
        POP BX
CHARGEN5:
        PUSH AX
        MOV AL,3
        OUT DX,AL
        POP AX
        MOV ES:[DI],AL
        PUSH AX
        MOV AL,12
        OUT DX,AL
        POP AX
        MOV ES:[DI],AH
        ADD DI,80
        SUB SI,80
        JNZ CHARGEN5
        MOV SI,V_HEIGHT
        SUB DI,SI
        INC DI
        SHL CH,CL
        JNB CHARGEN4
        POP AX
        POP ES
        POP DI
        POP SI
        POP DX
        POP CX
        POP BX
        TEST BYTE PTR NEED_FLAG,1
        JZ CHARGEN6
        CALL REVISE
CHARGEN6:
        RET
CHARGEN ENDP        

TWENTYFIVE DB 25
THIRTYTWO  DB 32
NINESIXTY  DW 960

;Semigraphics mode handler

SEMI    PROC NEAR
        PUSH CX
        SUB DI,V_TOP            ;Calculate EGA start address
        XCHG AX,DI
        AND AH,7FH
        DIV Byte Ptr THIRTYTWO
        MOV CH,AL
        MOV BL,AH
        MOV BH,0
        ADD BX,BX
        ADD BX,328
        MOV AH,0
        MUL WORD PTR V_HEIGHT
        ADD AX,BX
        XCHG AX,DI
        PUSH AX                 ;Calculate scanline row within character
        MOV AL,CH
        MOV CL,V_DIV
        MUL CL
        DIV TWELVE
        MOV CH,AH
        POP AX
        MUL TWENTYFIVE          ;Partial character handler
        ADD AX,SG_MODE
        MOV BX,AX
        MOV AL,2                ;Set negative of character colour
        MOV DX,3C4H
        OUT DX,AL
        MOV AL,BYTE PTR SS:FONT[BX]
        INC BX
        INC DX
        NOT AL
        OUT DX,AL
        PUSH AX
        MOV AL,CH               ;Calculate scanline within character to 
        MOV AH,0                ;start
        SHL AX,1
        ADD BX,AX
        POP AX
        PUSH ES                 ;Set up pointer to EGA memory
        MOV ES,VID_SEG
        MOV CH,0
        PUSH CX        
        PUSH DI
SEMI2:  MOV WORD PTR ES:[DI],0  ;Clear out bit planes not associated with
        ADD DI,80               ;colour
        LOOP SEMI2
        POP DI
        POP CX
        NOT AL
        OUT DX,AL               ;Address relevent colour planes
SEMI7:  MOV AX,SS:FONT[BX]      ;Loop for number of lines to character
        MOV ES:[DI],AX
        ADD DI,80
        INC BX
        INC BX
        LOOP SEMI7
        POP ES
        POP CX
        POP DI
        POP DX
        POP BX
        POP AX
        RET
SEMI    ENDP

COLOUR_LIST DB 8,14,9,12,15,11,13,6
TWELVE  DB 12

;Read current directory.  Search path name is in DX, table to store directory
;is at SS:SI (14 bytes per entry), CX is number of free entries in table,
;BL=10h for a list of subdirectories, BL=0 for files.

;On return, DI=first empty entry in directory, CX=number of remaining free
;entries.  Directory is sorted alphabetically.

SEARCH  PROC NEAR
        MOV DI,SI
        MOV AH,11H
        INT 21H
        INC AL
        JNZ SEARCH0
        RET
SEARCH0:
        MOV AL,DTA[19]
        XOR AL,BL
        AND AL,16
        JZ SEARCH1
        JMP SEARCH9
SEARCH1:                        ;Find DTA's entry's position in alphabetic
        PUSH SI                 ;list
        PUSH BX
SEARCH2:
        MOV BX,0
        CMP SI,DI
        JNB SEARCH6
SEARCH3:
        MOV AL,DTA[BX+8]
        CMP AL,SS:[SI+BX]
        JB SEARCH5
        JA SEARCH4
        INC BX
        CMP BX,11
        JB SEARCH3
SEARCH4:
        ADD SI,14
        JMP SEARCH2
SEARCH5:                        ;Shift entire directory list up one entry
        PUSH CX
        PUSH SI
        PUSH DI
        PUSH DS
        PUSH ES
        MOV AX,SS
        MOV DS,AX
        MOV ES,AX
        MOV CX,DI
        SUB CX,SI
        DEC DI
        MOV SI,DI
        ADD DI,14
        STD
        REP MOVSB
        MOV CX,14               ;Clear the newly created space
        MOV AL,32
        REP STOSB
        CLD
        POP ES
        POP DS
        POP DI
        POP SI
        POP CX
        MOV BX,0
SEARCH6:                        ;Move filename
        MOV AL,DTA[BX+8]
        MOV SS:[SI],AL
        CMP AL,' '
        JZ SEARCH7
        INC SI
        INC BL
        CMP BL,8
        JB SEARCH6
SEARCH7:                        ;Add extension if applicable
        MOV AH,DTA[16]
        CMP AH,' '
        JZ SEARCH8
        MOV AL,'.'
        MOV SS:[SI],AX
        ADD SI,2
        MOV AL,DTA[17]
        CMP AL,' '
        JZ SEARCH8
        MOV SS:[SI],AL
        INC SI
        MOV AL,DTA[18]
        CMP AL,' '
        JZ SEARCH8
        MOV SS:[SI],AL
        INC SI
SEARCH8:
        MOV BYTE PTR SS:[SI],0
        ADD DI,14
        POP BX
        POP SI
        LOOP SEARCH9
        RET
SEARCH9:
        MOV AH,12H
        INT 21H
        INC AL
        JNZ SEARCH10
        RET
SEARCH10:
        JMP SEARCH0
SEARCH  ENDP

;Build directory list and display first 21 entries in the directory window
;Specific file extension is given by FCB at DX.

TOTAL_DRIVES DB 0                       ;Total number of logical drives

DIR     PROC NEAR
        MOV LAST_DIR,DX
        MOV SI,CUR_DIR
DIR1:   MOV BYTE PTR SS:[SI],' '
        INC SI
        CMP SI,7000+CUR_DIR
        JB DIR1
        MOV CL,TOTAL_DRIVES
        MOV CH,0
        MOV SI,CUR_DIR
        MOV AX,3A41H                    ;Drive list, starting with A:
DIR1A:  MOV BYTE PTR SS:[SI],'['
        MOV SS:[SI+1],AX
        MOV BYTE PTR SS:[SI+3],']'
        INC AL
        ADD SI,14
        LOOP DIR1A
        PUSH DX
        MOV CX,498
        MOV AL,TOTAL_DRIVES
        MOV AH,0
        SUB CX,AX
        INC SI
        MOV DX,OFFSET DIRSEARCH
        MOV BL,16
        CALL SEARCH
        INC CX
        DEC SI
        DEC DI
DIR2:   CMP SI,DI               ;Put brackets around directory names
        JNB DIR3
        MOV BYTE PTR SS:[SI],'['
        ADD SI,14
        JMP DIR2
DIR3:   DEC SI
        CMP BYTE PTR SS:[SI],0
        JNZ DIR4
        MOV BYTE PTR SS:[SI],']'
DIR4:   CMP SI,CUR_DIR
        JNB DIR3
        POP DX
        MOV SI,DI
        MOV BL,0
        CALL SEARCH
        MOV AX,294
        MUL DIR_PAGE
        ADD AX,CUR_DIR
        MOV SI,AX
        CMP BYTE PTR SS:[SI],0
        JZ DIR5
        CMP BYTE PTR SS:[SI],32
        JZ DIR5
        CALL SHOWDIR
        RET
DIR5:   MOV DIR_PAGE,0
        CALL SHOWDIR
        RET
DIR     ENDP

;Display the 21st*(DIR_PAGE) entry of the directory listing.

DIR_PAGE DW 0

SHOWDIR PROC NEAR
        MOV DIR_PTR,-1
        MOV AX,294
        MUL DIR_PAGE
        ADD AX,CUR_DIR
        MOV SI,AX
        MOV DX,340H
SHOWDIR1:
        MOV AL,SS:[SI]
        MOV BX,107H
        MOV CX,1
        CALL PC_CHAR
        INC SI
        INC DL
        CMP DL,64+14
        JB SHOWDIR1
        MOV AL,32
        CALL PC_CHAR
        MOV DL,64
        INC DH
        CMP DH,24
        JB SHOWDIR1
        RET
SHOWDIR ENDP

;Reset main interpreter branch loop

RESETBRANCH PROC NEAR
        MOV BYTE PTR INST,0C3H  ;Set INST to "RET"
        CMP LASTKEY,0           ;If last key pressed not attended to, do it
        JNZ RB3
        CMP BRKPT,-1            ;Include breakpoint test if set
        JNZ RB2
        TEST DELAY,7FFFH        ;Include delay loop if requested
        JNZ RB1
        MOV AL,OFFSET MAIN-OFFSET BRANCH1
        MOV BYTE PTR BRANCH,AL
        MOV BYTE PTR INST,56H   ;Restore "PUSH SI"
        RET
RB1:    MOV BYTE PTR BRANCH,OFFSET SLOW-OFFSET BRANCH1
        RET
RB2:    MOV BYTE PTR BRANCH,OFFSET BRANCH3-OFFSET BRANCH1
        RET
RB3:    MOV BYTE PTR BRANCH,0
        RET
RESETBRANCH ENDP

;Clear the black border surrounding standard 256x192 window

CLEAR_BORDER PROC NEAR
        CMP BYTE PTR LASTKEY,3BH
        JNZ C_BORDER1
        RET
C_BORDER1:
        PUSH ES
        PUSH AX
        PUSH CX
        PUSH DI
        PUSH DX
        MOV DX,3C4H
        MOV AL,2
        OUT DX,AL
        INC DX
        MOV AL,15
        OUT DX,AL
        POP DX
        MOV ES,VID_SEG
        MOV AL,0
        MOV DI,0
        MOV CX,320
        REP STOSB
C_BORDER2:
        MOV WORD PTR ES:[DI],0
        MOV WORD PTR ES:[DI+2],0
        MOV WORD PTR ES:[DI+4],0
        MOV WORD PTR ES:[DI+6],0
        MOV WORD PTR ES:[DI+72],0
        MOV WORD PTR ES:[DI+74],0
        MOV WORD PTR ES:[DI+76],0
        MOV WORD PTR ES:[DI+78],0
        ADD DI,80
        CMP DI,15680
        JB C_BORDER2
        MOV CX,320
        REP STOSB
        POP DI
        POP CX
        POP AX
        POP ES
        RET
CLEAR_BORDER ENDP

;Display 8-character column message DI at DX

COLUMN  PROC NEAR                           
        MOV BX,11
        MOV AH,9
        MOV AL,[DI]
        MOV CX,1
        CALL PC_CHAR
        INC DI
        INC DL
        TEST DL,7
        JNZ COLUMN
        SUB DL,8
        INC DH
        CMP BYTE PTR [DI],0
        JNZ COLUMN
        MOV MARGIN,-1
        RET
COLUMN  ENDP

;Display source code

SOURCE  PROC NEAR
        MOV BL,DISTYPE
        CMP BL,8
        JZ EXPLICIT
        MOV BH,0
        ADD BX,BX
        MOV AX,REGPC[BX-2]
        MOV DISADR,AX
EXPLICIT:
        MOV AX,DISADR
        MOV DX,0C1FH
        CMP BYTE PTR DISTYPE,8
        JZ SOURCE2
        MOV AH,2
        MOV BX,7
        INT 10H
        MOV AH,14
        MOV AL,'['
        INT 10H
        MOV AH,14
        MOV AL,LASTDIS
        CMP AL,'A'
        JNZ SOURCE0
        MOV AL,'D'
SOURCE0:
        INT 10H
        MOV AL,LASTDIS
        CMP AL,'P'
        MOV CX,'C]'
        JZ SOURCE1
        MOV CX,'P]'
        CMP AL,'D'
        JZ SOURCE1
        MOV CX,'] '
SOURCE1:
        MOV AL,CH
        MOV AH,14
        INT 10H
        MOV AL,CL
        MOV AH,14
        INT 10H
        JMP SOURCE3
SOURCE2:
        CALL BIT16
SOURCE3:
        MOV DI,DISADR
        MOV DX,0D12H
SOURCE4:
        MOV AX,DI
        CALL BIT16
        MOV AX,0E20H
        MOV BX,7
        INT 10H
        MOV CX,25
        MOV AX,920H
        MOV BX,7
        INT 10H
        GETBYTE
        INC DI
        CMP AL,10H
        MOV SI,OFFSET DBL10
        JZ SOURCE5
        MOV SI,OFFSET DBL11
        CMP AL,11H
        JZ SOURCE5
        MOV SI,OFFSET SINGLE
        JMP SOURCE6
SOURCE5:
        GETBYTE
        INC DI
SOURCE6:
        CMP AL,0
        JZ SOURCE8
SOURCE7:   
        INC SI
        CMP BYTE PTR [SI-1],'|'
        JNZ SOURCE7
        DEC AL
        JMP SOURCE6
SOURCE8:
        MOV AL,[SI]
        INC SI
        CMP AL,'|'
        JZ SOURCE9
        CMP AL,'$'
        JZ SOURCE10
        MOV AH,14
        MOV BX,7
        INT 10H
        JMP SOURCE8
        RET
SOURCE9:
        INC DH
        CMP DH,24
        JB SOURCE4
        MOV AX,DI
        AND AX,0F0FH
        MOV BH,0
        MOV BL,AH
        NOT BX
        MOV AH,HEX_LIST[BX+16]
        MOV MSG8A[1],AH
        MOV BL,AL
        NOT BL              
        MOV AH,HEX_LIST[BX+16]
        MOV MSG8A[3],AH
        MOV AX,DI
        MOV CL,4
        SHR AX,CL
        AND AX,0F0FH
        MOV BH,0
        MOV BL,AH
        NOT BX
        MOV AH,HEX_LIST[BX+16]
        MOV MSG8A,AH
        MOV BL,AL
        NOT BL
        MOV AH,HEX_LIST[BX+16]
        MOV MSG8A[2],AH
        RET
SOURCE10:
        MOV AL,[SI]
        INC SI
        CMP AL,'d'      ;Base page direct mode
        MOV AH,'<'
        JZ SOURCE11
        CMP AL,'o'      ;8-bit post-byte offset
        JZ SOURCE11A
        CMP AL,'b'      ;8-bit immediate
        JNZ SOURCE12
        MOV AH,'#'
SOURCE11:        
        MOV AL,AH
        MOV AH,14
        MOV BX,7
        INT 10H
SOURCE11A:
        MOV AX,0E24H
        INT 10H
        PUSH DX
        MOV AH,3
        INT 10H
        GETBYTE
        INC DI
        CALL BIT8
        POP DX
        JMP SOURCE8
SOURCE12:
        CMP AL,'l'      ;Long label branch
        JZ SOURCE13
        CMP AL,'s'      ;Short label branch
        JNZ SOURCE15
        GETBYTE
        INC DI
        CBW
        ADD AX,DI
        JMP SOURCE14
SOURCE13:
        GETWORD
        ADD DI,2
        ADD AX,DI
SOURCE14:
        PUSH DX
        PUSH AX
        MOV AX,0E24H
        MOV BX,7
        INT 10H
        MOV AH,3
        INT 10H
        POP AX
        CALL BIT16
        POP DX
        JMP SOURCE8
SOURCE15:
        CMP AL,'a'      ;16-bit extended direct address
        MOV AH,14
        MOV BX,7
        JNZ SOURCE16
        GETWORD
        CMP AH,0
        JNZ SOURCE15B
        PUSH AX
        MOV AH,14
        MOV AL,'>'
        INT 10H
        POP AX
SOURCE15B:
        ADD DI,2
        JMP SOURCE14
SOURCE15A:        
        GETWORD
        ADD DI,2
        JMP SOURCE14
SOURCE16:
        CMP AL,'O'      ;16-bit post-byte offset
        JZ SOURCE15A
        CMP AL,'w'      ;16-bit immediate
        JNZ SOURCE17
        MOV AL,'#'
        MOV AH,14
        INT 10H
        GETWORD
        ADD DI,2
        JMP SOURCE14
SOURCE17:
        CMP AL,'2'      ;Binary
        JZ SOURCE17A
        CMP AL,'p'      ;Indirect index addressing post byte
        JZ SOURCE18
        CMP AL,'t'      ;EXG/TFR post byte
        JZ SOURCE19
        CMP AL,'r'      ;PSHS/PULS post byte
        MOV SI,OFFSET SP_LIST
        JZ SOURCE24A
        CMP AL,'u'      ;PSHU/PULU post byte
        MOV SI,OFFSET UP_LIST
SOURCE24A:        
        JZ SOURCE24
        MOV AX,0E00H+'?'
        INT 10H
        GETBYTE
        INC DI
        JMP SOURCE8
SOURCE17A:
        MOV AX,0E23H
        INT 10H
        MOV AX,0E25H
        INT 10H
        GETBYTE
        INC DI
        MOV CL,AL
        MOV CH,8
SOURCE17B:
        MOV AL,'0'
        ROL CL,1
        ADC AL,0
        MOV AH,14
        INT 10H
        DEC CH
        JNZ SOURCE17B
        JMP SOURCE8
SOURCE18:
        GETBYTE
        INC DI
        MOV SI,OFFSET POST_TABLE
        JMP SOURCE6
SOURCE19:
        GETBYTE
        INC DI
        PUSH AX
        MOV CL,4
        SHR AL,CL
        MOV SI,OFFSET EXG_LIST
SOURCE20:        
        CMP AL,0
        JZ SOURCE22
SOURCE21:        
        INC SI
        CMP BYTE PTR [SI-1],'|'
        JNZ SOURCE21
        DEC AL
        JNZ SOURCE21
SOURCE22:
        MOV AL,[SI]
        INC SI
        MOV AH,14
        MOV BX,7
        INT 10H
        CMP BYTE PTR [SI],'|'
        JNZ SOURCE22
        CMP CL,4
        JZ SOURCE23
SOURCE9A:
        JMP SOURCE9
SOURCE23:
        MOV AH,14
        MOV AL,','
        INT 10H
        POP AX
        AND AL,15
        MOV CL,0
        MOV SI,OFFSET EXG_LIST
        JMP SOURCE20
SOURCE24:
        GETBYTE
        INC DI
        CMP AL,0
        JZ SOURCE9A
        MOV CL,AL
SOURCE25:
        SHL CL,1
        JC SOURCE27
SOURCE26:
        INC SI
        CMP BYTE PTR [SI-1],'|'
        JNZ SOURCE26
        JMP SOURCE25
SOURCE27:
        MOV AL,[SI]
        MOV AH,14
        MOV BX,7
        INT 10H
        INC SI
        CMP BYTE PTR [SI],'|'
        JNZ SOURCE27
        CMP CL,0
        JZ SOURCE9A
        MOV AL,','
        MOV AH,14
        INT 10H
        INC SI
        JMP SOURCE25
SOURCE  ENDP

;Transfer 8086 flags in REGF to 6809 format in REGFI, no registers affected

XLTFLAG PROC NEAR
        PUSH AX
        PUSH BX
        MOV AX,REGF
        AND AX,08F7H
        OR AL,AH
        MOV BX,OFFSET FLAGS_TO_6809
        XLAT
        AND BYTE PTR REGFI,0D0H
        OR REGFI,AL
        POP BX
        POP AX
        RET
XLTFLAG ENDP

;Transfer 6809 flags in REGFI to 8086 flags in REGF, no registers affected

UPDFLAG PROC NEAR
        PUSH AX
        PUSH BX
        MOV AL,REGFI
        MOV BX,OFFSET FLAGS_TO_8086
        XLAT
        MOV AH,AL
        AND AX,08F7H
        AND REGF,0F72EH
        OR REGF,AX
        POP BX
        POP AX
        RET
UPDFLAG ENDP

;Display flag contents

SHOWFL  PROC NEAR
        MOV CH,8
        MOV CL,REGFI
        MOV DX,0E01H
SHOWFL1:
        MOV BH,0
        MOV AH,2
        INT 10H
        ADD DL,2
        MOV AX,0E30H
        ROL CL,1
        ADC AL,0
        MOV BL,7
        INT 10H
        DEC CH
        JNZ SHOWFL1
        RET
SHOWFL  ENDP

;Display message pointed to by SI on last line of video.  Must be terminated
;by a 0.

DISPLAY:
        MOV DX,1800H        
        MOV AH,2
        MOV BX,14
        INT 10H
        MOV AX,920H
        MOV BX,14
        MOV CX,80
        INT 10H
DISPLAY1:
        MOV AL,[SI]
        CMP AL,0
        JZ DISPLAY2
        MOV AH,14
        INT 10H
        INC SI
        JMP DISPLAY1
DISPLAY2:
        RET

;Return an address in AX (if NZ) or a register code in CL (if Z).
;Storage field is at DI, prompt text is at SI.

ADDRESS PROC NEAR
        MOV CX,4
        CALL INPUT
        JNC ADDR0
        RET
ADDR0:  CMP WORD PTR [DI],5044H
        JNZ ADDR3
        MOV CX,6
        CLC
        RET
ADDR3:  CMP WORD PTR [DI],2F41H
        JNZ ADDR4
        MOV CX,7
        CLC
        RET
ADDR4:  MOV AL,[DI]
        FIND RG_LIST,5
        CLC
        PUSHF
        MOV AX,0
        JNZ ADDR1
        INC CL
        POPF
        RET
ADDR1:  MOV BX,AX
        MOV AL,[DI]
        FIND HEX_LIST,16
        JNZ ADDR2        
        MOV AX,CX
        MOV CL,4
        SHL BX,CL
        ADD AX,BX
        INC DI
        JMP ADDR1
ADDR2:  POPF
        MOV AX,BX
        RET
ADDRESS ENDP

;Display 16-bit contents in AX at cursor location DX

BIT16:
        PUSH AX
        MOV AH,2
        MOV BH,0
        INT 10H
        POP AX
        MOV CX,404H
BIT16_1:
        ROL AX,CL
        PUSH AX
        AND AX,15
        MOV BX,AX
        NEG BX
        MOV AL,HEX_LIST[BX+15]
        MOV AH,14
        MOV BX,7
        INT 10H
        POP AX
        DEC CH
        JNZ BIT16_1
        RET

;Display 8-bit contents of AL at cursor location DX

BIT8    PROC NEAR
        PUSH AX
        MOV AH,2
        MOV BH,0
        INT 10H
        POP AX
        MOV CX,204H
        XCHG AH,AL
        JMP BIT16_1
BIT8    ENDP

;Update register contents

SHOWREG PROC NEAR
        MOV DX,404H
        MOV AX,REGD
        CALL BIT16
        INC DH
        MOV AX,REGX
        CALL BIT16
        INC DH
        MOV AX,REGY
        CALL BIT16
        INC DH
        MOV AX,REGU
        CALL BIT16
        INC DH
        MOV AX,REGSP
        CALL BIT16
        INC DH
        MOV AX,REGPC
        CALL BIT16
        INC DH
        MOV AL,REGDP
        CALL BIT8
        RET
SHOWREG ENDP

;Display prompt at SI and use last CX bytes as input field.  Return C set
;if ESC pressed.

INPUT   PROC NEAR
        PUSH SI
        PUSH CX
        CALL DISPLAY
        MOV AH,3
        MOV BH,0
        INT 10H
        POP CX
        POP SI
        SUB DL,CL
        MOV AH,2
        INT 10H
        MOV DH,0
        MOV DI,SI
        ADD DI,DX
        PUSH DI
        MOV BX,OFFSET BACKUP
INPUT0: MOV AL,[DI]
        MOV [BX],AL
        INC DI
        INC BX
        CMP AL,0
        JNZ INPUT0
        POP DI
        MOV BX,DI
        CSRON
        KEYSTROKE
        CMP AL,13
        JZ INPUT1
        CLEAR
        JMP INPUT3
INPUT1: CSROFF
        CLC
        RET
INPUT2: KEYSTROKE
INPUT3: CMP AL,13
        JZ INPUT1
        CMP AL,27
        JNZ INPUT4
        MOV BX,OFFSET BACKUP
        PUSH DI
INPUT7: MOV AL,[BX]    
        MOV [DI],AL
        INC BX
        INC DI
        CMP AL,0
        JNZ INPUT7
        POP DI
        CSROFF
        STC
        RET
INPUT4: CMP AL,8
        JNZ INPUT5
        CMP BX,DI
        JNA INPUT2
        DEC BX
        MOV BYTE PTR [BX],32
        MOV AH,14
        PUSH BX
        MOV BX,14
        INT 10H
        MOV AX,0E20H
        INT 10H
        MOV AX,0E08H
        INT 10H
        POP BX
        JMP INPUT2
INPUT5: CMP AL,32
        JB INPUT2
        CMP AL,96
        JB INPUT6
        SUB AL,32
INPUT6: CMP BYTE PTR [BX],0
        JZ INPUT2
        MOV [BX],AL
        INC BX
        MOV AH,14
        PUSH BX
        MOV BX,14
        INT 10H
        POP BX
        JMP INPUT2
INPUT   ENDP

;Display memory dump

SHOWMEM PROC NEAR
        MOV BL,MEMTYPE
        CMP BL,0
        JZ EXPLICIT1
        MOV BH,0
        ADD BX,BX
        MOV AX,REGPC[BX-2]
        MOV MEMADR,AX
EXPLICIT1:
        MOV AX,MEMADR
        MOV DX,21FH
        CMP BYTE PTR MEMTYPE,0
        JZ SHOWMEM2
        MOV AH,2
        MOV BX,7
        INT 10H
        MOV AX,0E00H+'['
        INT 10H
        MOV AH,14
        MOV AL,MSG4A
        CMP AL,'A'
        JNZ SHOWMEM0
        MOV AL,'D'
SHOWMEM0:
        INT 10H
        MOV AL,MSG4A
        CMP AL,'P'
        MOV CX,'C]'
        JZ SHOWMEM1
        MOV CX,'P]'
        CMP AL,'D'
        JZ SHOWMEM1
        MOV CX,'] '
SHOWMEM1:        
        MOV AH,14
        MOV AL,CH
        INT 10H
        MOV AH,14
        MOV AL,CL
        INT 10H
        JMP SHOWMEM3
SHOWMEM2:
        CALL BIT16
SHOWMEM3:
        MOV DX,312H
        MOV DI,MEMADR
SHOWMEM4:        
        MOV AX,DI
        CALL BIT16
        MOV AH,14
        MOV AL,':'
        MOV BX,7
        INT 10H
        PUSH DI
        MOV DL,24
SHOWMEM5:
        GETWORD
        ADD DI,2
        CALL BIT16
        ADD DL,5
        CMP DL,64
        JB SHOWMEM5
        MOV AX,0E20H
        MOV BX,7
        INT 10H
        POP DI
        MOV CX,16
SHOWMEM6:
        GETBYTE
        INC DI
        AND AL,127
        CMP AL,33
        JNB SHOWMEM7
        MOV AL,'.'
SHOWMEM7:
        MOV AH,14
        INT 10H
        LOOP SHOWMEM6
        INC DH
        MOV DL,18
        CMP DH,11
        JB SHOWMEM4
        RET
SHOWMEM ENDP

;Display U and SP stack contents

SHOWSP  PROC NEAR
        MOV DI,REGU
        MOV DX,1207H
SHOWSP1:
        GETWORD
        ADD DI,2
        CALL BIT16
        INC DH
        CMP DH,17H
        JB SHOWSP1
        MOV DI,REGSP
        MOV DX,120CH
SHOWSP2:
        GETWORD
        ADD DI,2
        CALL BIT16
        INC DH
        CMP DH,17H
        JB SHOWSP2
        RET
SHOWSP  ENDP

;Start of program, initialisation

START:  MOV AX,ES:[2CH]         ;Save environment segment
        MOV CS:ENVIRONMENT,AX
        MOV AH,3
        MOV BH,0
        INT 10H
        MOV CS:ORIGINAL_CURSOR,CX
        MOV CS:BASE_SEGMENT,ES
        MOV BX,OFFSET RAMHERE   ;Allocate program memory
        MOV CL,4
        SHR BX,CL
        MOV AX,CS
        ADD BX,AX               ;plus prefixed segments
        MOV AX,ES
        SUB BX,AX
        ADD BX,2001H            ;plus 64K RAM + 64K ROM of CoCo
        MOV CS:MEMORY_SIZE,BX   ;Store for use with shelling routine
        MOV AH,4AH
        INT 21H
        JNB ENOUGH_MEMORY
        MOV AX,CS
        MOV DS,AX
        SUB BX,MEMORY_SIZE      ;Calculate how short we were
        NEG BX
        MOV CL,6
        SHR BX,CL
        INC BX
        MOV AX,BX
        MOV BL,10
        DIV BL
        OR MSG44A[2],AH
        MOV AH,0
        DIV BL
        OR WORD PTR MSG44A,AX
        MOV AH,9
        MOV DX,OFFSET MSG44
        INT 21H
        MOV AX,4C00H
        INT 21H
ENOUGH_MEMORY:
        MOV SP,8000H
        MOV SI,129              ;Get snapshot name if applicable
        MOV DI,OFFSET SNAP_NAME
        MOV BL,0                ;Reset extension found flag
PRELOAD:
        MOV AL,[SI]
        INC SI
        CMP AL,32               ;Skip leading spaces
        JZ PRELOAD
        CMP AL,13               ;If CR, no name given
        JZ RESTART
        DEC SI                  ;Something found in command line
PRELOAD1:
        MOV AL,[SI]
        CMP AL,13               ;If carriage return found, done
        JZ PRELOAD4
        CMP AL,' '              ;Same with space
        JZ PRELOAD4
        CMP AL,'\'              ;If backslash, reset "extension flag"
        JNZ PRELOAD2
        MOV BL,0
PRELOAD2:
        CMP AL,'.'              ;Period found, set "extension flag"
        JNZ PRELOAD3
        INC BL
PRELOAD3:
        MOV CS:[DI],AL
        INC SI
        INC DI
        CMP DI,OFFSET SNAP_NAME+28      ;Leave enough room for extension
        JB PRELOAD1
PRELOAD4:                       ;Extensinon needed?
        OR BL,BL
        JNZ PRELOAD5
        MOV WORD PTR CS:[DI],502EH       ;".PAK"
        MOV WORD PTR CS:[DI+2],4B41H
        ADD DI,4
PRELOAD5:                       ;Terminating 0
        MOV CS:BYTE PTR [DI],0
        MOV BYTE PTR CS:PRELOAD_FLAG,-1
RESTART:
        MOV SP,8000H
        PUSH CS                 ;Set registers properly
        POP DS
        MOV CART_FLAG,0
        CSROFF
        MOV BX,OFFSET RAMHERE   ;Load RAM/ROM etc.
        MOV CL,4
        SHR BX,CL
        INC BX
        MOV AX,CS
        ADD AX,BX
        MOV SS:RAMBANK,AX       ;Set PC segment for 64K RAM
        MOV SS:BANK0R,AX
        MOV SS:BANK0W,AX
        MOV ES,AX               ;Clear RAM
        MOV CX,8000H
        PUSH AX
        MOV AX,-1
        MOV DI,0
        REP STOSW
        POP AX
        ADD AH,8
        MOV SS:ROMBANK,AX       ;Set PC segment for 32K ROM
        MOV SS:BANK1R,AX
        MOV ES,AX
        ADD AH,8
        MOV SS:BANK1W,AX        ;Direct ROM write to dead space after ROM
        MOV CH,80H
        MOV AL,7EH
        MOV DI,CX
        REP STOSB
        MOV AH,1AH
        MOV DX,OFFSET DTA
        INT 21H
START1: MOV AH,11H
        MOV DX,OFFSET ROMSEARCH
        INT 21H
        INC AL
        JNZ START2
        MOV AH,9
        MOV DX,OFFSET MSG14
        INT 21H
        MOV AX,4C00H
        INT 21H
START2: MOV SI,OFFSET DTA+1
        MOV DI,OFFSET ROMNAME        
START2A: 
        MOV AL,[SI]
        CMP AL,' '
        JZ START3
        MOV [DI],AL
        INC SI
        INC DI
        CMP SI,OFFSET DTA+9
        JB START2A
START3: MOV WORD PTR [DI],522EH ;".ROM",0
        MOV WORD PTR [DI+2],4D4FH
        MOV BYTE PTR [DI+4],0
        MOV DX,OFFSET ROMNAME
        MOV AX,3D00H
        INT 21H
        MOV BX,AX
        JNB START4
ERROR:  MOV AH,3EH
        INT 21H
        MOV BYTE PTR [DI+4],'$'
        MOV DX,OFFSET MSG15
        MOV AH,9
        INT 21H
        MOV AX,4C00H
        INT 21H
START4: MOV AH,3FH
        MOV DX,OFFSET REGPC
        MOV CX,2
        INT 21H
        JB ERROR
        CMP AX,2
        JNZ ERROR
        MOV DX,REGPC
        PUSH ES
        POP DS
        MOV CX,1
        MOV AH,3FH
        INT 21H
        ADD DX,AX
        MOV CX,-1
        MOV AH,3FH
        INT 21H
        PUSH CS
        POP DS
        JB ERROR
        MOV AH,3EH
        INT 21H
        MOV AH,12H
        MOV DX,OFFSET ROMSEARCH
        INT 21H
        INC AL
        JNZ START2
        MOV DI,0FFFEH
        GETWORD
        MOV BP,AX
        MOV AX,0                ;Test for presence of mouse
        INT 33H
        MOV MOUSE_HERE,AL
        PUSH ES
        MOV AX,3509H            ;Load old interrupt vectors
        INT 21H
        MOV KEY_LOW,BX
        MOV KEY_HI,ES
        MOV AX,3508H
        INT 21H
        MOV CLK_LOW,BX
        MOV CLK_HI,ES
        MOV AX,3523H
        INT 21H
        MOV BREAK_LO,BX
        MOV BREAK_HI,ES
        MOV AX,2508H
        MOV DX,OFFSET CLOCK_INTERCEPT
        INT 21H
        MOV AX,2509H
        MOV DX,OFFSET KEY_INTERCEPT
        INT 21H
        MOV AX,2523H
        MOV DX,OFFSET BREAK_INTERCEPT
        INT 21H
        PUSH CS
        POP ES
        MOV DX,OFFSET MOUSE_INTERCEPT
        MOV CX,47
        MOV AX,14H
        INT 33H
        MOV MOUSE_LO,DX
        MOV MOUSE_HI,ES
        MOV MOUSE_MK,CX
        POP ES
        MOV SI,OFFSET CUR_PATH  ;Save power-up path
        CALL SAVE_PATH
        MOV SI,OFFSET VIR_DIR   ;Also set it as default for virtual dir.
        CALL SAVE_PATH
        MOV SI,OFFSET CAS_DIR   ;the virtual cassette directory...
        CALL SAVE_PATH
        MOV SI,OFFSET SNAP_PATH ;and snapshots
        CALL SAVE_PATH
        MOV AX,3D00H            ;Read last virtual disk settings, if any
        MOV DX,OFFSET DISK_CONFIG
        INT 21H
        MOV BX,AX
        JB NO_DISK_CONFIG
        MOV AH,3FH
        MOV DX,OFFSET CFG1TOP
        MOV CX,OFFSET CFG1END-OFFSET CFG1TOP
        INT 21H
        MOV AH,3EH
        INT 21H
NO_DISK_CONFIG:
        MOV AX,3D00H            ;and general configurations file, if any
        MOV DX,OFFSET GENERAL_CONFIG
        INT 21H
        MOV BX,AX
        JB NO_GENERAL_CONFIG
        MOV AH,3FH
        MOV DX,OFFSET CFG2TOP
        MOV CX,OFFSET CFG2END-OFFSET CFG2TOP
        INT 21H
        PUSH DS
        MOV AX,SS
        MOV DS,AX
        MOV AH,3FH
        MOV DX,CUSTOM_LIST
        MOV CX,196
        INT 21H
        POP DS
        MOV AH,3EH
        INT 21H
NO_GENERAL_CONFIG:
        MOV SI,BP
        SAVEREG                 ;Enter standard 6809 interpreter loop
        MOV DX,OFFSET DTA+256
        CALL INITIALIZE
        MOV AL,60H
        MOV DI,400H
        MOV CX,512
        MOV ES,SS:BANK0W
        REP STOSB
        CALL SBINIT
        CALL JOYTEST
        CALL LOAD_PC_SET        ;Get PC character set
        CALL OPEN_CASSETTE      ;Open virtual cassette if any specified
        MOV AX,14
        INT 10H
        call UpdateSyncLock
        cli
        mov al,36h
        out 43h,al
        mov ax,cs:clock_period
        out 40h,al
        mov al,ah
        out 40h,al
        sti
;        JMP HELP
ALERT:  
;        MOV DI,0FFFEH           ;Load reset vector into PC
;        GETWORD
;        MOV REGPC,AX
;        MOV DI,0FFDEH           ;Request SAM to switch in ROMs
;        PUTBYTE
;        MOV DI,0FFD4H           ;Make sure lower memory is first 32K
;        PUTBYTE
;        CALL FREEZE
;        MOV DI,OFFSET MSG0
;        MOV DX,916H
;        MOV BX,8724H
;        MOV MENU_BACK,4         ;Make this window red/yellow
;        MOV SP,8000H
;        JMP ALERT1
HELP:   CALL FREEZE             ;Display power-up screen
        MOV DI,OFFSET MSG28
        MOV DX,0412H
        MOV BX,912BH
ALERT1: CALL MENU
        MOV MENU_BACK,1         ;Restore normal blue/cyan
        CALL THAW
        MOV AX,4                ;Position mouse, turn it on
        MOV CX,316
        MOV DX,96
        INT 33H
        MOV AX,1
        INT 33H
WAIT0:  MOV AH,1                ;Wait for keyboard or mouse button
        INT 16H
        JNZ WAIT2
        CMP MOUSE_HERE,0
        JZ WAIT0
        MOV AX,3
        INT 33H
        TEST BL,7
        JZ WAIT0
WAIT1:  MOV AX,3                ;Make sure mouse button released
        INT 33H
        TEST BL,7
        JNZ WAIT1
WAIT2:  MOV AX,2                ;Turn off mouse pointer
        INT 33H
        CMP BYTE PTR PRELOAD_FLAG,0
        JNZ PRELOAD6
        JMP CONTINUE1
PRELOAD6:
        JMP LSNAP1

PRELOAD_FLAG DB 0               ;Non-zero if snapshot name specified at prompt
MOUSE_HERE DB 0                 ;Non-zero => mouse present

;Debugger entrance, wait for command keystroke

DEBUG:  SAVEREG                 ;Save 6809 registers
        MOV BRKPT,-1            ;Reset break point interrupt
        MOV AH,5
        MOV AL,0
        INT 10H
        MOV AX,3
        INT 10H
        CSROFF
        PUSH ES
        MOV AX,0B800H
        MOV ES,AX
        PUSH DS
        PUSH SS
        POP DS
        MOV SI,FRAME
        MOV DI,0
        MOV CX,4000
        CLD
        REP MOVSB
        POP DS
        POP ES
        CALL SHOWREG
        CALL SHOWSP
        CALL SOURCE
        CALL SHOWMEM
        CALL XLTFLAG
        CALL SHOWFL
DEBUG_PROMPT:
        MOV SI,DBGMSG
        CALL DISPLAY
        MOV DBGMSG,OFFSET MSG2
DEBUG1: KEYSTROKE
        AND AL,223
        MOV SI,OFFSET COMMANDS
DEBUG2: CMP BYTE PTR [SI],0        
        JZ DEBUG1
        ADD SI,3
        CMP AL,[SI-3]
        JNZ DEBUG2
        JMP WORD PTR [SI-2]

;Change flag registers

FLAGS:  MOV SI,OFFSET MSG1
        CALL DISPLAY
        CALL XLTFLAG
        MOV AL,REGFI
        PUSH AX
FLAGS1: CALL SHOWFL
        KEYSTROKE
        CMP AL,13
        JZ FLAGS2
        CMP AL,27
        JZ FLAGS3
        AND AL,223
        FIND FL_LIST,8
        JNZ FLAGS1
        MOV AL,1
        ROL AL,CL
        XOR REGFI,AL
        JMP FLAGS1
FLAGS2: CALL UPDFLAG
        POP AX
        MOV AL,REGFI
        PUSH AX
FLAGS3: POP AX
        MOV REGFI,AL
        CALL SHOWFL
        JMP DEBUG_PROMPT

;Quit emulator

RESTART_FLAG DB 0

QUIT:   MOV SI,OFFSET MSG3
        CALL DISPLAY
        KEYSTROKE
        AND AL,223
        CMP AL,'Y'
        JZ QUIT1
        JMP DEBUG_PROMPT
QUIT1:  MOV AX,3
        INT 10H
QUIT1A: MOV AH,1
        MOV BH,0
        MOV CX,CS:ORIGINAL_CURSOR
        INT 10H
        MOV DX,MOUSE_LO         ;Restore mouse interrupt
        MOV ES,MOUSE_HI
        MOV CX,MOUSE_MK
        MOV AX,12
        INT 33H
        MOV AX,2509H            ;Restore keyboard interrupt
        MOV DX,KEY_LOW
        MOV DS,KEY_HI
        INT 21H
        MOV AX,2508H            ;Restore clock interrupt
        MOV DX,CS:CLK_LOW
        MOV DS,CS:CLK_HI
        INT 21H
        CLI
        MOV AL,36H              ;Slow down runaway clock
        OUT 43H,AL
        MOV AL,-1
        OUT 40H,AL
        OUT 40H,AL
        STI
        MOV AX,2523H            ;Restore CTRL-BREAK branch address
        MOV DX,CS:BREAK_LO
        MOV DS,CS:BREAK_HI
        INT 21H
        MOV AX,CS
        MOV DS,AX
        CALL SAVE_CONFIG        ;Update configurations files.
        MOV AH,3CH              ;Save virtual disk configuratons
        MOV DX,OFFSET DISK_CONFIG
        MOV CX,0
        INT 21H
        MOV BX,AX
        JB QUIT2
        MOV AH,40H
        MOV CX,OFFSET CFG1END-OFFSET CFG1TOP
        MOV DX,OFFSET CFG1TOP
        INT 21H
        MOV AH,3EH
        INT 21H
QUIT2:  CMP RESTART_FLAG,-1     ;If restarting, go back to beginning
        JZ QUIT3
        MOV AX,4C00H            ;Exit to DOS.  All's well.
        INT 21H
QUIT3:  MOV RESTART_FLAG,0
        JMP RESTART

;Memory dump

MEMORY: MOV SI,OFFSET MSG4
        CALL ADDRESS
        JNC MEMORY1
        JMP DEBUG_PROMPT
MEMORY1:
        MOV MEMTYPE,CL
        MOV MEMADR,AX
        JZ MEMORY2
        MOV MEMTYPE,0
MEMORY2:        
        CALL SHOWMEM
        JMP DEBUG_PROMPT

;Disassemble

DISASM: MOV SI,OFFSET MSG8
        CALL ADDRESS
        JNC DISASM1
        JMP DEBUG_PROMPT
DISASM1:
        MOV DISTYPE,CL
        MOV DISADR,AX
        JZ DISASM2
        MOV DISTYPE,8
DISASM2:
        MOV AL,MSG8A
        MOV LASTDIS,AL
        CALL SOURCE
        JMP DEBUG_PROMPT

;Change registers

POINTER MACRO LEFT,RIGHT        
        MOV AH,2
        MOV BX,14
        INT 10H
        MOV AX,LEFT
        MOV CX,1
        INT 10H
        PUSH DX
        ADD DL,5
        MOV AH,2
        INT 10H
        MOV AX,RIGHT
        INT 10H
        POP DX
        ENDM

SETREG: MOV SI,OFFSET MSG5
        CALL DISPLAY
        MOV DX,403H
SETREG1:
        POINTER 910H,911H
        KEYSTROKE
        PUSH AX
        POINTER 920H,920H
        POP AX
        CMP AL,27
        JNZ SETREG2
        JMP DEBUG_PROMPT
SETREG2:
        CMP AL,13
        JZ SETREG6
        CMP AX,4800H
        JZ SETREG3
        CMP AL,8
        JNZ SETREG4
SETREG3:
        DEC DH
        CMP DH,4
        JNB SETREG1
        MOV DH,10
        JMP SETREG1
SETREG4:
        CMP AX,5000H
        JZ SETREG5
        CMP AL,32
        JNZ SETREG5A
SETREG5:
        INC DH
        CMP DH,11
        JB SETREG1
        MOV DH,4
SETREG1A:        
        JMP SETREG1
SETREG5A:
        AND AL,223
        FIND PTR_LIST,11
        JNZ SETREG1A
        MOV DH,CL
SETREG6:
        POINTER 910H,911H
        MOV SI,OFFSET MSG6
        PUSH DX
        CALL ADDRESS
        POP DX
        PUSHF
        PUSH AX
        PUSH CX
        POINTER 920H,920H
        POP CX
        POP AX
        POPF
        JNC SETREG8
        JMP DEBUG_PROMPT
SETREG8:
        JNZ SETREG7
        MOV BX,CX
        ADD BX,BX
        MOV AX,REGPC[BX-2]
SETREG7:
        SUB DH,4
        JNZ SETREG10
        MOV REGD,AX
SETREG9:
        CALL SHOWREG
        CALL SHOWSP
        CALL SHOWMEM
        CALL SOURCE
        JMP DEBUG_PROMPT
SETREG10:
        DEC DH
        JNZ SETREG11
        MOV REGX,AX
        JMP SETREG9
SETREG11:
        DEC DH
        JNZ SETREG12
        MOV REGY,AX
        JMP SETREG9
SETREG12:
        DEC DH
        JNZ SETREG13
        MOV REGU,AX
        JMP SETREG9
SETREG13:
        DEC DH
        JNZ SETREG14
        MOV REGSP,AX
        JMP SETREG9
SETREG14:
        DEC DH
        JNZ SETREG15
        MOV REGPC,AX
        JMP SETREG9
SETREG15:
        MOV REGDP,AL
        JMP SETREG9

;Edit current memory page

EDIT:   MOV SI,OFFSET MSG7
        CALL DISPLAY
        CSRON
        MOV DL,0
EDIT1:  PUSH DX
        MOV DH,DL
        AND DL,31
        MOV AL,DL
        SHR DL,1
        SHR DL,1
        ADD DL,AL
        ADD DL,24
        MOV CL,5
        SHR DH,CL
        ADD DH,3
        MOV AH,2
        INT 10H
        POP DX
        KEYSTROKE
        CMP AL,13
        JNZ EDIT3
EDIT2:  CSROFF
        CALL SHOWSP
        CALL SOURCE
        JMP DEBUG_PROMPT      
EDIT3:  CMP AL,27
        JZ EDIT2
        CMP AL,32
        JZ EDIT4
        CMP AX,4D00H
        JNZ EDIT5
EDIT4:  INC DL
        JNZ EDIT1
        ADD MEMADR,128
EDIT4A: MOV MEMTYPE,0
        PUSH DX
        CALL SHOWMEM
        POP DX
EDIT1A: JMP EDIT1
EDIT5:  CMP AL,8
        JZ EDIT6
        CMP AX,4B00H
        JNZ EDIT7
EDIT6:  SUB DL,1
        JNB EDIT1A
        SUB MEMADR,128
        JMP EDIT4A
EDIT7:  CMP AL,9
        JNZ EDIT8
        ADD DL,4
        JNB EDIT1A
        ADD MEMADR,128
        JMP EDIT4A
EDIT8:  CMP AX,5000H
        JNZ EDIT9
        ADD DL,32
        JNB EDIT1A
        ADD MEMADR,128
        JMP EDIT4A
EDIT9:  CMP AX,4800H
        JNZ EDIT9A
        SUB DL,32
        JNB EDIT1A
        SUB MEMADR,128
        JMP EDIT4A
EDIT9A: CMP AX,5100H
        JNZ EDIT9B
        ADD MEMADR,128
        JMP EDIT4A
EDIT9B: CMP AX,4900H
        JNZ EDIT10
        SUB MEMADR,128
        JMP EDIT4A
EDIT10: CMP AL,96
        JB EDIT12
        SUB AL,32
EDIT12: FIND HEX_LIST,16
        JNZ EDIT1A
        PUSH AX
        MOV CH,CL
        MOV CL,4
        MOV AH,240
        PUSH DX
        SHR DL,1
        JB EDIT11
        SHL CH,CL
        ROL AH,CL
EDIT11: MOV DH,0
        ADD DX,MEMADR
        MOV DI,DX
        GETBYTE
        AND AL,AH
        OR AL,CH
        PUTBYTE
        CALL SHOWMEM
        POP DX
        JMP EDIT4

;Single step through instructions

STEP:   MOV AX,OFFSET MSG2
        MOV DBGMSG,AX
        LOADREG
        MOV BYTE PTR INST,0C3H
        CALL AUX
        SAVEREG
        CALL SHOWMEM
        CALL SOURCE
        CALL SHOWREG
        CALL SHOWSP
        CALL XLTFLAG
        CALL SHOWFL
        JMP DEBUG_PROMPT

;Hexidecimal calculator

MATH:   MOV AX,WORD PTR MSG9B
        MOV WORD PTR MSG9A,AX
        MOV AX,WORD PTR MSG9B[2]
        MOV WORD PTR MSG9A[2],AX
        MOV SI,OFFSET MSG9
        MOV CX,4
        CALL ADDRESS
        JNC MATH1
        JMP DEBUG_PROMPT
MATH1:  JNZ MATH2
        MOV BX,CX
        ADD BX,BX
        MOV AX,REGPC[BX-2]
MATH2:  MOV CALCDATA,AX
MATH3:  MOV SI,OFFSET MSG10
        CALL DISPLAY
        MOV AX,CALCDATA
        MOV DX,1800H
        CALL BIT16
        PUSH ES
        MOV AX,0B800H
        MOV ES,AX
        MOV AL,ES:[0F00H]
        MOV MSG9B,AL
        MOV AL,ES:[0F02H]
        MOV MSG9B[1],AL
        MOV AL,ES:[0F04H]
        MOV MSG9B[2],AL
        MOV AL,ES:[0F06H]
        MOV MSG9B[3],AL
        POP ES
MATH4:  KEYSTROKE
        CMP AL,96
        JB MATH5
        SUB AL,32
MATH5:  FIND CALC_CMD,13
        JNZ MATH4
        SUB CL,2                ;ENTER or ESC
        JNB MATH6
        JMP DEBUG_PROMPT
MATH6:  SUB CL,2                ;'S' or 'R'
        JNB MATH12
        INC CL                  ;CL=-1 -> 'R', CL=0 -> 'S'
        MOV SI,OFFSET MSG11
        JZ MATH7
        MOV SI,OFFSET MSG12
MATH7:  PUSH CX
        PUSH SI
        CALL DISPLAY
        MOV AX,CALCDATA
        MOV DX,1800H
        CALL BIT16
        KEYSTROKE
        POP SI
        POP CX
        CMP AL,27
        JZ MATH3
        CMP AL,13
        JZ MATH3
        CMP AL,8
        JZ MATH10
        CMP AX,4D00H
        JZ MATH10
        CMP AL,32
        JZ MATH8
        CMP AX,4B00H
        JNZ MATH7
MATH8:  OR CL,CL
        JZ MATH9
        ROL CALCDATA,1
        JMP MATH7
MATH9:  SHL CALCDATA,1
        JMP MATH7
MATH10: OR CL,CL
        JZ MATH11
        ROR CALCDATA,1
        JMP MATH7
MATH11: SHR CALCDATA,1
        JMP MATH7
MATH12: JNZ MATH13
        NEG CALCDATA
        JMP MATH3
MATH13: CMP AL,'D'
        JZ MATH13B
        PUSH CX
        MOV MSG9B[5],AL
        MOV WORD PTR MSG9A,2020H
        MOV WORD PTR MSG9A[2],2020H
        MOV SI,OFFSET MSG9B
        CALL ADDRESS
        MOV BX,CX
        POP CX
        JNC MATH13A
        JMP MATH3
MATH13A:
        JNZ MATH13B
        ADD BX,BX
        MOV AX,REGPC[BX-2]
MATH13B:
        DEC CL
        JNZ MATH14
        XOR CALCDATA,AX
        JMP MATH3
MATH14: DEC CL
        JNZ MATH15
        OR CALCDATA,AX
        JMP MATH3
MATH15: DEC CL
        JNZ MATH16
        AND CALCDATA,AX
        JMP MATH3
MATH16: DEC CL
        JNZ MATH17
        AND AX,AX
        JZ MATH16A
        XCHG AX,CALCDATA
        MOV DX,0
        DIV CALCDATA
        MOV CALCDATA,AX
MATH16A:
        JMP MATH3
MATH17: DEC CL
        JNZ MATH18
        MUL CALCDATA
        MOV CALCDATA,AX
        JMP MATH3
MATH18: DEC CL
        JNZ MATH19
        SUB CALCDATA,AX
        JMP MATH3
MATH19: DEC CL
        JNZ MATH20
        ADD CALCDATA,AX
        JMP MATH3
MATH20: MOV AX,WORD PTR MSG9B
        MOV WORD PTR MSG13,AX
        MOV AX,WORD PTR MSG9B[2]
        MOV WORD PTR MSG13[2],AX
        MOV AX,CALCDATA
        MOV SI,OFFSET MSG13B-2
        MOV MSG13A[5],' '
;        TEST AH,128
;        MOV MSG13A,'+'
;        JZ MATH21
;        MOV MSG13A,'-'
;        NEG AX
MATH21: MOV DX,0
        DIV TEN
        ADD DL,30H
        MOV [SI],DL
        DEC SI
        CMP SI,OFFSET MSG13A-1
        JA MATH21
        MOV CX,6
        MOV SI,OFFSET MSG13
        CALL INPUT
        MOV SI,OFFSET MSG13A
        MOV AX,0
        MOV DH,AH
        MOV BH,AH
        JNB MATH22
        JMP MATH3
MATH22: MOV DL,[SI]
        CMP DL,'-'
        JNZ MATH24
        NOT BH
MATH24: SUB DL,'0'
        JB MATH23
        CMP DL,9
        JA MATH23
        PUSH DX
        MUL TEN
        POP DX
        MOV DH,0
        ADD AX,DX
MATH23: INC SI
        CMP SI,OFFSET MSG13B
        JB MATH22
        TEST BH,-1
        JZ MATH25
        NEG AX
MATH25: MOV CALCDATA,AX
        JMP MATH3

TEN     DW 10

;Set break point and continue

BREAK:  MOV AX,OFFSET MSG2
        MOV DBGMSG,AX
        MOV SI,OFFSET MSG16
        CALL ADDRESS
        JZ BREAK1
        JNB BREAK2
BREAK1: JMP DEBUG_PROMPT
BREAK2: MOV BRKPT,AX
        MOV AX,14
        INT 10H
        MOV LASTKEY,0
        MOV VID_SEG,0A400H
        MOV VID_PAG,1
        CALL SHOW
        MOV DX,1500H
        MOV DI,OFFSET MSG20
        CALL COLUMN
        MOV AX,BRKPT
        MOV DX,1702H
        CALL BIT16
        CALL RESETBRANCH
        LOADREG
        JMP MAIN

;Show-video mode

BANK_BIT DB -1

SET_BANK_BIT:
        MOV BANK_BIT,0FFH
        CMP BYTE PTR PAGE_STATUS,0D5H
        JNZ SET_BANK_BIT1
        MOV BANK_BIT,7FH
SET_BANK_BIT1:
        RET

VIDEO:  MOV AX,14
        INT 10H
        CALL SET_BANK_BIT
        MOV LASTKEY,0
        MOV AX,NEW_TOP
        AND AH,BANK_BIT
        MOV V_TOP,AX
        MOV AX,NEW_BOTTOM
        AND AH,BANK_BIT
        MOV V_BOTTOM,AX
        MOV AX,NEWSET
        MOV CHARSET,AX
        MOV AL,NEW_DIV
        MOV V_DIV,AL
        CALL FIX_HEIGHT
        MOV AL,NEW_WIDTH
        MOV V_WIDTH,AL
        MOV AL,DRB2
        MOV OLD_DRB2,AL
        CALL SHOW
        MOV LASTKEY,3BH
        KEYSTROKE
        LOADREG
        JMP DEBUG

SHOW    PROC NEAR
        CMP CS:LASTKEY,3BH
        JNZ SHOW0
        RET
SHOW0:  PUSH DI
        PUSH BX
        PUSH DX
        MOV AX,LOWERCASE
        MOV SG_MODE,AX
        TEST DRB2,16
        JZ SHOW0A
        MOV SG_MODE,12800       ;Load alternate "character set" if mode=SG6
SHOW0A: XOR VID_SEG,400H
        XOR VID_PAG,1
        CALL CLEAR_BORDER
        MOV BX,V_TOP
        MOV ES,SS:RAMBANK       ;Video always runs off true RAM
SHOW1:  MOV AL,BANK_BIT
        NOT AL
        OR BH,AL
        MOV AL,ES:[BX]
        CALL CHARGEN
        INC BX
        AND BH,BANK_BIT        
        CMP BX,V_BOTTOM
        JB SHOW1
        MOV AH,5
        MOV AL,VID_PAG
        INT 10H
        PUSH SI
        MOV AL,DRB2                     ;Determine colour palette
        AND AL,0F8H
        CMP AL,0F8H                     ;Check for G6R black/buff mode
        JNZ SHOW4
        CMP BYTE PTR ARTIFACT,0         ;If so, check artifacting selection
        JZ SHOW4
        MOV DI,OFFSET PALETTE_ART0
        CMP BYTE PTR ARTIFACT,1
        JZ SHOW2
        MOV DI,OFFSET PALETTE_ART1
        JMP SHOW2
SHOW4:  AND AL,144
        MOV SI,OFFSET PALETTE_GC0
        MOV DI,OFFSET PALETTE_GC1
        CMP AL,16                       ;SG6 and G#C modes are four colour
        JZ SHOW2
        CMP AL,128
        JZ SHOW2
        MOV SI,OFFSET PALETTE_GR0       ;G#R modes are two colour
        MOV DI,OFFSET PALETTE_GR1
        CMP AL,144
        JZ SHOW2
        MOV SI,OFFSET PALETTE_T0        ;All others are eight colour
        MOV DI,OFFSET PALETTE_T1
SHOW2:  TEST BYTE PTR DRB2,8
        MOV DX,SI
        JZ SHOW3
        MOV DX,DI
SHOW3:  PUSH ES
        MOV AX,DS
        MOV ES,AX
        MOV AX,1002H
        INT 10H
        POP ES
        POP SI
        POP DX
        POP BX
        POP DI
        RET
SHOW    ENDP

PALETTE_T0  DB 0,1,2,3,4,5,6,7,26,25,26,27,28,29,30,31,0
PALETTE_T1  DB 0,1,0,3,4,5,6,7,26,25,6,27,28,29,30,31,0
PALETTE_GC0 DB 26,1,2,30,1,5,7,4,24,25,26,27,25,29,30,28,0
PALETTE_GC1 DB 31,1,0,27,4,5,7,0,24,25,6,27,29,29,30,6,0
PALETTE_GR0 DB 0,1,2,3,4,5,6,7,24,25,26,27,28,29,30,26,0
PALETTE_GR1 DB 0,1,2,3,4,5,6,7,24,25,26,27,28,29,30,15,0
PALETTE_ART0 DB 0,1,2,25,4,5,6,7,24,25,26,27,28,29,30,31,0
PALETTE_ART1 DB 0,1,2,28,4,5,6,7,24,25,26,27,25,29,30,31,0

;Continue with normal execution

CONTINUE:
        MOV AX,14
        INT 10H
        MOV LASTKEY,0
CONTINUE1:        
        MOV PRELOAD_FLAG,0
        CALL SHOW
        CALL RESETBRANCH
        LOADREG
        JMP MAIN

;Main interpreter loop

SLOW:   MOV BX,CX
        MOV CX,DELAY
        AND CH,7FH
HOLD:   LOOP HOLD
        MOV CX,BX
MAIN:   CALL AUX
BRANCH  EQU $+1        
        JMP MAIN
BRANCH1:
        JMP KEYBOARD
BRANCH2:
        JMP TIMER
BRANCH3:
        JMP BREAK_TEST
BRANCH4:
        JMP INVALID_ABORT
BRANCH5:
        JMP CLOCK_IRQ
BRANCH6:
        JMP HSYNC_IRQ

;CoCo 60Hz clock interrupt request handler

CLOCK_IRQ:
        CALL RESETBRANCH
        TEST BYTE PTR CRB1,1            ;If disabled, ignore cycle
        JZ MAIN
        TEST BYTE PTR REGFI,16          ;If I flag set, don't interrupt
        JNZ MAIN
        CALL IRQ
        JMP MAIN

;CoCo 16kHz HSYNC interrupt request handler

HSYNC_IRQ:
        CALL RESETBRANCH
        TEST BYTE PTR CRA1,1            ;If disabled on PIA, ignore cycle
        JZ MAIN
        TEST BYTE PTR REGFI,64          ;If F flag set, no IRQ interrupt
        JNZ MAIN
        CALL FIRQ
        JMP MAIN

;Additional breakpoint test in interpreter loop

BREAK_TEST:
        CMP SI,BRKPT
        JNZ BREAK_TEST_1
        MOV DBGMSG,OFFSET MSG18
        MOV LASTKEY,3BH
        JMP DEBUG
BREAK_TEST_1:
        MOV BX,CX
        MOV CX,DELAY
        AND CH,7FH
        JNZ HOLD
        MOV CX,BX
        JMP MAIN

;Generate HSYNC FIRQ

        public MakeHSYNC,HSYNC_PULSE

HSYNC_PULSE DB 0

MakeHSYNC:
        MOV HSYNC_PULSE,128     ;Set CoCo's clock FIRQ bit on PIA1's CRA
        MOV BYTE PTR INST,0C3H
        MOV BYTE PTR BRANCH,OFFSET BRANCH6-OFFSET BRANCH1
        RET

;The following code is executed once per PC clock pulse

NEED_FLAG DB 0

PREV_BANK_BIT DB -1

REVISE  PROC NEAR
        PUSH AX
        CALL SET_BANK_BIT
        MOV AX,NEW_TOP
        AND AH,BANK_BIT
        CMP AX,V_TOP
        JNZ TIMER1
        MOV AX,NEW_BOTTOM
        AND AH,BANK_BIT
        CMP AX,V_BOTTOM
        JNZ TIMER1
        MOV AL,BANK_BIT
        CMP AL,PREV_BANK_BIT
        JNZ TIMER1
        MOV AL,DRB2
        XOR AL,OLD_DRB2
        AND AL,0F8H
        JZ TIMER2
TIMER1: MOV AL,BANK_BIT
        MOV PREV_BANK_BIT,AL
        MOV AX,NEW_TOP
        AND AH,BANK_BIT
        MOV V_TOP,AX
        MOV AX,NEW_BOTTOM
        AND AH,BANK_BIT
        MOV V_BOTTOM,AX
        MOV AX,NEWSET
        MOV CHARSET,AX
        MOV AL,NEW_DIV
        MOV V_DIV,AL
        CALL FIX_HEIGHT
        MOV AL,NEW_WIDTH
        MOV V_WIDTH,AL
        MOV AL,DRB2
        MOV OLD_DRB2,AL
        CALL SHOW
TIMER2: MOV NEED_FLAG,0
        POP AX
        RET
REVISE  ENDP

NEED_REVISE PROC NEAR
        PUSH AX
        MOV AX,NEW_TOP
        CMP AX,V_TOP
        JNZ NEED1
        MOV AX,NEW_BOTTOM
        CMP AX,V_BOTTOM
        JNZ NEED1
        MOV AL,DRB2
        XOR AL,OLD_DRB2
        AND AL,0F8H
        JZ NEED2
NEED1:  MOV NEED_FLAG,1
NEED2:  POP AX
        RET
NEED_REVISE ENDP

GAXPOS  DB 0
GAYPOS  DB 0
GBXPOS  DB 0
GBYPOS  DB 0
STICKCYCLE DB 0

TIMER:  INC STICKCYCLE
        AND STICKCYCLE,3
        CALL REVISE
        CMP BYTE PTR LJOYSTK,2
        JZ LREAD
        CMP BYTE PTR RJOYSTK,2
        JZ LREAD
        OR STICKCYCLE,2
        JMP NO_LREAD
LREAD:  PUSH CX
        PUSH DX
        CMP STICKCYCLE,0
        JNZ LREAD3
        MOV AH,1
        CALL JOYREAD
        SUB CX,LCALIB
        JNB LREAD1
        MOV CX,0
LREAD1: MOV AX,CX
        MOV DX,0
        DIV LCALIB[4]
        MOV GAXPOS,AL
LREAD3: CMP STICKCYCLE,1        
        JNZ LREAD4
        MOV AH,2
        CALL JOYREAD
        SUB CX,LCALIB[2]
        JNB LREAD2
        MOV CX,0
LREAD2: MOV AX,CX
        MOV DX,0
        DIV LCALIB[6]
        MOV GAYPOS,AL
LREAD4: MOV DX,201H
        IN AL,DX
        NOT AL
        AND AL,30H
        MOV AL,2
        JZ NO_AFIRE
        MOV AL,0
NO_AFIRE:
        CMP LJOYSTK,2
        JNZ NO_LFIRE1
        AND FIRE,253
        OR FIRE,AL
NO_LFIRE1:
        ROR AL,1
        CMP RJOYSTK,2
        JNZ NO_RFIRE1
        AND FIRE,254
        OR FIRE,AL
NO_RFIRE1:
        POP DX
        POP CX
NO_LREAD:
        CMP BYTE PTR LJOYSTK,4
        JZ RREAD
        CMP BYTE PTR RJOYSTK,4
        JZ RREAD
        CMP STICKCYCLE,0
        JZ NO_RREAD
        MOV STICKCYCLE,3
        JMP NO_RREAD
RREAD:  PUSH CX
        PUSH DX
        CMP STICKCYCLE,2
        JNZ RREAD3
        MOV AH,4
        CALL JOYREAD
        SUB CX,RCALIB
        JNB RREAD1
        MOV CX,0
RREAD1: MOV AX,CX
        MOV DX,0
        DIV RCALIB[4]
        MOV GBXPOS,AL
RREAD3: CMP STICKCYCLE,3
        JNZ RREAD4
        MOV AH,8
        CALL JOYREAD
        SUB CX,RCALIB[2]
        JNB RREAD2
        MOV CX,0
RREAD2: MOV AX,CX
        MOV DX,0
        DIV RCALIB[6]
        MOV GBYPOS,AL
RREAD4: MOV DX,201H
        IN AL,DX
        NOT AL
        AND AL,0C0H
        MOV AL,2
        JZ NO_BFIRE
        MOV AL,0
NO_BFIRE:
        CMP LJOYSTK,4
        JNZ NO_LFIRE2
        AND FIRE,253
        OR FIRE,AL
NO_LFIRE2:
        ROR AL,1
        CMP RJOYSTK,4
        JNZ NO_RFIRE2
        AND FIRE,254
        OR FIRE,AL
NO_RFIRE2:
        POP DX
        POP CX
NO_RREAD:
        CMP COUNTDOWN,0        
        JZ TIMER3
        DEC COUNTDOWN
        JNZ TIMER3
        MOV BX,HANDLE
        MOV AH,3EH
        INT 21H
        MOV HANDLE,-1
TIMER3: CALL RESETBRANCH
        JMP MAIN

;Summon debugger if an invalid instruction was executed

INVALID_ABORT:
        MOV DBGMSG,OFFSET MSG19
        JMP DEBUG

BAD     PROC NEAR
;        MOV AL,OFFSET BRANCH4-OFFSET BRANCH1
;        MOV BYTE PTR BRANCH,AL
;        MOV BYTE PTR CS:INST,0C3H
        JMP INST
BAD     ENDP

;Keyboard handler

EXTENDED_KEY DB 0               ;Non-zero if processing extended keyboard key

        db 'here'
KEYBOARD:
        CMP LASTKEY,3BH         ;F1=Debug
        JNZ FUNCTION1
        MOV DBGMSG,OFFSET MSG17
        JMP DEBUG
FUNCTION1:                      ;F2=Virtual disk menu
        CMP LASTKEY,3CH
        JNZ FUNCTION2
        JMP VDISK
FUNCTION2:                      ;F3=Snapshots/Paks
        CMP LASTKEY,3DH
        JNZ FUNCTION3
        JMP SNAP
FUNCTION3:
        CMP LASTKEY,7EH
        JZ OPTION_BRANCH
        CMP LASTKEY,44H         ;F10 or CTRL-F10
        JNZ FLUSH
        PUSH ES
        MOV AX,64
        MOV ES,AX
        TEST BYTE PTR ES:[23],4
        POP ES
        JNZ FUNCTION4
        SAVEREG
        CALL SHIFT_KEYS
        KEYSTROKE
        JMP HELP
FUNCTION4:        
        MOV DI,0FFFEH           ;Load reset vector into PC
        GETWORD
        MOV SI,AX
        MOV DI,0FFDEH           ;Request SAM to switch in ROMs
        PUTBYTE
        MOV DI,0FFD4H           ;Make sure lower memory is first 32K
        PUTBYTE
FLUSH:        
        MOV AH,1
        INT 16H
        JNZ KEY1A
        JMP KEY1
OPTION_BRANCH:
        JMP OPTION0
PORT_BRANCH:
        JMP PORT
KEY1A:
        KEYSTROKE
        CMP AX,3F00H            ;F5=Sound on/off
        JZ CHANGE_SOUND
        CMP AX,4100H            ;F7=Keyboard mode
        JZ CHANGE_MODE
        CMP AX,4300H            ;F9=Port utility
        JZ PORT_BRANCH
        CMP AX,4000H            ;F6=Option menu
        JZ OPTION_BRANCH
        CMP AX,4200H            ;F8=Customize keyboard
        JZ CUSTOMIZE
        CMP AX,3E00H            ;F7=Virtual cassette menu
        JNZ NO_CALIBRATE
        JMP VIRCAS
NO_CALIBRATE:
        TEST BYTE PTR MARGIN,-1
        JZ FLUSH
        PUSH DX
        PUSH DI
        MOV DX,0
        MOV DI,OFFSET MSG23
        PUSH CX
        CALL COLUMN
        POP CX
        POP DI
        POP DX
        MOV MARGIN,0
        JMP FLUSH
CHANGE_SOUND:
        XOR BYTE PTR SOUND,1
        TEST BYTE PTR SOUND,1
        JZ CHANGE_SOUND_1
        PUSH DX
        PUSH DI
        MOV DX,0
        MOV DI,OFFSET MSG29
        PUSH CX
        CALL COLUMN
        POP CX
        POP DI
        POP DX
        JMP FLUSH
CHANGE_SOUND_1:
        PUSH DX
        PUSH DI
        MOV DX,0
        MOV DI,OFFSET MSG30
        PUSH CX
        CALL COLUMN
        POP CX
        POP DI
        POP DX
        JMP FLUSH
CHANGE_MODE:
        MOV AL,KEY_MODE
        INC AL
        CMP AL,3
        JB CHANGE_MODE_1
        MOV AL,0
CHANGE_MODE_1:
        MOV KEY_MODE,AL
        MOV AH,0
        ADD AX,AX
        PUSH DI
        MOV DI,AX
        MOV DI,KEY_MSG[DI]
        PUSH DX
        PUSH CX
        MOV DX,0
        CALL COLUMN
        POP CX
        POP DX
        POP DI
        JMP FLUSH
CUSTOMIZE:                      ;F7=Modify custom keyboard layout
        SAVEREG
        PUSH DS
        PUSH ES
        DB 9AH                  ;CALL FAR CUSTOMIZER_MENU
        DW 0
        DW SEG CUST_DUMMY
        PUSH CS
        POP ES
        MOV DI,OFFSET DRA1_MATRIX;Clear the CTRL key and any others that may
        MOV CX,256              ;have stuck
        MOV AL,-1
        REP STOSB
        MOV CX,8
        MOV DI,OFFSET KEY_MATRIX
        REP STOSB
        POP ES
        POP DS
        JMP CONTINUE
KEY1:   MOV EXTENDED_KEY,0
        MOV AL,LASTKEY
        CMP AL,0E0H             ;Set flag for extended keyboard code if
        JNZ KEY1C               ;applicable
        MOV EXTENDED_KEY,1
        CALL SHIFT_KEYS
        PUSH CX
        MOV CX,0
KEY1D:  MOV AL,LASTKEY          ;Wait for the next key in case interrupt
        CMP AL,0                ;is slow
        LOOPZ KEY1D
        POP CX
KEY1C:  AND AL,127
        CMP AL,47H              ;Select numeric keypad settings if it's one
        JB KEY1B                ;of those keys
        CMP AL,4AH
        JZ KEY1B
        CMP AL,4EH
        JZ KEY1B
        CMP AL,53H
        JA KEY1E
        PUSH ES                 ;and NUM LOCK is on
        MOV BX,64
        MOV ES,BX
        TEST BYTE PTR ES:[17H],32
        POP ES
        JZ KEY1B
        TEST EXTENDED_KEY,-1    ;and it's not an extended key
        JNZ KEY1B
        ADD AL,13
        JMP KEY1B
KEY1E:  ADD AL,10
KEY1B:  MOV BX,ALT_LIST
        MOV AH,KEY_MODE
        DEC AH
        JZ KEY2
        MOV BX,CUSTOM_LIST
        DEC AH
        JZ KEY2
        MOV BX,KEY_LIST
KEY2:   MOV AH,0
        DEC AL
        ADD BX,AX
        ADD BX,AX
        INC AL
        CMP AL,63H
        JB KEY3
        CALL SHIFT_KEYS
        CALL RESETBRANCH
        JMP MAIN
KEY8A:  JMP KEY8
KEY3:   SAVEREG
        MOV DI,BX
        PUSH ES                 ;Key translation found.
        MOV AX,64
        MOV ES,AX
        MOV AL,ES:[23]          ;Restore SHIFT keys to proper values
        MOV AH,AL               ;(LEFT and RIGHT are interchanged)
        SHR AH,1
        AND AX,101H
        OR AH,AL
        NOT AH
        ROR AH,1
        ROR AH,1
        AND BYTE PTR KEY_MATRIX[7],191
        OR KEY_MATRIX[7],AH
        TEST BYTE PTR LASTKEY,128;If key is released, go to release algorithm
        JNZ KEY6A
        MOV BX,0                ;Key pressed
        TEST BYTE PTR ES:[23],3 ;Select secondary definition if shift pressed
        JZ KEY4
        INC BX
KEY4:   MOV AL,SS:[DI+BX]       ;Get key binding definition
        TEST AL,8               ;Bit 3=key undefined
        JNZ KEY8A
        TEST AL,128             ;Highest bit indicates toggle SHIFT key
        JZ KEY6
        AND BYTE PTR KEY_MATRIX[7],191
        TEST BYTE PTR ES:[23],3
        JZ KEY6
        OR BYTE PTR KEY_MATRIX[7],64
KEY6:   MOV BL,AL
        AND BL,7                ;Lower three bits are address line
        MOV CL,4
        SHR AL,CL
        MOV CL,AL               ;Bits 4-6 are bit position
        AND CL,7
        CMP BYTE PTR DRAGON,0   ;If Dragon keyboard selected, exchange alpha
        JZ KEY6C                ;and numeric
        PUSH BX
        MOV BL,CL
        MOV CL,DRAG_XLAT[BX]
        POP BX
KEY6C:  MOV AL,0FEH
        ROL AL,CL
        AND KEY_MATRIX[BX],AL   ;If pressed, make bit high
        JMP KEY7
KEY6A:  MOV SI,0                ;Loop for primary and secondary definitions
KEY6B:  MOV BX,SI
        MOV AL,SS:[DI+BX]  
        MOV BL,AL
        AND BL,7
        MOV CL,4
        SHR AL,CL
        MOV CL,AL
        AND CL,7
        CMP BYTE PTR DRAGON,0   ;If Dragon keyboard selected, exchange alpha
        JZ KEY6D                ;and numeric
        PUSH BX
        MOV BL,CL
        MOV CL,DRAG_XLAT[BX]
        POP BX
KEY6D:  MOV AL,1
        ROL AL,CL
        OR KEY_MATRIX[BX],AL    ;Key released.  Make bit low.
        INC SI
        CMP SI,2
        JB KEY6B
KEY7:   MOV DI,0                ;Recalculate DRA1 matrix
KEY7B:  MOV BX,0
        MOV AX,0FF01H
KEY7C:  TEST DI,AX
        JNZ KEY7D
        AND AH,KEY_MATRIX[BX]
KEY7D:  INC BL
        ROL AL,1
        JNB KEY7C
        MOV DRA1_MATRIX[DI],AH
        INC DI
        CMP DI,256
        JB KEY7B
KEY8:   POP ES
        CALL SHIFT_KEYS
        CALL RESETBRANCH
        LOADREG
        JMP MAIN

;Virtual disk menu controller

VDISK:  MOV AH,1
        INT 16H
        JZ VDISK1
        KEYSTROKE
        JMP VDISK
VDISK1: SAVEREG
        MOV AH,3EH
        MOV BX,HANDLE
        INT 21H
        MOV HANDLE,-1
        CALL FREEZE
        MOV SI,OFFSET VIR_DIR
        CALL RESTORE_DIR
        MOV DI,OFFSET MSG24
        MOV DX,0
        MOV BX,8E2BH
        CALL MENU
        MOV DI,OFFSET MSG25
        MOV DX,63
        MOV BX,1911H
        CALL MENU
        MOV DH,9
VDISK1A:                        ;Show write protect status
        ROR WR_PROT,1
        JNB VDISK1B
        PUSH BX
        MOV BX,18BH             ;Display inverse bar
        MOV DL,3
        MOV CX,1
        MOV AL,' '
        MOV DL,3
        CALL PC_CHAR
        INC DL
        MOV AL,DH
        ADD AL,39
        CALL PC_CHAR
        INC DL
        MOV AL,' '
        CALL PC_CHAR
        POP BX
VDISK1B:
        INC DH
        CMP DH,13
        JB VDISK1A
        MOV CL,4
        ROR WR_PROT,CL
REDISPLAY:
        MOV SI,OFFSET PATHS     ;Display current path names
        MOV DH,9
VDISK2: MOV DL,9
        MOV BX,0
VDISK3: MOV AL,[SI+BX]
        PUSH BX
        MOV BX,10BH
        MOV CX,1
        CALL PC_CHAR
        POP BX
        INC DL
        INC BX
        CMP BX,32
        JB VDISK3
VDISK4: INC DH
        ADD SI,32
        CMP DH,13        
        JB VDISK2
        CALL THAW
        MOV DX,OFFSET DSKSEARCH
        CALL DIR
VDISK5:        
        MOV AX,1                ;Enable mouse pointer
        INT 33H
VDISK5A: 
        MOV AH,1                ;Main keyboard/mouse read loop
        INT 16H
        JZ VDISK7B
        MOV AX,2
        INT 33H
        JMP VDISK7
VDISK7B:
        TEST BYTE PTR MOUSE_HERE,-1
        JZ VDISK5A
        MOV AX,3
        INT 33H
        TEST BL,1
        JZ VDISK5A
        SHR DX,1                ;Work out text coordinate of mouse
        SHR DX,1
        SHR DX,1
        SHR CX,1
        SHR CX,1
        SHR CX,1
        MOV DH,DL
        MOV DL,CL
        PUSH DX
VDISK5B:        
        MOV AX,3
        INT 33H
        TEST BL,1
        JNZ VDISK5B
        MOV AX,2
        INT 33H
        POP DX
        CMP DL,63               ;Mouse scan (directory zone)
        JNA VDISK5C
        CALL DIR_WDW
        JMP VDISK5
VDISK5C:
        JZ VDISK5
        CMP DL,42               ;If outside windows, cancel
        JA VDISK6
        JZ VDISK5
        CMP DH,13
        JA VDISK6
        JZ VDISK5               ;Dead space part of window
        CMP DH,9
        JB VDISK5
        CMP DL,2
        JB VDISK5
        CMP DL,7                ;Write protect zone
        JNB VDISK8D
        JMP VDISK8
VDISK8D:
        CMP DL,9                ;Dead space
        JB VDISK5
        JMP VNAME               ;Drive name select
VDISK6: MOV LASTKEY,0
        MOV SI,OFFSET VIR_DIR   ;Save current path
        CALL SAVE_PATH
        MOV SI,OFFSET CUR_PATH  ;Restore power-up path
        CALL RESTORE_DIR
        CALL SHOW               ;Straighten up screens+branch, and re-enter
        LOADREG
        CALL RESETBRANCH
        JMP MAIN
VDISK7: KEYSTROKE               ;Keyboard read routine
        CMP AL,13               ;Change directory
        JNZ VDISK7A
        CALL CHANGE_DIR
        JMP VDISK5
VDISK7A:
        CMP AL,27               ;Escape
        JZ VDISK6               
        MOV DX,904H     
        CMP AL,')'              ;Write protect
        JZ VDISK8
        INC DH
        CMP AL,'!'
        JZ VDISK8
        INC DH
        CMP AL,'@'
        JZ VDISK8
        INC DH
        CMP AL,'#'
        JZ VDISK8        
        MOV DH,AL               ;Select drive
        SUB DH,'0'
        MOV DL,DH
        ADD DH,9
        CMP DL,4
        JB VNAME
        CALL DIR_CMD            ;Directory keys
        JMP VDISK5
VDISK8: MOV CL,DH
        SUB CL,9
        MOV AH,1
        SHL AH,CL
        XOR WR_PROT,AH
        MOV BX,10BH
        TEST WR_PROT,AH
        JZ VDISK9
        OR BL,128
VDISK9: MOV DL,3
        MOV AL,' '
        MOV CX,1
        CALL PC_CHAR
        INC DL
        MOV AL,DH
        ADD AL,39
        CALL PC_CHAR
        INC DL
        MOV AL,' '
        CALL PC_CHAR
        JMP VDISK5

;Specify new disk name

VNAME:  MOV DI,OFFSET FILE_BFR
        MOV CX,32
        PUSH DX
        CALL SET_NAME           ;Include current path, etc. in name
        POP DX
        MOV DL,9
        CALL GET_FILE
        JB VNAME1
        MOV BX,5344H            ;The extension, "DSK"
        MOV CH,4BH
        MOV DI,OFFSET PATHS
        MOV AL,DH
        SUB AL,9
        MUL BYTE PTR THIRTYTWO
        ADD DI,AX               ;DI=32 byte storage area
        SUB CURSOR,9
        CALL NEW_FILE
        MOV AL,[DI]             ;Ignore blank names
        AND AL,0DFH
        JZ VNAME1
        MOV AX,[DI+1]           ;or ones which are drive designations
        AND AH,0DFH
        CMP AX,3AH
        JZ VNAME1
        PUSH DI
        MOV SI,OFFSET VIR_DIR   ;Save current path and
        CALL SAVE_PATH
        MOV SI,OFFSET CUR_PATH
        CALL RESTORE_DIR        ;go to default dir. to get things right
        POP DI
        MOV DX,DI               ;Check to see if file exists
        MOV AX,3D00H
        INT 21H
        JB VNAME2
        MOV BX,AX
        MOV AH,3EH
        INT 21H
        MOV SI,OFFSET VIR_DIR   ;Restore current dir. path
        CALL RESTORE_DIR
VNAME1: JMP REDISPLAY        
VNAME2: PUSH DI                 ;File does not exist:  User must confirm
        CALL FREEZE             ;file create
        MOV SI,DI
        MOV CX,32
        MOV DI,OFFSET MSG26A    ;Include diskname in message
        PUSH ES
        MOV AX,DS
        MOV ES,AX
        REP MOVSB
        POP ES
        MOV DX,716H
        MOV BX,8A23H
        MOV DI,OFFSET MSG26
        MOV MENU_BACK,4         ;Make this window red/yellow
        CALL MENU
        MOV MENU_BACK,1         ;Restore normal blue/cyan
        MOV AX,4                ;Set mouse cursor position
        MOV DX,112
        MOV CX,216
        INT 33H
        CALL THAW
VNAME3: MOV AX,1                ;Enable mousy pointy thingy
        INT 33H
VNAME3A:                        ;Wait for user response
        MOV AH,1
        INT 16H
        JNZ VNAME5
        CMP MOUSE_HERE,0
        JZ VNAME3A
        MOV AX,3
        INT 33H
        TEST BL,1
        JZ VNAME3A
        SHR DX,1                ;Mouse button pressed.  Get coordinates.
        SHR DX,1
        SHR DX,1
        SHR CX,1
        SHR CX,1
        SHR CX,1
        MOV DH,DL
        MOV DL,CL
VNAME4: PUSH DX                 ;Wait for button to be released
        MOV AX,3
        INT 33H
        POP DX
        TEST BL,1
        JNZ VNAME4
        MOV AX,2                ;Bye-bye mousy pointy thingy
        INT 33H
        CMP DH,15               ;Dead space of mouse
        JA VNAME3
        CMP DH,13
        JB VNAME3
        CMP DL,23
        JB VNAME3
        CMP DL,31               ;"Yes" zone
        JB VNAME6
        CMP DL,56
        JA VNAME3
        CMP DL,48               ;"No" zone
        JA VNAME8
        JMP VNAME3
VNAME5: MOV AX,2                ;Keyboard intercept.  Kill mouse pointer.
        INT 33H
        KEYSTROKE
        AND AL,223
        CMP AL,'Y'
        JZ VNAME6
        CMP AL,'N'
        JZ VNAME8
        JMP VNAME3
VNAME6: POP DX                  ;"Yes" handler.  Create file.
        PUSH DX
        MOV AH,3CH
        MOV CX,0
        INT 21H
        JB VNAME7
        MOV BX,AX               ;Create directory structure
        MOV DX,3300h
        MOV CX,1                ;Skip to "track 17, sector 2"
        MOV AX,4200H
        INT 21H
        MOV DI,OFFSET DTA
        PUSH ES
        MOV AX,DS
        MOV ES,AX
        MOV AL,-1
        MOV CX,256
        REP STOSB
;        MOV CX,188
;        INC AL
;        REP STOSB
        MOV AH,40H
        MOV CX,256
        MOV DX,OFFSET DTA
        INT 21H
        MOV DI,OFFSET DTA       ;Create directory entry sectors (sectors 3-18)
        MOV AL,-1
        MOV CX,256
        REP STOSB
        POP ES
        MOV CX,16
VNAME6A:
        PUSH CX
        MOV AH,40H
        MOV CX,256
        MOV DX,OFFSET DTA
        INT 21H
        POP CX
        JB VNAME7
        LOOP VNAME6A
        MOV AH,3EH
        INT 21H
        JNB VNAME9
VNAME7: MOV AH,3EH              ;Error abort.  Ensure file closed
        INT 21H
        MOV AH,2                ;Beep
        MOV DL,7
        INT 21H
VNAME8: POP DI                  ;"No" handler
        PUSH ES                 ;Clear diskname field
        MOV AX,DS
        MOV ES,AX
        MOV AL,32
        MOV CX,32
        REP STOSB
        POP ES
        PUSH DI
VNAME9: POP DI                  ;General return from warning window
        CALL SHOW               ;Reset windows
        LOADREG
        JMP VDISK

NEW_FILE PROC NEAR              ;Copy file name from buffer to DI
        MOV SI,OFFSET FILE_BFR
        PUSH ES
        MOV AX,DS
        MOV ES,AX
        PUSH CX
        MOV CX,32
        REP MOVSB
        POP CX
        POP ES
        SUB DI,32
        MOV CL,0
        MOV AL,FILE_BFR         ;Don't add extensions to null file names
        AND AL,0DFH
        JZ NEW_FILE0
        MOV AX,WORD PTR FILE_BFR[1]
        AND AH,0DFH             ;or ones which are drive designations
        CMP AX,3AH
        MOV AH,-1
        JNZ NEW_FILE1
NEW_FILE0:
        RET
NEW_FILE1:                      ;Check to see if extension already there
        CMP BYTE PTR [DI],'\'
        JNZ NEW_FILE2
        MOV AH,-1
NEW_FILE2:
        CMP BYTE PTR [DI],'.'
        JNZ NEW_FILE3
        MOV AH,CL
NEW_FILE3:
        INC DI
        INC CL
        CMP CL,31
        JB NEW_FILE1
        SUB DI,31
        INC AH
        JZ NEW_FILE4
        DEC AH
        MOV CURSOR,AH
NEW_FILE4:
        PUSH DI
        ADD DI,31
        MOV AL,CURSOR
        CMP AL,27
        JA NEW_FILE5
        POP DI
        PUSH DI
        MOV AH,0                ;Add extension if there is room
        ADD DI,AX
        MOV BYTE PTR [DI],'.'
        MOV [DI+1],BX
        MOV [DI+3],CH
        ADD DI,4
NEW_FILE5:                      ;Add terminator byte
        MOV BYTE PTR [DI],0
        POP DI
        RET
NEW_FILE ENDP

DIR_CMD PROC NEAR               ;Directory window keyboard handler
        CMP AX,4900H
        JNZ DIR_CMD1
        JMP DIR_UP
DIR_CMD1:
        CMP AX,5100H
        JNZ DIR_CMD2
        JMP DIR_DOWN
DIR_CMD2:
        CMP AX,5000H
        JNZ DIR_CMD4
        CMP DIR_PTR,-1
        JZ DIR_CMD2A
        CALL HILITE
        MOV AL,14
        MUL DIR_PTR
        MOV SI,AX
        MOV AX,294
        MUL DIR_PAGE
        ADD SI,AX
        CMP BYTE PTR SS:CUR_DIR[SI+14],' '
        JZ DIR_CMD3
        INC DIR_PTR
        MOV AL,DIR_PTR
        CMP AL,21
        JB DIR_CMD3
        CALL DIR_DOWN
DIR_CMD2A:        
        MOV DIR_PTR,0
DIR_CMD3:
        CALL HILITE
        RET
DIR_CMD4:
        CMP AX,4800H
        JNZ DIR_CMD5
        CMP DIR_PTR,-1
        JZ DIR_CMD2A
        CALL HILITE
        SUB DIR_PTR,1
        JNS DIR_CMD3
        INC DIR_PTR
        CMP DIR_PAGE,0
        JZ DIR_CMD3
        CALL DIR_UP
        MOV DIR_PTR,20
        CALL HILITE
        RET
DIR_CMD5:
        RET
DIR_CMD ENDP

DIR_WDW PROC NEAR               ;Directory window mouse handler
        CALL HILITE             ;Dehighlight last selected file
        MOV DIR_PTR,-1          ;Clear directory file pointer
        CMP DH,0                ;Dead space of directory window
        JZ DIR_WDW1
        CMP DH,2
        JZ DIR_WDW1
        CMP DH,24
        JZ DIR_WDW1
        CMP DH,1                ;File name zone
        JNZ DIR_WDW4
        CMP DL,79
        JZ DIR_WDW1
        CMP DL,66               ;Up arrow
        JNA DIR_WDW2
        CMP DL,76               ;Down arrow
        JNB DIR_WDW3
DIR_WDW1:
        RET
DIR_WDW2:
        CALL DIR_UP
        RET
DIR_WDW3:
        CALL DIR_DOWN
        RET
DIR_WDW4:
        SUB DH,3
        MOV DIR_PTR,DH
        CALL HILITE
        CALL CHANGE_DIR
        RET
DIR_WDW ENDP

DIR_PTR DB -1                   ;Line of file pointer within dir window

CHANGE_DIR PROC NEAR            ;Change to directory highlighted        
        MOV DH,DIR_PTR
        INC DH
        JNZ CHANGE_DIR0
        RET
CHANGE_DIR0:
        DEC DH
        MOV AL,14
        MUL DH
        MOV SI,AX
        MOV AX,294
        MUL DIR_PAGE
        ADD SI,AX
        ADD SI,CUR_DIR
        MOV DX,SI
        INC DX
        CMP BYTE PTR SS:[SI],'['
        JZ CHANGE_DIR1
        RET
CHANGE_DIR1:
        CMP BYTE PTR SS:[SI+2],':'
        JZ CHANGE_DIR2
        INC SI
        CMP BYTE PTR SS:[SI],']'
        JNZ CHANGE_DIR1
        MOV NEW_DIR,-1
        MOV DIR_PTR,-1
        PUSH DS
        MOV AX,SS
        MOV DS,AX
        MOV BYTE PTR [SI],0
        MOV AH,3BH
        INT 21H
        MOV BYTE PTR [SI],']'
        POP DS
        MOV DIR_PAGE,0
        MOV DX,LAST_DIR
        CALL DIR
        RET
CHANGE_DIR2:
        MOV NEW_DIR,-1
        MOV DIR_PTR,-1
        MOV DL,SS:[SI+1]
        SUB DL,'A'
        CMP DL,2
        JNB HARD_DRIVE
        MOV AX,201H             ;Verify that sector is readable by MS-DOS
        MOV DH,0                ;before allowing this disk to become the
        MOV CX,1                ;default directory
        MOV BX,OFFSET DTA
        INT 13H
        JB NOT_MSDOS
HARD_DRIVE:
        MOV AH,0EH
        INT 21H
NOT_MSDOS:
        MOV DIR_PAGE,0
        MOV DX,LAST_DIR
        CALL DIR
        RET
CHANGE_DIR ENDP

RESTORE_DIR PROC NEAR           ;Restore path to that at SI
        PUSH DX
        MOV AH,0EH
        MOV DL,[SI]
        INT 21H
        MOV DX,SI
        INC DX
        MOV AH,3BH
        INT 21H
        POP DX
        RET
RESTORE_DIR ENDP

SAVE_PATH PROC NEAR             ;Save path to SI
        PUSH DX
        MOV AH,19H              ;Save default drive
        INT 21H
        MOV [SI],AL
        MOV AH,0EH              ;Save total number of drives
        MOV DL,AL
        INT 21H
        MOV TOTAL_DRIVES,AL
        MOV BYTE PTR [SI+1],'\' ;Leading "\" for path
        ADD SI,2
        PUSH DI         
        INC DL
        MOV AH,47H              ;Retrieve path
        INT 21H
        POP DI
        SUB SI,2
        POP DX
        RET
SAVE_PATH ENDP

NEW_DIR DB 0                    ;Non-zero if dir changed since last reset
LAST_DIR DW 0                   ;Offset to last directory search's mask

HILITE:                         ;Toggle highlight from file DIR_PTR
        INC DIR_PTR
        JNZ HILITE1
        DEC DIR_PTR
        RET
HILITE1:
        MOV NEW_HILITE,-1
        DEC DIR_PTR
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        MOV DH,DIR_PTR
        ADD DH,3
        MOV AH,2
        MOV DL,64
        MOV BH,VID_PAG
        INT 10H
        MOV AX,9DBH
        MOV CX,15
        MOV BL,86H
        INT 10H
        POP DX
        POP CX
        POP BX
        POP AX
        RET

NEW_HILITE DB 0                 ;Indicates hilight changed since last reset

DIR_UP  PROC NEAR               ;Scroll directory page back one
        CMP DIR_PAGE,0
        JZ DIR_UP1
        DEC DIR_PAGE
        CALL SHOWDIR
DIR_UP1:
        RET
DIR_UP  ENDP

DIR_DOWN PROC NEAR              ;Scroll directory page down one
        MOV AX,294
        MUL DIR_PAGE
        ADD AX,CUR_DIR+294
        MOV SI,AX
        CMP BYTE PTR SS:[SI],0
        JZ DIR_DOWN1
        CMP BYTE PTR SS:[SI],32
        JZ DIR_DOWN1
        MOV AX,DIR_PAGE
        CMP AL,22
        JNB DIR_DOWN1
        INC DIR_PAGE
        CALL SHOWDIR
DIR_DOWN1:
        RET
DIR_DOWN ENDP

;File name input routine.  Display FILE_BFR 31-byte field (plus terminator)
;at cursor location DX.  Returns upon ENTER/LEFT button second click (NC)
;or ESC/RIGHT button first click (C)

CURSOR  DB 0                    ;Current column position of cursor

GET_FILE PROC NEAR
        CMP DIR_PTR,-1
        JZ GETF1
        PUSH DX
        CALL SET_NAME           ;If file highlighted, take as default
        POP DX
GETF1:  PUSH DX
        MOV SI,OFFSET FILE_BFR
        MOV CURSOR,DL
GETF2:  MOV AL,[SI]             ;Display name
        MOV BX,10EH
        MOV CX,1
        CALL PC_CHAR
        INC SI
        INC DL
        MOV AL,[SI-1]
        CMP AL,' '
        JZ GETF3
        CMP AL,0
        JZ GETF3
        MOV CURSOR,DL
GETF3:  CMP SI,OFFSET FILE_BFR+31
        JB GETF2
        MOV DL,CURSOR           ;Display cursor
        MOV Al,0DBH
        MOV BX,10BH
        CALL PC_CHAR
        POP DX
GETF3A: MOV AX,1
        INT 33H
GETF4:  MOV AH,1
        INT 16H
        JZ GETF8A
        MOV AX,2
        INT 33H
        JMP GETF8
GETF8A: TEST BYTE PTR MOUSE_HERE,-1
        JZ GETF4
        PUSH DX
        MOV AX,3
        INT 33H
        SHR DX,1
        SHR DX,1
        SHR DX,1
        SHR CX,1
        SHR CX,1
        SHR CX,1
        MOV CH,DL
        POP DX
        TEST BL,3
        JZ GETF4
        TEST BL,2
        JZ GETF5
        MOV AX,2                ;Right button aborts.  Turn off mouse pointer
        INT 33H         
        MOV DL,CURSOR           ;and cursor
        MOV AL,' '
        MOV BX,10BH
        MOV CX,1
        CALL PC_CHAR
        STC                     ;and set abort flag
        RET
GETF5:  MOV AX,3                ;Wait for button to be released
        PUSH CX
        PUSH DX
        INT 33H
        POP DX
        POP CX
        TEST BL,1
        JNZ GETF5
        MOV AX,2
        INT 33H
        CMP CL,63
        JZ GETF3A
        JB GETF6
        PUSH DIR_PAGE
        PUSH WORD PTR DIR_PTR
        PUSH DX
        MOV NEW_DIR,0
        MOV NEW_HILITE,0
        MOV DX,CX
        CALL DIR_WDW            ;If mouse if directory window, handle it
        POP DX
        POP AX
        POP BX
        CMP NEW_HILITE,0
        JZ GETF5D
        CMP NEW_DIR,-1          ;If directory changed, set name appropriately
        JZ GETF5B
        CMP AL,DIR_PTR          ;If same highlight clicked a second time,
        JNZ GETF5B
        CMP AL,-1
        JZ GETF5B
        CMP BX,DIR_PAGE
        JNZ GETF5B
GETF5C: MOV DL,CURSOR           ;Turn off cursor
        MOV AL,' '
        MOV BX,10BH
        MOV CX,1
        CALL PC_CHAR
        CLC                     ;flag as "accept".
        RET
GETF5D: JMP GETF3A
GETF5B: PUSH DX
        CALL SET_NAME           ;If highlight changed, load new hilighted
        POP DX
        JMP GETF1               ;file into buffer.
GETF6:  CMP CH,DH               ;If clicked on other than current drive
        JZ GETF7                ;field, return ESCape flag
GETF6A: MOV DL,CURSOR
        MOV AL,' '
        MOV BX,10BH
        MOV CX,1
        CALL PC_CHAR
        STC
        RET
GETF7:  SUB CL,DL
        JB GETF6A
        CMP CL,32
        JA GETF6A
        JMP GETF5C              ;Otherwise return ENTER.
GETF8:  KEYSTROKE               ;Keyboard read routine
        CMP AL,13
        JNZ GETF9
        MOV NEW_DIR,0           ;ENTER: If directory highlighted, change it
        PUSH DX
        CALL CHANGE_DIR
        POP DX
        CMP NEW_DIR,0
        JNZ GETF8C
        JMP GETF5C              ;else return file name with NC
GETF8C: PUSH DX
        CALL SET_NAME
        POP DX
        JMP GETF1
GETF8B: JMP GETF3A
GETF9:  CMP AL,27               ;ESC: If buffer not empty, clear it
        JNZ GETF9A
        CMP FILE_BFR,32         ;else return with C set
        JZ GETF6A
        CMP FILE_BFR,0
        JZ GETF6A
        PUSH ES
        MOV AX,DS
        MOV ES,AX
        MOV DI,OFFSET FILE_BFR
        MOV AL,32
        MOV CX,32
        REP STOSB
        POP ES
        MOV CURSOR,DL
        JMP GETF1
GETF9A: CMP AL,8                ;Backspace
        JNZ GETF10
        CMP CURSOR,DL
        JNA GETF8B
        DEC CURSOR
        MOV AL,CURSOR
        MOV AH,0
        SUB AL,DL
        MOV SI,AX
        MOV FILE_BFR[SI],32
        PUSH DX
        MOV DL,CURSOR
        MOV AL,0DBH
        MOV BX,10BH
        MOV CX,1
        CALL PC_CHAR
        INC DL
        MOV AL,' '
        CALL PC_CHAR
        POP DX
        JMP GETF8B
GETF10: CMP AL,32               ;ASCII character input (spaces suppressed)
        JNA GETF11
        MOV AH,CURSOR
        SUB AH,DL
        CMP AH,31
        JNB GETF8B
        PUSH AX
        MOV AL,CURSOR
        MOV AH,0
        SUB AL,DL
        MOV SI,AX
        POP AX
        MOV FILE_BFR[SI],AL
        PUSH DX
        MOV DL,CURSOR
        MOV BX,10EH
        MOV CX,1
        MOV AL,FILE_BFR[SI]
        CALL PC_CHAR
        INC DL
        MOV AL,0DBH
        MOV BX,10BH
        CALL PC_CHAR
        POP DX
        INC CURSOR
        JMP GETF8B
GETF11: MOV NEW_HILITE,0        ;Check for directory commands
        PUSH DX
        CALL DIR_CMD
        POP DX
        CMP NEW_HILITE,0        ;If highlight changed, retrieve that file name
        JNZ GETF12
        JMP GETF8B
GETF12: PUSH DX
        CALL SET_NAME
        POP DX
        JMP GETF1
GET_FILE ENDP

SET_NAME PROC NEAR              ;Set FILE_BFR to current hilighted path
        MOV DI,OFFSET FILE_BFR
        MOV CX,32
        PUSH ES
        MOV AX,DS
        MOV ES,AX
        MOV AL,32
        REP STOSB
        POP ES
        MOV SI,OFFSET FILE_BFR
        MOV AH,19H
        INT 21H
        PUSH DX
        MOV DL,AL
        INC DL
        CMP AL,CUR_PATH
        JZ SET_NAME1
        ADD AL,'A'
        MOV [SI],AL
        MOV BYTE PTR [SI+1],':'
        ADD SI,2
SET_NAME1:
        MOV AH,47H
        PUSH SI
        MOV SI,OFFSET DTA
        INT 21H
        POP SI
        POP DX
        MOV DI,0
SET_NAME2:
        MOV AL,DTA[DI]
        CMP AL,CUR_PATH[DI+2]
        JNZ SET_NAME3
        INC DI
        CMP AL,0
        JNZ SET_NAME2
        JMP SET_NAME5
SET_NAME3:        
        MOV BYTE PTR [SI],'\'
        INC SI
        MOV DI,OFFSET DTA
SET_NAME4:
        MOV AL,[DI]
        CMP AL,0
        JZ SET_NAME4A
        MOV [SI],AL
        INC DI
        INC SI
        CMP SI,OFFSET FILE_BFR+30
        JB SET_NAME4
        RET
SET_NAME4A:
        CMP BYTE PTR [SI-1],'\'
        JZ SET_NAME5
        MOV BYTE PTR [SI],'\'
        INC SI
SET_NAME5:
        CMP DIR_PTR,-1
        JNZ SET_NAME6
        RET
SET_NAME6:
        MOV AL,14
        MUL DIR_PTR
        MOV DI,AX
        MOV AX,294
        MUL DIR_PAGE
        ADD DI,AX
        CMP BYTE PTR SS:CUR_DIR[DI+2],':'
        JZ SET_NAME8
        CMP BYTE PTR SS:CUR_DIR[DI],'['
        MOV BX,0
        JZ SET_NAME9
SET_NAME7:
        MOV AL,SS:CUR_DIR[DI+BX]
        MOV [SI],AL
        INC SI
        INC BX
        CMP SI,OFFSET FILE_BFR+31
        JNB SET_NAME8
        CMP BX,14
        JB SET_NAME7
SET_NAME8:
        RET
SET_NAME9:
        MOV AL,SS:CUR_DIR[DI+BX+1]
        CMP AL,']'
        JZ SET_NAME10
        MOV [SI],AL
        INC SI
        INC BX
        CMP SI,OFFSET FILE_BFR+31
        JNB SET_NAME8
        CMP BX,13
        JB SET_NAME9
SET_NAME10:
        CMP SI,OFFSET FILE_BFR+31
        JZ SET_NAME8
        MOV BYTE PTR [SI],'\'
        RET
SET_NAME ENDP

;Virtual cassette menu controller

CLOSE_CASSETTE PROC NEAR
        CMP CHANDLE,-1
        JZ CLOSE_CAS1
        MOV AH,3EH
        MOV BX,CHANDLE
        INT 21H
        MOV CHANDLE,-1
CLOSE_CAS1:
        MOV BYTE PTR CAS_BIT,0
        MOV BYTE PTR CAS_CYCLE,0
        RET
CLOSE_CASSETTE ENDP

OPEN_CASSETTE PROC NEAR
        CMP CHANDLE,-1
        JNZ OPEN_CAS1
        MOV SI,OFFSET CUR_PATH
        CALL RESTORE_DIR
        MOV AX,3D02H
        MOV DX,OFFSET CAS_NAME
        INT 21H
        JB OPEN_CAS1
        MOV CHANDLE,AX
OPEN_CAS1:
        MOV AX,4201H            ;Save current position
        MOV BX,CHANDLE
        MOV CX,0
        MOV DX,0
        INT 21H
        PUSH DX
        PUSH AX
        MOV AX,4202H            ;FInd end of virtual cassette
        MOV DX,CX
        INT 21H
        MOV CAS_END,AX
        POP DX
        POP CX
        MOV AX,4200H            ;Restore current position
        INT 21H
        RET
OPEN_CASSETTE ENDP

CASSETTE_POS PROC NEAR          ;Display in .CAS file
        PUSH BX
        PUSH DX
        MOV AX,0
        CMP CHANDLE,-1
        JZ VCAS4
        MOV AX,4201H            ;Figure out current offset in file
        MOV BX,CHANDLE
        MOV CX,0
        MOV DX,CX
        INT 21H
        JNB VCAS4
        POP DX
        POP BX
        RET
VCAS4:  POP DX                  ;Position of first digit
        POP BX
        MOV CX,5
        MOV CAS_PTR,AX
VCAS5:  PUSH DX
        MOV DX,0                ;Convert to decimal
        MOV SI,10
        DIV SI
        MOV SI,DX
        POP DX
        PUSH AX
        PUSH CX
        MOV AX,SI
        ADD AL,30H
        MOV CX,1
        CALL PC_CHAR
        POP CX
        POP AX
        DEC DL
        LOOP VCAS5
        RET
CASSETTE_POS ENDP

CAS_STEP DW 1                   ;Number of bytes to inc/dec for FF/Rewind
CAS_PTR DW 0                    ;Last displayed counter reading
CAS_END DW 0                    ;Position of end of virtual cassette
CAS_BIT DB 0                    ;Bit within byte currently being processed
CAS_CYCLE DB 0                  ;Number of samples within bit

VIRCAS: MOV AH,1
        INT 16H
        JZ VCAS1
        KEYSTROKE
        JMP VIRCAS
VCAS1:  SAVEREG
        MOV AH,3EH
        MOV BX,HANDLE
        INT 21H
        MOV HANDLE,-1
        CALL FREEZE
        MOV SI,OFFSET CAS_DIR
        CALL RESTORE_DIR
        MOV DI,OFFSET MSG46
        MOV DX,0
        MOV BX,8C2BH
        CALL MENU
        MOV DI,OFFSET MSG25
        MOV DX,63
        MOV BX,1911H
        CALL MENU
VCAS1A: MOV CX,1
        MOV DX,708H
        MOV SI,OFFSET MSG47A
        MOV BH,1
        TEST BYTE PTR CASMODE,-1
        JZ VCAS2
        MOV SI,OFFSET MSG47B
        MOV BH,4
VCAS2:  MOV BL,11               ;Display cassette mode
        LODSB
        CALL PC_CHAR
        INC DL
        CMP DL,16
        JB VCAS2
        MOV DX,608H
        MOV SI,OFFSET CAS_NAME
VCAS3:  LODSB                   ;Display virtual cassette name
        MOV BX,10BH
        MOV CX,1
        CALL PC_CHAR
        INC DL
        CMP SI,OFFSET CAS_NAME+32
        JB VCAS3
        CALL OPEN_CASSETTE      ;Make sure virtual cassette open
        MOV DX,327H
        MOV BX,10BH
        CALL CASSETTE_POS
        CALL THAW
        MOV DX,OFFSET CASSEARCH
        CALL DIR
VCAS6:  MOV AX,1                ;Mouse pointer on
        INT 33H
VCAS7:  MOV AH,1
        INT 16H
        JZ VCAS8
        MOV AX,2                ;Key pressed, branch to key handler
        INT 33H
        JMP VCAS13
VCAS8:  CMP MOUSE_HERE,0
        JZ VCAS7
        MOV AX,3                ;If mouse present, test it
        INT 33H
        TEST BL,1
        JZ VCAS7
        SHR CX,1
        SHR CX,1
        SHR CX,1
        SHR DX,1
        SHR DX,1
        SHR DX,1
        MOV DH,DL
        MOV DL,CL
        MOV CAS_STEP,1
        CMP DH,9                ;If on Forward or Rewind, don't bother
        JNZ VCAS9               ;waiting for release
        CMP DL,12
        JB VCAS9
        CMP DL,31
        JB VCAS9A
VCAS9:  PUSH DX                 ;Wait for release of mouse button
        MOV AX,3
        INT 33H
        POP DX
        TEST BL,1
        JNZ VCAS9
        MOV AX,2
        INT 33H
VCAS9A: CMP DL,63
        JZ VCAS6
        JB VCAS10
        CALL DIR_WDW
        JMP VCAS6
VCAS10: CMP DL,43               ;Outside window ... cancel
        JNB VCAS12
        JZ VCAS6A
        CMP DH,12
        JNB VCAS12
        CMP DL,0
        JZ VCAS6A
        CMP DH,6                ;Name line
        MOV AL,'N'
        JZ VCAS11
        CMP DH,7
        MOV AL,'M'              ;Mode line
        JZ VCAS11
        CMP DH,9
        JNZ VCAS6A
        CMP DL,2
        JB VCAS6A
        MOV AL,'S'              ;"Start" button
        CMP DL,11
        JB VCAS11
        JZ VCAS6A
        MOV AL,'R'              ;"Rewind" button
        CMP DL,21
        JB VCAS11
        JZ VCAS6A
        MOV AL,'F'              ;"Forward" button
        CMP DL,31
        JB VCAS11
        JZ VCAS6A
        MOV AL,'E'              ;"End" button
        CMP DL,41
        JB VCAS11
VCAS6A: JMP VCAS6
VCAS11: JMP VCAS14
VCAS12: MOV LASTKEY,0
        MOV SI,OFFSET CAS_DIR   ;Save last selected virtual cassette dir.
        CALL SAVE_PATH
        MOV SI,OFFSET CUR_PATH  ;Restore power-up path
        CALL RESTORE_DIR
        CALL SHOW               ;Straighten up screens+branch, and re-enter
        LOADREG
        CALL RESETBRANCH
        JMP MAIN
VCAS13: KEYSTROKE               ;Key pressed, interpret it
        CMP AL,27               ;ESC=abort
        JZ VCAS12
        CMP AL,13               ;ENTER=change directory
        JNZ VCAS14
        CALL CHANGE_DIR
        JMP VCAS6
VCAS14: CALL DIR_CMD            ;Interpret keys for dir. window
        AND AL,223
        CMP AL,'M'              ;Change mode
        JNZ VCAS16
        NOT BYTE PTR CASMODE
        JMP VCAS1A
VCAS16: MOV BX,CHANDLE          ;Cassette buttons don't work if no .CAS open
        CMP BX,-1
        JZ VCAS22
        CMP AL,'S'
        JNZ VCAS19
        MOV AX,4200H            ;Rewind to start of virtual cassette
        MOV DX,0
VCAS17: MOV CX,0        
        INT 21H
        MOV BYTE PTR CAS_BIT,0
        MOV BYTE PTR CAS_CYCLE,0
        MOV DX,327H
        MOV BX,10BH
        CALL CASSETTE_POS
        CMP CAS_STEP,64
        JNB VCAS18
        SHL CAS_STEP,1
VCAS18: JMP VCAS6
VCAS19: CMP AL,'E'              ;Go to end of virtual cassette
        JNZ VCAS20
        MOV AX,4202H
        MOV DX,0
        JMP VCAS17
VCAS20: CMP AL,'R'              ;Rewind virtual cassette
        JNZ VCAS21
        MOV DX,CAS_PTR
        SUB DX,CAS_STEP
        MOV AX,4200H
        JNB VCAS17
        MOV DX,0
        JMP VCAS17
VCAS21: CMP AL,'F'              ;Fast forward
        JNZ VCAS22
        MOV DX,CAS_PTR
        ADD DX,CAS_STEP
        CMP DX,CAS_END
        MOV AX,4200H
        JB VCAS17
        MOV DX,CAS_END
        JMP VCAS17
VCAS22: CMP AL,'N'              ;Change virtual cassette name
        JZ VCNAME
        JMP VCAS6

VCNAME: MOV AX,4                ;Set mouse cursor position to name field
        MOV CX,80
        MOV DX,52
        INT 33H
        MOV SI,OFFSET CAS_NAME  ;Currrent name is default
        MOV DI,OFFSET FILE_BFR
        MOV CX,32
        PUSH ES
        MOV AX,DS
        MOV ES,AX
        REP MOVSB
        POP ES
        MOV DX,608H
        CALL GET_FILE           ;Get file name
        JNB VCNAME1
        JMP VCAS1A
VCNAME1: 
        MOV DI,OFFSET CAS_NAME  ;Set new name plus extension
        MOV BX,4143H            ;".CAS"
        MOV CH,53H
        SUB CURSOR,8
        CALL NEW_FILE
        CALL CLOSE_CASSETTE
        MOV AL,CAS_NAME
        AND AL,223
        JZ VCAS1B
        CALL OPEN_CASSETTE
        CMP CHANDLE,-1
        JZ VCNAME2
        MOV BYTE PTR CASMODE,0  ;If existing file, default to "playback"
VCAS1B: JMP VCAS1A
VCNAME2: 
        CALL FREEZE             ;File does not exist: user must confirm
        MOV SI,OFFSET CAS_NAME
        MOV CX,32
        MOV DI,OFFSET MSG48A    ;Include diskname in message
        PUSH ES
        MOV AX,DS
        MOV ES,AX
        REP MOVSB
        POP ES
        MOV DX,716H
        MOV BX,8A23H
        MOV DI,OFFSET MSG48
        MOV MENU_BACK,4         ;Make this window red/yellow
        CALL MENU
        MOV MENU_BACK,1         ;Restore normal blue/cyan
        MOV AX,4                ;Set mouse cursor position
        MOV DX,112
        MOV CX,216
        INT 33H
        CALL THAW
VCNAME3: 
        MOV AX,1                ;Enable mousy pointy thingy
        INT 33H
VCNAME3A:                       ;Wait for user response
        MOV AH,1
        INT 16H
        JNZ VCNAME5
        CMP MOUSE_HERE,0
        JZ VCNAME3A
        MOV AX,3
        INT 33H
        TEST BL,1
        JZ VCNAME3A
        SHR DX,1                ;Mouse button pressed.  Get coordinates.
        SHR DX,1
        SHR DX,1
        SHR CX,1
        SHR CX,1
        SHR CX,1
        MOV DH,DL
        MOV DL,CL
VCNAME4: 
        PUSH DX                 ;Wait for button to be released
        MOV AX,3
        INT 33H
        POP DX
        TEST BL,1
        JNZ VCNAME4
        MOV AX,2                ;Bye-bye mousy pointy thingy
        INT 33H
        CMP DH,15               ;Dead space of mouse
        JA VCNAME3
        CMP DH,13
        JB VCNAME3
        CMP DL,23
        JB VCNAME3
        CMP DL,31               ;"Yes" zone
        JB VCNAME6
        CMP DL,56
        JA VCNAME3
        CMP DL,48               ;"No" zone
        JA VCNAME8
        JMP VCNAME3
VCNAME5: 
        MOV AX,2                ;Keyboard intercept.  Kill mouse pointer.
        INT 33H
        KEYSTROKE
        AND AL,223
        CMP AL,'Y'
        JZ VCNAME6
        CMP AL,'N'
        JZ VCNAME8
        JMP VCNAME3
VCNAME6: 
        MOV DX,OFFSET CAS_NAME  ;"Yes" handler.  Create file.
        MOV AH,3CH
        MOV CX,0
        INT 21H
        JB VCNAME7
        MOV CHANDLE,AX
        MOV BYTE PTR CASMODE,-1 ;New file must mean "record"
        JMP VCNAME9
VCNAME7: 
        MOV AH,2                ;Error: Beep
        MOV DL,7
        INT 21H
VCNAME8:                        ;"No" handler
        PUSH ES                 ;Clear diskname field
        MOV DI,OFFSET CAS_NAME
        MOV AX,DS
        MOV ES,AX
        MOV AL,0
        MOV CX,32
        REP STOSB
        POP ES
VCNAME9: 
        CALL SHOW               ;Reset windows
        LOADREG
        JMP VIRCAS

;Snapshot menu

SNAP:   MOV AH,1
        INT 16H
        JZ SNAP1
        KEYSTROKE
        JMP SNAP
SNAP1:  SAVEREG
        MOV AH,3EH              ;Close virtual disk
        MOV BX,HANDLE
        INT 21H
        MOV HANDLE,-1
        CALL CLOSE_CASSETTE
        MOV SI,OFFSET SNAP_PATH
        CALL RESTORE_DIR        ;Set snapshot path
        CALL FREEZE
        MOV DI,OFFSET MSG27
        MOV DX,0
        MOV BX,8729H
        CALL MENU
        MOV DI,OFFSET MSG25
        MOV DX,63
        MOV BX,1911H
        CALL MENU
SNAP2:  MOV SI,OFFSET SNAP_NAME
        MOV DX,508H
SNAP3:  LODSB                   ;Display snapshot name
        MOV BX,10BH
        MOV CX,1
        CALL PC_CHAR
        INC DL
        CMP SI,OFFSET SNAP_NAME+32
        JB SNAP3
        CALL THAW        
        MOV DX,OFFSET PAKSEARCH
        CALL DIR
SNAP4:  MOV AX,1                ;Back by popular demand...
        INT 33H                 ;...the mouse pointer!
SNAP5:  MOV AH,1
        INT 16H
        JZ SNAP6
        MOV AX,2
        INT 33H
        JMP SNAP11
SNAP6:  CMP MOUSE_HERE,0
        JZ SNAP5
        MOV AX,3
        INT 33H
        TEST BL,1
        JZ SNAP5
        SHR CX,1
        SHR CX,1
        SHR CX,1
        SHR DX,1
        SHR DX,1
        SHR DX,1
        MOV DH,DL
        MOV DL,CL
SNAP7:  PUSH DX                 ;I should really have written a macro for
        MOV AX,3                ;this whole *tedious* mess, shouldn't I?
        INT 33H
        POP DX
        TEST BL,1
        JNZ SNAP7
        MOV AX,2
        INT 33H
        CMP DL,63
        JZ SNAP4
        JB SNAP8
        CALL DIR_WDW
        JMP SNAP4
SNAP8:  CMP DL,41               ;Outside window ... cancel
        JNB SNAP10
        CMP DH,7
        JNB SNAP10
        CMP DH,2                ;The "LOAD" and "SAVE" line
        JNZ SNAP4
        CMP DL,15
        JB SNAP4
        CMP DL,20
        JA SNAP9
        JMP LSNAP               ;Load zone
SNAP9:  CMP DL,23
        JB SNAP4
        CMP DL,28
        JA SNAP4
        JMP SSNAP
SNAP10: MOV LASTKEY,0           ;Exit for one reason or another
        MOV SI,OFFSET SNAP_PATH ;Save current path
        CALL SAVE_PATH
        MOV SI,OFFSET CUR_PATH  ;Restore old path
        CALL RESTORE_DIR
        CALL OPEN_CASSETTE
        MOV PRELOAD_FLAG,0
        CALL RESETBRANCH
        MOV AL,DRB2
        NOT AL
        MOV OLD_DRB2,AL
        CALL REVISE
        CALL JOYTEST
        CALL SHOW
        LOADREG
        JMP MAIN
SNAP11: KEYSTROKE
        CMP AL,13
        JNZ SNAP13
        CALL CHANGE_DIR
        JMP SNAP4
SNAP13: CMP AL,27
        JZ SNAP10
        CMP AL,'L'
        JZ LSNAP
        CMP AL,'l'
        JZ LSNAP
        CMP AL,'S'
        JZ SNAP12
        CMP AL,'s'
        JZ SNAP12
        CALL DIR_CMD
        JMP SNAP4
SNAP12: JMP SSNAP

LSNAP:  MOV DX,20FH             ;Highlight "Load" and get new snapshot name
        CALL GSNAP
        JNB LSNAP1
        JMP SNAP2               ;Abort branch
LSNAP1: MOV AL,DRB1
        MOV OLD_DRB1,AL
        MOV AL,CRB1
        MOV OLD_CRB1,AL
        MOV AX,3D00H
        MOV DX,OFFSET SNAP_NAME
        INT 21H
        MOV BX,AX
        JB ESNAP1
        MOV AH,3FH
        MOV DX,OFFSET DTA
        MOV CX,4
        INT 21H
        MOV CX,WORD PTR DTA
        MOV DX,WORD PTR DTA[2]
        PUSH DS
        MOV DS,SS:RAMBANK
        CMP DX,8000H
        JB LSNAP1A
        MOV DS,SS:ROMBANK
        MOV AH,3FH
        INT 21H
        MOV AX,DS:[0BFFEH]
        XCHG AH,AL
        POP DS
        JB ESNAP1
        MOV REGPC,AX
        MOV BYTE PTR REGFI,50H
        MOV CART_FLAG,128       ;Enable cartridge interrupt flag
        MOV BYTE PTR ROM_STATUS,0       ;ROM/PAGE 0 mode
        MOV BYTE PTR PAGE_STATUS,0
        JMP LSNAP2
LSNAP1A:
        CMP CX,0
        JNZ LSNAP1B
        MOV CX,100H
        MOV AH,3FH
        INT 21H
        ADD DX,100H
        MOV CX,0FF00H
LSNAP1B:
        MOV AH,3FH
        INT 21H
        POP DS
ESNAP1: JB ESNAP
        MOV AH,3FH
        MOV CX,OFFSET SNPEND-OFFSET SNPTOP
        MOV DX,OFFSET SNPTOP
        INT 21H
        JB ESNAP
LSNAP2: MOV AH,3EH
        INT 21H
        MOV DI,WORD PTR PAGE_STATUS
        AND DI,1                ;Select mode for $0000-$7FFF
        OR DI,0FFD4H
        PUTBYTE
        MOV DI,WORD PTR ROM_STATUS
        AND DI,1                ;Select mode for $8000-$FFFF
        OR DI,0FFDEH
        PUTBYTE
        MOV AL,OLD_DRB1
        MOV DRB1,AL
        MOV AL,OLD_CRB1
        MOV CRB1,AL
        MOV AL,OLD_DRB2         ;Update VDG the thorough way
        MOV DI,0FF22H
        MOV DRB2,0
        PUTBYTE
        JMP SNAP10

ESNAP:  MOV AH,3EH              ;Error abort
        INT 21H
        MOV AH,2
        MOV DL,7
        INT 21H
        CMP PRELOAD_FLAG,0
        JNZ ESNAPA
        JMP SNAP2
ESNAPA: JMP CONTINUE1

SSNAP:  MOV DX,217H             ;Highlight "Save" and get new snapshot name
        CALL GSNAP
        JNB SSNAP1
        JMP SNAP2               ;Abort branch
SSNAP1: MOV AH,3CH              ;Create file
        MOV CX,0
        MOV DX,OFFSET SNAP_NAME
        INT 21H
        MOV BX,AX
        JB ESNAP
        MOV AH,40H
        MOV CX,4
        MOV DX,OFFSET DTA
        MOV WORD PTR DTA[2],0
        MOV WORD PTR DTA,0
        INT 21H
        PUSH DS
        MOV DS,SS:RAMBANK
        MOV AH,40H
        MOV CX,0FF00H
        MOV DX,0
        INT 21H
        MOV DX,0FF00H
        MOV CX,100H
        MOV AH,40H
        INT 21H
        POP DS
ESNAP2: JB ESNAP
        MOV AL,DRB2
        MOV OLD_DRB2,AL
        MOV AL,DRB1
        MOV OLD_DRB1,AL
        MOV AL,CRB1
        MOV OLD_CRB1,AL
        MOV AH,40H
        MOV DX,OFFSET SNPTOP
        MOV CX,OFFSET SNPEND-SNPTOP
        INT 21H
        JB ESNAP2
        MOV AH,3EH
        INT 21H
        JMP SNAP10

GSNAP   PROC NEAR               ;Get name of snapshot in buffer        
        PUSH DX                 ;Set mouse cursor to name field
        MOV AX,4
        MOV CX,192
        MOV DX,44
        INT 33H
        POP DX
        MOV AH,2                ;Highlight "Load"/"Save"
        PUSH DX
        MOV BH,VID_PAG
        INT 10H
        MOV AX,9DBH
        MOV CX,6
        MOV BL,9AH
        INT 10H
        MOV SI,OFFSET SNAP_NAME ;Currrent name is default
        MOV DI,OFFSET FILE_BFR
        MOV CX,32
        PUSH ES
        MOV AX,DS
        MOV ES,AX
        REP MOVSB
        POP ES
        MOV DX,508H
        CALL GET_FILE           ;Get file name
        POP DX
        PUSHF
        MOV AH,2                ;Clear highlight
        MOV BH,VID_PAG
        INT 10H
        MOV AX,9DBH
        MOV CX,6
        MOV BL,9AH
        INT 10H
        POPF
        JNB GSNAP1
        RET
GSNAP1: MOV DI,OFFSET SNAP_NAME ;Set new name plus extension
        MOV BX,4150H            ;".PAK"
        MOV CH,4BH
        SUB CURSOR,8
        CALL NEW_FILE
        CLC
        RET
GSNAP   ENDP

CART_INT PROC NEAR              ;Generate a cartridge interrupt if CART_FLAG
        PUSH AX                 ;detected
        TEST CART_FLAG,128
        JZ CART_INT_1
        TEST BYTE PTR REGFI,64  ;If F flag set, interrupt suppressed
        JNZ CART_INT_1
        TEST CRB2,1             ;If FIRQ CART enabled on PIA2 CRB generate
        JZ CART_INT_1           ;it
        CALL FIRQ
CART_INT_1:
        POP AX
        RET
CART_INT ENDP

SAVE_CONFIG PROC NEAR           ;Save general configurations file
        MOV SI,OFFSET CUR_PATH
        CALL RESTORE_DIR
        MOV AH,3CH
        MOV CX,0
        MOV DX,OFFSET GENERAL_CONFIG
        INT 21H
        MOV BX,AX
        MOV AH,40H
        MOV CX,OFFSET CFG2END-CFG2TOP
        MOV DX,OFFSET CFG2TOP
        INT 21H
        PUSH DS
        MOV AX,SS
        MOV DS,AX
        MOV CX,196
        MOV DX,CUSTOM_LIST
        MOV AH,40H
        INT 21H
        POP DS
        MOV AH,3EH
        INT 21H
        RET
SAVE_CONFIG ENDP

;Joystick calibration menu

CALIB_MENU DB 0

CALIB7A:
        JMP CALIB7
CALIB:  SAVEREG
        MOV AH,3EH
        MOV BX,HANDLE
        INT 21H
        MOV HANDLE,-1
CALIB0: CALL FREEZE
        CMP NO_GAME_PORT,0
        JNZ CALIB7A
        MOV DI,OFFSET MSG39A
        MOV CALIB_MENU,0
CALIB1: MOV DX,918H
        MOV BX,8720H
        CALL MENU
        CALL THAW
CALIB2: MOV AH,1
        INT 16H
        JZ CALIB3
        KEYSTROKE
        CMP AL,27
        JNZ CALIB3
        JMP OPTION14
CALIB3: MOV DX,201H
        IN AL,DX
        XOR AL,240
        TEST AL,240
        JZ CALIB2
        MOV DI,OFFSET LCALIB
        MOV AH,1
        TEST AL,0C0H
        JZ CALIB4
        MOV DI,OFFSET RCALIB
        MOV AH,4
CALIB4: CALL JOYREAD
        PUSH CX
        ROL AH,1
        CALL JOYREAD
        CMP CALIB_MENU,0
        JNZ CALIB5
        MOV [DI+2],CX
        POP AX
        MOV [DI],AX
        JMP CALIB6
CALIB5: MOV AX,CX
        SUB AX,[DI+2]
        MOV CL,6
        SHR AX,CL
        CMP AX,1
        ADC AX,0
        MOV [DI+6],AX
        POP AX
        SUB AX,[DI]
        SHR AX,CL
        CMP AX,1
        ADC AX,0
        MOV [DI+4],AX
CALIB6: MOV AH,1
        INT 16H
        JNZ CALIB6A
        MOV DX,201H
        IN AL,DX
        NOT AL
        TEST AL,0F0H
        JNZ CALIB6
CALIB6A:
        NOT CALIB_MENU
        MOV DI,OFFSET MSG39A
        CMP CALIB_MENU,0
        JZ CALIB1A
        MOV DI,OFFSET MSG39B
        JMP CALIB1
CALIB1A:
        JMP OPTION14
CALIB7: MOV DI,OFFSET MSG39C
        MOV DX,0A18H
        MOV BX,8620H
        CALL MENU
        CALL THAW
        KEYSTROKE
        JMP OPTION14

;Options menu

ITEM    PROC NEAR               ;Display string length CX in DI at DX
        PUSH CX
        MOV BX,10BH
        MOV CX,1
        MOV AL,[DI]
        INC DI
        CALL PC_CHAR
        POP CX
        INC DL
        LOOP ITEM
        RET
ITEM    ENDP

OPTION0: MOV AH,1
        INT 16H
        JZ OPTION1
        KEYSTROKE
        JMP OPTION0
OPTION1: 
        SAVEREG
        MOV AH,3EH
        MOV BX,HANDLE
        INT 21H
        MOV HANDLE,-1
OPTION1A:
        CALL FREEZE
        MOV DI,OFFSET MSG31     ;Display window
        MOV DX,20AH
        MOV BX,953BH
        CALL MENU
OPTION2:                        ;Display current settings        
        MOV DI,OFFSET MSG32A    ;Keyboard
        CMP Byte Ptr KEY_MODE,0
        JZ OPTION3
        MOV DI,OFFSET MSG32B
        CMP Byte Ptr KEY_MODE,1
        JZ OPTION3
        MOV DI,OFFSET MSG32E
OPTION3:
        CMP BYTE PTR DRAGON,0
        JZ OPTION3A
        ADD DI,27
OPTION3A:
        MOV CX,9
        MOV DX,920H
        CALL ITEM
        MOV AL,LJOYSTK          ;Left joystick
        CMP AL,6
        MOV DI,OFFSET MSG33D
        JZ OPTION4
        CMP AL,4
        MOV DI,OFFSET MSG33C
        JZ OPTION4
        CMP AL,2
        MOV DI,OFFSET MSG33B
        JZ OPTION4
        MOV DI,OFFSET MSG33A
OPTION4:
        MOV CX,6
        MOV DX,0A23H
        CALL ITEM
        MOV DI,OFFSET MSG33B    ;Right joystick
        MOV AL,RJOYSTK
        CMP AL,2
        JZ OPTION5
        CMP AL,4
        MOV DI,OFFSET MSG33C
        JZ OPTION5
        CMP AL,6
        MOV DI,OFFSET MSG33D
        JZ OPTION5
        MOV DI,OFFSET MSG33A
OPTION5:
        MOV CX,6
        MOV DX,0B23H
        CALL ITEM
        MOV DI,OFFSET MSG34A    ;Sound
        CMP SOUND,1
        JZ OPTION6
        MOV DI,OFFSET MSG34C
        CMP SOUND,3
        JZ OPTION6
        MOV DI,OFFSET MSG34B
OPTION6:
        MOV CX,8
        MOV DX,0C21H
        CALL ITEM
        MOV DI,OFFSET MSG35A    ;Character set
        CMP LOWERCASE,0
        JZ OPTION7
        MOV DI,OFFSET MSG35B
OPTION7:
        MOV CX,9
        MOV DX,0D20H
        CALL ITEM
        MOV DI,OFFSET MSG38A    ;Artifacting
        CMP ARTIFACT,0
        JZ OPTION7A
        MOV DI,OFFSET MSG38B
        CMP ARTIFACT,1
        JZ OPTION7A
        MOV DI,OFFSET MSG38C
OPTION7A:
        MOV CX,4
        MOV DX,0E25H
        CALL ITEM
        MOV DI,OFFSET MSG40A    ;Add linefeeds
        CMP BYTE PTR ADDLF,0
        JZ OPTION8
        MOV DI,OFFSET MSG40C
        CMP BYTE PTR ADDLF,80H
        JZ OPTION8
        MOV DI,OFFSET MSG40B
OPTION8:
        MOV CX,8
        MOV DX,0F21H
        CALL ITEM
        MOV DI,OFFSET MSG41A    ;Clock frequency
        CMP CLOCK_PERIOD,4DA7H
        JZ OPTION9
        MOV DI,OFFSET MSG41B
OPTION9:
        MOV CX,4
        MOV DX,1025H
        CALL ITEM
        MOV DI,OFFSET MSG42A    ;1.2Mb drive mode
        CMP BYTE PTR DOUBLE_STEP,1
        JZ OPTION9A
        MOV DI,OFFSET MSG42B
OPTION9A:
        MOV CX,8
        MOV DX,1121H
        CALL ITEM
        MOV DI,OFFSET MSG49A    ;Clock sync
        TEST DELAY,8000H
        JZ OPTION9B
        MOV DI,OFFSET MSG49B
OPTION9B:
        MOV CX,3
        MOV DX,1226H
        CALL ITEM
        MOV AX,DELAY            ;Speed slider
        AND AH,7FH
        MOV DX,0
        DIV SPEED_SCALE
        MOV DH,20
        CALL SLIDER
        MOV AL,VOLUME           ;Volume slider
        MOV AH,5
        MUL AH
        MOV DH,21
        CALL SLIDER
        CALL THAW
OPTION10:                       ;Ready for user.  Turn on mouse pointer
        MOV AX,1                ;and wait for some kind of input
        INT 33H
OPTION11:
        MOV AH,1
        INT 16H
        JZ OPTION12
        MOV AX,2
        INT 33H
        JMP OPTIONK
OPTION12:
        CMP MOUSE_HERE,0
        JZ OPTION10
        MOV AX,3
        INT 33H
        TEST BL,1
        JZ OPTION10
        SHR CX,1
        SHR CX,1
        SHR CX,1
        SHR DX,1
        SHR DX,1
        SHR DX,1
        MOV DH,DL
        MOV DL,CL
        PUSH DX
OPTION13:                       ;Otherwise do
        MOV AX,3
        INT 33H
        TEST BL,1
        JNZ OPTION13
        MOV AX,2
        INT 33H
        POP DX
        CMP DH,2                ;Off of window
        JB OPTION14
OPTION10A:
        JZ OPTION10
        CMP DH,22
        JA OPTION14
        JZ OPTION10
        CMP DL,10
        JB OPTION14
        JZ OPTION10
        CMP DL,68
        JA OPTION14
        JZ OPTION10
        CMP DH,8                ;Dead zone
        JB OPTION10
;        CMP DH,18
;        JZ OPTION10
        CMP DH,19
        JZ OPTION10
        MOV CX,OFFSET MOUSE_LEFT
        JA OPTION13B
        CMP DL,42
        JZ OPTION10A
        CMP DL,43
        JZ OPTION10A
        JB OPTION13B
        MOV CX,OFFSET MOUSE_RIGHT
OPTION13B:
        MOV BL,DH               ;Branch to zone handler
        MOV BH,0
        SUB BL,8
        ADD BX,BX
        ADD BX,CX
        JMP WORD PTR [BX]
OPTION14:
        MOV LASTKEY,0           ;Exit for one reason or another
        MOV AL,OLD_DRB2         ;Update VDG the thorough way
        MOV DI,0FF22H
        MOV DRB2,0
        PUTBYTE
        CALL RESETBRANCH
        LOADREG
        MOV AL,DRB2
        NOT AL
        MOV OLD_DRB2,AL
        CALL REVISE
        JMP MAIN

MOUSE_LEFT DW OPTION2,A_OPT,B_OPT,C_OPT,D_OPT,E_OPT,F_OPT,G_OPT,H_OPT
        DW I_OPT,SYNC_OPT,OPTION2,S_OPT,V_OPT
MOUSE_RIGHT DW J_OPT,K_OPT,L_OPT,M_OPT,N_OPT,P_OPT,Q_OPT,R_OPT,O_OPT,T_OPT
        DW OPTION2

A_OPT:  INC BYTE PTR KEY_MODE   ;Change keyboard and redisplay
        CMP BYTE PTR KEY_MODE,3
        JB A_OPT1
        MOV BYTE PTR KEY_MODE,0
        NOT DRAGON
A_OPT1: JMP OPTION2
B_OPT:  ADD LJOYSTK,2           ;Left joystick
        AND BYTE PTR LJOYSTK,6
        CALL JOYTEST
        MOV BYTE PTR FIRE,-1
        JMP OPTION2
C_OPT:  ADD RJOYSTK,2           ;Right joystick
        AND BYTE PTR RJOYSTK,6
        CALL JOYTEST
        MOV BYTE PTR FIRE,-1
        JMP OPTION2
D_OPT:  MOV AL,SOUND            ;Sound
        INC AL
        AND AL,SBMASK
        MOV SOUND,AL
        CMP AL,2
        JNZ A_OPT1
        MOV BYTE PTR SOUND,3
        JMP OPTION2
E_OPT:  CMP LOWERCASE,0         ;Lowercase
        MOV LOWERCASE,0
        JNZ A_OPT1
        MOV LOWERCASE,6400
        JMP OPTION2
F_OPT:  INC ARTIFACT            ;Artifacting
        CMP ARTIFACT,3
        JB A_OPT1
        MOV ARTIFACT,0
        JMP OPTION2
G_OPT:  MOV AL,ADDLF            ;Add linefeeds
        OR AL,AL
        MOV BYTE PTR ADDLF,-1
        JZ G_OPT1
        MOV BYTE PTR ADDLF,80H
        INC AL
        JZ G_OPT1
        MOV BYTE PTR ADDLF,0
G_OPT1: JMP OPTION2
H_OPT:  CMP CLOCK_PERIOD,4DA7H  ;Clock frequency
        MOV CLOCK_PERIOD,4DA7H
        JNZ h_OPT1
        MOV CLOCK_PERIOD,5D2FH
h_opt1: cli
        mov al,36h
        out 43h,al
        mov ax,clock_period
        out 40h,al
        mov al,ah
        out 40h,al
        sti
        JMP OPTION2
I_OPT:  XOR BYTE PTR DOUBLE_STEP,1;40/80 track mode of 1.2Mb drive
        JMP OPTION2
SYNC_OPT:
        XOR DELAY,8000H
        call UpdateSyncLock
        JMP OPTION2
S_OPT:  CMP DL,64               ;Speed
        JA S_OPT2
        CMP DL,26
        JB S_OPT2
        MOV AL,64
        SUB AL,DL
        MOV AH,0
        PUSH AX
        MUL SPEED_SCALE
        AND DELAY,8000H
        AND AH,7FH
        OR DELAY,AX
        POP AX
        MOV DH,20
        CALL SLIDER
S_OPT1: JMP OPTION10
OPTIONMA:
        JMP OPTIONM
OPTIONPA:
        JMP OPTIONP
S_OPT2: CMP DL,25
        JZ OPTIONMA
        CMP DL,66
        JZ OPTIONPA
        MOV AX,1
        INT 33H
S_OPT3: MOV AX,3                ;If outside slider, make sure button released
        INT 33H         
        TEST BL,1
        JNZ S_OPT3
        JMP OPTION11
V_OPT:  CMP DL,64               ;Volume
        JA V_OPT2
        CMP DL,26
        JB V_OPT2
        MOV AX,64
        SUB AL,DL
        MOV DL,5
        DIV DL
        MOV VOLUME,AL
        MUL DL
        MOV DH,21
        CALL SLIDER
V_OPT1: JMP OPTION10
OPTIONLA:
        JMP OPTIONL
OPTIONGA:
        JMP OPTIONG
V_OPT2: CMP DL,25
        JZ OPTIONLA
        CMP DL,66
        JZ OPTIONGA
        MOV AX,1
        INT 33H
V_OPT3: MOV AX,3                ;If outside slider, make sure button released
        INT 33H         
        TEST BL,1
        JNZ V_OPT3
        JMP OPTION11
J_OPT:  LOADREG                 ;Debug
        MOV DBGMSG,OFFSET MSG17
        JMP DEBUG
K_OPT:  LOADREG                 ;Virtual disk menu
        JMP VDISK
L_OPT:  LOADREG                 ;Snapshot menu
        JMP SNAP
M_OPT:  LOADREG                 ;Customize keyboard
        JMP CUSTOMIZE
N_OPT:  JMP CALIB0              ;Calibrate joystick
O_OPT:  MOV AX,3                ;Shell call to DOS
        INT 10H
        MOV AH,9
        MOV DX,OFFSET MSG43
        INT 21H
        PUSH DS
        PUSH ES
        MOV DS,ENVIRONMENT      ;Look for COMSPEC= in environment
        MOV DI,0
        JMP O_OPT2
O_OPT1: INC DI
        CMP BYTE PTR [DI-1],0
        JNZ O_OPT1
        CMP BYTE PTR [DI],0
        JNZ O_OPT2
        MOV AX,CS
        MOV DS,AX
        MOV DX,OFFSET COMMAND_NAME
        JMP O_OPT3
O_OPT2: CMP WORD PTR [DI],4F43H ;"CO"
        JNZ O_OPT1
        CMP WORD PTR [DI+2],534DH
        JNZ O_OPT1              ;"MS"
        CMP WORD PTR [DI+4],4550H
        JNZ O_OPT1              ;"PE"
        CMP WORD PTR [DI+6],3D43H
        JNZ O_OPT1              ;"C="
        MOV DX,DI
        ADD DX,8
        JMP O_OPT3A
O_OPT3: MOV AH,4AH              ;Decrease required memory size by 32K
        MOV ES,CS:BASE_SEGMENT  ;This part is executed only when shelling to
        MOV BX,CS:MEMORY_SIZE   ;PORT.EXE, so as to allow it to use the 
        SUB BX,800H             ;32K workspace normally allocated for 
        INT 21H                 ;discarded writes to ROM
O_OPT3A:
        MOV AX,CS               ;ES:BX is parameter block
        MOV ES,AX
        MOV BX,OFFSET PARAM_BLOCK
        MOV AX,4B00H
        INT 21H
        JNB O_OPT4
        MOV DL,7
        MOV AH,2
        INT 21H
O_OPT4: MOV ES,CS:BASE_SEGMENT  ;Restore required memory size
        MOV BX,CS:MEMORY_SIZE
        MOV AH,4AH
        INT 21H
        POP ES
        POP DS
        JNB O_OPT5
        MOV AX,3                ;If there was a memory allocation error,
        INT 10H                 ;abort
        MOV AH,9
        MOV DX,OFFSET MSG45
        INT 21H
        JMP QUIT1A
O_OPT5: MOV AX,14               ;Restore video
        INT 10H
        MOV AH,1AH              ;Reset Disk Transfer Address
        MOV DX,OFFSET DTA
        INT 21H
        MOV SI,OFFSET CUR_PATH  ;Restore working directory so vdisks work
        CALL RESTORE_DIR
        CALL SHOW               ;Redisplay CoCo screen
        PUSH ES                 ;Restore mouse driver after reset
        MOV AX,0
        INT 33H
        MOV AX,CS
        MOV ES,AX
        MOV DX,OFFSET MOUSE_INTERCEPT
        MOV CX,47
        MOV AX,0CH
        INT 33H
        POP ES
        JMP OPTION14            ;Redisplay options menu
PORT:   SAVEREG                 ;Standard preamble if PORT activated by F9
        MOV AH,3EH
        MOV BX,HANDLE
        INT 21H
        MOV HANDLE,-1
P_OPT:  MOV SI,OFFSET CUR_PATH  ;File import/export utility, call program
        CALL RESTORE_DIR        ;First select COCO.EXE's home directory
        MOV DX,OFFSET PORT_NAME ;then call the program
        PUSH DS
        PUSH ES
        JMP O_OPT3
Q_OPT:  MOV DI,OFFSET MSG36     ;Quit
        CALL CONFIRM
        JB R_OPT1
        JMP QUIT1
R_OPT:  MOV DI,OFFSET MSG37     ;Restart
        CALL CONFIRM
        JB R_OPT1
        MOV RESTART_FLAG,-1
        MOV LASTKEY,0
        JMP QUIT1
R_OPT1: JMP OPTION1A
T_OPT:  LOADREG                 ;Virtual cassette menu
        JMP VIRCAS
OPTIONLB:
        JMP OPTIONL
OPTIONK:                        ;Keyboard handler
        KEYSTROKE
        CMP AL,27
        JNZ OPTIONK1
        JMP OPTION14            ;ESC exit branch
OPTIONK1:
        CMP AL,'+'              ;Speed control keys
        JZ OPTIONP
        CMP AL,'-'
        JZ OPTIONM
        CMP AL,'<'              ;Volume control keys
        JZ OPTIONLB
        CMP AL,'>'
        JZ OPTIONG
        AND AL,223
        SUB AL,'A'              ;Letter options
        JB OPTIONK2
        CMP AL,20
        JNB OPTIONK2
        MOV BL,AL
        MOV BH,0
        ADD BX,BX
        JMP KEY_OPTION[BX]
OPTIONK2:
        JMP OPTION10
KEY_OPTION DW A_OPT,B_OPT,C_OPT,D_OPT,E_OPT,F_OPT,G_OPT,H_OPT,I_OPT,SYNC_OPT
        DW J_OPT,K_OPT,L_OPT,M_OPT,N_OPT,P_OPT,Q_OPT,R_OPT,O_OPT,T_OPT
OPTIONP:                        ;Increase speed by one step
        MOV AX,DELAY
        AND AH,7FH
        JZ OPTIONP1
        SUB AX,SPEED_SCALE
        JNB OPTIONP1
        MOV AX,0
OPTIONP1:
        AND DELAY,8000H
        AND AH,7FH
        OR DELAY,AX
        JMP OPTION2
OPTIONM:                        ;Decrease speed by one step
        MOV AX,DELAY
        AND AX,7FH
        ADD AX,SPEED_SCALE
        MOV DX,0
        DIV SPEED_SCALE
        CMP AX,38
        JNA OPTIONM1
        MOV AX,38
OPTIONM1:
        MUL SPEED_SCALE
        JMP OPTIONP1
OPTIONG:                        ;Increase volume by one step
        SUB BYTE PTR VOLUME,1
        JNB OPTIONG1
        MOV BYTE PTR VOLUME,0
OPTIONG1:        
        JMP OPTION2
OPTIONL:                        ;Decrease volume by one step
        ADD BYTE PTR VOLUME,1
        CMP BYTE PTR VOLUME,8
        JB OPTIONG1
        MOV BYTE PTR VOLUME,7
        JMP OPTION2

SPEED_SCALE DW 1

CONFIRM PROC NEAR               ;Display confirmation window in DI
        CALL FREEZE
        MOV DX,916H
        MOV BX,8623H
        MOV MENU_BACK,4         ;Make this window red/yellow
        CALL MENU
        MOV MENU_BACK,1         ;Restore normal blue/cyan
        MOV AX,4                ;Set mouse cursor position
        MOV DX,96
        MOV CX,216
        INT 33H
        CALL THAW
CONFIRM1: 
        MOV AX,1                ;Enable mousy pointy thingy
        INT 33H
CONFIRM2:                       ;Wait for user response
        MOV AH,1
        INT 16H
        JNZ CONFIRM4
        CMP MOUSE_HERE,0
        JZ CONFIRM2
        MOV AX,3
        INT 33H
        TEST BL,1
        JZ CONFIRM2
        SHR DX,1                ;Mouse button pressed.  Get coordinates.
        SHR DX,1
        SHR DX,1
        SHR CX,1
        SHR CX,1
        SHR CX,1
        MOV DH,DL
        MOV DL,CL
CONFIRM3:
        PUSH DX                 ;Wait for button to be released
        MOV AX,3
        INT 33H
        POP DX
        TEST BL,1
        JNZ CONFIRM3
        MOV AX,2                ;Bye-bye mousy pointy thingy
        INT 33H
        CMP DH,13               ;Dead space of mouse
        JA CONFIRM1
        CMP DH,11
        JB CONFIRM1
        CMP DL,23
        JB CONFIRM1
        CMP DL,31               ;"Yes" zone
        JB CONFIRMY
        CMP DL,56
        JA CONFIRM1
        CMP DL,48               ;"No" zone
        JA CONFIRMN
        JMP CONFIRM1
CONFIRM4:
        MOV AX,2                ;Keyboard intercept.  Kill mouse pointer.
        INT 33H
        KEYSTROKE
        AND AL,223
        CMP AL,'Y'
        JZ CONFIRMY
        CMP AL,'N'
        JZ CONFIRMN
        JMP CONFIRM1
CONFIRMY:
        CLC
        RET
CONFIRMN:
        STC
        RET
CONFIRM ENDP

SLIDER  PROC NEAR               ;Display speed slider        
        MOV CX,38
        SUB CX,AX
        JZ SLIDER1
        PUSH AX
        MOV DL,1BH
        MOV AL,7
        MOV BX,010BH
        PUSH DX
        CALL PC_CHAR
        POP DX
        POP AX
SLIDER1:
        ADD CL,27
        MOV DL,CL
        MOV CX,AX
        CMP AX,0
        JZ SLIDER2
        MOV AL,8
        MOV BX,01H
        CALL PC_CHAR
SLIDER2:
        RET
SLIDER  ENDP

;6809 instruction set -- diassembly

;Single byte instruction set

;00h-0Fh
SINGLE  DB 'neg $d|?|?|com $d|lsr $d|?|ror $d|asr $d|asl $d|rol $d|dec $d|?|'
        DB 'inc $d|tst $d|jmp $d|clr $d|'
;10-1Fh
        DB '?|?|nop|sync|?|?|lbra $l|lbsr $l|?|daa|orcc $2|?|andcc $2|sex|'
        DB 'exg $t|tfr $t|'
;20-2Fh
        DB 'bra $s|brn $s|bhi $s|bls $s|bcc $s|bcs $s|bne $s|beq $s|bvc $s|'
        DB 'bvs $s|bpl $s|bmi $s|bge $s|blt $s|bgt $s|ble $s|'
;30-3Fh
        DB 'leax $p|leay $p|leas $p|leau $p|pshs $r|puls $r|pshu $u|pulu $u|'
        DB '?|rts|abx|rti|cwai $2|mul|?|swi|'
;40-4Fh        
        DB 'nega|?|?|coma|lsra|?|rora|asra|asla|rola|deca|?|inca|tsta|?|clra|'
;50-5Fh
        DB 'negb|?|?|comb|lsrb|?|rorb|asrb|aslb|rolb|decb|?|incb|tstb|?|clrb|'
;60-6Fh
        DB 'neg $p|?|?|com $p|lsr $p|?|ror $p|asr $p|asl $p|rol $p|dec $p|'
        DB '?|inc $p|tst $p|jmp $p|clr $p|'
;70-7Fh
        DB 'neg $a|?|?|com $a|lsr $a|?|ror $a|asr $a|asl $a|rol $a|dec $a|'
        DB '?|inc $a|tst $a|jmp $a|clr $a|'
;80-8Fh
        DB 'suba $b|cmpa $b|sbca $b|subd $w|anda $b|bita $b|lda $b|?|eora $b|'
        DB 'adca $b|ora $b|adda $b|cmpx $w|bsr $s|ldx $w|?|'
;90-9Fh
        DB 'suba $d|cmpa $d|sbca $d|subd $d|anda $d|bita $d|lda $d|sta $d|'
        DB 'eora $d|adca $d|ora $d|adda $d|cmpx $d|jsr $d|ldx $d|stx $d|'
;A0-AFh
        DB 'suba $p|cmpa $p|sbca $p|subd $p|anda $p|bita $p|lda $p|sta $p|'
        DB 'eora $p|adca $p|ora $p|adda $p|cmpx $p|jsr $p|ldx $p|stx $p|'
;B0-BFh
        DB 'suba $a|cmpa $a|sbca $a|subd $a|anda $a|bita $a|lda $a|sta $a|'
        DB 'eora $a|adca $a|ora $a|adda $a|cmpx $a|jsr $a|ldx $a|stx $a|'
;C0-CFh
        DB 'subb $b|cmpb $b|sbcb $b|addd $w|andb $b|bitb $b|ldb $b|?|eorb $b|'
        DB 'adcb $b|orb $b|addb $b|ldd $w|?|ldu $w|?|'
;D0-DFh
        DB 'subb $d|cmpb $d|sbcb $d|addd $d|andb $d|bitb $d|ldb $d|stb $d|'
        DB 'eorb $d|adcb $d|orb $d|addb $d|ldd $d|std $d|ldu $d|stu $d|'
;E0-EFh
        DB 'subb $p|cmpb $p|sbcb $p|addd $p|andb $p|bitb $p|ldb $p|stb $p|'
        DB 'eorb $p|adcb $p|orb $p|addb $p|ldd $p|std $p|ldu $p|stu $p|'
;F0-FFh
        DB 'subb $a|cmpb $a|sbcb $a|addd $a|andb $a|bitb $a|ldb $a|stb $a|'
        DB 'eorb $a|adcb $a|orb $a|addb $a|ldd $a|std $a|ldu $a|stu $a|'

;Double byte instruction set

;10 00-10 1Fh
DBL10   DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
;10 20-10 2Fh        
        DB '?|lbrn $l|lbhi $l|lbls $l|lbhs $l|lblo $l|lbne $l|lbeq $l|'
        DB 'lbvc $l|lbvs $l|lbpl $l|lbmi $l|lbge $l|lblt $l|lbgt $l|lble $l|'
;10 30-10 3Fh
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|swi2|'
;10 40-10 7Fh
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
;10 80-10 8Fh
        DB '?|?|?|cmpd $w|?|?|?|?|?|?|?|?|cmpy $w|?|ldy $w|?|'
;10 90-10 9Fh
        DB '?|?|?|cmpd $d|?|?|?|?|?|?|?|?|cmpy $d|?|ldy $d|sty $d|'
;10 A0-10 AFh
        DB '?|?|?|cmpd $p|?|?|?|?|?|?|?|?|cmpy $p|?|ldy $p|sty $p|'
;10 B0-10 BFh
        DB '?|?|?|cmpd $a|?|?|?|?|?|?|?|?|cmpy $a|?|ldy $a|sty $a|'
;10 C0-10 CFh
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|lds $w|?|'
;10 D0-10 DFh
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|lds $d|sts $d|'
;10 E0-10 EFh        
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|lds $p|sts $p|'
;10 F0-10 FFh
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|lds $a|sts $a|'

;11 00-11 2Fh
DBL11   DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
;11 30-11 3Fh
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|swi3|'
;11 40-11 7Fh        
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
;11 80h-11 BFh
        DB '?|?|?|cmpu $w|?|?|?|?|?|?|?|?|cmps $w|?|?|?|'
        DB '?|?|?|cmpu $d|?|?|?|?|?|?|?|?|cmps $d|?|?|?|'
        DB '?|?|?|cmpu $p|?|?|?|?|?|?|?|?|cmps $p|?|?|?|'
        DB '?|?|?|cmpu $a|?|?|?|?|?|?|?|?|cmps $a|?|?|?|'
;11 C0-11 FFh
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|[8086 mode]|'

;Index/indirect post bytes

;00-0Fh
POST_TABLE DB '0,X|1,X|2,X|3,X|4,X|5,X|6,X|7,X|8,X|9,X|10,X|11,X|12,X|13,X|'
        DB '14,X|15,X|'
;10-1Fh
        DB '-16,X|-15,X|-14,X|-13,X|-12,X|-11,X|-10,X|-9,X|-8,X|-7,X|-6,X|'
        DB '-5,X|-4,X|-3,X|-2,X|-1,X|'
;20-2Fh        
        DB '0,Y|1,Y|2,Y|3,Y|4,Y|5,Y|6,Y|7,Y|8,Y|9,Y|10,Y|11,Y|12,Y|13,Y|'
        DB '14,Y|15,Y|'
;30-3Fh
        DB '-16,Y|-15,Y|-14,Y|-13,Y|-12,Y|-11,Y|-10,Y|-9,Y|-8,Y|-7,Y|-6,Y|'
        DB '-5,Y|-4,Y|-3,Y|-2,Y|-1,Y|'
;40-4Fh        
        DB '0,U|1,U|2,U|3,U|4,U|5,U|6,U|7,U|8,U|9,U|10,U|11,U|12,U|13,U|'
        DB '14,U|15,U|'
;50-5Fh
        DB '-16,U|-15,U|-14,U|-13,U|-12,U|-11,U|-10,U|-9,U|-8,U|-7,U|-6,U|'
        DB '-5,U|-4,U|-3,U|-2,U|-1,U|'
;60-6Fh        
        DB '0,S|1,S|2,S|3,S|4,S|5,S|6,S|7,S|8,S|9,S|10,S|11,S|12,S|13,S|'
        DB '14,S|15,S|'
;70-7Fh
        DB '-16,S|-15,S|-14,S|-13,S|-12,S|-11,S|-10,S|-9,S|-8,S|-7,S|-6,S|'
        DB '-5,S|-4,S|-3,S|-2,S|-1,S|'
;80-8Fh
        DB ',X+|,X++|,-X|,--X|,X|B,X|A,X|?|$o,X|$O,X|?|D,X|$o,PC|$O,PC|?|?|'
;90-9Fh
        DB '?|[,X++]|?|[,--X]|[,X]|[B,X]|[A,X]|?|[$o,X]|[$O,X]|?|[D,X]|'
        DB '[$o,PC]|[$O,PC]|?|[$O]|'
;A0-AFh
        DB ',Y+|,Y++|,-Y|,--Y|,Y|B,Y|A,Y|?|$o,Y|$O,Y|?|D,Y|$o,PC|$O,PC|?|?|'
;B0-BFh
        DB '?|[,Y++]|?|[,--Y]|[,Y]|[B,Y]|[A,Y]|?|[$o,Y]|[$O,Y]|?|[D,Y]|'
        DB '[$o,PC]|[$O,PC]|?|[$O]|'
;C0-CFh
        DB ',U+|,U++|,-U|,--U|,U|B,U|A,U|?|$o,U|$O,U|?|D,U|$o,PC|$O,PC|?|?|'
;D0-DFh
        DB '?|[,U++]|?|[,--U]|[,U]|[B,U]|[A,U]|?|[$o,U]|[$O,U]|?|[D,U]|'
        DB '[$o,PC]|[$O,PC]|?|[$O]|'
;E0-EFh
        DB ',S+|,S++|,-S|,--S|,S|B,S|A,S|?|$o,S|$O,S|?|D,S|$o,PC|$O,PC|?|?|'
;F0-FFh
        DB '?|[,S++]|?|[,--S]|[,S]|[B,S]|[A,S]|?|[$o,S]|[$O,S]|?|[D,S]|'
        DB '[$o,PC]|[$O,PC]|?|[$O]|'


;General lookup information

;MSG0    DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
;        DB 'º  *** UNREGISTERED SHAREWARE ***  º'
;        DB 'º                                  º'
;        DB 'º Disk and snapshot output is      º'
;        DB 'º available only to registered     º'  
;        DB 'º users. See COCO.DOC for details. º'
;        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
MSG1    DB 'Press appropriate letter to toggle flag.  ENTER when done or'
        DB ' ESC to abort.'
MSG2    DB 0
MSG3    DB 'Quit emulator/Return to DOS.  Reply "Y" to confirm.',0
MSG4    DB 'Memory dump.  Enter an address or a register: '    
MSG4A   DB '    ',0
MSG5    DB 'Select with arrow keys or letter.  Press ENTER to change or ESC '
        DB 'to abort.',0
MSG6    DB 'Enter new value for register:     ',0
MSG7    DB 'Arrow keys move cursor.  Press ENTER or ESC when done.',0
MSG8    DB 'Disassemble.  Enter an address or a register: '
MSG8A   DB '    ',0
MSG9B   DB '     ? '
MSG9    DB 'Hexidecimal number: '
MSG9A   DB '    ',0
MSG10   DB '       Options: + - * / And Or Xor Neg Shift Rot Dec.   ENTER '
        DB 'or ESC when done.',0
MSG11   DB '       Use arrows to shift.  Press ENTER or ESC to return to '
        DB 'options.',0
MSG12   DB '       Use arrows to rotate.  Press ENTER or ESC to return to '
        DB 'options.',0
MSG13   DB '       Decimal: '
MSG13A  DB '-00000'
MSG13B  DB 0
MSG14   DB 'No Colour Computer ROM files found in default path.$'
MSG16   DB 'Breakpoint.  Enter address:     ',0
MSG17   DB 'Debugger requested.  Press "C" to resume normal operation.',0
MSG18   DB 'Halted at breakpoint address.',0
MSG19   DB 'Bad instruction!  System may have crashed.  Press "C" to return '
        DB 'to emulation.',0
MSG20   DB 'ÚÄÄÄÄÄÄ¿³Break@³³      ³ÀÄÄÄÄÄÄÙ',0
MSG21   DB 'CoCo    keyboardlayout  selected',0
MSG22   DB 'PC      keyboardlayout  selected',0
MSG22A  DB 'Custom  keyboardlayout  selected',0
MSG23   DB 168 DUP(32),0
MSG24   DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º VIRTUAL DISK MENU:                      º'
        DB 'º Select a drive, then enter a disk name  º'
        DB 'º or chose it from the directory listing. º'
        DB 'ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶'
        DB 'º SHIFT+number to write protect a drive,  º'
        DB 'º or ESC to resume emulation.             º'
        DB 'ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶'
        DB 'º Drive  Diskname                         º'
        DB 'º   0                                     º'  
        DB 'º   1                                     º'
        DB 'º   2                                     º'
        DB 'º   3                                     º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
MSG25   DB 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
        DB '³ ',24,' Directory ',25,' ³'
        DB 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
MSG26   DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º WARNING!  Virtual disk          º'
        DB 'º '                                
MSG26A  DB '                                º'
        DB 'º does not exist!                 º'
        DB 'º                                 º'
        DB 'º Create it now?  Reply:          º'
        DB 'º ÚÄÄÄÄÄÄ¿               ÚÄÄÄÄÄÄ¿ º'
        DB 'º ³ Yes  ³               ³ No   ³ º'  
        DB 'º ÀÄÄÄÄÄÄÙ               ÀÄÄÄÄÄÄÙ º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
MSG27   DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º PROGRAM PAK/SNAPSHOT OPTION:          º'
        DB 'º Choose either Load or Save, or press  º'
        DB 'º ESC to resume normal emulation.       º'
        DB 'º                                       º'
        DB 'º Name:                                 º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
MSG28   DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º    TRS-80 COLOUR COMPUTER 2 EMULATOR    º'
        DB 'º  Ver 1.6 (C)1993-95,2001 Jeff Vavasour  º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
        DB 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
        DB '³ Debug                                F1 ³'
        DB '³ Virtual Disk Menu    Click middle or F2 ³'
        DB '³ Snapshots/Paks                       F3 ³'
        DB '³ Virtual Cassette Menu                F4 ³'
        DB '³ Sound on/off                         F5 ³'
        DB '³ Options Menu/Quit     Click right or F6 ³'
        DB '³ Select keyboard mode                 F7 ³'
        DB '³ Modify custom keyboard layout        F8 ³'
        DB '³ File Import/Export Utility           F9 ³'
        DB '³ Reset                          CTRL-F10 ³'
        DB '³ This screen                         F10 ³'
        DB 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
MSG29   DB 'Sound:  On                      ',0  
MSG30   DB 'Sound:  Off                     ',0
MSG31   DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º OPTIONS MENU:                                           º'
        DB 'º Press letter or click to change/select options.  ESC to º'
        DB 'º resume normal emulation.                                º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
        DB 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
        DB '³ CONFIGURATIONS:               ³³ K. Debug               ³'
        DB '³  A. Keyboard mode............ ³³ L. Virtual disk menu   ³'
        DB '³  B. Left joystick............ ³³ M. Snapshot/Pak menu   ³'
        DB '³  C. Right joystick........... ³³ N. Customize keyboard  ³'
        DB '³  D. Sound.................... ³³ O. Calibrate joysticks ³'
        DB '³  E. Character set............ ³³ P. File port utility   ³'
        DB '³  F. Artifacting.............. ³³ Q. Quit                ³'
        DB '³  G. Printer mode............. ³³ R. Restart             ³'
        DB '³  H. Clock frequency.......... ³³ S. Shell to DOS        ³'
        DB '³  I. 1.2Mb drive as........... ³³ T. Virtual tape menu   ³'
        DB '³  J. Original speed........... ³ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
        DB 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
        DB '³ SPEED:       -                                        + ³'
        DB '³ EXT. VOLUME: <                                        > ³'
        DB 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
MSG32A  DB '.......PC'
MSG32B  DB '.....CoCo'
MSG32E  DB '...Custom'
MSG32C  DB '.DragonPC'
MSG32D  DB '...Dragon'
MSG32F  DB 'DgnCustom'
MSG33A  DB '.Mouse'
MSG33B  DB 'Game A'
MSG33C  DB 'Game B'
MSG33D  DB '..None'
MSG34A  DB 'Internal'
MSG34B  DB '.....Off'
MSG34C  DB 'External'
MSG35A  DB '..Inverse'
MSG35B  DB 'Lowercase'
MSG36   DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º Confirm: QUIT?                  º'
        DB 'º ÚÄÄÄÄÄÄ¿               ÚÄÄÄÄÄÄ¿ º'
        DB 'º ³ Yes  ³               ³ No   ³ º'  
        DB 'º ÀÄÄÄÄÄÄÙ               ÀÄÄÄÄÄÄÙ º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
MSG37   DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º Confirm: RESTART?               º'
        DB 'º ÚÄÄÄÄÄÄ¿               ÚÄÄÄÄÄÄ¿ º'
        DB 'º ³ Yes  ³               ³ No   ³ º'  
        DB 'º ÀÄÄÄÄÄÄÙ               ÀÄÄÄÄÄÄÙ º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
MSG38A  DB '.Off'
MSG38B  DB '.Red'
MSG38C  DB 'Blue'
MSG39A  DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º CALIBRATE JOYSTICK:          º'
        DB 'º Move joystick A or B to the  º'
        DB 'º upper-left corner and press  º'
        DB 'º its button.  Press ESC to    º'
        DB 'º resume normal emulation.     º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
MSG39B  DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º CALIBRATE JOYSTICK:          º'
        DB 'º Move same joystick to the    º'
        DB 'º lower-right corner and press º'
        DB 'º its button.  Press ESC to    º'
        DB 'º resume normal emulation.     º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
MSG39C  DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º CALIBRATE JOYSTICK:          º'
        DB 'º No game port found in this   º'
        DB 'º machine.  Press any key to   º'
        DB 'º resume normal emulation.     º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
MSG40A  DB '.CR only'
MSG40B  DB '...CR/LF'
MSG40C  DB 'Disabled'
MSG41A  DB '60Hz'
MSG41B  DB '50Hz'
MSG42A  DB '40 track'
MSG42B  DB '80 track'
MSG43   DB 'Type "EXIT" to return to the CoCo emulator.',13,'$'
MSG44   DB 'Insufficient memory to run emulator.  Need an extra '
MSG44A  DB '000K free.',13,10,'$'
MSG45   DB 'Unable to reclaim emulator workspace, aborting...',13,10,'$'
MSG46   DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º VIRTUAL CASSETTE MENU:         ÚÄÄÄÄÄÄÄ¿º'
        DB 'º Select a field by clicking it  ³counter³º'
        DB 'º or pressing its associated     ³       ³º'
        DB 'º letter. ESC resumes emulation. ÀÄÄÄÄÄÄÄÙº'
        DB 'ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶'
        DB 'º Name:                                   º'
        DB 'º Mode:                                   º'  
        DB 'ºÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿º'
        DB 'º³ Start   ³ Rewind  ³ Forward ³ End     ³º'  
        DB 'ºÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÙº'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
MSG47A  DB 'PLAYBACK'
MSG47B  DB '*RECORD*'
MSG48   DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º WARNING!  Virtual cassette      º'
        DB 'º '                                
MSG48A  DB '                                º'
        DB 'º does not exist!                 º'
        DB 'º                                 º'
        DB 'º Create it now?  Reply:          º'
        DB 'º ÚÄÄÄÄÄÄ¿               ÚÄÄÄÄÄÄ¿ º'
        DB 'º ³ Yes  ³               ³ No   ³ º'  
        DB 'º ÀÄÄÄÄÄÄÙ               ÀÄÄÄÄÄÄÙ º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
MSG49A  DB 'Yes'
MSG49B  DB '.No'
MSG15   DB 'Error loading '
ROMNAME DB '????????.ROM$'
PAKSEARCH DB -1,0,0,0,0,0,00H
        DB 0,'????????PAK'
        DB 20 DUP(?)
DSKSEARCH DB -1,0,0,0,0,0,00H
        DB 0,'????????DSK'
        DB 20 DUP(?)
CASSEARCH DB -1,0,0,0,0,0,00H
        DB 0,'????????CAS'
        DB 20 DUP(?)
DIRSEARCH DB -1,0,0,0,0,0,10H
        DB 0,'???????????'
        DB 20 DUP(?)
ROMSEARCH DB 0,'????????ROM'
        DB 20 DUP(?)
DISK_CONFIG DB 'DRIVES.CFG',0
GENERAL_CONFIG DB 'GENERAL.CFG',0
COMMAND_NAME DB '\COMMAND.COM'
COMMAND_PARAM DB 0,13
PARAM_BLOCK DW 0
        DW OFFSET COMMAND_PARAM
        DW SEG COMMAND_PARAM
        DW OFFSET COMMAND_PARAM
        DW SEG COMMAND_PARAM
        DW OFFSET COMMAND_PARAM
        DW SEG COMMAND_PARAM
PORT_NAME DB 'PORT.EXE',0
FL_LIST DB 'EFHINZVC'
RG_LIST DB 'SUYXP'
HEX_LIST DB 'FEDCBA9876543210'
EXG_LIST DB 'D|X|Y|U|S|PC|?|?|A|B|CC|DP|?|?|?|?|'
SP_LIST DB 'PC|U|Y|X|DP|B|A|CC|'
UP_LIST DB 'PC|S|Y|X|DP|B|A|CC|'
PTR_LIST DB 'DPSUYXADDDD'
CALC_CMD DB 'D+-*/AOXNSR',13,27
DBGMSG  DW OFFSET MSG2
COMMANDS: 
        DB 'B'
        DW BREAK
        DB 'C'
        DW CONTINUE
        DB 'D'
        DW DISASM
        DB 'E'
        DW EDIT
        DB 'F'
        DW FLAGS
        DB 'H'
        DW MATH
        DB 'M'
        DW MEMORY
        DB 'Q'
        DW QUIT
        DB 'R'
        DW SETREG
        DB 'S'
        DW STEP
        DB 'V'
        DW VIDEO
        DB 0
LASTDIS DB 'P'
KEY_MSG DW MSG22
        DW MSG21
        DW MSG22A

;Flag translation tables

FLAGS_TO_6809 DB 0
        DB 1,0,1,0,1,0,1,2,3,2,3,2,3,2,3,32,33,32,33,32,33,32,33,34,35,34
        DB 35,34,35,34,35,0,1,0,1,0,1,0,1,2,3,2,3,2,3,2,3,32,33,32,33,32,33
        DB 32,33,34,35,34,35,34,35,34,35,4,5,4,5,4,5,4,5,6,7,6,7,6,7,6,7,36
        DB 37,36,37,36,37,36,37,38,39,38,39,38,39,38,39,4,5,4,5,4,5,4,5,6,7
        DB 6,7,6,7,6,7,36,37,36,37,36,37,36,37,38,39,38,39,38,39,38,39,8,9,8
        DB 9,8,9,8,9,10,11,10,11,10,11,10,11,40,41,40,41,40,41,40,41,42,43,42
        DB 43,42,43,42,43,8,9,8,9,8,9,8,9,10,11,10,11,10,11,10,11,40,41,40,41
        DB 40,41,40,41,42,43,42,43,42,43,42,43,12,13,12,13,12,13,12,13,14,15
        DB 14,15,14,15,14,15,44,45,44,45,44,45,44,45,46,47,46,47,46,47,46,47
        DB 12,13,12,13,12,13,12,13,14,15,14,15,14,15,14,15,44,45,44,45,44,45
        DB 44,45,46,47,46,47,46,47,46,47

FLAGS_TO_8086 DB 0
        DB 1,8,9,64,65,72,73,128,129,136,137,192,193,200,201,0,1,8,9,64,65
        DB 72,73,128,129,136,137,192,193,200,201,16,17,24,25,80,81,88,89,144
        DB 145,152,153,208,209,216,217,16,17,24,25,80,81,88,89,144,145,152,153
        DB 208,209,216,217,0,1,8,9,64,65,72,73,128,129,136,137,192,193,200,201
        DB 0,1,8,9,64,65,72,73,128,129,136,137,192,193,200,201,16,17,24,25,80
        DB 81,88,89,144,145,152,153,208,209,216,217,16,17,24,25,80,81,88,89
        DB 144,145,152,153,208,209,216,217,0,1,8,9,64,65,72,73,128,129,136,137
        DB 192,193,200,201,0,1,8,9,64,65,72,73,128,129,136,137,192,193,200,201
        DB 16,17,24,25,80,81,88,89,144,145,152,153,208,209,216,217,16,17,24
        DB 25,80,81,88,89,144,145,152,153,208,209,216,217,0,1,8,9,64,65,72,73
        DB 128,129,136,137,192,193,200,201,0,1,8,9,64,65,72,73,128,129,136,137
        DB 192,193,200,201,16,17,24,25,80,81,88,89,144,145,152,153,208,209,216
        DB 217,16,17,24,25,80,81,88,89,144,145,152,153,208,209,216,217

;Graphics fonts

FONT_128C DB 4
;Bit map    20   31   
        DB 000H,000H    ;00 00 nibble
        DB 00FH,000H    ;00 01 
        DB 000H,00FH    ;00 10
        DB 00FH,00FH    ;00 11
        DB 0F0H,000H    ;01 00
        DB 0FFH,000H    ;01 01
        DB 0F0H,00FH    ;01 10
        DB 0FFH,00FH    ;01 11
        DB 000H,0F0H    ;10 00
        DB 00FH,0F0H    ;10 01
        DB 000H,0FFH    ;10 10
        DB 00FH,0FFH    ;10 11
        DB 0F0H,0F0H    ;11 00
        DB 0FFH,0F0H    ;11 01
        DB 0F0H,0FFH    ;11 10
        DB 0FFH,0FFH    ;11 11
FONT_64C  DB 2
;Bit map    00   11        
        DB 000H,000H    ;00
        DB 0FFH,000H    ;01
        DB 000H,0FFH    ;10
        DB 0FFH,0FFH    ;11
FONT_256R DB 4
;First and second byte same, bit 0 -> 0/1, 1 -> 2/3, 2 -> 4/5, 3 -> 6/7        
        DB 000H,000H    ;0 0 0 0
        DB 003H,003H    ;0 0 0 1
        DB 00CH,00CH    ;0 0 1 0
        DB 00FH,00FH    ;0 0 1 1
        DB 030H,030H    ;0 1 0 0
        DB 033H,033H    ;0 1 0 1
        DB 03CH,03CH    ;0 1 1 0
        DB 03FH,03FH    ;0 1 1 1
        DB 0C0H,0C0H    ;1 0 0 0
        DB 0C3H,0C3H    ;1 0 0 1
        DB 0CCH,0CCH    ;1 0 1 0
        DB 0CFH,0CFH    ;1 0 1 1
        DB 0F0H,0F0H    ;1 1 0 0 
        DB 0F3H,0F3H    ;1 1 0 1
        DB 0FCH,0FCH    ;1 1 1 0
        DB 0FFH,0FFH    ;1 1 1 1
FONT_128R DB 2
;First and second byte save, bit 0 -> 0/1/2/3, 1 -> 4/5/6/7
        DB 000H,000H    ;0 0
        DB 00FH,00FH    ;0 1
        DB 0F0H,0F0H    ;1 0
        DB 0FFH,0FFH    ;1 1

;Emulator data -- not to be saved

KEY_MATRIX DB 8 DUP(-1)         ;Array representing each bit plane of PIA1
CALCDATA DW ?                   ;Used in Hex Math option
BRKPT   DW -1                   ;Break point address. -1=disable
BACKUP  DB 80 DUP(?)            ;Copy of keyboard buffer to restore if ESC
DTA     DB 6249 DUP(?)          ;Disk transfer address 
LASTKEY DB 16 DUP(?)            ;Last key caught by keyboard interrupt
MARGIN  DB 0                    ;Non-zero indicates data in screen margin
VID_SEG DW 0A000H               ;Video segment
VID_PAG DB 0                    ;Video page
DRA1_MATRIX DB 256 DUP(-1)      ;Lookup table for DRA1 response to DRB1 set
FILE_BFR DB 32 DUP(?)           ;File name input field
HANDLE  DW -1                   ;Handle of currently open virtual drive file
COUNTDOWN DB 0                  ;Timer for closing virtual files
CUR_PATH DB 0,'\',64 DUP(0)     ;Power-up default directory
PULSE DB 0                      ;128=clock interrupt request
SG_MODE DW 0                    ;Offset associated with VDG modes A/SG4/SG6
DRAG_XLAT DB 2,3,4,5,0,1,6,7    ;Dragon keyboard column rearrangement
ENVIRONMENT DW 0                ;Segment of DOS environment
BASE_SEGMENT DW 0               ;Segment of PSP
MEMORY_SIZE DW 0                ;Contains required memory alloc. in paragraphs
V_WIDTH DB 2    ;Graphics mode translation bytes.  Set by VDG
V_DIV   DB 12
V_HEIGHT DW 960
V_TOP   DW 400H ;Top and bottom RAM address of current active video screen
V_BOTTOM DW 600H
CHARSET DW FONT
NEW_DIV DB 12
NEWSET  DW FONT
NEW_WIDTH DB 2

CHANDLE DW -1   ;Handle for virtual cassette file

MEMTYPE DB 0    ;Memory dump type: 0=explicit, 1=PC, 2=X, 3=Y, 4=U, 5=S, 6=DP,
                ;                  7=A/B
DISTYPE DB 1    ;Disassembly type: 1=PC, 2=X, 3=Y, 4=U, 5=S, 6=DP, 7=A/B, 
                ;                  8=explicit
MEMADR  DW 0    ;Explicit address for memory dump
DISADR  DW 0    ;Explicit address for disassembly
SBMASK  DB 1    ;1=no SoundBlaster, 3=SoundBlaster found

;Emulation data -- to be saved

SNPTOP  EQU $

SNAP_NAME DB 33 DUP(0)
                ;Name of snapshot file
REGPC   DW ?    ;6809 PC register
REGX    DW ?    ;6809 X register
REGY    DW ?    ;6809 Y register
REGU    DW ?    ;6809 U register
REGSP   DW ?    ;6809 S register
        DB 0    ;Filler to make DP a 16-bit address for Mem dump and Disassem
REGDP   DB ?    ;6809 DP register
REGD    DW ?    ;6809 D register (MSB=A, LSB=B)
        DB 6 DUP(0)     ;Reserved for 6309 registers
REGF    DW ?    ;8086 flag registers
REGFI   DB 80   ;6809 flag registers

PAGE_STATUS DB 0D4H     ;0D4H if bank 0=0-7FFF, 0D5H if bank 0=8000-FFFF
ROM_STATUS DB 0DEH      ;0DEH if bank 1=ROM, 0DFH if bank 1=RAM
OLD_DRB1 DB -1  ;Last setting of DRB1, used in snapshot restore
OLD_CRB1 DB 4   ;Last setting of CRB1, used in snapshot restore
OLD_DRB2 DB 0   ;Last setting of DRB2
NEW_TOP DW 400H ;As V_*
NEW_BOTTOM DW 600H
ORIGINAL_CURSOR DW 15

;This data stored in DRIVES.CFG

CFG1TOP EQU $
WR_PROT DB 0    ;Bit n set => drive n write protected
VIR_DIR DB 66 DUP(?)
                ;Last directory viewed by virtual disk menu
PATHS   DB 0,31 DUP(?),0,31 DUP(?),0,31 DUP(?),0,31 DUP(?)
                ;Virtual disk paths for drives 0 through 3
CFG1END EQU $

;This data stored in GENERAL.CFG

CFG2TOP EQU $
SNAP_PATH DB 66 DUP(?)
ADDLF   DB -1   ;0=No LFs added after CRs, -1=add LFs after CRs, 80H=disabled
KEY_MODE DB 0   ;Specify PC (0), CoCo (1) or Custom (2) layout
DELAY   DW 0    ;Delay loop counter.  0=no delay
LJOYSTK DB 0    ;Left joystick: 0=mouse, 2=left game port, 4=right, 6=none
RJOYSTK DB 6    ;Right joystick input
LOWERCASE DW 0  ;0=Inverse font, 6400=lowercase font
SOUND   DB 1    ;Bit 0 set=sound on, bit 1 set=SoundBlaster
ARTIFACT DB 0   ;0=no artifacting, 1=blue edge, 2=red edge
DRAGON  DB 0    ;0=CoCo keyboard, -1=Dragon keyboard
LCALIB  DW 0    ;Base to subtract from left joystick calibration (H)
        DW 0    ;(V)
        DW 1    ;Division factor for left scaling (H)
        DW 1    ;(V)
RCALIB  DW 0    ;Same for right joystick
        DW 0
        DW 1
        DW 1
CLOCK_PERIOD DW 4DA7H   ;Timer counts for clock (4DA7H=60Hz, 5D2FH=50Hz)
DOUBLE_STEP DB 1        ;1.2Mb track step (0=single, 1=double)
VOLUME  DB 0    ;Volume setting
CASMODE DB 0    ;0=cassette playback, -1=cassette record
CAS_DIR DB 66 DUP(?)
CAS_NAME DB 33 DUP(0)
                ;Name of last opened virtual cassette
CFG2END EQU $

SNPEND  EQU $

PROG    ENDS
        END START
