/*
    2-19-2008
    Copyright Spark Fun Electronics© 2008
    Nathan Seidle
    nathan at sparkfun.com
    
	Keyboard PS/2 Interpreter
	
	http://www.computer-engineering.org/ps2protocol/
	
	Original Fuses : avrdude -p atmega8 -P lpt1 -c stk200 -U lfuse:w:0xE1:m -U hfuse:w:0xD9:m
	16MHz Fuses : avrdude -p atmega8 -P lpt1 -c stk200 -U lfuse:w:0xEE:m -U hfuse:w:0xC9:m
	
	Board uses the internal 1MHz clock
*/

#include <stdio.h>
#include <avr/io.h>

#define FOSC 1000000 //1MHz internal osc
#define BAUD 9600
#define MYUBRR (((((FOSC * 10) / (16L * BAUD)) + 5) / 10) - 1)

#define sbi(var, mask)   ((var) |= (uint8_t)(1 << mask))
#define cbi(var, mask)   ((var) &= (uint8_t)~(1 << mask))

#define STAT_LED	5 //PORTC

#define CLK_IN		2 //PORTB
#define DATA_IN		1 //PORTC

#define CLK_OUT		2 //PORTC
#define DATA_OUT	3 //PORTC

//Define functions
//======================
void ioinit(void);      //Initializes IO
void delay_ms(uint16_t x); //General purpose delay
void delay_us(uint8_t x);

static int uart_putchar(char c, FILE *stream);
static FILE mystdout = FDEV_SETUP_STREAM(uart_putchar, NULL, _FDEV_SETUP_WRITE);

uint8_t scan_keyboard(void);
uint8_t send_to_keyboard(uint8_t outgoing_byte);

uint8_t scan_computer(void);
void send_to_computer(uint8_t outgoing_byte);

void send_ps2_string(const char * outgoing_string);
void lookup_ps2_key(uint8_t incoming_character);
void display_info(uint32_t key_presses);
//======================

int main (void)
{
	uint8_t incoming_computer_byte, incoming_keyboard_byte;
	uint8_t checker = 0;
	uint32_t key_counter = 0;

	ioinit();

	while(1)
	{
		//Look for incoming commands from computer
		if( (PINC & (1<<CLK_OUT)) == 0) //Computer is pulling clock low to indicate Host-To-Device communication
		{
			sbi(PORTC, STAT_LED);

			incoming_computer_byte = scan_computer(); //Get command from computer			
			
			if(incoming_computer_byte == 0xFF) //Computer is requesting keyboard reset
			{
				delay_ms(1);
				send_to_computer(0xFA); //Ack the reset command
				delay_ms(5);
				send_to_computer(0xAA); //Send out that we are alive and well
			}
			else if(incoming_computer_byte != 0) 
			{
				send_to_keyboard(incoming_computer_byte); //Send this command to the keyboard
			}
			
			cbi(PORTC, STAT_LED);
		}
		
		//Look for incoming keys from keyboard
		if( (PINB & (1<<CLK_IN)) == 0) //Check to see if clock line is low
		{
			sbi(PORTC, STAT_LED);

			incoming_keyboard_byte = scan_keyboard(); //Spend 500us looking for incoming key board presses
			if(incoming_keyboard_byte != 0) 
			{
				//Inhibit keyboard from sending anything else
				DDRB |= (1<<CLK_IN); //Take control of clock (1 = output, 0 = input)
				cbi(PORTB, CLK_IN); //Inhibit clock line

				send_to_computer(incoming_keyboard_byte); //Send this keypress to the computer

				key_counter++; //Keep track of key presses
				
				//Check to see if we need to display the informational text
				if(incoming_keyboard_byte == 0x0E)
					checker++;
				else if(incoming_keyboard_byte != 0xF0)
					checker = 0;

				if(checker == 6) //We've seen 3 of the ` characters go by, now display info
				{
					checker = 0;

					display_info(key_counter); 
				}

				//Send a super annoying key to computer at various times
				/*if( (key_counter % 300) == 0)
				{
					send_to_computer(0x66); //Back space
					delay_ms(1);
					send_to_computer(0xF0); //Release
					delay_ms(1);
					send_to_computer(0x66); //Back space
				}*/

				//Release clock so that the keyboard can send us another command
				DDRB &= ~(1<<CLK_IN); //Release control of clock (1 = output, 0 = input)
				sbi(PORTB, CLK_IN); //Release clock line
			}
			
			cbi(PORTC, STAT_LED);
		}
	}

    return(0);
}

