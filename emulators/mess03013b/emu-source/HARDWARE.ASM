        TITLE Colour Computer Device Memory Handler
        ;Copyright (C) 1993-1995,2001 Jeff Vavasour

        ASSUME CS:PROG,DS:PROG
PROG    SEGMENT PUBLIC 'CODE'

        PUBLIC DEV_W8,DEV_R8,DEV_W16,DEV_R16,LINK_READ,LINK_WRITE,DRB2,DRB1
        PUBLIC CRB1,RAMHERE,READ,WRITE,CART_FLAG,CRB2,CRA1

        PUBLIC FDC_TRACK,FDC_SECTOR,DRIVE_SEL

        EXTRN DRA1_MATRIX:BYTE,NEW_TOP:WORD,NEW_BOTTOM:WORD,REVISE:NEAR
        EXTRN FONT_128R:BYTE,FONT_128C:BYTE,FONT_256R:BYTE,FONT_64C:BYTE
        EXTRN NEW_WIDTH:BYTE,NEW_DIV:BYTE,NEWSET:WORD,SBMASK:BYTE,SBWAIT:NEAR
        EXTRN HANDLE:WORD,COUNTDOWN:BYTE,PATHS:BYTE,WR_PROT:BYTE,LASTKEY:BYTE
        EXTRN DTA:BYTE,NMI:NEAR,IRQ:NEAR,LJOYSTK:BYTE,RJOYSTK:BYTE,REGFI:BYTE
        EXTRN MOUSE_X:BYTE,MOUSE_Y:BYTE,FIRE:BYTE,SOUND:BYTE,NEED_REVISE:NEAR
        EXTRN PULSE:BYTE,ARTIFACT:BYTE,ADDLF:BYTE,GAXPOS:BYTE,GAYPOS:BYTE
        EXTRN GBXPOS:BYTE,GBYPOS:BYTE,VOLUME:BYTE,PAGE_STATUS:BYTE
        EXTRN ROM_STATUS:BYTE,CASMODE:BYTE,CAS_BIT:BYTE,CART_INT:NEAR
        EXTRN CAS_CYCLE:BYTE,CHANDLE:WORD

        EXTRN SPINUP:NEAR,PHYS_READ:NEAR,PHYS_WRITE:NEAR,DRIVE_STATUS:NEAR
        EXTRN FORMAT:NEAR

;General FFxxH page I/O function lookup (byte and word)

DEV_R8  PROC NEAR
        ROL BX,1
        CALL READ[BX+511]
        ROR BX,1
        RET
DEV_R8  ENDP

DEV_W8  PROC NEAR
        ROL BX,1
        CALL WRITE[BX+511]
        ROR BX,1
        RET
DEV_W8  ENDP

DEV_R16 PROC NEAR
        ROL BX,1
        CALL READ[BX+511]
        MOV AH,AL
        INC BX
        INC BX
        CALL READ[BX+511]
        ROR BX,1
        DEC BX
        RET
DEV_R16 ENDP

DEV_W16 PROC NEAR
        ROL BX,1
        XCHG AH,AL
        CALL WRITE[BX+511]
        XCHG AH,AL
        INC BX
        INC BX
        CALL WRITE[BX+511]
        ROR BX,1
        DEC BX
        RET
DEV_W16 ENDP

;Nifty routines which other programs can call to link in devices to FFxxH

LINK_READ:
        CMP DI,0FF00H
        JB NO_LINK
        ROL DI,1
        MOV READ[DI+511],DX
        ROR DI,1
NO_LINK:
        RET

LINK_WRITE:
        CMP DI,0FF00H
        JB NO_LINK
        ROL DI,1
        MOV WRITE[DI+511],DX
        RET

;No function read and write 

NR      PROC NEAR
        MOV ES,SS:[4]
        ROR BX,1
        MOV AL,ES:[BX]
        ROL BX,1
        RET
NR      ENDP

NW      PROC NEAR
;        ROR BX,1
;        MOV ES:[BX],AL
;        ROL BX,1
        RET
NW      ENDP

;PIA1 support - keyboard matrix

FF00W   PROC NEAR
        TEST BYTE PTR CRA1,4
        JNZ FF00W_1
        MOV DDRA1,AL
FF00W_1:
        RET
FF00W   ENDP

FF01W   PROC NEAR
        MOV CRA1,AL
        RET
FF01W   ENDP

FF02W   PROC NEAR
        TEST BYTE PTR CRB1,4
        JZ FF02W_1
        MOV DRB1,AL
        RET
FF02W_1:
        MOV DDRB1,AL
        RET
FF02W   ENDP

FF03W   PROC NEAR
        MOV CRB1,AL
        RET
FF03W   ENDP

CRA1    DB 4
DDRA1   DB 0
CRB1    DB 4
DRB1    DB -1
DDRB1   DB -1

FF00R   PROC NEAR
        TEST BYTE PTR CRA1,4
        JNZ FF00R_0
        MOV AL,DDRA1
        RET
FF00R_0:
        PUSH BX
        MOV BH,0
        MOV BL,DRB1
        MOV AL,DRA1_MATRIX[BX]
        AND AL,FIRE
        MOV BL,LJOYSTK  ;Joystick select.  Bit 3 of CRA1 set => left joystick
        TEST BYTE PTR CRB1,8
        JNZ FF00R_1
        MOV BL,RJOYSTK
FF00R_1:
        TEST BYTE PTR CRA1,8
        JZ FF00R_2      ;Bit 3 of CRB1 set => vertical position read
        ADD BL,8
FF00R_2:
        CALL JOYSTICK[BX]
        POP BX
        RET
FF00R   ENDP

