6809 INSTRUCTION TABLES 4 TO 8
==============================

* * * * *

TABLE 4=20 - 8-BIT ACCUMULATOR AND MEMORY INSTRUCTIONS
------------------------------------------------------

  ----------------- ----------------------------------------------------
  ADCA, ADCB        Add memory to accumulator with carry
  ADDA, ADDB        Add memory to accumulator
  ANDA, ANDB        AND memory to accumulator
  ASL. ASLA, ASLB   Arithmetic shift of accumulator or memory left
  ASR, ASRA, ASRB   Arithmetic shift of accumulator or memory right
  BITA, BITB        Bit test memory with accumulator
  CLR, CLRA, CLRB   Clear accumulator or memory location
  CMPA, CMPB        Compare memory from accumulator
  COM, COMA, COMB   Complement accumulator or memory location
  DAA               Decimal Adjust Accumulator
  DEC, DECA, DECB   Decrement accumulator or memory location
  EORA, EORB        Exclusive-OR memory with accumulator
  EXG R1, R2        Exchange R1 with R2 (R1, R2 =3D A, B, CC, DP)
  INC, INCA, INCB   Increment accumulator or memory location
  LDA, LDB          Load accumulator from memory
  LSL, LSLA, LSLB   Logical shift left accumulator or memory location
  LSR, LSRA, LSRB   Logical shift right accumulator or memory location
  MUL               Unsiqned multiply (A x B =3D\> D)
  NEG, NEGA, NEGB   Negate accumulator or memory
  ORA, ORB          Or memory with accumulator
  ROL, ROLA, ROLB   Rotate accumulator or memory left
  ROR, RORA, RORB   Rotate accumulator or memory right
  SBCA, SBCB        Subtract memory from accumulator with borrow
  STA, STB          Store accumulator to memory
  SUBA, SUBB        Subtract memory from accumulator
  TST, TSTA, TSTB   Test accumulator or memory location
  TFR R1, R2        Transfer R1 to R2 (R1, R2 =3D A, B, CC, = DP)
  ----------------- ----------------------------------------------------

NOTE: A, B, CC or DP may be pushed to (or pulled from) either stack =
with=20 PSHS, PSHU (PULS, PULU) instructions.

* * * * *

TABLE 5=20 - 16-BIT ACCUMULATOR AND MEMORY INSTRUCTIONS
-------------------------------------------------------

  ---------- ----------------------------------------------
  ADDD       Add memory to D accumulator
  CMPD       Compare memory from D accumulator
  EXG D, R   Exchange D with X, Y, S, U or PC
  LDD        Load D accumulator from memory
  SEX        Sign Extend B accumulator into A accumulator
  STD        Store D accumulator to memory
  SUBD       Subtract memory from D accumulator
  TFR D, R   Transfer D to X, Y, S, U or PC
  TFR R, D   Transfer X, Y, S, U or PC to D
  ---------- ----------------------------------------------

NOTE: D may be pushed to (or pulled from) either = stack with=20 PSHS,
PSHU (PULS,PULU) instructions.

* * * * *

TABLE 6=20 - INDEX REGISTER / STACK POINTER INSTRUCTIONS
--------------------------------------------------------

  ------------ ---------------------------------------------------------------------
  CMPS, CMPU   Compare memory from stack pointer
  CMPX, CMPY   Compare memory from index register
  EXG R1, R2   Exchange D, X, Y, S, U or PC wth D, X, Y, S, U or PC
  LEAS, LEAU   Load effective address into stack pointer
  LEAX, LEAY   Load effective address into index register
  LDS, LDU     Load stack pointer from memory
  LDX, LDY     Load index register from memory
  PSHS         Push A, B, CC, DP, D, X, Y, **U**, or PC onto=20 **hardware** stack
  PSHU         Push A, B, CC, DP, D, X, Y, **S**, or PC onto=20 **user** stack
  PULS         Pull A, B, CC, DP, D, X, Y, **U**, or PC from=20 **hardware** stack
  PULU         Pull A, B, CC, DP, D, X, Y, **S**, or PC from=20 **user** stack
  STS, STU     Store stack pointer to memory
  STX, STY     Store index register to memory
  TFR R1, R2   Transfer D, X, Y, S, U or PC to D, X, Y, S, U or PC
  ABX          Add B accumulator to X (unsigned)
  ------------ ---------------------------------------------------------------------

* * * * *

TABLE 7=20 - BRANCH INSTRUCTIONS
--------------------------------

  ----------- ------------------------------------------
              **SIMPLE = BRANCHES**
  BEG, LBEQ   Branch if equal
  BNE, LBNE   Branch if not equal
  BMI, LBMI   Branch if minus
  BPL, LBPL   Branch if plus
  BCS, LBCS   Branch if carry set
  BCC, LBCC   Branch if carry clear
  BVS, LBVS   Branch if overflow set
  BVC, LBVC   Branch if overflow clear
              **SIGNED = BRANCHES**
  BGT, LBGT   Branch if greater (signed)
  BVS, LBVS   Branch if invalid 2's complement result
  BGE, LBGE   Branch if greater than or equal (signed)
  BEQ, LBEQ   Branch if equal
  BNE, LBNE   Branch if not equal
  BLE, LBLE   Branch if less than or equal (signed)
  BVC, LBVC   Branch if valid 2's complement result
  BLT, LBLT   Branch if less than (signed)
              **UNSIGNED = BRANCHES**
  BHI, LBHI   Branch if higher (unsigned)
  BCC, LBCC   Branch if higher or same (unsigned)
  BHS, LBHS   Branch if higher or same (unsigned)
  BEQ, LBEQ   Branch if equal
  BNE, LBNE   Branch if not Equal
  BLS, LBLS   Branch if lower or same (unsigned)
  BCS, LBCS   Branch if lower (unsigned)
  BL0, LBLO   Branch it lower (unsigned)
              **OTHER = BRANCHES**
  BSR, LBSR   Branch to subroutine
  BRA, LBRA   Branch always
  BRN, LBRN   Branch never
  ----------- ------------------------------------------

* * * * *

TABLE 8=20 - MISCELLANEOUS INSTRUCTIONS
---------------------------------------

  ----------------- -------------------------------------------------------
  ANDCC             AND Condition Code Register
  CWAI              AND Condition Code Register, then wait for interrupt.
  NOP               No Operation
  ORCC              OR Condition Code Register
  JMP               Jump
  JSR               Jump to subroutine
  RTI               Return from Interrupt
  RTS               Return from Subroutine
  SWI, SWI2, SWI3   Software Interrupt (absolute indirect)
  SYNC              Synchronise with Interrupt = line
  ----------------- -------------------------------------------------------


