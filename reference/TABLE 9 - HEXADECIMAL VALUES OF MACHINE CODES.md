TABLE 9 - HEXADECIMAL VALUES OF MACHINE=20 CODES
------------------------------------------------

Opcodes
-------

The Opcode and Mnemonics opcode reference = tables are both=20 complete
listings that contain both the Opcode instruction and the HEX=20
equivalant in all available addressing modes. The first table is =
arranged=20 sequentially by the binary opcodes, while the second table
is arranged=20 alphabetically by the Mnemonic instructions.

At the end of the second table there are data = tables=20 containing
information on Bit transfer/manipulation, branch = instructions,=20
inter-register instructions, and general register and stack information.
= These=20 are all helpful to the serious assembly language programmer,
who should = always=20 have one.

Where the 6309 differs from the 6809, the 6309 = specific=20 details are
highlighted in turquoise.

6309 Instructions generally take one less = instruction=20 cycle to
execute than the 6809.\
This makes the 6309 run twice as fast = as the=20 6809 for many
instructions!

* * * * *

### Opcode tables=20 (00-1F)

**Op**

**Mnem**

**Mode**

**\~**

 

**\#**

00

NEG

Direct

6

5

2

01

OIM

-

6

3

02

AIM

-

6

3

03

COM

6

5

2

04

LSR

6

5

2

05

EIM

-

6

3

06

ROR

6

5

2

07

ASR

6

5

2

08

ASL, LSL

6

5

2

09

ROL

6

5

2

0A

DEC

6

5

2

0B

TIM

-

6

-?

0C

INC

6

5

2

0D

TST

6

4

2

0E

JMP

3

2

2

0F

CLR

6

5

2

  -------- ----------- ---------- -------- --- --------
  **Op**   **Mnem**    **Mode**   **\~**       **\#**
  10       Page=20 2   -          -            -
  11       Page=20 3   -          -            -
  12       NOP         Inherent   2        1    
  13       SYNC        Inherent   \>=3D4   1   11
  14       SEXW        Inherent   -        4   1
  15       -           -          -            -
  16       LBRA        Relative   5        4   3
  17       LBSR        Relative   9        7   3
  18       -           -          -            -
  19       DAA         Inherent   2        1   1
  1A       ORCC        Immed.     3        2   2
  1B       -           -          -            -
  1C       ANDCC       Immed.     3            2
  1D       SEX         Inherent   2        1   1
  1E       EXG         Immed.     8        5   2
  1F       TFR         Immed.     6        4   2
  -------- ----------- ---------- -------- --- --------

* * * * *

### Opcode tables=20 (20-3F)

**Op**

**Mnem**

**Mode**

**\~**

**\#**

20

BRA

Relative

3

2

21

BRN

22

BHI

23

BLS

24

BHS, BCC

25

BLO, BCS

26

BNE

27

BEQ

28

BVC

29

BVS

2A

BPL

2B

BMI

2C

BGE

2D

BLT

2E

BGT

2F

BLE

**Op**

**Mnem**

**Mode**

**\~**

 

**\#**

30

LEAX

Indexed

4+

2

31

LEAY

32

LEAS

33

LEAU

34

PSHS

Immediate

5+

4+

2

35

PULS

36

PSHU

37

PULU

38

-

-

-

-

 

39

RTS

Inherent

5

1

1

3A

ABX

3

1

1

3B

RTI

6/15

17

1

3C

CWAI

Immediate

22

20

2

3D

MUL

Inherent

11

10

1

3E

-

-

-

-

 

3F

SWI

Inherent

19

21

1

* * * * *

### Opcode tables=20 (40-5F)

**Op**

**Mnem**

**Mode**

**\~**

 

**\#**

40

NEGA

Inherent

2

1

1

41

-

42

-

43

COMA

44

LSRA

45

-

46

RORA

47

ASRA

48

ASLA/LSLA

49

ROLA

4A

DECA

4B

 

4C

INCA

4D

TSTA

4E

 

4F

CLRA

**Op**

**Mnem**

**Mode**

**\~**

 

**\#**

50

NEGB

Inherent

2

1

1

51

 

52

 

53

COMB

54

LSRB

55

 

56

RORB

57

ASRB

58

ASLB/LSLB

59

ROLB

5A

DECB

5B

 

5C

INCB

5D

TSTB

5E

 

5F

CLRB

* * * * *

### Opcode tables=20 (60-7F)

**Op**

**Mnem**

**Mode**

**\~**

 

**\#**

60

NEG

Indexed

6+

2+

61

OIM

-

6+

3+

62

AIM

-

7

3+

63

COM

6+

2+

64

LSR

65

EIM

-

7+

3+

66

ROR

6+

2+

67

ASR

68

ASL/LSL

69

ROL

6A

DEC

6+

2+

6B

TIM

-

7+

3+

