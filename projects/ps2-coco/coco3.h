#ifndef COCO3_H
#define COCO3_H

#define F_CPU 14745600

#include <stdio.h>

#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include <inttypes.h>


#define COCO3_MATRIX_DDR			DDRD
#define	COCO3_MATRIX_PORT			PORTD

#define COCO3_CTRL_DDR				DDRB
#define COCO3_CTRL_PORT				PORTB
#define COCO3_CTRL_MSB_BIT			PB2
#define COCO3_CTRL_LSB_BIT			PB3
#define COCO3_CTRL_ENABLE			PB1


// helpers
#define COCO3_MTX_ON				COCO3_CTRL_PORT &= ~_BV(COCO3_CTRL_ENABLE)
#define COCO3_MTX_OFF				COCO3_CTRL_PORT |= _BV(COCO3_CTRL_ENABLE)
#define COCO3_MSB_HIGH				COCO3_CTRL_PORT |= _BV(COCO3_CTRL_MSB_BIT)
#define COCO3_MSB_LOW				COCO3_CTRL_PORT &= ~_BV(COCO3_CTRL_MSB_BIT)
#define COCO3_LSB_HIGH				COCO3_CTRL_PORT |= _BV(COCO3_CTRL_LSB_BIT)
#define COCO3_LSB_LOW				COCO3_CTRL_PORT &= ~_BV(COCO3_CTRL_LSB_BIT)

// global keyboard map values
extern uint8_t group1_len;
extern uint8_t group1[67][4];
extern uint8_t group2_len;
extern uint8_t group2[15][4];
extern uint8_t group3_len;
extern uint8_t group3[7][4];

// define kbd matrix structure
typedef struct
{
	uint8_t msb;
	uint8_t lsb;
	uint8_t asc;
} kbd_matrix;

volatile uint8_t counter;



// the coco3 data port is the 8-bit register that writes the matrix values to one of 2 latches
// the matrix_msb and matrix_lsb pins are the latch selectors
// the matrix_strobe enables the latch output for a specified amount of time
// the keys to be sent to the coco3 are kept in a FIFO stack, implemented in software
// a timer event pushes the keys to the coco3 so there is enough time for the machine to process the keystrokes

// intialize the coco3 matrix hardware
void coco3_init(void);

// maps a scan code to a coco3 lookup table and queues the keystroke
void coco3_keystroke (uint8_t scancode, uint16_t status);

// sends the break key press to the coco3
void coco3_break ();

// sends the caps lock key press to the coco3
void coco3_capslock ();

// writes a matrix value to the coco3 keyboad matrix hardware
void coco3_write_matrix (kbd_matrix matrix);

// maps the scan code to an msb/lsb combo - returns 0 for no matches
uint8_t coco3_map_scancode (uint8_t scancode, uint16_t status, kbd_matrix * matrix);

#endif
