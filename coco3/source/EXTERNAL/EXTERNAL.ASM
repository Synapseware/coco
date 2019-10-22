        TITLE Driver for Disk BASIC's new external access commands        

        ASSUME CS:PROG,DS:PROG

PROG    SEGMENT 'CODE'

        ORG 0

ERROR_MSG DB 'Could not open '
RFILE   DB 'COCO3.ROM',0,13,10,'$'
ROMHANDLE DW 0
ERROR_MSG2 DB 'Could not create backup file, '
BFILE   DB 'COCO3ROM.BAK',0,13,10,'$'
ERROR_MSG3 DB 'COCO3ROM.BAK already exists!  Have you already applied this patch?',13,10,'$'
CSIZE   DW 0
DONE    DB 'COCO3.ROM now incorporates emulator enhancements.',13,10
        DB 'An unmodified backup has been stored in COCO3ROM.BAK.',13,10,'$'

NEW_MSG DB 'DISK EXTENDED COLOR BASIC 2.0',13
        DB 'EMULATOR ENHANCEMENTS 1.1',13
        DB '(C)1981,1986 TANDY. LICENSED',13
        DB 'FROM MICROSOFT & MICROWARE.',13
        DB 13,0
        DB 'DISK EXTENDED COLOR BASIC 2.1',13
        DB 'EMULATOR ENHANCEMENTS 1.1',13
        DB '(C)1981,1986 TANDY. LICENSED',13
        DB 'FROM MICROSOFT & MICROWARE.',13
        DB 13,0
END_NEW_MSG EQU $

INSTALL_ERROR2:
        MOV AH,3EH
        MOV BX,ROMHANDLE
        INT 21H

INSTALL_ERROR:
        MOV AH,9
        INT 21H
        MOV AX,4C01H
        INT 21H

INSTALL:
        MOV AX,CS
        MOV DS,AX
        MOV ES,AX
        MOV AX,3D02H
        MOV DX,OFFSET RFILE
        INT 21H
        MOV DX,OFFSET ERROR_MSG
        MOV ROMHANDLE,AX
        JB INSTALL_ERROR

        MOV AH,3FH
        MOV BX,ROMHANDLE
        MOV CX,8000H
        MOV DX,2000H
        INT 21H
        MOV DX,OFFSET ERROR_MSG
        JB INSTALL_ERROR2

        MOV CSIZE,AX

        MOV AX,3D00H
        MOV DX,OFFSET BFILE
        INT 21H
        MOV DX,OFFSET ERROR_MSG3
        JNB INSTALL_ERROR2

        MOV AH,3CH
        MOV CX,0
        MOV DX,OFFSET BFILE
        INT 21H
        MOV DX,OFFSET ERROR_MSG2
        JB INSTALL_ERROR2

        MOV BX,AX
        MOV AH,40H
        MOV CX,CSIZE
        MOV DX,2000H
        INT 21H
        MOV AH,3EH
        INT 21H

        MOV SI,0C400H
        MOV DI,6402H
        MOV CX,1C00H
        REP MOVSB

        MOV SI,0FC00H
        MOV DI,9C02H
        MOV CX,100H
        REP MOVSB

        MOV SI,OFFSET NEW_MSG
        MOV DI,82A5H
        MOV CX,END_NEW_MSG-OFFSET NEW_MSG
        REP MOVSB

        MOV BYTE PTR DS:[2C28H],0C4H

        MOV AX,4200H
        MOV BX,ROMHANDLE
        MOV CX,0
        MOV DX,0
        INT 21H

        MOV AH,40H
        MOV CX,CSIZE
        MOV DX,2000H
        INT 21H
        MOV AH,3EH
        INT 21H

        MOV AH,9
        MOV DX,OFFSET DONE
        INT 21H

        MOV AX,4C00H
        INT 21H

        ASSUME DS:NOTHING

;Almost PUSHA/POPA, but SI not saved since it must be changed on return

PUSHALL MACRO
        PUSHF
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH DI
        PUSH BP
        ENDM

