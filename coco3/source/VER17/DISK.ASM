        TITLE Physical Disk Interface for CoCo II Emulator

        ASSUME CS:PROG,DS:PROG

        EXTRN DRIVE_SEL:BYTE,FDC_TRACK:BYTE,FDC_SECTOR:BYTE,HANDLE:WORD
        EXTRN DTA:BYTE,DOUBLE_STEP:BYTE

;Notes: In this context, HANDLE is unit select number

        PUBLIC SPINUP,PHYS_READ,PHYS_WRITE,FORMAT,DRIVE_STATUS
        PUBLIC INITIALIZE,DRIVE_TYPE

PROG    SEGMENT PUBLIC 'CODE'

SPINUP:               ;Make sure drive rotating and calibrated
        PUSH AX                 ;Unit select is external variable HANDLE
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        PUSH DS
        PUSH ES
        MOV AX,40H              ;Point to MS-DOS control page
        MOV ES,AX
        CALL FIX_DENS
        MOV AX,0                ;Retrieve media descriptor
        MOV DS,AX
        MOV SI,DS:[78H]
        MOV DS,DS:[7AH]
        MOV CX,CS:HANDLE        ;Calculate drive mask
        MOV AL,1
        SHL AL,CL
        MOV BYTE PTR ES:[40H],0FFH      ;Disable drive timeout
        MOV BL,AL
        MOV BH,AL
        XCHG BH,ES:[3FH]         ;Start up motor and select
        MOV CL,4
        SHL AL,CL
        OR AL,0CH
        OR AX,CS:HANDLE
        MOV DX,3F2H
        OUT DX,AL
        TEST BL,BH              ;Drive already spinning?
        JNZ SPINUP1
        MOV CX,18               ;If not, wait 18 ticks of clock
        CALL DELAY
SPINUP1:                        ;Recalibrate?
        CMP CS:FDC_TRACK,0      ;Yes, if track is 0
        JZ SPINUP2
        MOV BH,BL               ;or if previous recalibration lost
        XOR BH,ES:[3EH]
        AND BH,15
        JZ SPINUP3
SPINUP2:
        MOV ES:[3EH],BL
        MOV AL,07H              ;FDC recalibrate instruction
        CALL DISK_CMD           ;07h
        MOV AL,BL
        CALL DISK_CMD           ;***** 0 US1 US0
        CALL COMPLETE
        JB SPINUP4B
        MOV BYTE PTR ES:[40H],-1
SPINUP2A:
        MOV CS:PREV_TRACK,0
        MOV AL,8                ;Return interrupt status
        CALL DISK_CMD
        MOV CX,2                ;Return 2 byte result
        CALL RESULT
        MOV AL,ES:[42H]         ;Error
        TEST AL,0C0H
        STC
        JNZ SPINUP4
        AND AL,32               ;Wait until seek operation complete
        JZ SPINUP2A
SPINUP3:                        ;Seek current track
        MOV AL,CS:FDC_TRACK
        CMP AL,CS:PREV_TRACK
        JZ SPINUP4
        MOV AL,0FH              ;FDC seek instruction
        CALL DISK_CMD           ;0Fh
        MOV AL,CS:DRIVE_SEL     ;***** HD US1 US0
        SHR AL,1
        SHR AL,1
        AND AL,4
        OR AL,BL
        MOV AL,BL
        CALL DISK_CMD
        MOV BX,CS:HANDLE
        AND BX,3
        CMP CS:DRIVE_TYPE[BX],1
        MOV AL,CS:FDC_TRACK     ;Track #
        MOV CS:PREV_TRACK,AL
        JNZ NO_DOUBLE_STEP      ;Double step only if 1.2Mb drive
        MOV CL,CS:DOUBLE_STEP   ;Multiply by 2 if appropriate
        SHL AL,CL
NO_DOUBLE_STEP:
        CALL DISK_CMD
        CALL COMPLETE
SPINUP4B:        
        JB SPINUP4
        MOV BYTE PTR ES:[40H],-1
SPINUP3A:
        MOV AL,8                ;Return interrupt status
        CALL DISK_CMD
        MOV CX,2                ;Return 2 byte result
        CALL RESULT
        MOV AL,ES:[42H]         ;Error
        TEST AL,0C0H
        STC
        JNZ SPINUP4
        AND AL,32               ;Wait for seek operation to finish
        JZ SPINUP3A
