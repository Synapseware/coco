#include "keyboard.h"
#include "coco3.h"

volatile uint8_t	kbd_data_in;		// data received from kbd
volatile uint8_t	kbd_data_out;		// data to send to kbd
volatile uint16_t	kbd_status;			// running status of keyboard
volatile uint8_t	parity;				// parity sum
volatile uint8_t	is_up;				// 
volatile uint8_t	is_break;			// 
volatile uint8_t	char_waiting;		// character waiting from kbd
volatile uint8_t	started;			// data transaction in progress
volatile uint8_t	sending;			// sending data
volatile uint8_t	bit_count;			// bit count for tx/rx
volatile uint8_t	mode;				// 0 = RX, 1 = TX


//------------------------------------------------------------------------------------------
// setup keyboard functions
//------------------------------------------------------------------------------------------
void kb_init (void)
{
	// read from kbd values
	kbd_data_in = 0;
	kbd_data_out = 0;
	kbd_status = KBD_CAPSLOCK | KBD_NUMLOCK;
	char_waiting = 0;
	started = 0;
	sending = 0;
	bit_count = 0;

	// decode kbd values
	is_up = 0;
	is_break = 0;

	// mode values
	mode = RECEIVING;

	DDRB |= (1<<PB4);	// set caps lock LED to output
	DDRC |= (1<<PC3);	// set send LED to output
	PORTC |= (1<<PC3);	// turn LED off

	// to set a pin as input, write a 0 to the
	// corresponding DDRx bit

	// set clk & dat as input
	DDRC &= ~(1<<KBDCLK);
	DDRC &= ~(1<<KBDDAT);

	// turn on pullup resistors
	PORTC |= (1<<KBDCLK);
	PORTC |= (1<<KBDDAT);

	// enable PIN Change Interrupt 1 - This enables interrupts on pins
	// PCINT14...8 see p68 of datasheet
	PCICR |= (1<<PCIE1);

	// set the mask on Pin change interrupt 1 so that only KBDINT (KBDCLK) triggers
	// the interrupt. see p71 of datasheet
	PCMSK1 |= (1<<KBDINT);
}

// special break key sequence
uint8_t brkseq[8] PROGMEM = 
{
	0xE1, 0x14, 0x77, 0xE1, 0xF0, 0x14, 0xF0, 0x77
};

//------------------------------------------------------------------------------------------
// reads data from the keyboard
//------------------------------------------------------------------------------------------
ISR(PCINT1_vect)
{
	// make sure clock line is low, if not ignore this transition
	if (PINC & (1<<KBDCLK))
		return;

	// take action based on the mode value
	(RECEIVING == mode)
		? isr_receive()
		: isr_send();
}

//------------------------------------------------------------------------------------------
// receives data from the keyboard
//------------------------------------------------------------------------------------------
void isr_receive()
{
	//if we have not started, check for start bit on DATA line
	if (!started)
	{
		if ((PINC & (1<<KBDDAT)) == 0)
		{
			started = 1;
			bit_count = 0;
			kbd_data_in = 0;
			return;
		}
	}
	else if (bit_count < 8)
	{
		//we started, read in the new bit
		//put a 1 in the right place of kdb_data if data pin is high, leave
		//a 0 otherwise
		if (PINC & (1<<KBDDAT))
			kbd_data_in |= (1<<bit_count);

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

		// signal char available
		char_waiting = 1;
	}
}

//------------------------------------------------------------------------------------------
// sends data to the keyboard
//------------------------------------------------------------------------------------------
void isr_send()
{
	if (!started)
	{
		// syncro bit received
		started = 1;
		parity = 0;
		bit_count = 0;
		return;
	}
	
	if (bit_count < 8)
	{
		// send data
		if (kbd_data_out & (1 << bit_count))
		{
			DDRC |= (1<<KBDDAT);	// logical 1
			parity ^= 1;
		}
		else
			DDRC &= ~(1<<KBDDAT);	// logical 0

		bit_count++;
		return;
	}
	
	if (bit_count == 8)
	{
		// send odd parity bit
		parity ^= 1;
		if (parity)
			DDRC |= (1<<KBDDAT);
		else
			DDRC &= ~(1<<KBDDAT);

		bit_count++;
		return;
	}
	
	if (bit_count == 9)
	{
		// set stop bit
		DDRC &= ~(1<<KBDDAT);		// release the data line
		PORTC |= (1<<KBDDAT);

		bit_count++;
		return;
	}
	
	if (bit_count == 10)
	{
		sending = 0;
		return;
	}
}

