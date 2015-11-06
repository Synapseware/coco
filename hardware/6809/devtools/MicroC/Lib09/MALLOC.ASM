*
* Allocate a block of memory: char *malloc(size)
*
malloc	LDU	#?heap		Point to beginning of heap
* Search for free block of memory
?1	LDA	,U		Get flag
	BEQ	?4		End of list, allocate here
	LDX	1,U		Get size
	DECA			Un-allocated?
	BNE	?2		No, try next
* Found free block, see if its large enough
	CMPX	2,S		Large enough?
	BHS	?3		Yes, its ok
* This block not suitable, advance to next
?2	LEAX	3,X		Include overhead
	TFR	X,D		Get into acc
	LEAU	D,U		Advance to next
	BRA	?1		And try again
* This block is OK to re-allocate
?3	TFR	X,D		Get into ACC
	SUBD	2,S		Calculate remaining
	SUBD	#3		Convert for overhead
	BLS	?6		Leaved it alone
	TFR	D,Y		Save for later
* Split this block into two blocks
	LDD	2,S		Get size of block
	LEAX	D,U		Offset to next
	CLR	3,X		Set it free
	INC	3,X		Indicate de-allocated
	STY	4,X		Save size of block
	BRA	?5		And proceed
* Allocate on end of memory
?4	TFR	S,D		Get stack pointer
	SUBD	2,S		Adjust for buffer size
	SUBD	#1000		Adjust for margin
	PSHS	U		Save pointer
	LDX	#0		Assume it will fail
	CMPD	,S++		Test it
	BLS	?7		No, fail
* Ok to proceed, allocate memory
	LDD	2,S		Get size
	LEAX	D,U		Offset to new area
	CLR	3,X		Indicate end of list
?5	STD	1,U		Save block size
?6	LDB	#2		Get 'Allocated' flag
	STB	,U		Set it
	LEAX	3,U		Point to address
?7	TFR	X,D		In ACC for return
	RTS
*
* Release a block of memory: free(ptr)
*
free	LDX	2,S		Get address
	LEAX	-3,X		Backup to "real" beginning
	PSHS	X		Save for compare
* Search the allocation list for this block
	LDU	#?heap		Point to beginning of heap
?10	LDA	,U		Get address
	BEQ	?12		End of list
	CMPU	,S		Is this it?
	BEQ	?11		Yes, handle it
	LDD	1,U		Get size
	LEAU	D,U		Advance for size
	LEAU	3,U		Include overhead
	BRA	?10		And keep looking
* Mark this block as un-allocated
?11	LDA	#1		Get 'deallocated' flag
	STA	,U
?12	PULS	X		Clean up stack
* Garbage collection, scan allocation list and join any
* contiguous de-allocated blocks into single areas.
* Also, truncate list at last allocated block.
	LDU	#?heap		Point to beginning of heap
?20	LDA	,U		Get allocation flag
	BEQ	?25		End, quit
	LDX	1,U		Get size of block
	DECA			Test for de-allocated
	BNE	?23		No, its not
* This block is free, check following blocks
?21	TFR	X,D		'D' = offset
	LEAY	D,U		'Y' = next block
	LDA	3,Y		Get next flag
	BEQ	?24		End of list, its ok
	DECA			Test for allocated?
	BNE	?22		Yes, stop looking
* Next block is also free
	LDD	4,Y		Get size of next block
	LEAX	D,X		Add in size of next block
	LEAX	3,X		Inlude overhead
	BRA	?21		And keep looking
* Resave this block size
?22	STX	1,U		Save new block size
* Advance to next block in list
?23	TFR	X,D		Get length
	LEAU	D,U		Offset to next
	LEAU	3,U		Include overhead
	BRA	?20		And keep looking
* Mark this block as end of list
?24	CLR	,U		Indicate end of list
?25	RTS
*00000
