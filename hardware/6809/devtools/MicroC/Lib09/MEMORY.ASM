* Set memory contents: memset(dest, value, size)
memset	LDU	6,S		Get destination
	LDD	4,S		Get value
	LDX	2,S		Get size
?1	STB	,U+		Write a value
	LEAX	-1,X		Reduce count
	BNE	?1		Do all locations
	RTS
* Copy memory contents: memcpy(dest, source, size)
memcpy	LDU	6,S		Get destination
	LDY	4,S		Get source
	LDX	2,S		Get size
?2	LDB	,Y+		Read a byte
	STB	,U+		Write a byte
	LEAX	-1,X		Reduce count
	BNE	?2		Do all locations
	RTS
*00000
