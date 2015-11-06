        TITLE CoCo Virtual-to-Real Disk Transfer
        ;Copyright (C) 1993 Jeff Vavasour

        ASSUME CS:PROG,DS:PROG

FIRST_SECTOR EQU 1

        EXTRN FORMAT:NEAR,PHYS_WRITE:NEAR,INITIALIZE:NEAR,DRIVE_TYPE:BYTE
        EXTRN SPINUP:NEAR

        PUBLIC FDC_TRACK,FDC_SECTOR,DOUBLE_STEP,DRIVE_SEL,HANDLE,DTA

STACK   SEGMENT STACK
        DB 512 DUP(?)
STACK   ENDS

PROG    SEGMENT PUBLIC 'CODE'

ERROR1_A:
        JMP ERROR1
START:  MOV SI,128
        MOV DX,-1
PARSE:  INC SI
        CMP BYTE PTR [SI],' '           ;Skip leading spaces
        JZ PARSE
        CMP BYTE PTR [SI],13            ;Make sure there's a parameter
        JZ ERROR1_A
        MOV DX,0
        CMP WORD PTR [SI],382FH         ;"/8" option
        JNZ NOT_HIGH_DENS
HIGH_DENS:        
        MOV BYTE PTR CS:DOUBLE_STEP,0   ;If so, set flag
        INC SI
        JMP PARSE
NOT_HIGH_DENS:        
        CMP WORD PTR [SI],322FH         ;"/2" option
        JNZ NOT_SECOND_SIDE
        MOV BYTE PTR CS:DRIVE_SEL,90H
        MOV BYTE PTR CS:HEAD,'1'
        MOV BYTE PTR CS:HEAD1,'1'
        INC SI
        JMP PARSE
NOT_SECOND_SIDE:
        CMP WORD PTR [SI+1],0D3AH
        JZ DEFAULT_DRIVE
        CMP WORD PTR [SI+1],203AH       ;If current character followed by ": "
        JNZ PARSE1                      ;it's a drive designation
DEFAULT_DRIVE:
        LODSB                           ;Work out drive number
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

ERROR1: PUSH CS
        POP DS
        CMP DX,0
        JZ NO_VDISK_A
        MOV AH,9                        ;Error trap routine, bad syntax
        MOV DX,OFFSET MSG1
        INT 21H
        MOV AX,4C00H                    ;Exit
        INT 21H
NO_VDISK_A:
        JMP NO_VDISK

MSG1    DB 'Usage: DSKINI [/2] [/8] [d:] [[path\]diskname[.DSK]]',13,10
        DB '         "d:"         destination drive (default A:)',13,10
        DB '         "path"       source directory for virtual disk',13,10
        DB '         "diskname"   name of virtual disk',13,10
        DB '         /2           to write to the second side of the disk',13,10
        DB '         /8           if using an 80-track disk in 1.2Mb drive',13,10
        DB 13,10,'At least one parameter must be specified.',13,10,'$'

HANDLE  DB 0                            ;Default source drive=A:
        DB -2
FHANDLE DW 0                            ;Virtual disk file handle
DOUBLE_STEP DB 1                        ;0 => 360K drive, 1 => 1.2Mb drive

OPEN:   MOV AX,3D00H                    ;Create the virtual disk file
        INT 21H
        PUSH CS
        POP DS
        MOV FHANDLE,AX
        JNB NO_VDISK
        MOV AH,9                        ;Read error
        MOV DX,OFFSET MSG2
        INT 21H
        MOV AX,4C00H
        INT 21H
NO_VDISK:
        MOV DX,OFFSET DTA               ;Get drive types
        CALL INITIALIZE
        MOV BH,0                        ;Determine if disk is 3.5"
        MOV BL,HANDLE
        MOV AL,DRIVE_TYPE[BX]
        CMP AL,2
        JZ MICRODISK
        CMP AL,7
        JNZ NO_MICRODISK
MICRODISK:
        MOV DOUBLE_STEP,0               ;Set DOUBLE_STEP=0 so it's 80 track
NO_MICRODISK:        
        JMP READ

MSG2    DB 'Unable to open specified virtual disk.',13,10,'$'

MSG2B   DB 'Diskette write protected.',13,10,'$'

BUFFER  DB 4608 DUP(-1)
CONT    DB 0

MSG2A   DB 13,'Formatting track '
TRACK1  DB '00, head '            
HEAD1   DB '0            $'
MSG3    DB 13,'Writing    track '
TRACK   DB '00, head '
HEAD    DB '0, sector '
SECTOR  DB '0',FIRST_SECTOR+30H,' $'
MSG4    DB '-- write error!',13,10,'$'
MSG5    DB 'Abort, Retry, Ignore, or Continuous? $'
MSG7    DB 13,10,'$'
ERRCOUNT DB 2                           ;Number of error retries

FDC_TRACK DB 0                          ;Track for DISK package
FDC_SECTOR DB FIRST_SECTOR              ;Sector for DISK package
DRIVE_SEL DB 80H                        ;Density/head select
DTA DB 6249 DUP(?)                      ;DISK package buffer
LAST_TRACK DB 0                         ;Flag goes non-zero after end of .DSK
SEQUENCE DB 0,6,12,1,7,13,2,8,14,3,9,15,4,10,16,5,11,17

READ:   CMP FHANDLE,0                   ;If disk image specified, skip to
        JZ CONSTRUCT                    ;formatting stage
        MOV DI,OFFSET BUFFER
