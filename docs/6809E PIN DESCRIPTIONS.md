6809E PIN DESCRIPTIONS
======================

POWER (V~SS~, = V~CC~)
----------------------

Two pins are used to supply power to the part; V~SS~ is = ground or 0=20
volts, while V~CC~ is + 5.0 V =B15%

ADDRESS BUS (A0-15)
-------------------

Sixteen pins are used to output address information from the MPU onto =
the=20 address bus. When the processor does not require the bus for a
data = transfer, it=20 will output address FFFFh, R/!W =3D 1, and BS =3D
0; this is a "dummy = access" or=20 !VMA cycle. All address bus drivers
are made high-impedance when output = bus=20 available (BA) is high or
when TSC is asserted. Each pin will drive one = Schottky=20 TTL load or
four LS TTL loads and 90 pF.

DATA BUS (D0-7)
---------------

These eight pins provide communication with the system bidirectional =
data=20 bus. Each pin will drive one Schottky TTL load or four LS TTL
loads and = 130=20 pF.

READ/WRITE (R/!W)
-----------------

This indicates the direction of data transfer on the data bus. A low=20
indicates that the MPU is writing data onto the data bus. R/!W is made =
high=20 impedance when BA is high or when TSC is asserted.

!RESET
------

A low level on this Schrnitt-trigger input for greater than one bus =
cyde will=20 reset the MPU, as shown in Figure 6. The reset vectors are
fetched from=20 locations FFFEh and FFFFh (Table 1) when interrupt
acknowledge is true, = (BA=20 & BS =3D 1). During initial power on, the
reset line should be held = low until=20 the clock input signals are
fully operational.

Because the !RESET pin has a Schmitt-trigger input with a threshold =
voltage=20 higher than that of standard peripherals, a simple R/C
network may be = used to=20 reset the entire system. This higher
threshold voltage ensures that all=20 peripherals are out ot the reset
state before the processor.

!HALT
-----

A low level on this input pin will cause the MPU to stop running at =
the end=20 of the present instruction and remain halted indefinitely
without loss = of data.=20 When halted, the BA output is driven high
indicating the buses are high=20 impedance. BS is also high which
indicates the processor is in the halt = state.=20 While halted, the MPU
will not respond to external real-time requests = (!FIRQ,=20 !IRQ)
although !NMI or !RESET will be latched for later response. During =
the=20 halt state, Q and E should continue to run normally. A halted
state (BA = & BS=20 =3D 1) can be achieved by pulling HALT low while
!RESET is still low. = See Figure=20 7.

BUS AVAILABLE, BUS STATUS (BA, BS)
----------------------------------

The bus available output is an indication of an internal control =
signal which=20 makes the MOS buses at the MPU high impedance. When BA
goes low, a dead = cycle=20 will elapse before the MPU acquires the bus.
BA will not be asserted = when TSC is=20 active, thus allowing dead
cycle consistency. The bus status output = signal, when=20 decoded with
BA, represents the MPU state (valid with leading edge of = Q).

> **MPU\
> State**
> **MPU State=20 Definition**
> BA
> BS
> 0
> 0
> Normal (Running)
> 0
> 1
> Interrupt or Reset Acknowledge
> 1
> 0
> Sync Acknowledge
> 1
> 1
> Halt Acknowledge

Interrupt Acknowledge is indicated during both cycles of a hardware =
vector=20 fetch (!RESET, !NMI, !FIRQ, !IRQ, SWI, SWI2, SWI3). This
signal, plus = decoding=20 of the lower four address lines, can provide
the user with an indication = of=20 which interrupt level is being
serviced and allow vectoring by device. = See Table=20 1.

> **TABLE=20 1****- MEMORY MAP FOR = INTERRUPT=20 VECTORS**

> **Address**
> **Interrupt Vector=20 Description**
> MS
> LS
> FFF0
> FFF1
> Reserved
> FFF2
> FFF3
> SWI3
> FFF4
> FFF5
> SWI2
> FFF6
> FFF7
> FIRQ
> FFF8
> FFF9
> IRQ
> FFFA
> FFFB
> SWI
> FFFC
> FFFD
> NMI
> FFFE
> FFFF
> RESET

Sync Acknowledge is indicated while the MPU is waiting for external=20
synchronization on an interrupt line.\
Halt Acknowledge is indicated = when the=20 MC6809E is in a halt
condition.

NON MASKABLE INTERRUPT (!NMI) \<= FONT=20 color=3D\#0000ff\>\*
--------------------------------------------------------------

A negative transition on this input requests that a non-maskable =
interrupt=20 sequence be generated. A non-maskable interrupt cannot be
inhibited by = the=20 program and also has a higher priority than !FIRO,
!IRQ, or software = interrupts.=20 During recognition of an NMI, the
entire machine state is saved on the = hardware=20 stack. After reset,
an NMI will not be recognized until the first = program load=20 of the
hardware stack pointer (S). The pulse width of !NMI low must be = at
least=20 one E cycle. If the !NMI input does not meet the minimum set up
with = respect to=20 Q, the interrupt will not be recognized until the
next cycle See Figure = 8.

