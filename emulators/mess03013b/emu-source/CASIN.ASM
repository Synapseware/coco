        TITLE CoCo Emulator SoundBlaster to .CAS Utility
        ;Copyright (C) 1994 Jeff Vavasour

        NAME CASIN

        ASSUME CS:PROG,DS:PROG

STACK   SEGMENT STACK
        DB 512 DUP(?)
STACK   ENDS

PROG    SEGMENT

NAME_PTR DW 0                   ;Will contain offset in DTA for filename
SB_DETECTED DB 0                ;Changes to 4 if SoundBlaster detected
SBPORT  DW 220H                 ;Base address of SoundBlaster port
ENVIRONMENT DW 0                ;Segment containing environment text
VIDEO_SEGMENT DW 0B800H         ;Segment for video RAM to display "*"'s

OLDCLKLO DW 0                   ;Offset of original clock routine
OLDCLKHI DW 0                   ;Segment of original clock routine
OLDKEYLO DW 0                   ;Offset of original keyboard routine
OLDKEYHI DW 0                   ;Segment of original keyboard routine

OLDMASK DB 0                    ;Stores original IRQ mask

T1_TIME DW 1                    ;Number of loops for 0.1ms delay

MSG0    DB 'TRS-80 COLOUR COMPUTER EMULATOR Cassette File Input Utility  '
        DB 'Version 1.1',13,10   
        db 'Copyright (C) 1994 Jeff Vavasour',13,10,10,'$'
MSG1    DB 'Usage: CASIN [/W] [path\]filename[.CAS]',13,10,10
        DB  '      where "filename" is the destination virtual cassette,',13,10
        DB '             "/W" to read from a .WAV file instead of the SoundBlaster input.'
        DB 13,10,'$'
MSG2    DB 'Cannot open virtual cassette file by that name.',13,10,'$'
MSG3    DB 'Could not initialise SoundBlaster',13,10,'$'
MSG4    DB 'Press [ESC] to end.',13,10,10,'$'
MSG5    DB 13,'Recording stopped.',13,10,'$'
MSG6    DB 13,'Error writing cassette file to disk!',13,10,'$'
MSG7    DB 'Matching phase... $'
MSG8    DB 13,'                  ',13,'Ready... $'
MSG8A   DB 13,'                  ',13,'Processing... $'
MSG9    DB 'Source file [.WAV]: $'
MSG10   DB 'Could not open .WAV file by that name.',13,10,'$'
MSG11   DB 'This .WAV file is not a 11025Hz/mono/8-bit sample.  These are usually the ',13,10
        DB 'default settings of WREC.  See your soundcard manual on the use of WREC.',13,10,'$'

WAVNAME DB 0,0,64 DUP(0)        ;Storage area for .WAV filename if given

PARSE:  PUSH DS
        MOV AH,9                ;Display startup message
        PUSH CS
        POP DS
        MOV DX,OFFSET MSG0
        INT 21H
        POP DS
        MOV AX,ES:[2CH]
        MOV CS:ENVIRONMENT,AX
        MOV SI,128              ;Scan command line for filename and parameters
PARSE1: INC SI
        MOV AL,[SI]
        CMP AL,13
        JZ PARSE5
        CMP AL,32
        JZ PARSE1
        CMP AL,'/'
        JNZ PARSE2
        INC SI
        MOV AL,[SI]
        AND AL,223
        CMP AL,'W'
        JNZ PARSE1
        MOV CS:WAVNAME,60
        JMP PARSE1
PARSE2: MOV BL,0                ;BL will be 0 if .CAS needed, non-zero if not
        MOV CS:NAME_PTR,SI
        JMP PARSE6
PARSE5: PUSH CS
        POP DS
        MOV AH,9                ;If no filename specified, display usage
        MOV DX,OFFSET MSG1
        INT 21H
        MOV AX,4C00H            ;and exit
        INT 21H
