// Dasm6809c.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
/*----------------------------------------------------------------------*/
/* M6809 Disassembler, code by Bruno Vedder 13 Jun 2002			*/
/* Feel free to re-use this code, or use this desassembly as long as 	*/
/* you give proper credit.You use this program as your own risk, no 	*/
/* waranties ... 							*/
/* RESET* (OPC 3E) undocumented instruction is supported.		*/
/*----------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "dasm6809c.h"


using namespace std;
/*----------------------------------------------------------------------*/
/*	CPU willuse this functions to access memory. They contain here	*/
/* code for eventual bank switching or I/O mapping. They act like a BUS	*/
/* These functions are provided and attached to CPU 'object' by user.	*/
/*----------------------------------------------------------------------*/

u8  RdMem8  (u16 Adr);	/* CPU 8bit Read Function 			*/
u16 RdMem16 (u16 Adr);	/* CPU 16bit Read Function 			*/
u8 * CPU1Memory;	/* CPU Own Memory,var   used for read functions */

/*----------------------------------------------------------------------*/
/* Main loop. What's Done here:						*/
/* 1) Check if argument is given to load Binary. else display usage.	*/
/* 2) Allocate memory for CPU memory space.				*/
/* 3) 'Attach' CPU Read functions by updating M6809CPU structure.	*/	
/* 4) Load 6809 Binary into CPU adressing space.			*/
/* 5) Disassemble the whole thing.					*/
/*----------------------------------------------------------------------*/



/*----------------------------------------------------------------------*/
/*----------------------------------------------------------------------*/
void main (int argc,char *argv [])
{
	int i,size;
	FILE * BIN6809;
	M6809CPU CPU;
	char StringBuffer [DASM_STR_LEN];
	u8 OpcodeSize;
	u8 Cycles;
	int Address,BaseAddress;

	if (argc <3)
	{
		printf ("Usage: dasm6809 FILE Base_Address_in_Hexa.\n");
		exit (0);	
	}
	CPU1Memory = malloc (65536*2);
	if (CPU1Memory == NULL)
	{
		printf ("Unable to allocate memory.\n");
		exit (0);
	}
	CPU.ReadMem8 = &RdMem8;			/* Attach to CPU Object, read functions 		*/
	CPU.ReadMem16 = &RdMem16;		/* CPU will use this func to perform a 16bit read  	*/

	BIN6809 =fopen(argv[1],"rb");
	if (BIN6809 == NULL)
	{
		printf ("Unable to open file: %s\n",argv [1]);
		exit (0);
	}
	sscanf (argv[2],"%x",&BaseAddress);
	size = fread(&CPU1Memory[BaseAddress],1,0xffff,BIN6809);
	printf ("Archive size is:%d bytes.\nDisassembly base address  is 0x%.4X\n",size,BaseAddress);
	if (BaseAddress+size>65536) {printf ("Memory overflow: Address + archive size is> 0xFFFF.\n");exit (0);}
	Address=0;
	while (Address<size)
	{
		OpcodeSize = Dasm6809 (&CPU,Address+BaseAddress,StringBuffer,&Cycles);
		printf ("%s",StringBuffer);
		Address +=OpcodeSize;
	}
}


/*----------------------------------------------------------------------*/
/* CPU Read Function */
/*----------------------------------------------------------------------*/
u8  RdMem8  (u16 Adr)
{
	return (CPU1Memory [Adr]);
}


/*----------------------------------------------------------------------*/
/* CAREFULL WITH ENDIANESS */
/*----------------------------------------------------------------------*/
u16 RdMem16 (u16 Adr)
{
	return ((CPU1Memory [Adr]<<8)+CPU1Memory[Adr+1]);
}


