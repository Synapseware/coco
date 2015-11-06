        TITLE CoCo 3 VGA function checklist
        ;Copyright (C) 1994 Jeff Vavasour

        ASSUME CS:PROG,DS:PROG

PROG    SEGMENT 'CODE'

MSG1    DB 1,10,'COLOUR COMPUTER 3 EMULATOR VGA-FUNCTION CHECKLIST',13,10,1
        DB 10,'袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴'
        DB '袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴',13,10,0
        DB 'The shareware ',1,14,'Colour Computer 3 Emulator',1,7,' '
        DB 'makes use of several special functions',13,10
        DB 'found in most VGA boards.  Rarely, some non-standard '
        DB 'video boards do not support'
        DB 'some of these features.  With this program, you '
        DB 'can test your VGA board before',13,10
        DB 'ordering the ',1,14,'CoCo 3 Emulator',1,7
        DB ', to ensure that all the necessary functions are',13,10
        DB 'supported.',13,10,10
        DB 'The tests consist of seven sample screens.  You will first be '
        DB 'told what you',13,10
        DB 'should see.  After pressing the ',1,11,'SPACE BAR',1,7,', the '
        DB 'sample screen will be shown.  If',13,10
        DB 'the screen does not match the description, the feature being '
        DB 'tested is not',13,10
        DB 'supported by your VGA board.',13,10,10
        DB 'At any time, you may press the ',1,11,'ESC',1,7,' key to abort '
        DB 'testing and return to the DOS',13,10
        DB 'prompt, with your video screen restored to normal.  Use the '
        DB 1,11,'SPACE BAR',1,7,' to step',13,10
        DB 'through each test.',13,10,10,10
        DB 1,9,'Test #1: 192-line mode',1,7,13,10,10
        DB 'The standard CoCo screen has 192 lines.  The next screen should '
        DB 'consist of 12',13,10
        DB 'lines of double-height text.  (That is, each character will be 16 '
        DB 'pixels high.)'
        DB 13,10,10,'Press ',1,11,'SPACE BAR',1,7,' to view the screen. ',0
MSG4    DB 13,10,10,'Press ',1,11,'SPACE BAR',1,7,' to view the next test screen, '
        DB 'or ',1,11,'BACKSPACE',1,7,' to view the previous test screen again. ',0
MSG2    DB 'Testing aborted.',13,10,0
MSG3A   DB 1,10,'旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 '
NUM1A   DB '01 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커',0
MSG3B   DB 1,12,'쳐 TEXT 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 '
NUM1B   DB '02 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 TEXT 캑',0
MSG3C   DB 1,12,'읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 '
NUM1C   DB '12 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸',0
MSG3D   DB 1,10,'컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 '
        DB '25 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴',0
MSG5    DB 'If no text appeared below the red line marked "12" and the test '
        DB 'pattern filled',13,10
        DB 'the screen properly, then test #1 was successful.',13,10,10,10
        DB 1,9,'Test #2: Fractional characters',1,7,13,10,10
        DB 'The previous screen will be displayed again, but the number of '
        DB 'pixel-rows of',13,10
        DB 'each character will decrease until only the top half of each '
        DB 'character is',13,10
        DB 'visible.  At the end of this test, there should be 24 rows '
        DB 'consisting of only',13,10
        DB 'the top half of each character.',0
MSG6    DB 'If you saw 24 lines containing only the top half of the characters, the test',13,10
        DB 'was successful.',13,10,10,10
        DB 1,9,'Test #3: 225-line mode',1,7,13,10,10
        DB 'On the next screen you should see 28 text lines, followed by a solid green line.'
        DB 'The characters on this screen will be double-width.',0
