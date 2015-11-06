;
; ********************************************
; * [Add Project title here]                 *
; * [Add more info on software version here] *
; * (C)2010 by [Matthew Potter]              *
; ********************************************
;
; Included header file for target AVR type
.NOLIST
.INCLUDE "tn2313def.inc" ; Header for ATTINY2313
.LIST
;
;
; ================================================================================================
;   R E G I S T E R   D E F I N I T I O N S
; ================================================================================================
.DEF	rmp				= R16

.DEF	rKeyboardData	= R18					; data from the keyboard
.DEF	rKbdStatus		= R19					; keyboard status values (tracks state changes, like key up)
.DEF	rScanCode		= R20					; scan code
.DEF	rCodeStatus		= R21					; scan code status
.DEF	rSendData		= R23					; data to send to keyboard
.DEF	rParity			= R11					; parity tracking

; coco3 register definitions
.DEF	rIndex			= R15					; used to track the index into the scan code table
.DEF	rTValue			= R14					; used to capture the current table value for comparisons
.DEF	rMtxTimeout		= R13					; timeout decay value
.DEF	rTabOffset		= R22					; used to reference into address table
.DEF	rMTXH			= R25					; matrix lookup value, high order byte
.DEF	rMTXL			= R24					; matrix lookup value, low order byte

; ps/2 register definitions
.DEF	rBreakCount		= R8
.DEF	rBitCount		= R17
.DEF	rPs2Timeout		= R12
.DEF	rStarted		= R10


; ================================================================================================
;	C O N S T A N T S
; ================================================================================================

; scan code status values
.EQU	STATUS_SHFT		= 0						; bit 0 = shift is down
.EQU	STATUS_ALT		= 1						; bit 1 = alt key is down
.EQU	STATUS_CTRL		= 2						; bit 2 = ctrl key is down
.EQU	STATUS_GRP2		= 3						; group 2 scan code requested
.EQU	STATUS_GRP3		= 4						; group 3 scan code requested
.EQU	STATUS_CAPS		= 5						; caps lock
.EQU	STATUS_NUM		= 6						; num lock

; keyboard status values
.EQU	KBD_DATA_READY	= 0						; keyboard data is ready
.EQU	KBD_KEY_UP		= 1						; set by a key up (0xF0) message
.EQU	KBD_TIMEOUT		= 3						; set when kbd timeout is reached
.EQU	KBD_PARITY		= 4						; parity bit for kbd transactions
.EQU	KBD_DATA_DIR	= 5						; 0 = receive, 1 = send
.EQU	KBD_ACK_RCVD	= 6						; set when an ack byte is received
.EQU	KBD_BAT_OK		= 7						; as yet undefined status value


;
; ================================================================================================
;   R E S E T   A N D   I N T   V E C T O R S
; ================================================================================================
;
.CSEG
.ORG $0000
	rjmp Main ; Int vector 1 - Reset vector
	rjmp Int0Handler ; Int vector 2
	reti ; Int vector 3
	reti ; Int vector 4
	reti ; Int vector 5
	reti ; Int vector 6
	reti ; Int vector 7
	reti ; Int vector 8
	reti ; Int vector 9
	reti ; Int vector 10
	reti ; Int vector 11
	reti ; Int vector 12
	reti ; Int vector 13
	rjmp TimerCompare0A ; Int vector 14 - Timer compare 0A
	reti ; Int vector 15
	reti ; Int vector 16
	reti ; Int vector 17
	reti ; Int vector 18

;
; ================================================================================================
;     I N T E R R U P T   S E R V I C E S
; ================================================================================================
Int0Handler:
	PUSH	rmp
	IN		rmp, SREG
	PUSH	rmp

	SBRC	rKbdStatus, KBD_DATA_DIR			; bounce to the send portion if the send flag is set
	RJMP	int0_tx
int0_rx:
	RCALL 	PS2_Receive_Handler
	RJMP	int0_ex
int0_tx:
	RCALL	PS2_Transmit_Handler
int0_ex:
	POP		rmp
	OUT		SREG, rmp
	POP		rmp
	RETI

TimerCompare0A:
	PUSH	rmp
	IN		rmp, SREG
	PUSH	rmp
	RCALL	CC3_MatrixTimeout_Handler			; call the matrix timeout handler
	POP		rmp
	OUT		SREG, rmp
	POP		rmp
	RETI


;
; ================================================================================================
;     M A I N    P R O G R A M    I N I T
; ================================================================================================
;
; Include Coco3 keymap
.INCLUDE "cc3matrix.asm"
.INCLUDE "ps2-input.asm"

Main:
	LDI		rmp, LOW(RAMEND)					; Init LSB stack
	OUT		SPL,rmp

	RCALL	CC3_Init
	RCALL	PS2_Init

	LDI 	rmp, (1<<WGM01)						; CTC mode
	OUT 	TCCR0A, rmp
	LDI 	rmp, (1<<CS02) | (1<<CS00)			; CLK/8 (@8mHz, timer increments every 8us, or 7812.5Hz
	OUT 	TCCR0B, rmp
	LDI 	rmp, 0x3F							; compare at 64 ticks (.016384s), or 122.07Hz
	OUT 	OCR0A, rmp

	IN		rmp, TIMSK							; enable the timer
	ORI		rmp, (1<<OCIE0A)
	OUT		TIMSK, rmp

	SEI

	SBI		DDRA, PORTA0
	CBI		PORTA, PORTA0

Bat_Wait:
	SBRS	rKbdStatus, KBD_DATA_READY
	RJMP	Bat_Wait
	ANDI	rKbdStatus, ~(1<<KBD_DATA_READY)
	CPI		rKeyboardData, 0xAA
	BRNE	Loop
	ORI		rKbdStatus, (1<<KBD_BAT_OK)
	SBI		PORTA, PORTA0

	ORI		rCodeStatus, (1<<STATUS_CAPS)
	RCALL	PS2_UpdateStatusLeds


;
; ================================================================================================
;         P R O G R A M    L O O P
; ================================================================================================
;

Loop:
; wait for data
	SBRS	rKbdStatus, KBD_DATA_READY
	RJMP	Loop								; loop again

; when data is ready, copy it to the scan code register and clear the data ready flag
	ANDI	rKbdStatus, ~(1<<KBD_DATA_READY)
	MOV		rScanCode, rKeyboardData			; copy the scan code!
	CLR		rKeyboardData

; we have a scan code - lets decode it!  :)
	TST		rScanCode
	BREQ	Loop
	CPI		rScanCode, 0xFF
	BREQ	Loop

; decode the scan code!
	RCALL	PS2_DecodeScanCode
	TST		rScanCode
	BREQ	Loop
	CPI		rScanCode, 0xFF
	BREQ	Loop

; send the scan code to the coco hardware	
	RCALL	CC3_SendKeystroke
	CLR		rScanCode

	RJMP	Loop ; go back to loop


; ================================================================================================
; Delays for 1 us.  Does not include call and return times!  Useful for delays > 50us.
; This function depends on the CPU clock being set at 8Mhz
;	@ 8Mhz, each instruction cycle takes .125us.  So we need 8 instructions to delay for 1us.
; ================================================================================================
Delay_One_us:
	NOP											; 1
	NOP											; 1
	NOP											; 1
	NOP											; 1
	TST		rmp									; 1
	BREQ	Delay_1_Done						; 1 for false, 2 for true
	DEC		rmp									; 1
	RJMP	Delay_One_us						; 2
Delay_1_Done:
	RET											; 4

Delay_65_us:
	LDI		rmp, 0x40
	RCALL	Delay_One_us
	RET


.INCLUDE "data-tables.asm"
