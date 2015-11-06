        TITLE Keyboard customizer supplemental module for CoCo 2 Emulator
        ;Copyright (C) 1993 Jeff Vavasour

        ASSUME CS:CUST_SEG,DS:CUST_SEG

        EXTRN FRAME:BYTE,NAMES:BYTE,COORDS:BYTE,USED:BYTE,COORDS_END:BYTE

        PUBLIC CUSTOMIZER_MENU

CUST_SEG SEGMENT PUBLIC 'B1_MENU'

KEY_LIST EQU 32772              ;PC keyboard layout
ALT_LIST EQU 32968              ;CoCo keyboard layout
CUSTOM_LIST EQU 33164           ;Custom keyboard layout

        JMP CUSTOMIZER_MENU ;Branch for CALL FAR

;Data work area

PAGE_TOP DB 0           ;Offset within table of top key shown on list
LINE_OFF DB 0           ;Current line highlighted
SCANCODE DB 1           ;Current scancode highlighted
MSG1    DB '      '
MSG2    DB 'SHIFT+'
MSG3    DB 'Use up/down arrows to select a PC key from the list on the right, then use',13
        DB 'the function keys to modify its binding.  ESC returns to normal emulation.',13
MSG6    DB 'Modify unSHIFTed binding.  Select TRS-80 key using arrows.  ENTER to accept or',13
        DB 'ESC to abort.  Press "S" to toggle the TRS-80',39,'s SHIFT key for this binding.',13
MSG7    DB 'Modify SHIFTed binding.  Select TRS-80 key using arrows.  ENTER to accept or',13
        DB 'ESC to abort.  Press "S" to toggle the TRS-80',39,'s SHIFT key for this binding.',13
ADDRESS DW CUSTOM_LIST  ;Location of binding being modified by SELECT
OLDCODE DB -1           ;Original setting of SCANCODE before modification
MSG8    DB 'Use preprogrammed layout.  Press "T" to use the "TRS-80" layout, "P" to use the',13
        DB '"PC" layout, or any other key to cancel.',13

;Macros

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

;Subroutines

;Display list of PC keys starting with PAGE_TOP in white

PC_LIST PROC NEAR
        MOV DI,924              ;Video offset of first row in PC key list
        MOV AL,17
        MUL PAGE_TOP
        MOV DL,AL
PC_LIST0:        
        PUSH DI
        MOV SI,OFFSET NAMES
        MOV BX,OFFSET USED
        MOV AL,DL
        XLAT
PC_LIST1:                       ;Locate scancode name in list
        DEC AL
        JZ PC_LIST3
PC_LIST2:
        INC SI
        CMP BYTE PTR [SI-1],0
        JNZ PC_LIST2
        JMP PC_LIST1
PC_LIST3:                       ;Display name
        LODSB
        MOV AH,7
        OR AL,AL
        JZ PC_LIST8
        STOSW
        JMP PC_LIST3
PC_LIST8:                       ;Clear to righthand border
        CMP BYTE PTR ES:[DI],186
        JZ PC_LIST9
        MOV AX,0720H
        STOSW
        JMP PC_LIST8
PC_LIST9:                       ;Position to start of next line
        POP DI
        INC DL
        ADD DI,160
        CMP DI,3520
        JB PC_LIST0
        RET
PC_LIST ENDP

;Highlight LINE_OFF in PC key list, where SCANCODE is the appropriate key

HILITE  PROC NEAR
        MOV SI,OFFSET NAMES
        MOV CL,SCANCODE
        MOV CH,0
        LOOP HILITE1
        JMP HILITE2
HILITE1:
        INC SI
        CMP BYTE PTR [SI-1],0
        JNZ HILITE1
        LOOP HILITE1
HILITE2:
        MOV AL,160
        MUL LINE_OFF
        ADD AX,922
        MOV DI,AX
        PUSH DI
        MOV AX,0E10H
        STOSW
HILITE4:
        LODSB
        OR AL,AL
        JZ HILITE5
        STOSW
        JMP HILITE4
HILITE5:
        POP DI
        ADD DI,34
        MOV AL,17
        STOSW
        RET
