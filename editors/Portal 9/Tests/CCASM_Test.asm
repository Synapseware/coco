*------------------------------------------------------------------------------
* CCASM 6809/6309 cross assembler test source
* includes most of the assembler's functions
* not intended to be executed
*------------------------------------------------------------------------------
	ttl	CCASM_Test

	org	8192	defaults to org 0 if not specified

true	=	1
false	=	0

orange	=	fruit
fruit	=	-1

label2	equ	2	set "label2" to the value of 2
label3	=	3	set "label3" to the value of 3
label4	set	4	set "label4" to the value of 4
apple	equ	100
apple	set	50	reassign the value 50 to the label/symbol "apple"
apple3	set	10	same as "equ 10"
color3	=	19
row	=	5
col	=	8
ilong	=	71294
nlong	=	-1
IMM	equ	$12
DIR	equ	$34
EXT	equ	$5678

start	equ	*	set "start" label to the current Program Counter (PC) address

*------------------------------------------------------------------------------
* automatic Direct Page addressing
*------------------------------------------------------------------------------

	setdp	$11
	lda	#57
	sta	$11DF
	setdp	$00

*------------------------------------------------------------------------------
* 6809 instruction tests
*------------------------------------------------------------------------------

	ABX
*
	ADCA	#IMM
	ADCA	DIR
	ADCA	EXT
	ADCA	[EXT]
	ADCA	,X
	ADCA	,Y++
	ADCA	[,--U]
	ADCB	#IMM
	ADCB	DIR
	ADCB	EXT
	ADCB	[EXT]
	ADCB	,X
	ADCB	,Y++
	ADCB	[,--U]
*
	ADDA	#IMM
	ADDA	DIR
	ADDA	EXT
	ADDA	[EXT]
	ADDA	,X
	ADDA	,Y++
	ADDA	[,--U]
	ADDB	#IMM
	ADDB	DIR
	ADDB	EXT
	ADDB	[EXT]
	ADDB	,X
	ADDB	,Y++
	ADDB	[,--U]
	ADDD	#IMM
	ADDD	DIR
	ADDD	EXT
	ADDD	[EXT]
	ADDD	,X
	ADDD	,Y++
	ADDD	[,--U]
*
	ANDA	#IMM
	ANDA	DIR
	ANDA	EXT
	ANDA	[EXT]
	ANDA	,X
	ANDA	,Y++
	ANDA	[,--U]
	ANDB	#IMM
	ANDB	DIR
	ANDB	EXT
	ANDB	[EXT]
	ANDB	,X
	ANDB	,Y++
	ANDB	[,--U]
	ANDCC	#IMM
*
	ASLA
	ASLB
	ASL	DIR
	ASL	EXT
	ASL	[EXT]
	ASL	,X
	ASL	,Y++
	ASL	[,--U]
*
	ASRA
	ASRB
	ASR	DIR
	ASR	EXT
	ASR	[EXT]
	ASR	,X
	ASR	,Y++
	ASR	[,--U]
*
	BCC	*
	BCS	*
	BEQ	*
	BGE	*
	BGT	*
	BHI	*
	BHS	*
	BLE	*
	BLO	*
	BLS	*
	BLT	*
	BMI	*
	BNE	*
	BPL	*
	BRA	*
	BRN	*
	BVC	*
	BVS	*
	BSR	*
*
	BITA	#IMM
	BITA	DIR
	BITA	EXT
	BITA	[EXT]
	BITA	,X
	BITA	,Y++
	BITA	[,--U]
	BITB	#IMM
	BITB	DIR
	BITB	EXT
	BITB	[EXT]
	BITB	,X
	BITB	,Y++
	BITB	[,--U]
*
	CLRA
	CLRB
	CLR	DIR
	CLR	EXT
	CLR	[EXT]
	CLR	,X
	CLR	,Y++
	CLR	[,--U]
*
	CMPA	#IMM
	CMPA	DIR
	CMPA	EXT
	CMPA	[EXT]
	CMPA	,X
	CMPA	,Y++
	CMPA	[,--U]
	CMPB	#IMM
	CMPB	DIR
	CMPB	EXT
	CMPB	[EXT]
	CMPB	,X
	CMPB	,Y++
	CMPB	[,--U]
	CMPD	#IMM
	CMPD	DIR
	CMPD	EXT
	CMPD	[EXT]
	CMPD	,X
	CMPD	,Y++
	CMPD	[,--U]
	CMPX	#IMM
	CMPX	DIR
	CMPX	EXT
	CMPX	[EXT]
	CMPX	,X
	CMPX	,Y++
	CMPX	[,--U]
	CMPY	#IMM
	CMPY	DIR
	CMPY	EXT
	CMPY	[EXT]
	CMPY	,X
	CMPY	,Y++
	CMPY	[,--U]
	CMPU	#IMM
	CMPU	DIR
	CMPU	EXT
	CMPU	[EXT]
	CMPU	,X
	CMPU	,Y++
	CMPU	[,--U]
