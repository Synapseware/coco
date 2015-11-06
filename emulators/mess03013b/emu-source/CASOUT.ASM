        TITLE TRS-80 Colour Computer Emulator .CAS to SoundBlaster Utility
        ;Copyright (C) 1994 Jeff Vavasour

        NAME CASOUT

        ASSUME CS:PROG,DS:PROG

STACK   SEGMENT STACK
        DB 512 DUP(?)
STACK   ENDS

PROG    SEGMENT

NAME_PTR DW 0                   ;Will contain offset in DTA for filename
SBVOL   DB 0                    ;SoundBlaster volume: 0=loudest, 7=quietest
SB_DETECTED DB 0                ;Changes to 4 if SoundBlaster detected
SBPORT  DW 220H                 ;Base address of SoundBlaster port
ENVIRONMENT DW 0                ;Segment containing environment text
DELAY   DW 64                   ;Inter-block delay
OLDCLKLO DW 0                   ;Offset of original clock routine
OLDCLKHI DW 0                   ;Segment of original clock routine
OLDKEYLO DW 0                   ;Offset of original keyboard routine
OLDKEYHI DW 0                   ;Segment of original keyboard routine

OLDMASK DB 0                    ;Stores original IRQ mask

WAVNAME DB 0,0,64 DUP(0)        ;Storage area for .WAV filename if given

MSG0    DB 'TRS-80 COLOUR COMPUTER EMULATOR Cassette File Output Utility  '
        DB 'Version 1.1',13,10   
        db 'Copyright (C) 1994, 2001 Jeff Vavasour',13,10,10,'$'
MSG1    DB 'Usage: CASOUT [/Vn] [/W] [path\]filename[.CAS]',13,10,10
        DB '       where "filename" is the source virtual cassette file,',13,10
        DB '             "/Vn" sets volume level "n" (0=quietest, 7=loudest)',13,10
        DB '             "/W" to write to a .WAV file instead of SoundBlaster output.'
        DB 13,10,'$'
MSG2    DB 'Cannot open virtual cassette file by that name',13,10,'$'
MSG3    DB 'Could not initialise SoundBlaster',13,10,'$'
MSG4    DB 'Press [ESC] to abort. $'
MSG5    DB 13,'End of cassette file.',13,10,'$'
MSG6    DB 'Could not create .WAV file by that name.',13,10,'$'
MSG7    DB 'Error writing to .WAV file!',13,10,'$'
MSG8    DB 'Output file [.WAV]: $'

;34-byte .WAV file header
WAVHEADER DB 'RIFF'
L1LSW   DW 0                    ;File length-8
L1MSW   DW 0
        DB 'WAVEfmt '
        DB 16,0,0,0,1,0,1,0
        DW 2B11H,0,2B11H        ;Sampling frequency and bytes per second
        DB 0,0,1,0,8,0,'data'
L2LSW   DW 0                    ;File length-2CH
L2MSW   DW 0

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
        CMP BYTE PTR [SI],'/'   ;Look for command line switches
        JZ PARSE2
        CMP CS:NAME_PTR,0
        JNZ PARSE1
        MOV CS:NAME_PTR,SI
        JMP PARSE1
PARSE2: INC SI
        MOV AL,[SI]
        AND AL,223
        CMP AL,'V'
        JNZ PARSE4
        INC SI
        MOV AL,[SI]
        SUB AL,'0'
        JB PARSE4
        CMP AL,7
        JA PARSE4
        MOV AH,7                ;Internally SBVOL runs 0 to 7 rather than 7
        SUB AH,AL               ;to 0 (scale is reversed)
        MOV CS:SBVOL,AH
PARSE4: CMP AL,'W'              ;.WAV output option
        JNZ PARSE10
        MOV CS:WAVNAME,60
PARSE10:
        MOV AL,[SI]             ;After a command line switch has been 
        CMP AL,13               ;accounted for, look for next parameter
        JZ PARSE5
        CMP AL,'/'
        JZ PARSE2
        CMP AL,' '
        JZ PARSE1
        INC SI
        JMP PARSE4