6C

INC

6+

2+

6D

TST

3+

5+

2+

6E

JMP

6+

2+

6F

CLR

6+

2+

**Op**

**Mnem**

**Mode**

**\~**

 

**\#**

70

NEG

Extended

7

6

3

71

OIM

-

7

4

72

AIM

-

7

4

73

COM

7

6

3

74

LSR

75

EIM

-

7

4

76

ROR

7

6

3

77

ASR

78

ASL/LSL

79

ROL

7A

DEC

7B

TIM

-

7

4

7C

INC

7

6

3

7D

TST

7

5

3

7E

JMP

4

3

3

7F

CLR

7

6

3

* * * * *

### Opcode tables=20 (80-9F)

**Op**

**Mnem**

**Mode**

**\~**

 

**\#**

80

SUBA

Immediate

2

2

81

CMPA

82

SBCA

83

SUBD

4

3

3

84

ANDA

2

2

85

BITA

86

LDA

87

 

 

-

 

88

EORA

Immediate

2

2

89

ADCA

2

2

8A

ORA

2

2

8B

ADDA

2

2

8C

CMPX

4

3

3

8D

BSR

Relative

7

6

2

8E

LDX

Immediate

3

3

8F

 

 

 

 

**Op**

**Mnem**

**Mode**

**\~**

 

**\#**

90

SUBA

Direct

4

3

2

91

CMPA

4

3

92

SBC

4

3

93

SUBD

6

4

94

ANDA

4

3

95

BITA

4

3

96

LDA

4

3

97

STA

4

3

98

EORA

4

3

99

ADCA

4

3

9A

ORA

4

3

9B

ADDA

4

3

9C

CMPX

6

4

9D

JSR

7

6

9E

LDX

5

4

9F

STX

5

4

* * * * *

### Opcode tables=20 (A0-BF)

**Op**

**Mnem**

**Mode**

**\~**

 

**\#**

A0

SUBA

Indexed

4+

2+

A1

CMPA

4+

A2

SBCA

4+

A3

SUBD

6+

5+

A4

ANDA

4+

A5

BITA

4+

A6

LDA

4+

A7

STA

4+

A8

EORA

4+

A9

ADCA

4+

AA

ORA

4+

AB

ADDA

4+

AC

CMPX

6+

5+

AD

JSR

7+

6+

AE

LDX

5+

AF

STX

5+

**Op**

**Mnem**

**Mode**

**\~**

 

**\#**

B0

SUBA

Extended

5

4

3

B1

CMPA

5

4

B2

SBCA

5

4

B3

SUBD

5

4

B4

ANDA

5

4

B5

BITA

5

4

B6

LDA

5

4

B7

STA

5

4

B8

EORA

5

4

B9

ADCA

5

4

BA

ORA

5

4

BB

ADDA

5

4

BC

CMPX

7

5

BD

JSR

8

7

BE

LDX

6

5

BF

STX

6

5

* * * * *

### Opcode tables=20 (C0-DF)

**Op**

**Mnem**

**Mode**

**\~**

**\#**

C0

SUBB

Immediate

2

2

C1

CMPB

C2

SBCB

C3

ADDD

4

3

3

C4

ANDB

2

2

C5

BITB

C6

LDB

C7

 

 

 

 

C8

EORB

Immediate

2

2

C9

ADCB

CA

ORB

CB

ADDB

CC

LDD

3

3

CD

LDQ

5

5

CE

LDU

3

3

CF

 

 

 

 

**Op**

**Mnem**

**Mode**

**\~**

 

**\#**

D0

SUBB

Direct

4

3

2

D1

CMPB

D2

SBCB

D3

ADDD

6

4

D4

ANDB

4

3

D5

BITB

D6

LDB

D7

STB

D8

EORB

D9

ADCB

DA

ORB

DB

ADDB

DC

LDD

5

4

DD

STD

DE

LDU

DF

STU

* * * * *

### Opcode table=20 (E0-FF)

**Op**

**Mnem**

**Mode**

**\~**

 

**\#**

E0

SUBB

Direct

4+

2+

E1

CMPB

E2

SBCB

E3

ADDD

6+

5+

E4

ANDB

4+

E5

BITB

E6

LDB

E7

STB

E8

EORB

E9

ADCB

EA

ORB

EB

ADDB

EC

LDD

5+

ED

STD

EE

LDU

EF

STU

**Op**

**Mnem**

**Mode**

**\~**

 

**\#**

F0

SUBB

Extended

5

4

3

F1

CMPB

F2

SBCB

F3

ADDD

7

5

F4

ANDB

5

4

F5

BITB

F6

LDB

F7

STB

F8

EORB

F9

ADCB

FA

ORB

FB

ADDB

FC

LDD

6

5

FD

STD

FE

LDU

FF

STU

All unused opcodes are both undefined and illegal
