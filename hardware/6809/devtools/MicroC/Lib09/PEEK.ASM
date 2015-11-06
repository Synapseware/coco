* Read a BYTE of memory: int peek(address)
peek	LDB	[2,S]		Get address
	CLRA			Zero high
	RTS
* Read a WORD of memory: int peekw(address)
peekw	LDD	[2,S]		Get address
	RTS
* Write a BYTE to memory: poke(address, data)
poke	LDD	2,S		Get argument
	STB	[4,S]		Write data
	RTS
* Write a WORD to memory: pokew(address, data)
pokew	LDD	2,S		Get argument
	STD	[4,S]		Write data
	RTS
*00000
