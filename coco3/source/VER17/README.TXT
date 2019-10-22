For contact information and more details, visit:

http://www.vavasour.ca/jeff/trs80.html#coco3

The COCO3X.EXE in this directory represents Version 1.7 (beta) of the CoCo 3 
Emulator.  The files to build Version 1.7 are also included in this directory.
See section 8 below if you want details on how to rebuild the code.  If you
just want to try out Version 1.7, copy COCO3X.EXE from this directory into
your working emulator directory (preferably under a different name such as
COCO3-17.EXE) and then read up to and including section 2 below.

This code is provided as-is and without warranty.  Copyright remains with the
author.  Not for public or commercial distribution, in whole or in part.  If 
you wish to refer others to this code, please do so by the URL above.  Please
do NOT link directly to the URL for c3source.zip.

- - -

Overview of new features in CoCo 3X Emulator version 1.7:

* New high resolution graphics enhancements (640x480 with 16 colours and
  320x200 with 256 colours)

* Ability to read PC keyboard directly

* Extensions to support 16 megs of RAM where available

* Correction to error RGB palette

* RAM zeroed on start-up so that .PAK files compress better when archived via
  PKZIP (or equivalent compressor).

* New memory requirements:  (See MS-DOS "MEM" command for info on your
  system.)

  128K CoCo 3: 476K free conventional RAM
  512K CoCo 3: 556K free conventional RAM + 384K free EMS RAM
  2Mb CoCo 3: 556K free conventional RAM + 1920K free EMS RAM
  16Mb CoCo 3: 556K free conventional RAM + 16256K free EMS RAM

* New 6809 instruction to access MS-DOS INT 21H functions.

 - - -

1. Details on hi-res enhancements

All enhanced graphics modes are mapped to an additional 152K of dedicated
RAM, which can be switched in in place of the bottom 152K of a 512K CoCo 3.

In BASIC, you must issue the following three POKE's before you can use this
RAM and the advanced graphics modes:

POKE &HFF86,74 
POKE &HFF87,86 
POKE &HFF70,128

(See section 3 for more explanation of the &HFF70 register, and
important information on how to access this RAM if you wish to write
assembly routines to use it.)

If you want to restore the CoCo's normal bottom 152K of RAM use

POKE &HFF70,0

When the native graphics RAM is available, you can use LPOKE to set pixels
on these new screens.  It is not necessary for the native graphics mode to
be displayed on your monitor to do this.  (i.e. you can set pixels on the
hidden native graphics screens while the monitor displays a CoCo screen.)

To show the native graphics screen on your monitor, use the following three
commands in sequence:

POKE &HFF88,N   'See below for N

where N is the mode as defined below:

Mode    Description
----    -----------
0       Normal CoCo display mode
1       Show 320x200 256-colour page 0
2       Show 640x480 16-colour screen using native palette
3       Show 640x480 16-colour screen using CoCo palette
129     Show 320x200 256-colour page 1

Important: the CoCo will not automatically return to mode 0.  If your
program crashes, or you switch into a native graphics screen at the OK
prompt, you will not be able to see what you are typing until a POKE &HFF88,0
is issued.

(Note everything below assumes you've issued the three POKEs to activate
access to the native graphics RAM.)


1.1 The 320x200 screens

To set a pixel at (X,Y) to colour N in this mode, issue:

LPOKE X+Y*320,N         'Pixel on page 0

or

LPOKE X+Y*320+65536,N   'Pixel on page 1

Note there are two 320x200 graphics screens, which can be maintained
separately, allowing you to have two pages of graphics which you can switch
between rapidly.  You can also display one while you are modifying the other.
This is called double-buffering.


1.2 Defining colours

There are new palette registers for the 256-colour screen.  To define a
colour index N, use the following:

LPOKE &H25800+N*3,R
LPOKE &H25801+N*3,G
LPOKE &H25802+N*3,B

