* QUICKER BUBBLE SORT
* this bubble sort takes into account that on each pass
* the highest value always sinks to the bottom, so we
* don't need to scan the whole screen each time, but
* rather 1 byte less on each pass

	org	$0300
BUBSRT	clr	PassNo	set pass # to 0
	ldu	#1536
bub010	leau	-1,u
	stu	eotab
	ldx	#1024	point to screen
	ldy	#0	set 'change flag' to 0 (false)
bub020	lda	,x+	get first entry
	cmpa	,x	test next
	bls	bub030
	ldb	,x	get 2nd entry
	stb	-1,x	swap b to a
	sta	,x	swap a to b
	ldy	#1	set 'change flag'
bub030	cmpx	eotab	end of data?
	bne	bub020	no, keep sorting
	inc	PassNo	increment pass #
	cmpy	#0	test 'change flag'
	bne	bub010	sort again if change occured
	rts
	org	$0400
PassNo	fcb	0	pass # (initialized to 0)
eotab	fdb	1536	end of table pointer
	end	BUBSRT