MSG6A   DB '旼컴컴컴컴컴컴컴컴    컴컴컴컴컴컴컴컴커'
MSG6B   DB '쳐 TEXT 컴컴컴컴컴    컴컴컴컴컴 TEXT 캑'
MSG6C   DB '읕컴컴컴컴컴컴컴컴    컴컴컴컴컴컴컴컴켸'
MSG6D   DB '栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢'
MSG6E   DB 'You should not be able to see this line!'
MSG7    DB 'If there were 28 alternating green and red lines followed by a solid green',13,10 
        DB 'line, the test was successful.',13,10,10,10
        DB 1,9,'Test #4: Smooth scroll',1,7,13,10,10
        DB 'The screen from test #1 will be shown again, and smooth-scrolled up one line',13,10
        DB 'and back down repeatedly until you press the ',1,11,'SPACE BAR',1,7,'.  This is a 12-line',13,10  
        DB 'screen, so only one of lines 1 or 13 should be completely visible at either',13,10
        DB 'extreme of the scrolling.',0
MSG8    DB 'If you saw smooth-scrolling, the test was successful.',13,10,10,10
        DB 1,9,'Test #5: Downloadable Fonts',1,7,13,10,10
        DB 'On the next screen, you should see the standard CoCo low-res character set.  The'
        DB 'top quarter should show text characters in green on a black background.  The',13,10
        DB 'next quarter should be the same characters inverted, and the bottom half should '
        DB 'consist of block graphics.',0
MSG9    DB 'If you saw the standard CoCo low-res character set (no lowercase or accented',13,10
        DB 'characters), the test was successful.',13,10,10,10
        DB 1,9,'Test #6: Inter-character spacing',1,7,13,10,10
        DB 'The spacing between characters will be adjusted.  You should see a pattern of',13,10
        DB 'solid blocks of various colours.  There must be ',1,15,'no',1,7,' vertical black lines between',13,10 
        DB 'neighbouring blocks.',0
MSG10   DB 'If you saw a stable picture with ',1,15,'no',1,7,' vertical black lines between blocks, the',13,10
        DB 'test was successful.',13,10,10,10
        DB 1,9,'Test #7: 225-line graphics mode',1,7,13,10,10
        DB 'This final test verifies that the 225-line mode works with graphics.  You should'
        DB 'see a 14-column by 15-row pattern of coloured blocks.  Make sure the number of',13,10
        DB 'rows displayed is correct.',0
MSG0    DB 'If you saw a pattern of coloured blocks consisting of 14 columns and 15 rows,',13,10 
        DB 'the test was successful.',13,10,10,10
        DB 1,9,'Testing complete.',1,7,13,10,10
        DB 'If all test screens appeared as described, your VGA board works as expected and',13,10
        DB 'will be able to handle the ',1,14,'CoCo 3 Emulator',1,7,'.',13,10,10
        DB 'If any of these tests failed, but you still wish to obtain a copy of the ',1,14,'CoCo 3',13,10
        DB 'Emulator',1,7,', please contact me first with the number(s) of the failed test(s), the',13,10
        DB 'problem experienced, and the type of VGA board you are using, if known.  See the' 
        DB 'COCO.DOC file for my e-mail and/or postal address.',13,10,10
        DB 1,9,'- Jeff Vavasour',13,10,10,1,7
        DB 'Press ',1,11,'SPACE BAR',1,7,' to exit, or ',1,11,'BACKSPACE',1,7,' to view the last test screen again. ',0

COLOUR_TABLE DB 2,14,1,4,7,3,5,6

