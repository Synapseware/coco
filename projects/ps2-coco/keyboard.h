#ifndef KEYBOARD_H
#define KEYBOARD_H

#define F_CPU 14745600

#include <stdio.h>

#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include <inttypes.h>

#include "../libnerdkits/delay.h"
//#include "../libnerdkits/lcd.h"
//#include "../libnerdkits/uart.h"


// Bits in keyboard status register
#define	KBD_SHIFT		1				/* SHIFT is held down */
#define	KBD_CTRL		2				/* CTRL is held down */
#define	KBD_ALT			4				/* ALT is held down */
#define	KBD_NUMLOCK		8				/* NUM LOCK is activated */
#define	KBD_CAPSLOCK	16				/* CAPS LOCK is activated */
#define	KBD_SCROLL		32				/* SCROLL LOCK is activated */
#define	KBD_BAT_OK		1024			/* Keyboard passed its BAT test */

#define	KBD_SEND		64				/* This and the next bits are for internal use */
#define	KBD_EX			128
#define	KBD_BREAK		256
#define	KBD_LOCKED		512
#define KBD_EXTENDED	2048
#define KBD_ACK			4068

#define KBDINT	PCINT13

#define KBDCLK	PC5
#define KBDDAT	PC4

#define SENDING 1
#define RECEIVING 0

uint8_t brkseq[8];


// Initialize keyboard routines: activate appropriate interrupts.
void kb_init (void);

// reads a data from the keyboard
ISR(PCINT1_vect);

// receives data from the keyboard
void isr_receive();

// sends data to the keyboard
void isr_send();

// decodes the data byte from the keyboard
void decode_kb (uint8_t scancode);

// sends a byte of data to the keyboard
void kb_send (uint8_t scancode);

// updates the status LEDs on the keyboard
void kb_update_leds ();

// reads a character from the keyboard
uint8_t read_char();

#endif
