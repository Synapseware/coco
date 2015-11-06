* Return ABSOLUTE VALUE of argument: int abs(int arg)
abs	LDD	2,S		Get argument
	BPL	?1		Alreay positive
	COMA			Convert to
	COMB			Negative
	ADDD	#1		Value
?1	RTS
* Return MAXIMUM of two arguments: int max(int arg1, int arg2)
max	LDD	2,S		Get first argument
	CMPD	4,S		Compare with second
	BGE	?1		Already have largest
?2	LDD	4,S		Get largest
	RTS
* Return MINIMUM of two arguments: int min(int arg1, int arg2)
min	LDD	2,S		Get first argument
	CMPD	4,S		Compare with second
	BLE	?1		Already have smallest
	BRA	?2		Get smallest
* Return SQUARE ROOT of argument: int sqrt(int arg)
sqrt	LDX	#256		Assumed result
	LDD	2,S		Get argument
	CMPD	#255*255	Over limit
	BHI	?4		Assume 256
	LDX	#0		Start with ZERO
?3	TFR	X,D		Copy for multiply
	JSR	?mul		Perform multiply
	CMPD	2,S		Do we have it?
	BHS	?4		Yes, this is it
	LEAX	1,X		Advance count
	BRA	?3		And go again
?4	TFR	X,D		Get result
	RTS
*00000