JOYSTICK DW MOUSE_H     ;Handlers for joystick (mouse, game port left/right,
        DW GAME_AH      ;or none)
        DW GAME_BH
        DW NO_STICK
        DW MOUSE_V
        DW GAME_AV
        DW GAME_BV  
        DW NO_STICK

        EXTRN HSYNC_PULSE:BYTE

FF01R   PROC NEAR
        MOV AL,CRA1
        AND AL,31
        OR AL,HSYNC_PULSE
        MOV HSYNC_PULSE,0       ;Reset HSYNC interrupt pending
        RET
FF01R   ENDP

FF02R   PROC NEAR
        TEST BYTE PTR CRB1,4
        JZ FF02R_1
        MOV PULSE,0             ;Reset bit 7 of CRB1 (clock interrupt flag)
        MOV AL,DRB1
        RET
FF02R_1:
        MOV AL,DDRB1
        RET
FF02R   ENDP

FF03R   PROC NEAR
        MOV AL,CRB1
        AND AL,31
        OR AL,PULSE             ;Include clock interrupt flag
        RET
FF03R   ENDP

;SAM - video memory base/length controller

V012    DW 0

V_LENGTH DW 512
        DW 1024
        DW 2048
        DW 1536
        DW 3072
        DW 3072
        DW 6144
        DW 6144

UPDATE_BOTTOM MACRO
        PUSH AX
        PUSH DX
        PUSH DI
        MOV DI,V012
        SHL DI,1
        MOV AX,V_LENGTH[DI]
        ADD AX,NEW_TOP
        MOV NEW_BOTTOM,AX
        POP DI
        POP DX
        POP AX
        CALL NEED_REVISE
        RET
        ENDM

FFC0W:  AND V012,6
        UPDATE_BOTTOM
FFC1W:  OR V012,1
        UPDATE_BOTTOM
FFC2W:  AND V012,5
        UPDATE_BOTTOM
FFC3W:  OR V012,2
        UPDATE_BOTTOM
FFC4W:  AND V012,3
        UPDATE_BOTTOM
FFC5W:  OR V012,4
        UPDATE_BOTTOM

CLEAR_BASE MACRO ADDRESS
        PUSH AX
        MOV AX,NEW_TOP
        SUB NEW_BOTTOM,AX
        AND AX,-1-ADDRESS
        MOV NEW_TOP,AX
        ADD NEW_BOTTOM,AX
        POP AX
        CALL NEED_REVISE
        RET
        ENDM

SET_BASE MACRO ADDRESS
        PUSH AX
        MOV AX,NEW_TOP
        SUB NEW_BOTTOM,AX
        OR AX,ADDRESS
        MOV NEW_TOP,AX
        ADD NEW_BOTTOM,AX
        POP AX
        CALL NEED_REVISE
        RET
        ENDM

FFC6W:  CLEAR_BASE 200H
FFC7W:  SET_BASE 200H
FFC8W:  CLEAR_BASE 400H
FFC9W:  SET_BASE 400H
FFCAW:  CLEAR_BASE 800H
FFCBW:  SET_BASE 800H
FFCCW:  CLEAR_BASE 1000H
FFCDW:  SET_BASE 1000H
FFCEW:  CLEAR_BASE 2000H
FFCFW:  SET_BASE 2000H
FFD0W:  CLEAR_BASE 4000H
FFD1W:  SET_BASE 4000H
FFD2W:  CLEAR_BASE 8000H
FFD3W:  SET_BASE 8000H

;SAM - bank switching control

FFD4W   PROC NEAR               ;Clear page register.  Bank 0=0000h-7FFFFh
        PUSH AX
        MOV AX,SS:[6]           ;Get RAMBANK
        MOV SS:[0],AX           ;Store to BANK0R
        MOV SS:[2],AX           ;and BANK0W
        MOV PAGE_STATUS,0D4H
        POP AX
        RET
FFD4W   ENDP

FFD5W   PROC NEAR               ;Set page register.  Bank 0=8000h-FFFFh
        PUSH AX
        MOV AX,SS:[6]           ;Get RAMBANK
        ADD AX,800H             ;Add offset
        MOV SS:[0],AX           ;Store to BANK0R
        MOV SS:[2],AX           ;and BANK0W
        MOV PAGE_STATUS,0D5H
        POP AX
        RET
FFD5W   ENDP

FFDEW   PROC NEAR               ;Set 32K RAM/32K ROM mode
        PUSH AX
        MOV AX,SS:[4]           ;Get ROMBANK
        MOV SS:[8000H],AX       ;Store in BANK1R
        ADD AX,800H
        MOV WORD PTR SS:[8002H],AX
                                ;Lock out BANK1W
        MOV ROM_STATUS,0DEH
        POP AX
        RET
FFDEW   ENDP

FFDFW   PROC NEAR               ;Set 64K RAM mode
        PUSH AX
        MOV AX,SS:[6]           ;Get RAMBANK
        MOV SS:[8000H],AX       ;Store in BANK1R
        MOV SS:[8002H],AX       ;and BANK1W
        MOV ROM_STATUS,0DFH
        POP AX
        RET
FFDFW   ENDP

;PIA2 port B support - VDG

FF22R   PROC NEAR
        TEST BYTE PTR CRB2,4
        JZ FF22R_1
        MOV AL,DRB2
        AND AL,254              ;Clear RS-232 data input
        MOV PRINTER_BITS,0      ;Reset printer serial buffer
        CMP ADDLF,128
        JNZ FF22R_0
        OR AL,1                 ;If printer disabled, set BUSY high
FF22R_0:        
        RET
FF22R_1:
        MOV AL,DDRB2
        RET
FF22R   ENDP

CART_FLAG DB 0

FF23R   PROC NEAR
        MOV AL,CRB2
        AND AL,31
        OR AL,CART_FLAG
        RET
