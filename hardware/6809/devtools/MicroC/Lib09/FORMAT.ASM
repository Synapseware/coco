*
* Shared format routine: _format_(char *output, int *arg_ptr)
*
_format_ LDX	2,S		X = pointer to arguments
	LDU	,--X		x = format string
	STX	2,S		Save for later
* Process next character from format string
?1	LDA	,U+		Get character from string
	CMPA	#'%'		Format specifier?
	BEQ	?2		Yes, handle it
* Non-format, copy to string
	LDX	4,S		Get output pointer
	STA	,X+		Write it
	STX	4,S		Resave it
	TSTA			End of string?
	BNE	?1		No, proceed
	RTS
* Test for '-' (Left justify)
?2	LDA	,U		Get next char
	LDB	#' '		Assume space
	CMPA	#'-'		Left justify?
	BNE	?3		No, its OK
	ORB	#%10000000	Set LJ flag
	LEAU	1,U		Skip '-'
	LDA	,U		Get next char
* Test for leading '0' (zero fill)
?3	CMPA	#'0'		Zero fill?
	BNE	?4		No, its OK
	ORB	#'0'		Convert to ZF
?4	STB	?temp		Save flags
	CLRB			Zero width
* Evaluate field width
?5	LDA	,U+		Get char
	SUBA	#'0'		Convert
	CMPA	#10		In range?
	BHS	?6		No, end
	PSHS	A		Save it
	LDA	#10		X10
	MUL			B=B*10
	ADDB	,S+		Add in digit
	BRA	?5		Proceed
* Interpret the format specified
?6	STB	?temp+1		Save width
	LDX	2,S		Get pointer to args
	LDD	,--X		Get value
	STX	2,S		Resave
	TFR	D,X		'X' = value
	LDA	-1,U		Get char back
	PSHS	U		Save format string
	LDU	6,S		Get output pointer
* 'b' Binary number
	LDB	#2		Base 2
	CMPA	#'b'		Binary output?
	BEQ	?8		Yes, do it
* 'o' Octal number
	LDB	#8		Base 8
	CMPA	#'o'		Octal output?
	BEQ	?8		Yes, do it
* 'x' hexidecimal number
	LDB	#16		Base 16
	CMPA	#'x'		Hex output?
	BEQ	?8		Yes, do it
* 'u' unsigned number
	CMPA	#'u'		Unsigned number?
	BEQ	?7		Yes, do it
* 'd' decimal number
	CMPA	#'d'		Decimal number?
	BNE	?20		No, try next
	TFR	X,D		D = value
	TSTA			Negative?
	BPL	?7		No, its OK
	COMA			Convert to
	COMB			Negative
	ADDD	#1		of value
	TFR	D,X		Resave
	LDA	#'-'		Minus size
	STA	,U+		Write to output
	LDB	?temp+1		Get field
	BEQ	?7		Fixed length
	DEC	?temp+1		Reduce width
?7	LDB	#10		Base 10 output
* Output number in X using base in B
?8	CLRA			Zero initial width
	PSHS	A		Save marker
* Process value & stack digits (in reverse order)
?9	TFR	D,Y		Save value
	CLRA			Zero high
	JSR	?mod		D = value % base, X = value / base
	ADDB	#'0'		Convert to ASCII
	CMPB	#'9'		in range?
	BLS	?10		Its OK
	ADDB	#7		Convert
?10	PSHS	B		Save value
	TFR	Y,D		Get count/base
	INCA			Advance count
	CMPX	#0		More digits?
	BNE	?9		Yes, continue output
* Unstack digits into output buffer
	JSR	?40		Left fill if necessary
?11	LDB	,S+		Get char
	BEQ	?12		End of line
	STB	,U+		write to output
	BRA	?11		Keep going
?12	TST	?temp		Left justify?
	BPL	?13		No, don't PAD
	JSR	?50		Right fill
?13	STU	6,S		Resave output ptr
	PULS	U		Restore format string
	JMP	?1		And get next
* 's' string
?20	CMPA	#'s'		String output?
	BNE	?30		No, try next
	PSHS	X		Save pointer to string
	LDA	#-1		Initial count
?21	INCA			Advance count
	LDB	,X+		Test and advance
	BNE	?21		Go till end of string
	PULS	X		Restore pointer to string
	JSR	?40		Left fill if necessary
?22	LDB	,X+		Get char
	BEQ	?12		End of string
	STB	,U+		Write in output buffer
	BRA	?22		And continue
*'c' Character
?30	TFR	A,B		Copy character
	CMPA	#'c'		Character output?
	BNE	?31		No, use character
	TFR	X,D		'B' = character
?31	LDA	#1		Width=1
	JSR	?40		Left fill if necessary
	STB	,U+		Write output
	BRA	?12		And proceed
*
* Pad the field assuming width in A
*
?40	TST	?temp		Left justify?
	BPL	?50		No, pad
	RTS
?50	PSHS	A,B		Save width
	LDB	?temp+1		Fixed field?
	BEQ	?53		No, exit
	LDA	?temp		Get flags
	ANDA	#%00111111	Save only ' ' or '0'
?52	CMPB	,S		Are we over?
	BLS	?53		Yes, exit
	STA	,U+		Fill one char
	DECB			Reduce count
	BRA	?52		And proceed
?53	PULS	A,B,PC		Restore & return
*00000
