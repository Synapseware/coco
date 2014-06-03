GCCFLAGS=-g -Os -Wall -mmcu=atmega168 
LINKFLAGS=-Wl,-u,vfprintf -lprintf_flt -Wl,-u,vfscanf -lscanf_flt -lm
AVRDUDEFLAGS=-c avr109 -p m168 -b 115200 -P COM3
LINKOBJECTS=
#../libnerdkits/delay.o
#../libnerdkits/lcd.o ../libnerdkits/uart.o
#

all:	mapper-upload

mapper.hex: coco3.c	keyboard.c
	make -C ../libnerdkits
	avr-gcc ${GCCFLAGS} ${LINKFLAGS} -o mapper.o keyboard.c coco3.c ${LINKOBJECTS}
	avr-objcopy -j .text -O ihex mapper.o mapper.hex

mapper.ass:	mapper.hex
	avr-objdump -S -d mapper.o > mapper.ass

mapper-upload:	mapper.hex
	avrdude ${AVRDUDEFLAGS} -U flash:w:mapper.hex:a