FF23R   ENDP

CRB2    DB 4
DDRB2   DB -1
DRB2    DB 0

FF23W   PROC NEAR
        MOV CRB2,AL
        CALL CART_INT
        RET
FF23W   ENDP

FF22W   PROC NEAR
        TEST BYTE PTR CRB2,4
        JNZ FF22W_1
        MOV DDRB2,AL
        RET
FF22W_1:
        PUSH AX
        AND AL,0F8H
        CMP AL,0F8H             ;Check for 256x192 G6R select
        JNZ FF22W_5
        CMP BYTE PTR ARTIFACT,0 ;If so, select 128x192 G6C if artifacting
        JZ FF22W_5              ;requested
        MOV AL,60H
FF22W_5:
        PUSH BX
        MOV AH,0
        AND AL,70H
        SHR AX,1
        SHR AX,1
        SHR AX,1
        MOV BX,AX
        SHR AX,1
        ADD BX,AX
        MOV AX,V_MODES[BX]
        MOV NEWSET,AX
        MOV AL,BYTE PTR V_MODES[BX+2]
        MOV NEW_DIV,AL
        POP BX
        MOV NEW_WIDTH,1
        CMP AL,32
        JZ FF22W_2
        MOV NEW_WIDTH,2
FF22W_2:        
        POP AX
        MOV DRB2,AL
        CALL NEED_REVISE
        TEST BYTE PTR CRB2,8
        JZ FF22W_3      ;If DAC sound is disabled, use single bit
        RET
FF22W_3:
        TEST SOUND,1    ;If sound option off, skip
        JZ FF22W_4
        PUSH AX         ;Single bit sound is still channeled through internal
        MOV AH,AL       ;speaker
        AND AH,2
        IN AL,61H
        AND AL,0FCH
        OR AL,AH
        OUT 61H,AL
        POP AX
FF22W_4:
        RET
FF22W   ENDP

V_MODES DW FONT_64C     ;Mode 1 0 0 0 = G1C (64x64 4-colour)
        DB 16           ;Number of bytes per row
        DW FONT_128R    ;Mode 1 0 0 1 = G1R (128x64 2-colour)
        DB 16
        DW FONT_128C    ;Mode 1 0 1 0 = G2C (128x64 4-colour)
        DB 32
        DW FONT_128R    ;Mode 1 0 1 1 - G2R (128x96 2-colour)
        DB 16
        DW FONT_128C    ;Mode 1 1 0 0 - G3C (128x96 4-colour)
        DB 32
        DW FONT_128R    ;Mode 1 1 0 1 - G3R (128x192 2-colour)
        DB 16
        DW FONT_128C    ;Mode 1 1 1 0 - G6C (128x256 4-colour)
        DB 32
        DW FONT_256R    ;Mode 1 1 1 1 - G6R (256x192 2-colour)
        DB 32

;Drive selector -- only drive select bits and interrupt bit are interpreted

FDC_STATUS DB 0                 ;FDC status register
FDC_TRACK DB 0                  ;FDC track register
FDC_SECTOR DB 0                 ;FDC sector register
FDC_DATA DB 0                   ;FDC data register

DRIVE_BIT DB 0                  ;Last drive select bit configuration

FDC_FLAGS DB 0                  ;Bit 0=sector read, bit 1=sector write,
                                ;bit 2=interrupt pending, bit 3=track op.
SECTOR_PTR DW 0                 ;Read/write byte within sector pointer
INDEX_HOLE DB 0                 ;Counter to pulse index hole
FDC_WPFLAG DB 0                 ;0=not write protected, 40h=write protected
DATA_LENGTH DW 256              ;Number of bytes in read/write operation

DRIVE_SEL DB 80H                ;Static byte indicating double density, head 0
DAMS    DB 0                    ;Include DAM bit for PHYS_WRITE routine

FF40W   PROC NEAR
        PUSH AX
        PUSH DX
        MOV DL,AL
;*** Following line has been taken out to prevent drive timeout, thereby
;*** preventing spin-up delays built into Disk Basic
;        MOV COUNTDOWN,91        ;Close file if no access in five seconds
        MOV AH,DRIVE_BIT        ;Update old copy of output
        TEST AL,128             ;Don't do anything if it's an interrupt
        JNZ FF40W_4A
        TEST AL,8                                
        JZ FF40W_4A
                                ;Retain only interrupt and drive select bits
        AND AL,47H              ;Deselect?
        MOV DRIVE_BIT,AL
        JZ FF40W_4A
        CMP AL,AH               ;No change in drive selection?
        JNZ FF40W_1
        CMP HANDLE,-1           ;If so, return if file still open
        JZ FF40W_1
        POP DX
        POP AX
        RET
FF40W_4A:
        JMP FF40W_4
FF40W_1:                        ;Get density bit into bit 7 of DL
        ROL DL,1
        ROL DL,1
        AND DL,80H
                                ;If drive 3 select is set along with one
        CMP AL,40H              ;other bit,
        JNA HEAD0
        OR DL,10H               ;set bit for physical head 1
HEAD0:  MOV DRIVE_SEL,DL        ;Update density/head bits for physical I/O
        CMP AL,1                ;and open appropriate new virtual disk
        MOV DX,OFFSET PATHS
        JZ FF40W_2
        CMP AL,2
        MOV DX,OFFSET PATHS+32
        JZ FF40W_2
        MOV DX,OFFSET PATHS+64
        CMP AL,4                ;Drive 2
        JZ FF40W_2
        MOV AH,AL
        CMP AL,41H              ;Drive 0, head 1 is also called drive 2
        MOV AL,4                ;Set appropriate write protect bit mask
        JZ FF40W_2
        CMP AH,44H              ;This can't be done by ROM, but it's drive 2,
        JZ FF40W_2              ;head 2
        MOV AL,8                ;Drive 3 or drive 1, head 1
        MOV DX,OFFSET PATHS+96