PARSE6: LODSB
        CMP AL,' '              ;File name parameter ends with a space or
        JZ PARSE8               ;carriage return
        CMP AL,13
        JZ PARSE8
        CMP AL,'.'              ;If a "." detected, an extension was already
        JNZ PARSE7              ;given
        MOV BL,1
        JMP PARSE6
PARSE7: CMP AL,'\'              ;If a "\" detected, the period was part of
        JNZ PARSE6              ;"path" not "filename".
        MOV BL,0
        JMP PARSE6
PARSE8: DEC SI
        CMP BL,0                ;Add .CAS if needed
        JNZ PARSE9
        MOV WORD PTR [SI],432EH ;".CAS"
        MOV WORD PTR [SI+2],5341H
        ADD SI,4
PARSE9: MOV WORD PTR [SI],0     ;Terminating 0 on file name
        MOV AH,3CH              ;Open file for writing
        MOV CX,0
        MOV DX,CS:NAME_PTR
        INT 21H
        PUSH CS
        POP DS
        JNB FILE_OPENED
        MOV AH,9                ;If error opening file
        MOV DX,OFFSET MSG2
        INT 21H
        MOV AX,4C00H
        INT 21H
FILE_OPENED:
        MOV NAME_PTR,AX         ;Save file's handle
        CMP WAVNAME,0
        JZ NOT_WAV
        CALL OPENWAV
        JMP BEGIN
NOT_WAV:
        CALL SBINIT             ;Initialize SoundBlaster
        TEST SB_DETECTED,-1
        JNZ SB_OK
        MOV AH,9
        MOV DX,OFFSET MSG3
        INT 21H
        MOV AX,4C00H
        INT 21H
SB_OK:  MOV AX,3508H            ;Store old clock interrupt
        INT 21H
        MOV OLDCLKLO,BX
        MOV OLDCLKHI,ES
        MOV AX,3509H            ;Store old keyboard interrupt
        INT 21H
        MOV OLDKEYLO,BX
        MOV OLDKEYHI,ES
        MOV AH,9
        MOV DX,OFFSET MSG4
        INT 21H
        PUSH CX
        CALL CALIBRATE          ;Work out timing constants
        POP CX
        IN AL,33
        MOV OLDMASK,AL
        OR AL,1
        OUT 33,AL
        MOV AX,2509H            ;Enable new keyboard routine
        MOV DX,OFFSET KEYBOARD
        INT 21H
BEGIN:  MOV AX,SEG DATA_SEGMENT
        MOV ES,AX
        MOV AL,55H              ;Add 128 $55's at start of buffer
        MOV DI,0
        MOV CX,129
        REP STOSB
        MOV AH,9                ;Display "looking for phase" message
        MOV DX,OFFSET MSG7
        INT 21H
        CALL PHASE              ;Determine ADC levels from header
        MOV AH,9
        MOV DX,OFFSET MSG8
        CMP WAVNAME,0
        JZ NOT_WAV_1
        MOV DX,OFFSET MSG8A
NOT_WAV_1:
        INT 21H
LOCATE_START:                   ;Wait for sync byte
        PUSH AX
        PUSH CX
        CALL GETBIT
        POP CX
        POP AX
        RCR AL,1
        CMP AL,3CH
        JNZ LOCATE_START
        PUSH ES                 ;Display the traditional "**" in upper-right
        MOV ES,VIDEO_SEGMENT
        MOV WORD PTR ES:[156],0E2AH      ;An asterisk in yellow
        MOV WORD PTR ES:[158],0E2AH
        POP ES
REC_BYTE:                       ;Store byte
        STOSB
        MOV CX,8
        TEST DI,15              ;Blink asterisk every 32 bytes
        JNZ REC_BIT
        PUSH ES
        MOV ES,VIDEO_SEGMENT
        XOR BYTE PTR ES:[158],0AH
        POP ES
REC_BIT:                        ;Get next byte
        PUSH AX
        PUSH CX
        CALL GETBIT
        POP CX
        POP AX
        RCR AL,1
        LOOP REC_BIT
        JMP REC_BYTE