where R, G, and B and red, green, and blue values respectively, in the range
of 0-63.

At power-up, this palette is initialised so that colour N corresponds to
the traditional palette colour of that same number.  (i.e. 0 is black, 63 is
white).  Colours 64-127 correspond to the colours you would see if you were
viewing the traditional palette's 0-63 on a composite monitor.  Colours
128-255 default to duplicates of colours 0-127.


1.3 The 640x480 screens

Modes 2 and 3 are identical except for the method in which the palette is
set.

Mode 2 uses the first 16 colours in the native palette table defined in
section 1.2 above to specify the 16 colours available on this screen.

Mode 3 uses the traditional CoCo palette to define the 16 colours.

For example, in Mode 3, PALETTE 7,63 will set colour 7 to white.  In
Mode 2, you'd have to use

LPOKE &H25800+7*3,63
LPOKE &H25801+7*3,63
LPOKE &H25802+7*3,63

to set colour 7 to white.  The advantage of Mode 2 is that you have finer
definition on the palette (18 bits instead of 6) while in Mode 3 you have
greater backward compatibility.

In both of these modes, each byte in the first 150K of the graphics RAM
represents a pixel pair.  Given that you wish to set a pixel at (X,Y) to
colour N, in these modes you would need to use:

A=INT(X/2)+Y*320
IF X AND 1 THEN LPOKE A,N+(PEEK(A) AND 240) ELSE LPOKE A,N*16+(PEEK(A) AND 15)

Note that an error will occur if N is not in the range 0-15.

(For assembly programmers, the left pixel is in the high nybble of the pair.)


2. Direct access to the PC keyboard status

The key matrix representing the pressed/released state of the PC keyboard
is stored in the native graphics and I/O space.  To access it, you must
first enable access by issuing the three POKEs described in section 1.

Then you can check the status of a key by reading LPEEK(&H25B00+N) where N
is a "scan code" representing the key you wish to check.  If the value
returned is non-zero, the key is currently down; if it is zero, the key is
currently released.

Keys are generally numbered according to their position on the keyboard,
rather than their ASCII value.  Below is a brief summary of the scan codes.

Code    Key             Code    Key             Code    Key
----    ---             ----    ---             ----    ---
1       ESC             2       1               3       2
4       3               5       4               6       5
7       6               8       7               9       8
10      9               11      0               12      -_
13      =+              14      Backspace       15      Tab
16      Q               17      W               18      E
19      R               20      T               21      Y
22      U               23      I               24      O
25      P               26      [{              27      ]}
28      Enter           29      Left Ctrl       30      A
31      S               32      D               33      F
34      G               35      H               36      J
37      K               38      L               39      ;:
40      '"              41      `~              42      Left Shift
43      \|              44      Z               45      X
46      C               47      V               48      B
49      N               50      M               51      ,<
52      .>              53      /?              54      Right Shift
55      Numpad *        56      Left Alt        57      Spacebar
58      Caps Lock       59      F1              60      F2
61      F3              62      F4              63      F5
64      F6              65      F7              66      F8
67      F9              68      F10             69      Num Lock
70      Scroll Lock     71      Numpad 7        72      Numpad 8
73      Numpad 9        74      Numpad -        75      Numpad 4
76      Numpad 5        77      Numpad 6        78      Numpad +
79      Numpad 1        80      Numpad 2        81      Numpad 3
82      Numpad 0        83      Numpad .        87      F11
88      F12             156     Numpad Enter    157     Right Ctrl
181     Numpad /        183     Print Scrn      184     Right Alt
197     Pause           199     Home            200     Up Arrow
201     Pg Up           203     Left Arrow      205     Right Arrow
207     End             208     Down Arrow      209     Pg Down
210     Ins             211     Del

Notes:

i. some keys may not be visible in the emulator (e.g. many function keys)
   as they are assigned special emulator menu functions

ii. When comparing against tables of true IBM-standard scan codes, note that
    two byte sequences $E0 nn are found in the table above as scan code
    nn+128.


