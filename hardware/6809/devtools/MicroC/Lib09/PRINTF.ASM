* Terminal printf: register printf(format, args ...)
printf	INCB			Skip RET address
	LSLB			x2 for words
	LEAX	B,S		Point to first arg
	LEAS	-100,S		Get a local buffer
	TFR	S,D		D = output ptr
	PSHS	D		Output ptr for putstr
	PSHS	D		And again (_format_ modifies)
	PSHS	X		Argument pointer
	JSR	_format_	Call formatter
	LEAS	4,S		Clean up arguments
	JSR	putstr		Output the string
	LEAS	102,S		Clean up stack
	RTS
$EX:_format_
$EX:putstr
*00000
