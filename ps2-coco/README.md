coco
====

## About
Hardware and software projects related to my cherished Color Computer 3

### PS2 Keyboard
The ribbon cable that connects the keyboard to the mainboard has a small tear in it, which is preventing it from working.  The COCO uses a weird switching system which can only be replicated, as I understand, but something called an analog switch matrix.  These devices were used in analog phone switching systems to route different lines together dynamically.  They are sort of like wired connections, but provided via digital protocol.

The keyboard driver is written in assembly and interprets incoming PS2 data packets from a PS2 keyboard and remaps them to a rudimentary keyboard switching matrix.  The matrix still needs to be remapped to the analog switching chip, but so far it's working as expected.