/*----------------------------------------------------------------------*/
/*	Disassemble One Opcode.						*/
/*	CPU is the cpu structure that will be taen for disassembly.	*/
/*	Adr is the address to disassemble from. 			*/
/*	dst_str is a string were the disassembly can wrote is output.	*/
/*	The func return the size of the disassembled opcode.		*/
/*----------------------------------------------------------------------*/
u8 Dasm6809 (M6809CPU *CPU,u16 Adr,char *dst_str,u8 * cycle_nbr)
{
	u8 Opcode,prefix,Opsize,Inst_Clk;
	M6809Opcode *CurrentOpcodeTable;
	char Operands [OPERAND_STR_LEN];
	char Dump     [DUMP_STR_LEN];
	char Mnemo    [MNEMONIC_LEN];

	Operands[0]='\0';		/* Clear Operands string */
	Dump 	[0]='\0';
	Mnemo 	[0]='\0';
	Opcode = CPU->ReadMem8 (Adr);	/* Read byte */
	sprintf (dst_str,"%.4X: ",Adr);	/* Write Address */
	switch (Opcode)
	{
	case 0x10:
		Opcode = CPU->ReadMem8 (Adr+1);			/* Read Real Opcode */
		CurrentOpcodeTable = OpcodeTable10;		/* Use Table of 10h prefixed opcode*/
		/* Write operands in string: Call funct associated to addressing mode */
		Opsize = CurrentOpcodeTable[Opcode].AddrMode (CPU,&CurrentOpcodeTable[Opcode],Adr+1,Operands,&Inst_Clk);
		HexDump (CPU,Adr,Opsize,Dump);				/* Dump byte(s)*/
		strcpy (Mnemo,CurrentOpcodeTable[Opcode].Mnemonic); /* Write Mnemonic */

		break;
	case 0x11:
		Opcode = CPU->ReadMem8 (Adr+1);			/* Read Real Opcode */
		CurrentOpcodeTable = OpcodeTable11;		/* Use Table of 11h prefixed opcode*/
		/* Write operands in string: Call funct associated to addressing mode */
		Opsize = CurrentOpcodeTable[Opcode].AddrMode (CPU,&CurrentOpcodeTable[Opcode],Adr+1,Operands,&Inst_Clk);
		HexDump (CPU,Adr,Opsize,Dump);				/* Dump byte(s)*/	
		strcpy (Mnemo,CurrentOpcodeTable[Opcode].Mnemonic);	/* Write Mnemonic */	
		break;
	default:
		CurrentOpcodeTable = OpcodeTable;
		/* Write operands in string: Call funct associated to addressing mode */
		Opsize=CurrentOpcodeTable[Opcode].AddrMode (CPU,&CurrentOpcodeTable[Opcode],Adr,Operands,&Inst_Clk);
		HexDump (CPU,Adr,Opsize,Dump);				/* Dump byte(s)*/
		strcpy (Mnemo,CurrentOpcodeTable[Opcode].Mnemonic); 	/* Write Mnemonic */
		break;	
	}
	strcat (dst_str,Dump);
	strcat (dst_str,Mnemo);
	strcat (dst_str,Operands); 	/* Add Operands at the end of line */
	//strcat (dst_str,"\t\t\t"); 	/* Add Mnemonic help :-)*/
	//strcat (dst_str,CurrentOpcodeTable[Opcode].MnemoHelp);
	strcat (dst_str,"\n");		/* CR\LF at the end of line */
	return (Opsize);
}


/*-----------------------------------------------------------------------------
	This function is used to decode registers used with the Operands
using xRRxxxxx Post Byte Register Bit.Register are encoded like this: X11XXXXX
which is an index in Register16bit Table.
-----------------------------------------------------------------------------*/
u8 *IndexRegister(u8 postbyte)
{
	return Register16bit [(postbyte>>5)&0x03];
}


/*-----------------------------------------------------------------------------
	This function is used to decode registers used with the
EXG,TFR Operands. Four lowest bits are significatives. Register are 
encoded like this: XXXX1111 which is an index in Register Table.
-----------------------------------------------------------------------------*/
u8* InherentRegister (u8 postbyte)
{
	return (Registers [postbyte & 0xf]);
}