FONT12  DB 0,56,68,4,52,76,76,56,0,0,0,0,0,16,40,68,68,124,68,68,0,0,0,0,0,120
        DB 36,36,56,36,36,120,0,0,0,0,0,56,68,64,64,64,68,56,0,0,0,0,0,120,36
        DB 36,36,36,36,120,0,0,0,0,0,124,64,64,112,64,64,124,0,0,0,0,0,124,64
        DB 64,120,64,64,64,0,0,0,0,0,60,64,64,76,68,68,60,0,0,0,0,0,68,68,68
        DB 124,68,68,68,0,0,0,0,0,56,16,16,16,16,16,56,0,0,0,0,0,4,4,4,4,68
        DB 68,56,0,0,0,0,0,68,72,80,96,80,72,68,0,0,0,0,0,64,64,64,64,64,64
        DB 124,0,0,0,0,0,68,108,124,84,68,68,68,0,0,0,0,0,68,68,100,84,76,68
        DB 68,0,0,0,0,0,56,68,68,68,68,68,56,0,0,0,0,0,120,68,68,120,64,64,64
        DB 0,0,0,0,0,56,68,68,68,84,72,52,0,0,0,0,0,120,68,68,120,80,72,68,0
        DB 0,0,0,0,56,68,32,16,8,68,56,0,0,0,0,0,124,16,16,16,16,16,16,0,0,0
        DB 0,0,68,68,68,68,68,68,56,0,0,0,0,0,68,68,68,40,40,16,16,0,0,0,0,0
        DB 68,68,68,84,124,108,68,0,0,0,0,0,68,68,40,16,40,68,68,0,0,0,0,0,68
        DB 68,40,16,16,16,16,0,0,0,0,0,124,4,8,16,32,64,124,0,0,0,0,0,56,32
        DB 32,32,32,32,56,0,0,0,0,0,0,64,32,16,8,4,0,0,0,0,0,0,56,8,8,8,8,8
        DB 56,0,0,0,0,0,16,56,84,16,16,16,16,0,0,0,0,0,0,16,32,124,32,16,0,0
        DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,16,16,16,16,16,0,16,0,0,0,0,0,40
        DB 40,0,0,0,0,0,0,0,0,0,0,40,40,124,40,124,40,40,0,0,0,0,0,16,60,64
        DB 56,4,120,16,0,0,0,0,0,100,100,8,16,32,76,76,0,0,0,0,0,32,80,80,32
        DB 84,72,52,0,0,0,0,0,16,16,0,0,0,0,0,0,0,0,0,0,8,16,32,32,32,16,8,0
        DB 0,0,0,0,32,16,8,8,8,16,32,0,0,0,0,0,16,84,56,124,56,84,16,0,0,0,0
        DB 0,0,16,16,124,16,16,0,0,0,0,0,0,0,0,0,0,48,48,16,32,0,0,0,0,0,0,0
        DB 124,0,0,0,0,0,0,0,0,0,0,0,0,0,48,48,0,0,0,0,0,0,4,8,16,32,64,0,0
        DB 0,0,0,0,56,68,76,84,100,68,56,0,0,0,0,0,16,48,16,16,16,16,56,0,0
        DB 0,0,0,56,68,4,56,64,64,124,0,0,0,0,0,56,68,4,56,4,68,56,0,0,0,0,0
        DB 8,24,40,124,8,8,8,0,0,0,0,0,124,64,120,4,4,68,56,0,0,0,0,0,56,64
        DB 64,120,68,68,56,0,0,0,0,0,124,4,8,16,32,64,64,0,0,0,0,0,56,68,68
        DB 56,68,68,56,0,0,0,0,0,56,68,68,60,4,4,56,0,0,0,0,0,0,48,48,0,48,48
        DB 0,0,0,0,0,0,0,48,48,0,48,48,16,32,0,0,0,0,4,8,16,32,16,8,4,0,0,0
        DB 0,0,0,0,124,0,124,0,0,0,0,0,0,0,32,16,8,4,8,16,32,0,0,0,0,0,56,68
        DB 4,8,16,0,16,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,15,15,15
        DB 15,15,15,0,0,0,0,0,0,240,240,240,240,240,240,0,0,0,0,0,0,255,255
        DB 255,255,255,255,15,15,15,15,15,15,0,0,0,0,0,0,15,15,15,15,15,15,15
        DB 15,15,15,15,15,15,15,15,15,15,15,240,240,240,240,240,240,15,15,15
        DB 15,15,15,255,255,255,255,255,255,240,240,240,240,240,240,0,0,0,0
        DB 0,0,240,240,240,240,240,240,15,15,15,15,15,15,240,240,240,240,240
        DB 240,240,240,240,240,240,240,240,240,240,240,240,240,255,255,255,255
        DB 255,255,255,255,255,255,255,255,0,0,0,0,0,0,255,255,255,255,255,255
        DB 15,15,15,15,15,15,255,255,255,255,255,255,240,240,240,240,240,240
        DB 255,255,255,255,255,255,255,255,255,255,255,255

