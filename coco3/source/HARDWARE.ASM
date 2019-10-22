        TITLE Colour Computer Device Memory Handler
        
        ASSUME CS:PROG,DS:PROG

        .286

PROG    SEGMENT PUBLIC 'CODE'

        PUBLIC DEV_W8,DEV_R8,LINK_READ,LINK_WRITE,DRB1,NUM_ROWS,DRA1
        PUBLIC CRB1,RAMHERE,READ,WRITE,CHAR_LINES,CRA1,CRB2,CART_FLAG
        PUBLIC FIX_VIDEO

        PUBLIC FDC_TRACK,FDC_SECTOR,DRIVE_SEL,MEM_MASK,HDHANDLE,NATIVE

        EXTRN NEW_TOP:WORD,NEW_BOTTOM:WORD,OVERSCAN:BYTE,EI1_CHECK:NEAR
        EXTRN SBMASK:BYTE,SBWAIT:NEAR,USED_VRES:BYTE,COLOUR_BASE:BYTE
        EXTRN HANDLE:WORD,COUNTDOWN:BYTE,PATHS:BYTE,WR_PROT:BYTE,LASTKEY:BYTE
        EXTRN DTA:BYTE,NMI:NEAR,IRQ:NEAR,LJOYSTK:BYTE,RJOYSTK:BYTE,REGFI:BYTE
        EXTRN MOUSE_X:BYTE,MOUSE_Y:BYTE,FIRE:BYTE,SOUND:BYTE,IRQENR:BYTE
        EXTRN PULSE:BYTE,COLSET:BYTE,ADDLF:BYTE,GAXPOS:BYTE,GAYPOS:BYTE
        EXTRN GBXPOS:BYTE,GBYPOS:BYTE,VOLUME:BYTE,MMU:BYTE,VRES:BYTE
        EXTRN ROM_STATUS:BYTE,CASMODE:BYTE,CAS_BIT:BYTE,INIT0:BYTE,INIT1:BYTE
        EXTRN CAS_CYCLE:BYTE,CHANDLE:WORD,EMS_ENABLE:BYTE,TOPRAM:WORD
        EXTRN EMS_HANDLE:WORD,EMS_BANKS:WORD,EMS_WINDOWS:WORD,DRB2:BYTE
        EXTRN USED_LPR:BYTE,BORDER_ENABLE:BYTE,FIRQENR:BYTE,IRQSET:BYTE
        EXTRN HORZ_OFF:BYTE,PALETTE:BYTE,VERT_OFF_1:BYTE,VERT_OFF_0:BYTE
        EXTRN V012:WORD,VMODE:BYTE,SET_SCROLL:NEAR,VERT_SCROLL:BYTE
        EXTRN FIRQSET:BYTE,HSYNC_PULSE:BYTE,HSYNC_SET:NEAR,TMR_DIVIDER:WORD
        EXTRN CEILING:WORD,CART_INT:NEAR,COCO_TOP:WORD,VIDEO_BLOCK:BYTE
        extrn hires_x:word,hires_y:word
        
        EXTRN SPINUP:NEAR,PHYS_READ:NEAR,PHYS_WRITE:NEAR,DRIVE_STATUS:NEAR
        EXTRN FORMAT:NEAR

;General FFxxH page I/O function lookup (byte and word)

DEV_R8:
        CMP BH,0FEH             ;If on $FExx page, go to handler
        JZ DEV_R8_1
        ROL BX,1
        CALL READ[BX+511]
        ROR BX,1
        RET
DEV_R8_1:                       ;If not in fixed mode, treat as normal
        TEST INIT0,8
        MOV ES,SS:[0E000H]
        JZ DEV_R8_2
        MOV ES,TOPRAM           ;else, $FExx always comes from $3F RAM bank
DEV_R8_2:
        MOV AL,ES:[BX]
        RET

DEV_W8:
        CMP BH,0FEH
        JZ DEV_W8_1
        ROL BX,1
        CALL WRITE[BX+511]
        ROR BX,1
        RET
DEV_W8_1:
        TEST INIT0,8
        MOV ES,SS:[0E000H]
        JZ DEV_W8_2
        MOV ES,TOPRAM
DEV_W8_2:
        MOV ES:[BX],AL
        RET

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

NR:
        MOV ES,SS:[8]
        ROR BX,1
        MOV AL,ES:[BX]
        ROL BX,1
        RET

NW:
        RET

;Initialization Register 0

FF90W:
        PUSH AX
        XCHG AL,INIT0
        XOR AL,INIT0 
        TEST AL,43H     ;If MMU enable (bit 6) or ROM mode (bits 1, 0) 
        JZ FF90W_1      ;change, correct banks
        CALL FIX_BANKS
FF90W_1:
        TEST AL,128
        JZ FF90W_2
        MOV AL,VRES     ;Establish CoCo=0 graphics mode
        MOV USED_VRES,AL
        TEST INIT0,128  ;If we are going to CoCo=1 mode, make sure TOP
        JZ FF90W_3      ;or BOTTOM set properly
        MOV AX,COCO_TOP ;Calculate CoCo=1 screen TOP
        ADD AX,HORIZ_TOP
        MOV NEW_TOP,AX
        MOV AL,DRB2     ;Re-establish CoCo=1 video mode
        NOT BYTE PTR DRB2_COMPARE
        CALL FF22W
FF90W_3:
        CALL HSYNC_SET
        POP AX
        JMP UPDATE_BOTTOM
FF90W_2:
        CALL HSYNC_SET
        POP AX
        RET

;Initialization Register 1

FF91W:
        PUSH AX
        XCHG AL,INIT1
        XOR AL,INIT1
        TEST AL,1       ;If MMU's Task Register (bit 0) changes, correct
        JZ FF91W_1      ;banks
        TEST INIT0,64   ;Unless MMU not enabled
        JZ FF91W_1
        CALL FIX_BANKS
FF91W_1:
        POP AX
        RET

;Interrupt Request Enable Register

FF92W:
        PUSH AX
        AND AL,63
        MOV IRQENR,AL
        CALL HSYNC_SET
        POP AX
        RET

FF92R:
        MOV AL,0        ;Reset IRQ pending register when read
        XCHG AL,IRQSET
        RET

;Fast Interrupt Request Enable Register

FF93W:
        PUSH AX
        AND AL,63
        MOV FIRQENR,AL
        CALL HSYNC_SET
        POP AX
        RET

FF93R:
        MOV AL,0 
        XCHG AL,FIRQSET
        RET

;Programmable interval timer

HSYNC_TO_3580KHZ DB 228

FF94W:
        PUSH AX
        AND AL,15
        MOV BYTE PTR CEILING[1],AL
FF94W_0:
        MOV AX,CEILING
        TEST INIT1,32
        JZ FF94W_1
        DIV BYTE PTR HSYNC_TO_3580KHZ
        CMP AH,1
        SBB AL,-1               ;Round up
        MOV AH,0
FF94W_1:
        MOV TMR_DIVIDER,AX
        POP AX
        RET

FF95W:
        MOV BYTE PTR CEILING,AL
        PUSH AX
        JMP FF94W_0

;Video Mode Register

CHAR_LINES DB 8         ;Number of lines/character

FF98W:
        PUSH AX
        MOV AH,VMODE
        MOV VMODE,AL
        XOR AH,AL
        TEST AH,7
        JZ FF98W_1
        PUSH AX
        PUSH BX
        MOV BX,AX
        AND BX,7
        MOV AL,LENGTH_TABLE[BX]
        MOV CHAR_LINES,AL
        POP BX
        POP AX
        TEST INIT0,128  ;If in CoCo=0 mode...
        JNZ FF98W_1
        CMP LASTKEY,3BH ;and not in debugger...
        JZ FF98W_1
        PUSH AX
        PUSH DX
        MOV AL,CHAR_LINES
        MOV USED_LPR,AL ;Update lines/row for graphics routine
        DEC AL
        OR AL,0C0H
        MOV AH,AL       ;and update PC's lines/row register
        MOV AL,9
        MOV DX,3D4H
        OUT DX,AX
        POP DX
        POP AX