PARSE5: MOV SI,CS:NAME_PTR
        MOV BL,0                ;BL will be 0 if .CAS needed, non-zero if not
        CMP SI,0
        JNZ PARSE6
        PUSH CS
        POP DS
        MOV AH,9                ;If no filename specified, display usage
        MOV DX,OFFSET MSG1
        INT 21H
        MOV AX,4C00H            ;and exit
        INT 21H
PARSE6: LODSB
        CMP AL,'/'              ;File name parameter ends with "/", space, or
        JZ PARSE8               ;carriage return
        CMP AL,' '
        JZ PARSE8
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
        MOV AX,3D00H            ;Open file for reading
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
        JMP SB_OK
NOT_WAV:
        CALL SBINIT             ;Initialize SoundBlaster
        TEST SB_DETECTED,-1
        JNZ SB_OK
        MOV AH,9
        MOV DX,OFFSET MSG3
        INT 21H
        MOV AX,4C00H
        INT 21H
SB_OK:  MOV AX,SEG DATA_SEGMENT ;Read up to 65534 bytes into buffer
        MOV BX,NAME_PTR
        MOV DS,AX
        MOV ES,AX
        MOV AH,3FH
        MOV CX,-2
        MOV DX,0
        INT 21H
        MOV DI,AX
        MOV AL,55H              ;Tack on a terminating byte just in case it
        STOSB
        MOV CX,DI               ;CX will contain the length of file
        MOV AH,3EH              ;Close file
        INT 21H
        PUSH CS
        POP DS
        CALL SHIFT_BITS         ;Align bit fields to sync byte
        CMP WAVNAME,0
        JNZ WAV_OUTPUT
        PUSH ES
        MOV AX,3508H            ;Store old clock interrupt
        INT 21H
        MOV OLDCLKLO,BX
        MOV OLDCLKHI,ES
        MOV AX,3509H            ;Store old keyboard interrupt
        INT 21H
        MOV OLDKEYLO,BX
        MOV OLDKEYHI,ES
        POP ES
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
WAV_OUTPUT:
        JCXZ FINISHED           ;If file null-length, the exit
        MOV SI,0
        CALL PLAY_BYTE          ;Send one byte
        DEC CX
        JZ FINISHED
OUTPUT_HEADER:                  ;Output the leading $55's
        CMP BYTE PTR ES:[SI],3CH
        JZ OUTPUT_NAME
        CALL PLAY_BYTE
        CMP BYTE PTR ABORT,0
        JNZ DONE
        LOOP OUTPUT_HEADER
        JMP FINISHED
OUTPUT_NAME:                    ;Complete the Namefile block
        CALL PLAY_BYTE          ;Output the sync byte, $3C
        DEC CX
        JZ FINISHED
        MOV DELAY,64            ;Default delay of four 0 bit times
        CMP BYTE PTR ES:[SI],0  ;Check for block type
        JNZ NOT_NAMEFILE
        MOV DELAY,9600          ;Namefile block gets 0.5s delay
NOT_NAMEFILE:
        CALL PLAY_BYTE          ;Output block type
        DEC CX
        JZ FINISHED
        MOV BL,ES:[SI]          ;Get block length, add 3 bytes: one each for
        MOV BH,0                ;length, checksum and trailing $55
        ADD BX,3
NAME1:  CALL PLAY_BYTE          ;Output remainder of Namefile block
        DEC CX
        JZ FINISHED
        CMP BYTE PTR ABORT,0
        JNZ DONE
        DEC BX
        JNZ NAME1
        PUSH CX
        MOV BX,DELAY            ;Delay 0.5s after Namefile block, 1/300th of
NAME2:  MOV AL,128              ;a second after all other blocks
        CALL DAC_LEVEL
        DEC BX
        JNZ NAME2
        POP CX
        JMP OUTPUT_HEADER
FINISHED:                       ;Same as DONE, but prints a message
        MOV AH,9
        MOV DX,OFFSET MSG5
        INT 21H