DONE:   MOV AH,9                ;Display "stopped" message
        MOV DX,OFFSET MSG5
        INT 21H
        CMP WAVNAME,0
        JNZ WAV_DONE
        MOV AL,OLDMASK          ;Reenable IRQs
        OUT 33,AL
        CALL SBWAIT             ;Shut off SoundBlaster speaker
        MOV AL,0D3H
        OUT DX,AL
        MOV AX,2509H            ;Restore original keyboard handler
        MOV DX,OLDKEYLO
        MOV DS,OLDKEYHI
        INT 21H
        MOV AX,2508H            ;Restore original clock handler
        MOV DX,CS:OLDCLKLO
        MOV DS,CS:OLDCLKHI
        INT 21H
WAV_DONE:
        MOV AX,ES
        MOV DS,AX
        MOV AH,40H              ;Write buffer to disk
        MOV BX,CS:NAME_PTR
        MOV CX,DI
        MOV DX,0
        INT 21H
        JB WRITE_ERROR
        MOV AH,3EH
        INT 21H
        JB WRITE_ERROR
        MOV AX,4C00H            ;Exit to DOS
        INT 21H
WRITE_ERROR:
        PUSH CS
        POP DS
        MOV AH,9
        MOV DX,OFFSET MSG6
        INT 21H
        MOV AX,4C00H
        INT 21H

;Get 8-bit ADC level in AL

RAW_IN  PROC NEAR
        CMP WAVNAME,0
        JNZ RAW_IN_WAV
        CALL SBWAIT
        MOV AL,32
        OUT DX,AL
        CALL SBWAIT
        DEC DX
        DEC DX
        IN AL,DX
        TEST BYTE PTR INVERT,-1
        JZ RAW_IN_0
        NEG AL
RAW_IN_0:
        CMP BYTE PTR ABORT,0
        JNZ RAW_IN_1
        RET
RAW_IN_1:
        JMP DONE
RAW_IN_WAV:                     ;Read a byte from the .WAV file
        PUSH BX
        PUSH CX
        MOV AH,3FH
        MOV BX,WORD PTR WAVNAME[1]
        MOV CX,1
        MOV DX,OFFSET WAVNAME[3]
        INT 21H
        CMP AX,0                ;Exit when done
        JZ RAW_IN_1
        MOV AL,WAVNAME[3]
        POP CX
        POP BX
        TEST BYTE PTR INVERT,-1
        JZ RAW_IN_WAV_1
        NEG AL
RAW_IN_WAV_1:
        RET
RAW_IN  ENDP

;Null clock routine

INTERRUPT_FLAG DB 0             ;This increments each time CLOCK interrupts
COUNT_LSW DW 0                  ;To contain the least-sig word of loop counter
COUNT_MSW DW 0                  ;...most significant word

CLOCK:  PUSH AX
        INC CS:INTERRUPT_FLAG
        CMP CS:INTERRUPT_FLAG,2
        JNZ CLOCK1
        MOV CS:COUNT_LSW,CX     ;On second interrupt after FLAG reset, store
        MOV CS:COUNT_MSW,DX     ;the counter variables
CLOCK1: MOV AL,32               ;Reset interrupt controller
        OUT 32,AL
        POP AX
        IRET

NULL_CLOCK:                     ;This routine prevents clock interference
        PUSH AX
        MOV AL,32
        OUT 32,AL
        POP AX
        IRET
;Keyboard scan, detects only ESC key

ABORT   DB 0            ;Non-zero if abort requested

KEYBOARD:
        PUSH AX
        IN AL,96
        CMP AL,1
        JNZ KEYBOARD1
        MOV CS:ABORT,-1
KEYBOARD1:
        IN AL,97
        OR AL,128
        OUT 97,AL
        AND AL,127
        OUT 97,AL
        MOV AL,32
        OUT 32,AL
        POP AX
        IRET

