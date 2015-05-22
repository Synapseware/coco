6809 INSTRUCTION SET
====================

The instruction set of the MC6809E is similar to that of the MC6800 =
and is=20 upward compatible at the source code level. The number of
opcodes has = been=20 reduced from 72 to 59, but because of the expanded
architecture and = additional=20 addressing modes, the number of
available opcodes (with different = addressing=20 modes) has risen from
197 to 1464.\
Some of the new instructions are = described=20 in detail below.

PSHU/PSHS
---------

The push instructions have the capability of pushing onto either the =
hardware=20 stack (S) or user stack (U) any single register or set of
registers with = a=20 single instruction.

PULU/PULS
---------

The pull instructions have the same capability of the push =
instruction, in=20 reverse order. The byte immediately following the
push or pull opcode = determines=20 which register or registers are to
be pushed or pulled. The actual = push/pull=20 sequence is fixed; each
bit defines a unique register to push or pull, = as shown=20 below.

Push/Pull Post=20 Byte
----------------------

  --- --- --- --- --- --- --- --- -----
  7   6   5   4   3   2   1   0    
                                   
  |   |   |   |   |   |   |   +   CCR
  |   |   |   |   |   |   +   -   A
  |   |   |   |   |   +   -   -   B
  |   |   |   |   +   -   -   -   DPR
  |   |   |   +   -   -   -   -   X
  |   |   +   -   -   -   -   -   Y
  |   +   -   -   -   -   -   -   S/U
  +   -   -   -   -   -   -   -   PC
  --- --- --- --- --- --- --- --- -----

Push/Pull=20 Order
------------------

**Pull=20 Order**

**CC**

Increasing

|

**A**

memory

v

**B**

|

 

**DP**

v

 

**X=20 Hi**

 

 

**X=20 Lo**

 

 

**Y=20 Hi**

 

 

**Y=20 Lo**

 

 

**U/S=20 Hi**

 

\^

**U/S=20 Lo**

 

|

**PC=20 Hi**

 

**Push=20 Order**

**PC=20 Lo**

=

 

TFR/EXG
-------

Within the MC6809E, any register may be transferred to or exchanged =
with=20 another of like size; i.e. 8-bit to 8-bit or 16-bit to 16-bit. \
Bits = 4-7 of=20 postbyte define the source register, while bits 0-3
represent the = destination=20 register. These are denoted as follows:

Transfer/Exchange Post Byte
---------------------------

7

6

5

4

3

2

1

0

**Srce**

**Dest**

Register Field
--------------

  --- --- --- --- -------------
  0   0   0   0   **D (A,B)**
  0   0   0   1   **X**
  0   0   1   0   **Y**
  0   0   1   1   **U**
  0   1   0   0   **S**
  0   1   0   1   **PC**
  --- --- --- --- -------------

  --- --- --- --- ---------
  1   0   0   0   **A**
  1   0   0   1   **B**
  1   0   1   0   **CCR**
  1   0   1   1   **DPR**
  --- --- --- --- ---------

**NOTE:\
**All other = combinations are=20 undefined and INVALID

LEAX/LEAY/LEAU/LEAS
-------------------

The LEA (Load Effective Address) works by calculating the effective =
address=20 used in an indexed instruction and stores that address value,
rather = than the=20 data at that address, in a pointer register. This
makes all the features = of the=20 internal addressing hardware
available to the programmer. Some of the=20 implications of this
instruction are illustrated in Table 3

The LEA instruction also allows the user to access data and tables in =
a=20 position independent manner. For example:

>     LEAX MSG1, PCR
>     LBSR PDATA          (Print message routine)
>     MSG1 FCC 'MESSAGE'

This sample program prints 'MESSAGE'. By writing MSG1, PCR, the
assembler computes the = distance between=20 the present address and
MSG1. This = result is=20 placed as a constant into the LEAX =
instruction=20 which will be indexed from the PC value at the time of
execution. No = matter=20 where the code is located when it is executed,
the computed offset from = the PC=20 will put the absolute address of
MSG1 = into the X=20 pointer register. This code is totally
position-independent.