READ1:  MOV AH,3FH                      ;Read 256 bytes
        MOV BX,FHANDLE
        MOV DX,DI
        MOV CX,256
        ADD DI,CX
        INT 21H
        CMP AX,256
        JZ READ2
        DEC LAST_TRACK                  ;If sector empty, last track reached
        JMP CONSTRUCT
READ2:  CMP DI,OFFSET BUFFER+1200H      ;Loop for 18 sectors
        JB READ1

CONSTRUCT:                              ;Build sequence for formatting
        MOV SI,OFFSET SEQUENCE
        MOV CX,18
        MOV DI,OFFSET DTA
CONSTRUCT1:
        MOV BYTE PTR [DI],0FEH          ;ID address mark
        MOV AL,FDC_TRACK                ;Track
        MOV [DI+1],AL
;        MOV AL,DRIVE_SEL                ;Head
;        AND AL,10H
;        SHR AL,1
;        SHR AL,1
;        SHR AL,1
;        SHR AL,1
        MOV AL,0                        ;CoCo incorrectly labels both sides 0
        MOV [DI+2],AL
        LODSB                           ;Sector
        ADD AL,FIRST_SECTOR
        MOV [DI+3],AL
        MOV WORD PTR [DI+4],0FB01H      ;Length (1=256 bytes), DAM=STD
        ADD DI,6
        LOOP CONSTRUCT1

        MOV AH,9                        ;Display formatting message
        MOV DX,OFFSET MSG2A
        INT 21H

        CALL SPINUP
        CALL FORMAT                     ;Format track
        AND AL,40H
        JZ NOT_WRITE_PROT

        MOV AH,9                        ;If write protected, notify!
        MOV DX,OFFSET MSG2B
        INT 21H
        JMP ABORT

NEXT_A: JMP NEXT

NOT_WRITE_PROT:                         ;Here's where we attempt to dump
        MOV FDC_SECTOR,FIRST_SECTOR
        MOV SI,OFFSET BUFFER
        CMP FHANDLE,0                   ;If no virtual disk specified, skip
        JZ NEXT_A                       ;write sector phase
        CMP LAST_TRACK,-1               ;Or if last track was passed
        JL NEXT_A
WRITE_SECTOR:                           ;Work out position in buffer
        MOV AX,CS                       ;Move sector into DISK package's DTA
        MOV ES,AX
        MOV DI,OFFSET DTA
        MOV CX,256
        REP MOVSB

        MOV AH,FDC_SECTOR               ;Work out ASCII sector number
        CMP AH,10
        MOV AL,'0'
        JB LOW_SECTOR
        INC AL
        SUB AH,10
LOW_SECTOR:
        OR AH,'0'
        MOV WORD PTR SECTOR,AX

RETRY:  MOV AH,9                        ;Display write sector message
        MOV DX,OFFSET MSG3
        INT 21H

TRY_LOOP:
        MOV AL,0
        CALL PHYS_WRITE                 ;Write sector to disk
        AND AL,0BCH
        JZ NO_WRITE_ERROR
        DEC ERRCOUNT                    ;If there's an error, retry
        JNZ TRY_LOOP
        MOV ERRCOUNT,2

        MOV AH,9                        ;Read error branch
        MOV DX,OFFSET MSG4              ;Display error message
        INT 21H
        CMP CONT,0                      ;If continuous, ignore
        JNZ NO_WRITE_ERROR
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
        JZ NO_WRITE_ERROR
        CMP AL,'C'                      ;Continuous
        JZ CONTINUOUS
        CMP AL,'A'                      ;Abort
        JNZ KEYSTROKE
        JMP ABORT

RETRY_A:
        JMP RETRY

ABORT:  MOV AH,3EH                      ;Abort: Close virtual disk file
        MOV BX,FHANDLE
        INT 21H
        MOV AX,64                       ;Force recalibration of drives
        MOV ES,AX
        MOV BYTE PTR ES:[3EH],0
        MOV AX,4C00H                    ;Exit
        INT 21H

CONTINUOUS:
        MOV CONT,1

NO_WRITE_ERROR:                         ;Loop until all sectors eliminated
        CMP SI,OFFSET BUFFER+1200H
        JNB NEXT 
        INC FDC_SECTOR
        JMP WRITE_SECTOR

NEXT:   INC TRACK[1]
        INC TRACK1[1]
        CMP TRACK[1],3AH
        JB LOW_TRACK
        MOV TRACK[1],'0'
        MOV TRACK1[1],'0'
        INC TRACK
        INC TRACK1
LOW_TRACK:
        INC FDC_TRACK
        CMP FHANDLE,0                   ;If not virtual disk, determine end
        JZ NO_VDISK_1                   ;by parameter switches
        TEST LAST_TRACK,-1
        JZ READ_A
        CMP FDC_TRACK,40                ;Make sure we format to at least 40
        JB READ_A                       ;tracks anyway
        JMP DONE
READ_A: JMP READ
NO_VDISK_1:
        MOV AL,80                       ;40 track if DOUBLE_STEP=1,
        MOV CL,DOUBLE_STEP              ;80 track if DOUBLE_STEP=0
        SHR AL,CL
        CMP AL,FDC_TRACK
        JNA DONE
        JMP READ

DONE:   MOV AH,9                        ;"Done."
        MOV DX,OFFSET MSG8
        INT 21H
        JMP ABORT

MSG8    DB ' -- Done.',13,10,'$'

PROG    ENDS        

        END START