;SoundBlaster code:  Identify and initialise

SB_STRING DB 'BLASTER=A'

SBINIT  PROC NEAR
        PUSH ES         ;Check for BLASTER=A in environment
        MOV ES,ENVIRONMENT
        MOV DI,0
        MOV BX,0
SBINIT4:
        CMP BYTE PTR ES:[DI],0
        JZ SBINIT7
        MOV SI,OFFSET SB_STRING
        MOV CX,9
        REPZ CMPSB
        JZ SBINIT6
SBINIT5:
        CMP BYTE PTR ES:[DI-1],0
        JZ SBINIT4
        INC DI
        JMP SBINIT5
SBINIT6:                        ;If it was found, get new port address
        MOV AL,ES:[DI]
        INC DI
        SUB AL,'0'
        CMP AL,10
        JB SBINIT6A
        SUB AL,7
SBINIT6A:
        MOV CL,4
        SHL BX,CL
        MOV AH,0
        ADD BX,AX
        CMP BYTE PTR ES:[DI],'0'
        JNB SBINIT6
        MOV SBPORT,BX
SBINIT7:
        POP ES
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
SBINIT3:                        ;SoundBlaster detected, set mask bit
        MOV SB_DETECTED,4
        CALL SBWAIT
        MOV AL,0D1H             ;Turn on speaker
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

;Intercept the 18.2Hz clock, count number of instructions between interrupts
;to establish delay loop lengths

CALIBRATE PROC NEAR
        MOV AX,2508H
        MOV DX,OFFSET CLOCK
        INT 21H
        MOV CX,0
        MOV DX,0
        MOV INTERRUPT_FLAG,0
CALIBRATE1:                     ;Wait until a clock interrupt occurs
        CMP INTERRUPT_FLAG,0
        JZ CALIBRATE1
CALIBRATE2:
        LOOP CALIBRATE2
        INC DX
        CMP INTERRUPT_FLAG,2    ;Loop until a second interrupt has occurred
        JB CALIBRATE2  
        MOV AX,2508H            ;Disable clock during sound output
        MOV DX,OFFSET NULL_CLOCK
        INT 21H
        MOV DX,COUNT_MSW
        MOV AX,COUNT_LSW
        MOV BX,606              ;11025Hz is 1/606 of a 18.2Hz interval
        DIV BX
        CMP AX,1                ;Make sure it's not zero
        ADC AX,0
        MOV T1_TIME,AX
        RET
CALIBRATE ENDP

;This macro is a 0.1ms delay

WAIT_100us MACRO
        LOCAL DELAY
        MOV CX,T1_TIME
DELAY:  LOOP DELAY
        ENDM

;Match phase with signal.  Signal may be inverted (i.e. -sin(t) instead of
;sin(t) ), which will be indicated by INVERT being non-zero.  Phase is 
;determined by requiring that we pick up at least 64 bits from the $55's
;in the leader, which are recognised by alternating 1's and 0's.  If the
;signal has the wrong sign (value of INVERT), inputs will be out of phase
;by half a cycle, picking up half a "1" and half a "0", making every bit
;look the same with a 1600Hz cycle.

INVERT  DB 0                    ;If non-zero, signal is -sin(t) not sin(t)
TIMEOUT DB 0                    ;When non-zero, 5 second timeout enabled

PHASE   PROC NEAR
        MOV CX,32               ;Want to detect 32 1-0 or 0-1 cycles
        PUSH CX
        CALL GETBIT             ;Read the first bit
        JNB PHASE2              ;If it's a zero, the next better be a one
        POP CX                  ;Otherwise, if it's a one...
PHASE1: PUSH CX
        CALL GETBIT             ;The next one better be a zero
        JB PHASE3               ;If not, invert signal
PHASE2: CALL GETBIT             ;The next one better be a one
        JNB PHASE3              ;If not, invert signal
        POP CX
        LOOP PHASE1             ;Loop until 32 0-1's or 1-0's found
        MOV TIMEOUT,-1          ;Enable GETBIT timeout
        RET
