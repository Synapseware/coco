*#cpu 6809
*
* DDS MICRO-C 6809 Runtime Library - Prefix file
*
* Copyright 1991-2001 Dave Dunfield
* All rights reserved.
*
	ORG	$2000		Place code in memory here
?begin	LDS	#$B000		Initial stack goes here
	CLR	?heap		Zero out the heap
	JSR	main		Call user module
* Return to MON09 by calling the EPROM starting address
* Wait for and pending serial I/O to complete, and then jump.
exit	CLRA			Large counter
	CLRB			"" ""
?exit1	SUBD	#1		Reduce count
	BNE	?exit1		Wait for expiry
	JMP	$E082		Re-enter monitor
* 16 bit Multiply: D = X * D
?mul	PSHS	D,X		Save parameters
	LDA	1,S		Get low of parm 1
	LDB	3,S		And low of parm 2
	MUL			Multiply to get result
	PSHS	A,B		Save result
	LDA	2,S		Get high of parm 1
	LDB	5,S		And low of parm 2
	MUL			Multiply to get result
	ADDB	,S		Add to high of previous result
	STB	,S		And resave
	LDA	3,S		Get low of parm 1
	LDB	4,S		And high of parm 2
	MUL			Multiply to get result
	ADDB	,S		Add to result
	STB	,S		And resave
	PULS	A,B		Get result from stack
	LEAS	4,S		Drop saved parameters
	RTS
* 16 bit signed division: D = X / D
?sdiv	PSHS	A,B,X		Save D,X
	EORA	2,S		Get answer sign
	TFR	D,Y		Save
	LDD	,S		Get parm1
	BPL	?sdiv1		Not negative
	BSR	?sdiv3		Convert
	STD	,S		Resave
?sdiv1	LDD	2,S		Get parm2
	BPL	?sdiv2		Not negative
	BSR	?sdiv3		Convert
	STD	2,S		Resave
?sdiv2	TFR	Y,D		Get answer sign
	TSTA			Set flags
	PULS	A,B,X		Restore parameters
	BPL	?div		Non-negative answer
	BSR	?mod		X = X / D
	TFR	X,D		D = X / D
?sdiv3	COMA			Ones complment
	COMB			the 16 bit accumulator
	ADDD	#1		Two's complement (negate)
	RTS
* 16 bit unsigned Division: D = X / D
?div	BSR	?mod		X = X / D
	TFR	X,D		D = X / D
	RTS
* 16 bit Modulus and Division: (D = X % D, X = X / D)
?smod	EQU	*		Entry point for signed modulus
?mod	PSHS	D,X		Save parameters
	CLRA			Begin with zero
	CLRB			"" ""
	LDX	#17		16+1 bit shift
?mod1	ANDCC	#%11111110	No carry in
?mod2	ROL	3,S		Parm2 * 2, CF = carry out
	ROL	2,S		(16 bit shift)
	LEAX	-1,X		Reduce bit count
	BEQ	?mod3		All finished, exit
	ROLB			Shift in bit, result * 2;
	ROLA			(16 bit shift)
	CMPD	,S		Result < parm 1?
	BLO	?mod1		Yes, keep going
	SUBD	,S		Reduce by count
	ORCC	#00000001	Set carry in
	BRA	?mod2		And proceed
?mod3	LEAS	2,S		Drop saved parameter
	PULS	X,PC		Restore & return
* Shift left: D = X << D
?shl	EXG	D,X		D = value, X = #bits
	CMPX	#0		Special case (0 bit shift)
	BEQ	nargs		Yes, early exit
?shl1	LSLB			Shift one bit
	ROLA			(16 bit shift)
	LEAX	-1,X		Reduce count
	BNE	?shl1		Not finished, continue
nargs	RTS
* Shift right: D = X >> D
?shr	EXG	D,X		D = value, X = #bits
	CMPX	#0		Special case (0 bit shift)
	BEQ	nargs		Yes, early exit
?shr1	LSRA			Shift one bit
	RORB			(16 bit shift)
	LEAX	-1,X		Reduce count
	BNE	?shr1		Not finished, continue
	RTS
* Signed >, >=, <, <=
?gt	PSHS	A,B		D = X > D
	CMPX	,S++
	BGT	?ret1
	BRA	?ret0
?ge	PSHS	A,B		D = X >= D
	CMPX	,S++
	BGE	?ret1
	BRA	?ret0
?lt	PSHS	A,B		D = X < D
	CMPX	,S++
	BLT	?ret1
	BRA	?ret0
?le	PSHS	A,B		D = X <= D
	CMPX	,S++
	BLE	?ret1
	BRA	?ret0
* = amd !=
?eq	PSHS	A,B		D = X == D
	CMPX	,S++
	BEQ	?ret1
* FALSE result, D=0, ZF=1
?ret0	CLRA
	CLRB
	RTS
?ne	PSHS	A,B		D = X != D
	CMPX	,S++
	BEQ	?ret0
* TRUE result, D=1, ZF=0
?ret1	LDD	#1
	RTS
* Unsigned >, >=, <, <=
?ugt	PSHS	A,B		D = X > D
	CMPX	,S++
	BHI	?ret1
	BRA	?ret0
?uge	PSHS	A,B		D = X >= D
	CMPX	,S++
	BHS	?ret1
	BRA	?ret0
?ult	PSHS	A,B		D = X < D
	CMPX	,S++
	BLO	?ret1
	BRA	?ret0
?ule	PSHS	A,B		D = X <= D
	CMPX	,S++
	BLS	?ret1
	BRA	?ret0
* Logical negation: D = !D
?not	CMPD	#0
	BNE	?ret0
	BRA	?ret1
* Switch table handler
?switch	LDX	,U++		Get label value
	BEQ	?swit1		End of table, use default
	CMPD	,U++		Does value match?
	BNE	?switch		No, try next
	JMP	,X		Execute this case
?swit1	JMP	[,U]		Execute default case
* Temporary storage area...
$DD:?temp 2
*00000