CLS     PROC NEAR
        MOV AX,3
        INT 10H
        RET
CLS     ENDP

LOWRES  PROC NEAR        
        MOV AX,1
        INT 10H
        MOV DX,3D4H
        MOV AX,9410H
        OUT DX,AX
        MOV AX,7F12H
        OUT DX,AX
        MOV AX,8E15H
        OUT DX,AX
        MOV AX,0CB09H
        OUT DX,AX
        MOV AX,1100H
        MOV BX,0C00H
        MOV CX,128
        MOV DX,64
        MOV BP,OFFSET FONT12
        PUSH DS
        POP ES
        INT 10H
        MOV AX,0B800H
        MOV ES,AX
        RET
LOWRES  ENDP

DISPLAY PROC NEAR
        MOV BX,7
DISPLAY1:
        LODSB
        DEC AL
        JNZ DISPLAY2
        LODSB
        MOV BL,AL
        JMP DISPLAY1
DISPLAY2:
        INC AL
        JZ DISPLAY3
        CMP AL,32
        JB DISPLAY4
        PUSH AX
        MOV AH,3
        INT 10H
        POP AX
        MOV AH,9
        MOV CX,1
        INT 10H
        MOV AH,2
        INC DL
        CMP DL,80
        JB DISPLAY5
        MOV DL,0
        INC DH
        CMP DH,25
        JB DISPLAY5
        MOV DH,0
DISPLAY5:
        INT 10H
        JMP DISPLAY1
DISPLAY3:
        RET
DISPLAY4:
        MOV AH,14
        INT 10H
        JMP DISPLAY1
DISPLAY ENDP

KEYSCAN PROC NEAR
        MOV AH,1
        INT 16H
        JZ KEYSCAN1
        MOV AH,0
        INT 16H
        CMP AL,27
        JZ KEYSCAN2
        CMP AL,8
        JZ KEYSCAN0
        CMP AL,32
        JNZ KEYSCAN1
        OR AL,AL
KEYSCAN0:
        STC
        RET
KEYSCAN1:
        CLC
        RET
KEYSCAN2:
        CALL CLS
        MOV SI,OFFSET MSG1
        CALL DISPLAY
        MOV SI,OFFSET MSG2
        CALL DISPLAY
        MOV AX,4C00H
        INT 21H
KEYSCAN ENDP

KEYWAIT PROC NEAR
        CALL KEYSCAN
        JNB KEYWAIT
        RET
KEYWAIT ENDP

SPACEWAIT PROC NEAR
        CALL KEYSCAN
        JNB SPACEWAIT
        JZ SPACEWAIT
        RET
SPACEWAIT ENDP

TEXT    PROC NEAR
        MOV WORD PTR NUM1A,3130H
        MOV WORD PTR NUM1B,3230H
        MOV WORD PTR NUM1C,3231H
TEST1B: MOV SI,OFFSET MSG3A
        CALL DISPLAY
        MOV CX,10
TEST1D: MOV SI,OFFSET MSG3B
        PUSH CX
        CALL DISPLAY
        POP CX
        XOR MSG3B[1],6
        INC NUM1B[1]
        CMP NUM1B[1],3AH
        JB TEST1A
        INC NUM1B
        MOV NUM1B[1],30H
TEST1A: LOOP TEST1D
        MOV SI,OFFSET MSG3C
        CALL DISPLAY
        CMP NUM1A,'0'
        JNZ TEST1C
        MOV WORD PTR NUM1A,3331H
        MOV WORD PTR NUM1B,3431H
        MOV WORD PTR NUM1C,3432H
        JMP TEST1B
TEST1C: MOV SI,OFFSET MSG3D
        CALL DISPLAY
        RET
TEXT    ENDP

TEXT40  PROC NEAR
        MOV AX,0B800H
        MOV ES,AX
        MOV BX,3130H
        MOV SI,OFFSET MSG6A
        MOV AH,10
        MOV DI,0
TEXT40A:
        MOV CX,40
