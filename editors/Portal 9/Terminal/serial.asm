* Communicates with the serial port on the expansion board.
* See the 6551 documentation for information on the UART.
* 
* Currently, the UART answers on the following ports:
* I/O Register:		FF6C
* Status		FF6D
* Command		FF6E
* Control		FF6F

SERIAL namespace

SER_IO		equ		$FF6C
SER_STA		equ		$FF6D
SER_CMD		equ		$FF6E
SER_CTRL	equ		$FF6F


*--------------------------------------------------------------------------------
* Initalizes UART in standard communication mode.
* Default init is for 1200-N-8  (0001 1000), no interrupts, tx/rx enabled and
* DTR* ready. (0000 1011)
*--------------------------------------------------------------------------------
Initialize		proc	baud:word
	begin Initialize
				lda		#%00001011
				sta		SER_CMD
				
				call	ConvertToBaud	baud
				ora		#%00010000
				sta		SER_CTRL
				rts
	endproc


*--------------------------------------------------------------------------------
* Writes a character to the serial port.  Waits for rx ready and DTR* from client.
* A register contains the byte to be written to the serial port.
*--------------------------------------------------------------------------------
CharOut			proc	value:byte
	begin CharOut
				lda		value,u
				ldb		SER_CMD
				orb		#9		(set tx and DTR ready)
				stb		SER_CMD
!				ldb		SER_STA
				andb	#48		(see if tx register empty and carrier detected)
				bne		<
				sta		SER_IO	(send data to serial port)
				rts
	endproc

*--------------------------------------------------------------------------------
* Receives a character from the serial port.  Waits for the data if it's not
* received yet.  A contains character received.
*--------------------------------------------------------------------------------
ser_chr_in		ldb		SER_CMD
				orb		#9		(set tx and DTR ready)
				stb		SER_CMD
_in_wait		ldb		SER_STA
				andb	#8		(see if receiver ready)
				beq		_in_wait
				lda		SER_IO
				rts


*--------------------------------------------------------------------------------
* Converts the specified baud rate into it's bit field counterpart for the 6551.
* Value is returned in the A register.
*--------------------------------------------------------------------------------
ConvertToBaud	proc	baud:word
	begin ConvertToBaud
				ldd		baud,u
				cmpd	#300
				beq		@3
				cmpd	#1200
				beq		@4
				cmpd	#2400
				beq		@5
				cmpd	#4800
				beq		@6
				cmpd	#9600
				beq		@7
				cmpd	#19200
				beq		@8
				bra		@4			no matches found, so return default of 1200 baud

@3				lda		#%00000110	300
				rts

@4				lda		#%00001000	1200
				rts

@5				lda		#%00001010	2400
				rts

@6				lda		#%00001100	4800
				rts

@7				lda		#%00001110	9600
				rts

@8				lda		#%00001111	19200
				rts
	endproc

 endname

*--------------------------------------------------------------------------------
* Register Documentation for 6551
*
* - - - - - - - - - - - - - - - - - - - - -
*  Status Register Bits
*	7 - Interupt flag (0 = no interupt)
*	6 - DSR (0 = ready)
*	5 - DCD (0 = detected)
*	4 - Tx reg empty (0 = not empty)
*	3 - Rx reg full (0 = not full)
*	2 - Overrun (0 = none)
*	1 - Framing err (0 = no error)
*	0 - Parity err (0 = no error)
*
* - - - - - - - - - - - - - - - - - - - - -
*  Command Register
*	Bits 7-6	Parity Mode Control
*	 7	6		Parity
*	 0	0		Odd parity tx/rx
*	 0	1		Even parity tx/rx
*	 1	0		Mark parity tx, check disabled
*	 1	1		Space parity bit tx, check disabled
*	
*	Bit 5		Parit Mode Enable
*	  0			Disabled, no parity bit generated, check disabled
*	  1			Parity enabled
*
*	Bit 4		Reciever Echo Mode
*	  0			Normal
*	  1			Echo
*
*	Bits 3-2	Transmitter Interrupt Control
*	 3	2		Mode
*	 0	0		RTS* = high, tx disabled
*	 0	1		RTS* = low, tx interrupt enabled
*	 1	0		RTS* = low, tx interrupt disabled
*	 1	1		RTS* = low, tx interrupt disabled, tx break on TxD
*
*	Bit 1		Receiver Interup Request
*	  0			IRQ* enabled (rx)
*	  1			IRQ* disabled (rx)
*
*	Bit 0		Data Terminal Ready
*	  0			DTR* high (not ready)
*	  1			DTR* low (ready)
*
* - - - - - - - - - - - - - - - - - - - - -
*  Control Register Bits
*	Bit 7		Stop Bit Number
*	  0			1 stop bit
*	  1			2 stop bits
*	  1			1.5 stop bits (for WL = 5 and no parity)
*	  1			1 stop bit (for WL = 8 and parity)
*
*	Bits 6-5	Word Length
*	 6	5		# of bits
*	 0	0		8
*	 0	1		7
*	 1	0		6
*	 1	1		5
*
*	Bit 4		Receiver Clock Source
*	  0			External Clock
*	  1			Programmed baud rate
*
*	Bits 3-0	Baud Rate Select
*	 3210		Baud
*	 0000		16x external clock
*	 0001		50
*	 0010		75
*	 0011		109.92
*	 0100		134.58
*	 0101		150
*	 0110		300
*	 0111		600
*	 1000		1200
*	 1001		1800
*	 1010		2400
*	 1011		3600
*	 1100		4800
*	 1101		7200
*	 1110		9600
*	 1111		19200
*
*--------------------------------------------------------------------------------