HILITE  ENDP

;Restore LINE_OFF colour in PC key list, where SCANCODE is the appropriate key

RESTORE PROC NEAR
        MOV SI,OFFSET NAMES
        MOV CL,SCANCODE
        MOV CH,0
        LOOP RESTORE1
        JMP RESTORE2
RESTORE1:
        INC SI
        CMP BYTE PTR [SI-1],0
        JNZ RESTORE1
        LOOP RESTORE1
RESTORE2:
        MOV AL,160
        MUL LINE_OFF
        ADD AX,922
        MOV DI,AX
        PUSH DI
        MOV AX,0720H
        STOSW
RESTORE4:
        LODSB
        OR AL,AL
        JZ RESTORE5
        STOSW
        JMP RESTORE4
RESTORE5:
        POP DI
        ADD DI,34
        MOV AL,32
        STOSW
        RET
RESTORE ENDP

;Find matrix coordinate in TRS-80 key list

FIND_KEY PROC NEAR
        AND AL,127
        MOV DI,OFFSET COORDS
FIND_KEY1:
        CMP BYTE PTR [DI],0
        JZ FIND_KEY3            ;Not in list!
        CMP AL,[DI+6]
        JZ FIND_KEY2
        ADD DI,7
        JMP FIND_KEY1
FIND_KEY2:
        CLC
        RET
FIND_KEY3:
        STC
        RET
FIND_KEY ENDP

;Highlight binding keys on TRS-80 keyboard and update [F1] and [F2] messages

BINDING PROC NEAR
        MOV AL,2                ;Get binding codes
        MUL SCANCODE
        ADD AX,CUSTOM_LIST-2
        MOV DI,AX
        MOV AX,SS:[DI]          ;Get bindings
        PUSH AX
        CALL FIND_KEY           ;Find unSHIFTed key in TRS-80 coordinate list
        MOV BL,[DI]             ;Calculate video offset from coordinates
        MOV BH,0
        ADD BL,BL
        MOV AL,160
        MUL BYTE PTR [DI+1]
        ADD BX,AX
        INC BX
        MOV CL,[DI+2]
        MOV CH,0
BINDING1:                       ;Set to white-on-green
        OR BYTE PTR ES:[BX],2FH
        ADD BX,2
        LOOP BINDING1
        MOV AH,2FH              ;Put symbol next to [F1] line
        MOV SI,DI
        ADD SI,3
        MOV DI,2902
        LODSB
        STOSW
        LODSB
        STOSW
        LODSB
        STOSW
        POP AX
        PUSH AX
        MOV CX,6
        TEST AL,128             ;Display "SHIFT+" if SHIFT reversed
        MOV DI,2890
        MOV SI,OFFSET MSG1
        JZ BINDING3
        MOV SI,OFFSET MSG2
BINDING3:
        MOV AH,15
        LODSB
        STOSW
        LOOP BINDING3
        POP AX
        PUSH AX
        MOV AL,AH               ;Find SHIFTed key and repeat
        CALL FIND_KEY
        MOV BL,[DI]
        MOV BH,0
        ADD BL,BL
        MOV AL,160
        MUL BYTE PTR [DI+1]
        ADD BX,AX
        INC BX
        MOV CL,[DI+2]
        MOV CH,0
BINDING2:                       ;Set to white-on-red
        OR BYTE PTR ES:[BX],4FH
        ADD BX,2
        LOOP BINDING2
        MOV AH,4FH              ;Put symbol next to [F2] line
        MOV SI,DI
        ADD SI,3
        MOV DI,3062
        LODSB
        STOSW
        LODSB
        STOSW
        LODSB
        STOSW
        POP AX
        MOV CX,6
        TEST AH,128             ;Display "SHIFT+" if SHIFT not reversed
        MOV DI,3050
        MOV SI,OFFSET MSG1
        JNZ BINDING4
        MOV SI,OFFSET MSG2
BINDING4:
        MOV AH,15
        LODSB
        STOSW
        LOOP BINDING4
        RET
BINDING ENDP

;Restore binding keys on TRS-80 keyboard to colour 7

