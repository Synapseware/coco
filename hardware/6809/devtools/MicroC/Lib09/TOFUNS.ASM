* Convert to upper: toupper(char c)
toupper	LDD	2,S		Get argument
	CMPD	#'a'		Lower case?
	BLO	?1		No, leave alone
	CMPD	#'z'		Lower case
	BHI	?1		No, leave alone
	ANDB	#%11011111	Convert to upper
?1	RTS
* Convert to lower: tolower(char c)
tolower	LDD	2,S		Get argument
	CMPD	#'A'		Upper case?
	BLO	?1		No, leave alone
	CMPD	#'Z'		Upper case
	BHI	?1		No, leave alone
	ORB	#%00100000	Convert to lower
	RTS
*00000
