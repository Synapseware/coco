; ================================================================================================
; The lookup function searches the scan code tables and records the position of a match.
; Once a match is found, it's index is used to index into the matrix table to return
; the correct matrix for the matched scan code.  Unmatched scan codes are returned as 0x00
;
; The matrxi hardware is comprised of two 74574 latches.  Each latch is used to represent
; 8 bits of keyboard data from the old coco3 keyboard.  The latches drive their outputs low to
; simulate a keystroke.
; The latches get their data from the MCU port B (0-7).  The matrix output procedure is:
;	1 - Disable the latch outputs by bringing MTX_ENABLE high (PORTD6)
;	2 - Writing the first byte of keyboard data to the MTX_PORT (PORTB)
;	3 - Bringing MTX_SEL0 low, which causes one of the 74574 latches to grab the data
;	4 - Bringing MTX_SEL0 high to disable the latch
;	5 - Writing the next byte of keyboard data to MTX_PORT
;	6 - Bringing MTX_SEL1 low, which causes the other 74575 to latch the data
;	7 - Bringing MTX_SEL1 high
;	8 - Bringing MTX_ENABLE low and starting the timeout timer, which causes the latches to
;		make their data available on their output buffers
;	9 - Once the timeout timer elapses, it brings MTX_ENABLE high to disable the keyboard output,
;		then it disables the timeout timer.
; ================================================================================================

; MATRIX data and control port
.EQU	MTX_PORT		= PORTB				; latch data port
.EQU	MTX_DDR			= DDRB				; latch data direction control port
.EQU	MTX_CTRL_PORT	= PORTD				; latch control port
.EQU	MTX_CTRL_DDR	= DDRD				; latch control data direction port
.EQU	MTX_ENABLE		= PORTD6			; bring this low to enable the matrix
.EQU	MTX_SEL0		= PORTD4			; bring this low to latch byte 0 of the matrix
.EQU	MTX_SEL1		= PORTD5			; bring this low to latch byte 1 of the matrix
.EQU	MTX_TIMEOUT		= 0x19				; it'll take N ticks of the timer to timeout the matrix
											; each tick is 100us, so at 250 ticks, we'll reach 25ms


; scan code group definitions (and offsets)
.EQU	Group3Table		= 0x00				; group 3 scan code table offset (extended)
.EQU	Group2Table		= 0x02				; group 2 scan code table offset (special shift)
.EQU	Group1Table		= 0x04				; group 1 scan code table offset (normal keys)


; ================================================================================================
; Initializes the CoCo3 matrix hardware and sets up the timer0 options
;	modifies:
;		rmp
; ================================================================================================
CC3_Init:
	IN		rmp, MTX_CTRL_DDR				; load the matrix control DDR
	ORI		rmp, (1<<MTX_ENABLE)|(1<<MTX_SEL0)|(1<<MTX_SEL1)
	OUT		MTX_CTRL_DDR, rmp				; mark the control pins as output

	IN		rmp, MTX_CTRL_PORT				; load the current port values
	ORI		rmp, (1<<MTX_ENABLE)|(1<<MTX_SEL0)|(1<<MTX_SEL1)
	OUT		MTX_CTRL_PORT, rmp

	CLR		rmp								; set all bits low
	OUT		MTX_PORT, rmp					; set all values to 0
	SER		rmp								; set all pins as output
	OUT		MTX_DDR, rmp					; set the data direction

	RCALL	CC3_Matrix_KeysUp

	CLR		rIndex
	CLR		rTValue
	CLR		rMtxTimeout
	CLR		rTabOffset
	CLR		rMTXH
	CLR		rMTXL

	RET


; ================================================================================================
; Called when the timer expires and is used to turn off the matrix
;	modifies:
;		none
; ================================================================================================
CC3_MatrixTimeout_Handler:
	TST		rMtxTimeout						; compare to 0
	BREQ	CC3_Matrix_KeysUp				; branch to disable matrix
	DEC		rMtxTimeout						; subtract 1 from the timer register
	RJMP	cc3_mt_done
