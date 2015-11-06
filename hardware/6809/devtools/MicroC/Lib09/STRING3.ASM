* Search for character in string
strchr	LDX	4,S		Get string
	LDD	2,S		Get character
?1	CMPB	,X		Does this one match?
	BEQ	?2		Yes, we have it
	TST	,X+		End of string?
	BNE	?1		No, keep looking
	LDX	#0		Indicate not found
?2	TFR	X,D		Return pointer
	RTS
*00000