*
	COMA
	COMB
	COM	DIR
	COM	EXT
	COM	[EXT]
	COM	,X
	COM	,Y++
	COM	[,--U]
*
	CWAI	#IMM
	DAA
*
	DECA
	DECB
	DEC	DIR
	DEC	EXT
	DEC	[EXT]
	DEC	,X
	DEC	,Y++
	DEC	[,--U]
*
	EORA	#IMM
	EORA	DIR
	EORA	EXT
	EORA	[EXT]
	EORA	,X
	EORA	,Y++
	EORA	[,--U]
	EORB	#IMM
	EORB	DIR
	EORB	EXT
	EORB	[EXT]
	EORB	,X
	EORB	,Y++
	EORB	[,--U]
*
	EXG	A,B
	EXG	X,Y
*
	INCA
	INCB
	INC	DIR
	INC	EXT
	INC	[EXT]
	INC	,X
	INC	,Y++
	INC	[,--U]
*
	JMP	DIR
	JMP	EXT
	JMP	[EXT]
	JMP	,X
	JMP	,X++
	JMP	[,--Y]
	JSR	DIR
	JSR	EXT
	JSR	[EXT]
	JSR	,X
	JSR	,X++
	JSR	[,--Y]
*
	LBCC	*
	LBCS	*
	LBEQ	*
	LBGE	*
	LBGT	*
	LBHI	*
	LBHS	*
	LBLE	*
	LBLO	*
	LBLS	*
	LBLT	*
	LBMI	*
	LBNE	*
	LBPL	*
	LBRA	*
	LBRN	*
	LBVC	*
	LBVS	*
	LBSR	*
*
	LDA	#IMM
	LDA	DIR
	LDA	EXT
	LDA	[EXT]
	LDA	,X
	LDA	,Y++
	LDA	[,--U]
	LDB	#IMM
	LDB	DIR
	LDB	EXT
	LDB	[EXT]
	LDB	,X
	LDB	,Y++
	LDB	[,--U]
	LDD	#IMM
	LDD	DIR
	LDD	EXT
	LDD	[EXT]
	LDD	,X
	LDD	,Y++
	LDD	[,--U]
*
	LEAX	5,X
	LEAX	,Y++
	LEAX	,--U
	LEAX	[,S++]
	LEAY	5,X
	LEAY	,Y++
	LEAY	,--U
	LEAY	[,S++]
	LEAU	5,X
	LEAU	,Y++
	LEAU	,--U
	LEAU	[,S++]
	LEAS	5,X
	LEAS	,Y++
	LEAS	,--U
	LEAS	[,S++]
*
	LSLA
	LSLB
	LSL	DIR
	LSL	EXT
	LSL	[EXT]
	LSL	,X
	LSL	,Y++
	LSL	[,--U]
*
	LSRA
	LSRB
	LSR	DIR
	LSR	EXT
	LSR	[EXT]
	LSR	,X
	LSR	,Y++
	LSR	[,--U]
*
	MUL
*
	NEGA
	NEGB
	NEG	DIR
	NEG	EXT
	NEG	[EXT]
	NEG	,X
	NEG	,Y++
	NEG	[,--U]
*
	NOP
*
	ORA	#IMM
	ORA	DIR
	ORA	EXT
	ORA	[EXT]
	ORA	,X
	ORA	,Y++
	ORA	[,--U]
	ORB	#IMM
	ORB	DIR
	ORB	EXT
	ORB	[EXT]
	ORB	,X
	ORB	,Y++
	ORB	[,--U]
	ORCC	#IMM
*
	PSHS	A,B,CC,DP,X,Y,U,PC
	PSHU	A,B,CC,DP,X,Y,S,PC
	PULS	A,B,CC,DP,X,Y,U,PC
	PULU	A,B,CC,DP,X,Y,S,PC
*
	ROLA
	ROLB
	ROL	DIR
	ROL	EXT
	ROL	[EXT]
	ROL	,X
	ROL	,Y++
	ROL	[,--U]
*
	RORA
	RORB
	ROR	DIR
	ROR	EXT
	ROR	[EXT]
	ROR	,X
	ROR	,Y++
	ROR	[,--U]
*
	RTI
	RTS
