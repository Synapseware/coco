TDD43N  BIN  =  �� P� ��@ � o�� �"�C��� �"�� ���򆯗�0�� ��<4����#���� ��� 3����=�����d���U'!Z&�ƯI��F��'C'��� ���H��& �  ��� ���� ���Z&��� �UƭZ��'�s$��Z&�0&��DDD�P�� ����&�946 46��0�r��*� �� R�R���%F&
�'>0 :�
&0�  �&��  ��  %�@��� %� �� ����%��`��� %�0�����5�4��� ����� �5����� �3� ���5������ Ȗ�& `&0&������ ���'
���$����  ��� �4�@�����D�	Z&��5�4�Y���4F��& ��5F����%�5�� ����������_�_6&	v�%� 3HD$�0� �3� �3˦���X+��8�?&O9��   �� ���� F���F���� ;�� ����Z&�� ���� +�� ��ˀ���� ������ ;E
A SIUDRJNFCKTZLWHYPQOBG�MXV 3
- \87$4',!:(5")2#6019?& ./;  ��?CYNIAMZTFKOR\LXVWJEPG^S]UQ?B@?D673!*05'&8.~,#|=H?#9.)!-:4&+/2|,867*%0'~3=51?" ?$?-14)?:+/2?9(?
TDD VERSION 4  � .3
BY JOHN W. SPALDING

 �  � =TDD54   TXT� W










 TELECOMMUNICATION DEVICE FOR THE DEAF (TDD) EMULATION

 USING THE TRS-80 COLOR COMPUTER OR IBM PC/PCjr




  John W. Spalding
 1185 Collier Road, NW
! Apartment 12-F
 Atlanta, GA  30318

 CompuServe ID 73165,203

! March 17, 1985








































 TDD Emulation, Page 1