POPALL  MACRO
        POP BP
        POP DI
        POP DX
        POP CX
        POP BX
        POP AX
        POPF
        ENDM

RET6809 MACRO
        PUSH AX
        MOV AX,ES:[BP]
        XCHG AH,AL
        MOV SI,AX
        POP AX
        INC BP
        INC BP
        ENDM

RAMBANK MACRO REG
        PUSH AX
        MOV AX,CS
        ADD AX,2800H
        MOV REG,AX
        POP AX
        ENDM

OPCODE  MACRO VALUE,BRANCH
        MOV BYTE PTR CS:XMODE,0
        PUSH BX
        MOV BX,DS:[0A6H]
        XCHG BH,BL
        MOV BL,[BX-1]
        CMP BL,VALUE
        POP BX
        JNZ BRANCH
        CMP DH,'X'
        JNZ BRANCH
        ENDM

;Set load address

        ORG 0C400H

        DB 0CCH,'JV',0FDH,0FFH,86H

;Patch ROM vectors as required

        DW 0FF11H

        MOV AX,CS
        ADD AX,800H
        MOV ES,AX

        MOV AL,0C0H             ;Restore ROM
        MOV CS:[08C26H],AL

        MOV AX,OFFSET LOAD_CHECK_VECTOR;Patches for the LOAD command
        XCHG AH,AL
        MOV ES:[0C1FBH],AX
        MOV AX,OFFSET LOAD_OPEN_VECTOR
        XCHG AH,AL
        MOV ES:[0CA10H],AX
        MOV AX,OFFSET LOAD_CLOSE_VECTOR
        XCHG AH,AL
        MOV CS:[0A42EH],AX
        MOV BYTE PTR ES:[0C5C4H],7EH
        MOV AX,OFFSET LOAD_READ_VECTOR
        XCHG AH,AL
        MOV ES:[0C5C5H],AX

        MOV AX,OFFSET RUN_CHECK_VECTOR-0CA44H;Patch for the RUN command
        XCHG AH,AL
        MOV ES:[0CA42H],AX

        MOV AX,OFFSET DOS_CHECK_VECTOR ;Patch for DOS command
        XCHG AH,AL
        MOV ES:[0C217H],AX
        
        MOV AX,OFFSET COCO_ERROR_VECTOR;Patch to ensure everything reset if aborted
        XCHG AH,AL              ;by an error
        MOV CS:[0AC47H],AX

        MOV AX,OFFSET SAVE_WRITE_VECTOR;Additional patches for SAVE command
        XCHG AH,AL
        MOV ES:[0CC25H],AX
        MOV BYTE PTR ES:[0CC24H],7EH
        MOV AX,OFFSET SAVE_CHECK_VECTOR
        XCHG AH,AL
        MOV ES:[0C205H],AX

        MOV AX,OFFSET DIR_CHECK_VECTOR ;Patch to DIR command
        XCHG AH,AL
        MOV ES:[0C1F1H],AX

        MOV AX,OFFSET DRIVE_CHECK_VECTOR ;Patch to DRIVE command
        XCHG AH,AL
        MOV ES:[0C1F3H],AX

        MOV AX,OFFSET KILL_CHECK_VECTOR;Patch to KILL command
        XCHG AH,AL
        MOV ES:[0C1F9H],AX
        MOV AX,OFFSET KILL_FILE_VECTOR
        XCHG AH,AL
        MOV ES:[0C6F6H],AX

        MOV BYTE PTR CS:[0AC60H],7EH;Improve the error messages
        MOV AX,OFFSET ERROR_TEXT_VECTOR
        XCHG AH,AL
        MOV WORD PTR CS:[0AC61H],AX

        MOV BYTE PTR CS:[0E492H],7EH
        MOV WORD PTR CS:[0E493H],60ACH
        MOV BYTE PTR CS:[0E4A9H],7EH
        MOV WORD PTR CS:[0E4AAH],60ACH

        MOV AX,1212H            ;Remove the drive spinup delay
        MOV ES:[0D78CH],AX
        MOV ES:[0D78EH],AX
        MOV ES:[0D790H],AX

        MOV SI,0C000H
        RETF

