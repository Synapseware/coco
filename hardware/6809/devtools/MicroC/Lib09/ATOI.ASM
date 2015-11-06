*
* Get a decimal number from a string: atoi(string)
*
atoi	LDU	2,S		Get string
* Skip any leading whitespace
?1	LDA	,U+		Get char
	CMPA	#' '		Space?
	BEQ	?1		Skip spaces
	CMPA	#9		Tab?
	BEQ	?1		Skip tabs
* Handle leading '-'
	LDX	#0		Begin with zero
	CMPA	#'-'		Minus?
	PSHS	CC		Save for later
	BEQ	?2		Don't restore
	LEAU	-1,U		Backup
* Collect the digits & generate value
?2	LDA	,U+		Get char
	SUBA	#'0'		Convert
	CMPA	#9		In range?
	BHI	?3		No, its the end
	PSHS	A		Save
	LDD	#10		Value *= 10
	JSR	?mul		Do multiply
	TFR	D,X		X = result
	PULS	B		Get new digit
	ABX			Value += digit
	BRA	?2		And proceed
* If '-' was used. convert to negative
?3	TFR	X,D		Get value
	PULS	CC		Restore CC
	BNE	?4		No activity
	COMA			Convert
	COMB			To negative
	ADDD	#1		Value of result
?4	RTS
*00000