3. RAM extensions (for interest to advanced programmers)

There are two extensions to the emulator's RAM beyond the 2 megs supported
in version 1.6.  First, there is the additional 152K of native graphics and
I/O RAM.  Second, on systems with 16 megs or more of EMS memory available,
the emulator will make available 16 megs to the emulated CoCo's CPU.

Both of these memory extensions are available through the MMU extension
registers at FF70-FF7F.  When combined with the traditional FFA0-FFAF MMU
registers, you form a 16-bit MMU page number (with the MSB drawn from
FF70-FF7F) as follows:

Pages           Description
-----           -----------
$0000-$003F     Traditional 512K of CoCo RAM
$0040-$00FF     Additional banks available in 2Mb and 16Mb configuration
$0100-$07FF     Additional banks available only in 16Mb configuration
$8000-$8012*    152K native mode I/O memory (native video, keyboard, etc.)

* IMPORTANT: before you can access pages $8000-$8012, you must first enable
  the NATIVE mode by writing $4A to $FF86 and $56 to $FF87.  This also
  enables the Intel native code support available since version 1.6 of the
  emulator.

In section 1 above, it was possible to access the native graphics memory
via POKE &HFF70,128 because the LPOKE command always switches memory into
the address space $0-$1FFF.  Since $FF70 corresponds to the MMU extension
register for that address space, and since CoCo BASIC does not modify $FF70,
then LPOKE will write to page $8000 instead of 0, $8001 instead of 1, etc.
until you clear $FF70.

To enable the 16 meg option, check your MS-DOS configuration to ensure that
HIMEM.SYS and EMM386.EXE are loaded in your CONFIG.SYS and configured to
make at least 16 megs of EMS available.  Once this has been set up and you
have rebooted, go the the emulator's directory and issue the command:

ECHO >16MEGS

If your system is configured properly, the next time you run the emulator
you will see a purple start-up screen with "16Mb" in the upper righthand
corner.

As with the 2 meg mode in version 1.6, the additional bits needed to specify
the CoCo's video page base address are to be written to $FF9B.  (That is, in
forming the absolute address for the video page, bits 23-19 of that address
are written to the low bits of $FF9B.  This does not affect native mode
graphics, which are stored at a fixed location in banks $8000-$8012.)

Note: If the 16Mb mode is disabled, then bits 6-0 of the MMU extension
registers ($FF70-$FF7F) will be ignored.  If you run the emulator in 128K or
512K mode, the top two bits of the traditional MMU registers ($FFA0-$FFAF)
will also be ignored, as they are in a stock CoCo.


4. Clearing RAM at power-up and restart (but not reset)

When first entering the emulator and when restarting (by the key sequence
F6 R Y) the emulator now zeroes all RAM.  You will note a brief
"Please wait..." message over the title screen when this happens.  (In the
16 meg configuration, it may take somewhat longer.)  The reason for this
change is that .PAK files contain the full contents of the CoCo's RAM
space.  For memory that may never have been used since power-up, the .PAK
file would record whatever uninitialised junk was in that memory.  Since
.PAK files have the potential to be up to 16 megs now, it may be desirable
to compress these files for archiving or email (e.g. using PKZIP).
Uninitialised junk does not compress as well as "all-zeroed RAM", so RAM
is therefore initialised to zeroes to improve this situation.

RAM is *not* initialised via the CTRL+F10 reset.


5. Note on new memory requirements

The new emulator needs 556K of free conventional memory, in addition to EMS,
in order to run in its full configuration.  You can see how much free
conventional memory you have by issuing the MS-DOS commmand MEM.  If you have
less than 556K but more than 476K available, you will only emulate a 128K
CoCo.