TEXT40B:
        LODSB
        STOSW
        LOOP TEXT40B
        CMP BX,3932H
        JZ TEXT40C
        MOV ES:[DI-42],BL
        MOV ES:[DI-40],BH
        INC BH
        CMP BH,3AH
        JB TEXT40C
        MOV BH,30H
        INC BL
TEXT40C:
        XOR AH,6
        CMP DI,2160
        JNB TEXT40D
        MOV SI,OFFSET MSG6B
TEXT40D:
        CMP DI,2320
        JB TEXT40A
        RET
TEXT40  ENDP

LINES225 PROC NEAR
        MOV DX,3CCH
        IN AL,DX
        OR AL,192
        MOV DX,3C2H
        OUT DX,AL
        MOV DX,3D4H
        MOV AX,0E11H
        OUT DX,AX
        MOV AX,0B06H
        OUT DX,AX
        MOV AX,3E07H
        OUT DX,AX
        MOV AX,0EA10H
        OUT DX,AX
        MOV AX,0C112H
        OUT DX,AX
        MOV AX,0E715H
        OUT DX,AX
        MOV AX,0416H
        OUT DX,AX
        MOV AX,8C11H
        OUT DX,AX
        RET
LINES225 ENDP

PAUSE   PROC NEAR
        MOV AX,64
        MOV ES,AX
        MOV BX,ES:[6CH]
PAUSE1:
        MOV AX,ES:[6CH]
        SUB AX,BX
        CMP AX,2
        JB PAUSE1
        RET
PAUSE   ENDP

START:  PUSH CS
        POP DS
        CALL CLS
        MOV SI,OFFSET MSG1
        CALL DISPLAY
        CALL DISPLAY
;Test #1: 192 lines, double-height characters
        CALL SPACEWAIT
TEST1:  CALL CLS
        MOV DX,3D4H
        MOV AX,9410H
        OUT DX,AX
        MOV AX,7F12H
        OUT DX,AX
        MOV AX,8E15H
        OUT DX,AX
        MOV AX,0CF09H
        OUT DX,AX
        CALL TEXT
        CALL SPACEWAIT
;Test #2: reducing character height
        CALL CLS
        MOV SI,OFFSET MSG1
        CALL DISPLAY
        MOV SI,OFFSET MSG5
        CALL DISPLAY
        MOV SI,OFFSET MSG4
        CALL DISPLAY
        CALL KEYWAIT
        JZ TEST1
TEST2:  CALL CLS
        MOV DX,3D4H
        MOV AX,9410H
        OUT DX,AX
        MOV AX,7F12H
        OUT DX,AX
        MOV AX,8E15H
        OUT DX,AX
        MOV AX,0CF09H
        OUT DX,AX
        CALL TEXT
        MOV DX,3D4H
        MOV AX,0CF09H
TEST2A: PUSH AX
        CALL PAUSE
        CALL KEYSCAN
        JNB TEST2B
        JZ TEST2B
        JMP TEST3A
TEST2B: POP AX
        OUT DX,AX
        DEC AH
        CMP AH,0C7H
        JNB TEST2A
        CALL SPACEWAIT
;Test #3: 225-line mode
TEST3A: CALL CLS
        MOV SI,OFFSET MSG1
        CALL DISPLAY
        MOV SI,OFFSET MSG6
        CALL DISPLAY
        MOV SI,OFFSET MSG4
        CALL DISPLAY
        CALL KEYWAIT
        JZ TEST2
TEST3:  MOV AX,1
        INT 10H
        MOV DX,3D4H
        MOV AX,4F09H
        OUT DX,AX
        CALL LINES225
        CALL TEXT40
        CALL SPACEWAIT
;Test #4: Vertical smooth scroll        
        CALL CLS
        MOV SI,OFFSET MSG1
        CALL DISPLAY
        MOV SI,OFFSET MSG7
        CALL DISPLAY
        MOV SI,OFFSET MSG4
        CALL DISPLAY
        CALL KEYWAIT
        JZ TEST3
TEST4:  CALL CLS
        MOV DX,3D4H
        MOV AX,9410H
        OUT DX,AX
        MOV AX,7F12H
        OUT DX,AX
        MOV AX,8E15H
        OUT DX,AX
        MOV AX,0CF09H
        OUT DX,AX
        CALL TEXT
        MOV DX,3D4H
        MOV AX,8