/*-----------------------------------------------------------------------------
	This function is used to decode registers used with the
CWAI instruction.
-----------------------------------------------------------------------------*/
void WriteCWAIRegister (char *dst_str,u8 byte)
{
	char ValBuf [4];
	sprintf (ValBuf,"#%.2X",byte);
	strcat (dst_str,ValBuf);
}


/*-----------------------------------------------------------------------------
	Those functions are used to write register pushed/pulled
in right order. PSHS never Pushes S, PULU never Pull U.
For info: each register is represented by a bit in byte.
if byte =0, we got some datas, or an illegal combinaison.
-----------------------------------------------------------------------------*/
void WritePSHSRegister (char *dst_str,u8 byte)
{
	if (byte == 0) 
	{
		strcat (dst_str,"??");
		return;
	}
	if (byte & 0x80)
		strcat (dst_str,",PC");
	if (byte & 0x40)
		strcat (dst_str,",U");
	if (byte & 0x20)
		strcat (dst_str,",Y");
	if (byte & 0x10)
		strcat (dst_str,",X");
	if (byte & 0x08)
		strcat (dst_str,",DP");
	if (byte & 0x04)
		strcat (dst_str,",B");
	if (byte & 0x02)
		strcat (dst_str,",A");
	if (byte & 0x01)
		strcat (dst_str,",CC");
}


/*----------------------------------------------------------------------*/
/*----------------------------------------------------------------------*/
void WritePSHURegister (char *dst_str,u8 byte)
{
	if (byte == 0) {strcat (dst_str,"??");return;}
	if (byte & 0x80) strcat (dst_str,",PC");
	if (byte & 0x40) strcat (dst_str,",S");
	if (byte & 0x20) strcat (dst_str,",Y");
	if (byte & 0x10) strcat (dst_str,",X");
	if (byte & 0x08) strcat (dst_str,",DP");
	if (byte & 0x04) strcat (dst_str,",B");
	if (byte & 0x02) strcat (dst_str,",A");
	if (byte & 0x01) strcat (dst_str,",CC");
}


/*----------------------------------------------------------------------*/
/*----------------------------------------------------------------------*/
void WritePULSRegister (char *dst_str,u8 byte)
{
	if (byte == 0) {strcat (dst_str,"??");return;}
	if (byte & 0x01) strcat (dst_str,",CC");
	if (byte & 0x02) strcat (dst_str,",A");
	if (byte & 0x04) strcat (dst_str,",B");
	if (byte & 0x08) strcat (dst_str,",DP");
	if (byte & 0x10) strcat (dst_str,",X");
	if (byte & 0x20) strcat (dst_str,",Y");
	if (byte & 0x40) strcat (dst_str,",U");
	if (byte & 0x80) strcat (dst_str,",PC");
}


/*----------------------------------------------------------------------*/
/*----------------------------------------------------------------------*/
void WritePULURegister (char *dst_str,u8 byte)
{
	if (byte == 0) {strcat (dst_str,"??");return;}
	if (byte & 0x01) strcat (dst_str,",CC");
	if (byte & 0x02) strcat (dst_str,",A");
	if (byte & 0x04) strcat (dst_str,",B");
	if (byte & 0x08) strcat (dst_str,",DP");
	if (byte & 0x10) strcat (dst_str,",X");
	if (byte & 0x20) strcat (dst_str,",Y");
	if (byte & 0x40) strcat (dst_str,",S");
	if (byte & 0x80) strcat (dst_str,",PC");
}


