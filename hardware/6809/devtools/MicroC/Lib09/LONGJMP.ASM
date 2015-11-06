* Set a long jump: setjmp(int environment[2])
setjmp	PULS	A,B		Get return address
	LDX	,S		Point to save area
	STD	,X		Save return address
	STS	2,X		Save current stack
	CLRA			Zero high
	CLRB			Zero low
	JMP	[,X]		Return
* Perform a long jump: longjmp(int environment[2], int rvalue)
longjmp	LDX	4,S		Get pointer to save area
	LDD	2,S		Get return value
	LDS	2,X		Restore stack pointer
	JMP	[,X]		Return
*00000
