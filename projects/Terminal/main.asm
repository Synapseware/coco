* Main assembly file of terminal program.
* 
* 
* 
	include serial.asm
	include video.asm

start		call	VIDEO.SetupGfx,0,0,1024

			lbsr	serial_init
@_cls		ldx		#1024
			lda		#32
			sta		,x+
			cmps	#1535
			bls		@_cls
			rts
