        TITLE CoCo Real-to-Virtual Disk Transfer
        ;Copyright (C) 1993-1995 Jeff Vavasour

        ASSUME CS:PROG,DS:PROG

FIRST_TRACK  EQU 0
FIRST_SECTOR EQU 1
NSEC    EQU 18

        EXTRN PHYS_READ:NEAR,INITIALIZE:NEAR,DRIVE_TYPE:BYTE

        PUBLIC FDC_TRACK,FDC_SECTOR,DOUBLE_STEP,DRIVE_SEL,HANDLE,DTA

STACK   SEGMENT STACK
        DB 512 DUP(?)
STACK   ENDS

PROG    SEGMENT PUBLIC 'CODE'

START:  MOV SI,128
        JMP PARSE
ERROR1A:
        JMP ERROR1
PARSE:  INC SI
        CMP BYTE PTR [SI],' '           ;Skip leading spaces
        JZ PARSE
        CMP BYTE PTR [SI],13            ;Make sure there's a parameter
        JZ ERROR1A
        CMP WORD PTR [SI],722FH         ;"/r" option
        JZ ROM_REQUEST
        CMP WORD PTR [SI],522FH         ;"/R" option
        JNZ NO_ROM_REQUEST
ROM_REQUEST:        
        MOV CS:ROM,1
        INC SI
        JMP PARSE
NO_ROM_REQUEST:
        CMP WORD PTR [SI],382FH         ;"/8" option
        JNZ NOT_HIGH_DENS
        MOV BYTE PTR CS:DOUBLE_STEP,0   ;If so, set flag
        MOV BYTE PTR CS:MAX_TRACK,80    ;Make disk 80-track
        INC SI
        JMP PARSE
NOT_HIGH_DENS:        
        CMP WORD PTR [SI],322FH         ;"/2" option
        JNZ NOT_TWO_SIDED
        MOV BYTE PTR CS:HEAD,'1'
        MOV BYTE PTR CS:DRIVE_SEL,90H
        INC SI
        JMP PARSE
NOT_TWO_SIDED:
        CMP WORD PTR [SI],342FH         ;"/4" option
        JNZ NOT_40_TRACK
        MOV CS:MAX_TRACK,40
        INC SI
        JMP PARSE
NOT_40_TRACK:
        CMP WORD PTR [SI+1],203AH       ;If current character followed by ": "
        JNZ PARSE1                      ;it's a source drive designation
        MOV AL,[SI]                     ;Work out drive number
        ADD SI,2
        SUB AL,'A'
        MOV CS:HANDLE,AL
        CMP AL,32
        JB PARSE
        SUB CS:HANDLE,32
        JMP PARSE
PARSE1: MOV DX,SI                       ;Point to start of ".DSK" name
        MOV AL,0                        ;Reset "default extension" flag
PARSE2: CMP BYTE PTR [SI],'.'
        JNZ PARSE3
        MOV AL,-1                       ;If a "." found, don't use default
PARSE3: CMP BYTE PTR [SI],'\'
        JNZ PARSE4
        MOV AL,0                        ;unless it's part of the path
PARSE4: INC SI
        CMP BYTE PTR [SI-1],32          ;Check for end of line
        JA PARSE2
        CMP AL,0
        JNZ PARSE5
        MOV WORD PTR [SI-1],442EH       ;Add ".DSK" if flag set
        MOV WORD PTR [SI+1],4B53H
        ADD SI,4
PARSE5: MOV BYTE PTR [SI-1],0           ;Add terminator
        JMP OPEN

ERROR1: MOV AH,9                        ;Error trap routine, bad syntax
        PUSH CS
        POP DS
        MOV DX,OFFSET MSG1
        INT 21H
        MOV AX,4C00H                    ;Exit
        INT 21H