FAST-INTERRUPT REQUEST (!FIRQ) \<= FONT=20 color=3D\#0000ff\>\*
---------------------------------------------------------------

A low level on this input pin will initiate a fast interrupt =
sequence,=20 provided its mask bit (F) in the CC is clear This sequence
has priority = over the=20 standard interrupt request (!IRQ) and is fast
in the sense that it = stacks only=20 the contents at the condition code
register and the program counter. The = interrupt service routine should
clear the source of the interrupt = before doing=20 an RTI. See Figure
9.

INTERRUPT REQUEST (!IRQ) \<= FONT=20 color=3D\#0000ff\>\*
---------------------------------------------------------

A low level input on this pin will initiate an interrupt request =
sequence=20 provided the mask bit (l) in the CC is clear. Since !IRQ
stacks the = entire=20 machine state, it provides a slower response to
interrupts than !FIRQ. = !IRQ also=20 provides a lower priority than
!FIRQ, Again, the interrupt service = routine=20 should clear the source
of the interrupt before doing an RTI. See Figure = 8.

CLOCK = INPUTS E, Q
-------------------

E and Q are the clock signals required by the MC6809E. Q must lead E, =
that=20 is, a transition on Q must be followed by a similar transition
on E = after a=20 minimum delay. Addresses will be valid from the MPU,
t~AD~ = after the=20 falling edge of E, and data will be latched from
the bus by the falling = edge of=20 E. While the Q input is fully TTL
compatible, the E input directly = drives=20 internal MOS circuitry and,
thus, requires a high level above normal TTL = levels.=20 This approach
minimizes clock skew inherent with an internal buffer. = Refer to=20 BUS
TIMING CHARACTERISTICS for E and Q and to Figure 10 which shows a =
simple=20 clock generator for the MC6809E.

BUSY
----

BUSY will be high for the read and modify cycles of a =
read-modify-write=20 instruction and during the access of the first byte
at a double-byte = operation=20 (e.g., LDX, STD, ADDD). BUSY is also
high during the first byte of any = indirect=20 or other vector fetch
(e.g., jump extended, SWI indirect, etc).

In a multiprocessor system, BUSY indicates the need to defer the=20
rearbitration of the next bus cycle to insure the integrity of the above
= operations. This difference provides the indivisible memory access =
required tor=20 a "test-and-set" primitive, using any one of several
read-modify-write=20 instructions.

BUSY does not become active during PSH or PUL operations. A typical=20
read-modify-write instruction (ASL) is shown in Figure 11. Timing =
information is=20 given in Figure 12. BUSY is valid t~CD~ after the
rising edge = of Q.

AVMA
----

AVMA is the advanced VMA signal and indicates that the MPU will use =
the bus=20 in the following bus cycle. The predictive nature of the AVMA
signal = allows=20 efficient shared-bus multiprocessor systems. AVMA is
low when the MPU is = in=20 either a HALT or SYNC state. AVMA is valid
t~CD~ after the = rising edge=20 of Q.

LIC
---

LIC (last instruction cycle) is high during the last cycle of every=20
instruction, and its transition from high to low will indicate that the
= first=20 byte at an opcode will bc latched at the end of the present
bus cycle. = LIC will=20 be high when the MPU is halted at the end of an
instruction (i.e., not = in CWAI,=20 or RESET), in sync state, or while
stacking during interrupts. LIC is = valid=20 t~CD~ atter the rising
edge of Q.

TSC
---

TSC (three-state control) will cause MOS address, data, and R/W =
buffers to=20 assume a high-impedance state. The control signals (BA,
BS, BUSY, AVMA, = and LIC)=20 will not go to the high-impedance state.
TSC is intended to allow a = single bus=20 to be shared with other bus
masters (processors or DMA controllers).

While E is low, TSC controls the address buffers and R/!W directly. =
The data=20 bus buffers during a write operation are in a high-impedance
state until = Q rises=20 at which time, if TSC is true, they will remain
in a hiph-impedance = state. If=20 TSC is held beyond the rising edge of
E, then it will be internally = latched,=20 keeping the bus drivers in a
high-impedance state for the remainder ot = the bus=20 cycle. See Figure
13.

* * * * *

> **Note**
>
> !FIRQ, and !IRQ requests are sampled on the falling edqe of Q. One =
> cycle is=20 required for synchronisation before these interrupts are
> recognised. = The=20 pending interrupts will not be serviced until
> completion of the = current=20 instruction unless a SYNC or CWAl
> instruction is present lf !IRQ and = !FIRQ do=20 not remain low until
> completion of the current instruction, they may = not be=20
> recognised. However, !NMI is latched and need only remain low for one
> = cycle.=20 No interrupts are recognized or latched between the
> falling edge of = end the=20 rising edge of BS indicating !RESET
> acknowledge. See RESET sequence in = the MPU=20 flowchart in Figure
> 14.