*
	SBCA	#IMM
	SBCA	DIR
	SBCA	EXT
	SBCA	[EXT]
	SBCA	,X
	SBCA	,Y++
	SBCA	[,--U]
	SBCB	#IMM
	SBCB	DIR
	SBCB	EXT
	SBCB	[EXT]
	SBCB	,X
	SBCB	,Y++
	SBCB	[,--U]
*
	SEX
*
	STA	DIR
	STA	EXT
	STA	[EXT]
	STA	,X
	STA	,Y++
	STA	[,--U]
	STB	DIR
	STB	EXT
	STB	[EXT]
	STB	,X
	STB	,Y++
	STB	[,--U]
	STD	DIR
	STD	EXT
	STD	[EXT]
	STD	,X
	STD	,Y++
	STD	[,--U]
*
	SUBA	#IMM
	SUBA	DIR
	SUBA	EXT
	SUBA	[EXT]
	SUBA	,X
	SUBA	,Y++
	SUBA	[,--U]
	SUBB	#IMM
	SUBB	DIR
	SUBB	EXT
	SUBB	[EXT]
	SUBB	,X
	SUBB	,Y++
	SUBB	[,--U]
	SUBD	#IMM
	SUBD	DIR
	SUBD	EXT
	SUBD	[EXT]
	SUBD	,X
	SUBD	,Y++
	SUBD	[,--U]
*
	SWI
	SWI2
	SWI3
	SYNC
*
	TFR	A,B
	TFR	X,Y
*
	TSTA
	TSTB
	TST	DIR
	TST	EXT
	TST	[EXT]
	TST	,X
	TST	,Y++
	TST	[,--U]

*------------------------------------------------------------------------------
* constant value identifiers  ($=hex, %=binary, otherwise decimal)
*------------------------------------------------------------------------------

	lda	#-10		decimal value
	lda	#-$10		hex value
	ldd	#-%1101100	binary value
	lda	$ff		hex address
	ldd	$ff00		hex address
	lda	%011		binary address

*------------------------------------------------------------------------------
* ASCII character translation to binary
*------------------------------------------------------------------------------

	cond	1
	lda	#'a
	lda	#'Z
	lda	#'9
	lda	#'0
	endc


*------------------------------------------------------------------------------
* direct page and extended page addressing
* the "<" and ">" address mode modifiers are used
* to override the assembler's choice
*------------------------------------------------------------------------------

	if	true
	lda	<5	accesses Direct Page address $05
	lda	>5	accesses "64k" address $0005 (regardless of Direct Page contents)
	lda	5	let the assembler decide (produces the smallest possible code)
	lda	<1,x	force 8-bit offset
	lda	>1,x	force 16-bit offset
	lda	1,x	assembler chooses the smallest possible offset starting from 5-bit up to 16-bit
	lda	0,x	assembler chooses 5-bit offset of 0
	lda	,x	use NO offset (not exactly the same as 0,x)
	lda	<0,x	use 8-bit offset of 0
	lda	>5,x	use 16-bit offset of 5
	endc

*------------------------------------------------------------------------------
* loading data into registers
*------------------------------------------------------------------------------

	lda	#5	load a constant
	ldd	#-5	load a constant
	ldx	$0400	load directly from memory
	ldy	#512
	ldu	#100
	lds	#32512
	lda	#%011	load binary value of 3 into A
	lda	#$03	load hex value of 3 into A
	ldb	#$3	load hex value of 3 into B
	ldd	#%110	load binary value of 6 into D
	ldx	138	load 16-bit value at address 138 into register X
	ldy	158	load 16-bit value at address 158 into register Y
	ldx	apple	load into register X the contents of the address "apple"

*------------------------------------------------------------------------------
* storing registers to memory
*------------------------------------------------------------------------------

	sta	>$0a	write to $000a regardless of DP mode
	std	,x
	stx	32100
	sty	$100
	sts	%011

*------------------------------------------------------------------------------
* using the 6309's powerful 32-bit register Q (A,B,E,F)
*------------------------------------------------------------------------------

	ldq	#65536		load the value 65536
	ldq	#-1		load the highest possible unsigned 32-bit value
	ldq	#$FBAC3DE7	8-digit hexidecimal
	ldq	#$Beef

*------------------------------------------------------------------------------
* exchanging two registers (swapping their contents)
*------------------------------------------------------------------------------

	exg	a,b
	exg	b,a
	exg	d,x
	exg	x,u
	exg	x,pc

*------------------------------------------------------------------------------
* transferring one register to another
*------------------------------------------------------------------------------

	tfr	a,b
	tfr	x,y
	tfr	d,x

*------------------------------------------------------------------------------
* because the 6309 CPU has been found to allow exchanges between different
* register sizes, it is possible to assemble such instructions
*------------------------------------------------------------------------------

	tfr	a,x
	tfr	x,a
	tfr	y,b

