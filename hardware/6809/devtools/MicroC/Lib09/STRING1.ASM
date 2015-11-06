* Get length of string: strlen(char *string)
strlen	LDX	2,S		Get argument
	CLRA			Zero high
	CLRB			Zero low
?1	TST	,X+		End of string?
	BEQ	?5		Yes, exit
	ADDD	#1		Advance count
	BRA	?1		And proceed
* Concatinate one string to another: strcat(dest, source)
strcat	LDU	4,S		Get destinations
?2	LDA	,U+		Get char & advance
	BNE	?2		Not end of string
	LEAU	-1,U		Backup to end
	BRA	?3		And write the string
* Copy one string to another: strcpy(char *dest, char *source)
strcpy	LDU	4,S		Get destination
?3	LDX	2,S		Get source
?4	LDB	,X+		Get char from source
	STB	,U+		Write to dest
	BNE	?4		And proceed
?5	RTS
*00000