;Entry to RUN command.  Checks for "X"

RUN_CHECK:
;        CMP BYTE PTR CS:XMODE,1
;        JZ NOT_RUNX             ;Been here before?  Then we don't have a RUNX
        PUSH AX
        MOV AX,OFFSET COCO_ERROR_VECTOR;Patch to ensure everything reset if aborted
        XCHG AH,AL              ;by an error
        MOV ES:[0AC47H],AX
        POP AX
        OPCODE 8EH,NOT_RUNX
        INC BYTE PTR CS:XMODE
        SUB BP,2
;        MOV DS:[BP],3ECAH       ;Put RUN entry back on stack
        MOV word ptr DS:[BP],44CAH       ;Put RUN entry back on stack
        MOV SI,9FH              ;and jump to "next byte" routine
        RETF
NOT_RUNX:
        MOV SI,829CH            ;Jump to LOAD routine
        RETF

;Entry to LOAD command.  Checks for "X"

LOAD_CHECK:
        PUSH AX
        MOV AX,OFFSET COCO_ERROR_VECTOR;Patch to ensure everything reset if aborted
        XCHG AH,AL              ;by an error
        MOV ES:[0AC47H],AX
        POP AX
        MOV BYTE PTR CS:XMODE,0
        OPCODE 0D3H,NOT_LOADX
        INC BYTE PTR CS:XMODE
        SUB BP,2
        MOV word ptr DS:[BP],48CAH       ;Put LOAD entry on stack
        MOV SI,9FH              ;and jump to "next byte" routine
        RETF
NOT_LOADX:
        MOV SI,0CA48H           ;Jump to LOAD routine
        RETF

XMODE   DB 0                    ;0=normal operation, 1=LOADX, 2=SAVEX
FSPEC   DB 13 DUP(0)            ;Storage of MS-DOS style ASCIIZ filename
HANDLE  DW 0                    ;Handle of open file
BYTE_READ DB 0                  ;Last byte read from file

;File open intercept for LOAD command

LOAD_OPEN:
        CMP CS:XMODE,1
        JZ LOADX_OPEN
        CMP CS:XMODE,2
        JZ SAVEX_OPEN_A
        MOV SI,0C48DH           ;Go to C48D if following normal procedure
        RETF
SAVEX_OPEN_A:
        JMP SAVEX_OPEN
LOADX_OPEN:
        PUSHALL
        CALL CLOSE_OLD
        CALL PARSE_FILE
        MOV AX,CS
        MOV DS,AX
        MOV AX,3D00H
        MOV DX,OFFSET FSPEC
        INT 21H
        JNB NO_ERROR
ERROR:  MOV BX,CS
        MOV DS,BX
        MOV BX,OFFSET ERROR_XLAT
        XLAT
        MOV BP,SP
        MOV [BP+4],AL           ;Set 6809 B register to CoCo's error #
        MOV SI,0AC46H           ;BASIC's error branch
        POPALL
        RETF
NO_ERROR:                       ;Set file found flag
        MOV BYTE PTR ES:[973H],-1
        MOV CS:HANDLE,AX
        MOV BX,AX
        MOV AH,3FH
        MOV CX,1
        INT 21H
        MOV CS:FSPEC[1],-1      ;Set flag indicating byte already loaded
        MOV BL,ES:[6FH]         ;Set FCB to open for read status
        MOV BH,0
        ADD BX,BX
        MOV BX,ES:[BX+926H]
        XCHG BH,BL
        MOV BYTE PTR ES:[BX],10H
        MOV WORD PTR ES:[957H],0;Set BASIC/BINARY flags
        CMP BYTE PTR CS:FSPEC,-1
        JZ NOT_ASCII
        NOT BYTE PTR ES:[958H]  ;...unlesss it doesn't start with FFh
NOT_ASCII:
        POPALL
        RET6809
        CMP SI,0CA6EH           ;If it's not the BASIC LOAD command
        JZ NOT_BINARY           ;then it's the LOADM command being executed
        MOV WORD PTR ES:[957H],2;Identify file as M/L binary