FF98W_1:        
        TEST INIT0,128  ;If in CoCo=0 mode and LPR or BP changed, update
        JNZ FF98W_2     ;bottom of video
        TEST AH,87H
        JZ FF98W_2
        POP AX
        JMP UPDATE_BOTTOM
FF98W_2:
        POP AX
        RET

LENGTH_TABLE DB 1,2,3,8,9,10,11,16

;Video Resolution Register

FF99W:
        PUSH AX
        MOV AH,VRES
        MOV VRES,AL
        CMP AH,AL
        JNZ FF99W_1
        POP AX
        RET
FF99W_1:
        TEST INIT0,128          ;For CoCo=1 mode:
        JZ FF99W_4
        TEST AH,16              ;If horizontal clock rate changed
        JZ FF99W_3
        TEST BYTE PTR DRB2,128  ;and in a graphics mode
        JZ FF99W_3
        AND AL,10H              ;change HRES2 in USED_VRES
        AND BYTE PTR USED_VRES,0EFH
        OR USED_VRES,AL
        JMP FF99W_3
FF99W_4:
        MOV USED_VRES,AL        ;In CoCo=0 mode, USED_VRES is VRES
FF99W_3:
        POP AX
        JMP UPDATE_BOTTOM

;Border Overscan Colour Register

FF9AW:
        PUSH AX         ;This is largely the same as FFB0W below, except
        PUSH BX         ;in CoCo=1 mode
        PUSH DX
        MOV OVERSCAN,AL
        TEST BORDER_ENABLE,-1
        JZ FF9AW_3      ;If disabled, do nothing (also if debug active)
        CMP LASTKEY,3BH
        JZ FF9AW_3
        TEST INIT0,128  ;If in CoCo=1 mode
        JZ FF9AW_1
        MOV AL,PALETTE[8]       ;Use palette colour 8 for text screen
        TEST DRB2,128
        JZ FF9AW_1
        MOV BL,COLOUR_BASE      ;COLOUR_BASE for 4-colour screen
        MOV BH,0
        TEST DRB2,16
        JZ FF9AW_4
        INC BL          ;COLOUR_BASE+1 for 2-colour screen
FF9AW_4:
        MOV AL,PALETTE[BX]
FF9AW_1:
        MOV BX,OFFSET PALETTE_XLAT
        AND AL,63
        TEST COLSET,-1
        JZ FF9AW_2
        OR AL,64
FF9AW_2:
        XLAT
        MOV AH,AL
        MOV DX,3DAH
        IN AL,DX
        MOV DX,3C0H
        MOV AL,17
        OUT DX,AL
        MOV AL,AH
        OUT DX,AL
        MOV AL,32
        OUT DX,AL
FF9AW_3:
        POP DX
        POP BX
        POP AX
        RET

;2Mb extension of GIME controller

FF9BW:
        PUSH AX
        AND AL,3                ;Store A20-A19 of video address
        AND VIDEO_BLOCK,7
        SHL AL,1
        SHL AL,1
        SHL AL,1
        MOV AH,MEM_MASK
        SHR AH,1
        SHR AH,1
        SHR AH,1
        AND AL,AH
        OR VIDEO_BLOCK,AL
        POP AX
        JMP UPDATE_BOTTOM

;Vertical Scroll Register

FF9CW:
        PUSH AX
        AND AL,15
        MOV AH,VERT_SCROLL
        MOV VERT_SCROLL,AL
        CMP AH,AL
        JZ FF9CW_1
        CMP LASTKEY,3BH
        JZ FF9CW_1
        CALL SET_SCROLL
FF9CW_1:
        POP AX
        RET

;Vertical Offset Registers

FF9DW:
        PUSH AX
        XCHG AL,VERT_OFF_1
        CMP AL,VERT_OFF_1
        POP AX
        JNZ FF9DW_1
        RET
FF9DW_1:
        TEST INIT0,128
        JNZ FF9DW_2
        PUSH AX                 ;If not in CoCo mode, VERT_OFF determines
        MOV AX,NEW_TOP          ;full TOP address
        SUB NEW_BOTTOM,AX
        MOV AL,VERT_OFF_0
        MOV AH,VERT_OFF_1
        SHL AX,1
        SHL AX,1
        SHL AX,1
        ADD AX,HORIZ_TOP
        MOV NEW_TOP,AX
        ADD NEW_BOTTOM,AX
        POP AX
FF9DW_2:                        ;Make sure video is on correct segment
        PUSH AX
        MOV AL,VERT_OFF_1
        SHR AL,1
        SHR AL,1
        SHR AL,1
        SHR AL,1
        SHR AL,1
        MOV AH,MEM_MASK
        SHR AH,1
        SHR AH,1
        SHR AH,1
        AND AH,0F8H
        AND VIDEO_BLOCK,AH
        OR VIDEO_BLOCK,AL       ;Store A18-A16 of video address
        POP AX
        JMP UPDATE_BOTTOM

FF9EW:
        PUSH AX
        XCHG AL,VERT_OFF_0
        CMP AL,VERT_OFF_0
        POP AX
        JNZ FF9DW_1
        RET

;This routine sets the low and high video addresses for each bank in order to
;identify what parts of a bank might be video RAM

FIX_VIDEO:
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH DI
        MOV AH,VIDEO_BLOCK      ;Calculate MMU bank for video TOP
        MOV AL,BYTE PTR NEW_TOP[1]
        ROL AX,1
        ROL AX,1
        ROL AX,1
        MOV CL,AH
        MOV AH,VIDEO_BLOCK      ;Calculate MMU bank for video BOTTOM
        MOV AL,BYTE PTR NEW_BOTTOM[1]
        MOV BX,NEW_TOP          ;If it rolls over to next block, go to next
        CMP BX,NEW_BOTTOM       ;block's BOTTOM
        JB FIX_VIDEO0
        INC AH
FIX_VIDEO0:
        ROL AX,1
        ROL AX,1
        ROL AX,1
        MOV CH,AH
        MOV DI,0                ;Point to bank 0's TOP address
        MOV BX,0
        MOV DL,0                ;These bits ORed with MMU to restrict address
        CMP EMS_ENABLE,0
        JNZ FIX_VIDEO4
        MOV DL,30H              ;If no EMS, restrict to 128K
        OR CX,3030H
FIX_VIDEO4:
        TEST INIT1,1            ;Select MMU bank appropriate for task reg.
        JZ FIX_VIDEO1
        MOV BL,8
FIX_VIDEO1:
        MOV WORD PTR SS:[DI+6],0;Default is no video on bank
        MOV BH,0
        MOV BH,MMU[BX]
        OR BH,DL
        AND BH,MEM_MASK
        CMP CH,BH               ;If MMU bank does not lie in video memory
        JB FIX_VIDEO3           ;skip it (BOTTOM is below bank...
        CMP CL,BH               ;...or TOP is above bank)
        JA FIX_VIDEO3
        MOV SS:[DI+4],DI        ;If this bank doesn't have TOP, video starts
        JNZ FIX_VIDEO2          ;at the beginning of the bank
        MOV AX,NEW_TOP          ;Otherwise, video starts at offset TOP&1FFF
        AND AH,1FH
        OR SS:[DI+4],AX
FIX_VIDEO2:
        MOV SS:[DI+6],DI
        ADD BYTE PTR SS:[DI+7],20H
        CMP CH,BH               ;If BOTTOM isn't in this bank, then video RAM
        JNZ FIX_VIDEO3          ;runs to end of bank
        MOV AX,NEW_BOTTOM       ;Otherwise, it ends at offset BOTTOM&1FFF
        AND AH,1FH
        SUB AH,20H
        ADD SS:[DI+6],AX
FIX_VIDEO3:
        ADD DI,2000H            ;Go to next bank
        INC BL
        TEST BL,7
        JNZ FIX_VIDEO1
        POP DI
        POP DX
        POP CX
        POP BX
        POP AX
        RET

;Horizontal Offset Register

HORIZ_TOP DW 0

FF9FW:
        PUSH AX
        XCHG AL,HORZ_OFF
        CMP AL,HORZ_OFF
        POP AX
        JNZ FF9FW_1
        RET
