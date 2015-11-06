* Concatinate strings: register concat(dest, source1, source2, ...)
concat	LSLB			X2 for two byte entries
	LEAY	B,S		Point to first argment
	LSRB			/2 Get count back
	LDU	,Y		Get destination
?1	DECB			Reduce count
	BEQ	?3		Exit
	LDX	,--Y		Get next argument
?2	LDA	,X+		Get char
	BEQ	?1		End, proceed
	STA	,U+		Write to dest
	BRA	?2		Copy the string
?3	CLR	,U		Zero terminate
	RTS
*00000