*------------------------------------------------------------------------------
* indexed memory access
*------------------------------------------------------------------------------

	lda	,-x	automatic decrement before read
	lda	,x+	automatic increment after read
	lda	1,x	constant offset from x
	lda	-1,x	negative constant offset from x
	lda	16,x
	lda	-16,x
	lda	127,x
	lda	-127,x
	lda	128,x
	lda	-128,x
	lda	256,x
	lda	*+2
	lda	*-2
	lda	-256,x
	lda	32767,x
	LEAX	-$4000,X
	leax	$8000,x
	leay	-$40,y
	LEAX	-350,X
	leax	1,x
	LEAU	512,U
	LEAU	32,U
	ANDCC	#$CF
	leay	32,Y
	LEAS	2,S
	LEAU	D,U
	leax	-1,X
	leay	B,Y
	leax	-350,X

*------------------------------------------------------------------------------
* automatic index offset ranges (5-bit)
*------------------------------------------------------------------------------

	lda	-16,x
	lda	-15,x
	lda	15,x

*------------------------------------------------------------------------------
* automatic index offset ranges (8-bit)
*------------------------------------------------------------------------------

	lda	-128,x
	lda	-127,x
	lda	-17,x
	lda	16,x
	lda	127,x

*------------------------------------------------------------------------------
* automatic index offset ranges (16-bit)
*------------------------------------------------------------------------------

	lda	-32768,x
	lda	-32767,x
	lda	-129,x
	lda	128,x
	lda	32767,x

*------------------------------------------------------------------------------
* automatic vs. forced index offset ranges
*------------------------------------------------------------------------------

	leax	1,y		automatic 5-bit range
	leax	<1,y		force 8-bit range, but why?
	leax	>1,y		force 16-bit range, but why?
	leax	-1,y		automatic 5-bit range for negative offset
	leax	<-1,y		force 8-bit range on negative offset, but why?
	leax	>-1,y		force 16-bit range on negative offset, but why?
	leax	255,y		+255 can't fit into 5 bits, so becomes 16-bit range
	leax	<255,y		means -1,y since you're confining 255 to an 8-bit int
	leax	>255,y		force 16-bit range, so it equals 255,y
	leax	65535,y		automatic 5-bit range for -1,y (65535 means -1)
	leax	<65535,y	8-bit range for -1,y
	leax	>65535,y	16-bit range for -1,y

*------------------------------------------------------------------------------
* indirect addressing, indexing, pointers
*------------------------------------------------------------------------------

	lda	[,--x]	auto-decrement 16-bit pointer before reading byte
	lda	[,x++]	auto-increment 16-bit pointer after reading byte
	jsr	[40960]	call 16-bit address stored at 40960-40961
	std	[138]	store register D in the address pointed to by address 138-139
	sta	[138]	store register A in the address pointed to by address 138-139
	lda	[,x+]	possible on 6809, but probably useless [,r+]
	lda	[,-x]	possible on 6809, but probably useless [,-r]

*------------------------------------------------------------------------------
* relative addressing, position-independent memory access
*------------------------------------------------------------------------------

	leax	start,pcr	point X to the address of symbol "start"
	leax	apple,pcr	load into register X the address of "apple"
	ldx	start,pcr	load X with the contents of the address of symbol "start"
	ldx	apple,pcr	load into register X the contents of address "apple"
	leax	start+1,pcr	point X to the address of symbol "start" + 1
	lda	*,pcr		load the first opcode of the instruction "lda *,pcr"
	lda	*+2,pc		"pc" can be used for "pcr"

*------------------------------------------------------------------------------
* load effective address
*------------------------------------------------------------------------------

	leax	65535,x		same as leax -1,x
	leax	255,y
	leax	1,x	add 1 to the register X (load 1+X back into X)
	leax	1,u	add 1 to the register U and store result into register X
	leax	,y	similar to tfr y,x (load the contents of register Y into register X)
	leay	2,s	load Y with the value of S + 2

*------------------------------------------------------------------------------
* reserving uninitialized memory
*------------------------------------------------------------------------------

	rmb	1	reserve 1 byte of memory
	rmd	1	reserve 2 bytes
	rmq	1	reserve 4 bytes
	rmb	1024	reserve 1k of memory for a buffer, table, etc.

*------------------------------------------------------------------------------
* generating direct codes and constants
*------------------------------------------------------------------------------

* initialize data
	fcb	2	form constant byte of the value 2 (2)
	fcb	1	initialized byte
	fdb	2	form double-byte of the value 2 (0,2)
	fqb	2	form 32-bit structure of the value 2 (0,0,0,2)
	fqb	9	form 4-byte structure of the value 9 (0,0,0,9)
	byte	7	same as fcb
	word	1	same as fdb
	dword	3	same as fqb