FF9FW_1:
        MOV AX,HORIZ_TOP        ;Remove old offset from TOP and BOTTOM
        SUB NEW_TOP,AX
        SUB NEW_BOTTOM,AX
        MOV AL,HORZ_OFF         ;Calculate new byte offset
        AND AX,127
        SHL AX,1
        MOV HORIZ_TOP,AX
        ADD NEW_TOP,AX          ;Add new offset
        ADD NEW_BOTTOM,AX
        JMP UPDATE_BOTTOM

;MMU register controls

MEM_MASK DB 3FH         ;Memory limiter. 3FH for 512K, FFH for 2Mb

FFA0W:
        ROR BX,1
        CMP AL,MMU[BX-0FFA0H]
        MOV MMU[BX-0FFA0H],AL
        JZ FFA0W_1
        CALL SINGLE_BANK
FFA0W_1:
        ROL BX,1
        RET

FFA0R:
        ROR BX,1
        MOV AL,MMU[BX-0FFA0H]
        AND AL,MEM_MASK
        ROL BX,1
        RET

;This subroutine updates the SS: bank register pointers as appropriate for
;the current MMU settings

INTEXT  DB 3EH,3EH,40H,3CH      ;First MMU bank for external ROM as
                                ;determined by INIT0's bits 1 and 0
MMU_DISABLED DB 38H,39H,3AH,3BH,3CH,3DH,3EH,3FH
                                ;Settings if MMU disabled

FIX_BANKS:
        PUSH AX
        PUSH BX
        PUSH DI
        MOV DI,0
        MOV BX,OFFSET MMU_DISABLED
        TEST INIT0,64   ;If MMU disabled, use default "CoCo mode"
        JZ FIX_BANKS_1
        MOV BL,INIT1    ;Select MMU bank as determined by task register
        SHL BL,1
        SHL BL,1
        SHL BL,1
        AND BX,8
        ADD BX,OFFSET MMU
FIX_BANKS_1:
        MOV AL,[BX]
        AND AL,3FH      ;If ROM area selected, and ROM enabled, select
        CMP AL,3CH      ;internal/external bank instead of RAM
        JB FIX_BANKS_4
        CMP ROM_STATUS,0DEH
        JNZ FIX_BANKS_4
        PUSH BX         ;Determine if internal or external ROM
        MOV BL,INIT0
        AND BX,3
        MOV AH,INTEXT[BX]
        POP BX
        CMP AL,AH
        JB FIX_BANKS_2
        ROL AL,1        ;Ok, this is an external bank of 8K, we want 200H
        MOV AH,AL       ;* least significant 2 bits to get the segment offset
        AND AX,600H
        ADD AH,8
        ADD AX,SS:[8]   ;External ROM 8K block base address
        PUSH BX
        MOV BX,DI       ;Align base address for given RAM block
        SHR BX,1
        SHR BX,1
        SHR BX,1
        SHR BX,1
        SUB AX,BX
        POP BX
        JMP FIX_BANKS_3
FIX_BANKS_2:
        MOV AX,SS:[8]   ;Load segment of external ROM
        SUB AH,8        ;Make it internal ROM
        TEST DI,8000H
        JNZ FIX_BANKS_3
        ADD AH,8        ;If in $0-$7FFF, adjust segment start
FIX_BANKS_3:
        MOV SS:[DI],AX
        MOV AX,SS:[10]  ;Also set write segment to be the null segment
        ADD AH,2
        MOV SS:[DI+2],AX
        MOV AX,DI
        SHR AX,1        ;Subtract CoCo base address of bank
        SHR AX,1
        SHR AX,1
        SHR AX,1
        SUB SS:[DI+2],AX
        JMP FIX_BANKS_6
FIX_BANKS_4:
        MOV AL,[BX]     ;Reload bank register
        AND AL,MEM_MASK
        CMP EMS_ENABLE,0
        JNZ FIX_BANKS_5
        OR AL,30H       ;If no EMS, restrict to 128K
FIX_BANKS_5:
        CMP AL,30H
        JB EMS_HANDLER
        CMP AL,40H
        JB BASICRAM
        SUB AL,16       ;Keep EMS usage compact.  $30-$3F is conventional RAM
        JMP EMS_HANDLER
BASICRAM:
        SUB AL,30H      ;Work out segment offset of bank from RAMBANK
        ADD AL,AL
        MOV AH,AL
        MOV AL,0
        ADD AX,SS:[10]  ;Add RAMBANK to it
        MOV SS:[DI],AX
FIX_BANKS_8:
        MOV AX,DI
        SHR AX,1        ;Subtract CoCo base address of bank
        SHR AX,1
        SHR AX,1
        SHR AX,1
        SUB SS:[DI],AX
        MOV AX,SS:[DI]  ;Set write segment to be same as read segment
        MOV SS:[DI+2],AX
FIX_BANKS_6:
        INC BX
        ADD DI,2000H
        JZ FIX_BANKS_7
        JMP FIX_BANKS_1
FIX_BANKS_7:
        POP DI
        POP BX
        POP AX
        JMP FIX_VIDEO   ;If MMU changed, video RAM markers must be updated
EMS_HANDLER:            ;EMS enabled and an EMS bank has been addressed
        PUSH BX
        PUSH DX
        PUSH CX         ;Each MMU block has its own EMS window
        MOV CL,4
        MOV BX,DI
        ROL BX,CL
        POP CX
        MOV DX,EMS_BANKS[BX]    ;Get EMS window number
        MOV BX,EMS_WINDOWS[BX]  ;Get EMS window segment
        MOV SS:[DI],BX          ;Store base segment
        SHR AL,1
        JNB EMS_HANDLER_1       ;If in upper 8K of bank, add offset to seg.
        ADD BYTE PTR SS:[DI+1],2
EMS_HANDLER_1:
        MOV BL,AL       ;Logical page number is A18-A14 address lines
        MOV BH,0
        MOV AH,44H
        MOV AL,DL       ;EMS window number is "physical page number"
        MOV DX,EMS_HANDLE
        INT 67H
        POP DX
        POP BX
        JMP FIX_BANKS_8 ;Return to regular handler

SINGLE_BANK:
        PUSH AX
        PUSH CX
        PUSH DI
        MOV AX,BX       ;Calculate base address of this 8K bank
        MOV CL,13
        SHL AX,CL
        MOV DI,AX
        TEST INIT0,64   ;If MMU enabled
        JZ SINGLE_BANK0
        MOV AL,INIT1    ;and task register has selected this MMU set
        ADD AL,AL       ;update RAM pointers
        ADD AL,AL
        ADD AL,AL
        XOR AL,BL
        AND AL,8
        JZ SINGLE_BANK1
SINGLE_BANK0:
        POP DI
        POP CX
        POP AX
        RET
SINGLE_BANK1:           ;Figure out physical address of bank
        MOV AL,MMU[BX-0FFA0H]
        AND AL,3FH      ;If ROM area selected, and ROM enabled, select
        CMP AL,3CH      ;internal/external bank instead of RAM
        JB SINGLE_BANK4
        CMP ROM_STATUS,0DEH
        JNZ SINGLE_BANK4
        PUSH BX         ;Determine if internal or external ROM
        MOV BL,INIT0
        AND BX,3
        MOV AH,INTEXT[BX]
        POP BX
        CMP AL,AH
        JB SINGLE_BANK2
        ROL AL,1        ;Ok, this is an external bank of 8K, we want 200H
        MOV AH,AL       ;* least significant 2 bits to get the segment offset
        AND AX,600H
        ADD AH,8
        ADD AX,SS:[8]   ;External ROM 8K block base address
        PUSH BX
        MOV BX,DI       ;Align base address for given RAM block
        SHR BX,1
        SHR BX,1
        SHR BX,1
        SHR BX,1
        SUB AX,BX
        POP BX
        JMP SINGLE_BANK3
SINGLE_BANK2:
        MOV AX,SS:[8]   ;Load segment of external ROM
        SUB AH,8        ;Make it internal ROM
        TEST DI,8000H
        JNZ SINGLE_BANK3
        ADD AH,8        ;If in $0-$7FFF, adjust segment start