//Sends the current key count information to the computer
//This 'll print keys in whatever application you have open
//Very fun
void display_info(uint32_t key_presses)
{
	uint8_t i, digit;
	char digit_string[10];
	
	for(i = 0 ; i < 9 ; i++) digit_string[i] = '0';
	digit_string[9] = '\0';
	
	send_ps2_string(" Key presses today: ");
	
	//Okay so this is actually a rough guess. When you press a key, there is the key and 2-ish break commands
	//So let's divide by 3 to get total keys pressed
	key_presses /= 3;
	
	for(i = 8 ; key_presses > 0 ; i--)
	{
		digit = key_presses % 10;
		digit_string[i] = digit + '0';

		key_presses = key_presses / 10;
	}
	
	send_ps2_string(digit_string);
}

//Send string out PS2 port
void send_ps2_string(const char * outgoing_string)
{
	uint8_t i = 0;
	
	while(outgoing_string[i] != '\0')
	{
		lookup_ps2_key(outgoing_string[i]);
		i++;
	}
}

//Takes an ASCII value as input and sends out the given keyboard PS2 commands
void lookup_ps2_key(uint8_t incoming_character)
{
	uint8_t make, break0, break1, break2;
	uint8_t upper_case = 0;

	make = 0;
	break0 = 0;
	break1 = 0;
	break2 = 0;

	if(incoming_character >= 'A' && incoming_character <= 'Z')
	{
		upper_case = 1;
		incoming_character += ('a' - 'A'); //Make a upper case letter a lower case letter
	}

	switch(incoming_character)
	{
		case 'a': make = 0x1C; break;
		case 'b': make = 0x32; break;
		case 'c': make = 0x21; break;
		case 'd': make = 0x23; break;
		case 'e': make = 0x24; break;
		case 'f': make = 0x2B; break;
		case 'g': make = 0x34; break;
		case 'h': make = 0x33; break;
		case 'i': make = 0x43; break;
		case 'j': make = 0x3B; break;
		case 'k': make = 0x42; break;
		case 'l': make = 0x4B; break;
		case 'm': make = 0x3A; break;
		case 'n': make = 0x31; break;
		case 'o': make = 0x44; break;
		case 'p': make = 0x4D; break;
		case 'q': make = 0x15; break;
		case 'r': make = 0x2D; break;
		case 's': make = 0x1B; break;
		case 't': make = 0x2C; break;
		case 'u': make = 0x3C; break;
		case 'v': make = 0x2A; break;
		case 'w': make = 0x1D; break;
		case 'x': make = 0x22; break;
		case 'y': make = 0x35; break;
		case 'z': make = 0x1A; break;

		case '0': make = 0x45; break;
		case '1': make = 0x16; break;
		case '2': make = 0x1E; break;
		case '3': make = 0x26; break;
		case '4': make = 0x25; break;
		case '5': make = 0x2E; break;
		case '6': make = 0x36; break;
		case '7': make = 0x3D; break;
		case '8': make = 0x3E; break;
		case '9': make = 0x46; break;

		case ' ': make = 0x29; break0 = 1; break;
		case ':': make = 0x4C; break0 = 1; upper_case = 1; break;
	}

	//Most of the characters have the same break codes as the make code
	if( (break0 == 1) | (incoming_character >= 'A' && incoming_character <= 'Z') | (incoming_character >= 'a' && incoming_character <= 'z') | (incoming_character >= '0' && incoming_character <= '9'))
	{
		break0 = 0xF0;
		break1 = make;
	}
	
	if(upper_case) //Throw a shift before the letter
	{
		send_to_computer(0x12); //Right shift cause left handed people rock
		delay_ms(1);
	}

	send_to_computer(make);
	delay_ms(1);

	send_to_computer(break0);
	delay_ms(1);

	send_to_computer(break1);
	delay_ms(1);
	
	if (break2 != 0)
	{
		send_to_computer(break2);
		delay_ms(4);
	}

	if(upper_case) //Throw a shift break after the letter
	{
		send_to_computer(0xF0);
		delay_ms(1);

		send_to_computer(0x12);
		delay_ms(1);
	}
}

