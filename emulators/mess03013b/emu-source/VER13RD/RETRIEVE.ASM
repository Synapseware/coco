        TITLE CoCo Real-to-Virtual Disk Transfer
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
        CMP WORD PTR [SI],722FH         ;"/r" option
        JZ ROM_REQUEST
        CMP WORD PTR [SI],522FH         ;"/R" option
        JNZ NO_ROM_REQUEST
ROM_REQUEST:        
        MOV BYTE PTR CS:ROM,-1          ;If so, set flag
        INC SI
        JMP PARSE
NO_ROM_REQUEST:
        CMP WORD PTR [SI+1],203AH       ;If current character followed by ": "
        JNZ PARSE1                      ;it's a source drive designation
        MOV AL,[SI]                     ;Work out drive number
        ADD SI,2
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

ERROR1: MOV AH,9                        ;Error trap routine, bad syntax
        PUSH CS
        POP DS
        MOV DX,OFFSET MSG1
        INT 21H
        MOV AX,4C00H                    ;Exit
        INT 21H

MSG1    DB 'Usage: RETRIEVE [/R] [d:] [path\]diskname[.DSK]',13,10
        DB '         "d:"         source drive (default A:)',13,10
        DB '         "path"       destination directory for virtual disk',13,10
        DB '         "diskname"   name of virtual disk',13,10
        DB '         /R           if retrieving ROM image only',13,10,'$'

DRIVE   DB 0                            ;Default source drive=A:
HANDLE  DW ?                            ;Virtual disk file handle
ROM     DB 0                            ;Non-zero => terminate after 32K

OPEN:   MOV AH,3CH                      ;Create the virtual disk file
        MOV CX,0
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
MEDIALSW DW ?                           ;Media address
MEDIAMSW DW ?

MSG2    DB 'Unable to create specified virtual disk.',13,10,'$'

MEDIA:  MOV AX,351EH                    ;Get media descriptor address
        INT 21H
        MOV MEDIALSW,BX
        MOV MEDIAMSW,ES
        MOV AX,ES:[BX+3]                ;Save original setting
        MOV OLDMEDIA,AX
        MOV AX,2523H                    ;Set CTRL-C abort vector
        MOV DX,OFFSET ABORT
        INT 21H
        MOV AX,440DH                    ;Determine drive type
        MOV BH,0
        MOV BL,DRIVE
        INC BL
        MOV CX,0860H
        MOV DX,OFFSET BUFFER
        INT 21H
        MOV AL,BUFFER[1]
        MOV DRIVE_TYPE,AL
        JMP READ

BUFFER  DB 256 DUP(?)
CONT    DB 0
DRIVE_TYPE DB 0

MSG3    DB 13,'Reading track '
TRACK   DB '00, sector '
SECTOR  DB '01 $'
MSG4    DB ' -- read error!',13,10,'$'
MSG5    DB 'Abort, Retry, Ignore, or Continuous? $'
MSG6    DB ' -- write error!'
MSG7    DB 13,10,'$'
ERRCOUNT DB 2                           ;Number of error retries

READ:   MOV CX,1                        ;Read contents
MAIN_LOOP:
        MOV AH,9                        ;Display track/sector
        MOV DX,OFFSET MSG3
        INT 21H
        MOV ERRCOUNT,2                  ;Reset retry count
TRY_LOOP:        
        MOV ES,MEDIAMSW                 ;Update media descriptor
        MOV BX,MEDIALSW
        MOV WORD PTR ES:[BX+3],1201H    ;18 256-byte sectors per track
        CMP BYTE PTR DRIVE_TYPE,0
        JZ DENSITY_OK
        MOV AX,40H                      ;If not a 360K drive, correct media
        MOV ES,AX                       ;descriptor
        MOV BL,DRIVE
        MOV BH,0
        MOV BYTE PTR ES:[BX+90H],74H
DENSITY_OK:
        MOV AX,201H                     ;Issue read command
        MOV BX,OFFSET BUFFER
        MOV DH,0
        MOV DL,DRIVE
        PUSH DS                         ;Make sure ES: is buffer segment
        POP ES
        INT 13H
        JNB NO_READ_ERROR
        DEC ERRCOUNT                    ;If there's an error, retry
        JNZ TRY_LOOP

        MOV AH,9                        ;Read error branch
        MOV DX,OFFSET MSG4              ;Display error message
        INT 21H
        CMP CONT,0                      ;If continuous, ignore
        JNZ NO_READ_ERROR
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
        JZ MAIN_LOOP
        CMP AL,'I'                      ;Ignore
        JZ NO_READ_ERROR
        CMP AL,'C'                      ;Continuous
        JZ CONTINUOUS
        CMP AL,'A'                      ;Abort
        JNZ KEYSTROKE

ABORT:  MOV DI,MEDIALSW                 ;Abort: Restore old media descriptor
        MOV ES,MEDIAMSW
        MOV AX,OLDMEDIA
        MOV ES:[DI+3],AX
        MOV AH,3EH                      ;Close virtual disk file
        INT 21H
        MOV AX,4C00H                    ;Exit
        INT 21H

CONTINUOUS:
        MOV CONT,1

NO_READ_ERROR:                          ;Write sector to virtual disk
        PUSH CX
        MOV ES,MEDIAMSW                 ;Restore media descriptor
        MOV BX,MEDIALSW
        MOV AX,OLDMEDIA
        MOV ES:[BX+3],AX
        MOV AH,40H                      ;Write 256 bytes
        MOV DX,OFFSET BUFFER
        MOV BX,HANDLE
        MOV CX,256
        INT 21H
        POP CX
        JNB NO_WRITE_ERROR

        MOV AH,9                        ;Write error branch
        MOV DX,OFFSET MSG6
        INT 21H
        JMP ABORT

NO_WRITE_ERROR:
        INC CL                          ;Next sector
        INC SECTOR[1]
        CMP SECTOR[1],3AH
        JB NOT_SECTOR_10
        MOV WORD PTR SECTOR,3031H       ;Roll over ones digit of sector
NOT_SECTOR_10:
        CMP BYTE PTR ROM,0              ;Terminate when ROM done?
        JZ NO_ROM_REQUEST_1
        CMP CX,508H
        JZ DONE
NO_ROM_REQUEST_1:
        CMP CL,19                       ;18 sectors/track
        JB NEXT
        MOV CL,1
        MOV WORD PTR SECTOR,3130H       ;Reset sector
        INC CH                          ;Increment track
        INC TRACK[1]
        CMP TRACK[1],3AH
        JB NOT_TRACK_10
        MOV TRACK[1],'0'                ;Roll over ones digit of track
        INC TRACK
NOT_TRACK_10:
        CMP CH,35                       ;35 tracks
        JNB DONE
NEXT:   JMP MAIN_LOOP

DONE:   MOV AH,9                        ;"Done."
        MOV DX,OFFSET MSG8
        INT 21H
        JMP ABORT

MSG8    DB ' -- Done.',13,10,'$'

PROG    ENDS        

        END START