/*-----------------------------------------------------------------------------
	Dump nb_byte byte from Add, via CPU->ReadMem8, in dst string.
-----------------------------------------------------------------------------*/
void HexDump (M6809CPU *Cpu,u16 Add,u8 nb_byte,char *dst)
{
	switch (nb_byte)
	{
		case 1:
			sprintf (dst,"%.2X              ",Cpu->ReadMem8 (Add));
			break;
		case 2:
			sprintf (dst,"%.2X %.2X           ",Cpu->ReadMem8 (Add),Cpu->ReadMem8 (Add+1));
			break;
		case 3:
			sprintf (dst,"%.2X %.2X %.2X        ",Cpu->ReadMem8 (Add),Cpu->ReadMem8 (Add+1),Cpu->ReadMem8 (Add+2));
			break;
		case 4:
			sprintf (dst,"%.2X %.2X %.2X %.2X     ",Cpu->ReadMem8 (Add),Cpu->ReadMem8 (Add+1),Cpu->ReadMem8 (Add+2),Cpu->ReadMem8 (Add+3));	
			break;
		case 5:
			sprintf (dst,"%.2X %.2X %.2X %.2X %.2X  ",Cpu->ReadMem8 (Add),Cpu->ReadMem8 (Add+1),Cpu->ReadMem8 (Add+2),Cpu->ReadMem8 (Add+3),Cpu->ReadMem8 (Add+4));	
			break;
		default:
			sprintf (dst,"find instruction with len of : %d chars !",nb_byte);
			break;
	}
}


/*-----------------------------------------------------------------------------
	Those functions are used to write instruction operands with specific
	addressing mode. They are attached to an opcode via a pointer in the
	opcode table. All have the same prototype:
	Input: 	Cpu is the concerned ... CPU :-)
		Op is the opcode descriptor, in right table (maybe prefixed).
		Add is the Address of the instruction opcode. (prefix shunted)
		Operands is a string for returning string with Operand disassembly.
		Cycle nbr is a pointer to an u8 to return the number of inst cycle.
	Output: return an int equal to the opcode Size.
-----------------------------------------------------------------------------*/


/*-----------------------------------------------------------------------------
	Return in string decoded operands, using Inherent addressing mode.
-----------------------------------------------------------------------------*/
int AM_Inherent   	(M6809CPU *CPU,M6809Opcode *Op,u16 Add,char *Operands,u8 *Cycles_nbr)
{
	u8 byte;
	if (Op->Size != 1) 	/* Mean that instruction have operands -> EXG,TFR,PSHS,PULS,PSHU,PULU */
	{
		byte = CPU->ReadMem8 (Add+1);
		if (Op->Opcode==OP_EXG || Op->Opcode==OP_TFR)
		{
			sprintf (Operands,"%s,%s",InherentRegister (byte>>4),InherentRegister (byte &0xf));			
		}
		else
		{
			switch (Op->Opcode)
			{
				case OP_PSHS:
					WritePSHSRegister (Operands,byte);
					break;
				case OP_PSHU:
					WritePSHURegister (Operands,byte);
					break;
				case OP_PULS:
					WritePULSRegister (Operands,byte);
					break;
				case OP_PULU:
					WritePULURegister (Operands,byte);
					break;
				case OP_CWAI:
					WriteCWAIRegister (Operands,byte);
					break;
				case OP_SWI:	/* No Operand for prefixed swi2-swi3 Instructions .*/
					break;
				default:
					printf ("Unknown Inherent adressing mode instruction.\n ",Op->Opcode);
					break;
			}
		}
	}
	*Cycles_nbr = Op->Clock;	/* Store in Cycles_nbr, cycles total */
	return (Op->Size);
}


/*-----------------------------------------------------------------------------
	Return in string decoded operands, using Immediat_8 addressing mode.
-----------------------------------------------------------------------------*/
int AM_Immediat_8 	(M6809CPU *CPU,M6809Opcode *Op,u16 Add,char *Operands,u8 *Cycles_nbr)
{
	u8 byte;
	byte = CPU->ReadMem8(Add+1);	/* Get next byte:Immediate 8b value */
	sprintf (Operands,"#$%.2X",byte);		
	*Cycles_nbr = Op->Clock;
	return (Op->Size);
}