For the 2Mb and 16Mb configurations, in addition to the memory requirements,
you must issue the MS-DOS command "ECHO >2MEGS" or "ECHO >16MEGS"
respectively in order to enable these expanded memory features.  These
commands create a file which the emulator looks for as a sign that it should
enable the extra RAM.  (These files must be created in the directory
containing the emulator and its ROM files.)

Memory for the enhanced native graphics and I/O features are included in
the basic memory requirements.

Finally, for those curious, though the executable for version 1.7 is only
232 bytes larger than version 1.6, a considerable amount of modification
took place.  Unfortunately, since COCO3X.EXE is reaching the limits of its
size as dictated by the programming model, some "unrolled loops" had to be
"re-rolled" to make room for the new features.  This means performance may
have been slightly compromised, but hopefully the effect should not be overly
significant.


6. MS-DOS call opcode

The byte sequence 11 FD xx is interpreted in version 1.7 of the CoCo 3
Emulator to mean the following 80x86 opcode sequence:

        MOV AH,xx
        MOV AL,REG6809_DP
        MOV BX,REG6809_U
        MOV CX,REG6809_X
        MOV DX,REG6809_D
        MOV SI,REG6809_PC
        MOV DI,REG6809_Y
        INT 21H
        MOV REG6809_DP,AL
        MOV REG6809_U,BX
        MOV REG6809_X,CX
        MOV REG6809_D,DX
        MOV REG6809_PC,SI
        MOV REG6809_Y,DI

This can be used to execute MS-DOS functions such as File Open, Close, etc.
Consult an MS-DOS programmer's reference manual for details on the INT 21H
functions.

IMPORTANT: When performing buffered operations via INT 21H (e.g. File Read)
when the 11 FD xx instruction is being executed in an MMU bank other than
30-3F, the buffer must reside entirely within the same MMU bank.  Ignoring
this will cause the Read to be incomplete at best, or crash your computer
at worst.


7. Additional note on 80x86 code

Only MMU banks $0030-$003F and $8000-$8012 plus the CoCo's "ROM space" are
visible to 80x86 subroutines.  Upon entry into a 80x86 subroutine (via the
11 FF instruction code, introduced in version 1.6 of the emulator),
registers DS and ES point to beginning of MMU bank $0038.  (Since segments
contain 64K, all of banks $0038-$003F is accessible by default.)  A constant
offset must be added to the value in DS to access another bank.  The table
below summarises these offsets:

Offset  Contents
------  --------
-2000H  Internal boot ROM of the CoCo 3 (offset 0 corresponds to address
        $8000 in CoCo memory space)
-1800H  External ROM (e.g. Disk BASIC, offset 0 corresponds to address $8000
        in CoCo memory space so the Disk BASIC ROM would be at offset 4000H
        in this segment)
-1000H  MMU banks $0030-$0037
 0      MMU banks $0038-$003F
+1200H  MMU banks $8000-$8007
+2200H  MMU banks $8008-$800F
+3200H  MMU banks $8010-$8012 (do not write above offset 5FFFH)

(Note: the 8K skipped at offset +1000H is a scratch space which is only
       modified if a CoCo program attempts to write to a memory address
       occupied by ROM.)

The remaining banks are stored in EMS memory which is not readily accessible
except internally by the emulator.  Generally, the default EMS page frame's
4 16K pages will contain the last EMS pages accessed by MMU registers 0-3
respectively.  So, if $FFA2 was set to $1F, then offset 8000H-BFFFH of the
default EMS page frame would contain MMU banks $001E and $001F.  (Since EMS
can only bank switch 16K at a time, pages are always bank switched in in
even/odd pairs.)

MMU registers 4-7 also have an EMS page frame for banks not covered above,
however, its position is not fixed.  In fact, it may even change from one
execution of COCO3X.EXE to the next, depending on how much memory is free.


8. Building the Source Code

If you are using Microsoft's Macro Assembler (MASM) version 5.x, use 
BUILD5.BAT to rebuild the code.  If you are using MASM version 6.x, use
BUILD6.BAT to rebuild the code.