NOT_BINARY:
        RETF

SAVEX_OPEN:
        PUSHALL
        CALL CLOSE_OLD
        CALL PARSE_FILE
        MOV AX,CS
        MOV DS,AX
        MOV AH,3CH
        MOV CX,0
        MOV DX,OFFSET FSPEC
        INT 21H
        JB ERROR_A
        MOV HANDLE,AX
        MOV BL,ES:[6FH]         ;Set FCB to open for read status
        MOV BH,0
        ADD BX,BX
        MOV BX,ES:[BX+926H]
        XCHG BH,BL
        MOV BYTE PTR ES:[BX],20H
        POPALL
        RET6809
        RETF
ERROR_A:
        JMP ERROR

ERROR_XLAT DB 32H,32H,34H,2AH,26H,3CH,28H,0CH,0CH,08H,3EH,28H,2AH,26H,42H
        DB 26H,34H

;Read a byte from the file

LOAD_READ:
        PUSH CS
        POP DS
        CMP XMODE,1
        JZ LOADX_READ
        MOV SI,OFFSET NOT_LOADX_READ
        RETF
LOADX_READ:
        CMP FSPEC[1],0          ;First, make sure the previous byte loaded
        JZ LOADX_READ_1         ;at open has been read
        MOV DH,FSPEC
        MOV FSPEC[1],0
        JMP LOADX_READ_2
LOADX_READ_1:
        PUSH AX                 ;Read next byte from file
        PUSH BX
        PUSH CX
        PUSH DX
        MOV AH,3FH
        MOV BX,HANDLE
        MOV CX,1
        MOV DX,OFFSET FSPEC
        INT 21H
        CMP AL,1
        JZ NOT_EOF              ;Set EOF flag if byte not read
        MOV BYTE PTR ES:[70H],-1
NOT_EOF:
        POP DX
        MOV DH,FSPEC
        POP CX
        POP BX
        POP AX
LOADX_READ_2:
        RET6809
        RETF

;Close the file

LOAD_CLOSE:
        TEST CS:XMODE,-1
        JNZ LOADX_CLOSE
        MOV SI,0176H
        RETF
LOADX_CLOSE:
        PUSH AX
        PUSH BX
        MOV CS:XMODE,0          ;Disable external patches
        MOV BL,ES:[6FH]         ;Set FCB to closed status
        MOV BH,0
        ADD BX,BX
        MOV BX,[BX+926H]
        XCHG BH,BL
        MOV BYTE PTR [BX],0
        CALL CLOSE_OLD
        POP BX
        POP AX
        INC BP                  ;Return to caller of A42D, not to A430 itself
        INC BP
        RET6809
        RETF

;Close last file if it was left open

CLOSE_OLD:
        MOV BX,CS:HANDLE
        OR BX,BX
        JZ ALL_CLOSED
        MOV AH,3EH
        INT 21H
        MOV CS:HANDLE,0
ALL_CLOSED:
        RET

;Parse filename at 94CH into something we can use

PARSE_FILE:
        PUSH ES
        MOV AX,CS
        MOV ES,AX
        MOV SI,94CH
        MOV DI,OFFSET FSPEC
        MOV CX,8
PARSE_FN:
        LODSB
        CMP AL,' '
        JZ ADD_DOT
        STOSB
        LOOP PARSE_FN
ADD_DOT:
        MOV AL,'.'
        STOSB
        MOV SI,954H
        MOV CX,3
PARSE_EXT:
        LODSB
        CMP AL,' '
        JZ ADD_NULL
        STOSB
        LOOP PARSE_EXT
ADD_NULL:
        MOV AL,0
        STOSB
        POP ES
        RET

;Check for DOSX, and quit emulator if found

DOS_CHECK:
        OPCODE 0E1H,NOT_DOSX
        MOV SI,OFFSET DOSX_OPCODE
        RETF
NOT_DOSX:
        MOV SI,0D6ECH
        RETF