/*-----------------------------------------------------------------------------
	Return in string decoded operands, using Immediat_16 addressing mode.
-----------------------------------------------------------------------------*/
int AM_Immediat_16	(M6809CPU *CPU,M6809Opcode *Op,u16 Add,char *Operands,u8 *Cycles_nbr)
{
	u16 word;
	word =CPU->ReadMem16(Add+1);	/* Get next byte:Immediate 8b value */
	sprintf (Operands,"#$%.4X",word);		
	*Cycles_nbr = Op->Clock;
	return (Op->Size);
}


/*-----------------------------------------------------------------------------
	Return in string decoded operands, using Branch_rel_8 addressing mode.
-----------------------------------------------------------------------------*/
int AM_Branch_Rel_8	(M6809CPU *CPU,M6809Opcode *Op,u16 Add,char *Operands,u8 *Cycles_nbr)
{
	u8 byte;
	u16 word;
	byte = CPU->ReadMem8(Add+1);	/* Get next byte:Immediate 8b value */
	if (byte<127)
	{
		word = Add + 2 + byte;	/* +2 = from byte after Inst + 8bit value */
	}
	else
	{
		word = Add + 2 - (256 - byte);
	}
	sprintf (Operands,"$%.4X",word);		
	*Cycles_nbr = Op->Clock;
	return (Op->Size);
}


/*-----------------------------------------------------------------------------
	Return in string decoded operands, using Branch_Rel_16 addressing mode.
-----------------------------------------------------------------------------*/
int AM_Branch_Rel_16    (M6809CPU *CPU,M6809Opcode *Op,u16 Add,char *Operands,u8 *Cycles_nbr)
{
	u16 word;
	word = CPU->ReadMem16(Add+1);	/* Get next byte:Immediate 8b value */
	if (word<32767)
	{
		word = Add + 3 + word;	/* +3 = from byte after Inst + 16bit value */
	}
	else
	{
		word = Add + 3 - (65536 - word);
	}
	sprintf (Operands,"$%.4X",word);		
	*Cycles_nbr = Op->Clock;
	return (Op->Size);
}


/*-----------------------------------------------------------------------------
	Return in string decoded operands, using Direct addressing mode.
-----------------------------------------------------------------------------*/
int AM_Direct		(M6809CPU *CPU,M6809Opcode *Op,u16 Add,char *Operands,u8 *Cycles_nbr)
{
	u8 byte;
	byte = CPU->ReadMem8(Add+1);	/* Get next byte:Immediate 8b value */
	sprintf (Operands,"$%.2X",byte);		
	*Cycles_nbr = Op->Clock;
	return (Op->Size);
}


/*-----------------------------------------------------------------------------
	Return in string decoded operands, using Extended addressing mode.
-----------------------------------------------------------------------------*/
int AM_Extended   	(M6809CPU *CPU,M6809Opcode *Op,u16 Add,char *Operands,u8 *Cycles_nbr)
{
	u16 word;
	word = CPU->ReadMem16 (Add+1);
	sprintf (Operands,"$%.4X",word);
	*Cycles_nbr = Op->Clock;
	return (Op->Size);
}


/*-----------------------------------------------------------------------------
	Return in string decoded operands, using Illegal addressing mode.
-----------------------------------------------------------------------------*/
int AM_Illegal   	(M6809CPU *CPU,M6809Opcode *Op,u16 Add,char *Operands,u8 *Cycles_nbr)
{
	Add++;
	Operands [0]='\0';
	CPU->ReadMem8 (Add);
	sprintf (Operands,"??");
	*Cycles_nbr = Op->Clock;
	return (Op->Size);
}