//Send command to keyboard
//Data is latched when clock is high. This is opposite from reading from keyboard.
uint8_t send_to_keyboard(uint8_t outgoing_byte)
{
	uint8_t incoming_byte, i, parity;
	incoming_byte = 0;
	parity = 0;

    //1 = output, 0 = input
    DDRB |= (1<<CLK_IN); // (CLK_IN on PB2) Take over clock_in
    DDRC |= (1<<DATA_IN); // (DATA_IN on PC1) Take over data_in
	
	cbi(PORTB, CLK_IN); //Pull clock line low for at least 100us
	delay_us(100);
	cbi(PORTC, DATA_IN); //Pull data line low
	delay_us(5);
	
	//Release clock line
	DDRB &= ~(1<<CLK_IN); // (CLK_IN on PB2) Release clock_in
	PORTB = (1<<CLK_IN); //Enable pull-up on PB2
	
	//Wait for device to bring clock line low
	i = 0;
	while(PINB & (1<<CLK_IN))
	{
		i++;
		if(i == 0) return (0); //Error
		delay_us(1);
	}
	
	//We should now have control of the data line starting with first data bit
	for(i = 0 ; i < 9 ; i++)
	{
		delay_us(20); //Wait for middle of clock high

		if(i == 8) //Parity bit!
		{
			//Figure out parity bit
			parity ^= 1; //The final toggle
			if(parity)
				sbi(PORTC, DATA_IN);
			else
				cbi(PORTC, DATA_IN);
		}
		else //Normal bits
		{
			if( (outgoing_byte & 0x01) == 1)
			{
				sbi(PORTC, DATA_IN);
				parity ^= 1;
			}
			else
				cbi(PORTC, DATA_IN);

			outgoing_byte >>= 1; //Rotate outgoing data byte
		}

		while( (PINB & (1<<CLK_IN)) == 0); //Wait for device to bring clock line high
		while( (PINB & (1<<CLK_IN)) ); //Wait for device to bring clock line low
	}

	//Release data line and check for ACK
    //1 = output, 0 = input
    DDRC &= ~(1<<DATA_IN); // (DATA_IN on PC1) Take over data_in
	PORTC |= (1<<DATA_IN); //Enable pull-up on DATA_IN

	delay_us(10); //Wait a bit for keyboard to settle the data_in line

	while( (PINC & (1<<DATA_IN)) ); //Wait for device to bring data line low
	while( (PINB & (1<<CLK_IN)) ); //Wait for device to bring clock line low

	delay_us(2); //Wait a bit for keyboard to settle the data_in line
	
	char ack = 0;
	if( (PINC & (1<<DATA_IN)) == 0) ack = 1; //We have ack!

	while( (PINB & (1<<CLK_IN)) == 0); //Wait for device to bring clock line high
	while( (PINC & (1<<DATA_IN)) == 0); //Wait for device to bring data line high
	
	return(ack);
}