;Error abort patch... make sure file closed and patches disabled

COCO_ERROR:
        PUSH AX
        PUSH BX
        CALL CLOSE_OLD
        MOV CS:XMODE,0
        POP BX
        POP AX
        MOV SI,0E470H
        RETF

;Entry to SAVE command.  Checks for "X"

SAVE_CHECK:
        PUSH AX
        MOV AX,OFFSET COCO_ERROR_VECTOR;Patch to ensure everything reset if aborted
        XCHG AH,AL              ;by an error
        MOV ES:[0AC47H],AX
        POP AX
        OPCODE 0D8H,NOT_SAVEX
        MOV BYTE PTR CS:XMODE,2
        SUB BP,2
        MOV word ptr DS:[BP],0E0C9H      ;Put SAVE entry on stack
        MOV SI,9FH              ;and jump to "next byte" routine
        RETF
NOT_SAVEX:
        MOV SI,0C9E0H           ;Jump to SAVE routine
        RETF

;Entry to byte write routine as used by SAVE and others

SAVE_WRITE:
        PUSH CS
        POP DS
        CMP XMODE,2
        JZ SAVEX_WRITE
        MOV SI,OFFSET NOT_SAVEX_WRITE_VECTOR
        RETF
SAVEX_WRITE:
        MOV FSPEC,DH
        MOV FSPEC[1],10
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        MOV AH,40H
        MOV BX,HANDLE
        MOV CX,1
        CMP BYTE PTR ES:[958H],-1
        JNZ NOT_CRLF            ;If the file is ASCII, and the character is
        CMP FSPEC,13            ;a carriage return
        JNZ NOT_CRLF
        INC CL                  ;Output LF with it
NOT_CRLF:
        MOV DX,OFFSET FSPEC
        INT 21H
        POP DX
        POP CX
        POP BX
        POP AX
        RET6809
        RETF

;Intercept of DIR command

DTA_LO  DW 0                    ;Storage area for old Disk Transfer Address
DTA_HI  DW 0

WILDCARD DW 0
EVERYTHING DB '*.*',0

NOT_DIRX:
        MOV SI,0CCA9H
        RETF
DIR_CHECK:
        OPCODE 0CEH,NOT_DIRX
        MOV CS:WILDCARD,OFFSET EVERYTHING
        MOV SI,OFFSET CHECK_ARGUMENT_VECTOR
        RETF                    ;See if there was a parameter included
CHECK_ARGUMENT:
        CMP DH,':'
        JZ NO_ARGUMENT
        CMP DH,' '
        JB NO_ARGUMENT
        MOV SI,OFFSET GET_ARGUMENT_VECTOR
        RETF
GET_ARGUMENT:
        MOV CS:WILDCARD,OFFSET FSPEC;Point wildcard to parsed file name
NO_ARGUMENT:        
        PUSHALL
        CALL PARSE_FILE
        RAMBANK DS
        PUSH ES
        MOV AH,2FH              ;Save current Disk Transfer Address
        INT 21H
        MOV CS:DTA_LO,BX
        MOV CS:DTA_HI,ES
        POP ES
        MOV AH,1AH              ;Set new DTA for use with DIRX command
        MOV DX,0FD80H   
        INT 21H
        MOV AX,CS
        MOV DS,AX
        MOV AH,4EH
        MOV DX,WILDCARD
        MOV CX,10H
        INT 21H
        JNB FORM_ENTRY
        MOV AH,1AH              ;File not found
        MOV DX,CS:DTA_LO
        MOV DS,CS:DTA_HI
        INT 21H
        MOV AL,2
        JMP ERROR
FORM_ENTRY:                     ;Construct the line for the directory entry
        RAMBANK DS
        MOV DI,0FD60H
CLEAR_LINE:
        MOV BYTE PTR [DI],' '
        INC DI
        CMP DI,0FD7EH
        JB CLEAR_LINE
        MOV WORD PTR [DI],13
        SUB DI,30
        MOV SI,0FD9EH
        MOV AX,[SI]
        CMP AX,2EH
        JZ SELF
        CMP AX,2E2EH
        JNZ GET_NAME
        CMP BYTE PTR [SI+2],0
        JNZ GET_NAME
