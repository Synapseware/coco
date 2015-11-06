; ================================================================================================
; PS/2 Input Support
; ps/2 clock is on PD2, (pin 6) which is INT0
; ps/2 data is on PD1, (pin 3)
; ================================================================================================

.EQU	KBD_PORT		= PORTD
.EQU	KBD_PIN			= PIND
.EQU	KBD_DDR			= DDRD
.EQU	KBD_DBG_LED		= PD3
.EQU	KBD_CLOCK_PIN	= PD2
.EQU	KBD_DATA_PIN	= PD1

; ================================================================================================
; Initializes the PS/2 module and enables int0 so we can capture the clock signal
; ================================================================================================
PS2_Init:
	SBI		KBD_PORT, KBD_DBG_LED				; enable pull up resistor
	SBI		KBD_DDR, KBD_DBG_LED				; set debug pin as output

	SBI		KBD_PORT, KBD_CLOCK_PIN				; enable pull up resistor
	CBI		KBD_DDR, KBD_CLOCK_PIN				; set clock as input

	SBI		KBD_PORT, KBD_DATA_PIN				; enable pull up resistor
	CBI		KBD_DDR, KBD_DATA_PIN				; set data as input

	IN		rmp, PCMSK
	ORI		rmp, (1<<KBD_CLOCK_PIN)
	OUT		PCMSK, rmp

	IN		rmp, MCUCR							; setup int0 flags
	ORI		rmp, (1<<ISC01)						; set INT0 to trigger on falling edge
	ANDI	rmp, ~(1<<ISC00)			
	OUT		MCUCR, rmp

	IN		rmp, GIMSK							; enable int0
	ORI		rmp, (1<<INT0)
	OUT		GIMSK, rmp

	CLR		rKeyboardData
	CLR		rKbdStatus
	CLR		rScanCode
	CLR		rCodeStatus
	CLR		rSendData
	CLR		rBreakCount
	CLR		rBitCount
	CLR		rStarted
	CLR		rPs2Timeout
	RET


; ================================================================================================
; Decodes a scan code and sets flags
; ================================================================================================
PS2_DecodeScanCode:
	PUSH	rmp
	MOV		rmp, rBreakCount
	TST		rmp
	BREQ	decode_continue
	CPI		rmp, 0x08
	BRSH	decode_continue
	LDI		ZH, HIGH(BREAK_SEQUENCE<<1)			; load the break sequence table
	LDI		ZL, LOW(BREAK_SEQUENCE<<1)
	ADD		ZL, rBreakCount						; add the break count as an offset to the register
	CLR		rmp
	ADC		ZH, rmp								; add any carry value
	LPM		rmp, z								; load the indexed sequence character
	CP		rmp, rScanCode						; compare the scan code with the table character
	BREQ	decode_is_break
	CLR		rBreakCount							; clear the break count (mismatch found)
	RJMP	decode_done_ret						; jump out
decode_is_break:
	CLR		rScanCode
	INC		rBreakCount
	LDI		rmp, 0x08
	CPSE	rmp, rBreakCount					; check for last char (skip next if not last char)
	RJMP	decode_done_ret
	CLR		rBreakCount							; this is the end of the break sequence
	LDI		rScanCode, 0xE1						; load the break code
	RJMP	decode_done_ret
decode_continue:
	CPI		rScanCode, 0xAA						; set BAT code
	BRNE	decode_up
	CLR		rScanCode
	ORI		rKbdStatus, (1<<KBD_BAT_OK)
	RJMP	decode_done_ret
decode_up:
	CPI		rScanCode, 0xF0						; check for key-up.  if so, then set key-up flag and stop processing
	BRNE	decode_ack
	CLR		rScanCode
	ORI		rKbdStatus, (1<<KBD_KEY_UP)
	RJMP	decode_done_ret
decode_ack:
	CPI		rScanCode, 0xFA						; set the ACK flag
	BRNE	decode_break
	CLR		rScanCode
	ORI		rKbdStatus, (1<<KBD_ACK_RCVD)
	RJMP	decode_done_ret
decode_break:
	CPI		rScanCode, 0xE1						; start the break sequence detection
	BRNE	decode_ext
	CLR		rScanCode
	CLR		rBreakCount
	INC		rBreakCount
	RJMP	decode_done_ret
decode_ext:
	CPI		rScanCode, 0xE0						; set the EXT/Group3 flag
	BRNE	decode_shift_keys
	CLR		rScanCode
	SBRC	rCodeStatus, STATUS_GRP3			; skip next if key up flag is set
	RJMP	decode_ext_clear
	ORI		rCodeStatus, (1<<STATUS_GRP3)
	RJMP	decode_done_ret
decode_ext_clear:
	ANDI	rCodeStatus, ~(1<<STATUS_GRP3)
	RJMP	decode_done_ret
decode_shift_keys:
	CPI		rScanCode, 0x12						; detect shift keys
	BREQ	decode_shift_state
	CPI		rScanCode, 0x59
	BREQ	decode_shift_state
	RJMP	decode_alt
