* Compare two strings: strcmp(char *string1, char *string1)
strcmp	LDX	2,S		Get string1
	LDU	4,S		Get string2
?1	LDA	,X+		Get char
	CMPA	,U+		Compare
	BLO	?2		string1 < string2
	BHI	?3		string1 > string2
	TSTA			End of string
	BNE	?1		Keep going
	CLRB			Zero low
	RTS
?2	LDD	#-1		Lower
	RTS
?3	LDD	#1		Higher
	RTS
*00000
