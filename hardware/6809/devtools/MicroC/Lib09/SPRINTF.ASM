* String printf: register sprintf(output, format, args ...)
sprintf	LSLB			x2 for words
	LEAX	B,S		Point to first arg
	LDD	,X		Get output buffer
	PSHS	D		Save it
	PSHS	X		Save pointer
	JSR	_format_	Call formatter
	LEAS	4,S		Clean up
	RTS
$EX:_format_
*00000