* zero-initialized data
	fzb	1	form 1 zero-initialized byte (1 PC address)
	fzd	1	form 1 zero-initialized word (2 PC addresses)
	fzq	1	form 1 zero-initialized double word (4 PC addresses)
	fzq	5	form a total of 5 32-bit integers holding the values (0,0,0,0)

*------------------------------------------------------------------------------
* forming lists/tables/arrays
*------------------------------------------------------------------------------

	fcb	1,2,3,4,5,6,7		form a simple list of bytes
	fdb	1,2,4,7,3,5,6		form a table of (7) 16-bit entries
	fdb	100,200,300,.,400	the "." returns the Program Counter within the constant list
	fqb	1,2,3,4			form a table of (4) 32-bit entries
	fcb	0+1,2,3,3+1,2+3,10-4,14/2,2*2*2
	fdb	1,$5,%101,-1,5*5

*------------------------------------------------------------------------------
* ASCII strings
*------------------------------------------------------------------------------

	fcc	"CoCo"	;form string of characters
	fcn	"CoCo"	;form null-terminated string (adds null to end)
	fcs	"CoCo"	;form Sign-terminated string (sets bit 7 of last character)
	fcr	"CoCo"	;form Carriage-Return/Null-Terminated string (adds 13,0) to end

*------------------------------------------------------------------------------
* forming simple tables of data with automatic size calculation
*------------------------------------------------------------------------------

	ldb	#tablsz		;returns size of the following "segment" of code
table	equ	*		;set "table" to the current Program Counter value (*)
	fcb	1,2,3		;store bytes 1,2,3 in the table
tablsz	equ	*-table		;compute size in bytes from here back to the address of "table"


*------------------------------------------------------------------------------
* RUN-TIME MATH (performed while this assembled program is being executed)
*------------------------------------------------------------------------------

	asra			;signed divide reg.a by 2
	lsra			;unsigned divide reg.a by 2
	lsla			;reg.a=(reg.a*2)
	addr	a,a		;reg.a=(reg.a+reg.a)
	inca			;reg.a=reg.a+1
	deca			;reg.a=reg.a=1
	adda	#16		;reg.a=reg.a+16
	addd	#32		;reg.d=reg.d+32
	addr	x,d		;reg.x=reg.x+reg.d

*------------------------------------------------------------------------------
* COMPILE-TIME MATH (mathematical expression evaluation)
* (performed while this program is being assembled)
*------------------------------------------------------------------------------

*------------------------------------------------------------------------------
* unary operations (single value operations)
*------------------------------------------------------------------------------

	lda	#-2
	ldx	#-100
	lda	#-apple		;negate a symbol's value
	lda	#^apple		;compliment a symbol's value
	lds	#~apple		;compliment a symbol's value

*------------------------------------------------------------------------------
* multiplication
*------------------------------------------------------------------------------

	lda	3*3*3
	ldx	#-30*5		; multiply 30 x 5, negate the result, giving -150
	ldx	#50*(-5)	; enclose negative multiplier
	ldx	#40*(-5)
	ldx	#30*(-5)
	lda	#5*-3		;same as 5*(0-3)
	lds	#5*(0-3)
	lda	#-3*5		;(0-3)*5
	lda	-(5*3)
	lda	-(5)*3
	ldx	#-50*5		; no need to enclose beginning negative number to multiply
	ldx	#-40*5		; multiply 40 x 5, negate the result, giving -200

*------------------------------------------------------------------------------
* division
*------------------------------------------------------------------------------

	lda	#4/2
	lda	#100/2
	ldd	#(512-100)/2
	lda	#-(100/10)
	lda	-(100/2)
	lda	#-(1/2)		-.5 (rounded off)
	ldd	#apple/100	divide value of apple by 100
	lda	#511/2
	lda	#255/4
	lda	#254/4
	lda	#253/4
	lda	#252/4
	lda	#251/4

*------------------------------------------------------------------------------
* modulas division (computes the remainder)
*------------------------------------------------------------------------------

	lda	#254%4		compute remainder of 254/4
	lda	#253%4		compute remainder of 253/4
	lda	#252%4
	lda	#255%16
	ldd	#255%8
	ldd	#255%4
	ldx	#251%4

*------------------------------------------------------------------------------
* addition/subtraction
*------------------------------------------------------------------------------

	lda	#2-1
	lda	#1-2
	ldx	#start+$1000
	lda	#100-10-10-20
	ldx	#apple+apple	same as (apple*2)