TEST4C: OUT DX,AX
        PUSH AX
        CALL PAUSE
        CALL KEYSCAN
        POP AX
        JNB TEST4D
        JZ TEST4D
        JMP TEST4B
TEST4D: INC AH
        CMP AH,16
        JB TEST4C
        MOV AH,14
TEST4A: OUT DX,AX
        PUSH AX
        CALL PAUSE
        CALL KEYSCAN
        POP AX
        JB TEST4B
        DEC AH
        JNZ TEST4A
        JMP TEST4C
TEST4B: CALL CLS
;Test #5: Downloadable fonts
        MOV SI,OFFSET MSG1
        CALL DISPLAY
        MOV SI,OFFSET MSG8
        CALL DISPLAY
        MOV SI,OFFSET MSG4
        CALL DISPLAY
        CALL KEYWAIT
        JZ TEST4
TEST5:  CALL LOWRES
        MOV DI,8
        MOV AH,2
        MOV AL,64
        MOV BX,0
TEST5D: STOSW
        INC AL
        INC DI
        INC DI
        TEST AL,15
        JNZ TEST5A
        ADD DI,16
TEST5A: CMP AL,128
        JB TEST5D
        CMP DI,640
        JNB TEST5B
        MOV AX,2040H
        JMP TEST5D
TEST5B: MOV AH,COLOUR_TABLE[BX]
        INC BL
        MOV CX,16
        MOV AL,128
TEST5C: STOSW
        INC AL
        INC DI
        INC DI
        LOOP TEST5C
        ADD DI,16
        CMP BL,16
        JB TEST5B
        CALL SPACEWAIT
;Test #6: 8-pixel wide characters        
        CALL CLS
        MOV SI,OFFSET MSG1
        CALL DISPLAY
        MOV SI,OFFSET MSG9
        CALL DISPLAY
        MOV SI,OFFSET MSG4
        CALL DISPLAY
        CALL KEYWAIT
        JZ TEST5
TEST6:  CALL LOWRES
        MOV DX,3C4H
        MOV AL,1
        OUT DX,AL
        INC DX
        IN AL,DX
        OR AL,1
        OUT DX,AL
        MOV DX,3CCH
        IN AL,DX
        AND AL,0F3H
        MOV DX,3C2H
        OUT DX,AL
        MOV DI,0
        MOV CX,1280
        MOV AX,18FH
TEST6A: STOSW
        INC AH
        AND AH,15
        CMP AH,1
        ADC AH,0
        LOOP TEST6A
        CALL SPACEWAIT
;Test #7: 225-line graphics mode
        CALL CLS
        MOV SI,OFFSET MSG1
        CALL DISPLAY
        MOV SI,OFFSET MSG10
        CALL DISPLAY
        MOV SI,OFFSET MSG4
        CALL DISPLAY
        CALL KEYWAIT
        JZ TEST6
TEST7:  MOV AX,14
        INT 10H
        MOV DX,3D4H
        MOV AX,0CE09H
        OUT DX,AX
        CALL LINES225
        MOV AX,0A000H
        MOV ES,AX
        MOV AX,205H
        MOV DX,3CEH
        OUT DX,AX
        MOV SI,0
        MOV AL,1
TEST7B: MOV DI,SI
        ADD DI,5
        MOV CX,14
TEST7A: PUSH CX
        MOV CX,5
        REP STOSB
        INC AL
        AND AL,15
        CMP AL,1
        ADC AL,0
        POP CX
        LOOP TEST7A
        ADD SI,80
        CMP SI,1280
        JB TEST7B
        CALL SPACEWAIT
        CALL CLS
        MOV SI,OFFSET MSG1
        CALL DISPLAY
        MOV SI,OFFSET MSG0
        CALL DISPLAY
        CALL KEYWAIT
        JZ TEST7
        MOV AH,2
        MOV DL,10
        INT 21H
        MOV AX,4C00H
        INT 21H

PROG    ENDS

        END START