decode_shift_state:
	SBRC	rKbdStatus, KBD_KEY_UP				; detect shift key state
	RJMP	decode_shift_clear					; 	if the key-up flag is set, then clear the shift flag, otherwise, set it
	ORI		rCodeStatus, (1<<STATUS_SHFT)		; 	shift keys should not persist
	RJMP	decode_done_ret
decode_shift_clear:
	ANDI	rCodeStatus, ~(1<<STATUS_SHFT)
	ANDI	rKbdStatus, ~(1<<KBD_KEY_UP)
	RJMP	decode_done_ret
decode_alt:
	CPI		rScanCode, 0x11						; detect alt key state
	BRNE	decode_ctrl
	SBRC	rKbdStatus, KBD_KEY_UP
	RJMP	decode_alt_clear
	ORI		rCodeStatus, (1<<STATUS_ALT)
	RJMP	decode_done_ret
decode_alt_clear:
	ANDI	rCodeStatus, ~(1<<STATUS_ALT)
	ANDI	rKbdStatus, ~(1<<KBD_KEY_UP)
	RJMP	decode_done_ret
decode_ctrl:
	CPI		rScanCode, 0x14						; set the CTRL flag
	BRNE	decode_state_keys
	SBRC	rKbdStatus, KBD_KEY_UP
	RJMP	decode_ctrl_clr
	ORI		rCodeStatus, (1<<STATUS_CTRL)
	RJMP	decode_done_ret
decode_ctrl_clr:
	ANDI	rCodeStatus, ~(1<<STATUS_CTRL)
	ANDI	rKbdStatus, ~(1<<KBD_KEY_UP)
	RJMP	decode_done_ret

; all key checks after this point have toggle behavior and skip the key make/break syntax
decode_state_keys:
	SBRS	rKbdStatus, KBD_KEY_UP				; if the key-up flag is set, clear it and return
	RJMP	decode_caps
	CLR		rScanCode
	ANDI	rKbdStatus, ~(1<<KBD_KEY_UP)
	RJMP	decode_done_ret
decode_caps:
	CPI		rScanCode, 0x58						; detect the caps lock state
	BRNE	decode_num
	SBRC	rCodeStatus, STATUS_CAPS
	RJMP	decode_caps_clr
	ORI		rCodeStatus, (1<<STATUS_CAPS)
	RJMP	decode_caps_done
decode_caps_clr:
	ANDI	rCodeStatus, ~(1<<STATUS_CAPS)
decode_caps_done:
	RCALL	PS2_UpdateStatusLeds
	RJMP	decode_done_ret
decode_num:
	CPI		rScanCode, 0x77						; detect the num lock state
	BRNE	decode_done_ret
	CLR		rScanCode
	SBRC	rCodeStatus, STATUS_NUM
	RJMP	decode_num_clr
	ORI		rCodeStatus, (1<<STATUS_NUM)
	RJMP	decode_num_done
decode_num_clr:
	ANDI	rCodeStatus, ~(1<<STATUS_NUM)
decode_num_done:
	RCALL	PS2_UpdateStatusLeds
decode_done_ret:
	POP		rmp
	RET


; ================================================================================================
; Sets the status LEDs on the keyboard
; ================================================================================================
PS2_UpdateStatusLeds:
	ANDI	rKbdStatus, ~(1<<KBD_DATA_READY)

	LDI		rSendData, 0xED						; send update LED cmd
	RCALL	PS2_SendByte

ps2_usl_wait1:
	SBRS	rKbdStatus, KBD_DATA_READY			; wait for AK
	RJMP	ps2_usl_wait1
	ANDI	rKbdStatus, ~(1<<KBD_DATA_READY)

	CLR		rSendData
	SBRC	rCodeStatus, STATUS_CAPS			; set caps bit
	ORI		rSendData, (1<<2)
	SBRC	rCodeStatus, STATUS_NUM				; set numlck bit
	ORI		rSendData, (1<<1)
	RCALL	PS2_SendByte						; send LED on values

ps2_usl_wait2:
	SBRS	rKbdStatus, KBD_DATA_READY			; wait for AK
	RJMP	ps2_usl_wait2
	ANDI	rKbdStatus, ~(1<<KBD_DATA_READY)

	RET


; ================================================================================================
; Starts a send cycle
;	The byte in rSendData will be sent to the keyboard
; ================================================================================================
PS2_SendByte:
	CLI											; setup
	ORI		rKbdStatus, (1<<KBD_DATA_DIR)		; signal send mode

	CBI		KBD_PORT, KBD_CLOCK_PIN				; 1 - bring clock low for at least 100us
	SBI		KBD_DDR, KBD_CLOCK_PIN
	RCALL	Delay_65_us

	SBI		KBD_DDR, KBD_DATA_PIN				; 2 - bring data low
	CBI		KBD_PORT, KBD_DATA_PIN

	CBI		KBD_DDR, KBD_CLOCK_PIN				; 3 - release clock
	SBI		KBD_PORT, KBD_CLOCK_PIN

	SEI											;4 - wait for device to start generating clock pulses

send_wait:
	SBRC	rKbdStatus, KBD_DATA_DIR			; - wait for tx to complete
	RJMP	send_wait

	RET