*------------------------------------------------------------------------------
* mixed arithmetic
*------------------------------------------------------------------------------

	lda	#50*4/2
	ldd	#(1024+32)*15+31
	ldd	#1+2*(3+4)+5 ; notice the order of operations ( 1 + 2*7 + 5 = 20) 
	ldx	#-(100/5*2)
	ldx	#100+(-100*10)
	ldd	#apple+200/2 ; return (value of apple) + (100)
	ldx	1*2+3*4+5*6
	ldx	#1024+8*32+15
	ldq	#0-100*200*300*400
	ldx	#apple+apple*apple
	ldx	apple-apple+1

*------------------------------------------------------------------------------
* comparison operations (return Boolean value, where true=1, false=0)
*------------------------------------------------------------------------------

 lda #1=2 ; load A register with condition (0=False, 1=True) for "1 is equal to 2"
 lda #100=100 ; load A register with condition for "100 is equal to 100"
 lda #100=100
 lda #1<2 ; condition result for "1 is less than 2"
 lda #2<2 ; check to see if "2 is less than 2"
 lda #1>2 ; check if "1 is greater than 2"
 lda #2>1 ; check if "2 is greater than 1" 
 lda #1>1 ; returns (1=True) if "1 is greater than 1", otherwise returns (0=False)
 lda #100*4=5 ; check if "100*4 is equal to 5"
 lda #100*4=4 ; check if "100*4 is equal to 4"
 lda #1<2
 lda #2<3 ; is 2 less than 3?  yes, so load the value 1 (for true)
 lda #5>=5 ; is "5 greater than or equal to 5" ? (yes)
 lda #3>4 ; 3 is not greater than 4, so this loads 0 into register A
 lda #6<=5 ; is "6 less than or equal to 5" ? (no)
 lda #6<=5
 lda #3>2 ; load condition flag 0 or 1 into A
 lda #4=4 ; load condition flag 1 into A
 lda #4=5
 lda #apple<1 ; load condition (true or false) (0 or 1) if "apple" is less than 1
 lda #apple>1
 lda #apple=1
 lda #apple+5>apple
 ldd #100*apple=apple ; 100*apple does not equal apple
 ldd #100*apple<apple ; 100*apple is not less than apple
 ldx #apple+1/2<apple
 lda #-254<=255
 ldx #1000>-1000
 ldx #-2000>2000
 ldx #2000>-5000

* logical, bitwise and Boolean operations

	lda	#true&true  ; returns true if both cases are true
	lda	#true&false
	lda	#false&true
	lda	#false&false

 lda #true!true  ; returns true if either case is true
 lda #true!false
 lda #false!true
 lda #false!false

 lda #true^false	Exclusive OR on two Boolean values
 lda #true^false
 lda #true!false!true
 lda #true&false!false
 lda #true&true&true
 lda #true!true&false

	lda #~(true&true)
	lda #^(true!true)
	lda #^(true&false)
	lda #^(false&true)
	lda #^(true!false)
	lda #^(1<255)

	lda	#(color3=19)&(row=5)&(col=8)
	lda	#(color3=19)!(row=4)!(col=1)

* should return True case
 if (color3<20)&(row<(7-1))&(col>=3+4)
 endif

* should return False case
 if (color3>=19)&(row>(7-1))&(col>=3+4)
 endif

	lda #^1
	lda #~255
	lda #^0
	lda #^192
	lda #^-1

	lda #%11111111&%11110000
	lda #%10101010&%00001111
	lda #%01010101&%11111111
	lda #%111000&%11100
	lda #apple&apple3
	lda #255&128

	lda #%10101010!%01010101
	lda #%11110000!%00001111
	lda #%110011!%001100
	lda #$f0!$0f
	lda #$0f!$80
	lda #apple!apple3
	lda #128!64
	
	lda #%1111^%1001
	lda #%1001^%0110
	lda #%101010^%010101

*------------------------------------------------------------------------------
* block memory transfers
*------------------------------------------------------------------------------

* copy an 8k block of RAM to another location in lightning speed
	ldx	#49152	start address
	ldy	#16384	destination address
	ldw	#8192	size of RAM block to copy
	copy	x,y	do the copy

* blast 64k of memory into the 6-bit sound port in lightning speed
	ldx	#0	top of CPU address space
	ldw	#65280	size of block to blast into one address
	ldy	#65312	DAC port
	imp	x,y	implode contents of ,x into ,y

* fill a 16k block of RAM with the live contents of a hardware port
	ldx 	#65314	address to read from
 	ldy	#8192	start of block to be filled
	ldw	#16384	number of bytes to read from port
	exp	x,y	expand the live contents of address 65314 into addresses 8192-24576

