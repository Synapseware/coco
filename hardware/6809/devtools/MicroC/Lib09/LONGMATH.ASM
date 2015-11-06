*
* Functions to perform basic arithmetic operations on arbitrarily
* large unsigned numbers. Supports: + - * / % <<1 >>1 == != < >
*
* To work on other than 32 bits, adjust the following constants:
?LSIZE	EQU	4		4 bytes (32 bits)
$DD:Longreg	4
*
* Subtract two LONG numbers: longsub(num1, num2)
*
longsub	LDX	4,S		Get num1
	LDU	2,S		Get num2
?bigsub	LDB	#?LSIZE		Get byte count
	CLRA			Clear carry in
?1	LDA	,X		Get byte from num1
	SBCA	,U+		Subtract num2
	STA	,X+		Resave dest
	DECB			Reduce count
	BNE	?1		Do them all
	ROLB			Get carry out
	CLRA			Zero high
	RTS
*
* Add two LONG numbers: longadd(num1, num2)
*
longadd	LDX	4,S		Get num1
	LDU	2,S		Get num2
?bigadd	LDB	#?LSIZE		Get byte count
	CLRA			Clear carry in
?2	LDA	,X		Get byte from num1
	ADCA	,U+		Add num2
	STA	,X+		Resave dest
	DECB			Reduce count
	BNE	?2		Do them all
	ROLB			Get carry out
	CLRA			Zero high
	RTS
*
* Shift LONG number right: longshr(num1)
*
longshr	LDX	2,S		Get num2
?bigshr	LDB	#?LSIZE		Get byte count
	ABX			Adjust to end
	CLRA			No carry in
?3	ROR	,-X		Shift one byte
	DECB			Reduce count
	BNE	?3		Do them all
	ROLB			Get carry out
	RTS
*
* Shift a LONG number left: longshl(num1)
*
longshl	LDX	2,S		Get num2
?bigshl	CLRA			No carry in
?bigslc	LDB	#?LSIZE		Get byte count
?4	ROL	,X+		Shift one byte
	DECB			Reduce count
	BNE	?4		Do them all
	ROLB			Get carry out
	RTS
*
* Divide two LONG numbers: longdiv(num1, num2)
*
longdiv	BSR	?10		Zero temp location
	LDY	#(?LSIZE*8)+1	Get bit count
?5	CLRA			No carry in
?6	LDX	4,S		Point to num1
	BSR	?bigslc		Shift it
	LEAY	-1,Y		Reduce count
	BEQ	?14		End, exit
	LDX	#Longreg	Point to temp
	RORB			Set carry out
	BSR	?bigslc		Do shift
	LDU	2,S		Point to num2
	LDX	#Longreg	Point to temp
	BSR	?bigcmp		Do compare
	TSTA			Is it less
	BNE	?5		Yes, carry zero
	LDU	2,S		Get num2
	LDX	#Longreg	Point to temp
	BSR	?bigsub		Do subtract
	ORCC	#$01		Set carry in
	BRA	?6		And proceed
*
* Multiply two LONG numbers: longmul(num1, num2)
*
longmul	LEAS	-?LSIZE,S	Reserve space for num3
	LEAX	,S		Point to it
	LDU	?LSIZE+2,S	Get num2 pointer
	BSR	?bigcpy		Copy the number
	BSR	?10		Zero temp location
?7	LDX	?LSIZE+4,S	Point to num1
	BSR	?bigshr		Do the shift
	TSTB			Carry out?
	BEQ	?8		No, leave it
	LDX	#Longreg	Point to temp
	LEAU	,S		Point to num3
	BSR	?bigadd		Do the addition
?8	LDX	?LSIZE+4,S	Point to num1
	BSR	?bigtst		Test it
	BEQ	?9		End, exit
	LEAX	,S		Point to num3
	BSR	?bigshl		Do the shift
	LEAX	,S		Restore pointer
	BSR	?bigtst		Test it
	BNE	?7		Keep going
?9	LEAS	?LSIZE,S	Restore stack
	LDX	4,S		Get num1 pointer
	LDU	#Longreg	Point to temp
	BRA	?bigcpy		Copy & return
*
* Zero the temporary location
*
?10	LDX	#Longreg	Point to register
?11	LDB	#?LSIZE		Get byte count
?12	CLR	,X+		Zero one byte
	DECB			Reduce count
	BNE	?12		Do them all
	RTS
*
* Test a LONG number for zero: longtst(num1)
*
longtst	LDX	2,S		Get num1
?bigtst	LDA	#?LSIZE		Get byte count
?13	LDB	,X+		Get byte
	BNE	?14		Not zero - exit
	DECA			Reduce count
	BNE	?13		Exit
?14	RTS
*
* Compare two LONG numbers: longcmp(num1, num2)
*
longcmp	LDX	4,S		Get num1
	LDU	2,S		Get num2
?bigcmp	LDB	#?LSIZE		Get byte count
	ABX			Adjust num1 ptr
	LEAU	B,U		Adjust num2 ptr
?15	LDA	,-X		Get byte from source
	SUBA	,-U		Does it match?
	BLO	?16		Its lower
	BHI	?17		Its higher
	DECB			Reduce count
	BNE	?15		Test them all
	RTS
?16	LDD	#-1		Return -1
	RTS
?17	LDD	#1		Return 1
	RTS
*
* Copy one LONG number to another: longcpy(num1, num2)
*
longcpy	LDX	4,S		Get num1
	LDU	2,S		Get num2
?bigcpy	LDB	#?LSIZE		Get byte count
?18	LDA	,U+		Get byte from num2
	STA	,X+		Copy to num1
	DECB			Reduce count
	BNE	?18		Do them all
	RTS
*
* Set a long number
*
longset	LDX	4,S		Get address
	BSR	?11		Zero it
	LDX	4,S		Get address back
	LDD	2,S		Get value
	STB	,X		Write LOW
	STA	1,X		Write HIGH
	RTS
*00000