UNBIND  PROC NEAR
        MOV AL,2                ;Get binding codes
        MUL SCANCODE
        ADD AX,CUSTOM_LIST-2
        MOV DI,AX
        MOV AX,SS:[DI]
        PUSH AX
        CALL FIND_KEY           ;Find unSHIFTed key in TRS-80 coordinate list
        MOV BL,[DI]             ;Calculate video offset from coordinates
        MOV BH,0
        ADD BL,BL
        MOV AL,160
        MUL BYTE PTR [DI+1]
        ADD BX,AX
        INC BX
        MOV CL,[DI+2]
        MOV CH,0
UNBIND1:
        MOV BYTE PTR ES:[BX],7
        ADD BX,2
        LOOP UNBIND1
        POP AX
        MOV AL,AH               ;Find SHIFTed key and repeat
        CALL FIND_KEY
        MOV BL,[DI]
        MOV BH,0
        ADD BL,BL
        MOV AL,160
        MUL BYTE PTR [DI+1]
        ADD BX,AX
        INC BX
        MOV CL,[DI+2]
        MOV CH,0
UNBIND2:
        MOV BYTE PTR ES:[BX],7
        ADD BX,2
        LOOP UNBIND2 
        RET
UNBIND  ENDP

;Display a message on the message lines

DISPLAY PROC NEAR
        MOV DI,3680
        MOV AH,14
        MOV CX,80
DISPLAY1:
        LODSB
        CMP AL,13
        JZ DISPLAY2
        STOSW
        LOOP DISPLAY1
        JMP DISPLAY3
DISPLAY2:
        MOV AL,32
        REP STOSW
DISPLAY3:        
        MOV CX,80
        CMP DI,4000
        JB DISPLAY1
        RET
DISPLAY ENDP

;Move back to next available scan code

PREV_LINE PROC NEAR
        MOV AL,SCANCODE
        DEC AL
        JNZ PREV1
        RET
PREV1:  SUB LINE_OFF,1
        JNB PREV2
        MOV LINE_OFF,16
        DEC PAGE_TOP
PREV2:  MOV AL,17
        MUL PAGE_TOP
        ADD AL,LINE_OFF
        MOV BX,OFFSET USED
        XLAT
        MOV SCANCODE,AL
        RET
PREV_LINE ENDP

;Move ahead to next available scan code

NEXT_LINE PROC NEAR
        MOV AL,SCANCODE
        CMP AL,62H
        JB NEXT1
        RET
NEXT1:  INC LINE_OFF
        CMP LINE_OFF,17
        JB NEXT2
        MOV LINE_OFF,0
        INC PAGE_TOP
NEXT2:  MOV AL,17
        MUL PAGE_TOP
        ADD AL,LINE_OFF
        MOV BX,OFFSET USED
        XLAT
        MOV SCANCODE,AL
        RET
NEXT_LINE ENDP

;Select a new TRS-80 binding.  BX=0 if unSHIFTed, BX=1 if SHIFTed.
;DI=coordinate of [Fx] function key marker.  SI=help message.

SELECT  PROC NEAR
        PUSH DI
        PUSH BX
        MOV AL,14
        STOSB
        INC DI
        STOSB
        INC DI
        STOSB
        INC DI
        STOSB
        CALL DISPLAY
        CSRON
        MOV AL,2
        MUL SCANCODE
        ADD AX,CUSTOM_LIST-2
        MOV DI,AX
        POP BX
        PUSH BX
        ADD DI,BX
        MOV ADDRESS,DI  ;Save address being modified
        MOV AL,SS:[DI]
        MOV OLDCODE,AL  ;Save original code in case of abort
SELECT1:
        MOV DI,ADDRESS  ;Position cursor - first need TRS-80 matrix address
        MOV AL,SS:[DI]
        AND AL,127
        MOV DI,OFFSET COORDS
SELECT2:
        CMP BYTE PTR [DI],0
        JZ SELECT3      ;Not in list!
        CMP AL,[DI+6]
        JZ SELECT3
        ADD DI,7
        JMP SELECT2