SINGLE_BANK3:
        MOV SS:[DI],AX
        MOV AX,SS:[10]  ;Also set write segment to be the null segment
        ADD AH,2
        MOV SS:[DI+2],AX
        MOV AX,DI
        SHR AX,1        ;Subtract CoCo base address of bank
        SHR AX,1
        SHR AX,1
        SHR AX,1
        SUB SS:[DI+2],AX
        JMP VIDEO_SINGLE
SINGLE_BANK4:
        MOV AL,MMU[BX-0FFA0H]
        AND AL,MEM_MASK
        CMP EMS_ENABLE,0
        JNZ SINGLE_BANK5
        OR AL,30H       ;If no EMS, restrict to 128K
SINGLE_BANK5:
        CMP AL,30H
        JB EMS_SINGLE
        CMP AL,40H
        JB BASICRAM1
        SUB AL,16       ;Keep EMS usage compact.  $30-$3F is conventional RAM
        JMP EMS_SINGLE
BASICRAM1:
        SUB AL,30H      ;Work out segment offset of bank from RAMBANK
        ADD AL,AL
        MOV AH,AL
        MOV AL,0
        ADD AX,SS:[10]  ;Add RAMBANK to it
        MOV SS:[DI],AX
SINGLE_BANK8:
        MOV AX,DI
        SHR AX,1        ;Subtract CoCo base address of bank
        SHR AX,1
        SHR AX,1
        SHR AX,1
        SUB SS:[DI],AX
        MOV AX,SS:[DI]  ;Set write segment to be same as read segment
        MOV SS:[DI+2],AX
        JMP VIDEO_SINGLE
EMS_SINGLE:             ;EMS enabled and an EMS bank has been addressed
        PUSH BX
        PUSH DX
        MOV BX,DI       ;Each MMU block has its own EMS window
        MOV CL,4
        ROL BX,CL
        MOV DX,EMS_BANKS[BX]    ;Get EMS window number
        MOV BX,EMS_WINDOWS[BX]  ;Get EMS window segment
        MOV SS:[DI],BX  ;Store base segment
        SHR AL,1
        JNB EMS_SINGLE1 ;If in upper 8K of bank, add offset to seg.
        ADD BYTE PTR SS:[DI+1],2
EMS_SINGLE1:
        MOV BL,AL       ;Logical page number is A18-A14 address lines
        MOV BH,0
        MOV AH,44H
        MOV AL,DL       ;EMS window number is "physical page number"
        MOV DX,EMS_HANDLE
        INT 67H
        POP DX
        POP BX
        JMP SINGLE_BANK8;Return to regular handler
VIDEO_SINGLE: 
        PUSH BX
        PUSH DX
        PUSH BX
        MOV AH,VIDEO_BLOCK      ;Calculate MMU bank for video TOP
        MOV AL,BYTE PTR NEW_TOP[1]
        ROL AX,1
        ROL AX,1
        ROL AX,1
        MOV CL,AH
        MOV AH,VIDEO_BLOCK      ;Calculate MMU bank for video BOTTOM
        MOV AL,BYTE PTR NEW_BOTTOM[1]
        MOV BX,NEW_TOP          ;If it rolls over to next block, go to next
        CMP BX,NEW_BOTTOM       ;block's BOTTOM
        JB VIDEO_SINGLE0
        INC AH
VIDEO_SINGLE0:
        ROL AX,1
        ROL AX,1
        ROL AX,1
        MOV CH,AH
        MOV DL,0                ;These bits ORed with MMU to restrict address
        CMP EMS_ENABLE,0
        JNZ VIDEO_SINGLE1
        MOV DL,30H              ;If no EMS, restrict to 128K
        OR CX,3030H
VIDEO_SINGLE1:
        MOV WORD PTR SS:[DI+6],0;Default is no video on bank
        POP BX
        MOV BH,MMU[BX-0FFA0H]
        OR BH,DL
        AND BH,MEM_MASK
        CMP CH,BH               ;If MMU bank does not lie in video memory
        JB VIDEO_SINGLE3        ;skip it (BOTTOM is below bank...
        CMP CL,BH               ;...or TOP is above bank)
        JA VIDEO_SINGLE3
        MOV SS:[DI+4],DI        ;If this bank doesn't have TOP, video starts
        JNZ VIDEO_SINGLE2       ;at the beginning of the bank
        MOV AX,NEW_TOP          ;Otherwise, video starts at offset TOP&1FFF
        AND AH,1FH
        OR SS:[DI+4],AX
VIDEO_SINGLE2:
        MOV SS:[DI+6],DI
        ADD BYTE PTR SS:[DI+7],20H
        CMP CH,BH               ;If BOTTOM isn't in this bank, then video RAM
        JNZ VIDEO_SINGLE3       ;runs to end of bank
        MOV AX,NEW_BOTTOM       ;Otherwise, it ends at offset BOTTOM&1FFF
        AND AH,1FH
        SUB AH,20H
        ADD SS:[DI+6],AX
VIDEO_SINGLE3:
        POP DX
        POP BX
        POP DI
        POP CX
        POP AX
        RET

;Palette registers

FFB0W:
        PUSH AX         ;Convert bit ordering to PC style
        PUSH BX
        PUSH DX
        ROR BX,1
        CMP AL,PALETTE[BX-0FFB0H]
        JZ FFB0W_1
        MOV PALETTE[BX-0FFB0H],AL
        CMP LASTKEY,3BH
        JZ FFB0W_1
        PUSH BX
        MOV BX,OFFSET PALETTE_XLAT
        AND AL,63
        TEST COLSET,-1
        JZ FFB0W_0
        OR AL,64
FFB0W_0:
        XLAT
        MOV AH,AL
        MOV DX,3DAH
        IN AL,DX
        MOV DX,3C0H
        POP BX
        MOV AL,BL
        TEST BYTE PTR INIT0,128
        JZ FFB0W_2              ;If in CoCo=1 mode,
        TEST BYTE PTR DRB2,128
        JNZ FFB0W_2             ;and in text mode
        XOR AL,8                ;palette cols. 0-7 and 8-15 reversed
FFB0W_2:
        AND AL,15
        OUT DX,AL
        MOV AL,AH
        OUT DX,AL
        MOV AL,32
        OUT DX,AL
        TEST INIT0,128          ;If in CoCo=1 mode...
        JZ FFB0W_1
        CMP BL,0B8H             ;and palette 8 while in text mode
        JNZ FFB0W_3
        TEST DRB2,128
        JZ FFB0W_4
FFB0W_3:
        AND BL,15               ;or it's COLOUR_BASE+1 in graphics mode
        DEC BL
        CMP BL,COLOUR_BASE
        JNZ FFB0W_1
        TEST DRB2,128
        JZ FFB0W_1
FFB0W_4:                        ;then set overscan register to match it
        MOV AL,OVERSCAN
        CALL FF9AW
FFB0W_1:
        POP DX
        POP BX
        POP AX
        RET

FFB0R:
        ROR BX,1
        MOV AL,PALETTE[BX-0FFB0H]
        ROL BX,1
        AND AL,63
        OR AL,64
        RET

PALETTE_XLAT DB 00H,08H,10H,18H,20H,28H,30H,38H
        DB 01H,09H,11H,19H,21H,29H,31H,39H
        DB 02H,0AH,12H,1AH,32H,3AH,42H,4AH
        DB 03H,0BH,13H,1BH,23H,2BH,33H,3BH
        DB 04H,0CH,14H,1CH,24H,2CH,34H,3CH
        DB 05H,0DH,15H,1DH,25H,2DH,35H,3DH
        DB 06H,0EH,16H,1EH,26H,2EH,36H,3EH
        DB 07H,0FH,17H,1FH,27H,2FH,37H,3FH
;Composite mode translations
        DB 0,16,48,48,20,20,4,36,44,5,33,1,17,35,24,16
        DB 56,34,18,38,6,5,52,39,53,29,9,25,17,3,19,42
        DB 7,58,30,2,54,46,60,47,61,29,57,11,43,59,27,19
        DB 63,23,55,46,23,39,39,47,47,15,15,15,31,31,23,63

;PIA1 support - keyboard matrix

FF00W:
        TEST BYTE PTR CRA1,4
        JNZ FF00W_1
        MOV DDRA1,AL
FF00W_1:
        RET

FF01W:
        MOV CRA1,AL
        RET