//------------------------------------------------------------------------------------------
// decodes the data byte from the keyboard
//------------------------------------------------------------------------------------------
void decode_kb(uint8_t scancode)
{
	// check for remainder of break sequence
	if (is_break > 0 && is_break < 8)
	{
		// We got into this condition because an E1 appeared from the keyboard.
		// Start checking the long break button sequence (E1, 14, 77, E1, F0, 14, F0, 77)
		//                                                0   1   2   3   4   5   6   7
		// is_break acts as an index into the break sequence array
		if (scancode == pgm_read_byte (&brkseq [is_break]))
		{
			// move to next break byte in pre-coded sequence
			is_break++;
		}
		else
		{
			// we got a byte from the keyboard that didn't match the break sequence, so quit
			is_break = 0;
		}

		// check for completion of break sequence
		if (is_break == 8)
		{
			// we got a complete break sequence, send break key
			coco3_break ();
			// terminate break key processing
			is_break = 0;
		}

		// stop processing because this is a break sequence
		return;
	}

	// process special characters
	switch (scancode)
	{
	case 0xAA:			// BAT passed
		kbd_status |= KBD_BAT_OK;
		break;
	case 0xFF:			// error
		// reset?
		break;
	case 0xFA:			// acknowledge
		kbd_status |= KBD_ACK;
		break;
	case 0xE0:			// E0 always preceeds extchar group characters, but is not meant to be preserved
		kbd_status |= KBD_EXTENDED;
		break;
	case 0xE1:			// break sequence starts with E1
		is_break = 1;	// set is_break and return -> starts break-sequence
		break;
	case 0xF0:			// F0 only received on key-up
		is_up++;		// set is_up and return, wait for next byte
		break;
	case 0x12:			// shift keys
	case 0x59:
		kbd_status = (is_up > 0)
			? kbd_status & ~KBD_SHIFT
			: kbd_status | KBD_SHIFT;
		break;
	case 0x11:			// alt keys
		kbd_status = (is_up > 0)
			? kbd_status & ~KBD_ALT
			: kbd_status | KBD_ALT;
		break;
	case 0x14:			// ctrl keys
		kbd_status = (is_up > 0)
			? kbd_status & ~KBD_CTRL
			: kbd_status | KBD_CTRL;
		break;
	case 0x77:			// num lock
		if (is_up == 0)
		{
			kbd_status ^= KBD_NUMLOCK;
			kb_update_leds();
		}
		break;
	case 0x58:			// caps lock
		if (is_up == 0)
		{
			kbd_status ^= KBD_CAPSLOCK;
			kb_update_leds ();
			//coco3_capslock ();
		}
		break;
	default:
		if (is_up == 0)
		{
			// send keystroke to coco3
			//coco3_keystroke (scancode, kbd_status);
			// clear the ext bit
			kbd_status &= ~KBD_EXTENDED;
			return;
		}

		// clear the is_up flag
		is_up--;
		break;
	}
}

