DDS MICRO-C 6809 Runtime Library is currently configured as follows:

MEMORY:
	RAM ONLY: Starting at $2000 and ending at $BFFF.
	To change start address, modify 'ORG' at beginning of 6809RLP.ASM
	To change ending address, modify 'LDS' at beginning of 6809RLP.ASM

	To set up for split ROM/RAM operation, set 'ORG' in 6809RLP.ASM to
	beginning of ROM, and 'LDS' to end of RAM. Then modify 6809RLM.ASM
	to contain an 'ORG' to the beginning of RAM. See 'Compiling for ROM'
	in the MICRO-C Technical manual.

CONSOLE:
	External 6551 Type UART device at address $0000.
	For other device types, replace the code in SERIO.ASM.
	To change device address modify '?uart EQU' at beginning of SERIO.ASM

If you are using INTERRUPTS, check out the 6809RL*.ASM file(s) to make sure
that space is available for the interrupt vectors. Also, see the file
6809INT.H for information on defining interrupt handling functions in C.
Make sure you READ THE COMMENTS in this file carefully, and understand how
it works. Note that you may have to modify the interrupt vector addresses
passed to the INTERRUPT macro when compiling for a debug system or a "raw"
system.

***IMPORTANT*** If you edit the .LIB file(s) directly, MAKE SURE that you
(or your editor) do not remove the trailing space from any line beginning
with '$'. Many 3rd party editors automatically remove trailing spaces. If
in doubt, use my EDT or DDSIDE (included with this package).

NOTE: A useful excercise to help understand the compiler/linkers usage of
memory is to compile the following program with the -CL options, and view
the resulting .LST file:

To gain a better understanding of the source linker and it's directives,
compile the program again with the -AC options, and look at the segment
directives in the .ASM output file, matching the output with the final
code in the first listing.

------------------------------ CUT HERE ----------------------------------
char init_global[5] = { 1, 2, 3, 4, 5 };
char uninit_global[5];

// Compilers for CPU's with on-chip internal memory use "register" to force
// a global (or static) variable to be allocated therein. For other CPU's,
// this will be treated the same as any uninitialized global.
register char register_global[5];

main()
{
	unsigned local_auto;
	static unsigned local_static;

	// Access locals to identify, as symbol names are lost in listing
	local_auto;
	local_static;

	// Call a library function to demonstrate linking of library
	putstr("Hello world");
}
S/N: 00000