FF02W:
        TEST BYTE PTR CRB1,4
        JZ FF02W_1
        MOV DRB1,AL
        PUSH AX
        CALL EI1_CHECK
        POP AX
        RET
FF02W_1:
        MOV DDRB1,AL
        RET

FF03W:
        MOV CRB1,AL
        RET

CRA1    DB 4
DDRA1   DB 0
CRB1    DB 4
DRB1    DB -1
DDRB1   DB -1
DRA1    DB -1

FF00R:
        TEST BYTE PTR CRA1,4
        JNZ FF00R_0
        MOV AL,DDRA1
        RET
FF00R_0:
        PUSH BX
        MOV AL,DRA1
        AND AL,FIRE
        MOV BH,0
        MOV BL,LJOYSTK  ;Joystick select.  Bit 3 of CRA1 set => left joystick
        TEST BYTE PTR CRB1,8
        JNZ FF00R_1
        MOV BL,RJOYSTK
FF00R_1:
        TEST BYTE PTR CRA1,8
        JZ FF00R_2      ;Bit 3 of CRB1 set => vertical position read
        ADD BL,10
FF00R_2:
        CALL JOYSTICK[BX]
        POP BX
        RET

JOYSTICK DW MOUSE_H     ;Handlers for joystick (mouse, game port left/right,
        DW GAME_AH      ;or none)
        DW GAME_BH
        DW NO_STICK
        dw hires_h
        DW MOUSE_V
        DW GAME_AV
        DW GAME_BV  
        DW NO_STICK
        dw hires_v

FF01R:
        MOV AL,CRA1
        AND AL,31
        OR AL,HSYNC_PULSE       ;Include HSYNC interrupt pending bit
        MOV HSYNC_PULSE,0       ;Reset HSYNC interrupt pending
        RET

FF02R:
        TEST BYTE PTR CRB1,4
        JZ FF02R_1
        MOV PULSE,0             ;Reset bit 7 of CRB1 (clock interrupt flag)
        MOV AL,DRB1
        RET
FF02R_1:
        MOV AL,DDRB1
        RET

FF03R:
        MOV AL,CRB1
        AND AL,31
        OR AL,PULSE             ;Include clock interrupt flag
        RET

;SAM - video memory base/length controller

V_LENGTH DW 2048
        DW 1024
        DW 2048
        DW 1536
        DW 3072
        DW 3072
        DW 6144
        DW 3072

NUM_ROWS DB 16

UPDATE_BOTTOM:
        PUSH AX                 ;First stage is to determine scanlines
        PUSH DX                 ;per character row (i.e. how high is each 
        PUSH DI                 ;character or pixel)
        TEST INIT0,128          ;If in CoCo=0...
        JNZ UPDATE_BOTTOM_1
        MOV AL,CHAR_LINES       ;it's determined by lower 3 bits of $FF98
        MOV USED_LPR,AL         ;This will be the active lines per row for
        JMP UPDATE_BOTTOM_3     ;graphics
UPDATE_BOTTOM_1:
        MOV AL,12               ;If in CoCo=1 and text mode, it's always 12
        TEST BYTE PTR DRB2,128
        JZ UPDATE_BOTTOM_3
        MOV DI,V012             ;Otherwise, it's determined by 
        SHL DI,1                ;192/unmodified_rows where u_r=buffer/16 if
        MOV AX,6144             ;HRES1=0 or 32 if HRES1=1
        TEST DI,10
        JZ UPDATE_BOTTOM_2      ;In 2048 byte buffer mode, HRES1 is always 1
        TEST BYTE PTR USED_VRES,8
        JNZ UPDATE_BOTTOM_2
        SHR AX,1                ;Divide by 2 to get 16*192 if HRES1=0
UPDATE_BOTTOM_2:
        MOV DX,0
        DIV WORD PTR V_LENGTH[DI]
        CMP AL,1                ;Cannot have 0 lines/row.  Minimum is 1.
        ADC AL,0
        MOV USED_LPR,AL         ;Save the lines per row for CoCo 1/2 graphics
UPDATE_BOTTOM_3:                ;Now determine the actual number of scanlines
        MOV DX,192              ;on the screen
        TEST BYTE PTR VRES,96   ;192 lines if LPF=0
        JZ UPDATE_BOTTOM_4
        MOV DL,225
        TEST BYTE PTR VRES,64   ;225 lines if LPF1=1
        JNZ UPDATE_BOTTOM_4
        MOV DL,200              ;else there are 200 lines
UPDATE_BOTTOM_4:                ;Number of character rows=scanlines/lines per
        XCHG DX,AX              ;row
        DIV DL
        CMP AH,1                ;If there is a remainder (part row), round
        SBB AL,-2               ;up.  Also, add another row in case of scroll.
        MOV NUM_ROWS,AL         ;Row count used in GRAPHICS_MODE to set colour
        MOV AH,32               ;Now work out bytes per row (default 32 chars)
        TEST HORZ_OFF,128
        JZ UPDATE_BOTTOM_9
        MOV AH,AL               ;If HVEN=1, always 256 bytes/row
        MOV AL,0
        JMP UPDATE_BOTTOM_7A
UPDATE_BOTTOM_9:
        TEST INIT0,128          ;If in CoCo=0 mode...
        JNZ UPDATE_BOTTOM_5
        TEST VMODE,128
        JNZ UPDATE_BOTTOM_8     ;and BP=1, go to graphics handler
        TEST VRES,4             ;If in CoCo=0 text and HRES0=1...
        JZ UPDATE_BOTTOM_4A
        MOV AH,40               ;then default becomes 40 chars
UPDATE_BOTTOM_4A:
        TEST VRES,1             ;If also in CRES0=1...
        JZ UPDATE_BOTTOM_6
        ADD AH,AH               ;then 2 bytes/character
        JMP UPDATE_BOTTOM_6
UPDATE_BOTTOM_5:
        TEST BYTE PTR DRB2,128  ;If in CoCo=1 mode and graphics selected
        JNZ UPDATE_BOTTOM_8     ;again, go to graphics handler
UPDATE_BOTTOM_6:
        TEST VRES,16            ;In both text modes, if HRES2=1
        JZ UPDATE_BOTTOM_7
        ADD AH,AH               ;Then characters/row are doubled
UPDATE_BOTTOM_7:                ;Multiply bytes per row by number rows to
        MUL AH                  ;get true video RAM size
UPDATE_BOTTOM_7A:
        ADD AX,NEW_TOP          ;Add base address to get end of video RAM
        MOV NEW_BOTTOM,AX
        POP DI
        POP DX
        POP AX
        JMP FIX_VIDEO           ;Update banks' video RAM boundaries
UPDATE_BOTTOM_8:
        MOV AH,16               ;In graphics mode, default is 16 bytes/row
        PUSH CX
        MOV CL,USED_VRES
        TEST CL,4               ;If HRES0=1, then default becomes 20
        JZ UPDATE_BOTTOM_10
        MOV AH,20
UPDATE_BOTTOM_10:
        TEST BYTE PTR V012,5    ;If in 2048 byte buffer mode...
        JNZ UPDATE_BOTTOM_11
        TEST BYTE PTR INIT0,128 ;and in CoCo=1 mode...
        JZ UPDATE_BOTTOM_11
        OR CL,8                 ;HRES1=1 automatically
UPDATE_BOTTOM_11:
        SHR CL,1
        SHR CL,1
        SHR CL,1
        AND CL,3                ;Multiply by 2^(HRES), found in bits 3 and 4
        ROL AH,CL
        POP CX
        JMP UPDATE_BOTTOM_7

COCO_SET MACRO                  ;This will return unless CoCo bit is set
        LOCAL EXECUTE
        TEST INIT0,128
        JNZ EXECUTE
        RET
EXECUTE:
        ENDM

FFC0W:  TEST INIT0,128          ;If in CoCo=0 mode, retain change only
        JZ FFC0W_2
        TEST V012,1
        JZ FFC0W_1
        AND V012,6
        JMP UPDATE_BOTTOM
FFC0W_1:
        RET
FFC0W_2:
        AND V012,6
        RET
FFC1W:  TEST INIT0,128
        JZ FFC1W_1
        TEST V012,1
        JNZ FFC0W_1
        OR V012,1
        JMP UPDATE_BOTTOM