SELECT3:
        MOV DX,[DI]
        MOV BH,0
        MOV AH,2
        INT 10H
SELECT3A:        
        KEYSTROKE       ;Wait for keystroke
        CMP AL,13       ;ENTER=exit
        JZ SELECT4
        CMP AL,27
        JNZ SELECT5
        CALL UNBIND     ;ESC=abort, restore old code
        MOV AL,OLDCODE
        MOV DI,ADDRESS
        MOV SS:[DI],AL
        CALL BINDING
SELECT4:
        POP BX
        POP DI
        MOV AL,11
        STOSB
        INC DI
        STOSB
        INC DI
        STOSB
        INC DI
        STOSB
        CSROFF
        MOV SI,OFFSET MSG3
        CALL DISPLAY
        RET
SELECT5:
        MOV DX,[DI]             ;Retrieve current cursor position
        CMP AX,4B00H            ;Left arrow=previous key
        JNZ SELECT6
        CMP DI,OFFSET COORDS
        JA SELECT5A             ;Wrap around if needed
        MOV DI,OFFSET COORDS_END
SELECT5A:
        MOV AL,[DI-1]
SELECT5B:
        PUSH AX
        CALL UNBIND
        MOV DI,ADDRESS
        POP AX
        AND BYTE PTR SS:[DI],128
        OR SS:[DI],AL
        CALL BINDING
        JMP SELECT1
SELECT6:
        CMP AX,4D00H            ;Right arrow=next key
        JNZ SELECT7
        ADD DI,7
        CMP DI,OFFSET COORDS_END
        JB SELECT6A             ;Wrap around if needed
        MOV DI,OFFSET COORDS
SELECT6A:
        MOV AL,[DI+6]
        JMP SELECT5B
SELECT7:
        CMP AX,4800H            ;Up arrow=previous row
        JNZ SELECT8
        MOV DX,[DI]
SELECT7A:                       ;Scan back until previous line found
        SUB DI,7
        CMP DI,OFFSET COORDS
        JA SELECT7B
        MOV DI,OFFSET COORDS_END-7
SELECT7B:
        CMP DH,[DI+1]
        JZ SELECT7A
        MOV DH,[DI+1]
SELECT7C:
        CMP DL,[DI]             ;Is the current column too far right?
        MOV AL,[DI+6]
        JNB SELECT5B            ;If so, use last column in line
        CMP DI,OFFSET COORDS    ;If at upper left, can't go any further left
        JZ SELECT5B
        CMP DH,[DI-6]           ;If at left of any line, same thing
        JNZ SELECT5B
        SUB DI,7                ;Otherwise move left
        JMP SELECT7C
SELECT8:
        CMP AX,5000H            ;Down arrow=next row
        JNZ SELECT9
        MOV DX,[DI]
SELECT8A:                       ;Scan forward until next line found
        ADD DI,7
        CMP DI,OFFSET COORDS_END
        JB SELECT8B
        MOV DI,OFFSET COORDS
SELECT8B:
        CMP DH,[DI+1]
        JZ SELECT8A
        MOV DH,[DI+1]
SELECT8C:        
        CMP DL,[DI]             ;Is the current column too far left?
        MOV AL,[DI+6]           
        JNA SELECT8D            ;If so, use first column in line
        CMP DI,OFFSET COORDS_END-7
        JZ SELECT8D             ;If at lower right, can't go any further right
        CMP DH,[DI+8]           ;If at right of any line, same thing
        JNZ SELECT8D
        CMP DL,[DI+7]           ;If next one is too far right, use this one
        JB SELECT8D
        ADD DI,7
        JMP SELECT8C
SELECT8D:
        JMP SELECT5B
SELECT9:                        ;"S"=Toggle TRS-80 SHIFT key
        AND AL,223
        CMP AL,'S'
        JNZ SELECT10
        CALL UNBIND
        MOV DI,ADDRESS
        XOR BYTE PTR SS:[DI],128
        CALL BINDING
        JMP SELECT1
SELECT10:
        JMP SELECT3A
SELECT  ENDP

;Menu to customize keyboard layout

