/*
 * This macro allows you to use a 'C' function to handle a 6809 interrupt.
 *
 * The only parameter is the DECIMAL address of the interrupt vector.
 *
 * The macro MUST be placed IMMEDIATELY preceeding the definition of the
 * function which is to be the interrupt handler. Example:
 *
 * 		INTERRUPT(_SER_) serial_int_handler()
 * 		{
 *			/* ... Function code to handle serial interrupt ... */
 *		}
 *
 * This file **REQUIRES** the extended pre-processor (MCP).
 * (CC09 ... -P, or "Preprocess" step enabled in DDSIDE)
 *
 * Copyright 1991-2001 Dave Dunfield
 * All rights reserved.
 */
#define	_SP_				/* Null separator */
#define	INTERRUPT(vec) asm {\
$SE:0						/* Insure output in code segment */\
_/**/vec	/* This label will be the address of the "prefix" stub */\
		ORG		vec			/* Position to interrupt vector */\
		FDB		_/**/vec	/* Enter the label address */\
		ORG		_/**/vec	/* Position back to original PC */\
		LDD		_SP_?temp	/* Get temporary location */\
		PSHS	A,B			/* Save during interrupt */\
		BSR		_/**/vec+13	/* Invoke 'C' interrupt handler*/\
		PULS	A,B			/* Restore temporary location value*/\
		STD		_SP_?temp	/* Restore temporary location */\
		RTI					/* End interrupt */\
}
#undef _SP_
//00000