FF40W_2:
        MOV FDC_WPFLAG,0        ;Clear write protect flag
        TEST AL,WR_PROT         ;Set write protect bit if appropriate
        JZ FF40W_2A
        MOV FDC_WPFLAG,40H
FF40W_2A:
        AND BYTE PTR FDC_STATUS,3
                                ;Set disk controller to ready
        PUSH BX                 ;Close old file
        MOV AH,3EH
        MOV BX,HANDLE
        INT 21H
        MOV BX,DX               ;Check if a real disk path was specified
        MOV AL,[BX]
        MOV BX,[BX+1]
        AND BH,0DFH
        CMP BX,3AH
        JNZ FF40W_5
        MOV AH,-2               ;If so, set HANDLE to FEdd where dd is PC's
        DEC AL                  ;unit select 0-3
        AND AL,3
        MOV HANDLE,AX
        CALL SPINUP
        CALL DRIVE_STATUS       ;Get write protect status
        MOV FDC_WPFLAG,AL
        JMP FF40W_3
FF40W_5:
        MOV AX,3D02H            ;If a virtual disk, open file
        INT 21H
        JB FF40W_3
        MOV BUFFER_VALID,0      ;Clear flag indicating read/write buffer
                                ;position valid
        MOV HANDLE,AX
FF40W_3:                        
        POP BX
        POP DX
        POP AX
        RET
FF40W_4:
;*** Following lines has been taken out to prevent drive timeout, thereby
;*** preventing spin-up delays built into Disk Basic
;        PUSH BX
;        MOV BX,HANDLE           ;Close current virtual disk
;        MOV AH,3EH
;        INT 21H
;        MOV HANDLE,-1
;        MOV FDC_WPFLAG,0        ;Clear write protect bit
;        POP BX
        POP DX
        POP AX
        RET
FF40W   ENDP

;Floppy Disk Controller handler

FF49R   PROC NEAR               ;Track register read
        MOV AL,FDC_TRACK
        RET
FF49R   ENDP

FF49W   PROC NEAR               ;Track register write
        MOV FDC_TRACK,AL
        RET
FF49W   ENDP

FF4AR   PROC NEAR               ;Sector register read
        MOV AL,FDC_SECTOR
        RET
FF4AR   ENDP

FF4AW   PROC NEAR               ;Sector register write
        MOV FDC_SECTOR,AL
        RET
FF4AW   ENDP

FF4BR   PROC NEAR               ;Read data register
        CMP LASTKEY,3BH         ;If debug active, don't screw up counters
        JZ FF4BR_0
        TEST BYTE PTR FDC_FLAGS,1
        JNZ FF4BR_1
FF4BR_0:        
        MOV AL,FDC_DATA         ;Just read data register if read not active
        RET
FF4BR_1:                        ;Read byte from sector data if read active
        TEST BYTE PTR FDC_STATUS,2
        JNZ FF4BR_1A
        CALL CONDITIONAL_NMI
        MOV FDC_FLAGS,0
        RET
FF4BR_1A:
        PUSH BX
        MOV BX,SECTOR_PTR
        OR BX,BX
        JNZ FF4BR_1B
        CALL VALIDATE_READ      ;Make sure drive select wasn't changed
FF4BR_1B:
        MOV AL,DTA[BX]
        MOV FDC_DATA,AL
        INC BYTE PTR SECTOR_PTR
        POP BX
        JZ FF4BR_2
        RET
FF4BR_2:                        ;If last byte, shut down read operation
        AND FDC_STATUS,252
        MOV INDEX_HOLE,0
        RET
FF4BR   ENDP

FF4BW   PROC NEAR               ;Write data register
        MOV FDC_DATA,AL
        TEST BYTE PTR FDC_FLAGS,2
        JNZ FF4BW_1
        RET                     ;If sector write not active, just return
FF4BW_0:
        CALL CONDITIONAL_NMI
        MOV FDC_FLAGS,0         ;Make sure write protect bit is passed
        RET
FF4BW_1:
        TEST BYTE PTR FDC_STATUS,2
        JZ FF4BW_0
        PUSH BX                 ;else store byte in DTA
        MOV BX,SECTOR_PTR
        MOV DTA[BX],AL
        INC BX
        MOV SECTOR_PTR,BX
        CMP BX,DATA_LENGTH
        POP BX
        JNB FF4BW_2
        RET                     ;If not end of record, return
FF4BW_2:                        ;else clear write flag
        CALL VALIDATE_WRITE     ;Make sure drive select didn't change
        MOV INDEX_HOLE,0
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        CMP BYTE PTR HANDLE[1],-2
        JNZ FF4BW_4             ;If in real disk mode,
        TEST FDC_WPFLAG,40H
        MOV FDC_STATUS,50H
        JNZ FF4BW_3
        TEST FDC_FLAGS,8        ;If in format mode, write track
        JNZ FF4BW_5
        MOV AL,DAMS
        CALL PHYS_WRITE         ;call appropriate routine
        MOV FDC_STATUS,AL
        JMP FF4BW_3
FF4BW_5:
        CALL SPINUP
        CALL FORMAT
        MOV FDC_STATUS,0
        JMP FF4BW_3
FF4BW_4:
        TEST FDC_FLAGS,8        ;Format mode check for virtual disks
        JNZ FF4BW_6
        MOV CX,256