MSG1    DB 'Usage: RETRIEVE [/2] [/4] [/8] [/R] [d:] [path\]diskname[.DSK]',13,10
        DB '         "d:"         source drive (default A:)',13,10
        DB '         "path"       destination directory for virtual disk',13,10
        DB '         "diskname"   name of virtual disk',13,10
        DB '         /2           to read the second side of the disk',13,10
        DB '         /4           if using 40-track disks (default is 35)',13,10
        DB '         /8           if using 80-track disks in a 1.2Mb drive',13,10
        DB '         /R           to retrieve the ROM image (see manual)',13,10,'$'

HANDLE  DB 0                            ;Default source drive=A:
        DB -2
FHANDLE DW ?                            ;Virtual disk file handle
DOUBLE_STEP DB 1                        ;0 => 360K drive, 1 => 1.2Mb drive
ROM     DB 0                            ;0 => Normal disk, 1 => ROM

OPEN:   PUSH DS
        PUSH CS
        POP DS
        PUSH DX
        MOV DX,OFFSET DTA               ;Get drive types
        CALL INITIALIZE
        MOV BL,HANDLE
        MOV BH,0
        MOV AL,DRIVE_TYPE[BX]
        CMP AL,2
        JZ MICRODISK
        CMP AL,7
        JNZ NO_MICRODISK
MICRODISK:
        CMP MAX_TRACK,40                ;Unless there's a /4 override
        JZ NO_MICRODISK
        MOV MAX_TRACK,80                ;All 3.5" disks are 80-track
NO_MICRODISK:
        POP DX
        POP DS
        MOV AH,3CH                      ;Create the virtual disk file
        MOV CX,0
        INT 21H
        PUSH CS
        POP DS
        MOV FHANDLE,AX
        JB OPEN_ERROR
        MOV SI,0                        ;Reset pointer to top of DAM table
        JMP READ

OPEN_ERROR:
        MOV AH,9                        ;Read error
        MOV DX,OFFSET MSG2
        INT 21H
        MOV AX,4C00H
        INT 21H

MSG2    DB 'Unable to create specified virtual disk.',13,10,'$'

MSG2B   DB 13,10,'Warning!  May not have found all sectors on track.',13,10,'$'

BUFFER  DB 4608 DUP(?)
CONT    DB 0

DAM     DB 2200H DUP(-1)

MSG3    DB 13,'Reading track '
TRACK   DB '0',FIRST_TRACK+30H,', head '
HEAD    DB '0, sector '
SECTOR  DB '00 $'
MSG4    DB '-- read error!',13,10,'$'
MSG5    DB 'Abort, Retry, Ignore, or Continuous? $'
MSG6    DB '-- write error!'
MSG7    DB 13,10,'$'
ERRCOUNT DB 2                           ;Number of error retries

FDC_TRACK DB FIRST_TRACK                ;Track for DISK package
FDC_SECTOR DB 0                         ;Sector for DISK package
DRIVE_SEL DB 80H                        ;Density/head select
DTA DB 256 DUP(?)                       ;DISK package buffer

READ_ERROR_A:
        JMP READ_ERROR

READ:   MOV CL,NSEC                     ;Determine first sector in sequence
        MOV CH,0
        MOV FDC_SECTOR,FIRST_SECTOR     ;Set sector count to first sector
        MOV DI,OFFSET BUFFER            ;Point to top of buffer
TRY_LOOP:
        MOV AH,FDC_SECTOR               ;Display sector number
        CMP AH,10
        MOV AL,'0'
        JB LOW_SECTOR
        INC AL
        SUB AH,10
LOW_SECTOR:
        ADD AH,'0'
        MOV WORD PTR SECTOR,AX
RETRY:  MOV AH,9
        MOV DX,OFFSET MSG3
        INT 21H
        CALL PHYS_READ                  ;Read sector specified
        TEST AL,9CH
        JZ NO_READ_ERROR_A
        DEC ERRCOUNT                    ;If there's an error, retry
        JNZ TRY_LOOP
        MOV ERRCOUNT,2

READ_ERROR:
        MOV AH,9                        ;Read error branch
        MOV DX,OFFSET MSG4              ;Display error message
        INT 21H
        CMP CONT,0                      ;If continuous, ignore
        JZ KEYSTROKE