FFC1W_1:
        OR V012,1
        RET
FFC2W:  TEST INIT0,128
        JZ FFC2W_1
        TEST V012,2
        JZ FFC0W_1
        AND V012,5
        JMP UPDATE_BOTTOM
FFC2W_1:
        AND V012,5
        RET
FFC3W:  TEST INIT0,128
        JZ FFC3W_1
        TEST V012,2
        JNZ FFC0W_1
        OR V012,2
        JMP UPDATE_BOTTOM
FFC3W_1:
        OR V012,2
        RET
FFC4W:  TEST INIT0,128
        JZ FFC4W_1
        TEST V012,4
        JZ FFC0W_1
        AND V012,3
        JMP UPDATE_BOTTOM
FFC4W_1:
        AND V012,3
        RET
FFC5W:  TEST INIT0,128
        JZ FFC5W_1
        TEST V012,4
        JNZ FFC5W_2
        OR V012,4
        JMP UPDATE_BOTTOM
FFC5W_1:
        OR V012,4
FFC5W_2:
        RET

CLEAR_BASE MACRO ADDRESS
        AND WORD PTR COCO_TOP,-1-ADDRESS
        COCO_SET        
        PUSH AX
        MOV AX,NEW_TOP
        SUB NEW_BOTTOM,AX
        SUB AX,HORIZ_TOP
        AND AX,-1-ADDRESS
        ADD AX,HORIZ_TOP
        MOV NEW_TOP,AX
        ADD NEW_BOTTOM,AX
        POP AX
        RET
        ENDM

SET_BASE MACRO ADDRESS
        OR WORD PTR COCO_TOP,ADDRESS
        COCO_SET
        PUSH AX
        MOV AX,NEW_TOP
        SUB NEW_BOTTOM,AX
        SUB AX,HORIZ_TOP
        OR AX,ADDRESS
        ADD AX,HORIZ_TOP
        MOV NEW_TOP,AX
        ADD NEW_BOTTOM,AX
        POP AX
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

        EXTRN CPU_SPEED:byte,CPUSpeed:byte

FFD8W:  MOV CPUSpeed,57
        MOV CPU_SPEED,0D8H
        RET
FFD9W:  MOV CPUSpeed,114
        MOV CPU_SPEED,0D9H
        RET

;SAM - ROM enable

FFDEW:               ;Set 32K RAM/32K ROM mode
        CMP ROM_STATUS,0DEH
        MOV ROM_STATUS,0DEH
        JZ FFDEW_1
        CALL FIX_BANKS          ;If ROM mode changed, update MMU
FFDEW_1:
        RET

FFDFW:               ;Set 64K RAM mode
        CMP ROM_STATUS,0DFH
        MOV ROM_STATUS,0DFH
        JZ FFDFW_1
        CALL FIX_BANKS          ;If ROM mode changed, update MMU
FFDFW_1:
        RET

;PIA2 port B support - VDG

FF22R:
        TEST BYTE PTR CRB2,4
        JZ FF22R_1
        MOV AL,DRB2
        MOV PRINTER_BITS,0      ;Reset printer serial buffer
        AND AL,DDRB2            ;Mask off input bits to keep RGB detect on
        OR AL,4                 ;Set RAM size bit
        CMP ADDLF,128
        JNZ FF22R_0
        OR AL,1                 ;If printer disabled, set BUSY high
FF22R_0:
        RET
FF22R_1:
        MOV AL,DDRB2
        RET

CART_FLAG DB 0                  ;This becomes 128 if a cartridge is present

FF23R:
        MOV AL,CRB2
        AND AL,31
        OR AL,CART_FLAG
        RET

CRB2    DB 4
DDRB2   DB -1

FF23W:
        MOV CRB2,AL
        CALL CART_INT
        RET

FF22W:
        TEST BYTE PTR CRB2,4
        JNZ FF22W_1
        MOV DDRB2,AL
        RET
FF22W_1:
        PUSH AX
        CMP AL,128              ;If it's a text mode, don't bother with rev.
        JB FF22W_2
        TEST INIT0,128          ;If not in CoCo=1 mode, doesn't matter anyway
        JZ FF22W_2
        AND AX,78H
        PUSH BX
        SHR AX,1
        SHR AX,1
        MOV BX,AX
        MOV AL,VRES             ;Get HRES2.  (LPF always read from real VRES)
        AND AX,0F0H
        OR AX,WORD PTR V_MODES[BX]
        POP BX                  ;Look up BP-equivalent horizontal resolution
        MOV USED_VRES,AL        ;This is the effective CoCo 3 mode
        MOV COLOUR_BASE,AH      ;CoCo 1/2 modes can use a different colour set
FF22W_2:
        POP AX
        MOV DRB2,AL
        TEST BYTE PTR CRB2,8
        JNZ FF22W_3     ;If DAC sound is disabled, use single bit
        TEST SOUND,1    ;If sound option off, skip
        JZ FF22W_3
        PUSH AX         ;Single bit sound is still channeled through internal
        MOV AH,AL       ;speaker
        AND AH,2
        IN AL,61H
        AND AL,0FCH
        OR AL,AH
        OUT 61H,AL
        POP AX
FF22W_3:
        TEST INIT0,128  ;If in CoCo=1 mode
        JZ FF22W_4
        PUSH AX
        AND AL,0F0H
        CMP AL,DRB2_COMPARE
        MOV DRB2_COMPARE,AL
        POP AX          ;and video mode changed, update bottom
        JZ FF22W_4
        JMP UPDATE_BOTTOM
FF22W_4:
        RET

DRB2_COMPARE DB 0

;Equivalent $FF99 bits 0-3 for CoCo 1/2 graphics modes, plus the lowest
;palette colour displayed in that mode
V_MODES DB 1,0,1,4      ;64 pixels, 4-colour, colour base=4*CSS
        DB 0,8,0,10     ;128 pixels, 2-colour, colour base=2*CSS+8
        DB 9,0,9,4      ;128 pixels, 4-colour, colour base=4*CSS
        DB 0,8,0,10     ;128 pixels, 2-colour, colour base=2*CSS+8
        DB 9,0,9,4      ;128 pixels, 4-colour, colour base=4*CSS
        DB 0,8,0,10     ;128 pixels, 2-colour, colour base=2*CSS+8
        DB 9,0,9,4      ;128 pixels, 4-colour, colour base=4*CSS
        DB 8,8,8,10     ;256 pixels, 2-colour, colour base=2*CSS+8

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

THIS_SPT DB 18                  ;Current drive's sectors per track
THIS_HEADER DB 0                ;Header size for virtual disk data

FF40W:
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
        MOV THIS_SPT,18         ;Reset SPT count
        MOV THIS_HEADER,0       ;Number of header bytes
        MOV BX,AX
        MOV AX,4202H            ;Go to end of file to figure size
        PUSH CX
        MOV CX,0
        MOV DX,0
        POP CX
        INT 21H
        JB FF40W_3
        CMP AL,0                ;Virtual disk non-integral multiple of 256?
        JZ FF40W_3
        MOV THIS_HEADER,AL      ;Then there's a header
        MOV AX,4200H            ;Return to beginning to get header info
        PUSH CX
        MOV CX,0
        MOV DX,0
        INT 21H
        MOV AH,3FH              ;Read header
        MOV DX,OFFSET DTA
        MOV CH,0
        MOV CL,THIS_HEADER
        INT 21H
        POP CX
        JB FF40W_3
        MOV AL,DTA
        MOV THIS_SPT,AL
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

;Floppy Disk Controller handler

FF49R:               ;Track register read
        MOV AL,FDC_TRACK
        RET

FF49W:               ;Track register write
        MOV FDC_TRACK,AL
        RET

FF4AR:               ;Sector register read
        MOV AL,FDC_SECTOR
        RET

FF4AW:               ;Sector register write
        MOV FDC_SECTOR,AL
        RET

FF4BR:               ;Read data register
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

FF4BW:               ;Write data register
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
        MOV AL,THIS_SPT
        MUL BYTE PTR FDC_TRACK
        MOV DH,AL
        MOV CL,AH
        MOV CH,0
        MOV DL,THIS_HEADER
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