FF4BW_7:
        MOV AH,40H              ;Write sector to virtual disk
        MOV BX,HANDLE
        MOV DX,OFFSET DTA
        TEST FDC_WPFLAG,40H     ;unless write protected
        MOV FDC_STATUS,50H
        JNZ FF4BW_3
        INT 21H
        JB FF4BW_3
        MOV FDC_STATUS,0        ;Set error flag unless successful
FF4BW_3:
        POP DX
        POP CX
        POP BX
        POP AX
        RET
FF4BW_6:                        ;Virtual disk format.  Calculate track offset
        MOV AL,18
        MUL BYTE PTR FDC_TRACK
        MOV DH,AL
        MOV CL,AH
        MOV CH,0
        MOV DL,CH
        MOV BX,HANDLE
        MOV AX,4200H
        INT 21H
        PUSH DI                 ;Fill buffer with 18 sectors of FF's
        PUSH ES
        MOV AX,CS
        MOV ES,AX
        MOV DI,OFFSET DTA
        MOV CX,1200H
        MOV AL,-1
        REP STOSB
        POP ES
        POP DI
        MOV CX,1200H            ;Branch to write routine
        JMP FF4BW_7
FF4BW   ENDP

CONDITIONAL_NMI PROC NEAR       ;Conditional NMI: suppressed if debug active
        CMP LASTKEY,3BH
        JZ C_NMI1
        MOV FDC_FLAGS,4
        CALL NMI
C_NMI1: RET
CONDITIONAL_NMI ENDP

FF48R   PROC NEAR               ;Read status register
        CMP HANDLE,-1           ;If no file open, return controller not ready
        JNZ FF48R_0
        MOV AL,128
        RET