//Reads incoming command from computer
uint8_t scan_keyboard(void)
{
	uint8_t incoming_byte, i, parity;

	//We might be in a weird state so make sure we are not looking at previous byte
	while( (PINB & (1<<CLK_IN)) == 0); //Wait for clock line to go high

	incoming_byte = 0;

	parity = 0;
	
	for(i = 0 ; i < 9 ; i++)
	{
		while( (PINB & (1<<CLK_IN)) ); //Wait for clock line to go low

		if(i == 8) //Parity bit
		{
			//Figure out parity bit
			parity ^= 1; //Final toggle
			if( (PINC & (1<<DATA_IN)) && parity) 
				; //Data is good
			else if ( ((PINC & (1<<DATA_IN)) == 0) && (parity == 0) )
				; //Data is good
			else
				incoming_byte = 0; //Return error code	
		}
		else
		{
			incoming_byte >>= 1; //Rotate incoming_byte
			if( PINC & (1<<DATA_IN) ) 
			{
				parity ^= 1;
				incoming_byte |= 0x80; //Record any incoming data
			}
		}
		
		while( (PINB & (1<<CLK_IN)) == 0); //Wait for clock line to go high
	}
	
	//Read stop bit
	while( (PINB & (1<<CLK_IN)) ); //Wait for clock line to go low
	while( (PINB & (1<<CLK_IN)) == 0); //Wait for clock line to go high

	return(incoming_byte);
}

//Polls the clock out line for incoming comm from computer
//Returns 0 if nothing is heard from computer
uint8_t scan_computer(void)
{
	uint8_t incoming_byte, parity;
	uint16_t i;

	//Bus should be in computer's control at this point

	incoming_byte = 0;

	while( (PINC & (1<<CLK_OUT)) == 0); //Wait for computer to release clock (and control of bus)

	delay_us(40); //Start bit

	DDRC |= (1<<CLK_OUT); //Take back control of clock (1 = output, 0 = input)
	
	parity = 0;
	
	for(i = 0 ; i < 9 ; i++)
	{
		cbi(PORTC, CLK_OUT); //Drive clock low
		delay_us(40); //12.5kHz clock
		sbi(PORTC, CLK_OUT); //Drive clock high
		delay_us(5); //Wait for data to stablize

		if(i == 8) //Parity bit
		{
			//Figure out parity bit
			parity ^= 1; //Final toggle
			if( (PINC & (1<<DATA_OUT)) && parity) 
				; //Data is good
			else if ( ((PINC & (1<<DATA_OUT)) == 0) && (parity == 0) )
				; //Data is good
			else
				incoming_byte = 0; //Return error code	
		}
		else
		{
			incoming_byte >>= 1;
			if( PINC & (1<<DATA_OUT) )
			{
				parity ^= 1;
				incoming_byte |= 0x80; //Read data
			}		
		}
		delay_us(35); //Remainder of 12.5kHz clock
	}

	//Stop bit
	cbi(PORTC, CLK_OUT); //Drive clock low
	DDRC |= 1<<DATA_OUT; //Take over data line
	sbi(PORTC, DATA_OUT); //Drive data high for stop bit
	delay_us(40); //12.5kHz clock
	
	//Ack
	sbi(PORTC, CLK_OUT); //Drive clock high
	delay_us(20); //Short wait
	PORTC &= ~(1<<DATA_OUT); //Drive data low for ack
	delay_us(20); //Remainder of 12.5kHz clock

	PORTC &= ~(1<<CLK_OUT); //Drive clock low
	delay_us(40); //12.5kHz clock
	PORTC |= (1<<CLK_OUT); //Drive clock high

	//Release data and clock lines so that the computer can take over clock if needed
	DDRC &= ~( (1<<CLK_OUT) | (1<<DATA_OUT) ); //Release control of clock/data (1 = output, 0 = input)
	PORTC |= (1<<CLK_OUT) | (1<<DATA_OUT); //Enable pull up on clock/data
	
	return(incoming_byte);
}