CONDITIONAL_NMI:       ;Conditional NMI: suppressed if debug active
        CMP LASTKEY,3BH
        JZ C_NMI1
        MOV FDC_FLAGS,4
        CALL NMI
C_NMI1: RET

FF48R:               ;Read status register
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
        MOV AL,THIS_SPT         ;We're dealing with a virtual disk,
        MUL FDC_TRACK           ;correct write pointer's offset
        ADD AL,FDC_SECTOR
        MOV CH,0
        ADC AH,CH
        DEC AX
        MOV DL,THIS_HEADER
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

FF48W:               ;FDC command register write
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
        MOV AL,THIS_SPT         ;Calculate offset for current "track/sector"
        MOV AH,0
        MUL FDC_TRACK
        PUSH AX
        MOV AL,FDC_SECTOR
        DEC AL
        CMP AL,THIS_SPT
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
        MOV DL,THIS_HEADER
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

;Joystick handlers

MOUSE_H:               ;Read mouse horizontal pos.
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

comparitor_x dw 0
comparitor_y dw 0

hires_h:
        cmp word ptr cs:comparitor_x,0
        jz hires_h1
        dec word ptr cs:comparitor_x
        and al,127
hires_h1:
        ret

hires_v:
        cmp word ptr cs:comparitor_y,0
        jz hires_v1
        dec word ptr cs:comparitor_y
        and al,127
hires_v1:
        ret

MOUSE_V:               ;Read mouse vertical pos.
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

GAME_AH:               ;Read JOYSTICK A horizontal position
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

GAME_AV:               ;Read JOYSTICK A vertical position
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

GAME_BH:               ;Read JOYSTICK B horizontal position
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

GAME_BV:               ;Read JOYSTICK B vertical position
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

NO_STICK: RET

;PIA2 port A -- DAC output, printer output and cassette input

FF20R:
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

FF21R:
        MOV AL,CRA2
        AND AL,31
        RET

FF20W:
        TEST BYTE PTR CRA2,4
        JNZ FF20W_1
        MOV DDRA2,AL
        RET
FF20W_1:
        push ax
        mov ax,cs:hires_x
        mov cs:comparitor_x,ax
        mov ax,cs:hires_y
        mov cs:comparitor_y,ax
        pop ax
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
        CMP AH,AL
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
        AND CL,127
        SHR AL,CL
        POP CX
        OUT DX,AL
FF20W_11:
        POP DX
        POP AX
        RET

FF21W:
        MOV CRA2,AL
        RET

CRA2    DB 4
DDRA2   DB 0
DRA2    DB 0
DAC     DB 0            ;DAC bits.  Range 0-63
PREV_DAC DB 0           ;Previous DAC setting*4.  For comparison in sound
                        ;interpretation
PRINTER_BITS DB 0       ;Printer bit counter, include 1 bit for reset of mark
PRINTER_CHAR DB 0       ;Bit buffer for printer byte

;Vector addresses.  Mapped to BFE0h-BFFFh

FFE0R:
        ROR BX,1
        MOV ES,SS:[8]   ;Get ROMBANK
        MOV AL,ES:[BX-0C000H]
        ROL BX,1
        RET

;Virtual casssette routines

CAS_BYTE DB 0           ;Buffer for cassette byte

CAS_OUT:       ;Write a byte to the virtual cassette
        PUSH AX
        PUSH ES
        MOV ES,SS:[8]   ;Move segment pointer to ROM bank
        MOV AH,ES:[2864H]
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
        MOV AH,ES:[2876H]
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

;Advanced functions

LRN     DB 0,0,0,0
HDHANDLE DW -1
HDFILE  DB 'COCO3.VHD',0
HDERROR DB -1
HDBUFFER DB 0,0

FF80W:                  ;$FF80: Set logical record number
        MOV LRN[3],AL
        RET

FF81W:
        MOV LRN[2],AL
        RET

FF82W:
        MOV LRN[1],AL
        RET

FF80R:
        MOV AL,LRN[3]
        RET

FF81R:
        MOV AL,LRN[2]
        RET

FF82R:
        MOV AL,LRN[1]
        RET

FF83R:                          ;$FF83 read: status register
        MOV AL,HDERROR
        RET

FF83W:
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH AX
        MOV BX,HDHANDLE
        CMP BX,-1
        JNZ HDOPEN
        MOV AX,3D02H
        MOV DX,OFFSET HDFILE
        INT 21H
        JB FF83W_ERROR
        MOV HDHANDLE,AX
        MOV BX,AX
HDOPEN:
        MOV AX,4200H            ;Seek LRN
        MOV CX,WORD PTR LRN[2]
        MOV DX,WORD PTR LRN
        INT 21H
        JB FF83W_ERROR
        POP AX
        PUSH AX
        CMP AL,0
        JZ HDREAD
        CMP AL,2
        JZ HDCLOSE
        JNB HDUNDEFINED
        PUSH DS
        PUSH SI
        MOV DX,WORD PTR HDBUFFER
        MOV SI,DX
        AND SI,0E000H
        MOV DS,SS:[SI]
        MOV CX,256              ;Write sector (command $01)
        MOV AH,40H
        INT 21H
        POP SI
        POP DS
        JB FF83W_ERROR
        XOR AL,AL
        JMP FF83W_ERROR
HDUNDEFINED:
        MOV HDERROR,-2
        JMP FF83W_ERROR
HDREAD:
        PUSH DS
        PUSH SI
        MOV DX,WORD PTR HDBUFFER
        MOV SI,DX
        AND SI,0E000H
        MOV DS,SS:[SI]
        MOV CX,256              ;Read sector (command $00)
        MOV AH,3FH
        INT 21H
        POP SI
        POP DS
        JB FF83W_ERROR
        XOR AL,AL
        JMP FF83W_ERROR
HDCLOSE:
        MOV AH,3EH              ;Close drive (command $02)
        INT 21H
        MOV HDHANDLE,-1
        JB FF83W_ERROR
        XOR AL,AL
FF83W_ERROR:
        MOV HDERROR,AL
        POP AX
        POP DX
        POP CX
        POP BX
        RET

FF84R:
        MOV AL,HDBUFFER[1]
        RET

FF84W:
        MOV HDBUFFER[1],AL
        RET

FF85R:
        MOV AL,HDBUFFER
        RET

FF85W:
        MOV HDBUFFER,AL
        RET

FF86R:
        MOV AL,BYTE PTR HIRES_X[1]
        RET

FF87R:
        MOV AL,BYTE PTR HIRES_X
        RET

FF88R:
        MOV AL,BYTE PTR HIRES_Y[1]
        RET

FF89R:
        MOV AL,BYTE PTR HIRES_Y
        RET

TIMEDATE DB 9 DUP(0)

FFC0R:  PUSH AX
        PUSH CX
        PUSH DX
        PUSH SI
        PUSH DI
        PUSH BP
        MOV AH,2AH
        INT 21H
        MOV TIMEDATE[2],DH
        MOV TIMEDATE[3],DL
        MOV TIMEDATE[4],AL
        MOV AX,CX
        MOV CL,100
        DIV CL
        MOV WORD PTR TIMEDATE,AX
        MOV AH,2CH
        INT 21H
        MOV TIMEDATE[5],CH
        MOV TIMEDATE[6],CL
        MOV TIMEDATE[7],DH
        MOV TIMEDATE[8],DL
        POP BP
        POP DI
        POP SI
        POP DX
        POP CX
        POP AX
        MOV AL,TIMEDATE         ;Year MSB
        RET
FFC1R:  MOV AL,TIMEDATE[1]      ;Year LSB
        RET
FFC2R:  MOV AL,TIMEDATE[2]      ;Month
        RET
FFC3R:  MOV AL,TIMEDATE[3]      ;Day
        RET
FFC4R:  MOV AL,TIMEDATE[4]      ;Day of week
        RET
FFC5R:  MOV AL,TIMEDATE[5]      ;Hour
        RET
FFC6R:  MOV AL,TIMEDATE[6]      ;Minutes
        RET
FFC7R:  MOV AL,TIMEDATE[7]      ;Seconds
        RET