CC3_Matrix_KeysUp:
	CLR		rmp
	OUT		MTX_PORT, rmp					; copy the high matrix value to the matrix data port
	CBI		MTX_CTRL_PORT, MTX_SEL0			; enable matrix latch 0
	NOP
	SBI		MTX_CTRL_PORT, MTX_SEL0			; disable matrix latch 0
	NOP
	OUT		MTX_PORT, rmp					; copy the low matrix value to the matrix data port
	CBI		MTX_CTRL_PORT, MTX_SEL1			; enable matrix latch 1
	NOP
	SBI		MTX_CTRL_PORT, MTX_SEL1			; disable matrix latch 1
cc3_mt_done:
	RET


; ================================================================================================
; Looks up the scan code based on the rScanCode and rStatus register.  If no match is found, then
; nothing is written to the hardware matrix.
;	rScanCode should have the value of the scan code we are interested in sending to the coco
;	rStatus should have any status flags set.
; ================================================================================================
CC3_SendKeystroke:
	TST		rScanCode
	BREQ	cc3_sk_done
	CPI		rScanCode, 0xE1					; check for break key
	BRNE	cc3_sk_caps
	LDI		rMTXH, 0xDF						; load break key matrix
	LDI		rMTXL, 0x7F
	RJMP	cc3_sk_nxt3
cc3_sk_caps:
	CPI		rScanCode, 0x58					; check for caps lock
	BRNE	cc3_sk_grp3
	LDI		rMTXH, 0x7E						; load caps lock key matrix
	LDI		rMTXL, 0x7E
	RJMP	cc3_sk_nxt3
cc3_sk_grp3:
	CLR		rMTXH
	CLR		rMTXL
	SBRS	rCodeStatus, STATUS_GRP3
	RJMP	cc3_sk_grp2
	RCALL	CC3_FindGrp3ScanCode			; find the extended scan code
	RJMP	cc3_sk_gp1
cc3_sk_grp2:
	SBRS	rCodeStatus, STATUS_GRP2
	RJMP	cc3_sk_gp1
	RCALL	CC3_FindGrp2ScanCode			; find the group2 scan code
cc3_sk_gp1:
	TST		rMTXH							; if this isn't 0, then either GP3 or GP2 found something
	BRNE	cc3_sk_nxt
	RCALL	CC3_FindGrp1ScanCode			; find the group1 scan code because neither GP3 nor GP2 found anything
	TST		rMTXH							; if the lookup doesn't find anything, then rMTXH will be 0
	BREQ	cc3_sk_done
cc3_sk_nxt:
	SBRS	rCodeStatus, STATUS_SHFT
	BRNE	cc3_sk_nxt1
	ANDI	rMTXH, 0xFE
	ANDI	rMTXL, 0xFE
cc3_sk_nxt1:
	SBRS	rCodeStatus, STATUS_ALT
	BRNE	cc3_sk_nxt2
	ANDI	rMTXH, 0xEF
	ANDI	rMTXL, 0xFE
cc3_sk_nxt2:
	SBRS	rCodeStatus, STATUS_CTRL
	BRNE	cc3_sk_nxt3
	ANDI	rMTXH, 0xF7
	ANDI	rMTXL, 0xFE
cc3_sk_nxt3:
	RCALL	CC3_OutputToMatrix
cc3_sk_done:
	RET


; ================================================================================================
; Writes a scan code value to the matrix and starts the timeout timer
; ================================================================================================
CC3_OutputToMatrix:
	PUSH	rmp
	SER		rmp
	EOR		rMTXH, rmp
	EOR		rMTXL, rmp