SPINUP4:
        MOV AL,[SI+2]           ;Restore normal timeout interval
        MOV ES:[40H],AL
        POP ES
        POP DS
        POP SI
        POP DX
        POP CX
        POP BX
        POP AX
        RET

PREV_TRACK DB 0                 ;Previous track for seek/recalibrate

DISK_CMD:              ;Send command to FDC
        PUSH CX
        PUSH DX
        PUSH AX
        MOV CX,0
        MOV DX,3F4H
DISK_CMD1:                      ;Wait for bit 7 to go high
        IN AL,DX
        TEST AL,80H
        LOOPZ DISK_CMD1
        POP AX
        JZ DISK_CMD2
        INC DX                  ;If ready, send code
        OUT DX,AL
DISK_CMD2:
        POP DX
        POP CX
        RET

RESULT:               ;Read CX bytes from FDC to 0040:0042
        PUSH DX
        PUSH SI
        MOV SI,42H
        MOV DX,3F4H
RESULT0:
        PUSH CX
        MOV CX,0
RESULT1:
        IN AL,DX
        TEST AL,80H
        LOOPZ RESULT1
        POP CX
        JZ RESULT2
        AND AL,50H
        CMP AL,50H
        JNZ RESULT2
        INC DX
        IN AL,DX
        DEC DX
        MOV ES:[SI],AL
        INC SI
        LOOP RESULT0
RESULT2:
        POP SI
        POP DX
        RET

COMPLETE:              ;Wait for FDC interrupt (wait 5 seconds)
        PUSH AX 
        PUSH BX
        MOV AX,ES:[6CH]         ;Load current timer ticks for comparison
COMPLETE1:
        TEST BYTE PTR ES:[3EH],128
        JNZ COMPLETE2
        MOV BX,ES:[6CH]
        SUB BX,AX
        CMP BX,18               ;1 second wait for execution
        JB COMPLETE1
        STC
        POP BX
        POP AX
        RET
COMPLETE2:
        AND BYTE PTR ES:[3EH],127
        POP BX
        POP AX
        RET

DELAY:               ;Timer delay.  Wait CX ticks
        PUSH AX
        PUSH BX
        MOV AX,ES:[6CH]         ;Get current count
DELAY1: MOV BX,ES:[6CH]
        SUB BX,AX
        CMP BX,CX
        JB DELAY1
        POP BX
        POP AX
        RET

PHYS_READ:             ;Read disk sector
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        PUSH DI
        PUSH ES
        MOV AX,64               ;Point to control page
        MOV ES,AX
        CALL SPINUP             ;Spin up drive and seek track
        MOV AL,80H              ;Not ready error?
        JB PHYS_READ2
        CALL FIX_DENS
        MOV AL,46H              ;Enable DMA
        MOV BX,256              ;for 256 bytes
        CALL SET_DMA
        MOV AL,DRIVE_SEL        ;Determine single/double density instruction
        SHR AL,1
        AND AL,64
        OR AL,6                 ;FDC read operation: 06 (SDEN) or 46 (DDEN)
        CALL DISK_CMD
        MOV AL,DRIVE_SEL        ;***** HD US1 US0
        SHR AL,1
        SHR AL,1
        AND AL,4
        OR AX,HANDLE
;        PUSH AX
        CALL DISK_CMD
        MOV AL,FDC_TRACK        ;Track
        CALL DISK_CMD
;        POP AX                  ;Head
        MOV AL,0                ;CoCo incorrectly labels both sides as head 0
;        SHR AL,1
;        SHR AL,1
        CALL DISK_CMD
        MOV AL,FDC_SECTOR       ;Sector
        CALL DISK_CMD
        MOV AL,1                ;Length (1=256 bytes)
        CALL DISK_CMD
        MOV AL,18               ;Sectors per track
        CALL DISK_CMD
        MOV AL,14               ;Gap length
        CALL DISK_CMD
        MOV AL,-1               ;Secondary data length (meaningless)
        CALL DISK_CMD
        CALL COMPLETE           ;Wait for instruction to finish
        MOV AL,80H              ;Not ready error?
        JB PHYS_READ2
        MOV CX,7                ;7 byte result sequence
        CALL RESULT
        MOV AL,ES:[43H]         ;Calculate 1793-style status register
        SHR AL,1                ;CRC error bit
        SHR AL,1
        AND AL,8
        TEST BYTE PTR ES:[43H],5;REC NOT FOUND error bit
        JZ PHYS_READ1
        OR AL,10H
