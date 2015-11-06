* Setups of video display
* Has numerous utility functions


VIDEO namespace 

TEXT_MODE			fcb		1
VIDEO_HRES			fcb		1
VIDEO_VRES			fcb		1


VIDEO_MODE			equ		$FF98
VIDEO_RES			equ		$FF99
VIDEO_BRDR_CLR		equ		$FF9A
VIDEO_VRT_SCRL		equ		$FF9C
VIDEO_VRT_OFFST_MSB	equ		$FF9D	(start of video ram * 2048)
VIDEO_VRZ_OFFST_LSB	equ		$FF9E	(start of video ram * 8)
VIDEO_HRZ_OFFSET	equ		$FF9F	(horizontal offset)

VIDEO_MODES			fcb		0,9,18,4,13,22,8,17,26,12,21,30,16,25,20,29


*--------------------------------------------------------------------------------
* Sets up the view port
*--------------------------------------------------------------------------------
SetupGfx	proc	vrez:byte,hrez:byte,start:word
	begin SetupGfx
			lda			#%10000000
			sta			VIDEO_MODE

			ldb			vrez,u
			aslb
			aslb
			aslb
			aslb
			aslb

			lda			hrez,u
			ldx			#VIDEO_MODES
			orb			x,a

			stb			VIDEO_RES
			
			rts

	endproc


 endname


*--------------------------------------------------------------------------------
* Video Documentation:
*
*  FF98	 - video mode register
*	7	- 1 = gfx, 0 = text
*	6	- n/a
*	5	- 1 = invert color phase
*	4	- 1 = monochrome on composite
*	3	- 1 = 50 hz, 0 = 60 hz
*	Bits 2-0	Lines Per Row
*	  2 1 0		LPR
*	  0 0 x		1
*	  0 1 0		2
*	  0 1 1		8
*	  1 0 0		9
*	  1 0 1		10
*	  1 1 0		11
*	  1 1 1		*infinte
*
*
*  Video Mode - Vertical Res		Bits 6-5	Value
*	 Ordinal	Vrt Rez				65
*		 0		192 scan lines		00			0
*		 1		200 scan lines		01			32
*		 2		unused				10			64
*		 3		225 scan lines		11			96
*
*
*  Text Modes	Character Width		Bits 4-0	Value	Page Size
*	 Ordinal	Hrz Res				43210		(dec)
*		 0		32 x 16				00001		 1		 512
*		 1		40 x 25				00101		 5		1000
*		 2		64 x 25				10001		17		1600
*		 3		80 x 25				10101		21		2000
*
*
*  Video Mode - Hor Res				Bits 4-0	Value	Page Size/scan lines
*	Ordinal		Horz Res			43210		(dec)	  192	  200	  225
*		 0		128 x 2 color		00000		 0		 3072	 3200	 3600
*		 1		128 x 4 color		01001		 9		 6144	 6400	 7200
*		 2		128 x 16 color		10010		18		12288	12800	14400
*		 3		160 x 2 color		00100		 4		 3840	 4000	 4500
*		 4		160 x 4 color		01101		13		 7680	 8000	 9000
*		 5		160 x 16 color		10110		22		15360	16000	18000
*		 6		256 x 2 color		01000		 8		 6144	 6400	 7200
*		 7		256 x 4 color		10001		17		12288	12800	14400
*		 8		256 x 16 color		11010		26		24576	25600	28800
*		 9		320 x 2 color		01100		12		 7680	 8000	 9000
*		10		320 x 4 color		10101		21		15360	16000	18000
*		11		320 x 16 color		11110		30		30720	32000	36000
*		12		512 x 2 color		10000		16		12288	12800	14400
*		13		512 x 4 color		11001		25		24576	25600	28800
*		14		640 x 2 color		10100		20		15360	16000	18000
*		15		640 x 4 color		11101		29		30720	32000	36000
*
*
*  Palette Registers - looks at bits 5-0 (6 bit color)
*		FFB0	- color 0
*		FFB1	- color 1
*		 .....
*		FFBF	- color 15