/*
This doc come from: 
-------------------
Description Of The Motorola 6809 Instruction Set
#FILE: m6809.html
#REV: 1.1
#DATE: 01/06/95
#AUTHOR: Paul D. Burgin
  +------------------------------------------------------------------------+
  |          INDEX ADDRESSING POST BYTE REGISTER BIT ASSIGNMENTS           |
  +-------------------------------+--------------------------------+-------+
  |    POST BYTE REGISTER BIT     |                                |  Add  |
  +---+---+---+---+---+---+---+---+          INDEXED MODE          +---+---+
  | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |                                | ~ | # |
  +---+---+---+---+---+---+---+---+--------------------------------+---+---+
  | 0 | R | R | F | F | F | F | F |      (+/- 4 bit offset),R      | 1 | 0 |
  +---+---+---+---+---+---+---+---+--------------------------------+---+---+
  | 1 | R | R | 0 | 0 | 0 | 0 | 0 |               ,R+              | 2 | 0 |
  +---+---+---+---+---+---+---+---+--------------------------------+---+---+
  | 1 | R | R | I | 0 | 0 | 0 | 1 |               ,R++             | 3 | 0 |
  +---+---+---+---+---+---+---+---+--------------------------------+---+---+
  | 1 | R | R | 0 | 0 | 0 | 1 | 0 |               ,-R              | 2 | 0 |
  +---+---+---+---+---+---+---+---+--------------------------------+---+---+
  | 1 | R | R | I | 0 | 0 | 1 | 1 |               ,--R             | 3 | 0 |
  +---+---+---+---+---+---+---+---+--------------------------------+---+---+
  | 1 | R | R | I | 0 | 1 | 0 | 0 |               ,R               | 0 | 0 |
  +---+---+---+---+---+---+---+---+--------------------------------+---+---+
  | 1 | R | R | I | 0 | 1 | 0 | 1 |             (+/- B),R          | 1 | 0 |
  +---+---+---+---+---+---+---+---+--------------------------------+---+---+
  | 1 | R | R | I | 0 | 1 | 1 | 0 |             (+/- A),R          | 1 | 0 |
  +---+---+---+---+---+---+---+---+--------------------------------+---+---+
  | 1 | X | X | X | 0 | 1 | 1 | 1 |              Illegal           | u | u |
  +---+---+---+---+---+---+---+---+--------------------------------+---+---+
  | 1 | R | R | I | 1 | 0 | 0 | 0 |      (+/- 7 bit offset),R      | 1 | 1 |
  +---+---+---+---+---+---+---+---+--------------------------------+---+---+
  | 1 | R | R | I | 1 | 0 | 0 | 1 |      (+/- 15 bit offset),R     | 4 | 2 |
  +---+---+---+---+---+---+---+---+--------------------------------+---+---+
  | 1 | X | X | X | 1 | 0 | 1 | 0 |              Illegal           | u | u |
  +---+---+---+---+---+---+---+---+--------------------------------+---+---+
  | 1 | R | R | I | 1 | 0 | 1 | 1 |             (+/- D),R          | 4 | 0 |
  +---+---+---+---+---+---+---+---+--------------------------------+---+---+
  | 1 | X | X | I | 1 | 1 | 0 | 0 |      (+/- 7 bit offset),PC     | 1 | 1 |
  +---+---+---+---+---+---+---+---+--------------------------------+---+---+
  | 1 | X | X | I | 1 | 1 | 0 | 1 |      (+/- 15 bit offset),PC    | 5 | 2 |
  +---+---+---+---+---+---+---+---+--------------------------------+---+---+
  | 1 | X | X | X | 1 | 1 | 1 | 0 |              Illegal           | u | u |
  +---+---+---+---+---+---+---+---+--------------------------------+---+---+
  | 1 | 0 | 0 | 1 | 1 | 1 | 1 | 1 |             [address]          | 5 | 2 |
  +---+---+---+---+---+---+---+---+--------------------------------+---+---+

    Key
    ===

    ~ Additional clock cycles.
    # Additional post bytes.
    u Undefined.
    X Don't Care.
    F Offset.
    I Indirect field.
        0 = Non indirect
        1 = Indirect (add 3 cycles)
    R Register field.
       00 = X
       01 = Y
       10 = U
       11 = S */