FFC8R:  MOV AL,TIMEDATE[8]      ;Hundredths
        RET

NATIVE  DB 0,0,0

FF86W:                          ;Security key to activate native mode
FF87W:
FF88W:
        ROR BX,1
        MOV NATIVE[BX-0FF86H],AL
        ROL BX,1
        RET

;RS-232 I/O emulation

RS232_IN DB 0
RS232_STATUS DB 10H
RS232_COMMAND DB 0
RS232_CONTROL DB 0

UPDATE_RS232_STATUS:
        MOV DH,RS232_STATUS
        AND DH,18H
        MOV DL,AL               ;Carrier detect: bit 7 of AL to bit 5
        ROR DL,1
        ROR DL,1
        NOT DL
        AND DL,20H
        OR DH,DL
        MOV DL,AL               ;Data set ready: bit 5 of AL to bit 6
        ROL DL,1
        NOT DL
        AND DL,40H
        OR DH,DL
        MOV DL,AH               ;Receive data ready: bit 0 of AH to bit 3
        ROL DL,1
        ROL DL,1
        ROL DL,1
        AND DL,8
        OR DH,DL
        MOV DL,AH               ;Overrun: bit 1 of AH to bit 2
        ROL DL,1
        AND DL,4
        OR DH,DL
        MOV DL,AH               ;Framing error: bit 3 of AH to bit 1
        ROR DL,1                ;Parity error: bit 2 of AH to bit 0
        ROR DL,1
        AND DL,3
        OR DH,DL
        MOV RS232_STATUS,DH
        RET

FF68R:
        PUSH AX
        PUSH DX
        PUSH SI
        PUSH DI
        PUSH BP
        MOV AH,3
        MOV DH,0
        MOV DL,VOLUME
        ROL DL,1
        AND DL,1
        PUSH DX
        INT 14H
        CALL UPDATE_RS232_STATUS
        POP DX
        TEST AH,1
        JZ FF68R_1
        MOV AH,2
        INT 14H
        MOV RS232_IN,AL
FF68R_1:
        POP BP
        POP DI
        POP SI
        POP DX
        POP AX
        MOV AL,RS232_IN
        AND RS232_STATUS,0FFH-8 ;Clear data ready flag
        RET
FF69R:
        PUSH AX
        PUSH DX
        PUSH SI
        PUSH DI
        PUSH BP
        MOV AH,3
        MOV DH,0
        MOV DL,VOLUME
        ROL DL,1
        AND DL,1
        INT 14H
        CALL UPDATE_RS232_STATUS
        POP BP
        POP DI
        POP SI
        POP DX
        POP AX
        MOV AL,RS232_STATUS
        RET
FF6AR:
        MOV AL,RS232_COMMAND
        RET
FF6BR:
        MOV AL,RS232_CONTROL
        RET

FF68W:
        PUSH AX
        PUSH DX
        PUSH SI
        PUSH DI
        PUSH BP
        MOV AH,1
        MOV DH,0
        MOV DL,VOLUME
        ROL DL,1
        AND DL,1
        INT 14H
        POP BP
        POP DI
        POP SI
        POP DX
        POP AX
        RET
FF69W:
        MOV RS232_STATUS,10H
        AND RS232_COMMAND,0E0H
        RET
FF6AW:
        MOV RS232_COMMAND,AL
        RET
FF6BW:
        MOV RS232_CONTROL,AL
        RET

;Memory function lookup table

READ    DW FF00R,FF01R,FF02R,FF03R,FF00R,FF01R,FF02R,FF03R
        DW FF00R,FF01R,FF02R,FF03R,FF00R,FF01R,FF02R,FF03R
        DW FF00R,FF01R,FF02R,FF03R,FF00R,FF01R,FF02R,FF03R
        DW FF00R,FF01R,FF02R,FF03R,FF00R,FF01R,FF02R,FF03R
        DW FF20R,FF21R,FF22R,FF23R,FF20R,FF21R,FF22R,FF23R
        DW FF20R,FF21R,FF22R,FF23R,FF20R,FF21R,FF22R,FF23R
        DW FF20R,FF21R,FF22R,FF23R,FF20R,FF21R,FF22R,FF23R
        DW FF20R,FF21R,FF22R,FF23R,FF20R,FF21R,FF22R,FF23R
        DW NR,   NR,   NR,   NR,   NR,   NR,   NR,   NR
        DW FF48R,FF49R,FF4AR,FF4BR,FF48R,FF49R,FF4AR,FF4BR
        DW NR,   NR,   NR,   NR,   NR,   NR,   NR,   NR
        DW FF48R,FF49R,FF4AR,FF4BR,FF48R,FF49R,FF4AR,FF4BR
        DW FF68R,FF69R,FF6AR,FF6BR,FF68R,FF69R,FF6AR,FF6BR
        DW FF68R,FF69R,FF6AR,FF6BR,FF68R,FF69R,FF6AR,FF6BR
        DW FF68R,FF69R,FF6AR,FF6BR,FF68R,FF69R,FF6AR,FF6BR
        DW FF68R,FF69R,FF6AR,FF6BR,FF68R,FF69R,FF6AR,FF6BR
        DW FF80R,FF81R,FF82R,FF83R,FF84R,FF85R,FF86R,FF87R
        DW FF88R,FF89R,NR,   NR,   NR,   NR,   NR,   NR
        DW NR,   NR,   FF92R,FF93R,NR,   NR,   NR,   NR
        DW NR,   NR,   NR,   NR,   NR,   NR,   NR,   NR
        DW FFA0R,FFA0R,FFA0R,FFA0R,FFA0R,FFA0R,FFA0R,FFA0R
        DW FFA0R,FFA0R,FFA0R,FFA0R,FFA0R,FFA0R,FFA0R,FFA0R
        DW FFB0R,FFB0R,FFB0R,FFB0R,FFB0R,FFB0R,FFB0R,FFB0R
        DW FFB0R,FFB0R,FFB0R,FFB0R,FFB0R,FFB0R,FFB0R,FFB0R
        DW FFC0R,FFC1R,FFC2R,FFC3R,FFC4R,FFC5R,FFC6R,FFC7R
        DW FFC8R,NR,   NR,   NR,   NR,   NR,   NR,   NR
;        DW NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR,NR
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
        DW FF68W,FF69W,FF6AW,FF6BW,FF68W,FF69W,FF6AW,FF6BW
        DW FF68W,FF69W,FF6AW,FF6BW,FF68W,FF69W,FF6AW,FF6BW
        DW FF68W,FF69W,FF6AW,FF6BW,FF68W,FF69W,FF6AW,FF6BW
        DW FF68W,FF69W,FF6AW,FF6BW,FF68W,FF69W,FF6AW,FF6BW
        DW FF80W,FF81W,FF82W,FF83W,FF84W,FF85W,FF86W,FF87W
        DW FF88W,NW,   NW,   NW,   NW,   NW,   NW,   NW
        DW FF90W,FF91W,FF92W,FF93W,FF94W,FF95W,NW,   NW
        DW FF98W,FF99W,FF9AW,FF9BW,FF9CW,FF9DW,FF9EW,FF9FW
        DW FFA0W,FFA0W,FFA0W,FFA0W,FFA0W,FFA0W,FFA0W,FFA0W
        DW FFA0W,FFA0W,FFA0W,FFA0W,FFA0W,FFA0W,FFA0W,FFA0W
        DW FFB0W,FFB0W,FFB0W,FFB0W,FFB0W,FFB0W,FFB0W,FFB0W
        DW FFB0W,FFB0W,FFB0W,FFB0W,FFB0W,FFB0W,FFB0W,FFB0W
        DW FFC0W,FFC1W,FFC2W,FFC3W,FFC4W,FFC5W,FFC6W,FFC7W
        DW FFC8W,FFC9W,FFCAW,FFCBW,FFCCW,FFCDW,FFCEW,FFCFW
        DW FFD0W,FFD1W,FFD2W,FFD3W,NW,   NW,   NW,   NW
        DW FFD8W,FFD9W,NW,   NW,   NW,   NW,   FFDEW,FFDFW
        DW NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW
        DW NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW,NW
        DW NW

RAMHERE EQU $

PROG    ENDS
        END
