*
* DDS MICRO-C 6809 Serial I/O routines
* These routines are set up to talk to a 6551 UART device.
*
?uart	EQU	$0000		Console uart address
* Write a string to the console: putstr(char *string)
putstr	LDX	2,S		Get string address
?putstr	LDB	,X+		Get character
	BEQ	?1		End, exit
	BSR	?putch		Write the character
	BRA	?putstr		And proceed
* Write character to console - Translate newlines: putch(char c)
putch	LDD	2,S		Get char to write
?putch	CMPB	#$0A		Newline?
	BNE	?putchr		No, write it
	BSR	?putchr		Write it
	LDB	#$0D		Get return
	BRA	?putchr		Write & exit
* Write character to console - Raw format
putchr	LDD	2,S		Get char to write
?putchr	LDA	?uart+1		Get status
	BITA	#%00010000	TX ready?
	BEQ	?putchr		No, wait for it
	STB	?uart		Write character
?1	RTS
* Check for character - Raw format
chkchr	LDA	?uart+1		Get status
	BITA	#%00001000	RX ready?
	BNE	getchr		Yes, get it
	LDD	#-1		Return -1
	RTS
* Check for character
chkch	LDA	?uart+1		Get status
	CLRB			Zero high
	ANDA	#%00001000	RX ready?
	BEQ	?1		No, return with zero
* Read character from console - Translate Returns
getch	BSR	getchr		Get character
	CMPB	#$0D		Return?
	BNE	?1		Its OK
	LDB	#$0A		Convert to newline
	RTS
* Read character from console - Raw format
getchr	LDA	?uart+1		Get status
	BITA	#%00001000	RX ready?
	BEQ	getchr		No, wait for it
	LDB	?uart		Read the character
	CLRA			Zero high
	RTS
* Read a string (with editing) from the console: getstr(buffer, length)
getstr	LDU	4,S		Get buffer
	LDX	#0		Starting length is zero
?2	BSR	getch		Get a character
	CMPB	#$7F		Delete?
	BEQ	?3		Yes, handle it
	CMPB	#$08		Backspace?
	BEQ	?3		Yes, handle it
	CMPB	#$0A		Enter?
	BEQ	?4		Yes, handle it
	CMPX	2,S		Are we within length?
	BHS	?2		No, ignore
	STB	,U+		Write to buffer
	LEAX	1,X		Advance length
	BSR	?putchr		Echo character to console
	BRA	?2		And proceed
?3	CMPX	#0		Any data in buffer?
	BEQ	?2		No, ignore
	LDB	#$08		Backspace
	BSR	?putchr		Echo
	LDB	#' '		Overwrite with space
	BSR	?putchr		Echo
	LDB	#$08		Backspace
	BSR	?putchr		Echo
	LEAX	-1,X		Backup count
	LEAU	-1,U		Backup in buffer
	BRA	?2		And proceed
?4	CLR	,U		Zero end of buffer
	BSR	?putch		New line on console
	TFR	X,D		Report # chars received
	RTS
*00000