//------------------------------------------------------------------------------------------
// send data to the keyboard
//------------------------------------------------------------------------------------------
void kb_send (uint8_t value)
{
	/*
	http://www.computer-engineering.org/index.php?title=PS/2_Mouse/Keyboard_Protocol
	Host to Keyboard
	The Host to Keyboard Protocol is initiated by taking the KBD data line low. However to prevent the keyboard from sending data at
	the same time that you attempt to send the keyboard data, it is common to take the KBD Clock line low for more than 60us. This
	is more than one bit length. Then the KBD data line is taken low, while the KBD clock line is released.

	The keyboard will start generating a clock signal on it's KBD clock line. This process can take up to 10mS. After the first
	falling edge has been detected, you can load the first data bit on the KBD Data line. This bit will be read into the keyboard on
	the next falling edge, after which you can place the next bit of data. This process is repeated for the 8 data bits. After the
	data bits come an Odd Parity Bit.

	Once the Parity Bit has been sent and the KBD Data Line is in an idle (High) state for the next clock cycle, the keyboard will
	acknowledge the reception of the new data. The keyboard does this by taking the KBD Data line low for the next clock transition.
	If the KBD Data line is not idle after the 10th bit (Start, 8 Data bits + Parity), the keyboard will continue to send a KBD
	Clock signal until the KBD Data line becomes idle.
	*/

	// disable interrupts on the clock pin
	PCMSK1 &= ~(1<<KBDINT);
	PORTC &= ~(1<<PC3);		// turn send LED on
	COCO3_MATRIX_PORT = 0xFF ^ value;
	COCO3_MSB_HIGH;
	COCO3_MSB_LOW;

	mode = SENDING;
	sending = 1;

	// setup the data value we are going to send
	kbd_data_out = 0xff ^ value;

	//
	// start send cycle
	//

	// step 2
	PORTC &= ~(1<<KBDDAT);		// pull data low
	DDRC |= (1<<KBDDAT);		// set data as output
	NOP;
	NOP;
	NOP;

	// step 3
	//DDRC &= ~(1<<KBDCLK);		// set clock as input
	PORTC |= (1<<KBDCLK);		// turn on pullup resistor

	// step 4
	PCMSK1 |= (1<<KBDINT);		// enable interrupts on the clock pin

	// wait for send to complete
	while (sending > 0)
	{}

	// send complete
	mode = RECEIVING;
	DDRC &= ~(1<<KBDDAT);		// set data as input
	PORTC |= (1<<KBDDAT);		// turn on pullup resistor

	PORTC |= (1<<PC3);			// turn send LED off
}

//------------------------------------------------------------------------------------------
// updates the status LEDs on the keyboard
//------------------------------------------------------------------------------------------
void kb_update_leds ()
{
/*
0xED - Write LEDs
This command is followed by a byte indicating the desired LEDs setting.
Bits 7-3: unused [0]
Bit 2: CapsLock LED state. [1]=On [0]=Off.
Bit 1: NumLock LED state. [1]=On [0]=Off.
Bit 0: ScrollLock LED state. [1]=On [0]=Off. 
*/

	uint8_t status = 0;
	if (kbd_status & KBD_CAPSLOCK)
	{
		status |= (1<<2);
		PORTB &= ~(1<<PB4);	// turn on caps lock LED
	}
	else
		PORTB |= (1<<PB4);	// turn on caps lock LED

	if (kbd_status & KBD_NUMLOCK)
		status |= (1<<1);
	if (kbd_status & KBD_SCROLL)
		status |= (1<<0);

	kb_send (0xED);			// send 0xED command
	read_char();			// read the ack byte
	kb_send (status);		// send status bits
	read_char();			// read the ack byte
}

//------------------------------------------------------------------------------------------
// reads a character from the keyboard
//------------------------------------------------------------------------------------------
uint8_t read_char()
{
	//wait for a character
	while (!char_waiting)
	{}
	char_waiting = 0;
	COCO3_MATRIX_PORT = 0xFF ^ kbd_data_in;
	COCO3_LSB_HIGH;
	COCO3_LSB_LOW;
	return kbd_data_in;
}

//------------------------------------------------------------------------------------------
// main func
//------------------------------------------------------------------------------------------
int main ()
{
	// setup global values
	kb_init ();

	// setup the coco3 matrix hardware
	coco3_init ();
	COCO3_MTX_ON;

	sei();

	// wait for keyboard to complete it's self test
	uint8_t data = read_char();
	decode_kb(data);

	// set status lights on
	//kb_update_leds ();

	// setup timer event for driving data?
	//		do we push data on a timer, and then queue up
	//		additional keystrokes?  how much data do we hold?

	while (1)
	{
		// capture the keyboard data value in a local variable
		data = read_char();

		// decode the keyboard data
		decode_kb(data);
	}

	return 0;
}
