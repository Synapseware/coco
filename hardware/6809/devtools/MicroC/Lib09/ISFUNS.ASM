*
* Test for ASCII character
*
isascii	LDD	#$007F		Range to test
	BRA	?3		Perform test
*
* Test for alphanumeric character (0-9, A-Z, a-z)
*
isalnum	PULS	X		X = ret address
	BSR	isdigit		Is it a digit?
	BEQ	?2		No, try next
?1	TFR	X,PC		Return to caller
*
* Test for alphabetic character (A-Z, a-z)
*
isalpha	PULS	X		X = ret address
?2	BSR	isupper		Uppercase?
	BNE	?1		Yes, we have it
	PSHS	X		X = ret address
*
* Test for lowercase alphabetic character (a-z)
*
islower	LDD	#'az'		Range to test
	BRA	?3		Perform test
*
* Test for uppercase alphabetic character (A-Z)
*
isupper	LDD	#'AZ'		Range to test
	BRA	?3		Perform test
*
* Test for graphic (printable) character
*
isgraph	LDD	#$217E		Range to test
	BRA	?3		And proceed
*
* Test for hexidecimal digit
*
isxdigit PULS	X		X = ret addrss
	LDD	#'AF'		Test range
	BSR	?5		Test it
	BNE	?1		Found it
	LDD	#'af'		Test range
	BSR	?5		Test it
	BNE	?1		Found it
	PSHS	X		Resave ret addr
*
* Test for an ASCII digit (0-9)
*
isdigit	LDD	#'09'		Range to test
* Test argument against range in A:B
?3	CMPA	3,S		Test LOWER limit
	BHI	?5		Failed, return FALSE
	CMPB	3,S		Test UPPER limit
	BLO	?5		Failed, return FALSE
* Test that upper byte of argument is zero
?4	LDA	2,S		Get high byte
	BNE	?5		Non-zero, fail
	LDB	#1		return 1
	RTS
* Report failure, return FALSE (0)
?5	CLRA			Zero HIGH
	CLRB			Zero LOW
	RTS	
*
* Test for CONTROL character
*
iscntrl	LDB	3,S		Get argument
	CMPB	#$7F		Delete?
	BEQ	?4		Yes, test high
	LDD	#$001F		CTRL-range
	BRA	?3		Complete test
*
* Test for a punctuation character
*
ispunct	LDD	2,S		Get argument
	PSHS	A,B		Pass it on
	BSR	isalnum		Alphanumeric?
	LEAS	2,S		Clean up
	BNE	?5		Yes, false
isprint	LDD	#$207E		Printable range
	BRA	?3		And test for it
*
* Test for a "space" character
*
isspace	LDB	3,S		Get argument
	CMPB	#' '		Space?
	BEQ	?4		Seems OK
	CMPB	#9		Tab?
	BEQ	?4		Seems OK
	CMPB	#10		Newline?
	BEQ	?4		Seems OK
	BRA	?5		Invalid
*00000
