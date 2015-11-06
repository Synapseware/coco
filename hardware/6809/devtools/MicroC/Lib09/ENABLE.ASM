* Enable main interrupt: enable()
enable	ANDCC	#%11101111	Clear IRQ mask
	RTS
* Disable main interrupt: disable()
disable	ORCC	#%00010000	Set IRQ mask
	RTS
* Enable fast interrupt: enablef()
enablef	ANDCC	#%10111111	Clear FIRQ mask
	RTS
* Disable fast interrupt: disablef()
disablef ORCC	#%01000000	Set FIRQ mask
	RTS
*00000