* clear the 32-column "VDG" screen in Disk BASIC
	ldx	#filler
	ldy	#1024
	ldw	#512
	exp	x,y
	rts
filler	fcb	96

* black out the CoCo 3's 16-color palette registers
	ldx	#65456		palette slots start here
	ldy	#blackcode	address holding filler byte
	ldw	#16		slots
	exp	x,y		fill ,y+ with zeros
	rts
blackcode	fcb	0

*------------------------------------------------------------------------------
* 6309 bit transfers between a register and a DP memory location
*------------------------------------------------------------------------------

	bor	a,7,1,$00	or memory $00 (bit 1) into register A (bit 7)
	beor	a,0,7,65280	XOR port $FF00 (bit 7) into register A (bit 0)
	ldbt	b,6,2,$10	load memory $10 (bit 2) into register B (bit 6) 
	stbt	cc,5,3,10	store reg. CC (bit 5) into memory 10 (bit 3)
	stbt	cc,5,3,<20	store reg. CC (bit 5) into memory 20 (bit 3)
	stbt	cc,5,3,>30	store reg. CC (bit 5) into memory 30 (bit 3)

*------------------------------------------------------------------------------
* 6309 BOOMs (Bit Operation On Memory) INSTRUCTIONS
* bits; memory
*------------------------------------------------------------------------------

	aim	4;1024		AND %00000100 with the memory in address 1024
	aim	252;65312	AND %11111100 with the contents of the DAC
	oim	%00001000;65386	OR the value 8 with a port
	tim	%100;65385	TEST bit 2 of the RS-232 pak status register
	tim	8;[1000]	what does this do?
	oim	128;[40960] 	OR bit #7 into the address pointed to by addresses 40960-40961
	eim	64;,x		do XOR of 64 with memory pointed to by register X
	oim	128;,u		same as LDA ,U ; ORA #128 ; STA ,U
	oim	16;1,u		same as LDA 1,U ; ORA #16 ; STA 1,U
	oim	4;2,u		same as LDA 2,U ; ORA #4 ; STA 2,U
	aim	%10000000;[,x]	same as LDA [,X] ; ANDA #128 ; STA [,X]
	aim	%01000000;[2,y]	same as LDA [2,Y] ; ANDA #64 ; STA [2,Y]
	aim	%00100000;,x+	same as LDA ,X ; ANDA #32 ; STA ,X+
	oim	%00010000;,y++ 	same as LDA ,Y ; ORA #%00010000 ; STA ,Y++


*------------------------------------------------------------------------------
* CONDITIONAL ASSEMBLY
* Any symbols used in conditional expressions MUST be pre-resolved!
*------------------------------------------------------------------------------

	cond	label2=2
lab_A	pshsw		push E/F (W) onto the S stack
	pulsw		pull E/F (W) from the S stack
	ldmd	#1	load Mode register with value of 1 (enable full 6309 mode)
	pshs	cc	push condition code register onto the S stack
	pshs	a	push A register onto the S stack
	pshs	b	push B
	pshs	d	push A/B (D)
	pshs	x	push X register onto the S stack
	pshs	y	push Y register onto the S stack
	pshs	u	push U register onto the S stack
	pshs	pc	push PC (Program Counter) register onto the S stack
	endc	end conditional assembly case

	if	label2=2
	pshs	a		push A register onto the S stack
	pshs	b		push B
	endif

	if	label2=3
lab_A	pshs	a		push A register onto the S stack
	pshs	b		push B
	endif

*------------------------------------------------------------------------------
* assembly-time instruction and operand pointers
*------------------------------------------------------------------------------

	ldx	#*	get address of instruction opcode
	leax	*,pcr	get address of instruction opcode
	ldx	*	load first 2 bytes of instruction/operand
	ldx	#.	get address of instruction operand
	leax	.,pcr	get address of instruction operand
	lda	.	load 1st byte of operand code

*------------------------------------------------------------------------------
* setting labels to the current Program Counter without using "label equ * "
*------------------------------------------------------------------------------

Somewhere:
SomewhereElse:
AnotherSomewhere:
	rmb	126
	bra	SomewhereElse
	jmp	Somewhere
	jmp	AnotherSomewhere

*------------------------------------------------------------------------------
* ALIGNING THE PROGRAM COUNTER, INSERTING OPTIONAL NULL BYTES
*------------------------------------------------------------------------------

	even		align Program Counter on an even boundary
	odd		align Program Counter on an odd boundary
	align	8	align PC on an 8-byte boundary

*------------------------------------------------------------------------------
* RECORDS/STRUCTURES
*------------------------------------------------------------------------------

person	struct
name	rmb	2	2 bytes for person's name (pointer to string)
weight	word	1	2 bytes for person's weight
	endstruct