SELF:   OR AX,2020H
        MOV [DI],AX
        JMP NO_EXT
GET_NAME:
        LODSB
        CMP AL,0
        JZ NO_EXT
        CMP AL,'.'
        JZ GET_EXT
        MOV [DI],AL
        INC DI
        JMP GET_NAME
GET_EXT:
        MOV DI,0FD69H
GET_EXT_1:
        LODSB
        CMP AL,0
        JZ NO_EXT
        MOV [DI],AL
        INC DI
        JMP GET_EXT_1
NO_EXT: MOV AL,DS:[0FD95H]      ;Directory?
        TEST AL,16
        JZ NOT_DIR
        MOV WORD PTR DS:[0FD6DH],443CH
        MOV WORD PTR DS:[0FD6FH],5249H
        MOV BYTE PTR DS:[0FD71H],3EH
        JMP LINE_DONE
NOT_DIR:
        MOV DH,0                ;Get number of sectors in DX:AX
        ADD word ptr DS:[0FD9AH],8FFH
        ADC WORD PTR DS:[0FD9CH],0
        MOV DL,DS:[0FD9DH]
        MOV AX,DS:[0FD9BH]
        CMP DL,9
        JNB DISPLAY_LINE
        MOV SI,0FD71H
        MOV BX,9
        DIV BX
        MOV BL,10
DIV_DIGITS:
        MOV DL,0
        DIV BX
        OR DL,30H
        MOV DS:[SI],DL
        DEC SI
        OR AX,AX
        JNZ DIV_DIGITS
LINE_DONE:
        POPALL
        MOV CX,0FD5FH
        MOV SI,OFFSET DISPLAY_LINE_VECTOR
        RETF
DISPLAY_LINE:
        PUSHALL
        MOV AX,CS
        MOV DS,AX
        MOV AH,4FH
        INT 21H
        JB NO_MORE_FILES
        JMP FORM_ENTRY
NO_MORE_FILES:
        MOV AH,1AH
        MOV DX,CS:DTA_LO
        MOV DS,CS:DTA_HI
        INT 21H
        POPALL
        RET6809                 ;Return to BASIC for next command
        RETF

;Entry to DRIVE command.  Checks for "X"

NOT_DRIVEX:
        MOV SI,0CEC5H
        RETF
DRIVE_CHECK:
        OPCODE 0CFH,NOT_DRIVEX
        MOV SI,OFFSET GET_DRIVE_ARGUMENT_VECTOR
        RETF
GET_DRIVE_ARGUMENT:
        PUSHALL
        RAMBANK DS
        MOV BH,0                ;BX = 6809 B register
        MOV BL,DL
        MOV DX,CX               ;DX = 6809 X register
        ADD BX,DX               ;ABX
        MOV CL,[BX]
        MOV BYTE PTR [BX],0
        MOV SI,DX
        CMP BYTE PTR [SI+1],':'
        JNZ NO_DRIVE
        PUSH DX
        MOV DL,[SI]
        AND DL,223
        SUB DL,'A'
        MOV AH,14
        INT 21H
        CMP DL,AL
        POP DX
        JNB DRIVE_ERROR
        INC DX
        INC DX
        JMP NO_DRIVE
DRIVE_ERROR:
        MOV AX,2
        JMP ERROR
NO_DRIVE:
        DEC SI
CORRECT_PATH:
        INC SI
        CMP BYTE PTR [SI],'/'
        JNZ NOT_SLASH
        MOV BYTE PTR [SI],'\'
NOT_SLASH:
        CMP BYTE PTR [SI],0
        JNZ CORRECT_PATH
        MOV AH,3BH
        INT 21H
        MOV BYTE PTR [BX],CL
        MOV AH,2
        JNB NO_DRIVE_ERROR
        JMP ERROR
NO_DRIVE_ERROR:
        POPALL
        RET6809
        RETF