DONE:   CMP WAVNAME,0
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
        MOV AX,4C00H            ;Exit to DOS
        INT 21H
WAV_DONE:
        CALL CLOSEWAV
        MOV AX,4C00H
        INT 21H

;Send a single byte of data through the SoundBlaster in CoCo cassette
;format

SINE_TABLE DB 128,176,217,245,255,245,217,176,128,79,38,10,1,10,38,79

PLAY_BYTE:
        MOV AL,ES:[SI]
        INC SI
        PUSH BX
        PUSH CX
        MOV CX,8
PLAY_BIT:
        ROR AL,1
        PUSH AX
        LAHF                    ;Save carry, indicating a "0" or "1" bit
        MOV BX,OFFSET SINE_TABLE
PLAY_BIT_1:                     ;Read a byte off sine table and set DAC level
        MOV AL,[BX]
        CALL DAC_LEVEL
        SAHF
        ADC BX,1                ;Go through table 2 bytes at a time for 2400Hz
        CMP BX,OFFSET SINE_TABLE+16
        JB PLAY_BIT_1
        POP AX                  ;Loop for all 8 bits in byte
        LOOP PLAY_BIT
        POP CX
        POP BX
        RET

;Set DAC level based on value in AL

WAVDATA DB 0

num_lsw dw 0
num_msw dw 0
denom   dw 0

DAC_LEVEL:
        PUSH CX
        MOV CL,SBVOL
        SHR AL,CL
        POP CX
        CMP WAVNAME,0           ;If we're writing a .WAV file, output a
        JNZ WAVPULSE            ;block of data to instead
        PUSH AX
        CALL SBWAIT
        MOV AL,16
        OUT DX,AL
        CALL SBWAIT
        POP AX
        OUT DX,AL
        PUSH CX                 ;Delay for next 19200Hz interval
T1_TIME:
        MOV CX,1
DAC_LEVEL_1:
        LOOP DAC_LEVEL_1
        POP CX
        RET
WAVPULSE:
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        mov cx,denom
        cmp cx,19200-11025
        jb tick_incomplete
        mov ah,0
        push ax
        mov bx,19200
        sub bx,cx
        mul bx
        add ax,num_lsw
        adc dx,num_msw
        mov bx,19200
        div bx
        mov wavdata,al
        add cx,11025-19200
        mov denom,cx
        pop ax
        mul cx
        mov num_lsw,ax
        mov num_msw,dx
        MOV AH,40H
        MOV BX,WORD PTR WAVNAME[1]
        MOV CX,1
        MOV DX,OFFSET WAVDATA
        INT 21H
        JB WAVERROR
        POP DX
        POP CX
        POP BX
        POP AX
        RET
WAVERROR:
        MOV AH,9
        MOV DX,OFFSET MSG7
        INT 21H
        JMP DONE
tick_incomplete:
        mov bx,11025
        add denom,bx
        mov ah,0
        mul bx
        add num_lsw,ax
        adc num_msw,dx
        pop dx
        pop cx
        pop bx
        pop ax
        ret

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

SBINIT:
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

;Wait for SoundBlaster command port

SBWAIT:
        MOV DX,SBPORT
        ADD DX,12
SBWAIT1:
        IN AL,DX
        ROL AL,1
        JB SBWAIT1
        RET

;Intercept the 18.2Hz clock, count number of instructions between interrupts
;to establish delay loop lengths

CALIBRATE:
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
        MOV DX,COUNT_MSW
        MOV AX,COUNT_LSW
        NOT AX
        MOV BX,1055             ;19200Hz interval is 1/1055th a 18.2Hz one
        DIV BX
        CMP AX,1                ;Make sure counter is not 0
        ADC AX,0
        MOV WORD PTR T1_TIME[1],AX
        MOV INTERRUPT_FLAG,0
CALIBRATE3:
        CMP INTERRUPT_FLAG,0
        JZ CALIBRATE3
        MOV CX,1055             ;Make sure we got it right