student	struct	person
	endstruct
teacher	struct	person
	endstruct

	ldx	#sizeof{person}		get size of structure

	ldu	#students
	leax	student.name,u		point U to beginning of "name" field (chars)
	ldy	student.weight,u	load Y from "weight" field (integer)

	ldu	#teachers
	leax	teacher.name,u
	ldy	teacher.weight,u

students	rmb	1024	where records/objects are stored
teachers	rmb	1024

* Forward reference to structures and unions?
* Not a problem.

	ldx	s2.ccc
	ldx	s1.value.ccc

*------------------------------------------------------------------------------
* NAMED UNIONS & ANONYMOUS UNIONS
*------------------------------------------------------------------------------

* named union
s1	struct
ddd	byte	1
eee	word	1
value	union
aaa	byte	1	all union fields start at the same address
bbb	word	1	regardless of their size
ccc	dword	1	fields can be different data types, too
	endu
	ends

	lda	s1.value.aaa
	ldb	s1.value.bbb
	ldd	s1.value.ccc

* anonymous union
s2	struct
ddd	byte	1
eee	word	1
	union
aaa	byte	1
bbb	word	1
ccc	dword	1
	endu
	ends

	lda	s2.aaa
	ldb	s2.bbb
	ldd	s2.ccc
*------------------------------------------------------------------------------
* LOCAL LABELS AND BRANCH POINTS
* Any label containing at least one '@' character is a local label.
* local labels can be reused if separated by a blank line of sourc code.
* Branch Points are named '!' and allow you to use the '<' or '>'
* characters to branch upwards or downwards in the source code to the nearest
* Branch Point.
*------------------------------------------------------------------------------

!	lda	#50*4/2			Branch Point '!'
	ldd	#(1024+32)*15+31
	ldd	#1+2*(3+4)+5
a@	ldx	#100+101/11
	ldd	#apple+200/2
	ldx	1*2+3*4+5*6
	ldx	#1024+8*32+15
@d@	bra	>			branch downward to nearest Branch Point
	ldq	#0-100*200*300*400
	ldx	#apple+apple*apple
	ldx	apple-apple+1
@a	lda	#50*4/2
	ldd	#(1024+32)*15+31
	bra	a@			branch to the "a@" above, not directly below

a@	ldd	#1+2*(3+4)+5		reused local, possible since blank line separates other "a@"
a@@	ldx	#-(100/5*2)
	ldx	#99+10/10
!	ldd	#apple+200/2		another Branch Point '!'
	ldx	1*2+3*4+5*6
	ldx	#1024+8*32+15
@c@	ldq	#0-100*200*300*400
	ldx	#apple+apple*apple
	ldx	apple-apple+1
@b	lda	#50*4/2
	bra	a@			branch to the "a@" above
	ldd	#(1024+32)*15+31
	ldd	#1+2*(3+4)+5
b@	ldx	#100+100/10
	ldd	#apple+200/2
	ldx	1*2+3*4+5*6
@@b	ldx	#1024+8*32+15
	ldq	#0-100*200*300*400
b@b	ldx	#apple+apple*apple
	ldx	apple-apple+1
	bra	<			branch back/upwards to nearest '!' label

; ';'semicolon commenting is now allowed as well as '*' commenting
; the '?' character is now allowed for identifying local labels as well as '@'
	; comment
		;comment

a?	bra	a?a	;local label
?a	bra	?a		;local label
a?a	bra	a?			;local label
?b	leax	.,pcr
?0	fdb	1,.,3			

	lda	-1,w	register W used as a 16-bit index register
	lda	-1,x
	lda	-1,y
	lda	-1,u
	lda	-1,s
	lda	-1,pcr

* EDTASM-compatible operators

	lda	#3.and.1
	ldb	#.not.0
	lda	#1.xor.1
	lda	#10.div.2
	lda	#255.mod.4
	lda	#1.or.2
	lda	#4.equ.5
	lda	#6.equ.6
	lda	#5.neq.6
	lda	#5.neq.5
	ldx	#(true).equ.false
	ldx	#1.and.false

* Important note to EDTASM users: in order to use the .OP.
* operators correctly, use the CCASM -e option.  This
* prevents the expression evaluator from seeing structures
* and namespaces and uses the dot-named operators such as
* .not. .or. .and. .xor. correctly,
* or you can stay in full CCASM mode and stil use these
* named operators by enclosing all symbol names in parenthesis
* like so:
	
* EDTASM expression mode off but still useable

	if	(false).equ.(true)
	endif
	if	(false).or.(true).and.(true)
	endif

* EDTASM mode (-e) on but namespaces and structures now unusable
*	ldx	#true.or.false

	end