//Sends command to computer
void send_to_computer(uint8_t outgoing_byte)
{
	uint8_t parity, i;
	parity = 0;
	
	//Take over bus
	DDRC |= (1<<CLK_OUT) | (1<<DATA_OUT); //Release control of clock/data (1 = output, 0 = input)
	
	cbi(PORTC, DATA_OUT); //Pull data low for start bit
	delay_us(15);
	cbi(PORTC, CLK_OUT); //Pull clock low to start transmission
	delay_us(35); //Toggle clock at 15kHz

	for(i = 0 ; i < 10 ; i++)
	{
		sbi(PORTC, CLK_OUT); //Set clock high
		delay_us(20); //Toggle clock at 15kHz
		
		if(i == 9) //Stop bit!
		{
			sbi(PORTC, DATA_OUT); //Stop bit is data high
		}
		else if(i == 8) //Parity bit!
		{
			//Figure out parity bit
			parity ^= 1; //The final toggle
			if(parity)
				sbi(PORTC, DATA_OUT);
			else
				cbi(PORTC, DATA_OUT);
		}
		
		else //Normal bits
		{
			if( (outgoing_byte & 0x01) == 1)
			{
				sbi(PORTC, DATA_OUT);
				parity ^= 1;
			}
			else
				cbi(PORTC, DATA_OUT);

			outgoing_byte >>= 1; //Rotate outgoing data byte
		}

		delay_us(15); //Toggle clock at 15kHz

		cbi(PORTC, CLK_OUT); //Set clock low
		delay_us(35); //Toggle clock at 15kHz
	}

	//Release data and clock lines so that the computer can take over clock if needed
	DDRC &= ~( (1<<CLK_OUT) | (1<<DATA_OUT) ); //Release control of clock/data (1 = output, 0 = input)
	PORTC |= (1<<CLK_OUT) | (1<<DATA_OUT); //Enable pull up on clock/data
	
	while( (PINC & (1<<CLK_OUT)) == 0) //Wait for computer to release clock. Computer will hold clock down to inhibit bus
	{
		//If we see the data line go low, then the computer is trying to send a command
		if( (PINC & (1<<DATA_OUT)) == 0) break;
	}
}

void ioinit (void)
{
    //1 = output, 0 = input
    DDRD = 0b11111110; // (RXD on PD0)
	DDRC |= (1<<STAT_LED);
	
	//Release data and clock lines so that the computer can take over clock if needed
	DDRC &= ~( (1<<CLK_OUT) | (1<<DATA_OUT) ); //Release control of clock/data (1 = output, 0 = input)
	PORTC |= (1<<CLK_OUT) | (1<<DATA_OUT); //Enable pull up on clock/data

	//Release data and clock lines on keyboard
	DDRB &= ~(1<<CLK_IN); //Release control of clock (1 = output, 0 = input)
	PORTB |= (1<<CLK_IN); //Enable pull up on clock
	DDRC &= ~(1<<DATA_IN); //Release control of data (1 = output, 0 = input)
	PORTC |= (1<<DATA_IN); //Enable pull up on data

    //USART Baud rate: 9600
    UBRR0H = MYUBRR >> 8;
    UBRR0L = MYUBRR;
    UCSR0B = (1<<RXEN0)|(1<<TXEN0);

    stdout = &mystdout; //Required for printf init

    //Init timer 2
	//1,000,000 / 1 = 1,000,000
    TCCR2B = (1<<CS20); //Set Prescaler to 1. CS20=1
}

static int uart_putchar(char c, FILE *stream)
{
    if (c == '\n') uart_putchar('\r', stream);
  
    loop_until_bit_is_set(UCSR0A, UDRE0);
    UDR0 = c;
    
    return 0;
}

//General short delays
void delay_ms(uint16_t x)
{
	for (; x > 0 ; x--)
	{
		delay_us(250);
		delay_us(250);
		delay_us(250);
		delay_us(250);
	}
}

//General short delays
//Uses internal timer do a fairly accurate 1us
void delay_us(uint8_t x)
{
	TIFR2 = 0x01; //Clear any interrupt flags on Timer2
	
    TCNT2 = 256 - x; //256 - 125 = 131 : Preload timer 2 for x clicks. Should be 1us per click

	while( (TIFR2 & (1<<TOV2)) == 0);
}
