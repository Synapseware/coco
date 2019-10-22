        TITLE Convert .CAS CSAVEM of ROM to .ROM file

        NAME CAS2ROM

        ASSUME CS:PROG,DS:PROG

PROG    SEGMENT 'CODE'

MSG1    DB 'TRS-80 COLOUR COMPUTER EMULATOR Virtual Cassette ROM Extractor'
        DB '  Version 1.0',13,10,'Copyright (C) 1994 Jeff Vavasour',13,10
        DB 10,'$'
MSG2    DB 'Usage: CAS2ROM [path\]filename[.CAS]',13,10,10
        DB '       where "filename" is the source virtual cassette '
        DB 'containing the ROM dump.',13,10,10
        DB 'The output file will take the name given when the CSAVEM '
        DB 'command was issued on'
        DB 13,10,'the CoCo.  A ".ROM" extension will automatically be ' 
        DB 'appended.',13,10,'$'
MSG3    DB 'Could not open virtual cassette file by that name.',13,10,'$'
MSG4    DB 'Could not create ROM file.',13,10,'$'
MSG5    DB 'Virtual cassette ends prematurely.',13,10,'$'
MSG6    DB 'Virtual cassette does not start with file description header.'
        DB 13,10,'$'
MSG7    DB 'This is not a CSAVEM file!',13,10,'$'
MSG8    DB 'Error writing to ROM file!',13,10,'$'
MSG9    DB 'Checksum error in the virtual cassette!  An error occurred '
        DB 'transfer!',13,10,'$'
MSG10   DB 'ROM extraction successful.',13,10,'$'
MSG11   DB 'Extracting to '
OUTNAME DB 13 DUP(32)           ;Name of output file
MSG11A  DB '... ',13,10,'$'
MSG11B  DB '.ROM$'
MSG12   DB 'The load address of this CSAVEM file is not ROM!'
        DB 13,10,'$'

INFILE  DW 129                  ;Contains handle of input file
OUTFILE DW -1                   ;Same for output

USAGE:  MOV AH,9                ;No parameter given, display usage
        MOV DX,OFFSET MSG2
        INT 21H
        MOV AX,4C00H
        INT 21H

START:  PUSH CS
        POP DS
        MOV AH,9                ;Display entry message and get .CAS filename
        MOV DX,OFFSET MSG1
        INT 21H
        MOV BL,0                ;Add .CAS extension if necessary
        MOV SI,129
        MOV CL,ES:[128]
        MOV CH,0
        JCXZ USAGE
SKIP_SPACE:
        MOV AL,ES:[SI]
        CMP AL,' '
        JNZ PARSE_IN
        INC SI
        MOV INFILE,SI
        LOOP SKIP_SPACE
        JCXZ USAGE
PARSE_IN:
        MOV AL,ES:[SI]
        INC SI
        CMP AL,'.'
        JNZ PARSE_IN1
        MOV DI,SI
        MOV BL,1
PARSE_IN1:
        CMP AL,'\'
        JNZ PARSE_IN2
        MOV BL,0
PARSE_IN2:
        LOOP PARSE_IN
        OR BL,BL                ;If an extension already skip next part
        JNZ GET_OUT
        MOV DI,SI
        MOV word ptr ES:[SI],432EH       ;Add a ".CAS" if no extension given
        MOV word ptr ES:[SI+2],5341H
        ADD SI,4
GET_OUT:
        MOV BYTE PTR ES:[SI],0  ;Terminate file name
        MOV AX,3D00H
        MOV DX,INFILE           ;Open file for input
        PUSH ES
        POP DS
        INT 21H
        PUSH CS
        POP DS
        MOV INFILE,AX           ;Save handle
        JNB SYNC_NAME
        MOV AH,9
        MOV DX,OFFSET MSG3      ;Error opening input file
        INT 21H
        MOV AX,4C00H
        INT 21H
SYNC_NAME:                      ;File open.  Now find first $3C sync byte
        CALL GETBIT
        RCR AL,1
        CMP AL,3CH
        JNZ SYNC_NAME
        CALL GETBYTE
        OR AL,AL                ;If this is not a Namefile block, something's
        JZ NAME_FOUND           ;wrong
        MOV AH,9
        MOV DX,OFFSET MSG6
        INT 21H
        MOV AX,4C00H
        INT 21H
NAME_FOUND:
        CALL GETBYTE            ;Skip header length
        MOV CX,8                ;Get CSAVEM name
        MOV DI,OFFSET OUTNAME
SKIP_NAME:
        PUSH CX
        CALL GETBYTE
        POP CX
        MOV [DI],AL
        INC DI
        LOOP SKIP_NAME
        CALL GETBYTE            ;Get file type byte
        CMP AL,2
        JZ TYPE_OK
WRONG_TYPE:
        MOV AH,9
        MOV DX,OFFSET MSG7
        INT 21H
        MOV AX,4C00H
        INT 21H