PHYS_READ1:
        TEST BYTE PTR ES:[44H],40H      ;RD PROT bit
        JZ PHYS_READ2
        OR AL,20H
PHYS_READ2:
        POP ES
        POP DI
        POP SI
        POP DX
        POP CX
        POP BX
        RET

SET_DMA:               ;Set up DMA controller        
        CLI
        PUSH BX
        PUSH CX
        PUSH DX
        OUT 0BH,AL              ;Set interrupt mode
        DEC BX
        MOV AL,BL               ;Set length of buffer
        OUT 12,AL
        OUT 5,AL
        MOV AL,BH
        OUT 5,AL
        MOV BX,OFFSET DTA       ;Work out absolute start address of buffer
        MOV AX,CS
        MOV CL,4
        ROL AX,CL
        MOV CL,AL
        AND CL,0FH
        AND AL,0F0H
        ADD AX,BX
        ADC CL,0
        OUT 4,AL
        MOV AL,AH
        OUT 4,AL
        MOV AL,CL               ;64K segment
        OUT 129,AL
        STI
        MOV AL,2                ;Mysterious code
        OUT 10,AL
        POP DX
        POP CX
        POP BX
        RET

PHYS_WRITE:            ;Write disk sector
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        PUSH DI
        PUSH ES
        PUSH AX
        MOV AX,64               ;Point to control page
        MOV ES,AX
        CALL SPINUP             ;Spin up drive and seek track
        MOV AL,80H              ;Not ready error?
        POP CX
        JNB PHYS_WRITE2A
        JMP PHYS_WRITE2
PHYS_WRITE2A:
        CALL FIX_DENS
        MOV AL,4AH              ;Enable DMA
        MOV BX,256              ;for 256 bytes
        CALL SET_DMA
        MOV AL,DRIVE_SEL        ;Determine single/double density instruction
        SHR AL,1
        AND AL,64
        OR AL,5                 ;FDC write operation: 05 (SDEN) or 45 (DDEN)
        AND CL,1                ;x9 istead of x5 if RD PROT
        SHL CL,1
        SHL CL,1
        ADD AL,CL
        CALL DISK_CMD
        MOV AL,DRIVE_SEL        ;***** HD US1 US0
        SHR AL,1
        SHR AL,1
        AND AL,4
        OR AX,HANDLE
;        PUSH AX
        CALL DISK_CMD
        MOV AL,FDC_TRACK        ;Track
        CALL DISK_CMD
;        POP AX                  ;Head
;        SHR AL,1
;        SHR AL,1
        MOV AL,0                ;CoCo incorrectly labels both sides as head 0
        CALL DISK_CMD
        MOV AL,FDC_SECTOR       ;Sector
        CALL DISK_CMD
        MOV AL,1                ;Length (1=256 bytes)
        CALL DISK_CMD
        MOV AL,18               ;Sectors per track
        CALL DISK_CMD
        MOV AL,14               ;Gap length
        CALL DISK_CMD
        MOV AL,-1               ;Secondary data length (meaningless)
        CALL DISK_CMD
        CALL COMPLETE           ;Wait for instruction to finish
        MOV AL,128
        JB PHYS_WRITE2          ;Not ready?
        MOV CX,7                ;7 byte result sequence
        CALL RESULT
        MOV AL,ES:[43H]         ;Calculate 1793-style status register
        SHR AL,1                ;CRC error bit
        SHR AL,1
        AND AL,8
        TEST BYTE PTR ES:[43H],5;REC NOT FOUND error bit
        JZ PHYS_WRITE2
        OR AL,10H
PHYS_WRITE2:
        POP ES
        POP DI
        POP SI
        POP DX
        POP CX
        POP BX
        RET

DAM     DB 256 DUP(?)           ;256-byte DAM table
NSEC    DB 18                   ;Number of sectors in table

FORMAT:               ;Format track using 1793 image
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        PUSH DI
        PUSH ES
        MOV SI,0                ;Look for ID address marks
        MOV DI,0
        MOV BX,0
        MOV AL,0FEH             ;(FE track)
        MOV AH,FDC_TRACK