" INTRODUCTION

 Telecommunication Devices for the Deaf, usually referred to as
 TDDs or TTYs, have been in use since the early sixties.  At that
 time, the telephone company was replacing its old teletype
 machines with newer models, and made the old machines available
 at little or no cost.  A Bell Labs engineer named Robert
 Weitbrecht developed an accoustic coupler for connecting these
 machines to the telephone system.  With the proliferation of
 personal computers, there has been considerable interest in
 making TDDs and computers talk to each other.  Unfortunately
 there is not the slightest degree of compatibility between the
 two systems, as shown in the following table:

 TDD (Weitbrecht modem) Computer (Bell 103 modem)

 5-level Baudot code 7-bit ASCII code

 half-duplex full-duplex

 1400 Hz MARK 1270/2225 Hz MARK

 1800 Hz SPACE 1070/2025 Hz SPACE

 45.45 bits per second 300 bits per second (bps)

 While some computers' communication interfaces can operate at
 45.45 bps (bits per second) with a 5-bit data word, and ASCII to
 Baudot translation is fairly straightforward, the modem
 incompatibility problem cannot be solved so easily.  Commercial
 Weitbrecht modems for computers are scarce (although the Novation
 Apple-Cat II (tm) has TDD capability built in), leaving one with
 the prospect of building a modem from scratch, or modifying a
 Bell 103 type modem.

 This document describes two programs:

 TDD version 4.3 for the TRS-80 Color Computer (TDD43)
 
 TDD version 5.4 for the IBM PC/PCjr (TDD54)

 These programs eliminate the need for a Weitbrecht modem by
 performing carrier modulation/demodulation in software, passing
 the modulated carrier through the computer's cassette interface.
 The Color Computer version can burned into an EPROM and run from
 a ROM cartridge.  The IBM XT, Portable PC, AT and 3270 PC do not
 have a cassette interface and are therefore not supported.
















 TDD Emulation, Page 2


 SOFTWARE EMULATION OF THE WEITBRECHT MODEM

 The slow speed and half-duplex (one direction at a time) mode of
 the TDD would suggest that the terminal and modem functions could
 both be emulated in software.  Indeed, the TRS-80 Color Computer
 and IBM PC both support an audio cassette recorder as an I/O
 device for storing and retrieving programs, performing modulation
 and demodulation via software at a much higher speed (1500 bps)
 than that required for the TDD.  Also the existance of the Audio
 Analyzer program for the Color Computer suggested that the
 machine had ample signal processing ability.  If it were possible
 to perform the modem function within the software, then it would
 only be necessary to couple the audio signals between the
 cassette interface and the telephone line.

 The steps to transmit keystrokes are:

 1-read an ASCII character code from the keyboard.

 2-translate to Baudot code, inserting FIGS or LTRS shift
 codes as required.

 3-transmit one start bit consisting of a SPACE tone (1800
 Hz) with a 22 millisecond duration.

 4-transmit each data bit, starting with the least
 significant bit, consisting of a SPACE tone (1800 Hz)
 if the bit is 0, or a MARK tone (1400 Hz) if the bit is
 1, with a 22 millisecond duration for each bit.  This
 can be conveniently done by shifting the data byte to
 the RIGHT and testing for a carry.

 5-transmit one and one half stop bits, consisting of a
 MARK tone (1400 Hz) with a 33 millisecond duration.

 6-continue sending the MARK tone (1400 Hz) for up to one
 half second while waiting for more data from the
 keyboard (optional, but general practice).

 The tones are produced in the form of a square wave, by
 alternately writing ones and zeros to an output port.  How this
 is done will be described specifically for each machine later.
 One possible difficulty to note here is the necessity of sending
 a tone and reading the keyboard at the same time.

 ASCII to BAUDOT translation requires that FIGS (figures) and LTRS
 (letters) shifts are inserted as required.  For example, the
 Baudot code 01 (binary) is the letter E if the last shift
 received was LTRS or the number 3 if the last shift received was
 FIGS.  Shift codes do not precede each character, but are only
 sent when the required shift changes.  Also, it is common
 practice to follow a carriage-return and line-feed with a shift
 code to give the old teletype machines time to return the
 carriage.  Note that the current shift state is a function of the
 last shift code which was received or sent.








 TDD Emulation, Page 3



 The steps to receive and display incoming characters are:

 1-wait for the beginning of a start bit consisting of a
 SPACE tone (1800 Hz).

 2-wait for one and one half bit times, leaving us in the
 middle of the first data bit.

 3-if the incoming signal is MARK (1400 Hz), then the data
 bit is a 1, if the incoming signal is a SPACE (1800
 Hz), then the data bit is a 0.  Shift this bit to the
 RIGHT, into a register or work area.

 4-wait for one bit time, leaving us in the middle of the
 next data bit; go back to step 3 until we've shifted in
 all 5 data bits.

 5-shift the resulting byte from steps 3-4 to the RIGHT 3
 more positions (the Baudot code will now be correctly
 alligned in the byte), and translate to ASCII, removing
 FIGS and LTRS shift codes.

 6-Display the resulting ASCII code.

 In order to move between the transmit and receive functions, the
 first steps of both lists must be combined, i.e., test the
 keyboard and look for the start bit (SPACE tone) at the same
 time.  One possible problem in the receive function will be the
 time it takes the display to scroll, which could cause the next
 start bit to be lost.

 The final piece of the puzzle is determining the incoming
 frequency.  The typical cassette data input port returns a 1 or 0
 (when read) depending on the polarity of the input voltage.  One
 possible way to determine frequency would be to measure the time
 (by incrementing a counter) between subsequent 0-to-1 transitions
 of input port.  This is how Radio Shack's Audio Analyzer program
 works, and was the technique first tried for the TDD program.  It
 soon became apparent, however, that this simply provided too much
 information to digest.  The frequency values would have to be
 averaged, smoothed, bad values thrown out, etc.

 The technique finally employed is to sample the input port at
 roughly twice the SPACE frequency of 1800 Hz, shifting each bit
 into an 8 bit work area.  If the incoming signal is indeed 1800
 Hz, we will be reading the port during alternate half cycles,
 and will see a pattern of alternating ones and zeros,
 i.e., 01010101 or 10101010.  As the incoming signal frequency
 deviates from 1800 Hz, the alternating ones and zeros are
 interspersed with double ones or double zeros.  In particular an
 incoming signal at the MARK frequency of 1400 Hz will show a
 pattern such as 01011010.  If the incoming signal is at 1800 Hz,
 but the samples occur close to the zero crossing points of the
 signal, we might not see the desired pattern due to noise or








 TDD Emulation, Page 4


 waveform asymetry.  For this reason, the actual sampling rate
 used is slightly higher than twice the SPACE frequency (3912 Hz
 is used in the IBM PC version), so that the sample will not get
 "stuck" close to the zero crossing points for long.  This
 frequency is still close enough to see the alternating zero and
 one pattern "often enough" when the SPACE tone is present, and
 actually improves the rejection of the MARK tone because it is
 even further off.

 The reason for specifically looking for the SPACE tone is that
 the start bit is transmitted as a SPACE tone.  Once the start bit
 is detected, the "if this isn't SPACE then it must be MARK" logic
 is sufficient to receive the data bits.  Actually, the MARK tone
 isn't completely useless, as it masks any possible noise from
 being confused for a SPACE tone.

 To insure that a SPACE tone isn't missed, the signal is monitored
 during a significant portion (roughly one half) of the data bit
 time.  If the 01010101 pattern is seen anywhere in that "window"
 then it's called SPACE, otherwise it's called MARK.

 TRS-80 COLOR COMPUTER IMPLEMENTATION

 All timing in the Color Computer (CoCo) TDD program is based on
 the video horizontal sync (HS) frequency of 15748 Hz, which is
 used to drive one of two interrupt (IRQ) routines (one is used
 when transmimtting, the other during receiving).

 During receive processing, cassette input port data is shifted
 into a work area at 3937 Hz (HS/4) by the interrupt routine.  The
 main program continuously examines this area for the 01010101
 pattern.  Timing is done in the main program by counting
 interrupts via the SYNC instruction.  (Actually, two shift
 registers are used alternately at a rate of 7874 Hz -- this was
 done out of convenience rather than necessity with the same net
 result.)

 During transmit processing, the interrupt routine produces the
 required carrier tone (MARK or SPACE) by writing to the cassette
 output port (actually a 6-bit D-to-A converter) at appropriate
 times, and maintaining a software clock for the main program
 transmit routine.  The actual signal frequencies are the closest
 approximations possible, based on the HS frequency: the MARK
 frequency (normally 1400 Hz) is 1432 Hz (HS/11) and the SPACE
 frequency (normally 1800 Hz) is 1750 Hz (HS/9).

 The program does its own keyboard scanning (instead of calling
 the ROM routine to do this) because reading the keyboard inputs
 resets the interrupt request.  Therefore, the interrupt routine
 reads the keyboard lines to reset the interrupt, and saves the
 value for the keyboard scan routine.  The keyboard scan routine
 uses the SYNC instruction to insure that this data has been read.

 Because the transmitted carrier (MARK OR SPACE tone) is
 maintained by the transmit interrupt routine, the main program is








 TDD Emulation, Page 5


 free to do other things, such as scan the keyboard for the next
 character.  A one character type-ahead buffer is used to improve
 the typing "feel" of the program.  To make operation similar to a
 real teletype, shifted letters are mapped to their corresponding
 FIGS shift codes.  For example, typing # or shift-H has the same
 effect.  The down arrow key sends a line feed, and keys with no
 Baudot equivalent are ignored.

 During receive processing, interrupts are turned off while
 writing to the video display, because scrolling takes too long
 (incoming data is lost/garbled) with interrupts enabled.

 Whenever the program is idle, it is simultaneously scanning the
 keyboard and looking for a start bit (SPACE tone) at the cassette
 input port.  In addition, the cassette input data is sampled at a
 slow rate (78 Hz) to detect non-TDD signals (such as busy
 signals).  When such a signal is present, the screen cursor is
 changed from a solid blue to and orange-black checkerboard.

 The current version of the Color Computer TDD program is 4.3.  It
 is written in 6809 assembler language, for the CompuServe MAC69
 cross-assembler, but could be easily be modified for other
 assemblers.  The source file is TDD43.M69.  The object code can
 be burned into a 2716 EPROM for very convenient operation from a
 ROM cartridge.

 IBM PC/PCjr IMPLEMENTATION

 The cassette output port of the IBM PC is driven directly by
 timer-2 of an Intel 8253 Progrmmable Interval Timer chip, thus
 greatly simplifying carrier tone generation.  Timer-0, normally
 used to update the system time-of-day clock, is used to generate
 interrupts for input sampling and general timing purposes.  The
 system time-of-day is maintained by invoking the IBM timer
 interrupt routine at appropriate intervals.  Timer-1 is used in
 the RAM refresh function, and so is not available.  (On the PCjr,
 timer-1 is used for keyboard data deserialization.)

 Both timer-0 and timer-2 are driven by a 1193180 Hz clock, and
 are programmed to run as square wave generators ("mode-3").  When
 transmitting, carrier tones are generated by loading the correct
 values into timer-2.  The actual frequencies generated are 1400.5
 Hz (MARK) and 1799.7 Hz (SPACE), using counter values 852 and 663
 respectively.

 Timer-0 is loaded with a value 305 to produce interrupts at the
 desired sampling rate of 3912 Hz.  This value was chosen because
 it is close to the Color Computer version's sampling rate of 3937
 Hz, and is close to a multiple of the desired baud rate.
 
 Timing is provided by two software clocks, both incremented at
 the interrupt rate of 3912 Hz.  One is used by the interrupt
 routines themselves for timing of serialization/deserialization
 of data, and the other is used by the main program to control the
 transition between transmit, receive and idle mode.








 TDD Emulation, Page 6



 All time dependent transmit and receive functions are handled
 within the interrupt routines (this is a departure from the Color
 Computer version where the function was split between the
 interrupt routine and the main program).  This was necessitated
 by two problems with the PCjr: (1) Because of interference with
 video refresh, the CPU runs slower on the PCjr, causing incoming
 data to be lost during scrolling, and (2) whenever a key is
 stuck, a NMI (non maskable interrupt) is generated, and the CPU
 spends the next 4.4 milliseconds deserializing the incoming
 keyboard data with interrupts disabled, during which time some 17
 timer interrupts are lost.

 Handling all data transmission and reception at the interrupt
 level, and buffering received data, rendered the slow scrolling
 not a problem.  (This also will make it much simpler to add
 printer support in a future release.)

 To solve the second PC jr problem, a NMI routine was included
 which adds 17 (for the 17 lost timer interrupts) to both software
 clocks, and then jumps to the IBM NMI routine.  The net result is
 that, at worst, an incoming keystroke could delay a carrier
 frequency transition by 4.4 milliseconds, but the effect will not
 be cumulatitive, i.e., the next transition will occur on time.

 The shifted letters are mapped to their FIGS equivalents.  In
 addition, line feeds will be inserted automatically if necessary.
 Line feeds can be sent manually by hitting Ctrl-J.  Characters
 will not be sent until no characters have been received for 3/4
 second.  (Keystrokes will simply accumulate in the system type-
 ahead buffer.)  Once transmission begins, the carrier stays on
 (and incoming data is ignored) until 1/2 second after the last
 character is transmitted.  When neither transmitting or
 receiving, non-TDD signals will register in the upper right
 corner of the screen as <SIGNAL>.

 The cassette motor relay is used to control going off-hook and
 pulse dialing. (Note: not currently supported in the Color
 Computer version).  When the program first comes up, it will
 prompt for a phone number.  When the number has been entered, it
 will go off-hook (by closing the relay) and then pulse dial (by
 opening the relay in pulses at 10Hz).  To answer a call, just hit
 enter to dial "nothing".

 The current version of the IBM PC/PCjr TDD Emulation Program is
 5.4.  It is written in 8088 Assembler Language for the Microsoft
 Assembler (MASM).  The source file is TDD54.ASM and the
 executable file is TDD54.EXE.















 TDD Emulation, Page 7


 CONNECTION TO THE TELEPHONE LINE

 SOLE RESPONSIBILITY FOR SAFETY TO THE USER'S COMPUTER EQUIPMENT
 AND LEGAL CONNECTION TO THE PUBLIC TELEPHONE SYSTEM RESTS WITH
 THE USER.  MODIFYING THE RADIO SHACK TELEPHONE AMPLIFIER, AS
 DESCRIBED BELOW, VOIDS THE MANUFACTURER'S WARRANTY.

 Color Computer or IBM PC 5-pin DIN connector:

% 1-3 Motor Control Relay
 3   1 2 Logic Ground
 5 4 4 Data in (+-13V MAX)
 2 5 Data out (.075 VDC)

 (Note: Voltages shown above apply to the IBM PC, which should be
 strapped as it comes from the factory for mic level output.)

 IBM PCjr 7-pin Berg connector:

% A4-B3 Motor Control Relay
 A1  A2  A3  A4 A1 Logic Ground
 B2  B3  B4 A2 Data in (+-13V MAX)
( A3 Data out (.075 VDC)
% B2-B4 Aux out, Shield ground *NOT USED*

 Connections from computer to telephone amplifier:

 1 (A4) $-> connect in parallel
5 to phone amp
 3 (B3) $-> on/off switch

( 1:1
 4 (A2) -) (-> to speaker output of
( ) (
 phone amp
 2 (A1) -) (-> (disconnect speaker)

' 1K:8 ohm
 5 (A3) -10K-,-) (-> to mic input of
 1K ) (
 phone amp
 2 (A1) -'-) (-> (disconnect mic)

 10K, 1K (1/4 watt) resistors NOT USED FOR PC/PCjr
 1:1 transformer is Radio Shack # 273-1375
 1K:8 ohm transformer is Radio Shack # 273-1380
 Telephone amplifier is Radio Shack # 43-278

 IMPORTANT NOTES:

 Connections from pins 1-3 are not used in the CoCo version, but
 may be wired for possible future use.  The current version
 of the program does not close the relay contacts.

 10K, 1K resistors are only for the CoCo, NOT FOR PC/PCjr.  (For
 PC/PCjr, just go straight to the transformer.)









 TDD Emulation, Page 8


 COLOR COMPUTER OPERATIONAL SUMMARY

 (These instructions assume the program will be run from a ROM
 cartridge.  The program can also be run from tape or disk.)

 Power the computer off, plug in the cartridge, plug the telephone
 amplifier into the cassette port, and power the computer on.
 COMPUTER OR CARTRIDGE DAMAGE MAY OCCUR IF YOU INSERT OR
 REMOVE A CARTRIDGE WITH THE POWER ON!

 The program will identify itself and show a solid blue cursor to
 indicate that it's ready.

 Tentatively set the telephone amp mic sensitivity switch to MIN,
 and speaker volume to half; adjust later as needed.

 To place a call, pick up the telephone and dial the number, then
 turn on the telephone amplifier and hang up the phone.

 To answer a call, simply turn on the telephone amplifier.

 Transmitted and received signals are routed to the TV audio,
 primarily for testing purposes, so TV volume should be
 turned all the way down in normal use.

 Whenever a signal is being received, the cursor will change from
 solid blue to orange and black.  This will serve a visual
 indication of ringing or busy signals, and also indicates
 whether the carrier tone from the other party is present.

 Shifted letters are mapped to their corresponding FIGS
 characters; thus typing # or shift-H has the same effect.
 Use the down arrow key to send a line feed and the enter key
 for carriage return.  The shifted letters are as follows:

 1   2   3   4   5   6   7   8   9   0
 Q   W   E   R   T   Y   U   I   O   P

 -  BEL  $   !   &   #   '   (   )
 A   S   D   F   G   H   J   K   L

 "   /   :   ;   ?   ,   .
 Z   X   C   V   B   N   M

 To hang up, turn off the telephone amplifier.

 IBM PC/PCjr OPERATIONAL SUMMARY

 Connect the telephone amplifier to the cassette port of the
 computer and to the telephone line.

 Tentatively set the telephone amplifier mic sensitivity switch to
 MIN, and speaker volume to half; adjust later as needed.
 Leave the telephone amplifier switched OFF.









 TDD Emulation, Page 9


 Start the program by typing TDD54 at the DOS prompt.

 You will be prompted for a telephone number.  Enter the desired
 phone number, or to answer a call, just hit carriage-return
 to dial "nothing".

 Call progress can be monitored via the <SIGNAL> flag which will
 appear in the upper right corner of the screen whenever a
 non-TDD signal (such as a busy signal) is present.

 Shifted letters are mapped to their equivalent FIGS characters;
 thus typing shift-H or # has the same effect.  Line feeds
 will be inserted as needed, but may be sent manually by
 hitting ctrl-J.  Shifted letter codes are as follows:

 1   2   3   4   5   6   7   8   9   0
 Q   W   E   R   T   Y   U   I   O   P

 -  BEL  $   !   &   #   '   (   )
 A   S   D   F   G   H   J   K   L

 "   /   :   ;   ?   ,   .
 Z   X   C   V   B   N   M

 To end the call, hit Ctrl-Break, which will disconnect from the
 telephone line, and return to PC-DOS.

 FOR MORE INFORMATION

 Information on obtaining copies of these programs, as well as
 other TDD emulation programs and a wealth of other information,
 is available from:
 
 Handicapped Educational Exchange (HEX)
 Richard Barth, SYSOP
 11523 Charlton Drive
 Silver Spring, MD  20902
 bulletin board: (301)593-7033 (300 baud or TDD)

 Blank ROM cartridges (and many other goodies for the Color
 Computer) are available from:
 
 Spectrun Projects
 PO Box 21272
 Woodhaven, NY  11421

& -END-
















 F                                                                                                                                                                                                                                                                                                                                                                                                 