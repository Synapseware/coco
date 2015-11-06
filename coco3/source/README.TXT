For contact information and more details, visit:

http://www.vavasour.ca/jeff/trs80.html#coco3

If you are interested in the beta Version 1.7 of the CoCo 3 
Emulator, refer to the VER17 subdirectory within this 
c3source.zip collection.

The files in this directory represent the source code of my 
TRS-80 CoCo 3 Emulator version 1.6B.  The EXTERNAL directory 
contains the source code for EXTERNAL.EXE, the MS-DOS command 
and error message enhancements to CoCo 3 BASIC which may be 
downloaded from the URL above.

This code is provided as-is and without warranty.  Copyright 
remains with the author.  Not for public or commercial 
distribution, in whole or in part.  If you wish to refer 
others to this code, please do so by the URL above.  Please
do NOT link directly to the URL for c3source.zip.

- - -

This directory contains source code to rebuild the CoCo 3 
Emulator project.

A replacement 6809.ASM provides the same functionality, 
however.  It also is more compact (albeit slower) than the
original core, and so is better suited to those wishing to
upgrade the emulator to support 6309 instructions.  Due to
copyright reasons, the original 6809.ASM cannot be included.

The subdirectory VER17 contains replacement files for some
files in this directory, allowing you to build the unreleased
CoCo 3 Emulator version 1.7.  The details of features provided
in this upgrade can be found in the README.TXT file in the VER17
directory.

The EXTERNAL directory contains a project capable of building
EXTERNAL.EXE which, when run, will modify COCO3.ROM to add
a number of new commands to the CoCo BASIC command set.  These
commands are suited to accessing programs in your MS-DOS
directory.  EXTERNAL.EXE makes a backup of your original 
COCO3.ROM in the file COCO3ROM.BAK.

In all cases, the batch file BUILD5.BAT can be used to build
the project with Microsoft's Macro Assembler version 5.0.
BUILD6.BAT is used to build the same project with Microsoft's
Macro Assembler version 6.11.