PHASE3: POP CX
        NOT INVERT              ;Invert when needed
        CALL GETBIT             ;Make sure in phase with next bit time before
        CALL GETBIT             ;trying again
        JMP PHASE
PHASE   ENDP

;Wait for a clock pulse and a 0 or 1 bit signal.  Will timeout to DONE
;routine if no clock pulse received after 5 seconds.

GETBIT  PROC NEAR
        MOV BP,55125            ;Reset timeout counter
        MOV BX,0
INPUT_HIGH:                     ;Measure length of positive half-wave
        INC BX
        CALL RAW_IN
        WAIT_100us
        CMP AL,125
        JB INPUT_LOW
        DEC BP                  ;Loop until timeout
        JNZ INPUT_HIGH
        CMP TIMEOUT,0           ;Don't timeout if timeout disabled (during
        JZ INPUT_HIGH           ;phase matching)
        JMP DONE
INPUT_LOW:                      ;Now measure length of negative half-wave
        INC BX
        CALL RAW_IN
        WAIT_100us
        CMP AL,131
        JA BIT_DONE
        DEC BP
        JNZ INPUT_LOW
        CMP TIMEOUT,0
        JZ INPUT_LOW
        JMP DONE
BIT_DONE:                       ;If less than 8 samples for a full wave, it's
        CMP BX,8                ;a "1" else it's a "0"
        RET
GETBIT  ENDP

;If a .WAV file is selected for input, get its name

OPENWAV PROC NEAR
        MOV AH,9                ;Prompt for name
        MOV DX,OFFSET MSG9
        INT 21H
        MOV AH,10
        MOV DX,OFFSET WAVNAME
        INT 21H
        MOV AH,2                ;Linefeed after prompt
        MOV DL,10
        INT 21H
        MOV AH,2
        INT 21H
        MOV SI,OFFSET WAVNAME+2 ;Determine if the extension was already
        MOV BL,0                ;given
PARSEWAV:
        LODSB
        CMP AL,'.'
        JNZ PARSEWAV1
        MOV BL,1
PARSEWAV1:
        CMP AL,'\'
        JNZ PARSEWAV2
        MOV BL,0
PARSEWAV2:
        CMP AL,13
        JNZ PARSEWAV
        CMP BL,0
        JNZ ALREADY_EXT         ;Add extension only if not explicitly given
        MOV WORD PTR [SI-1],572EH
        MOV WORD PTR [SI+1],5641H
        ADD SI,4
ALREADY_EXT:
        MOV BYTE PTR [SI-1],0
        MOV AX,3D00H            ;Open .WAV file
        MOV DX,OFFSET WAVNAME+2
        INT 21H
        JNB WAV_OK
        MOV DX,OFFSET MSG10
WAV_ERROR:        
        MOV AH,9
        INT 21H
        MOV AX,4C00H
        INT 21H
WAV_OK: MOV WORD PTR WAVNAME[1],AX
        MOV BX,AX
        MOV AH,3FH              ;Get .WAV header
        MOV CX,2CH
        MOV DX,OFFSET WAVNAME[3]
        INT 21H
        MOV DX,OFFSET MSG11
        CMP WORD PTR WAVNAME[1BH],2B11H
        JNZ WAV_ERROR           ;Make sure it's 11025Hz
        CMP WAVNAME[19H],1
        JNZ WAV_ERROR           ;Mono
        CMP WAVNAME[25H],8
        JNZ WAV_ERROR           ;8-bit
        CMP WORD PTR WAVNAME[1FH],2B11H
        JNZ WAV_ERROR           ;Single byte per sample (no multichannel)
        RET                     ;Save handle for WAV and return
OPENWAV ENDP

PROG    ENDS

DATA_SEGMENT SEGMENT
        DB 0                    ;This is where the .CAS file will be loaded
DATA_SEGMENT ENDS

        END PARSE