CUSTOMIZER_MENU:
        PUSH CS
        POP DS
        MOV AX,3                ;Clear screen and display menu
        INT 10H
        CSROFF
        MOV AX,0B800H
        MOV ES,AX
        MOV SI,OFFSET FRAME
        MOV DI,0
        MOV CX,4000
        REP MOVSB
        CALL PC_LIST            ;Display current page of PC key list
        CALL HILITE             ;Highlight currently select PC key
        CALL BINDING            ;Display TRS-80 bindings
MENU0:  MOV SI,OFFSET MSG3
        CALL DISPLAY
MENU1:  KEYSTROKE               ;Wait for keystroke
        CMP AL,27               ;ESC exits
        JNZ MENU2
        RETF
MENU2:  CMP AX,4800H            ;Up arrow=move up through scancode list
        JNZ MENU4
        CALL UNBIND
        CALL RESTORE
        MOV AL,PAGE_TOP
        PUSH AX
        CALL PREV_LINE
        POP AX
        CMP AL,PAGE_TOP
        JZ MENU3A
        CALL PC_LIST
MENU3A: CALL HILITE
        CALL BINDING
        JMP MENU1
MENU4:  CMP AX,5000H            ;Down arrow=move down through scancode list
        JNZ MENU5
        CALL UNBIND
        CALL RESTORE
        MOV AL,PAGE_TOP
        PUSH AX
        CALL NEXT_LINE
        POP AX
        CMP AL,PAGE_TOP
        JZ MENU4A
        CALL PC_LIST
MENU4A: CALL HILITE
        CALL BINDING
        JMP MENU1
MENU5:  CMP AX,4900H            ;PG UP=scroll back 17 lines
        JNZ MENU6
        CALL UNBIND
        CALL RESTORE
        MOV CX,17
MENU5A: PUSH CX
        CALL PREV_LINE
        POP CX
        LOOP MENU5A
        CALL PC_LIST
        CALL HILITE
        CALL BINDING
        JMP MENU1
MENU6:  CMP AX,5100H            ;PG DN=scroll ahead 17 lines
        JNZ MENU7
        CALL UNBIND
        CALL RESTORE
        MOV CX,17
MENU6A: PUSH CX
        CALL NEXT_LINE
        POP CX
        LOOP MENU6A
        CALL PC_LIST
        CALL HILITE
        CALL BINDING
        JMP MENU1
MENU7:  CMP AX,3B00H            ;F1=Modify unSHIFTed binding
        JNZ MENU8
        MOV BX,0
        MOV DI,2881
        MOV SI,OFFSET MSG6
        CALL SELECT
        JMP MENU1
MENU8:  CMP AX,3C00H            ;F2=Modify SHIFTed binding
        JNZ MENU9
        MOV BX,1
        MOV DI,3041
        MOV SI,OFFSET MSG7
        CALL SELECT
        JMP MENU1
MENU9:  CMP AX,3E00H            ;F4=Reset (use preprogrammed setting)
        JNZ MENU10
        MOV SI,OFFSET MSG8
        CALL DISPLAY
        MOV DI,3361             ;Highlight [F4]
        MOV AL,14
        STOSB
        INC DI
        STOSB
        INC DI
        STOSB
        INC DI
        STOSB
        KEYSTROKE
        PUSH AX
        CALL UNBIND
        POP AX
        AND AL,223
        CMP AL,'P'
        MOV SI,KEY_LIST
        JZ MENU9A
        CMP AL,'T'
        MOV SI,ALT_LIST
        JNZ MENU9B
MENU9A: PUSH DS                 ;Copy standard layout if requested
        PUSH ES
        MOV AX,SS
        MOV DS,AX
        MOV ES,AX
        MOV DI,CUSTOM_LIST
        MOV CX,196
        REP MOVSB
        POP ES
        POP DS
MENU9B: MOV DI,3361             ;Restore [F4] to cyan
        MOV AL,11
        STOSB
        INC DI
        STOSB
        INC DI
        STOSB
        INC DI
        STOSB
        CALL BINDING
        JMP MENU0
MENU10: JMP MENU1

CUST_SEG ENDS

        END