/*-----------------------------------------------------------------------------
	Return in string decoded operands, using Indexed addressing mode.
-----------------------------------------------------------------------------*/
int AM_Indexed (M6809CPU *CPU,M6809Opcode *Op,u16 Add,char *Operands,u8 *Cycles_nbr)
{
	u8 extrabyte=0;
	u8 postbyte,byte;
	u16 word;
	char signe;

	postbyte = CPU->ReadMem8 (Add+1);
	if (!(postbyte & 0x80))
	{/*	(+/- 4 bit offset),R -> CONSTANT OFFSET FROM REGISTER	*/
		byte = (postbyte & 0x1f);
		if (byte & 0x10) {byte=0x20-byte;signe ='-';}	
		else signe ='+';
		sprintf (Operands,"%c$%.2X,%s",signe,byte,IndexRegister(postbyte));	
	}
	else 
	{
		switch (postbyte & 0x1f)
		{
		case 0x00:	/* ,R+ -> POSTINCREMENT FROM REGISTER */ 
			sprintf (Operands,",%s+",IndexRegister(postbyte));	
			break;
		case 0x01:	/* ,R++ -> POSTINCREMENT FROM REGISTER */ 
			sprintf (Operands,",%s++ ",IndexRegister(postbyte));	
			break;
		case 0x02:	/* ,-R -> PRE DECREMENT FROM REGISTER */ 
			sprintf (Operands,",-%s",IndexRegister(postbyte));	
			break;
		case 0x03:	/* ,--R -> PRE DECREMENT FROM REGISTER */ 
			sprintf (Operands,",--%s",IndexRegister(postbyte));	
			break;
		case 0x04:	/* ,R ->  FROM REGISTER */ 
			sprintf (Operands,",%s",IndexRegister(postbyte));	
			break;
		case 0x05:	/* B,R -> ACCUMULATOR OFFSET FROM REGISTER */ 
			sprintf (Operands,"B,%s",IndexRegister(postbyte));	
			break;
		case 0x06:	/* A,R -> ACCUMULATOR OFFSET FROM REGISTER */ 
			sprintf (Operands,"A,%s",IndexRegister(postbyte));	
			break;
		case 0x07:	/* ILLEGAL ADRESSING MODE */ 
			sprintf (Operands,"??");	
			break;	
		case 0x08:	/* (+/- 7 bit offset),R Display sign ?*/ 
			byte = CPU->ReadMem8 (Add+2);
			if (byte>127)
				signe = '-';byte=0x0100-byte;
			else
				signe = '+';
			sprintf (Operands,"%c$%2.X,%s",signe,byte,IndexRegister (postbyte));	
			extrabyte = 1;
			break;
		case 0x09:	/* (+/- 15 bit offset),R  */ 
			word = CPU->ReadMem16 (Add+2);
			sprintf (Operands,"$%.4X,%s",word,IndexRegister (postbyte));	
			extrabyte = 2;
			break;
		case 0x0a:	/* ILLEGAL ADRESSING MODE ?? */ 
			sprintf (Operands,"??");	
			break;
		case 0x0b:	/* D,R ->  FROM REGISTER */ 
			sprintf (Operands,"D,%s",IndexRegister(postbyte));	
			break;
		case 0x0c:	/* (+/- 7 bit offset),PC */ 
			byte = CPU->ReadMem8 (Add+2);
			if (byte>127)
				signe = '-';byte=0x0100-byte;
			else
				signe = '+';
			sprintf (Operands,"%c$%2.X,PC",signe,byte);	
			extrabyte = 1;
			break;
		case 0x0d:	/* (+/- 15 bit offset),PC */ 
			word = CPU->ReadMem16 (Add+2);
			sprintf (Operands,"$%.4X,PC",word);	
			extrabyte = 2;
			break;
		case 0x0e:	/* ILLEGAL ADRESSING MODE */ 
			sprintf (Operands,"??");
			break;
		case 0x0f:	/* $XXXX,R */ 
			word = CPU->ReadMem16 (Add+2);
			sprintf (Operands,"$%.4X,%s",word,IndexRegister(postbyte));	
			extrabyte = 2;
			break;
		case 0x10:	/* ADRESSING MODE [,R+] */ 
			sprintf (Operands,"[,%s+]",IndexRegister (postbyte));	
			break;
		case 0x11:	/* ADRESSING MODE [,R++] */ 
			sprintf (Operands,"[,%s++]",IndexRegister (postbyte));	
			break;
		case 0x12:	/* ADRESSING MODE [,-R] */ 
		sprintf (Operands,"[,-%s]",IndexRegister (postbyte));	
			break;
		case 0x13:	/* ADRESSING MODE [,--R] */ 
			sprintf (Operands,"[,--%s]",IndexRegister (postbyte));	
			break;
		case 0x14:	/* ADRESSING MODE [,R] */ 
			sprintf (Operands,"[,%s]",IndexRegister (postbyte));	
			break;
		case 0x15:	/* ILLEGAL ADRESSING MODE OR [B,R] ?*/ 
			sprintf (Operands,"[B,%s]",IndexRegister (postbyte));	
			break;
		case 0x16:	/* ILLEGAL ADRESSING MODE OR [A,R] ?*/ 
			sprintf (Operands,"[A,%s]",IndexRegister (postbyte));	
			break;
		case 0x17:	/* ILLEGAL ADRESSING MODE */ 
			sprintf (Operands,"??");	
			break;
		case 0x18:	/* (+/- 7 bit offset),R */ 
			byte = CPU->ReadMem8 (Add+2);
			if (byte>127)
				signe = '-';byte=0x0100-byte;
			else
				signe = '+';
			sprintf (Operands,"[%c$%2.X,%s]",signe,byte,IndexRegister (postbyte));	
			extrabyte = 1;
			break;
		case 0x19:	/* (+/- 15 bit offset),R */ 
			word = CPU->ReadMem16 (Add+2);
			sprintf (Operands,"[$%.4X,%s]",word,IndexRegister (postbyte));	
			extrabyte = 2;
			break;
		case 0x1a:	/* ILLEGAL ADRESSING MODE */ 
			sprintf (Operands,"??");	
			break;
		case 0x1b:	/* [D,R] ->  FROM REGISTER */ 
			sprintf (Operands,"[D,%s]",IndexRegister(postbyte));	
			break;
		case 0x1c:	/* [(+/- 7 bit offset),PCR]  */ 
			byte = CPU->ReadMem8 (Add+2);
			if (byte>127)
				signe = '-';byte=0x0100-byte;
			else
				signe = '+';
			sprintf (Operands,"[%c$%.2X,PC]",signe,byte);	
			extrabyte = 1;
			break;
		case 0x1d:	/* [(+/- 15 bit offset),PCR]  */ 
			word = CPU->ReadMem16 (Add+2);
			sprintf (Operands,"[$%.4X,PC]",word);	
			extrabyte = 2;
			break;

		case 0x1e:	/* ILLEGAL ADRESSING MODE */ 
			sprintf (Operands,"??");	
			break;
		case 0x1f:	/* [XXXX]*/
			word = CPU->ReadMem16 (Add+2);
			sprintf (Operands,"[$%.4X]",word);	
			extrabyte = 2;
			break;
		default:
			sprintf (Operands,"UNSUPPORTED INDEXED ADRESSING MODE");	
			break;		
		}		
	}
	*Cycles_nbr = Op->Clock;
	return (Op->Size+extrabyte);
}