The LEA instructions are very powerful and use an internal holding =
register=20 (temp). Care must be exercised when using the LEA
instructions with the = auto=20 increment and auto decrement addressing
modes due to the sequence of = internal=20 operations. The LEA internal
sequence is outlined as follows:

>     LEAa,b+ (any of the 18 bit pointer registers X, Y, U, =
>     or S may be substituted for a and b.)
>
>     1. b    =3D> temp        =
>     (calculate the EA)
>     2. b+1  =3D> b       (modify b, postincrement)
>     3. temp =3D> a       (load a)
>
>     LEAa, - b
>
>     1. b-1  =
>     =3D> temp        (calculate EA with predecrement)
>     2. b-1  =3D> b       (modify b, predecrement)
>     3. temp =3D> a       (load a)

**TABLE 3 - LEA=20 EXAMPLES**

  ----------------- ----------------- --------------------------------
  **Instruction**   **Operation**     **Comment**
  LEAX 10,X         X + 10 =3D\> X    Adds 5-Bit Constant 10 to X
  LEAX 500,X        X + 500 =3D\> X   Adds 15-Bit Constant 500 to X
  LEAY A,Y          Y + A =3D\> Y     Adds 8-Bit A Accumulator to Y
  LEAY D,Y          Y + D =3D\> Y     Adds 16-Bit D Accumulator to Y
  LEAU -10,U        U - 10 =3D\> U    Subtracts 10 from U
  LEAS -10,S        S - 10 =3D\> S    Used to Reserve Area on Stack
  LEAS 10,S         S + 10 =3D\> S    Used to 'Clean Up' Stack
  LEAX 5,S          S + 5 =3D\> S     Transfers As Well As Adds
  ----------------- ----------------- --------------------------------

Auto increment-by-two and auto decrement-by-two instructions work =
similarly.=20 Note that LEAX,X+ does not change X; however LEAX, - X
does decrement X. = LEAX=20 1,X should be used to increment X by one.

MUL=20
------

Multiplies the unsigned binary numbers in the A and B accumulator and =
places=20 the unsigned result into the 16-bit D accumulator. This
unsigned = multiply also=20 allows multiple-precision muitiplications.

LONG AND=20 SHORT RELATIVE BRANCHES
-----------------------------------

The MC6809E has the capability of program-counter relative branching=20
throughout the entire memory map. In this mode, if the branch is to be =
taken,=20 the 8- or 16-bit signed offset is added to the value of the
program = counter to=20 be used as the effective address. This allows
the program to branch = anywhere in=20 the 64K memory map. Position
independent code can be easily generated = through=20 the use of
relative branching. Both short (8 bit) and long (16 bit) = branches
are=20 available

SYNC
----

After encountering a sync instruction, the MPU enters a sync state, =
stops=20 processing instructions, and waits for an interrupt. If the
pending = interrupt is=20 non-maskable (!NMI) l or maskable (!FIRQ, =
!IRQ) with=20 its mask bit (F or l) clear, the processor will cear the
sync state and = perform=20 the normal interrupt stacking and service
routine. Since !FIRQ and !IRQ are not edge triggered, a low level = with
a=20 minimum duration of three bus cydes is required to assure that the
= interrupt=20 will be taken. If the pending interrupt is maskable
(!FIRQ, !IRQ) with = its mask=20 bit (F or I) set, the processor will
clear the sync state and continue=20 processing by executing the next
in-line instruction. Figure 16 depicts = sync=20 timing.

SOFTWARE=20 INTERRUPTS
----------------------

A software interrupt is an instruction which will cause an interrupt =
and its=20 associated vector fetch. These software interrupts are useful
in = operating=20 system calls, software debugging, trace operations,
memory mapping, and = software=20 development systems. Three levels of
SWI are available on the MC6809E = and are=20 prioritized in the
following order: SWI, SWI2, SWI3.

16-BIT OPERATION=20
-------------------

The MC6809 has the capability of processing 16-bit data. Thee =
instructions=20 include loads. stores, compares, adds, subtracts,
transfers. exchanges, = pushes,=20 and pulls.