;Entry to KILL command.  Checks for "X"

KILL_CHECK:
        OPCODE 0D2H,NOT_KILLX
        MOV BYTE PTR CS:XMODE,3
        SUB BP,2
        MOV word ptr DS:[BP],0EFC6H      ;Put KILL entry on stack
        MOV SI,9FH              ;and jump to "next byte" routine
        RETF
NOT_KILLX:
        MOV SI,0C6EFH           ;Jump to KILL routine
        RETF

;Hander for KILLX

KILL_FILE:
        CMP BYTE PTR CS:XMODE,3
        JZ KILLX
        MOV SI,0C79DH
        RETF
KILLX:  PUSHALL
        MOV CS:XMODE,0
        CALL CLOSE_OLD
        CALL PARSE_FILE
        MOV AX,CS
        MOV DS,AX
        MOV AH,41H
        MOV DX,OFFSET FSPEC
        INT 21H
        JNB NO_KILLX_ERROR
        JMP ERROR
NO_KILLX_ERROR:
        POPALL
        INC BP                  ;Done with KILL command, pop return address
        INC BP                  ;off stack and return to next BASIC command
        RET6809
        RETF

;Handler to display full-text error messages

ERROR_TEXT:
        PUSH BX
        PUSH DX
        CMP DL,50H
        JB ERROR_KNOWN
        MOV DL,50H
ERROR_KNOWN:
        MOV BX,OFFSET ERROR_MESSAGES-1
        OR DL,DL
        JZ DISPLAY_ERROR
FIND_ERROR:
        DEC DL
        JZ DISPLAY_ERROR
NEXT_ERROR:
        INC BX
        CMP BYTE PTR CS:[BX],0
        JNZ NEXT_ERROR
        DEC DL
        JNZ FIND_ERROR
DISPLAY_ERROR:
        MOV CX,CS
        MOV DS,CX
        RAMBANK ES
        MOV CX,100H
        PUSH DI
        MOV SI,BX
        MOV DI,0FD00H
        MOV CX,100H
        REP MOVSB
        POP DI
        MOV CX,0FD00H 
        POP DX
        POP BX
        MOV SI,0AC68H
        RETF

ERROR_MESSAGES DB 'NEXT WITHOUT FOR',0
        DB 'SYNTAX ERROR',0
        DB 'RETURN WITHOUT GOSUB',0
        DB 'OUT OF DATA',0
        DB 'ILLEGAL FUNCTION CALL',0
        DB 'OVERFLOW',0
        DB 'OUT OF MEMORY',0
        DB 'UNDEFINED LINE',0
        DB 'BAD SUBSCRIPT',0
        DB 'REDIMENSIONED ARRAY',0
        DB 'DIVISION BY ZERO',0
        DB 'ILLEGAL DIRECT',0
        DB 'TYPE MISMATCH',0
        DB 'OUT OF STRING SPACE',0
        DB 'STRING TOO LONG',0
        DB 'STRING FORMULA TOO COMPLEX',0
        DB 'CAN',39,'T CONTINUE',0
        DB 'BAD FILE DATA',0
        DB 'ALREADY OPEN',0
        DB 'BAD DRIVE/DEVICE NUMBER',0
        DB 'I/O ERROR',0
        DB 'BAD FILE MODE',0
        DB 'FILE NOT OPEN',0
        DB 'INPUT PAST END',0
        DB 'DIRECT STATEMENT',0
        DB 'UNDEFINED FUNCTION',0
        DB 'FILE NOT FOUND',0
        DB 'BAD RECORD NUMBER',0
        DB 'DISK FULL',0
        DB 'OUT OF BUFFER SPACE',0
        DB 'WRITE PROTECTED',0
        DB 'BAD FILE NAME',0
        DB 'BAD FILE STRUCTURE',0
        DB 'ALREADY EXISTS',0
        DB 'FIELD OVERFLOW',0
        DB 'NON-FIELDED STRING',0
        DB 'VERIFY FAILED',0
        DB 'PAST END OF RECORD',0
        DB 'HIRES GRAPHICS ERROR',0
        DB 'HIRES PRINT ERROR',0
        DB 'UNKNOWN ERROR',0

        ORG 0FC00H

