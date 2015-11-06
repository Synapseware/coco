6809/6809E PROGRAMMlNG MODEL
============================

As shown in Figure 4, the MC6809E adds three registers to the set =
available=20 in the MC6800. The added registers include a direct page
register, the = user=20 stack pointer, and a second index register.

> **FIGURE 4 - PROGRAMMING MODEL OF THE=20 MICROPROCESSING UNIT**
>
>  
>
> 15
>
> 8
>
> 7
>
> 0
>
>  
>
> **X**
>
> **Index register**
>
>  
>
> **Y**
>
> **Index register**
>
>  
>
> **U**
>
> **User Stack Pointer**
>
>  
>
> **S**
>
> **Hardware Stack Pointer**
>
>  
>
> **PC**
>
> **Program Counter**
>
>  
>
> **D**
>
> **A**
>
> **B**
>
> Accumulators
>
>  
>
>  
>
>  
>
>  
>
>  
>
> **DP**
>
> **Direct Page**
>
>  
>
> -
>
> -
>
> -
>
> -
>
> -
>
> -
>
> -
>
> -
>
> -
>
>  
>
> A1
>
>  
>
> **CCR**
>
> **E**
>
> **F**
>
> **H**
>
> **I**
>
> **N**
>
> **Z**
>
> **V**
>
> **C**
>
> Condition Code Register

 

ACCUMULATORS (A, B, D)
----------------------

The A and B registers are general purpose accumulators which are used =
for=20 arithmetic calculations and manipulation of data.

Certain instructions concatenate the A and B registers to form a =
single=20 16-bit accumulator. This is referred to as the D register, and
is formed = with=20 the A register as the most significant byte.

DIRECT PAGE REGISTER (DP)
-------------------------

The direct page register of the MC6809E serves to enhance the direct=20
addressing mode. The content of this register appears at the higher =
address=20 outputs (A8-A15) during direct addressing instruction
execution. This = allows the=20 direct mode to be used at any place in
memory, under program control. To = ensure=20 M6800 compatibility, all
bits of this register are cleared during = processor=20 reset.

INDEX REGISTERS (X, Y)
----------------------

The index registers are used in indexed mode of addressing. The =
16-bit=20 address in this register takes part in the calculation of
effective = addresses.=20 This address may be used to point to data
directly or may be modified by = an=20 optional constant or register
offset. During some indexed modes, the = contents of=20 the index
register are incremented and decremented to point to the next = item
of=20 tabular type data. All four pointer registers (X, Y, U, S) may be
used = as index=20 registers.

STACK POINTER (U, S)
--------------------

The hardware stack pointer (S) is used automatically by the processor =
during=20 subroutine calls and interrupts. The user stack pointer (U) is
= controlled=20 exclusively by the programmer. This allows arguments to
be passed to and = from=20 subroutines with ease. The U register is
frequently used as a stack = marker. Both=20 stack pointers have the
same indexed mode addressing capabilities as the = X and Y=20 registers,
but also support push and pull instructions. This allows the =
MC6809E=20 to be used efficiently as a stack processor, greatly
enhancing its = ability to=20 support higher level languages and modular
programming.

> **NOTE**
>
> The stack pointers of the MC6809E point to the top of the stack in =
> contrast=20 to the MC6800 stack pointer, which pointed to the next
> free location = on=20 stock.

PROGRAM COUNTER (PC)
--------------------

The program counter is used by the processor to point to the address =
of the=20 next instruction to be executed by the processor. Relative
addressing is = provided allowing the program counter to be used like an
index register = in some=20 situations.

CONDITION CODE REGISTER (CCR)
-----------------------------

The condition code register defines the state of the processor at any =
given=20 time. See Figure 5

> **FIGURE 5 - CONDITION CODE REGISTER=20 FORMAT**

>   ------- ------- ------- ------- ------- ------- ------- ------- ---------------
>   7       6       5       4       3       2       1       0        
>   **E**   **F**   **H**   **I**   **N**   **Z**   **V**   **C**    
>   |       |       |       |       |       |       |       +       Carry
>   |       |       |       |       |       |       +       -       Overflow
>   |       |       |       |       |       +       -       -       Zero
>   |       |       |       |       +       -       -       -       Negative
>   |       |       |       +       -       -       -       -       !IRQ Mask
>   |       |       +       -       -       -       -       -       Half Carry
>   |       +       -       -       -       -       -       -       !FIRQ
>   +       -       -       -       -       -       -       -       Entire = Flag
>   ------- ------- ------- ------- ------- ------- ------- ------- ---------------
>
CONDITION CODE REGISTER = DESCRIPTION
-------------------------------------

> ### CARRY FLAG (C)
>
> > Bit 0 is the carry flag and is usually the carry from the binary =
> > ALU. C=20 is also used to represent a "borrow" from subtract like
> > instructions = (CMP,=20 NEG, SUB, SBCI and is the complement of the
> > carry from the binary=20 ALU.
>
> ### OVERFLOW FLAG (V)
>
> > Bit 1 is the overflow flag and is set to a one by an operation =
> > which=20 causes a signed two's complement overflow. This overflow is
> > detected = in an=20 operation in which the carry from the MSB in the
> > ALU does not match = the=20 carry from the MSB-1,
>
> ### ZERO FLAG (Z)
>
> > Bit 2 is the zero flag and is set to one if the result of the =
> > previous=20 operation was identical to zero.
>
> ### NEGATIVE FLAG (N)
>
> > Bit 3 is the negative flag, which contains exactly the value of =
> > the MSB=20 of the result of the preceding operation. Thus, a
> > negative two's = complement=20 result will leave N set to a one.
>
> ### !IRQ MASK (I)
>
> > Bit 4 is the !IRQ mask bit. The processor wiII not recognize =
> > interrupts=20 from the !IRQ line if this bit is set to a one. !NMI,
> > !IRQ, !FIRQ, = !RESET=20 and SWI set I to a one. SWI2 and SWI3 do
> > not affect = I.
>
> ### HALF CARRY (H)
>
> > Bit 5 is the half-carry bit, and is used to indicate a carry from =
> > bit 3=20 in the ALU as a result of an 8-bit addition only (ADC or
> > ADD). This = bit is=20 used by the DAA instruction to perform a BCD
> > decimal add adjust = operation.=20 The state of this flag is
> > undefined in all subtract-like=20 instructions.
>
> ### !FIRQ MASK (F)
>
> > Bit 6 is the !FIRQ mask bit. The processor wiII not recognize =
> > interrupts=20 from the F!IRQ line if this bit is set to a one. !NMI,
> > !FIRQ, !RESET = and SWI=20 set F to a one. !IRQ, SWI2 and SWI3 do
> > not affect = I.
>
> ### ENTIRE FLAG (E)
>
> > Bit 7 is the entire flag, and when set to a one indicates that =
> > the=20 complete machine state (all the registers) was stacked, as
> > opposed = to the=20 subset state (PC and CC). The E bit of the
> > stacked CC is used on a = return=20 from interrupt (RTI) to
> > determine the extent of the unstacking. = Therefore,=20 the current
> > E left in the condition code register represents past = action.=20