; ================================================================================================
; PS/2 Clock signal interrupt handler
; Reads a byte from the keyboard and stores it in register rMatch
; ================================================================================================
PS2_Receive_Handler:
	SBIC	KBD_PIN, KBD_CLOCK_PIN				; test the clock value to see if it's clear
	RJMP	ps2_int_done						; since the clock is a 1, bail out (just in case)
	TST		rStarted							; check the start value
	BRNE	ps2_int_started						; branch to the started block
	SBIC	KBD_PIN, KBD_DATA_PIN				; check for start bit on data line
	RJMP	ps2_int_done						; bail out if the start bit isn't set
	CBI		KBD_PORT, KBD_DBG_LED				; turn on debug led
	CLR		rStarted							; mark as started
	INC		rStarted
	CLR		rBitCount							; mark bit count as 0
	CLR		rKeyboardData						; mark scan code as 0
	RJMP	ps2_int_done						; we are done with start cycle
ps2_int_started:
	CPI		rBitCount, 0x08						; check if we should receive data bits
	BRLO	ps2_int_rcv_data_bits				; branch to data receive block
	BREQ	ps2_int_rcv_parity_bit				; branch to parity receive block
ps2_int_rcv_stop_bit:
	SBI		KBD_PORT, KBD_DBG_LED				; turn off debug led
	CLR		rStarted
	ORI		rKbdStatus, (1<<KBD_DATA_READY)
	RJMP	ps2_int_done
ps2_int_rcv_data_bits:
	SBIC	KBD_PIN, KBD_DATA_PIN				; skip the next instruction if the data line is clear
	ORI		rKeyboardData, 0x80					; set bit in position 7 (it'll get shifted right)
	LDI		rmp, 0x07
	CPSE	rBitCount, rmp
	LSR		rKeyboardData						; push the bits right 1 position
	INC		rBitCount							; increment the bit count
	RJMP	ps2_int_done
ps2_int_rcv_parity_bit:
	INC		rBitCount							; add 1 to the bit count
	RJMP	ps2_int_done

ps2_int_done:
	IN		rmp, EIFR							; clear the interrupt flag
	ORI		rmp, (1<<INTF0)
	OUT		EIFR, rmp
	RET


; ================================================================================================
; Transmits a byte of data to the keyboard
;	The setup for the transmit is already done when this is called
;	rSendData should have the byte to transmit
; ================================================================================================
PS2_Transmit_Handler:
	SBIC	KBD_PIN, KBD_CLOCK_PIN				; 4 - wait for device to bring clock low
	RJMP	ps2_tx_final

	TST		rStarted
	BREQ	ps2_tx_start
	CPI		rBitCount, 0x08
	BRLO	ps2_tx_bits
	BREQ	ps2_tx_parity
	RJMP	ps2_tx_stop

ps2_tx_start:
	CBI		PORTA, PORTA0
	SBI		KBD_DDR, KBD_DATA_PIN				; start bit is 0
	CLR		rStarted
	INC		rStarted
	CLR		rBitCount
	CLR		rParity

ps2_tx_bits:
	ROR		rSendData
	BRCS	ps2_tx_set
	SBI		KBD_DDR, KBD_DATA_PIN				; 5 - bit 0 is clear (set as output, low)
	RJMP	ps2_tx_done
ps2_tx_set:
	CBI		KBD_DDR, KBD_DATA_PIN				; 5 - bit 0 is set (set as input, high-z)
	INC		rParity
	RJMP	ps2_tx_done

ps2_tx_parity:
	SBRS	rParity, 0							; check bit 0 of parity
	RJMP	ps2_tx_parity_set
	SBI		KBD_DDR, KBD_DATA_PIN				; send a 0
	RJMP	ps2_tx_done
ps2_tx_parity_set:
	CBI		KBD_DDR, KBD_DATA_PIN				; send a 1
	RJMP	ps2_tx_done

ps2_tx_stop:
	CBI		KBD_DDR, KBD_DATA_PIN				; 9 - release data line
	SBI		KBD_PORT, KBD_DATA_PIN
ps2_tx_stop_data:
	SBIC	KBD_PIN, KBD_DATA_PIN				; 10 - wait for device to bring data low
	RJMP	ps2_tx_stop_data
ps2_tx_stop_clock:
	SBIC	KBD_PIN, KBD_CLOCK_PIN				; 11 - wait for device to bring clock low
	RJMP	ps2_tx_stop_clock
ps2_tx_stop3:
	SBIS	KBD_PIN, KBD_DATA_PIN
	RJMP	ps2_tx_stop3
ps2_tx_stop4:
	SBIS	KBD_PIN, KBD_CLOCK_PIN				; 12 - wait for data and clock to be released
	RJMP	ps2_tx_stop4
	SBI		PORTA, PORTA0
	CLR		rStarted
	ANDI	rKbdStatus, ~(1<<KBD_DATA_DIR)
	RJMP	ps2_tx_done

ps2_tx_done:
	INC		rBitCount
ps2_tx_final:
	IN		rmp, EIFR							; clear the interrupt flag
	ORI		rmp, (1<<INTF0)
	OUT		EIFR, rmp
	RET

