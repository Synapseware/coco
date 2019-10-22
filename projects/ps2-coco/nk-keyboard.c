// keyboard.c
// for NerdKits with ATmega168
// hevans@nerdkits.com
//
// Designed for use with the USB NerdKit running with ATMega168. Datasheet page
// numbers refer to ATMega168 datasheet.

#define F_CPU 14745600

#include <stdio.h>

#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include <inttypes.h>

#include "../libnerdkits/delay.h"
#include "../libnerdkits/lcd.h"
#include "../libnerdkits/uart.h"
#include "keymap.h"

//Keyboard pin out
//Green - pin 5 - clock
//Yellow - pin 3 - GND
//White - pin 1 - data
//Red - pin 4 - VCC

//PIN configuration
//PC4 (PCINT12) -  CLK
//PC2           -  DATA

volatile uint8_t kbd_data;
volatile uint8_t char_waiting;
uint8_t started;
uint8_t bit_count;
uint8_t shift;
uint8_t caps_lock;
uint8_t extended;
uint8_t release;

ISR(PCINT1_vect)
{
	//make sure clock line is low, if not ignore this transition
	if (PINC & (1<<PC4))
		return;

	//if we have not started, check for start bit on DATA line
	if (!started)
	{
		if ((PINC & (1<<PC2)) == 0)
		{
			started = 1;
			bit_count = 0;
			kbd_data = 0;
			return;
		}
	}
	else if (bit_count < 8)
	{
		//we started, read in the new bit
		//put a 1 in the right place of kdb_data if PC2 is high, leave
		//a 0 otherwise
		if (PINC & (1<<PC2))
			kbd_data |= (1<<bit_count);

		bit_count++;
		return;
	}
	else if (bit_count == 8)
	{
		//pairty bit 
		//not implemented
		bit_count++;
		return;
	}
	else
	{
		//stop bit
		//should check to make sure DATA line is high, what to do if not?
		started = 0;
		bit_count = 0;
	}

	if (kbd_data == 0xF0)
	{
		//release code
		release = 1;
		kbd_data = 0;
		return;
	}
	else if (kbd_data == 0x12)
	{
		//hanlde shift key
		if(release == 0)
		{
			shift = 1;
		}
		else
		{
			shift = 0;
			release = 0;
		}
		return;
	}
	else
	{
		//not a special character
		if (release)
		{
			//we were in release mode - exit release mode
			release = 0;
			//ignore that character
		}
		else
		{
			char_waiting = 1;
		}
	}
}

char render_scan_code(uint8_t data)
{
	char to_ret = pgm_read_byte(&(keymap[data])); //grab character from array
	if (shift)
	{
		to_ret -= 0x20;
	}
	return to_ret;
}

uint8_t read_char()
{
	//wait for a character
	while (!char_waiting)
	{}
	char_waiting = 0;
	return kbd_data;
}

void init_keyboard()
{
	started = 0;
	kbd_data = 0;
	bit_count = 0;

	//make PC4 input pin
	//DDRC &= ~(1<<PC4);
	//turn on pullup resistor
	PORTC |= (1<<PC4);

	//Enable PIN Change Interrupt 1 - This enables interrupts on pins
	//PCINT14...8 see p70 of datasheet
	PCICR |= (1<<PCIE1);
  
	//Set the mask on Pin change interrupt 1 so that only PCINT12 (PC4) triggers
	//the interrupt. see p71 of datasheet
	PCMSK1 |= (1<<PCINT12);
}

int main()
{
	//fire up the LCD
	lcd_init();
	FILE lcd_stream = FDEV_SETUP_STREAM(lcd_putchar, 0, _FDEV_SETUP_WRITE);
	lcd_home();

	uart_init();
	FILE uart_stream = FDEV_SETUP_STREAM(uart_putchar, uart_getchar, _FDEV_SETUP_RW);
	stdin = stdout = &uart_stream;

	init_keyboard(); 
  
	//enable interrupts
	sei();

	//debug LED - output
	DDRC |= (1<<PC3);

	uint8_t key_code = 0;

	char str_buf[21];
	uint8_t buf_pos = 0;
	str_buf[0] = str_buf[1] = 0x00;
	while(1)
	{
		if(char_waiting)
		{
			key_code = read_char();
			if (key_code == 0x5A)
			{
				// enter key, clear the line
				buf_pos = 0;
				str_buf[0] = str_buf[1] = 0x00;
			}
			else if (key_code == 0x66)
			{
				//backspace
				buf_pos--;
				str_buf[buf_pos] = 0x00;
			}
			else
			{
				str_buf[buf_pos] = render_scan_code(key_code);
				buf_pos++;
				str_buf[buf_pos] = 0x00;
			}
		} 
 
		lcd_home();
		fprintf_P(&lcd_stream,PSTR("%-20s"),str_buf);
   
		if (shift)
		{
			lcd_line_four();
			fprintf_P(&lcd_stream,PSTR("SHIFT"));
		}
		else
		{
			lcd_line_four();
			fprintf_P(&lcd_stream,PSTR("          "));
		}
	}
  
	return 0;
}