TYPE_OK:
        CALL GETBYTE            ;Get ASCII flag
        INC AL                  ;If $FF, it's ASCII and that's wrong
        JZ WRONG_TYPE
        MOV DI,OFFSET OUTNAME   ;Parse output name
        MOV CX,8
        PUSH CS
        POP ES
        MOV AL,32
        REPNZ SCASB             ;Look for the space in the name
        DEC DI
        MOV SI,OFFSET MSG11B    ;Append extension and terminator ("$")
        MOV CX,5
        REP MOVSB
        CALL GETBYTE            ;Skip gap type and entry address
        CALL GETBYTE
        CALL GETBYTE
        CALL GETBYTE            ;Get MSB of load address
        CMP AL,80H              ;Does this file have a ROM load address?
        JNB ROM_BANK
        MOV AH,9
        MOV DX,OFFSET MSG12
        INT 21H
        MOV AX,4C00H
        INT 21H
ROM_BANK:
        PUSH AX
        MOV AH,9                ;Display name of destination file
        MOV DX,OFFSET MSG11
        INT 21H
        MOV BYTE PTR [DI-1],0   ;Change terminator to 0 to make name ASCIIZ
        MOV AH,9
        MOV DX,OFFSET MSG11A
        INT 21H
        MOV AH,3CH              ;Open output file
        MOV CX,0
        MOV DX,OFFSET OUTNAME
        INT 21H
        MOV OUTFILE,AX
        JNB CREATE_OK
        MOV AH,9
        MOV DX,OFFSET MSG4
        INT 21H
        MOV AX,4C00H
        INT 21H
CREATE_OK:
        CALL GETBYTE            ;Get LSB of load address
        CALL PUTBYTE            ;Write LSB of load address
        POP AX
        CALL PUTBYTE            ;Write MSB of load address
COMPARE_CHECKSUM:
        MOV BL,CHECKSUM         ;Verify the checksum is correct
        PUSH BX
        CALL GETBYTE
        POP BX
        CMP AL,BL
        JZ CHECK_OK
        MOV AH,9
        MOV DX,OFFSET MSG9
        INT 21H
        MOV AX,4C00H
        INT 21H
CHECK_OK:                       ;Reset checksum counter
        MOV BYTE PTR CHECKSUM,0
        MOV AL,0
NEXT_SYNC:                      ;Locate next sync byte
        CALL GETBIT
        RCR AL,1
        CMP AL,3CH
        JNZ NEXT_SYNC
        CALL GETBYTE            ;Sync byte located, determine block type
        INC AL                  ;$FF is the end-of-file marker
        JZ DONE
        CALL GETBYTE            ;Get block length
        MOV CL,AL
        MOV CH,0
        JCXZ NO_DATA
READ_DATA:
        PUSH CX
        CALL GETBYTE
        CALL PUTBYTE
        POP CX
        LOOP READ_DATA
NO_DATA:
        JMP COMPARE_CHECKSUM
DONE:   MOV AH,3EH              ;Close files
        MOV BX,INFILE
        INT 21H
        MOV AH,3EH
        MOV BX,OUTFILE
        INT 21H
        MOV AH,9
        MOV DX,OFFSET MSG10
        INT 21H
        MOV AX,4C00H
        INT 21H

;Read the input file one bit at a time

BIT_COUNT DB 1
INPUT_BYTE DB 0

GETBIT:
        DEC BIT_COUNT
        JNZ GETBIT2
        MOV BIT_COUNT,8
        MOV AH,3FH
        MOV BX,INFILE
        MOV CX,1
        MOV DX,OFFSET INPUT_BYTE
        INT 21H
        JNB GETBIT2
GETBIT1:        
        MOV AH,9
        MOV DX,OFFSET MSG5
        INT 21H
        MOV AX,4C00H
        INT 21H
GETBIT2:
        RCR INPUT_BYTE,1
        RET

CHECKSUM DB 0

GETBYTE:               ;After bit sync has been achieved, this will
        MOV CX,8                ;read 8 bits (1 byte) into AL
GETBYTE1:
        PUSH AX
        PUSH CX
        CALL GETBIT
        POP CX
        POP AX
        RCR AL,1
        LOOP GETBYTE1
        ADD CHECKSUM,AL         ;Keep a checksum tally
        RET

OUTPUT_BYTE DB 0

PUTBYTE:               ;Writes a byte in AL to the output file
        MOV OUTPUT_BYTE,AL
        MOV AH,40H
        MOV BX,OUTFILE
        MOV CX,1
        MOV DX,OFFSET OUTPUT_BYTE
        INT 21H
        JB PUTBYTE1
        RET
PUTBYTE1:
        MOV AH,9
        MOV DX,OFFSET MSG8
        INT 21H
        MOV AX,4C00H
        INT 21H

PROG    ENDS

        END START

