        TITLE CoCo Disk Formatter and Virtual-to-Real Disk Transfer
        ;Copyright (C) 1993 Jeff Vavasour

        ASSUME CS:PROG,DS:PROG

STACK   SEGMENT STACK
        DB 512 DUP(?)
STACK   ENDS

PROG    SEGMENT 'CODE'

START:  MOV SI,128
PARSE:  INC SI
        CMP BYTE PTR [SI],' '           ;Skip leading spaces
        JZ PARSE
        CMP BYTE PTR [SI],13            ;Make sure there's a parameter
        JZ ERROR1
        CMP WORD PTR [SI+1],0D3AH       ;":"/CR also gives drive
        JZ PARSE0
        CMP WORD PTR [SI+1],203AH       ;If current character followed by ": "
        JNZ PARSE1                      ;it's a source drive designation
PARSE0: MOV AL,[SI]                     ;Work out drive number
        INC SI
        SUB AL,'A'
        MOV CS:DRIVE,AL
        CMP AL,32
        JB PARSE
        SUB CS:DRIVE,32
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

ERROR1: PUSH CS                         ;No source disk specified
        POP DS
        JMP MEDIA

DRIVE   DB -1                           ;Default source drive=A:
HANDLE  DW 0                            ;Virtual disk file handle

OPEN:   CMP CS:DRIVE,-1                 ;If name specified, default output
        JNZ OPEN1                       ;becomes drive A:
        INC CS:DRIVE
OPEN1:  MOV AX,3D00H                    ;Create the virtual disk file
        INT 21H
        PUSH CS
        POP DS
        MOV HANDLE,AX
        JNB MEDIA

        MOV AH,9                        ;Read error
        MOV DX,OFFSET MSG2
        INT 21H
        MOV AX,4C00H
        INT 21H

OLDMEDIA DW ?                           ;Original media descriptor
OLDSECGAP DB ?                          ;Original sector I/O gap
OLDGAP  DW ?                            ;Original format gap length
MEDIALSW DW ?                           ;Media address
MEDIAMSW DW ?

MSG2    DB 'Unable to read specified virtual disk.',13,10,'$'

MEDIA:  CMP DRIVE,-1                    ;If no drive or file specified,
        JNZ MEDIA1                      ;display usage information
        MOV AH,9
        MOV DX,OFFSET MSG0
        INT 21H
        MOV AX,4C00H
        INT 21H
MEDIA1: MOV AX,351EH                    ;Get media descriptor address
        INT 21H
        MOV MEDIALSW,BX
        MOV MEDIAMSW,ES
        MOV AX,ES:[BX+3]                ;Save original settings
        MOV OLDMEDIA,AX
        MOV AL,ES:[BX+5]
        MOV OLDSECGAP,AL
        MOV AX,ES:[BX+7]
        MOV OLDGAP,AX
        MOV AX,2523H                    ;Set CTRL-C abort vector
        MOV DX,OFFSET ABORT
        INT 21H
        MOV AX,440DH                    ;Determine drive type
        MOV BL,DRIVE
        MOV BH,0
        INC BL
        MOV CX,0680H
        MOV DX,OFFSET BUFFER
        INT 21H
        MOV AL,BUFFER[1]
        MOV DRIVE_TYPE,AL
        JMP READ

BUFFER  DB 256 DUP(?)
CONT    DB 0
DRIVE_TYPE DB 0

MSG0    DB 'Usage: DSKINI [d:] [[path\]diskname[.DSK]]',13,10
        DB '         "d:"         drive containing disk to be formatted '
        DB '(default A:)',13,10
        DB '         "path"       path containing virtual disk image',13,10
        DB '         "diskname"   disk image to write to disk, if any',13,10
        DB 10,'At least one of "d:" or "diskname" must be specified.',13,10
        DB '$'

MSG1    DB 13,'Formatting track '
FTRACK  DB '00            $'
MSG3    DB 13,'Writing track '
TRACK   DB '00, sector '
SECTOR  DB '01 $'
MSG4    DB ' -- write error!',13,10,'$'
MSG5    DB 'Abort, Retry, Ignore, or Continuous? $'
MSG6    DB ' -- read error!'
MSG7    DB 13,10,'$'
ERRCOUNT DB 2                           ;Number of error retries

READ:   MOV CX,1                        ;Read contents
TRACK_LOOP:
        MOV AH,9                        ;Display formatting message
        MOV DX,OFFSET MSG1
        INT 21H
        INC FTRACK[1]
        CMP FTRACK[1],3AH
        JB TRACK_LOOP_1
        INC FTRACK
        MOV FTRACK[1],'0'
TRACK_LOOP_1:
        MOV ES,MEDIAMSW                 ;Update media descriptor
        MOV BX,MEDIALSW
        MOV WORD PTR ES:[BX+3],1201H    ;18 256-byte sectors per track
        MOV BYTE PTR ES:[BX+5],10       ;Half gap length for sector write
        MOV WORD PTR ES:[BX+7],0FF12H   ;20-byte gap, fill sectors with FF's
        CMP BYTE PTR DRIVE_TYPE,0       ;If 360K drive, density is okay
        JZ DENSITY_OK
        MOV AX,40H
        MOV ES,AX
        MOV BL,DRIVE
        MOV BH,0
        MOV BYTE PTR ES:[90H+BX],74H    ;else enforce 360K mode on 1.2Mb drive