SAVEREG DW 0,0

HOMEBANK:
        MOV CS:SAVEREG[2],AX
        MOV CS:SAVEREG,BX
        MOV AX,CS
        SUB AX,2800H
        POP BX
        MOV BX,CS:[BX]
        PUSH AX
        PUSH BX
        MOV AX,CS:SAVEREG[2]
        MOV BX,CS:SAVEREG
        RETF

LOAD_CHECK_VECTOR DB 11H,0FFH
        CALL HOMEBANK
        DW OFFSET LOAD_CHECK
RUN_CHECK_VECTOR DB 11H,0FFH
        CALL HOMEBANK
        DW OFFSET RUN_CHECK
LOAD_OPEN_VECTOR DB 11H,0FFH
        CALL HOMEBANK
        DW OFFSET LOAD_OPEN
LOAD_CLOSE_VECTOR DB 11H,0FFH
        CALL HOMEBANK
        DW OFFSET LOAD_CLOSE
LOAD_READ_VECTOR DB 11H,0FFH
        CALL HOMEBANK
        DW OFFSET LOAD_READ
DOS_CHECK_VECTOR DB 11H,0FFH
        CALL HOMEBANK
        DW OFFSET DOS_CHECK
COCO_ERROR_VECTOR DB 11H,0FFH
        CALL HOMEBANK
        DW OFFSET COCO_ERROR
SAVE_WRITE_VECTOR DB 11H,0FFH
        CALL HOMEBANK
        DW OFFSET SAVE_WRITE
SAVE_CHECK_VECTOR DB 11H,0FFH
        CALL HOMEBANK
        DW OFFSET SAVE_CHECK
DIR_CHECK_VECTOR DB 11H,0FFH
        CALL HOMEBANK
        DW OFFSET DIR_CHECK
DRIVE_CHECK_VECTOR DB 11H,0FFH
        CALL HOMEBANK
        DW OFFSET DRIVE_CHECK
KILL_CHECK_VECTOR DB 11H,0FFH
        CALL HOMEBANK
        DW OFFSET KILL_CHECK
KILL_FILE_VECTOR DB 11H,0FFH
        CALL HOMEBANK
        DW OFFSET KILL_FILE
ERROR_TEXT_VECTOR DB 11H,0FFH
        CALL HOMEBANK
        DW OFFSET ERROR_TEXT
CHECK_ARGUMENT_VECTOR DB 0BDH,0,9FH           
        DB 11H,0FFH             ;jsr $009F
        CALL HOMEBANK
        DW OFFSET CHECK_ARGUMENT
NOT_LOADX_READ DB 34H,14H       ;pshs X,B
        DB 0FH,70H              ;clr <$70
        DB 7EH,0C5H,0C8H        ;jmp $C5C8
GET_ARGUMENT_VECTOR DB 0BDH,0CAH,33H        
        DB 11H,0FFH             ;jsr $CA33
        CALL HOMEBANK
        DW OFFSET GET_ARGUMENT
GET_DRIVE_ARGUMENT_VECTOR DB 0BDH,0,9FH           ;jsr $009F
        DB 0BDH,87H,48H         ;jsr $8748
        DB 11H,0FFH    
        CALL HOMEBANK
        DW OFFSET GET_DRIVE_ARGUMENT
DISPLAY_LINE_VECTOR DB 0BDH,0B9H,9CH        
        DB 11H,0FFH             ;jsr $B99C
        CALL HOMEBANK
        DW OFFSET DISPLAY_LINE
DOSX_OPCODE DW 0FE11H
NOT_SAVEX_WRITE_VECTOR:
        DB 34H,16H              ;pshs X,B,A
        DB 8EH,09H,26H          ;ldx #$0926
        DB 7EH,0CCH,29H         ;jmp $CC29

        ORG 0FD00H

PROG    ENDS

        END INSTALL