FORMAT1:
        CMP WORD PTR DTA[SI],AX
        JZ FORMAT2
        CMP DTA[SI],0F8H        ;Record data address mark
        JB FORMAT1A
        CMP DTA[SI],0FCH
        JNB FORMAT1A
        MOV CL,DTA[SI]
        MOV DAM[BX],CL
        INC BL
FORMAT1A:                       ;Loop for all bytes
        INC SI
        CMP SI,6144
        JB FORMAT1
        JMP FORMAT3
FORMAT2:                        ;Transfer ID
        PUSH AX
        MOV AX,WORD PTR DTA[SI+1]
        MOV WORD PTR DTA[DI],AX
        MOV AX,WORD PTR DTA[SI+3]
        MOV WORD PTR DTA[DI+2],AX
        POP AX
        ADD DI,4
        JMP FORMAT1A
FORMAT8A:
        JMP FORMAT8
FORMAT3:                        ;Execute format instruction
        MOV AL,0
        CMP DI,0                ;If no sectors, do not execute
        JZ FORMAT8A
        MOV AX,64               ;Point to control page
        MOV ES,AX
        CALL SPINUP             ;Spin up drive and seek track
;        MOV AL,80H              ;Not ready error?
;        JB FORMAT8A
        MOV AL,4AH              ;Enable DMA
        MOV BX,DI               ;for number of entries in table
        CALL SET_DMA
        MOV AL,DRIVE_SEL        ;Determine single/double density instruction
        SHR AL,1
        AND AL,64
        OR AL,13                ;FDC write operation: 0D (SDEN) or 4D (DDEN)
        CALL DISK_CMD
        MOV AL,DRIVE_SEL        ;***** HD US1 US0
        SHR AL,1
        SHR AL,1
        AND AL,4
        OR AX,HANDLE
        CALL DISK_CMD
        MOV AL,1                ;Length (1=256 bytes)
        CALL DISK_CMD
        MOV AX,DI               ;Sectors per track
        SHR AL,1
        SHR AL,1
        MOV NSEC,AL
        CALL DISK_CMD
        MOV AL,14H              ;Gap length
        CALL DISK_CMD
        MOV AL,0FFH             ;Filler byte
        CALL DISK_CMD
        CALL COMPLETE           ;Wait for instruction to finish
        MOV AL,128
        JB FORMAT8A
        MOV CX,7                ;7 byte result sequence
        CALL RESULT
        MOV AL,0
FORMAT8:        
        POP ES
        POP DI
        POP SI
        POP DX
        POP CX
        POP BX
        RET

DRIVE_STATUS:          ;Return write protect status of drive
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH ES
        MOV AX,64
        MOV ES,AX
        MOV AL,4                ;Sense drive status, 04h
        CALL DISK_CMD
        MOV AL,DRIVE_SEL        ;***** HD US1 US0
        SHR AL,1
        SHR AL,1
        AND AL,4
        OR AX,HANDLE
        CALL DISK_CMD
        MOV CX,1
        CALL RESULT
        MOV AL,ES:[42H]         ;Check write protect status
        AND AL,40H
DRIVE_STATUS1:
        POP ES
        POP DX
        POP CX
        POP BX
        RET
        
FIX_DENS:              ;Set standard double density mode
        PUSH AX
        PUSH BX
        PUSH DX
        MOV BX,CS:HANDLE
        MOV BH,0
        MOV AX,7401H            ;1.2Mb/360K drives
        CMP CS:DRIVE_TYPE[BX],2
        JB FIX_DENS1
        MOV AX,9702H            ;1.44Mb/720K drives
FIX_DENS1:
        MOV DX,3F7H
        OUT DX,AL
        MOV ES:[90H+BX],AH
        MOV ES:[8BH],AH
        POP DX
        POP BX
        POP AX
        RET

DRIVE_TYPE DB 4 DUP(0)        

INITIALIZE:            ;Load drive IDs in order to identify densities
        MOV BX,1                ;and step skip (if any)
        PUSH ES
        MOV AX,64
        MOV ES,AX
        AND BYTE PTR ES:[3EH],0F0H
        POP ES                  ;Enforce recalibration
INITIALIZE1:
        MOV AX,440DH
        MOV CX,0860H
        INT 21H
        JB INITIALIZE2
        MOV DI,DX
        MOV AL,[DI+1]
        MOV DRIVE_TYPE[BX-1],AL
INITIALIZE2:
        INC BL
        CMP BL,4
        JB INITIALIZE1
        RET

PROG    ENDS

        END