CYCLE-BY-CYCLE=20 OPERATION
---------------------------

The address-bus cycle-by-cycle performance chart (Figure 16) =
illustrates the=20 memory-access sequence corresponding to each possible
instruction and = addressing=20 mode in the MC6809E. Each instruction
begins with an opcode fetch. While = that=20 opcode is being internally
decoded. the next program byte is always = fetched.=20 Most instructions
will use the next byte, so this technique considerably = speeds=20
throughput) Next, the operation of each opcode will follow the =
flowchart. !VMA=20 is an indication of \$FFFF on the address bus, R/!W
=3D 1 and BS =3D 0. = The following=20 examples illustrate the use of
the chart.

**Example 1: LBSR (Branch Taken) Before = Execution=20 SP =3D F000**

  -------- ----- ------ -----
  \$8000         LBSR   CAT
                 ...     
  \$A000   CAT   ...     
                 ...     
  -------- ----- ------ -----

**CYCLE-BY-CYCLE FLOW**

  ------------- ------------- ---------- ---------- -----------------------------------------
  **Cycle\#**   **Address**   **Data**   **R/!W**   **Description**
  1             8000          17         1          Opcode fetch
  2             8001          20         1          Offset high byte
  3             8002          00         1          Offset low byte
  4             FFFF          \*         1          !VMA cycle
  5             FFFF          \*         1          !VMA cycle
  6             A000          \*         1          Computed branch address
  7             FFFF          \*         1          !VMA cycle
  8             EFFE          80         0          Stack high order byte of return address
  9             EFFE          03         0          Stack low order byte of return address
  ------------- ------------- ---------- ---------- -----------------------------------------

**Example 2: DEC = (Extended)**

  -------- ----- ------ --------
  \$8000         DEC    \$A000
                 ...     
  \$A000   FCB   \$80    
                 ...     
  -------- ----- ------ --------

**CYCLE-BY-CYCLE FLOW**

  ------------- ------------- ---------- ---------- ----------------------------
  **Cycle\#**   **Address**   **Data**   **R/!W**   **Description**
  1             8000          7A         1          Opcode fetch
  2             8001          A0         1          Operand address, high byte
  3             8002          00         1          Operand address, low byte
  4             FFFF          \*         1          !VMA cycle
  5             A000          80         1          Read the data
  6             FFFF          \*         1          !VMA cycle
  7             EFFE          7F         0          Store the decremented data
  ------------- ------------- ---------- ---------- ----------------------------

\* The data bus has the data at that particular = address.

INSTRUCTION = SET=20 TABLES
---------------------------

The instructions of the MC6809E have been broken down into five =
different=20 categories. They are as follows:

-   8-bit operation (Table 4)=20
-   15-bit operation (Table 5)=20
-   Index register/stack pointer instructions (Table 8)=20
-   Relative branches (long or short) (Table 7)=20
-   Miscellaneous instructions (Table 8)

Hexedecimal values for the instructions are given in Table 9.

PROGRAMMING=20 AID
------------------

Figure 18 contains a compilation of data that will assist you in =
programming=20 the MC6809E.

FIGURE=20 17 - CYCLE-BY-CYCLE PERFORMANCE (Sheet 1 of 5)

**Notes**

1.  Each state shows
      ------------- --------------------
      Data bus      **Offset=20 High**
      Address bus   **NNN+ 1=20 (2)**
      ------------- --------------------

2.  Address NNNN is a location of opcode=20
3.  If opcode is a two-byte opcode subsequent addresses are in =
    parentheses=20 (-).=20
4.  Two-byte opcodes are highlighted.

FIGURE=20 17 - CYCLE-BY-CYCLE PERFORMANCE (Sheet 2 of 5)\
FIGURE=20 17 - CYCLE-BY-CYCLE PERFORMANCE (Sheet 3 of 5)\
FIGURE=20 17 - CYCLE-BY-CYCLE PERFORMANCE (Sheet 4 of 5)\
FIGURE=20 17 - CYCLE-BY-CYCLE PERFORMANCE (Sheet 5 of = 5)