FF48R_0:
        MOV AL,FDC_STATUS
        TEST BYTE PTR FDC_FLAGS,7
        JNZ FF48R_1             ;If sector operation active, status changes
        CMP HANDLE,-1           ;If no virtual disk, don't pulse index hole
        JZ FF48R_1
        INC INDEX_HOLE
        CMP INDEX_HOLE,8        ;After 8 reads (yes, that's too fast) pulse
        JB FF48R_1              ;index hole
        OR AL,2
        MOV INDEX_HOLE,0
FF48R_1:                        ;Interrupt handled
        AND BYTE PTR FDC_FLAGS,251
        RET
FF48R   ENDP

BUFFER_VALID DB 0               ;Zeroed if drive select invalidated I/O buffer

VALIDATE_READ:                  ;OS-9 changes drive select *after* initiating
        TEST BUFFER_VALID,-1    ;a read/write sector operation.  Make sure
        JZ VALIDATE1            ;we don't have the wrong buffer as a result.
        RET
VALIDATE1:
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        CMP BYTE PTR HANDLE[1],-2
        JZ VALIDATE4
        CALL VALIDATE3          ;Position virtual file pointer
        MOV AH,3FH
        MOV BX,HANDLE
        MOV CX,256
        MOV DX,OFFSET DTA
        INT 21H
        POP DX
        POP CX
        POP BX
        POP AX
        RET
VALIDATE4:
        CALL PHYS_READ
        POP DX
        POP CX
        POP BX
        POP AX
        RET

VALIDATE_WRITE:                 ;OS-9 changes drive select *after* initiating
        TEST BUFFER_VALID,-1    ;a read/write sector operation.  Make sure
        JNZ VALIDATE2           ;we don't have the wrong buffer as a result.
        CMP BYTE PTR HANDLE[1],-2
        JNB VALIDATE2
VALIDATE3:
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        MOV AL,18               ;We're dealing with a virtual disk,
        MUL FDC_TRACK           ;correct write pointer's offset
        ADD AL,FDC_SECTOR
        MOV CH,0
        ADC AH,CH
        DEC AX
        MOV DL,CH
        MOV CL,AH
        MOV DH,AL
        MOV BX,HANDLE
        MOV AX,4200H
        INT 21H
        POP DX
        POP CX
        POP BX
        POP AX
VALIDATE2:
        RET

FF48W   PROC NEAR               ;FDC command register write
        AND BYTE PTR FDC_FLAGS,0F4H       
                                ;A write automatically aborts I/O ops.
        AND BYTE PTR FDC_STATUS,252
        CMP AL,16               ;00-0Fh, seek track 0
        JNB FF48W_1
        MOV FDC_TRACK,0         ;Set track and status registers correctly
        MOV FDC_STATUS,24H
        RET
FF48W_1:
        CMP AL,32               ;10-1Fh, seek track in data register
        JNB FF48W_3
        PUSH AX
        MOV AL,FDC_DATA
        MOV FDC_TRACK,AL
FF48W_1A:        
        CMP AL,80               ;If greater than 80, invalid => seek error
        MOV AH,30H
        JNB FF48W_2
        CMP AL,0
        MOV AH,24H              ;Set track 0 bit if necessary
        JZ FF48W_2
        MOV AH,20H
FF48W_2:        
        MOV FDC_STATUS,AH
        POP AX
        RET
FF48W_3:
        CMP AL,96
        JNB FF48W_4             ;Step in operation 20-5Fh
        INC FDC_TRACK
        PUSH AX
        MOV AL,FDC_TRACK
        JMP FF48W_1A
FF48W_4:
        CMP AL,128
        JNB FF48W_5             ;Step out operation 60-7Fh
        SUB FDC_TRACK,1
        PUSH AX
        MOV AL,FDC_TRACK
        JNB FF48W_1A            ;Make sure not trying to step out beyond 0
        INC FDC_TRACK
        POP AX
        RET
FF48W_9A:
        JMP FF48W_9
FF48W_5:
        CMP AL,192
        JNB FF48W_9A            ;Sector read/write operation 80-BFh
        MOV BUFFER_VALID,-1     ;Validate read/write buffer position
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH AX
        CMP BYTE PTR HANDLE[1],-2
        JZ FF48W_10             ;If real disk operation, skip offset calc.
        MOV AX,18               ;Calculate offset for current "track/sector"
        MUL FDC_TRACK
        PUSH AX
        MOV AL,FDC_SECTOR
        DEC AL
        CMP AL,18
        JB FF48W_7              ;Make sure in sector 1-18 range
        POP AX
FF48W_6:
        POP AX
        POP DX
        POP CX
        POP BX
        MOV FDC_STATUS,38H      ;else report an error
        CMP AL,160
        JNB FF48W_6A
        OR FDC_FLAGS,1
        RET
FF48W_6A:
        OR FDC_FLAGS,2
        RET
FF48W_7:
        MOV AH,0
        POP DX
        ADD AX,DX               ;Now have absolute sector offset
        MOV CH,0                ;Convert to double-word byte offset
        MOV CL,AH
        MOV DH,AL
        MOV DL,0
        MOV AX,4200H
        MOV BX,HANDLE
        INT 21H                 ;Set file pointer
        POP AX
        PUSH AX
FF48W_10:
        CMP AL,160
        JNB FF48W_8             ;Read operation 80-9Fh
        CMP BYTE PTR HANDLE[1],-2
        JNZ FF48W_11
        CALL PHYS_READ          ;Physical read
        MOV FDC_STATUS,AL
        TEST AL,9CH
        JNZ FF48W_7A
        MOV FDC_STATUS,3
        JMP FF48W_7A
FF48W_11:
        MOV AH,3FH              ;Read 256 bytes from virtual disk
        MOV DX,OFFSET DTA
        MOV CX,256
        INT 21H
        MOV FDC_STATUS,3BH
        JB FF48W_7A             ;Branch if error
        MOV FDC_STATUS,3
FF48W_7A:        
        OR FDC_FLAGS,1          ;else set flags
        MOV SECTOR_PTR,0
        MOV DATA_LENGTH,256
        POP AX
        POP DX
        POP CX
        POP BX
        RET
FF48W_8:
        MOV DAMS,AL
        MOV AL,3
        OR AL,FDC_WPFLAG
        MOV FDC_STATUS,AL       ;Write sector A0-BFh, set flags
        OR FDC_FLAGS,2
        MOV SECTOR_PTR,0
        MOV DATA_LENGTH,256
        POP AX
        POP DX
        POP CX
        POP BX
        RET
FF48W_9:
        CMP AL,0F0H             ;C0-EFh not interpreted.  Takes as FDC reset
        JNB FF48W_12
        MOV FDC_STATUS,0
        RET
FF48W_12:                       ;Format track F0-FFh
        MOV DATA_LENGTH,6248    ;6248 bytes per track 
        TEST DRIVE_SEL,128      ;unless single density
        JNZ FF48W_13
        SHR DATA_LENGTH,1       ;which is half that
FF48W_13:
        MOV SECTOR_PTR,0
        PUSH AX
        MOV AL,FDC_WPFLAG
        OR AL,3
        MOV FDC_STATUS,AL
        OR FDC_FLAGS,10         ;Write and track operation flags
        POP AX
        RET
FF48W   ENDP

;Joystick handlers

MOUSE_H PROC NEAR               ;Read mouse horizontal pos.
        PUSH AX
        MOV AL,DAC
        CMP AL,MOUSE_X
        JA MOUSE_H1
        POP AX
        RET
MOUSE_H1:
        POP AX
        AND AL,127
        RET
MOUSE_H ENDP

MOUSE_V PROC NEAR               ;Read mouse vertical pos.
        PUSH AX
        MOV AL,DAC
        CMP AL,MOUSE_Y
        JA MOUSE_V1
        POP AX
        RET
MOUSE_V1:
        POP AX
        AND AL,127
        RET
MOUSE_V ENDP

GAME_AH PROC NEAR               ;Read JOYSTICK A horizontal position
        PUSH AX
        MOV AL,DAC
        CMP AL,GAXPOS
        JA GAME_AH1
        POP AX
        RET
GAME_AH1:
        POP AX
        AND AL,127
        RET
GAME_AH ENDP

GAME_AV PROC NEAR               ;Read JOYSTICK A vertical position
        PUSH AX
        MOV AL,DAC
        CMP AL,GAYPOS 
        JA GAME_AV1
        POP AX
        RET
GAME_AV1:
        POP AX
        AND AL,127
        RET
GAME_AV ENDP

GAME_BH PROC NEAR               ;Read JOYSTICK B horizontal position
        PUSH AX
        MOV AL,DAC
        CMP AL,GBXPOS
        JA GAME_BH1
        POP AX
        RET
GAME_BH1:
        POP AX
        AND AL,127
        RET
GAME_BH ENDP

GAME_BV PROC NEAR               ;Read JOYSTICK B vertical position
        PUSH AX
        MOV AL,DAC
        CMP AL,GBYPOS 
        JA GAME_BV1
        POP AX
        RET
GAME_BV1:
        POP AX
        AND AL,127
        RET
GAME_BV ENDP

NO_STICK: RET

;PIA2 port A -- DAC output, printer output and cassette input

FF20R   PROC NEAR
        TEST BYTE PTR CRA2,4
        JNZ FF20R_1
        MOV AL,DDRA2
        RET
FF20R_1:
        MOV AL,DRA2
        OR AL,1
        CMP CASMODE,0           ;If virtual cassette in playback
        JNZ FF20R_2
        CMP CHANDLE,-1          ;a .CAS file is open
        JZ FF20R_2
        TEST BYTE PTR CRA2,8    ;and cassette motor is on, read a bit
        JNZ FF20R_3
FF20R_2:
        RET
FF20R_3:
        CMP CAS_BIT,0           ;If on first bit of byte, read byte from
        JNZ FF20R_4             ;file
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        MOV AH,3FH
        MOV BX,CHANDLE
        MOV CX,1
        MOV DX,OFFSET CAS_BYTE
        INT 21H
        POP DX
        POP CX
        POP BX
        POP AX
        INC CAS_BIT             ;Starting new bit
FF20R_4:
        INC CAS_CYCLE           ;Increment position in this cycle
        TEST BYTE PTR CAS_BYTE,1
        JZ FF20R_5
        INC CAS_CYCLE           ;"1"'s have half the cycle length
FF20R_5:
        CMP CAS_CYCLE,24        ;We'll give a "0" 48 cycles total
        JB FF20R_6
        INC CAS_BIT             ;Then it's on to the next bit
        ROR CAS_BYTE,1          ;Shift next bit into position
        MOV CAS_CYCLE,0
        CMP CAS_BIT,9
        JB FF20R_6
        MOV CAS_BIT,0           ;If next bit to process was "8th", new byte
FF20R_6:
        CMP CAS_CYCLE,12        ;First half of cycle should be low input
        SBB AL,0                ;second half should be high.
        XOR AL,1
        RET
FF20R   ENDP

FF21R   PROC NEAR
        MOV AL,CRA2
        AND AL,31
        RET
FF21R   ENDP

FF20W   PROC NEAR
        TEST BYTE PTR CRA2,4
        JNZ FF20W_1
        MOV DDRA2,AL
        RET
FF20W_1:
        TEST BYTE PTR CRA2,8    ;If cassette motor on,
        JZ FF20W_0
        CMP CASMODE,-1          ;virtual cassette in write mode
        JNZ FF20W_0
        CMP CHANDLE,-1          ;and a virtual cassette is open
        JZ FF20W_0
        CALL CAS_OUT
FF20W_0:
        MOV DRA2,AL
        CMP ADDLF,80H           ;If printer disabled, skip routine
        JZ FF20W_6
        CMP PRINTER_BITS,0
        JZ FF20W_7
        PUSH AX                 ;If printer buffer active, shift out bits
        ROR AL,1
        MOV AH,PRINTER_CHAR
        ROR AX,1
        MOV PRINTER_CHAR,AH
        POP AX
        DEC PRINTER_BITS
        JNZ FF20W_6
        PUSH AX                 ;When all bits received, print it
        PUSH DX
        MOV AH,2
        MOV DX,0
        INT 17H
        AND AH,30H              ;Make sure printer on and selected
        XOR AH,10H
        JNZ FF20W_9
        MOV AH,0
        MOV AL,PRINTER_CHAR     ;Print character
        INT 17H
        CMP AL,13
        JNZ FF20W_9
        CMP ADDLF,0
        JZ FF20W_9
        MOV AX,10               ;Add LF to CRs
        INT 17H
FF20W_9:
        POP DX
        POP AX
        JMP FF20W_6
FF20W_7:
        TEST AL,2
        JNZ FF20W_6             ;If space received, start bit count for RS-232
        MOV PRINTER_BITS,8      ;but only 7 bits are printed
FF20W_6:
        PUSH AX
        SHR AL,1
        SHR AL,1
        MOV DAC,AL
        POP AX
        TEST BYTE PTR CRB2,8    ;Test sound enable
        JNZ FF20W_2
        RET
FF20W_2:
        PUSH AX
        MOV AH,SOUND
        AND AH,SBMASK
        CMP AH,3
        JZ FF20W_10
        MOV AH,PREV_DAC
        AND AX,0FCFCH
        MOV PREV_DAC,AL
        CMP AL,AH               ;PC's 1-bit sound goes low on signal level
        JB FF20W_3              ;drop, high on increase
        IN AL,61H
        AND AL,0FCH
        OR AL,2
        JMP FF20W_4
FF20W_3:
        IN AL,61H
        AND AL,0FCH
FF20W_4:                        ;Check for sound disabled
        TEST SOUND,1
        JZ FF20W_5
        OUT 61H,AL
FF20W_5:
        POP AX
        RET
FF20W_10:
        PUSH DX
        MOV AH,PREV_DAC
        AND AX,0FCFCH
        MOV PREV_DAC,AL
        CMP AL,AH
        JZ FF20W_11
        PUSH AX
        CALL SBWAIT
        MOV AL,16
        OUT DX,AL
        CALL SBWAIT
        POP AX
        AND AL,0FCH
        PUSH CX
        MOV CL,VOLUME
        SHR AL,CL
        POP CX
        OUT DX,AL
FF20W_11:
        POP DX
        POP AX
        RET
FF20W   ENDP

FF21W   PROC NEAR
        MOV CRA2,AL
        RET
FF21W   ENDP

CRA2    DB 4
DDRA2   DB 0
DRA2    DB 0
DAC     DB 0            ;DAC bits.  Range 0-63
PREV_DAC DB 0           ;Previous DAC setting*4.  For comparison in sound
                        ;interpretation
PRINTER_BITS DB 0       ;Printer bit counter, include 1 bit for reset of mark
PRINTER_CHAR DB 0       ;Bit buffer for printer byte

;Vector addresses.  Mapped to BFE0h-BFFFh

FFE0R   PROC NEAR
        ROR BX,1
        MOV ES,SS:[4]   ;Get ROMBANK
        MOV AL,ES:[BX-4000H]
        ROL BX,1
        RET
FFE0R   ENDP

;Virtual casssette routines

CAS_BYTE DB 0           ;Buffer for cassette byte

CAS_OUT PROC NEAR       ;Write a byte to the virtual cassette
        PUSH AX
        PUSH ES
        MOV ES,SS:[4]   ;Move segment pointer to ROM bank
        MOV AH,ES:[0A864H]
        AND AX,0FCFCH
        CMP AH,AL
        JNZ CAS_OUT1    ;If detecting first byte in sine table
        MOV CAS_CYCLE,0 ;Reset cycle count
        POP ES
        POP AX
        RET
CAS_OUT1:
        CMP CAS_CYCLE,-1;If end cycle reached, but none new started, do
        JZ CAS_OUT1A    ;nothing
        MOV AH,ES:[0A876H]
        AND AH,0FCH     ;If detecting last byte in sine table (less one
        CMP AL,AH       ;in case it's skipping odd bytes)
        JZ CAS_OUT2     ;then a bit is complete
        INC CAS_CYCLE
CAS_OUT1A:
        POP ES
        POP AX
        RET
CAS_OUT2:
        CMP CAS_CYCLE,2 ;Less than two cycles is a glitch
        JB CAS_OUT1A
        CMP CAS_CYCLE,12;Check for the length of *half* a cycle
        RCR CAS_BYTE,1  ;Short cycle is 18 counts ("1"), long is 36 ("0")
        INC CAS_BIT
        MOV CAS_CYCLE,-1;Lockout bit input until a new cycle starts
        CMP CAS_BIT,8
        JNB CAS_OUT3
        POP ES
        POP AX
        RET
CAS_OUT3:               ;Save completed byte to the virtual cassette file
        PUSH BX
        PUSH CX
        PUSH DX
        MOV AH,40H
        MOV BX,CHANDLE
        MOV CX,1
        MOV DX,OFFSET CAS_BYTE
        INT 21H
        MOV CAS_BIT,0   ;Reset shift register bit count
        POP DX
        POP CX
        POP BX
        POP ES
        POP AX
        RET
CAS_OUT ENDP

;Memory function lookup table

READ    DW FF00R,FF01R,FF02R,FF03R,FF00R,FF01R,FF02R,FF03R
        DW FF00R,FF01R,FF02R,FF03R,FF00R,FF01R,FF02R,FF03R
        DW FF00R,FF01R,FF02R,FF03R,FF00R,FF01R,FF02R,FF03R
        DW FF00R,FF01R,FF02R,FF03R,FF00R,FF01R,FF02R,FF03R
        DW FF20R,FF21R,FF22R,FF23R,FF20R,FF21R,FF22R,FF23R
        DW FF20R,FF21R,FF22R,FF23R,FF20R,FF21R,FF22R,FF23R
        DW FF20R,FF21R,FF22R,FF23R,FF20R,FF21R,FF22R,FF23R
        DW FF20R,FF21R,FF22R,FF23R,FF20R,FF21R,FF22R,FF23R
        DW NR,NR,NR,NR,NR,NR,NR,NR
        DW FF48R,FF49R,FF4AR,FF4BR,FF48R,FF49R,FF4AR,FF4BR
        DW NR,NR,NR,NR,NR,NR,NR,NR
        DW FF48R,FF49R,FF4AR,FF4BR,FF48R,FF49R,FF4AR,FF4BR
        DW NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR
        DW NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR
        DW NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR
        DW NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR
        DW NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR
        DW NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR
        DW NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR
        DW NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR
        DW FFE0R,FFE0R,FFE0R,FFE0R,FFE0R,FFE0R,FFE0R,FFE0R
        DW FFE0R,FFE0R,FFE0R,FFE0R,FFE0R,FFE0R,FFE0R,FFE0R
        DW FFE0R,FFE0R,FFE0R,FFE0R,FFE0R,FFE0R,FFE0R,FFE0R
        DW FFE0R,FFE0R,FFE0R,FFE0R,FFE0R,FFE0R,FFE0R,FFE0R
        DW NR

        DW NW
WRITE   DW FF00W,FF01W,FF02W,FF03W,FF00W,FF01W,FF02W,FF03W
        DW FF00W,FF01W,FF02W,FF03W,FF00W,FF01W,FF02W,FF03W
        DW FF00W,FF01W,FF02W,FF03W,FF00W,FF01W,FF02W,FF03W
        DW FF00W,FF01W,FF02W,FF03W,FF00W,FF01W,FF02W,FF03W
        DW FF20W,FF21W,FF22W,FF23W,FF20W,FF21W,FF22W,FF23W
        DW FF20W,FF21W,FF22W,FF23W,FF20W,FF21W,FF22W,FF23W
        DW FF20W,FF21W,FF22W,FF23W,FF20W,FF21W,FF22W,FF23W
        DW FF20W,FF21W,FF22W,FF23W,FF20W,FF21W,FF22W,FF23W
        DW FF40W,FF40W,FF40W,FF40W,FF40W,FF40W,FF40W,FF40W
        DW FF48W,FF49W,FF4AW,FF4BW,FF48W,FF49W,FF4AW,FF4BW
        DW FF40W,FF40W,FF40W,FF40W,FF40W,FF40W,FF40W,FF40W
        DW FF48W,FF49W,FF4AW,FF4BW,FF48W,FF49W,FF4AW,FF4BW
        DW NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW
        DW NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW
        DW NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW
        DW NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW
        DW NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW
        DW NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW
        DW FFC0W,FFC1W,FFC2W,FFC3W,FFC4W,FFC5W,FFC6W,FFC7W
        DW FFC8W,FFC9W,FFCAW,FFCBW,FFCCW,FFCDW,FFCEW,FFCFW
        DW FFD0W,FFD1W,FFD2W,FFD3W,FFD4W,FFD5W,NW,NW
        DW NW,NW,NW,NW,NW,NW,FFDEW,FFDFW
        DW NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW
        DW NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW
        DW NW

RAMHERE EQU $

PROG    ENDS
        END
