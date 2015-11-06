* Generate a pseudo-random number: int rand(limit)
rand	LDD	RANDSEED	Get the current seed
	LDX	#13709		First calculation
	JSR	?mul		Perform it
	ADDD	#13849		Add second
	STD	RANDSEED	Resave seed
	TFR	D,X		C = value
	LDD	2,S		Get limit
	JMP	?mod		Calculate result
$DD:RANDSEED 2
*00000