CALIBRATE4:
        MOV AL,128
        PUSH CX
        CALL DAC_LEVEL
        POP CX
        CMP INTERRUPT_FLAG,2
        LOOPNZ CALIBRATE4
        SUB CX,1055             ;Figure out how many clock cycles we came
        NEG CX                  ;up short and rescale by them
        MOV AX,WORD PTR T1_TIME[1]
        MUL CX
        MOV CX,1055
        DIV CX
        CMP AX,1                ;Make sure counter is not 0
        ADC AX,0
        MOV WORD PTR T1_TIME[1],AX
        MOV AX,2508H            ;Disable clock during sound output
        MOV DX,OFFSET NULL_CLOCK
        INT 21H
        RET

;This will make sure that a virtual cassette's bit alignment is correct,
;so that characters are not spread across the lower half of one byte and
;the upper half of another.  This is accomplished by shifting the bits
;until the first character that's neither a $55 or $AA is a $3C, the sync
;byte.

SHIFT_BITS:
        MOV BL,8                ;Only shift the file 8 times
        CMP CX,2                ;There's got to be at least 2 bytes in the
        JNB SHIFT_BITS_1        ;for this to work
        RET
SHIFT_BITS_1:
        PUSH CX
        DEC CX
        MOV DI,1
        MOV AL,ES:[DI]          ;Leader will be a bunch of $AA's or $55's
        REPZ SCASB              ;Look for the first non-leader byte excluding
        POP CX                  ;the first one
        JNZ SHIFT_BITS_2
        RET                     ;If file is leader, forget it
SHIFT_BITS_2:
        MOV SI,CX               ;Set pointer to end of file
        DEC SI
        CLC
        LAHF
        CMP BYTE PTR ES:[DI-1],3CH
        JNZ SHIFT_BITS_3        ;If the first non-leader byte is a $3C, we're
        RET                     ;done
SHIFT_BITS_3:
        SAHF
        RCR BYTE PTR ES:[SI],1  ;Shift every byte right one bit field
        LAHF
        DEC SI
        JNZ SHIFT_BITS_3
        SAHF                    ;Byte at offset 0 is not done by the loop
        RCR BYTE PTR ES:[SI],1
        DEC BL
        JNZ SHIFT_BITS_1
        RET                     ;No sync byte found after 8 shifts, return

;If a .WAV file is selected for input, get its name

OPENWAV:
        MOV AH,9                ;Prompt for name
        MOV DX,OFFSET MSG8
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
        MOV AH,3CH              ;Create .WAV file
        MOV CX,0
        MOV DX,OFFSET WAVNAME+2
        INT 21H
        JNB WAV_OK
        MOV DX,OFFSET MSG6
        MOV AH,9
        INT 21H
        MOV AX,4C00H
        INT 21H
WAV_OK: MOV WORD PTR WAVNAME[1],AX
        MOV BX,AX
        MOV AX,4200H            ;Position past .WAV header area
        MOV CX,0                ;That will be written when the file is closed
        MOV DX,2CH
        INT 21H
        RET                     ;Save handle for WAV and return

;Close .WAV file and fix length fields in header

CLOSEWAV:
        MOV AX,4202H
        MOV BX,WORD PTR WAVNAME[1]
        MOV CX,0
        MOV DX,0
        INT 21H
        SUB AX,8                ;First field is length-8
        SBB DX,0
        MOV L1LSW,AX
        MOV L1MSW,DX
        SUB AX,24H              ;Second field is length-2CH
        SBB DX,0
        MOV L2LSW,AX
        MOV L2MSW,DX
        MOV AX,4200H            ;Return to beginning of file
        MOV CX,0
        MOV DX,0
        INT 21H
        MOV AH,40H              ;Write header
        MOV CX,2CH
        MOV DX,OFFSET WAVHEADER
        INT 21H
        MOV AH,3EH
        INT 21H
        RET

PROG    ENDS

DATA_SEGMENT SEGMENT
        DB 0                    ;This is where the .CAS file will be loaded
DATA_SEGMENT ENDS

        END PARSE