;	SBI		MTX_CTRL_PORT, MTX_ENABLE		; disable matrix
	NOP
	OUT		MTX_PORT, rMTXH					; copy the high matrix value to the matrix data port
	CBI		MTX_CTRL_PORT, MTX_SEL0			; enable matrix latch 0
	NOP
	SBI		MTX_CTRL_PORT, MTX_SEL0			; disable matrix latch 0
	NOP
	OUT		MTX_PORT, rMTXL					; copy the low matrix value to the matrix data port
	CBI		MTX_CTRL_PORT, MTX_SEL1			; enable matrix latch 1
	NOP
	SBI		MTX_CTRL_PORT, MTX_SEL1			; disable matrix latch 1
	NOP
	CBI		MTX_CTRL_PORT, MTX_ENABLE		; enable matrix
	LDI		rmp, MTX_TIMEOUT				; start the timer
	MOV		rMtxTimeout, rmp
	POP		rmp
	RET


; ================================================================================================
; Takes the value in register R20 as the scan code to match.  Returned matches are in
; registers R20:R21.  If R20 is zero, then no match was found
; ================================================================================================
; Finds extended scan codes
CC3_FindGrp3ScanCode:
	PUSH	rTabOffset
	LDI		rTabOffset, Group3Table			; load the table offset
	RJMP	CC3_FindScanCode
; Finds shifted scan codes
CC3_FindGrp2ScanCode:
	PUSH	rTabOffset
	LDI		rTabOffset, Group2Table			; load the table offset
	RJMP	CC3_FindScanCode
; Finds normal scan codes
CC3_FindGrp1ScanCode:
	PUSH	rTabOffset
	LDI		rTabOffset, Group1Table			; load the table offset
	RJMP	CC3_FindScanCode
; Main find function
CC3_FindScanCode:
	PUSH	rIndex
	PUSH	ZH								; save registers
	PUSH	ZL
	PUSH	XH
	PUSH	XL
	LDI		ZH, HIGH(SCAN_CODE_TABLES<<1)	; load the table value
	LDI		ZL, LOW(SCAN_CODE_TABLES<<1)
	ADD		ZL, rTabOffset					; add the offset to the table address
	LPM		XL, Z+							; load the X register with the address from the Z register
	LPM		XH, Z
	BCLR	SREG_C							; clear the C bit in the status register
	ROL		XL
	ROL		XH
	MOV		ZL, XL							; copy the X register to the Z register
	MOV		ZH, XH
	CLR		rIndex							; rIndex tracks the index
CC3_FindLoop:
	LPM		rTValue, Z+						; load the first table address
	TST		rTValue							; check to see if register is 0 (at the end of the table)
	BREQ	CC3_NoMatixMatch
	INC		rIndex							; increment position counter
	CP		rScanCode, rTValue				; compare the scan code to the register
	BRNE	CC3_FindLoop
; match found. take index and add it to matrix table to get code
	DEC		rIndex							; take one off the position to get the correct index
	LSL		rIndex							; multiply R24 by 2
	LDI		ZH, HIGH(MATRIX_TABLES<<1)		; load the table value
	LDI		ZL, LOW(MATRIX_TABLES<<1)
	ADD		ZL, rTabOffset					; add the offset to the table address
	LPM		XL, Z+							; load the X register with the address from the Z register
	LPM		XH, Z
	BCLR	SREG_C							; clear the C bit in the status register
	ROL		XL
	ROL		XH
	MOV		ZL, XL							; copy the X register to the Z register
	MOV		ZH, XH
	RJMP	CC3_LoadMatrixValue
; no match was found - clear the matrix registers and return
CC3_NoMatixMatch:
	CLR		rMTXH
	CLR		rMTXL
	RJMP	CC3_FindDone
; a match was found - load it
CC3_LoadMatrixValue:
	ADD		ZL, rIndex						; add the index to the Z register
	CLR		rIndex
	ADC		ZH, rIndex						; add any carry values (in-case larger than 255)
	LPM		rMTXL, Z+						; load matrix byte
	LPM		rMTXH, Z						; load matrix byte
; all done - pop registers off stack and return
CC3_FindDone:
	POP		XL
	POP		XH
	POP		ZL
	POP		ZH
	POP		rIndex
	POP		rTabOffset
	RET										; all done