NO_READ_ERROR_A:
        JMP NO_READ_ERROR
KEYSTROKE:                              ;Else prompt for action
        MOV AH,9
        MOV DX,OFFSET MSG5
        INT 21H
        MOV AH,1
        INT 21H
        PUSH AX
        MOV AH,9
        MOV DX,OFFSET MSG7
        INT 21H
        POP AX
        AND AL,223
        CMP AL,'R'                      ;Retry
        JZ RETRY_A
        CMP AL,'I'                      ;Ignore
        JZ NO_READ_ERROR
        CMP AL,'C'                      ;Continuous
        JZ CONTINUOUS
        CMP AL,'A'                      ;Abort
        JNZ KEYSTROKE
        JMP ABORT

RETRY_A:
        JMP RETRY

ABORT:  MOV AH,3EH                      ;Abort: Close virtual disk file
        MOV BX,CS:FHANDLE
        INT 21H
        MOV AX,64
        MOV ES,AX
        MOV BYTE PTR ES:[3EH],0
        MOV AX,4C00H                    ;Exit
        INT 21H

CONTINUOUS:
        MOV CONT,1

NO_READ_ERROR:                          ;Write sector to virtual disk
        PUSH CX                         ;Add sector to buffer table
        PUSH SI
        MOV AX,DS
        MOV ES,AX
        MOV SI,OFFSET DTA
        MOV CX,256
        REP MOVSB
        POP SI
        POP CX
        INC FDC_SECTOR
        LOOP TRY_LOOP_A                 ;Loop for all sectors on track
        JMP TRACK_LOOP_DONE

TRY_LOOP_A:
        JMP TRY_LOOP

TRACK_LOOP_DONE:
        MOV FDC_SECTOR,FIRST_SECTOR     ;Restore starting sector
        MOV CL,NSEC                     ;Set CX to number of sectors again
        MOV CH,0
        MOV SI,OFFSET BUFFER
WRITE_LOOP:                             ;Calculate address of sector to write
        CMP ROM,0                       ;If not writing rom proceed as usual
        JZ NO_ROM_WRITE
        CMP FDC_TRACK,5                 ;Otherwise, terminate at track 5,
        JB NO_ROM_WRITE
        MOV AL,NSEC+FIRST_SECTOR
        SUB AL,CL
        CMP AL,7                        ;sector 7
        JB NO_ROM_WRITE
        MOV AH,40H                      ;Write the extra two bytes from the
        MOV BX,FHANDLE                  ;wrap around
        MOV CX,2
        MOV DX,OFFSET BUFFER+700H
        INT 21H
        JMP DONE
NO_ROM_WRITE:
        MOV DX,SI
        PUSH CX
        MOV CX,256                      ;Write 256 bytes
        MOV AH,40H      
        MOV BX,FHANDLE
        INT 21H
        POP CX
        JB WRITE_ERROR
        ADD SI,256
        LOOP WRITE_LOOP
        JMP NEXT_HEAD

WRITE_ERROR:        
        MOV AH,9                        ;Write error branch
        MOV DX,OFFSET MSG6
        INT 21H
        JMP ABORT

NEXT_HEAD:
        INC TRACK[1]
        CMP TRACK[1],3AH
        JB LOW_TRACK
        MOV TRACK[1],'0'
        INC TRACK
LOW_TRACK:
        INC FDC_TRACK
        MOV AL,FDC_TRACK
        CMP AL,MAX_TRACK
        JNB DONE
        JMP READ

DONE:   MOV AH,9                        ;"Done."
        MOV DX,OFFSET MSG8
        INT 21H
        JMP ABORT

MSG8    DB ' -- Done.',13,10,'$'
MSG9    DB 'Unable to open COCO.ROM!',13,10,'$'
COCOROM DB 'COCO.ROM',0

MAX_TRACK DB 35

PROG    ENDS        

        END START