DENSITY_OK:
        MOV AX,512H                     ;Format, 18 sectors
        MOV BX,OFFSET INTERLEAVE
        MOV DH,0
        MOV DL,DRIVE
        PUSH DS
        POP ES
        INT 13H
        PUSH CX                         ;Increment track in DAM table
        MOV CX,18
TRACK_LOOP_2:
        INC BYTE PTR [BX]
        ADD BX,4
        LOOP TRACK_LOOP_2
        POP CX
        CMP HANDLE,0                    ;If a virtual disk is specified, 
        JNZ MAIN_LOOP                   ;transfer its contents
        JMP NO_DATA

MAIN_LOOP:
        MOV AH,9                        ;Display track/sector
        MOV DX,OFFSET MSG3
        INT 21H
        
        PUSH CX                         ;Read sector from virtual disk
        MOV ES,MEDIAMSW                 ;Restore media descriptor
        MOV BX,MEDIALSW
        MOV AX,OLDMEDIA
        MOV ES:[BX+3],AX
        MOV AL,OLDSECGAP
        MOV ES:[BX+5],AL
        MOV AX,OLDGAP
        MOV ES:[BX+7],AX
        MOV AH,3FH                      ;Read 256 bytes
        MOV DX,OFFSET BUFFER
        MOV BX,HANDLE
        MOV CX,256
        INT 21H
        POP CX
        JNB NO_READ_ERROR

        MOV AH,9                        ;Read error branch
        MOV DX,OFFSET MSG6
        INT 21H
        JMP ABORT

NO_READ_ERROR:
        MOV ERRCOUNT,2                  ;Reset retry count
TRY_LOOP:        
        MOV ES,MEDIAMSW                 ;Update media descriptor
        MOV BX,MEDIALSW
        MOV WORD PTR ES:[BX+3],1201H    ;18 256-byte sectors per track
        MOV BYTE PTR ES:[BX+5],10       ;10-byte gap for sector I/O
        CMP BYTE PTR DRIVE_TYPE,0       ;Again verify that media descriptor
        JZ DENSITY_OK1                  ;is okay
        MOV AX,40H
        MOV ES,AX
        MOV BL,DRIVE
        MOV BH,0
        MOV BYTE PTR ES:[BX+90H],74H
DENSITY_OK1:
        MOV AX,301H                     ;Issue write command
        MOV BX,OFFSET BUFFER
        MOV DH,0
        MOV DL,DRIVE
        PUSH DS                         ;Make sure ES: is buffer segment
        POP ES
        INT 13H
        JNB NO_WRITE_ERROR
        DEC ERRCOUNT                    ;If there's an error, retry
        JNZ TRY_LOOP

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
        JZ MAIN_LOOP_1
        CMP AL,'I'                      ;Ignore
        JZ NO_WRITE_ERROR
        CMP AL,'C'                      ;Continuous
        JZ CONTINUOUS
        CMP AL,'A'                      ;Abort
        JNZ KEYSTROKE

ABORT:  MOV DI,MEDIALSW                 ;Abort: Restore old media descriptor
        MOV ES,MEDIAMSW
        MOV AX,OLDMEDIA
        MOV ES:[DI+3],AX
        MOV AL,OLDSECGAP
        MOV ES:[DI+5],AL
        MOV AX,OLDGAP
        MOV ES:[DI+7],AX
        MOV AH,3EH                      ;Close virtual disk file
        INT 21H
        MOV AX,4C00H                    ;Exit
        INT 21H

MAIN_LOOP_1:                            ;For the branch that was out of range
        JMP MAIN_LOOP

CONTINUOUS:
        MOV CONT,1

NO_WRITE_ERROR:
        INC CL                          ;Next sector
        INC SECTOR[1]
        CMP SECTOR[1],3AH
        JB NOT_SECTOR_10
        MOV WORD PTR SECTOR,3031H       ;Roll over ones digit of sector
NOT_SECTOR_10:
        CMP CL,19                       ;18 sectors/track
        JB NEXT
        MOV CL,1
        MOV WORD PTR SECTOR,3130H       ;Reset sector

NO_DATA:                                ;If no source disk, rejoin here
        INC CH                          ;Increment track
        INC TRACK[1]
        CMP TRACK[1],3AH
        JB NOT_TRACK_10
        MOV TRACK[1],'0'                ;Roll over ones digit of track
        INC TRACK
NOT_TRACK_10:
        CMP CH,35                       ;35 tracks
        JNB DONE
        JMP TRACK_LOOP

NEXT:   JMP MAIN_LOOP

DONE:   MOV AH,9                        ;"Done."
        MOV DX,OFFSET MSG8
        INT 21H
        JMP ABORT

MSG8    DB ' -- Done.',13,10,'$'

INTERLEAVE DB 0,0,1,1,0,0,12,1,0,0,5,1  ;Interleave sequence (Track, Head,
        DB 0,0,16,1,0,0,9,1,0,0,2,1     ;Sector, Length)
        DB 0,0,13,1,0,0,6,1,0,0,17,1
        DB 0,0,10,1,0,0,3,1,0,0,14,1
        DB 0,0,7,1,0,0,18,1,0,0,11,1
        DB 0,0,4,1,0,0,15,1,0,0,8,1

PROG    ENDS        

        END START

