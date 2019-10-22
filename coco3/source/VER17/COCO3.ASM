        TITLE TRS-80 Colour Computer Emulator
        
;General register maps during execution time:        
; D  -> DX ( A -> DH, B -> DL )
; PC -> SI
; SP -> BP
; X  -> CX
; Y  -> DI

        .286

        INCLUDE SWITCHES.ASM

        ASSUME CS:PROG,DS:PROG,SS:STACK

STACK   SEGMENT STACK 'AT_TOP'

        INCLUDE STACK.INC

        ORG 0A008H

MSG28   DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º TRS-80 COLOUR COMPUTER 3X EMULATOR '
MSG28A  DB '128K º'
        DB 'º Version 1.71á  (C)1993-98 Jeff Vavasour º'
        DB 'º                                         º'
        DB 'º Source code release           99-Apr-18 º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
        DB 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
        DB '³ Debug                                F1 ³'
        DB '³ Virtual Disk Menu    Click middle or F2 ³'
        IF ENABLE_SNAPSHOTS
        DB '³ Snapshots/Paks                       F3 ³'
        ELSE
        DB '³                                         ³'
        ENDIF
        DB '³ Virtual Cassette Menu                F4 ³'
        DB '³ Sound on/off                         F5 ³'
        DB '³ Options Menu/Quit     Click right or F6 ³'
        DB '³ Select keyboard mode                 F7 ³'
        DB '³ Modify custom keyboard layout        F8 ³'
        DB '³ File Import/Export Utility           F9 ³'
        DB '³ Reset                          CTRL-F10 ³'
        DB '³ This screen                         F10 ³'
        DB 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
MSG24   DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º VIRTUAL DISK MENU:                      º'
        DB 'º Select a drive, then enter a disk name  º'
        DB 'º or chose it from the directory listing. º'
        DB 'ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶'
        DB 'º SHIFT+number to write protect a drive,  º'
        DB 'º or ESC to resume emulation.             º'
        DB 'ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶'
        DB 'º Drive  Diskname                         º'
        DB 'º   0                                     º'  
        DB 'º   1                                     º'
        DB 'º   2                                     º'
        DB 'º   3                                     º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
MSG25   DB 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
        DB '³ ',24,' Directory ',25,' ³'
        DB 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB '³               ³'
        DB 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
MSG26   DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º WARNING!  Virtual disk          º'
        DB 'º '                                
MSG26A  DB '                                º'
        DB 'º does not exist!                 º'
        DB 'º                                 º'
        DB 'º Create it now?  Reply:          º'
        DB 'º ÚÄÄÄÄÄÄ¿               ÚÄÄÄÄÄÄ¿ º'
        DB 'º ³ Yes  ³               ³ No   ³ º'  
        DB 'º ÀÄÄÄÄÄÄÙ               ÀÄÄÄÄÄÄÙ º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
MSG51   DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º Please wait ... º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'

        IF ENABLE_SNAPSHOTS

MSG27   DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º PROGRAM PAK/SNAPSHOT OPTION:          º'
        DB 'º Choose either Load or Save, or press  º'
        DB 'º ESC to resume normal emulation.       º'
        DB 'º                                       º'
        DB 'º Name:                                 º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'

        ENDIF

MSG31   DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º OPTIONS MENU:                                           º'
        DB 'º Press letter or click to change/select options.  ESC to º'
        DB 'º resume normal emulation.                                º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
        DB 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
        DB '³ A. Keyboard mode............. ³³ K. Debug               ³'
        DB '³ B. Left joystick............. ³³ L. Virtual disk menu   ³'
        DB '³ C. Right joystick............ ³³ M. Snapshot/Pak menu   ³'
        DB '³ D. Sound..................... ³³ N. Customize keyboard  ³'
        DB '³ E. Colour set................ ³³ O. Calibrate joysticks ³'
        DB '³ F. Border colour............. ³³ P. File port utility   ³'
        DB '³ G. Printer mode.............. ³³ Q. Quit                ³'
        DB '³ H. Timers.................... ³³ R. Restart             ³'
        DB '³ I. 1.2Mb drive as............ ³³ S. Shell to DOS        ³'

        IF ENABLE_RS232

        DB '³ J. Port for RS-232........... ³³ T. Virtual tape menu   ³'

        ELSE

        DB '³                               ³³ T. Virtual tape menu   ³'

        ENDIF

        DB 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
        DB 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
        DB '³ SPEED:       -                                        + ³'
        DB '³ EXT. VOLUME: <                                        > ³'
        DB 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
MSG36   DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º Confirm: QUIT?                  º'
        DB 'º ÚÄÄÄÄÄÄ¿               ÚÄÄÄÄÄÄ¿ º'
        DB 'º ³ Yes  ³               ³ No   ³ º'  
        DB 'º ÀÄÄÄÄÄÄÙ               ÀÄÄÄÄÄÄÙ º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
MSG37   DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º Confirm: RESTART?               º'
        DB 'º ÚÄÄÄÄÄÄ¿               ÚÄÄÄÄÄÄ¿ º'
        DB 'º ³ Yes  ³               ³ No   ³ º'  
        DB 'º ÀÄÄÄÄÄÄÙ               ÀÄÄÄÄÄÄÙ º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
MSG39A  DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º CALIBRATE JOYSTICK:          º'
        DB 'º Move joystick A or B to the  º'
        DB 'º upper-left corner and press  º'
        DB 'º its button.  Press ESC to    º'
        DB 'º resume normal emulation.     º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
MSG39B  DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º CALIBRATE JOYSTICK:          º'
        DB 'º Move same joystick to the    º'
        DB 'º lower-right corner and press º'
        DB 'º its button.  Press ESC to    º'
        DB 'º resume normal emulation.     º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
MSG39C  DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º CALIBRATE JOYSTICK:          º'
        DB 'º No game port found in this   º'
        DB 'º machine.  Press any key to   º'
        DB 'º resume normal emulation.     º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
MSG46   DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º VIRTUAL CASSETTE MENU:         ÚÄÄÄÄÄÄÄ¿º'
        DB 'º Select a field by clicking it  ³counter³º'
        DB 'º or pressing its associated     ³       ³º'
        DB 'º letter. ESC resumes emulation. ÀÄÄÄÄÄÄÄÙº'
        DB 'ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶'
        DB 'º Name:                                   º'
        DB 'º Mode:                                   º'  
        DB 'ºÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿º'
        DB 'º³ Start   ³ Rewind  ³ Forward ³ End     ³º'  
        DB 'ºÀÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÙº'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
MSG48   DB 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»'
        DB 'º WARNING!  Virtual cassette      º'
        DB 'º '                                
MSG48A  DB '                                º'
        DB 'º does not exist!                 º'
        DB 'º                                 º'
        DB 'º Create it now?  Reply:          º'
        DB 'º ÚÄÄÄÄÄÄ¿               ÚÄÄÄÄÄÄ¿ º'
        DB 'º ³ Yes  ³               ³ No   ³ º'  
        DB 'º ÀÄÄÄÄÄÄÙ               ÀÄÄÄÄÄÄÙ º'
        DB 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
MSG32A  DB '.......PC'
MSG32B  DB '.....CoCo'
MSG32E  DB '...Custom'
MSG32G  DB '.....OS-9'
        IF ENABLE_DRAGON
MSG32C  DB '.DragonPC'
MSG32D  DB '...Dragon'
MSG32F  DB 'DgnCustom'
MSG32H  DB 'DragonOS9'
        ENDIF
MSG33A  DB '.Mouse'
MSG33B  DB 'Game A'
MSG33C  DB 'Game B'
MSG33D  DB '..None'
MSG33E  DB 'Hi-res'
MSG34A  DB 'Internal'
MSG34B  DB '.....Off'
MSG34C  DB 'External'
MSG35A  DB '...Black'
MSG35B  DB 'Variable'
MSG38A  DB '......RGB'
MSG38B  DB 'Composite'
MSG40A  DB '.CR only'
MSG40B  DB '...CR/LF'
MSG40C  DB 'Disabled'
MSG41A  DB '.60Hz only'
MSG41B  DB '.50Hz only'
MSG41C  DB '60Hz/16kHz'
MSG41D  DB '50Hz/16kHz'
MSG41E  DB '.Sync lock'
MSG42A  DB '40 track'
MSG42B  DB '80 track'
        IF ENABLE_RS232
MSG43A  DB 'COM1'
MSG43B  DB 'COM2'
        ENDIF
MSG14   DB 'No Colour Computer ROM files found in default path.',13,10,'$'
MSG14A  DB 'Colour Computer internal ROM file "COCO3.ROM" not found in '
        DB 'default path.',13,10,'$'
MSG1    DB 'Press appropriate letter to toggle flag.  ENTER when done or'
        DB ' ESC to abort.'
MSG2    DB 0
MSG3    DB 'Quit emulator/Return to DOS.  Reply "Y" to confirm.',0
MSG4D   DB 'Could not find the specified word in the current 6809 address space.',0
MSG5    DB 'Select with arrow keys or letter.  Press ENTER to change or ESC '
        DB 'to abort.',0
MSG7    DB 'Arrow keys move cursor.  Press ENTER or ESC when done.',0
MSG17   DB 'Debugger requested.  Press "C" to resume normal operation.',0
MSG18   DB 'Halted at breakpoint address.',0
MSG43   DB 'Type "EXIT" to return to the CoCo emulator.',13,'$'
MSG52   DB 'Insufficient memory to spawn process.  Aborting.',13,10,10
        DB 'Press any key to return to emulator. $'
MSG53   DB 7,'Fatal error!  Unable to recover EMS window!',13,10,10
        DB 'Aborting emulator.  Press any key to return to DOS... $'
MSG44   DB 'Insufficient memory to run emulator.  Need an extra '
MSG44A  DB '000K free.',13,10,'$'

;6809 instruction set -- diassembly

;Single byte instruction set

        ORG 0C008H

;00h-0Fh
SINGLE  DB 'neg $d|?|?|com $d|lsr $d|?|ror $d|asr $d|asl $d|rol $d|dec $d|?|'
        DB 'inc $d|tst $d|jmp $d|clr $d|'
;10-1Fh
        DB '?|?|nop|sync|?|?|lbra $l|lbsr $l|?|daa|orcc $2|?|andcc $2|sex|'
        DB 'exg $t|tfr $t|'
;20-2Fh
        DB 'bra $s|brn $s|bhi $s|bls $s|bcc $s|bcs $s|bne $s|beq $s|bvc $s|'
        DB 'bvs $s|bpl $s|bmi $s|bge $s|blt $s|bgt $s|ble $s|'
;30-3Fh
        DB 'leax $p|leay $p|leas $p|leau $p|pshs $r|puls $r|pshu $u|pulu $u|'
        DB '?|rts|abx|rti|cwai $2|mul|?|swi|'
;40-4Fh        
        DB 'nega|?|?|coma|lsra|?|rora|asra|asla|rola|deca|?|inca|tsta|?|clra|'
;50-5Fh
        DB 'negb|?|?|comb|lsrb|?|rorb|asrb|aslb|rolb|decb|?|incb|tstb|?|clrb|'
;60-6Fh
        DB 'neg $p|?|?|com $p|lsr $p|?|ror $p|asr $p|asl $p|rol $p|dec $p|'
        DB '?|inc $p|tst $p|jmp $p|clr $p|'
;70-7Fh
        DB 'neg $a|?|?|com $a|lsr $a|?|ror $a|asr $a|asl $a|rol $a|dec $a|'
        DB '?|inc $a|tst $a|jmp $a|clr $a|'
;80-8Fh
        DB 'suba $b|cmpa $b|sbca $b|subd $w|anda $b|bita $b|lda $b|?|eora $b|'
        DB 'adca $b|ora $b|adda $b|cmpx $w|bsr $s|ldx $w|?|'
;90-9Fh
        DB 'suba $d|cmpa $d|sbca $d|subd $d|anda $d|bita $d|lda $d|sta $d|'
        DB 'eora $d|adca $d|ora $d|adda $d|cmpx $d|jsr $d|ldx $d|stx $d|'
;A0-AFh
        DB 'suba $p|cmpa $p|sbca $p|subd $p|anda $p|bita $p|lda $p|sta $p|'
        DB 'eora $p|adca $p|ora $p|adda $p|cmpx $p|jsr $p|ldx $p|stx $p|'
;B0-BFh
        DB 'suba $a|cmpa $a|sbca $a|subd $a|anda $a|bita $a|lda $a|sta $a|'
        DB 'eora $a|adca $a|ora $a|adda $a|cmpx $a|jsr $a|ldx $a|stx $a|'
;C0-CFh
        DB 'subb $b|cmpb $b|sbcb $b|addd $w|andb $b|bitb $b|ldb $b|?|eorb $b|'
        DB 'adcb $b|orb $b|addb $b|ldd $w|?|ldu $w|?|'
;D0-DFh
        DB 'subb $d|cmpb $d|sbcb $d|addd $d|andb $d|bitb $d|ldb $d|stb $d|'
        DB 'eorb $d|adcb $d|orb $d|addb $d|ldd $d|std $d|ldu $d|stu $d|'
;E0-EFh
        DB 'subb $p|cmpb $p|sbcb $p|addd $p|andb $p|bitb $p|ldb $p|stb $p|'
        DB 'eorb $p|adcb $p|orb $p|addb $p|ldd $p|std $p|ldu $p|stu $p|'
;F0-FFh
        DB 'subb $a|cmpb $a|sbcb $a|addd $a|andb $a|bitb $a|ldb $a|stb $a|'
        DB 'eorb $a|adcb $a|orb $a|addb $a|ldd $a|std $a|ldu $a|stu $a|'

;Double byte instruction set

;10 00-10 1Fh
DBL10   DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
;10 20-10 2Fh        
        DB '?|lbrn $l|lbhi $l|lbls $l|lbhs $l|lblo $l|lbne $l|lbeq $l|'
        DB 'lbvc $l|lbvs $l|lbpl $l|lbmi $l|lbge $l|lblt $l|lbgt $l|lble $l|'
;10 30-10 3Fh
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|swi2|'
;10 40-10 7Fh
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
;10 80-10 8Fh
        DB '?|?|?|cmpd $w|?|?|?|?|?|?|?|?|cmpy $w|?|ldy $w|?|'
;10 90-10 9Fh
        DB '?|?|?|cmpd $d|?|?|?|?|?|?|?|?|cmpy $d|?|ldy $d|sty $d|'
;10 A0-10 AFh
        DB '?|?|?|cmpd $p|?|?|?|?|?|?|?|?|cmpy $p|?|ldy $p|sty $p|'
;10 B0-10 BFh
        DB '?|?|?|cmpd $a|?|?|?|?|?|?|?|?|cmpy $a|?|ldy $a|sty $a|'
;10 C0-10 CFh
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|lds $w|?|'
;10 D0-10 DFh
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|lds $d|sts $d|'
;10 E0-10 EFh        
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|lds $p|sts $p|'
;10 F0-10 FFh
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|lds $a|sts $a|'

;11 00-11 2Fh
DBL11   DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
;11 30-11 3Fh
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|swi3|'
;11 40-11 7Fh        
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
;11 80h-11 BFh
        DB '?|?|?|cmpu $w|?|?|?|?|?|?|?|?|cmps $w|?|?|?|'
        DB '?|?|?|cmpu $d|?|?|?|?|?|?|?|?|cmps $d|?|?|?|'
        DB '?|?|?|cmpu $p|?|?|?|?|?|?|?|?|cmps $p|?|?|?|'
        DB '?|?|?|cmpu $a|?|?|?|?|?|?|?|?|cmps $a|?|?|?|'
;11 C0-11 FFh
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|?|'
        DB '?|?|?|?|?|?|?|?|?|?|?|?|?|[DOS call $b]|[exit to DOS]|[8086 mode]|'

;Index/indirect post bytes

;00-0Fh
POST_TABLE DB '0,X|1,X|2,X|3,X|4,X|5,X|6,X|7,X|8,X|9,X|10,X|11,X|12,X|13,X|'
        DB '14,X|15,X|'
;10-1Fh
        DB '-16,X|-15,X|-14,X|-13,X|-12,X|-11,X|-10,X|-9,X|-8,X|-7,X|-6,X|'
        DB '-5,X|-4,X|-3,X|-2,X|-1,X|'
;20-2Fh        
        DB '0,Y|1,Y|2,Y|3,Y|4,Y|5,Y|6,Y|7,Y|8,Y|9,Y|10,Y|11,Y|12,Y|13,Y|'
        DB '14,Y|15,Y|'
;30-3Fh
        DB '-16,Y|-15,Y|-14,Y|-13,Y|-12,Y|-11,Y|-10,Y|-9,Y|-8,Y|-7,Y|-6,Y|'
        DB '-5,Y|-4,Y|-3,Y|-2,Y|-1,Y|'
;40-4Fh        
        DB '0,U|1,U|2,U|3,U|4,U|5,U|6,U|7,U|8,U|9,U|10,U|11,U|12,U|13,U|'
        DB '14,U|15,U|'
;50-5Fh
        DB '-16,U|-15,U|-14,U|-13,U|-12,U|-11,U|-10,U|-9,U|-8,U|-7,U|-6,U|'
        DB '-5,U|-4,U|-3,U|-2,U|-1,U|'
;60-6Fh        
        DB '0,S|1,S|2,S|3,S|4,S|5,S|6,S|7,S|8,S|9,S|10,S|11,S|12,S|13,S|'
        DB '14,S|15,S|'
;70-7Fh
        DB '-16,S|-15,S|-14,S|-13,S|-12,S|-11,S|-10,S|-9,S|-8,S|-7,S|-6,S|'
        DB '-5,S|-4,S|-3,S|-2,S|-1,S|'
;80-8Fh
        DB ',X+|,X++|,-X|,--X|,X|B,X|A,X|?|$o,X|$O,X|?|D,X|$o,PC|$O,PC|?|?|'
;90-9Fh
        DB '?|[,X++]|?|[,--X]|[,X]|[B,X]|[A,X]|?|[$o,X]|[$O,X]|?|[D,X]|'
        DB '[$o,PC]|[$O,PC]|?|[$O]|'
;A0-AFh
        DB ',Y+|,Y++|,-Y|,--Y|,Y|B,Y|A,Y|?|$o,Y|$O,Y|?|D,Y|$o,PC|$O,PC|?|?|'
;B0-BFh
        DB '?|[,Y++]|?|[,--Y]|[,Y]|[B,Y]|[A,Y]|?|[$o,Y]|[$O,Y]|?|[D,Y]|'
        DB '[$o,PC]|[$O,PC]|?|[$O]|'
;C0-CFh
        DB ',U+|,U++|,-U|,--U|,U|B,U|A,U|?|$o,U|$O,U|?|D,U|$o,PC|$O,PC|?|?|'
;D0-DFh
        DB '?|[,U++]|?|[,--U]|[,U]|[B,U]|[A,U]|?|[$o,U]|[$O,U]|?|[D,U]|'
        DB '[$o,PC]|[$O,PC]|?|[$O]|'
;E0-EFh
        DB ',S+|,S++|,-S|,--S|,S|B,S|A,S|?|$o,S|$O,S|?|D,S|$o,PC|$O,PC|?|?|'
;F0-FFh
        DB '?|[,S++]|?|[,--S]|[,S]|[B,S]|[A,S]|?|[$o,S]|[$O,S]|?|[D,S]|'
        DB '[$o,PC]|[$O,PC]|?|[$O]|'

EXG_LIST DB 'D|X|Y|U|S|PC|?|?|A|B|CC|DP|?|?|?|?|'
SP_LIST DB 'PC|U|Y|X|DP|B|A|CC|'
UP_LIST DB 'PC|S|Y|X|DP|B|A|CC|'

        ORG 0E008H

        DB 32 DUP(?)

STACK   ENDS

CUST_SEG SEGMENT PUBLIC 'B1_MENU'
CUST_SEG ENDS

;Stack segment structure

BANK0R  EQU 0                   ;CoCo 8K bank 0 segment for read
BANK0W  EQU 2                   ;CoCo 8K bank 0 segment for write
ROMBANK EQU 8                   ;PC segment for ROM (32K internal, 32K ext.)
RAMBANK EQU 10                  ;PC segment for 128K RAM
BANK1R  EQU 8192                ;CoCo 8K bank 1 segment for read
BANK1W  EQU 8194                ;CoCo 8K bank 1 segment for write
BANK2R  EQU 16384               ;CoCo 8K bank 2 segment for read
BANK2W  EQU 16386               ;CoCo 8K bank 2 segment for write
BANK3R  EQU 24576               ;CoCo 8K bank 3 segment for read
BANK3W  EQU 24578               ;CoCo 8K bank 3 segment for write
BANK4R  EQU 32768               ;CoCo 8K bank 4 segment for read
BANK4W  EQU 32770               ;CoCo 8K bank 4 segment for write
BANK5R  EQU 40960               ;CoCo 8K bank 5 segment for read
BANK5W  EQU 40962               ;CoCo 8K bank 5 segment for write
BANK6R  EQU 49152               ;CoCo 8K bank 6 segment for read
BANK6W  EQU 49154               ;CoCo 8K bank 6 segment for write
BANK7R  EQU 57344               ;CoCo 8K bank 7 segment for read
BANK7W  EQU 57346               ;CoCo 8K bank 7 segment for write
FRAME   EQU 12                  ;Video mask for debugger
KEY_LIST EQU 4012               ;PC keyboard layout
ALT_LIST EQU 4208               ;CoCo keyboard layout
CUSTOM_LIST EQU 4404            ;Custom keyboard layout
OS9_LIST EQU 4600               ;OS9 keyboard layout
DAC_TABLE EQU 8200              ;Proper colour table for DAC to emulate EGA
FONT    EQU 8392                ;Character set for text modes and SG4
FONT3   EQU 9928                ;CoCo 3 character set
CUR_DIR EQU 32776               ;Current directory listing, 500 entries max.

PROG    SEGMENT PUBLIC 'CODE'

        PUBLIC REGDP,REGU,REGX,REGY,REGF,REGFI,XLTFLAG,UPDFLAG,DBGMSG,DEBUG
        PUBLIC BRKPT,BAD,NEW_TOP,NEW_BOTTOM,CHARGEN,LASTKEY,BRANCH,CART_INT
        PUBLIC SBWAIT,ADDLF,VRES,USED_LPR,USED_VRES,DRB2,VERT_SCROLL
        PUBLIC HANDLE,PATHS,COUNTDOWN,GRAPHICS_MODE,OVERSCAN,BORDER_ENABLE
        PUBLIC WR_PROT,DTA,LJOYSTK,RJOYSTK,MOUSE_X,MOUSE_Y,FIRE,SOUND,VOLUME
        PUBLIC PULSE,COLSET,SBMASK,IRQENR,FIRQENR,IRQSET,FIRQSET,CYCLE_COUNT
        PUBLIC GAXPOS,GAYPOS,GBXPOS,GBYPOS,QUIT1,DOUBLE_STEP,TOPRAM,HORZ_OFF
        PUBLIC ROM_STATUS,CHANDLE,CAS_BIT,CAS_CYCLE,CASMODE,PALETTE,COCO_TOP
        PUBLIC EMS_ENABLE,MMU,INIT0,INIT1,EMS_BANKS,EMS_HANDLE,EMS_WINDOWS
        PUBLIC VERT_OFF_1,VERT_OFF_0,VMODE,V012,COLOUR_BASE,SET_SCROLL
        PUBLIC HSYNC_PULSE,HSYNC_SET,CEILING,TMR_DIVIDER,VIDEO_BLOCK
        PUBLIC EI1_CHECK,hires_x,hires_y,RETURN_ADDRESS,CLOCK_MODE,REGD
        PUBLIC MISSED_INTERRUPT,RETRY_CLOCK,CHARGEN_IF_CHANGED,REGPC,REGSP

        IF ENABLE_NATIVE_VIDEO
        PUBLIC NATIVE_VIDEO
        ENDIF

        EXTRN INST:NEAR,MEM_R8:NEAR,MEM_W8:NEAR,MEM_R16:NEAR
        EXTRN DRB1:BYTE,CRB1:BYTE,IRQ:NEAR,INITIALIZE:NEAR,DRA1:BYTE
        EXTRN AUX:NEAR,CHAR_LINES:BYTE,NUM_ROWS:BYTE,FIRQ:NEAR,CRA1:BYTE
        EXTRN CART_FLAG:BYTE,CRB2:BYTE,FIX_VIDEO:NEAR,MEM_MASK:WORD
        EXTRN HDHANDLE:WORD,UpdateSyncLock:near,MMU2:BYTE,NATIVE:BYTE
        EXTRN PALETTE_XLAT:BYTE,FIX_BANKS:NEAR

;Macros

;Patch: correction to INT 10H calls so that AH is saved

INT10H  MACRO
        PUSH AX
        INT 10H
        POP AX
        ENDM

;Read word of CoCo's memory at [DI] into AX

GETWORD MACRO
        CALL MEM_R16
        ENDM

;Read byte of CoCo's memory at [DI] into AL

GETBYTE MACRO
        CALL MEM_R8
        ENDM

;Write byte AL to CoCo's memory at [DI]

PUTBYTE MACRO
        CALL MEM_W8
        ENDM

;Save registers into emulator's data area

SAVEREG MACRO
        MOV REGX,CX
        MOV REGY,DI
        MOV REGSP,BP
        MOV REGD,DX
        MOV REGPC,SI
        ENDM

;Load registers from emulator's data area

LOADREG MACRO
        MOV CX,REGX
        MOV DI,REGY
        MOV DX,REGD
        MOV SI,REGPC
        MOV BP,REGSP
        ENDM

;Keyscan:  Return scancode in AH, ASCII in AL.

KEYSTROKE MACRO
        MOV AH,0
        INT 16H
        ENDM
 
;Turn off cursor, no registers affected

CSROFF  MACRO
        PUSH AX
        PUSH CX
        MOV AH,1
        MOV CX,-1
        INT10H
        POP CX
        POP AX
        ENDM

;Turn on cursor, no registers affected

CSRON   MACRO
        PUSH AX
        PUSH CX
        MOV AH,1
        MOV CX,15
        INT10H
        POP CX
        POP AX
        ENDM

;Find AL in LIST of LENGTH characters, return result in CX

FIND    MACRO LIST,LENGTH
        PUSH DI
        MOV CX,LENGTH
        PUSH ES
        PUSH DS
        POP ES
        MOV DI,OFFSET LIST
        REPNZ SCASB
        POP ES
        POP DI
        ENDM

;Clear input buffer addressed by DI, length CX, no registers affected

CLEAR   MACRO
        PUSH AX
        PUSH CX
        PUSH DI
        MOV AL,32
        PUSH ES
        PUSH DS
        POP ES
        REP STOSB
        POP ES
        POP DI
        POP CX
        MOV AX,920H
        PUSH BX
        MOV BX,14
        INT10H
        POP BX
        POP AX
        ENDM

;Display CoCo character AL at EGA address [DI]


;PC interrupt intercept routines

KEY_INTERCEPT:
        PUSH AX
        PUSH BX
        MOV BX,0
        IN AL,96
        TEST AL,128
        JZ KEY_INT1
        MOV CS:CAS_STEP,1
KEY_INT1:        
        CMP BYTE PTR CS:LASTKEY[BX],0
        JNZ SUPPRESS
        MOV CS:LASTKEY[BX],AL
        MOV BYTE PTR CS:LASTKEY[BX+1],0
        MOV BYTE PTR CS:BRANCH,0
        MOV BYTE PTR CS:INST,0C3H
        JMP KEY_BIOS
SUPPRESS:
        INC BX
        CMP BL,15
        JB KEY_INT1
KEY_BIOS:
        POP BX
        POP AX
        DB 0EAH
KEY_LOW DW 0
KEY_HI  DW 0

CLOCK_PERIOD DW 4DA7H           ;4DA7H if 60Hz, 5D2FH if 50Hz

CLOCK_INTERCEPT:                ;Dual timer clock interrupt
        CMP CS:REGULAR,0        ;If PC interrupt scheduled, branch to handler
        JNZ PC_CLOCK
        PUSH AX                 ;CoCo 60Hz interrupt handler
        MOV AX,CS:CYCLE         ;Calculate type of next timer interrupt
        ADD AX,CS:CLOCK_PERIOD
        JA CLOCK1               ;Branch if next interrupt is also CoCo
        XCHG AX,CS:CYCLE
        NEG AX                  ;Set remaining cycles to PC interrupt
        CMP AX,40H
        JNB CLOCK0A
        MOV AL,40H
CLOCK0A:
        PUSH AX
        MOV AL,36H
        OUT 43H,AL
        POP AX
        OUT 40H,AL
        MOV AL,AH
        OUT 40H,AL
        MOV CS:REGULAR,1        ;Set PC interrupt flag
CLOCK0: 
        MOV CS:PULSE,128        ;Set CoCo's clock IRQ bit on PIA1's CRB
        MOV BYTE PTR CS:BRANCH,OFFSET BRANCH5-OFFSET BRANCH1
                                ;Set branch to IRQ handler
        MOV AL,CS:IRQENR        ;Set chip IRQ if mask bit set
        AND AL,8
        OR CS:IRQSET,AL
        MOV AL,CS:FIRQENR       ;Same for FIRQ
        AND AL,8
        OR CS:FIRQSET,AL
        MOV BYTE PTR CS:INST,0C3H
        MOV AL,20H              ;Reset interrupt controller
        OUT 20H,AL
        POP AX
        IRET                    ;Return
CLOCK1: MOV CS:CYCLE,AX         ;Save counter to next PC interrupt
        MOV AL,20H              ;Reset interrupt controller
        OUT 20H,AL
        MOV AL,36H              ;Set counter for next CoCo 16.7ms interval
        OUT 43H,AL
        MOV AX,CS:CLOCK_PERIOD
        OUT 40H,AL
        MOV AL,AH
        OUT 40H,AL
        JMP CLOCK0
PC_CLOCK:                       ;PC clock 18.2Hz interrupt handler
        PUSH AX
        MOV AL,36H
        OUT 43H,AL              ;Load remainder of CoCo's 16.7ms interval
        MOV AX,CS:CYCLE         ;into counter
        CMP AX,40H
        JNB PC_CLOCK0A
        MOV AL,40H
PC_CLOCK0A:
        OUT 40H,AL
        MOV AL,AH
        OUT 40H,AL
        MOV CS:REGULAR,0        ;Reset PC clock interrupt flag
        POP AX
        CMP BYTE PTR CS:BRANCH,0
        JZ PC_CLOCK1            ;If nothing else happening, set screen
                                ;refresh interpreter branch
        MOV BYTE PTR CS:INST,0C3H
        MOV BYTE PTR CS:BRANCH,OFFSET BRANCH2-OFFSET BRANCH1
PC_CLOCK1:                      ;Go to PC clock interrupt handler
        DB 0EAH                 
CLK_LOW DW 0
CLK_HI  DW 0

REGULAR DB 0            ;Timer interrupt type flag.  Non-zero=PC, zero=CoCo
CYCLE   DW 0            ;Counter for determining which type is next

;This clock routine includes the horizontal sync and timer chip interrupts
;PC and 50/60Hz interrupts are secondary, and may not be precisely
;accurate

VSYNC_DIVIDER DW 262    ;VSYNC occurs every 262 HSYNC interrupts
PC_DIVIDER DW 863       ;PC interrupt to occur every 863 HSYNC interrupts
VSYNC_RESET DW 262      ;VSYNC count is 262 if 60Hz or 314 if 50Hz
HSYNC_PULSE DB 0        ;128 if HSYNC interrupt pending
TMR_DIVIDER DW 4095     ;CoCo's internal programmable timer count
HSYNC_TO_3580KHZ DB 228 ;This is roughly 3.58MHz/HSYNC

        PUBLIC CPUSpeed,CPU_SPEED

FAST_CLOCK:
        PUSH AX
        MOV AL,32               ;Reset interrupt controller so that no
        OUT 32,AL               ;bottlenecking occurs
        PUSH DS
        MOV AX,CS
        MOV DS,AX
        MOV BYTE PTR CYCLE_COUNT,57
CPUSpeed EQU $-1                ;57 = 0.89MHz, 114 = 1.78MHz
        DEC VSYNC_DIVIDER       ;Decrement 60Hz counter
        JNZ FAST_CLOCK_0        ;If time for a 60Hz interrupt, set branch
        MOV BYTE PTR INST,0C3H
        MOV BYTE PTR BRANCH,OFFSET BRANCH5-OFFSET BRANCH1
        MOV AX,VSYNC_RESET      ;Roll over counter
        MOV VSYNC_DIVIDER,AX
        MOV PULSE,128           ;Set CoCo's clock IRQ bit on PIA1's CRB
        MOV AL,IRQENR           ;Set chip IRQ if mask bit set
        AND AL,8
        OR IRQSET,AL
        MOV AL,FIRQENR          ;Same for FIRQ
        AND AL,8
        OR FIRQSET,AL
;        JMP FAST_CLOCK_2
FAST_CLOCK_0:
        MOV HSYNC_PULSE,128     ;Set CoCo's clock FIRQ bit on PIA1's CRA
FAST_CLOCK_1:
        JMP FAST_CLOCK_2
        MOV BYTE PTR INST,0C3H
        MOV BYTE PTR BRANCH,OFFSET BRANCH6-OFFSET BRANCH1
        MOV AL,IRQENR           ;Set chip IRQ if mask bit set
        AND AL,16
        OR IRQSET,AL
        MOV AL,FIRQENR          ;Set chip FIRQ if mask bit set
        AND AL,16
        OR FIRQSET,AL
FAST_CLOCK_2:
        DEC TMR_DIVIDER         ;If time for a programmable CoCo timer
TMR_ENABLE:
        JNZ FAST_CLOCK_3        ;interrupt, deal with it
        MOV BYTE PTR INST,0C3H
        MOV BYTE PTR BRANCH,OFFSET BRANCH7-OFFSET BRANCH1
        MOV AL,IRQENR           ;Set chip IRQ if mask bit set
        AND AL,32
        OR IRQSET,AL
        MOV AL,FIRQENR          ;Set chip FIRQ if mask bit set
        AND AL,32
        OR FIRQSET,AL
        MOV AX,CEILING          ;Roll over counter to its maximum
        TEST BYTE PTR INIT1,32  ;If in 3.58MHz mode, divide by 3580/16
        JZ TMR_HSYNC
        DIV BYTE PTR HSYNC_TO_3580KHZ
        CMP AH,1
        SBB AL,-1               ;Round up
        MOV AH,0
TMR_HSYNC:
        MOV TMR_DIVIDER,AX
FAST_CLOCK_3:
        DEC PC_DIVIDER          ;If time for a PC interrupt, generate it
        JNZ FAST_CLOCK_4
        MOV PC_DIVIDER,863      ;Roll over counter
        CMP BYTE PTR BRANCH,0
        JZ PC_CLOCK1A           ;If nothing else happening, set screen
                                ;refresh interpreter branch
        MOV BYTE PTR INST,0C3H
        MOV BYTE PTR BRANCH,OFFSET BRANCH2-OFFSET BRANCH1
PC_CLOCK1A:
        POP DS
        POP AX
        JMP PC_CLOCK1
FAST_CLOCK_4:
        POP DS
        POP AX
        IRET

MOUSE_INTERCEPT:
        TEST BL,1
        JZ MOUSE_FIRE_RELEASE
        cmp cs:ljoystk,8
        jz hires_fire1
        CMP CS:LJOYSTK,0
        JNZ NO_LEFT_FIRE
hires_fire1:
        AND BYTE PTR CS:FIRE,253
NO_LEFT_FIRE:
        cmp cs:rjoystk,8
        jz hires_fire2
        CMP CS:RJOYSTK,0
        JNZ NO_MOUSE_FIRE
hires_fire2:
        AND BYTE PTR CS:FIRE,254
        JMP NO_MOUSE_FIRE
MOUSE_FIRE_RELEASE:
        cmp cs:ljoystk,8
        jz hires_fire3
        CMP CS:LJOYSTK,0
        JNZ NO_LEFT_RELEASE
hires_fire3:
        OR BYTE PTR CS:FIRE,2
NO_LEFT_RELEASE:
        cmp cs:rjoystk,8
        jz hires_fire4
        CMP CS:RJOYSTK,0
        JNZ NO_MOUSE_FIRE
hires_fire4:
        OR BYTE PTR CS:FIRE,1
NO_MOUSE_FIRE:
        MOV AX,CX
        MOV CS:HIRES_X,AX
        DIV BYTE PTR CS:TEN
        MOV CS:MOUSE_X,AL
        MOV AX,DX
        MOV CS:HIRES_Y,AX
        SHL AX,1
        SHL AX,1
        SHL AX,1
        DIV CS:TWENTYFIVE
        MOV CS:MOUSE_Y,AL
        CMP CS:LASTKEY,0
        JNZ NO_BUTTON_RESPONSE
        TEST BL,6
        JZ NO_BUTTON_RESPONSE
        MOV CS:LASTKEY,3DH
        MOV BYTE PTR CS:BRANCH,0
        MOV BYTE PTR CS:INST,0C3H
        CMP BL,5                        ;Left+middle=snapshot
        JZ NO_BUTTON_RESPONSE
        MOV CS:LASTKEY,3CH
        TEST BL,5                       ;Left+right or middle=virtual disk
        JNZ NO_BUTTON_RESPONSE
        MOV CS:LASTKEY,7EH              ;Right only=options
NO_BUTTON_RESPONSE:
        RETF

MOUSE_LO DW 0
MOUSE_HI DW 0
MOUSE_MK DW 0

MOUSE_X DB 31                   ;Mouse coordinates in 0-63 range
MOUSE_Y DB 31
HIRES_X DW 0
HIRES_Y DW 0
FIRE    DB -1                   ;Left button is mapped to joystick trigger

BREAK_INTERCEPT:                ;Keep that pesky fatal error and CTRL-C
        IRET                    ;from leaving the program

BREAK_LO DW 0
BREAK_HI DW 0

;Subroutines

;Enable the HSYNC interrupt in FAST_CLOCK if anything might trigger it

HSYNC_SET:
        MOV BYTE PTR FAST_CLOCK_1[1],0
        TEST CRA1,1
        JNZ HSYNC_SET_1         ;If PIA1 CRA bit 0 set, enable HSYNC int.
        AND AL,FIRQENR          ;Also enable if chip FIRQ HSYNC mask set...
        OR AL,IRQENR            ;or chip IRQ HSYNC mask set
        TEST AL,16
        JNZ HSYNC_SET_1
        MOV BYTE PTR FAST_CLOCK_1[1],OFFSET FAST_CLOCK_2-OFFSET FAST_CLOCK_1-2
HSYNC_SET_1:                    ;Enable TMR interrupt...
        MOV BYTE PTR TMR_ENABLE,75H
        MOV AL,FIRQENR          ;if chip FIRQ TMR mask set...
        OR AL,IRQENR            ;or chip IRQ TMR mask set
        TEST AL,32
        JNZ HSYNC_SET_2
        MOV BYTE PTR TMR_ENABLE,0EBH
HSYNC_SET_2:
        RET

;Select clock interrupt and VSYNC frequency according to CLOCK_MODE

CLOCK_SET:
        PUSH AX
        PUSH DX
        MOV VSYNC_RESET,262     ;60Hz settings
        MOV CLOCK_PERIOD,4DA7H
        MOV AL,CLOCK_MODE
        TEST AL,1
        JZ CLOCK_SET_1
        MOV VSYNC_RESET,314     ;50Hz settings
        MOV CLOCK_PERIOD,5D2FH
CLOCK_SET_1:
        call UpdateSyncLock
        TEST AL,6               ;Set appropriate interrupt driver
        JZ CLOCK_SET_2
        MOV AX,2508H
        MOV DX,OFFSET FAST_CLOCK
        INT 21H
        MOV AL,36H      ;Reset count to a mere 76/65536th of the 18.2Hz
        OUT 43H,AL      ;interval (i.e. 63.7us... close enough to HSYNC)
        MOV AL,76
        OUT 40H,AL
        XOR AL,AL
        OUT 40H,AL
        POP DX
        POP AX
        RET
CLOCK_SET_2:
        MOV DX,OFFSET CLOCK_INTERCEPT
        MOV AX,2508H
        INT 21H
        POP DX
        POP AX
        RET

;Select correct graphics mode as set by configurations

PREV_UNDERLINE DB 15            ;Indicates line within char. of last underline

GRAPHICS_MODE:
        CMP LASTKEY,3BH
        JNZ GRMODE0
        RET
GRMODE0AA:
        JMP GRMODE0A
GRMODE0:
        IF ENABLE_NATIVE_VIDEO

        CMP WORD PTR NATIVE,JV
        JNZ NOT_NATIVE_MODE
        TEST BYTE PTR NATIVE[2],VIDEO_MODE_BITMASK
        JZ NOT_NATIVE_MODE
        PUSH BP
        MOV AL,NATIVE[2]
        AND AL,VIDEO_MODE_BITMASK
        CMP AL,1
        MOV AX,12H
        JNZ NATIVE_MODE_SELECT
        MOV AX,13H
NATIVE_MODE_SELECT:
        INT 10H
        MOV AL,NATIVE[2]
        AND AL,VIDEO_MODE_BITMASK
        CMP AL,3
        JNZ NOT_EMULATED_PALETTE
        CALL FIX_DAC
NOT_EMULATED_PALETTE:
        POP BP
        RET
NOT_NATIVE_MODE:

        ENDIF
                                ;Select 40 column text mode
        PUSH BX
        PUSH CX
        PUSH DX                 ;Select 200 scan line mode
        PUSH BP
        PUSH ES
        MOV AL,INIT0            ;if in CoCo=1 mode
        MOV AH,AL
        NOT AH
        AND AL,DRB2             ;and a graphics screen, or...
        AND AH,VMODE            ;in CoCo=0 mode and BP=1
        TEST AX,8080H
        JZ GRMODE0AA
        MOV AX,14               ;Select 640x200 16-colour bitplane graphics
        INT10H
        MOV DX,3D4H             ;Also select proper number of lines/row
        MOV AX,0C009H
        OR AH,USED_LPR
        DEC AH
        OUT DX,AX
        TEST BYTE PTR INIT0,128 ;If in CoCo=1 mode change background to 
        JZ GRMODE0B             ;COLOUR_BASE
        PUSH SI
        PUSH DI
        PUSH DS
        MOV ES,VID_SEG
        MOV AX,205H             ;Select write mode 2 (set colour)
        MOV DX,3CEH
        OUT DX,AX
        MOV CX,32               ;First fill in centre colour with COLOUR_BASE
        MOV AL,COLOUR_BASE
        MOV AH,AL
        MOV DI,8
        REP STOSW
        TEST BYTE PTR USED_VRES,4
        JNZ GRMODE0D            ;Then if in 4-colour mode, make border
        TEST BYTE PTR DRB2,16   ;same as background
        JZ GRMODE0D
        ADD AX,101H             ;2-colour mode, it's the same as foreground
GRMODE0D:
        TEST BYTE PTR BORDER_ENABLE,-1
        JNZ GRMODE0C
        MOV AX,0808H            ;If border is disabled, set it to colour 8
GRMODE0C:
        MOV DI,0
        MOV CX,4
        REP STOSW
        MOV DI,72
        MOV CX,4
        REP STOSW
        MOV AX,105H             ;Select write mode 1 (block transfer)
        OUT DX,AX
        MOV AL,NUM_ROWS         ;Now copy this pattern to the rest of the
        DEC AL                  ;rows
        MOV AH,80
        MUL AH
        MOV CX,AX
        MOV SI,0
        MOV DI,80
        MOV DS,VID_SEG
        REP MOVSB
        MOV AX,5                ;Select write mode 0 (normal)
        OUT DX,AX
        POP DS
        POP DI
        POP SI
GRMODE0B:
        JMP LINE_FIX
GRMODE0A:
        MOV AX,1
        MOV CX,0420H            ;32 column mode has 4 char. margin
        TEST BYTE PTR VRES,16   ;If CoCo dot clock doubled, use 80 col. mode
        JZ GRMODE1
        MOV AL,3
        SHL CX,1                ;64 column mode has 8 char. margin
GRMODE1:
        MOV BH,0
        INT10H
        CSROFF
        PUSH CX
        MOV AX,SS
        MOV ES,AX
        TEST BYTE PTR INIT0,128
        JNZ GRMODE3
        PUSH DS                 ;Prepare CoCo 3 character set: add underlines
        PUSH SI                 ;as appropriate
        PUSH DI
        MOV DS,AX
        MOV SI,FONT3
        MOV DI,FONT3+2048
        MOV CX,128
        MOV AH,0
        MOV AL,CS:CHAR_LINES
        DEC AL
        ADD DI,AX
        XCHG AL,CS:PREV_UNDERLINE
        ADD SI,AX
        MOV AL,-1
GRMODE5:                        ;Then set last displayed line to all 1's
        MOV AH,[SI]             ;Clear old underline
        MOV [SI+2048],AH
        STOSB                   ;Add new one
        ADD DI,15       
        ADD SI,16
        LOOP GRMODE5
        POP DI
        POP SI
        POP DS
        MOV BX,1000H            ;Ready to download font
        MOV CX,256
        MOV BP,FONT3
        MOV DX,0
        JMP GRMODE4
GRMODE3:                        ;Select CoCo 1/2 character set
        MOV BX,0C00H
        MOV CX,128
        MOV DX,64
        MOV BP,FONT
GRMODE4:
        MOV AX,1100H            ;Download character set
        INT10H
        POP CX
        MOV DX,03D4H
        MOV AX,0CB09H           ;with 12 lines/character
        TEST BYTE PTR INIT0,128
        JNZ GRMODE6
        MOV AH,CHAR_LINES       ;If in CoCo=0 mode, lines/char determined
        DEC AH                  ;by LPR values at port $FF98
        OR AH,0C0H
GRMODE6:
        OUT DX,AX
        MOV DX,3C4H             ;Select 8 bit wide characters
        MOV AL,1
        OUT DX,AL
        INC DX
        IN AL,DX
        OR AL,1
        OUT DX,AL
        mov dx,3dah
        in al,dx
        mov dx,3c0h             ;Reset PEL horizontal panning register
        mov al,13h
        out dx,al
        inc dx
        in al,dx
        dec dx
        and al,0f0h
        out dx,al
        mov al,20h
        out dx,al
        MOV DX,3CCH             ;Read miscellaneous register to reset dot
        IN AL,DX                ;clock to 25MHz
        MOV DL,0C2H
        AND AL,0F3H
        OUT DX,AL
LINE_FIX:
        MOV AL,VRES
        AND AL,96
        CMP AL,32               ;If in 200 line mode, do nothing to vert.
        JZ GRMODE8              ;registers
        TEST AL,64
        JNZ GRMODE7
        MOV DX,3D4H
        MOV AX,9410H            ;Vertical retrace now starts on line 404
        OUT DX,AX
        MOV AX,7F12H            ;Vertical end display now lines 383 (2*192-1)
        OUT DX,AX
        MOV AX,8E15H            ;Vertical blanking starts on line 398
        OUT DX,AX
        JMP GRMODE2
GRMODE8:                        ;200 line mode, make sure 200 lines enforced
        MOV DX,3D4H
        MOV AX,9C10H            ;Vertical retrace now starts on line 412
        OUT DX,AX
        MOV AX,8F12H            ;Vertical end display now lines 399 (2*200-1)
        OUT DX,AX
        MOV AX,9615H            ;Vertical blanking starts on line 406
        OUT DX,AX
        JMP GRMODE2
GRMODE7:                        ;225 line mode: customized 480/2 mode
        MOV DX,3CCH             ;First set to 480 line mode
        IN AL,DX
        OR AL,192
        MOV DX,3C2H
        OUT DX,AL
        MOV DX,3D4H             ;Enable write to critical timing registers
        MOV AX,0E11H
        OUT DX,AX
        MOV AX,0B06H            ;Set vertical total register to 523 lines
        OUT DX,AX               ;(standard for 480 line mode)
        MOV AX,3E07H
        OUT DX,AX
        MOV AX,0EA10H           ;Vertical retrace start at line 490
        OUT DX,AX
        MOV AX,0C112H           ;Vertical display end at line 449 (225*2-1)
        OUT DX,AX
        MOV AX,0E715H           ;Start vertical blanking on line 487
        OUT DX,AX
        MOV AX,0416H            ;End vertical blanking on line 516
        OUT DX,AX
        MOV AX,8C11H            ;Vertical retrace end at line 492
        OUT DX,AX
GRMODE2:
        CALL SET_SCROLL
        POP ES
        POP BP
        POP DX
        POP CX
        POP BX
FIX_DAC:        
        PUSH BX                 ;Set each of first four 64 DAC blocks to 
        PUSH CX                 ;EGA compatible set
        PUSH DX
        PUSH ES
        MOV AX,SS
        MOV ES,AX
        MOV AX,1012H
        MOV BX,0
        MOV CX,64
        MOV DX,DAC_TABLE
FIX_DAC_1:
        PUSH BX
        INT10H
        POP BX
        ADD BL,40H
        JNZ FIX_DAC_1
        POP ES
        POP DX
        POP CX
        POP BX
        RET

MENU_SCREEN:
        MOV AX,3                ;Return to text mode for menus
        INT10H
        CSROFF
        MOV BYTE PTR CYCLE_COUNT,127
        RET

;Set vertical scroll register according to emulator's $FF9C value

SET_SCROLL:
        TEST BYTE PTR INIT0,128
        JNZ SET_SCROLL_1
        PUSH AX
        PUSH BX
        PUSH DX
        MOV AL,VMODE            ;CoCo vertical scroll register can't go
        AND AL,7                ;beyond first line, so translation may be
        MOV AH,16               ;needed based on LPR setting
        MUL AH
        ADD AX,OFFSET SCROLL_TABLE
        MOV BX,AX
        MOV AL,VERT_SCROLL
        AND AL,15
        XLAT
        MOV AH,AL
        MOV DX,3D4H             ;Load PC scroll register with appropriate
        MOV AL,8                ;CoCo value
        OUT DX,AL
        INC DX
        IN AL,DX
        AND AL,0E0H
        OR AL,AH
        OUT DX,AL
        POP DX
        POP BX
        POP AX
SET_SCROLL_1:
        RET

SCROLL_TABLE DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;LPR=1 has no scroll
             DB 0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1 ;LPR=2 bit 0 significant
             DB 0,1,2,2,0,1,2,2,0,1,2,2,0,1,2,2 ;LPR=3 peaks at line 2
             DB 0,1,2,3,4,5,6,7,7,7,7,7,7,7,7,0 ;LPR=8 peaks at line 7
             DB 0,1,2,3,4,5,6,7,8,7,8,7,8,7,8,0 ;LPR=9 peaks at 7/8 (alt.)
             DB 0,1,2,3,4,5,6,7,8,9,8,9,7,8,9,0 ;LPR=10 peaks at 7/8/9
             DB 0,1,2,3,4,5,6,7,8,9,10,7,8,9,10,0       ;LPR=11
             DB 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15   ;LPR=16

;Determine character coordinate based on value returned from mouse func. 3

MOUSE_COORD:
        SHR DX,1                ;Mouse button pressed.  Get coordinates.
        SHR DX,1
        SHR DX,1
        SHR CX,1
        SHR CX,1
        SHR CX,1
        RET

;Test for EMS memory setup and create map if possible

FREE_MEMORY DW 0        ;Will contain lowest free segment after START done
NO_EMS_MEMORY DW 0      ;Lowest free segment excluding EMS windows

        IF ENABLE_NATIVE_VIDEO
NATIVE_VIDEO DW 0       ;Base segment of native video mode pixels
NATIVE_PALETTE DW 0     ;Base segment of native video mode palette
NATIVE_KEYBOARD DW 0    ;Segment where native keyboard state is stored
        ENDIF

MEM_LIMIT DW 24         ;Number of EMS pages to allocate
MEM_MESSAGE DW MSG50A   ;Points to mem size. message
MEM_COLOUR DB 2
EMS_MASK DW 3FH         ;Goes to FFH if 2 megs *requested*

MSG50A  DB '512K'
MSG50B  DB ' 2Mb'
MSG50C  DB '16Mb'

ENTRY_MAP DB 256 DUP(?) ;Storage area for EMS page map upon entry

EMS_TEST_5A: 
        JMP EMS_TEST_5

EMS_TEST:
        PUSH DS
        PUSH ES
        MOV AX,3567H    ;Make sure EMS interrupt is valid
        INT 21H
        MOV AX,ES
        OR AX,BX
        MOV AX,CS
        MOV DS,AX
        MOV ES,AX
        JZ EMS_TEST_5A
        MOV AX,5800H
        MOV DI,OFFSET DTA
        INT 67H
        CMP AH,0        ;Need EMS 4.0 with at least 8 pages available
        JNZ EMS_TEST_5A
        CMP CX,8
        JB EMS_TEST_5A
        MOV DX,0
        MOV SI,0
        MOV AX,FREE_MEMORY
EMS_TEST_1:             ;Search for each page in table in numerical order
        MOV BX,0
        PUSH CX
EMS_TEST_2:
        CMP [BX+DI+2],DX
        JZ EMS_TEST_4
        ADD BX,4
        LOOP EMS_TEST_2
EMS_TEST_3:
        POP CX
        INC DX
        CMP DX,CX
        JB EMS_TEST_1
        POP ES
        POP DS
        RET
EMS_TEST_4:             ;When each entry found, check to see if it is above
        MOV AX,[BX+DI]  ;FREE_MEMORY
        CMP AX,FREE_MEMORY
        JB EMS_TEST_3
        MOV EMS_WINDOWS[SI],AX
        MOV EMS_BANKS[SI],DX
        CMP AH,0A0H
        JNB EMS_TEST_6
        ADD AH,4        ;If EMS window is in MS-DOS RAM, make sure to protect
        MOV FREE_MEMORY,AX
EMS_TEST_6:
        ADD SI,2        ;If so, add this bank to the EMS table and find the
        CMP SI,16       ;next one (8 required)
        JB EMS_TEST_3
        POP CX
        MOV AH,43H      ;When 8 windows found, allocate 384K of EMS
        MOV BX,CS:MEM_LIMIT
        INT 67H
        CMP AH,0
        JNZ EMS_TEST_5
        MOV EMS_HANDLE,DX
        MOV AX,4E00H    ;Get EMS page map on entry
        MOV DI,OFFSET ENTRY_MAP
        INT 67H
        MOV AX,SEG SINGLE
        MOV ES,AX
        MOV BX,MEM_MESSAGE
        MOV AX,[BX]
        MOV WORD PTR ES:MSG28A,AX       ;Change powerup banner to say "512K"
        MOV AX,[BX+2]
        MOV WORD PTR ES:MSG28A[2],AX
        MOV BYTE PTR EMS_ENABLE,-1      ;Set EMS flag
        MOV AL,MEM_COLOUR
        MOV BYTE PTR HELP_COLOUR,AL     ;Make help screen green if 512K
        MOV AX,CS:EMS_MASK              ;Take out the EMS memory limiter
        MOV CS:MEM_MASK,AX
EMS_TEST_5:
        POP ES
        POP DS
        RET

;Free up allocated EMS memory

FREE_EMS:
        CMP BYTE PTR EMS_ENABLE,0
        JZ FREE_EMS_2
        MOV AX,CS
        MOV DS,AX
        MOV ES,AX
        MOV DX,EMS_HANDLE       ;Deallocate 384K block
        MOV AH,45H
        INT 67H
        MOV AX,4E01H            ;Restore memory map set up at entry time
        MOV SI,OFFSET ENTRY_MAP
        INT 67H
FREE_EMS_2:
        RET

;Test for presence of joystick, remap to mouse if none detected

NO_GAME_PORT DB 0

JOYTEST:
        PUSH DS
        PUSH CX
        MOV DX,201H
        OUT DX,AL
        MOV CX,0
        PUSH AX
        PUSH DX
        MOV AX,CS
        MOV DS,AX
JOYTEST1:
        IN AL,DX
        TEST AL,15
        JNZ JOYTEST2
        IN AL,DX
        TEST AL,15
        LOOPZ JOYTEST1
        JZ JOYTEST3
JOYTEST2:
        IN AL,DX
        NOT AL
        TEST AL,15
        JNZ JOYTEST5
        IN AL,DX
        NOT AL
        TEST AL,15
        LOOPZ JOYTEST2
        JNZ JOYTEST5
JOYTEST3:        
        MOV NO_GAME_PORT,-1
        CMP BYTE PTR LJOYSTK,0
        JZ JOYTEST4
        cmp byte ptr ljoystk,6
        jz joytest4
        cmp byte ptr ljoystk,8
        jz joytest4
        MOV BYTE PTR LJOYSTK,6
JOYTEST4:
        CMP BYTE PTR RJOYSTK,0
        JZ JOYTEST5
        cmp byte ptr rjoystk,6
        jz joytest5
        cmp byte ptr rjoystk,8
        jz joytest5
        MOV BYTE PTR RJOYSTK,6
JOYTEST5:
        POP DX
        POP AX
        POP CX
        POP DS
        RET

;Read bit of joystick port as masked in AH, return timing in CX

JOYREAD:
        PUSH AX
        PUSH DX
        MOV CX,0
        CLI
        MOV DX,201H
        OUT DX,AL
JOYREAD1:
        IN AL,DX
        TEST AL,AH
        LOOPNZ JOYREAD1
        STI
        NEG CX
        POP DX
        POP AX
        RET

;SoundBlaster code:  Identify and initialise

SBINIT:
        CLI
        MOV DX,SBPORT
        ADD DX,6
        MOV AL,1
        OUT DX,AL
        MOV CX,10
SBINIT1:
        LOOP SBINIT1
        DEC AL
        OUT DX,AL
        STI
        ADD DX,4
        MOV CX,100
SBINIT2:
        IN AL,DX
        CMP AL,0AAH
        JZ SBINIT3
        LOOP SBINIT2
        RET
SBINIT3:
        MOV BYTE PTR SBMASK,3
        CALL SBWAIT
        MOV AL,0D1H
        OUT DX,AL
        RET

;Wait for SoundBlaster command port

SBWAIT:
        MOV DX,SBPORT
        ADD DX,12
SBWAIT1:
        IN AL,DX
        ROL AL,1
        JB SBWAIT1
        RET

SBPORT  DW 220H

;Shift keyboard buffer one byte

SHIFT_KEYS:
        PUSH BX
        MOV BX,0
SHIFT_KEYS1:
        MOV AL,LASTKEY[BX+1]
        MOV LASTKEY[BX],AL
        INC BL
        CMP BL,15
        JB SHIFT_KEYS1
        POP BX
        RET

;Display CX copies of PC character AL at DX, foreground BL, background BH
;bit 7 of BL = 1 => reverse character

TEXT_SEG DW 0B800H
ONESIXTY DW 160

PC_CHAR:
        PUSH ES
        PUSH DI
        PUSH CX
        PUSH BX
        PUSH AX
        MOV AL,DH
        MOV AH,0
        PUSH DX
        MUL ONESIXTY
        POP DX
        PUSH DX
        MOV DH,0
        ADD AX,DX
        ADD AX,DX
        POP DX
        MOV DI,AX
        POP AX
        PUSH AX
        MOV ES,TEXT_SEG
        TEST BL,128
        JZ PCC1
        XCHG BH,BL
PCC1:   AND BX,70FH
        ROL BH,1
        ROL BH,1
        ROL BH,1
        ROL BH,1
        OR BL,BH
        MOV AH,BL
        REP STOSW
        POP AX
        POP BX
        POP CX
        POP DI
        POP ES
        RET

;Invert CX PC characters at DX

PC_INVERT:
        PUSH ES
        PUSH DI
        PUSH CX
        PUSH AX
        MOV AL,DH
        MOV AH,0
        PUSH DX
        MUL ONESIXTY
        POP DX
        PUSH DX
        MOV DH,0
        ADD AX,DX
        ADD AX,DX
        INC AX
        POP DX
        MOV DI,AX
        MOV ES,TEXT_SEG
PCI1:   MOV AL,ES:[DI]
        MOV AH,AL
        ROL AL,1                ;Exchange foreground and background colours
        ROL AL,1
        ROL AL,1
        ROL AL,1
        AND AX,8877H            ;but leave intensity bit alone
        OR AL,AH
        MOV ES:[DI],AL
        INC DI
        INC DI
        LOOP PCI1
        POP AX
        POP CX
        POP DI
        POP ES
        RET

;Display an EGA overlay menu in [DI] (with shadow) at video coord DX, with 
;height BH, width BL.  Menu framework is light cyan on dark blue.
;BH bit 7=1 => draw shadow

MENU:       
        PUSH ES
        MOV AX,SEG SINGLE
        MOV ES,AX
        PUSH BX
MENU1:  PUSH BX
        MOV AL,ES:[DI]
        INC DI
        MOV CX,1
        MOV BH,MENU_BACK
        MOV BL,BH
        OR BL,MENU_FRONT
        CALL PC_CHAR
        INC DL
        POP BX
        DEC BL
        JNZ MENU1
        POP AX
        PUSH AX
        MOV BL,AL
        SUB DL,AL
        INC DH
        DEC BH
        TEST BH,127
        JNZ MENU1
        POP BX
        TEST BH,128
        JNZ MENU2
        POP ES
        RET
MENU2:  ADD DL,BL               ;Create shadow
        AND BH,127
        SUB DH,BH
MENU3:  INC DH
        PUSH BX
        MOV AL,219              ;Display a solid dark grey block
        MOV BX,8
        MOV CX,1
        CALL PC_CHAR
        POP BX
        DEC BH
        JNZ MENU3
        SUB DL,BL
        INC DL
        MOV CL,BL
        MOV BX,8
        CALL PC_CHAR
        POP ES
        RET

MENU_BACK DB 1                  ;Menu background colour
HELP_COLOUR DB 1                ;Colour of help screen (green if 512K)
MENU_FRONT DB 10                ;Colour to add to back to get foreground

;Display CoCo character AL at RAM address [DI] on EGA screen

COL_LSB DB 0                    ;Temporary storage of CoCo char column
USED_VRES DB 0                  ;Effective VRES based on DRB2 output
COLOUR_BASE DB 0                ;Add to pixel colour before displaying
USED_LPR DB 0                   ;Effective lines/row in graphics modes

        IF ENABLE_NATIVE_VIDEO

DEFAULT_PALETTE DB 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0

RESTORE_NATIVE_PALETTE:
        CMP WORD PTR NATIVE,JV
        JNZ NO_RESTORE_PALETTE
        MOV AL,NATIVE[2]
        AND AL,VIDEO_MODE_BITMASK
        JZ NO_RESTORE_PALETTE
        CMP AL,3
        JZ NO_RESTORE_PALETTE
        CMP AL,2
        JZ RESTORE_HIRES_PALETTE
        PUSH ES
        MOV ES,NATIVE_PALETTE
        MOV AX,1012H
        MOV BX,0
        MOV CX,100H
        MOV DX,0
        INT 10H
        POP ES
NO_RESTORE_PALETTE:
        RET
RESTORE_HIRES_PALETTE:
        PUSH ES
        MOV AX,CS
        MOV ES,AX
        MOV DX,OFFSET DEFAULT_PALETTE
        MOV AX,1002H
        INT 10H
        MOV ES,NATIVE_PALETTE
        MOV AX,1012H
        MOV BX,0
        MOV CX,10H
        MOV DX,0
RESTORE_HIRES_PALETTE_LOOP:
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        INT 10H
        POP DX
        POP CX
        POP BX
        POP AX
        ADD BL,10H
        JNZ RESTORE_HIRES_PALETTE_LOOP
        POP ES
        RET

HIRES_PALETTE:
        SUB BX,5800H            ;In palette range?
        JB NOT_HR_PAL
        CMP BX,16*3
        JNB NOT_HR_PAL
        PUSH DS
        MOV DS,NATIVE_PALETTE
        MOV AX,BX
        MOV CL,3
        DIV CL
        MOV DL,AL               ;DL = palette register
        SUB BL,AH               ;Realign BX to start of triplet
        SBB BH,0
        MOV DH,[BX]             ;Red
        MOV CH,[BX+1]           ;Green
        MOV CL,[BX+2]           ;Blue
        MOV BL,DL               ;Register
        MOV BH,0
        MOV AX,1010H
HR_PAL_LOOP:
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        INT 10H
        POP DX
        POP CX
        POP BX
        POP AX
        ADD BL,10H
        JNB HR_PAL_LOOP
        POP DS
NOT_HR_PAL:
        POP ES
        POP DI
        POP DX
        POP CX
        POP BX
        POP AX
        RET
            
LOWRES_PALETTE:
        SUB BX,5800H            ;In palette range?
        JB NOT_PALETTE
        CMP BX,256*3
        JNB NOT_PALETTE
        PUSH DS
        MOV DS,NATIVE_PALETTE
        MOV AX,BX
        MOV CL,3
        DIV CL
        MOV DL,AL               ;DL = palette register
        SUB BL,AH               ;Realign BX to start of triplet
        SBB BH,0
        MOV DH,[BX]             ;Red
        MOV CH,[BX+1]           ;Green
        MOV CL,[BX+2]           ;Blue
        MOV BL,DL               ;Register
        MOV BH,0
        MOV AX,1010H
        INT 10H
        POP DS
NOT_PALETTE:
        POP ES
        POP DI
        POP DX
        POP CX
        POP BX
        POP AX
        RET
            
HIRES_SHOW:
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        PUSH DI
        PUSH DS
        PUSH ES
        MOV DI,0FFB0H           ;Do this in case we're using emulated palette
HIRES_SHOW1:
        MOV AL,PALETTE[DI-0FFB0H]
        NOT BYTE PTR PALETTE[DI-0FFB0H]
        PUTBYTE                 ;Update colour palette
        INC DI
        CMP DI,0FFC0H
        JB HIRES_SHOW1
        CALL RESTORE_NATIVE_PALETTE
        MOV AX,0A000H
        MOV ES,AX
        MOV DS,NATIVE_VIDEO
        MOV DX,3CEH             ;Set colour write mode
        MOV AX,205H
        OUT DX,AX
        MOV AL,8                ;Write index to select bitmask register
        OUT DX,AL
        INC DX
        MOV BX,0
        MOV SI,0
        MOV CX,4000H
HIRES_SHOW2:
        CMP BX,80*480
        JNZ HIRES_SHOW3
        POP ES
        POP DS
        POP DI
        POP SI
        POP DX
        POP CX
        POP BX
        POP AX
        RET
HIRES_SHOW3:
        MOV AL,64               ;Process 8 pixels (4 bytes) at a time
        OUT DX,AL
        LODSB
        MOV AH,ES:[BX]
        MOV ES:[BX],AL
        MOV AH,AL
        SHR AH,4
        MOV AL,128
        OUT DX,AL
        MOV AL,ES:[BX]
        MOV ES:[BX],AH

        MOV AL,16
        OUT DX,AL
        LODSB
        MOV AH,ES:[BX]
        MOV ES:[BX],AL
        MOV AH,AL
        SHR AH,4
        MOV AL,32
        OUT DX,AL
        MOV AL,ES:[BX]
        MOV ES:[BX],AH

        MOV AL,4
        OUT DX,AL
        LODSB
        MOV AH,ES:[BX]
        MOV ES:[BX],AL
        MOV AH,AL
        SHR AH,4
        MOV AL,8
        OUT DX,AL
        MOV AL,ES:[BX]
        MOV ES:[BX],AH

        MOV AL,1
        OUT DX,AL
        LODSB
        MOV AH,ES:[BX]
        MOV ES:[BX],AL
        MOV AH,AL
        SHR AH,4
        MOV AL,2
        OUT DX,AL
        MOV AL,ES:[BX]
        MOV ES:[BX],AH

        INC BX
        LOOP HIRES_SHOW2
        MOV AX,DS
        ADD AX,1000H
        MOV DS,AX
        MOV CX,4000H
        JMP HIRES_SHOW3

;HIRES_PIXEL entry: assumes DH:BX is byte offset, AL is pixel, ES=A000H.
;Trashes AX, BX, CX, DX.

HIRES_PIXEL:                    ;Given a byte offset in DX:BX, draw pixel pair
        MOV CH,AL
        MOV CL,BL               ;Get byte alignment (=CoCo mem address/4)
        SHR BX,2
        SHL DH,6                ;Shift top bits in to get 16-bit offset
        OR BH,DH
        AND CL,3                ;CL = 2*low bits of CoCo address (to form bit
        SHL CL,1                ;field)
        MOV DX,3CEH             ;Set colour write mode
        MOV AX,205H
        OUT DX,AX
        MOV AL,8                ;Write index to select bitmask register
        OUT DX,AL
        INC DX
        MOV AL,64               ;Form mask for right pixel
        SHR AL,CL
        OUT DX,AL
        MOV CL,ES:[BX]
        MOV ES:[BX],CH
        SHR CH,4
        SHL AL,1
        OUT DX,AL
        MOV CL,ES:[BX]
        MOV ES:[BX],CH
        RET

HIRES_CHARGEN:
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH DI
        PUSH ES
        CALL GET_TRUE_ADDRESS
        CMP DH,2
        JNZ NOT_HR_PALETTE
        CMP BX,5800H
        JB NOT_HR_PALETTE
        JMP HIRES_PALETTE
NOT_HR_PALETTE:
        MOV CX,0A000H
        MOV ES,CX
        CALL HIRES_PIXEL
        POP ES
        POP DI
        POP DX
        POP CX
        POP BX
        POP AX
        RET

        ENDIF

CHARGEN_DONE:
        RET
CHARGEN_IF_CHANGED:
        CMP AL,ES:[BX]
        JZ CHARGEN_DONE
        MOV ES:[BX],AL
        JMP CHARGEN

CHARGEN:
        CMP CS:LASTKEY,3BH
        JNZ CHARGEN1
        RET
CHARGEN1:
        IF ENABLE_NATIVE_VIDEO

        CMP WORD PTR NATIVE,JV
        JNZ NOT_NATIVE_CHAR
        TEST BYTE PTR NATIVE[2],VIDEO_MODE_BITMASK
        JZ NOT_NATIVE_CHAR
        TEST BYTE PTR NATIVE[2],VIDEO_MODE_BITMASK-1
        JNZ HIRES_CHARGEN
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH DI
        PUSH ES
        CALL GET_TRUE_ADDRESS
        CMP DH,2                ;Doing palette?
        JZ LOWRES_PALETTE_A
        MOV AH,NATIVE[2]
        AND AH,PAGE_MASK
        MOV AH,0
        JZ NOT_PAGE1
        MOV AH,1
NOT_PAGE1:
        CMP DH,AH
        JNZ NOT_THIS_PAGE
        MOV DX,0A000H
        MOV ES,DX
        MOV ES:[BX],AL
NOT_THIS_PAGE:
        POP ES
        POP DI
        POP DX
        POP CX
        POP BX
        POP AX
        RET
LOWRES_PALETTE_A:
        JMP LOWRES_PALETTE
NOT_NATIVE_CHAR:

        ENDIF

        TEST BYTE PTR INIT0,128 ;Check for CoCo-compatible mode
        JNZ CHARGEN1A
        TEST BYTE PTR VMODE,128 ;If CoCo=0 and BP=1, we're in a graphics mode
        JNZ CHARGEN1B
        JMP ATTRIB              ;If disabled, go to "attributes enabled" text
CHARGEN1A:
        TEST BYTE PTR DRB2,128
        JZ CHARGEN2             ;Branch to text or graphics handler for 
CHARGEN1B:
        JMP GRAPHICS            ;CoCo=1 as appropriate
CHARGEN2:                       ;Text generation
        PUSH AX
        PUSH BX
        PUSH DX
        PUSH DI
        CALL GET_TRUE_ADDRESS
        MOV DI,AX
        MOV AX,BX
        SUB AX,NEW_TOP
        MOV BX,0FF20H
        TEST BYTE PTR VRES,16
        JZ CHARGEN2A
        MOV BX,64
CHARGEN2A:
        TEST BYTE PTR HORZ_OFF,128
        JZ CHARGEN2B
        XCHG AL,AH              ;If HVEN=1, lines are always 256 bytes long
        CMP AH,BL               ;If col. outside HVEN window, don't show it
        JB CHARGEN2C
        JMP CHARGEN2E
CHARGEN2B:
        DIV BL
CHARGEN2C:
        MOV BL,AH
        SHL BL,1
        MOV AH,80
        MUL AH
        ADD AX,8                ;Left margin of four characters
        INC BH
        JZ CHARGEN2D
        SHL AX,1                ;If in 64 col. mode, lines are twice as wide
CHARGEN2D:
        MOV BH,0                ;Add horizontal offset within line
        ADD AX,BX
        XCHG AX,DI
        TEST AL,128             ;If bit 7 set, this is a semigraphics mode
        JNZ SEMI
        MOV DL,DRB2
        MOV AH,54H              ;Text colour: Foreground 12, background 13
        TEST DL,8
        JZ CHARGEN2G
        MOV AH,76H              ;Unless CSS=1, then foreground 14, back 15
CHARGEN2G:
        TEST DL,16              ;If bit 4 is reset, character set is literal
        JZ CHARGEN2H
        CMP AL,32               ;Otherwise first 32 characters become
        JNB CHARGEN2H           ;lowercase
        OR AL,160
        JMP CHARGEN2F
SEMI:   MOV AH,AL               ;In semigraphics mode
        ROR AH,1                ;Extract colour from bits 4-6
        ROR AH,1
        ROR AH,1
        ROR AH,1
        AND AH,15               ;Colour is XORed with 8 first anyway
        AND AL,8FH              ;Select standard SG4 characters
        TEST BYTE PTR VRES,16
        JZ CHARGEN2F
        OR AL,16                ;Unless in 64 column mode, then select LHS
        JMP CHARGEN2F
CHARGEN2H:
        CMP AL,64
        JNB CHARGEN2F
        ROR AH,1                ;If in green-on-black portion of character
        ROR AH,1                ;set, reverse colours
        ROR AH,1
        ROR AH,1
        OR AL,64
CHARGEN2F:
        PUSH ES
        AND DI,32767
        MOV ES,TEXT_SEG
        STOSW
        POP ES
CHARGEN2E:
        POP DI
        POP DX
        POP BX
        POP AX
        RET

GRAPHICS:                       ;Graphics generator
        PUSH AX
        PUSH CX
        PUSH DX
        PUSH DI
        PUSH ES
        PUSH BX
        CALL GET_TRUE_ADDRESS   ;Get low 16 bits of 512K address
        MOV DI,AX
        MOV AX,BX
        SUB AX,NEW_TOP
        MOV BX,810H             ;Effective HRES0=0 gives 8 character margin
        TEST BYTE PTR USED_VRES,4
        JZ GRAPHICS1
        MOV BX,20               ;If we use margin, 5/4ths as many bytes/row
GRAPHICS1:                      ;Calculate the row we're on
        MOV CL,USED_VRES
        MOV CH,CL
        AND CH,3                ;CH=CRES
        TEST BYTE PTR INIT0,128 ;If CoCo=1 and...
        JZ GRAPHICS2
        TEST BYTE PTR V012,5    ;in 2048 byte mode...
        JNZ GRAPHICS2
        OR CL,8                 ;set HRES1=1 automatically
GRAPHICS2:
        SHR CL,1
        SHR CL,1
        SHR CL,1
        AND CL,3                ;CL=HRES2,1
        SHL BL,CL               ;(16 or 20)*2^(HRES2,1) bytes/row
        TEST BYTE PTR HORZ_OFF,128
        JZ GRAPHICS3            ;If HVEN=1 then always 256 bytes
        MOV DL,AL
        MOV DH,0
        MOV AL,AH
        CMP DL,BL               ;If past end of displayable bytes, don't
        JB GRAPHICS4            ;show anything
        JMP GRAPHICS_DONE
GRAPHICS3:
        PUSH BX
        MOV BH,0
        MOV DX,0
        DIV BX                  ;Divide offset by bytes/row
        POP BX
GRAPHICS4:
        MOV AH,80               ;80 bytes per PC row always
        MUL AH
        MOV BL,BH               ;Add margin offset if applicable
        MOV BH,0
        ADD AX,BX
        SHL DX,1                ;Multiply character offset by PC bytes per
        SHL DX,1                ;CoCo byte (which is 2^(2-HRES2,1)
        SHR DX,CL
        ADD AX,DX               ;Add offset to PC address
        XCHG AX,DI              ;AL=character, DI=PC video offset
        PUSH AX
        MOV DX,3C4H             ;Select colour plane register
        MOV AL,2
        OUT DX,AL
        INC DX
        DEC AL                  ;By default, select bitplane 0
        OUT DX,AL
        POP AX
        MOV ES,VID_SEG          ;Set ES: to point to video segment
        OR CL,CL                ;Check for HRES2,1=0 modes
        JNZ NOT_HRES0
        OR CH,CH
        JNZ NOT_128R
        MOV AH,AL               ;128- or 160-pixel 2-colour mode (CRES=0)
        MOV BX,OFFSET TABLE_128
        MOV CX,4
GRAPHICS_128R:
        ROL AH,1
        ROL AH,1
        MOV AL,AH
        AND AL,3
        XLAT
        STOSB
        LOOP GRAPHICS_128R      ;CoCo byte is broken down into 4 PC bytes
        JMP GRAPHICS_DONE
NOT_128R:
        DEC CH
        JNZ NOT_64C
        MOV AH,AL               ;64- or 80-pixel 4-colour mode (CRES=1)
        MOV CH,2                ;Two bit planes
GRAPHICS_64C:
        MOV CL,4                ;4 bytes per CoCo byte
GRAPHICS_64C_1:
        ROL AH,1
        ROL AH,1                ;Align to next pixel field
        SBB AL,AL               ;Set AL=-1 or 0 according to bit 0 of AH
        STOSB
        DEC CL
        JNZ GRAPHICS_64C_1
        SUB DI,4                ;Go back to start of field
        ROR AH,1                ;Select next colour bit field
        MOV AL,CH               ;Select bitplane 1
        OUT DX,AL
        DEC CH                  ;Loop for both bit planes
        JNZ GRAPHICS_64C
        JMP GRAPHICS_DONE
NOT_64C:
        DEC CH                  ;HRES2,1=0, CRES=2 is a mutant mode in which
        JZ GRAPHICS_64P         ;the res. is 64P but each byte is spaced out
        JMP GRAPHICS_DONE       ;CRES=3 is an invalid mode
NOT_HRES0:
        DEC CL                  ;Check for HRES2,1=1 modes
        JNZ NOT_HRES1
        OR CH,CH
        JNZ NOT_256R
        MOV AH,AL               ;256- or 320-pixel 2-colour mode (CRES=0)
        MOV CL,4
        SHR AH,CL
        AND AX,0F0FH
        MOV BX,OFFSET TABLE_256
        XLAT
        XCHG AH,AL
        XLAT
        STOSW
        JMP GRAPHICS_DONE
NOT_256R:
        DEC CH
        JNZ NOT_128C
        MOV AH,AL               ;128- or 160-pixel 4-colour mode (CRES=1)
        MOV CX,204H             ;2 bit planes
        SHR AH,CL
        MOV BX,OFFSET TABLE_128
GRAPHICS_128C:
        PUSH AX
        AND AX,0505H
        XLAT
        XCHG AH,AL
        XLAT
        MOV ES:[DI],AX
        MOV AL,2                ;Select bitplane 1
        OUT DX,AL
        POP AX
        ROR AX,1                ;Align to bitplane 1 pixels
        DEC CH
        JNZ GRAPHICS_128C       ;Loop for next bitplane
        JMP GRAPHICS_DONE
NOT_128C:
        DEC CH
        JNZ NOT_64P
GRAPHICS_64P:                   ;64- or 80-pixel 16-colour (CRES=2)
        MOV BH,AL
        MOV BL,AL
        MOV CX,4
        SHR BH,CL
GRAPHICS_64P_1:
        SHR BL,1                ;Get right pixel's bitplane on/off state
        SBB AH,AH
        SHR BH,1                ;Get left pixel's bitplane on/off state
        SBB AL,AL
        MOV ES:[DI],AX
        MOV AL,32               ;Select next bitplane (mask=32/2^CX)
        SHR AL,CL
        OUT DX,AL
        LOOP GRAPHICS_64P_1
NOT_64P:                        ;CRES=3 mode invalid
        JMP GRAPHICS_DONE
NOT_HRES1:                      ;Check for HRES2,1=2 modes
        DEC CL
        JNZ NOT_HRES2
        OR CH,CH
        JNZ NOT_512R
        STOSB                   ;512- or 640-pixel 2-colour (CRES=0)
        JMP GRAPHICS_DONE       ;is a simple direct write of the CoCo byte
NOT_512R:
        DEC CH
        JNZ NOT_256C
        MOV AH,AL               ;256- or 320-pixel 4-colour (CRES=1)
        AND AX,0AA55H
        MOV BX,AX
        SHL BL,1
        SHR BH,1
        OR AX,BX
        STOSB
        MOV AL,2                ;Select bitplane 1
        OUT DX,AL
        MOV ES:[DI-1],AH
        JMP GRAPHICS_DONE
NOT_256C:
        DEC CH
        JNZ NOT_128P
        MOV CX,4                ;128- or 160-pixel 16-colour (CRES=2)
        MOV BL,AL
        MOV BH,15
GRAPHICS_128P:
        MOV AL,BL               ;Get bits associated with pixels' bitplanes
        AND AL,11H
        MUL BH                  ;Convert to four-bit patterns
        MOV ES:[DI],AL
        MOV AL,32               ;Select next bitplane on VGA
        SHR AL,CL
        OUT DX,AL
        ROR BL,1                ;Select next bitplane in CoCo byte
        LOOP GRAPHICS_128P
NOT_128P:                       ;CRES=3 is invalid
        JMP GRAPHICS_DONE
NOT_HRES2:                      ;HRES2,1=3 mode.
        OR CH,CH
        JNZ NOT_1024R           ;HRES2,1=3, CRES=0 is a mutant mode where
        POP BX                  ;only even-address video RAM bytes count,
        PUSH BX
        TEST BL,1
        JNZ NOT_128P            ;and bit 7 of the data sets the entire
        ROL AL,1                ;64- or 80-pixel/line pixel
        SBB AL,AL
        STOSB
        JMP GRAPHICS_DONE
NOT_1024R:
        POP BX
        PUSH BX                 ;For the rest, each CoCo byte is *half*
        PUSH ES                 ;the PC byte, so two CoCo bytes are needed
        MOV AX,BX
        AND BX,0E000H
        MOV ES,SS:[BX]          ;Get them from appropriate bank of CoCo mem.
        AND AL,0FEH
        MOV BX,AX
        MOV AX,ES:[BX]
        POP ES
        DEC CH
        JNZ NOT_512C
        MOV CX,204H             ;512- or 640-pixel 4-colour (CRES=1)
        MOV BX,OFFSET TABLE_512
GRAPHICS_512C:
        PUSH AX
        AND AX,5555H            ;Translate a bitplane's word into a byte
        XLAT
        XCHG AH,AL
        XLAT
        ROL AH,CL
        OR AL,AH
        MOV ES:[DI],AL
        MOV AL,2                ;Select bitplane 1
        OUT DX,AL
        POP AX
        SHR AX,1                ;Align to next bitplane's data
        DEC CH
        JNZ GRAPHICS_512C
        JMP GRAPHICS_DONE
NOT_512C:
        DEC CH
        JNZ NOT_256P
        MOV CX,4                ;Four bitplanes for this one
        MOV BX,AX
GRAPHICS_256P:
        MOV AX,BX
        AND AX,1111H            ;Pick out pixels for this bit plane
        PUSH DX
        MOV DX,15               ;Set the three adjacent bits if they are set
        MUL DX
        POP DX
        AND AX,3C3CH            ;Isolate them into two sets 4 adjacent pixels
        ROR AH,1                ;(with 2 bits per CoCo pixel), then combine
        ROR AH,1                ;them
        ROL AL,1
        ROL AL,1
        OR AL,AH
        MOV ES:[DI],AL
        SHR BX,1                ;Align to next bitplane
        MOV AL,32
        ROR AL,CL
        OUT DX,AL               ;Select next PC bitplane
        LOOP GRAPHICS_256P      ;Loop for all bitplanes
NOT_256P:
GRAPHICS_DONE:
        POP BX
        POP ES
        POP DI
        POP DX
        POP CX
        POP AX
        RET

;CoCo=0 text mode handler starts here
ATTRIB: PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        PUSH DI
        PUSH ES
        MOV CL,VRES
        TEST CL,1               ;If CRES0=0, attribute bytes are disabled
        JZ ATTRIB1
        PUSH BX
        AND BX,0E000H           ;Get both character *and* attribute
        MOV ES,SS:[BX]
        POP BX
        AND BL,0FEH
        MOV AX,ES:[BX]          ;Get character in AL, attribute in AH
ATTRIB1:        
        AND AL,127              ;There are only seven bits to the CoCo 3 font
        PUSH AX
        CALL GET_TRUE_ADDRESS   ;Get the low 16 bits of the absolute address
        MOV ES,TEXT_SEG
        MOV AX,BX               ;Find offset into CoCo video memory
        SUB AX,NEW_TOP
        TEST CL,1
        JZ ATTRIB2
        SHR AX,1                ;2 bytes per character in CRES0=1 mode
ATTRIB2:
        MOV BL,32               ;If HRES0=0 then 32/64 column mode
        TEST CL,4
        JZ ATTRIB3
        MOV BL,40               ;else in 40/80 column mode
ATTRIB3:
        TEST CL,16              ;If HRES2=1 then in 64/80 column mode
        JZ ATTRIB4
        SHL BL,1
ATTRIB4:
        TEST BYTE PTR HORZ_OFF,128
        JZ ATTRIB5
        MOV DL,AL               ;If HVEN=1, each line always 256 bytes wide
        MOV AL,AH
        MOV AH,0
        MOV DH,AH
        TEST CL,1
        JZ ATTRIB4A             ;If CRES=0, that's 256 characters
        RCL DL,1                ;Else it's 128 characters, so bit 7 of
        ADC AX,AX               ;remainder becomes bit 0 of AX as AX doubles
        SHR DL,1
ATTRIB4A:
        CMP DL,BL               ;If remainder beyond physics cols/row
        JB ATTRIB6
        POP AX                  ;then skip this character
        JMP ATTRIB15
ATTRIB5:
        MOV DX,0
        PUSH BX
        MOV BH,0
        DIV BX
        POP BX
ATTRIB6:
        MOV AH,80               ;Calculate offset in text display
        MUL AH
        TEST CL,4               ;If in 32/64 mode, add margin
        JNZ ATTRIB6A
        ADD AL,8
ATTRIB6A:
        TEST CL,16              ;If in 64/80 col. mode, twice as many bytes
        JZ ATTRIB6B             ;per line
        SHL AX,1
ATTRIB6B:
        ADD AX,DX
        ADD AX,DX
        MOV DI,AX               ;DI now offset to char. on PC screen
        POP AX
        TEST AH,64
        JZ ATTRIB7
        OR AL,128               ;Upper 128 characters in set are underlined
ATTRIB7:
        MOV BL,AH               ;Work out PC style character attribute
        ROR BL,1                
        ROR BL,1
        ROR BL,1
        MOV BH,AH
        ROL BH,1
        ROL BH,1
        ROL BH,1
        ROL BH,1
        AND BX,7007H
        AND AH,128              ;Retain blinking bit
        OR AH,BH
        OR AH,BL
        OR AH,8                 ;Foreground colours are 8-15
        TEST CL,1               ;If CRES0=0, then no blinking and colours are
        JNZ ATTRIB8             ;foreground: CoCo palette 1, background: 0
        AND AL,127
        MOV AH,1
ATTRIB8:
        STOSW                   ;Store character to text screen
ATTRIB15:
        POP ES
        POP DI
        POP SI
        POP DX
        POP CX
        POP BX
        POP AX
        RET

TABLE_128 DB 0                  ;x0x0 or xx00 -> 0000 0000
        DB 15                   ;xx01 or x0x1 -> 0000 1111
        DB 240                  ;xx10 -> 1111 0000
        DB 255                  ;xx11 -> 1111 1111
        DB 240                  ;x1x0 -> 1111 0000
        DB 255                  ;x1x1 -> 1111 1111

TABLE_256 DB 0                  ;0000 -> 00 00 00 00
        DB 03H                  ;0001 -> 00 00 00 11
        DB 0CH                  ;0010 -> 00 00 11 00
        DB 0FH                  ;0011 -> 00 00 11 11
        DB 30H                  ;0100 -> 00 11 00 00
        DB 33H                  ;0101 -> 00 11 00 11
        DB 3CH                  ;0110 -> 00 11 11 00
        DB 3FH                  ;0111 -> 00 11 11 11
        DB 0C0H                 ;1000 -> 11 00 00 00
        DB 0C3H                 ;1001 -> 11 00 00 11
        DB 0CCH                 ;1010 -> 11 00 11 00
        DB 0CFH                 ;1011 -> 11 00 11 11
        DB 0F0H                 ;1100 -> 11 11 00 00
        DB 0F3H                 ;1101 -> 11 11 00 11
        DB 0FCH                 ;1110 -> 11 11 11 00
        DB 0FFH                 ;1111 -> 11 11 11 11

;Denoting output bit # "O#", and input bit # "I#", XLATing using this table
;gives a byte with O0=I0 or I1, O1=I2 or I3, O2=I4 or I5, O3=I6 or I7
TABLE_512 DB 0
        DB 1,1,1,2,3,3,3,2,3,3,3,2,3,3,3,4,5,5,5,6,7,7,7,6,7,7,7,6,7,7,7,4
        DB 5,5,5,6,7,7,7,6,7,7,7,6,7,7,7,4,5,5,5,6,7,7,7,6,7,7,7,6,7,7,7,8,9
        DB 9,9,10,11,11,11,10,11,11,11,10,11,11,11,12,13,13,13,14,15,15,15,14
        DB 15,15,15,14,15,15,15,12,13,13,13,14,15,15,15,14,15,15,15,14,15,15
        DB 15,12,13,13,13,14,15,15,15,14,15,15,15,14,15,15,15,8,9,9,9,10,11
        DB 11,11,10,11,11,11,10,11,11,11,12,13,13,13,14,15,15,15,14,15,15,15
        DB 14,15,15,15,12,13,13,13,14,15,15,15,14,15,15,15,14,15,15,15,12,13
        DB 13,13,14,15,15,15,14,15,15,15,14,15,15,15,8,9,9,9,10,11,11,11,10
        DB 11,11,11,10,11,11,11,12,13,13,13,14,15,15,15,14,15,15,15,14,15,15
        DB 15,12,13,13,13,14,15,15,15,14,15,15,15,14,15,15,15,12,13,13,13,14
        DB 15,15,15,14,15,15,15,14,15,15,15

THIRTYTWO  DB 32
TWENTYFIVE DB 25

;Converts CoCo 64K bank address to true 512K absolute address

GET_TRUE_ADDRESS:
        MOV DI,BX
        AND BH,1FH              ;Get offset within bank
        ROL DI,1
        ROL DI,1
        ROL DI,1
        AND DI,7                ;A15-A13 determine MMU register
        TEST BYTE PTR INIT1,1
        JZ GTA1
        ADD DI,8                ;Select MMU set based on task register
GTA1:   MOV DL,MMU[DI]          ;Load MMU bank number
        MOV DH,MMU2[DI]
        ROL DX,5                ;Want only A15-A13 of true address
        AND DX,7E0H
        OR BH,DL
GTA2:   RET

;Read current directory.  Search path name is in DX, table to store directory
;is at SS:SI (14 bytes per entry), CX is number of free entries in table,
;BL=10h for a list of subdirectories, BL=0 for files.

;On return, DI=first empty entry in directory, CX=number of remaining free
;entries.  Directory is sorted alphabetically.

SEARCH:
        MOV DI,SI
        MOV AH,11H
        INT 21H
        INC AL
        JNZ SEARCH0
        RET
SEARCH0:
        MOV AL,DTA[19]
        XOR AL,BL
        AND AL,16
        JZ SEARCH1
        JMP SEARCH9
SEARCH1:                        ;Find DTA's entry's position in alphabetic
        PUSH SI                 ;list
        PUSH BX
SEARCH2:
        MOV BX,0
        CMP SI,DI
        JNB SEARCH6
SEARCH3:
        MOV AL,DTA[BX+8]
        CMP AL,SS:[SI+BX]
        JB SEARCH5
        JA SEARCH4
        INC BX
        CMP BX,11
        JB SEARCH3
SEARCH4:
        ADD SI,14
        JMP SEARCH2
SEARCH5:                        ;Shift entire directory list up one entry
        PUSH CX
        PUSH SI
        PUSH DI
        PUSH DS
        PUSH ES
        MOV AX,SS
        MOV DS,AX
        MOV ES,AX
        MOV CX,DI
        SUB CX,SI
        DEC DI
        MOV SI,DI
        ADD DI,14
        STD
        REP MOVSB
        MOV CX,14               ;Clear the newly created space
        MOV AL,32
        REP STOSB
        CLD
        POP ES
        POP DS
        POP DI
        POP SI
        POP CX
        MOV BX,0
SEARCH6:                        ;Move filename
        MOV AL,DTA[BX+8]
        MOV SS:[SI],AL
        CMP AL,' '
        JZ SEARCH7
        INC SI
        INC BL
        CMP BL,8
        JB SEARCH6
SEARCH7:                        ;Add extension if applicable
        MOV AH,DTA[16]
        CMP AH,' '
        JZ SEARCH8
        MOV AL,'.'
        MOV SS:[SI],AX
        ADD SI,2
        MOV AL,DTA[17]
        CMP AL,' '
        JZ SEARCH8
        MOV SS:[SI],AL
        INC SI
        MOV AL,DTA[18]
        CMP AL,' '
        JZ SEARCH8
        MOV SS:[SI],AL
        INC SI
SEARCH8:
        MOV BYTE PTR SS:[SI],0
        ADD DI,14
        POP BX
        POP SI
        LOOP SEARCH9
        RET
SEARCH9:
        MOV AH,12H
        INT 21H
        INC AL
        JNZ SEARCH10
        RET
SEARCH10:
        JMP SEARCH0

;Build directory list and display first 21 entries in the directory window
;Specific file extension is given by FCB at DX.

TOTAL_DRIVES DB 0                       ;Total number of logical drives

DIR:
        MOV LAST_DIR,DX
        MOV SI,CUR_DIR
DIR1:   MOV BYTE PTR SS:[SI],' '
        INC SI
        CMP SI,7000+CUR_DIR
        JB DIR1
        MOV CL,TOTAL_DRIVES
        MOV CH,0
        MOV SI,CUR_DIR
        MOV AX,3A41H                    ;Drive list, starting with A:
DIR1A:  MOV BYTE PTR SS:[SI],'['
        MOV SS:[SI+1],AX
        MOV BYTE PTR SS:[SI+3],']'
        INC AL
        ADD SI,14
        LOOP DIR1A
        PUSH DX
        MOV CX,498
        MOV AL,TOTAL_DRIVES
        MOV AH,0
        SUB CX,AX
        INC SI
        MOV DX,OFFSET DIRSEARCH
        MOV BL,16
        CALL SEARCH
        INC CX
        DEC SI
        DEC DI
DIR2:   CMP SI,DI               ;Put brackets around directory names
        JNB DIR3
        MOV BYTE PTR SS:[SI],'['
        ADD SI,14
        JMP DIR2
DIR3:   DEC SI
        CMP BYTE PTR SS:[SI],0
        JNZ DIR4
        MOV BYTE PTR SS:[SI],']'
DIR4:   CMP SI,CUR_DIR
        JNB DIR3
        POP DX
        MOV SI,DI
        MOV BL,0
        CALL SEARCH
        MOV AX,294
        MUL DIR_PAGE
        ADD AX,CUR_DIR
        MOV SI,AX
        CMP BYTE PTR SS:[SI],0
        JZ DIR5
        CMP BYTE PTR SS:[SI],32
        JZ DIR5
        CALL SHOWDIR
        RET
DIR5:   MOV DIR_PAGE,0
        CALL SHOWDIR
        RET

;Display the 21st*(DIR_PAGE) entry of the directory listing.

DIR_PAGE DW 0

SHOWDIR:
        MOV DIR_PTR,-1
        MOV AX,294
        MUL DIR_PAGE
        ADD AX,CUR_DIR
        MOV SI,AX
        MOV DX,340H
SHOWDIR1:
        MOV AL,SS:[SI]
        MOV BX,10BH
        MOV CX,1
        CALL PC_CHAR
        INC SI
        INC DL
        CMP DL,64+14
        JB SHOWDIR1
        MOV AL,32
        CALL PC_CHAR
        MOV DL,64
        INC DH
        CMP DH,24
        JB SHOWDIR1
        RET

;Reset main interpreter branch loop

RESETBRANCH:
        MOV BYTE PTR INST,0C3H  ;Set INST to "RET"
        CMP LASTKEY,0           ;If last key pressed not attended to, do it
        JNZ RB3
        CMP BRKPT,-1            ;Include breakpoint test if set
        JNZ RB2
        CMP DELAY,0             ;Include delay loop if requested
        JNZ RB1
        MOV AL,OFFSET MAIN-OFFSET BRANCH1
        MOV BYTE PTR BRANCH,AL
        MOV BYTE PTR INST,56H   ;Restore "PUSH SI"
        RET
RB1:    MOV BYTE PTR BRANCH,OFFSET SLOW-OFFSET BRANCH1
        RET
RB2:    MOV BYTE PTR BRANCH,OFFSET BRANCH3-OFFSET BRANCH1
        RET
RB3:    MOV BYTE PTR BRANCH,0
        RET

;Display source code

SOURCE:
        PUSH ES
        MOV AX,SEG SINGLE
        MOV ES,AX
        MOV BL,DISTYPE
        CMP BL,8
        JZ EXPLICIT
        MOV BH,0
        ADD BX,BX
        MOV AX,REGPC[BX-2]
        MOV DISADR,AX
EXPLICIT:
        MOV AX,DISADR
        MOV DX,0C1FH
        CMP BYTE PTR DISTYPE,8
        JZ SOURCE2
        MOV AH,2
        MOV BX,7
        INT10H
        MOV AH,14
        MOV AL,'['
        INT10H
        MOV AL,LASTDIS
        CMP AL,'A'
        JNZ SOURCE0
        MOV AL,'D'
SOURCE0:
        INT10H
        MOV AL,LASTDIS
        CMP AL,'P'
        MOV CX,'C]'
        JZ SOURCE1
        MOV CX,'P]'
        CMP AL,'D'
        JZ SOURCE1
        MOV CX,'] '
SOURCE1:
        MOV AL,CH
        INT10H
        MOV AL,CL
        INT10H
        JMP SOURCE3
SOURCE2:
        CALL BIT16
SOURCE3:
        MOV DI,DISADR
        MOV DX,0D12H
SOURCE4:
        MOV AX,DI
        CALL BIT16
        MOV AX,0E20H
        MOV BX,7
        INT10H
        MOV CX,25
        MOV AX,920H
        MOV BX,7
        INT10H
        PUSH ES
        GETBYTE
        POP ES
        INC DI
        CMP AL,10H
        MOV SI,OFFSET DBL10
        JZ SOURCE5
        MOV SI,OFFSET DBL11
        CMP AL,11H
        JZ SOURCE5
        MOV SI,OFFSET SINGLE
        JMP SOURCE6
SOURCE5:
        PUSH ES
        GETBYTE
        POP ES
        INC DI
SOURCE6:
        CMP AL,0
        JZ SOURCE8
SOURCE7:   
        INC SI
        CMP BYTE PTR ES:[SI-1],'|'
        JNZ SOURCE7
        DEC AL
        JMP SOURCE6
SOURCE8:
        MOV AL,ES:[SI]
        INC SI
        CMP AL,'|'
        JZ SOURCE9
        CMP AL,'$'
        JZ SOURCE10
        MOV AH,14
        MOV BX,7
        INT10H
        JMP SOURCE8
SOURCE9:
        INC DH
        CMP DH,24
        JB SOURCE4
        MOV AX,DI
        AND AX,0F0FH
        MOV BH,0
        MOV BL,AH
        NOT BX
        MOV AH,HEX_LIST[BX+16]
        MOV MSG8A[1],AH
        MOV BL,AL
        NOT BL              
        MOV AH,HEX_LIST[BX+16]
        MOV MSG8A[3],AH
        MOV AX,DI
        MOV CL,4
        SHR AX,CL
        AND AX,0F0FH
        MOV BH,0
        MOV BL,AH
        NOT BX
        MOV AH,HEX_LIST[BX+16]
        MOV MSG8A,AH
        MOV BL,AL
        NOT BL
        MOV AH,HEX_LIST[BX+16]
        MOV MSG8A[2],AH
        POP ES
        RET
SOURCE10:
        MOV AL,ES:[SI]
        INC SI
        CMP AL,'d'      ;Base page direct mode
        MOV AH,'<'
        JZ SOURCE11
        CMP AL,'o'      ;8-bit post-byte offset
        JZ SOURCE11A
        CMP AL,'b'      ;8-bit immediate
        JNZ SOURCE12
        MOV AH,'#'
SOURCE11:        
        MOV AL,AH
        MOV AH,14
        MOV BX,7
        INT10H
SOURCE11A:
        MOV AX,0E24H
        INT10H
        PUSH DX
        MOV AH,3
        INT10H
        PUSH ES
        GETBYTE
        POP ES
        INC DI
        CALL BIT8
        POP DX
        JMP SOURCE8
SOURCE12:
        CMP AL,'l'      ;Long label branch
        JZ SOURCE13
        CMP AL,'s'      ;Short label branch
        JNZ SOURCE15
        PUSH ES
        GETBYTE
        POP ES
        INC DI
        CBW
        ADD AX,DI
        JMP SOURCE14
SOURCE13:
        PUSH ES
        GETWORD
        POP ES
        ADD DI,2
        ADD AX,DI
SOURCE14:
        PUSH DX
        PUSH AX
        MOV AX,0E24H
        MOV BX,7
        INT10H
        MOV AH,3
        INT10H
        POP AX
        CALL BIT16
        POP DX
        JMP SOURCE8
SOURCE15:
        CMP AL,'a'      ;16-bit extended direct address
        MOV AH,14
        MOV BX,7
        JNZ SOURCE16
        PUSH ES
        GETWORD
        POP ES
        CMP AH,0
        JNZ SOURCE15B
        PUSH AX
        MOV AH,14
        MOV AL,'>'
        INT10H
        POP AX
SOURCE15B:
        ADD DI,2
        JMP SOURCE14
SOURCE15A:
        PUSH ES
        GETWORD
        POP ES
        ADD DI,2
        JMP SOURCE14
SOURCE16:
        CMP AL,'O'      ;16-bit post-byte offset
        JZ SOURCE15A
        CMP AL,'w'      ;16-bit immediate
        JNZ SOURCE17
        MOV AL,'#'
        INT10H
        PUSH ES
        GETWORD
        POP ES
        ADD DI,2
        JMP SOURCE14
SOURCE17:
        CMP AL,'2'      ;Binary
        JZ SOURCE17A
        CMP AL,'p'      ;Indirect index addressing post byte
        JZ SOURCE18
        CMP AL,'t'      ;EXG/TFR post byte
        JZ SOURCE19
        CMP AL,'r'      ;PSHS/PULS post byte
        MOV SI,OFFSET SP_LIST
        JZ SOURCE24A
        CMP AL,'u'      ;PSHU/PULU post byte
        MOV SI,OFFSET UP_LIST
        JZ SOURCE24A
        MOV AL,'?'
        INT10H
        PUSH ES
        GETBYTE
        POP ES
        INC DI
        JMP SOURCE8
SOURCE24A:
        JMP SOURCE24
SOURCE17A:
        MOV AX,0E23H
        INT10H
        MOV AX,0E25H
        INT10H
        PUSH ES
        GETBYTE
        POP ES
        INC DI
        MOV CL,AL
        MOV CH,8
SOURCE17B:
        MOV AL,'0'
        ROL CL,1
        ADC AL,0
        MOV AH,14
        INT10H
        DEC CH
        JNZ SOURCE17B
        JMP SOURCE8
SOURCE18:
        PUSH ES
        GETBYTE
        POP ES
        INC DI
        MOV SI,OFFSET POST_TABLE
        JMP SOURCE6
SOURCE19:
        PUSH ES
        GETBYTE
        POP ES
        INC DI
        PUSH AX
        MOV CL,4
        SHR AL,CL
        MOV SI,OFFSET EXG_LIST
SOURCE20:        
        CMP AL,0
        JZ SOURCE22
SOURCE21:        
        INC SI
        CMP BYTE PTR ES:[SI-1],'|'
        JNZ SOURCE21
        DEC AL
        JNZ SOURCE21
SOURCE22:
        MOV AL,ES:[SI]
        INC SI
        MOV AH,14
        MOV BX,7
        INT10H
        CMP BYTE PTR ES:[SI],'|'
        JNZ SOURCE22
        CMP CL,4
        JZ SOURCE23
SOURCE9A:
        JMP SOURCE9
SOURCE23:
        MOV AH,14
        MOV AL,','
        INT10H
        POP AX
        AND AL,15
        MOV CL,0
        MOV SI,OFFSET EXG_LIST
        JMP SOURCE20
SOURCE24:
        PUSH ES
        GETBYTE
        POP ES
        INC DI
        CMP AL,0
        JZ SOURCE9A
        MOV CL,AL
SOURCE25:
        SHL CL,1
        JC SOURCE27
SOURCE26:
        INC SI
        CMP BYTE PTR ES:[SI-1],'|'
        JNZ SOURCE26
        JMP SOURCE25
SOURCE27:
        MOV AL,ES:[SI]
        MOV AH,14
        MOV BX,7
        INT10H
        INC SI
        CMP BYTE PTR ES:[SI],'|'
        JNZ SOURCE27
        CMP CL,0
        JZ SOURCE9A
        MOV AL,','
        MOV AH,14
        INT10H
        INC SI
        JMP SOURCE25

;Transfer 8086 flags in REGF to 6809 format in REGFI, no registers affected

XLTFLAG:
        PUSH AX
        PUSH BX
        MOV AX,REGF
        AND AX,08F7H
        OR AL,AH
        MOV BX,OFFSET FLAGS_TO_6809
        MOV BL,AL
        MOV AL,SS:[BX]
        AND BYTE PTR REGFI,0D0H
        OR REGFI,AL
        POP BX
        POP AX
        RET

;Transfer 6809 flags in REGFI to 8086 flags in REGF, no registers affected

UPDFLAG:
        PUSH AX
        PUSH BX
        MOV AL,REGFI
        MOV BX,OFFSET FLAGS_TO_8086
        MOV BL,AL
        MOV AL,SS:[BX]
        MOV AH,AL
        AND AX,08F7H
        AND REGF,0F72EH
        OR REGF,AX
        POP BX
        POP AX
        RET

;Display flag contents

SHOWFL:
        MOV CH,8
        MOV CL,REGFI
        MOV DX,0E01H
SHOWFL1:
        MOV BH,0
        MOV AH,2
        INT10H
        ADD DL,2
        MOV AX,0E30H
        ROL CL,1
        ADC AL,0
        MOV BL,7
        INT10H
        DEC CH
        JNZ SHOWFL1
        RET

;Display message pointed to by SI on last line of video.  Must be terminated
;by a 0.

DISPLAYCS:
        PUSH DS
        MOV AX,SEG MSG17
        MOV DS,AX
        CALL DISPLAY
        POP DS
        RET

DISPLAY:
        MOV DX,1800H        
        MOV AH,2
        MOV BX,14
        INT10H
        MOV AX,920H
        MOV BX,14
        MOV CX,80
        INT10H
DISPLAY1:
        MOV AL,[SI]
        CMP AL,0
        JZ DISPLAY2
        MOV AH,14
        INT10H
        INC SI
        JMP DISPLAY1
DISPLAY2:
        RET

;Return an address in AX (if NZ) or a register code in CL (if Z).
;Storage field is at DI, prompt text is at SI.

ADDRESS:
        MOV CX,4
        CALL INPUT
        JNC ADDR0
        RET
ADDR0:  CMP WORD PTR [DI],5044H
        JNZ ADDR3
        MOV CX,6
        CLC
        RET
ADDR3:  CMP WORD PTR [DI],2F41H
        JNZ ADDR4
        MOV CX,7
        CLC
        RET
ADDR4:  MOV AL,[DI]
        FIND RG_LIST,5
        CLC
        PUSHF
        MOV AX,0
        JNZ ADDR1
        INC CL
        POPF
        RET
ADDR1:  MOV BX,AX
        MOV AL,[DI]
        FIND HEX_LIST,16
        JNZ ADDR2        
        MOV AX,CX
        MOV CL,4
        SHL BX,CL
        ADD AX,BX
        INC DI
        JMP ADDR1
ADDR2:  POPF
        MOV AX,BX
        RET

;Display 16-bit contents in AX at cursor location DX

BIT16:
        PUSH AX
        MOV AH,2
        MOV BH,0
        INT10H
        POP AX
        MOV CX,404H
BIT16_1:
        ROL AX,CL
        PUSH AX
        AND AX,15
        MOV BX,AX
        NEG BX
        MOV AL,HEX_LIST[BX+15]
        MOV AH,14
        MOV BX,7
        INT10H
        POP AX
        DEC CH
        JNZ BIT16_1
        RET

;Display 8-bit contents of AL at cursor location DX

BIT8:
        PUSH AX
        MOV AH,2
        MOV BH,0
        INT10H
        POP AX
        MOV CX,204H
        XCHG AH,AL
        JMP BIT16_1

;Update register contents

SHOWREG:
        MOV DX,404H
        MOV AX,REGD
        CALL BIT16
        INC DH
        MOV AX,REGX
        CALL BIT16
        INC DH
        MOV AX,REGY
        CALL BIT16
        INC DH
        MOV AX,REGU
        CALL BIT16
        INC DH
        MOV AX,REGSP
        CALL BIT16
        INC DH
        MOV AX,REGPC
        CALL BIT16
        INC DH
        MOV AL,REGDP
        CALL BIT8
        RET

;Display prompt at SI and use last CX bytes as input field.  Return C set
;if ESC pressed.

INPUT:
        PUSH SI
        PUSH CX
        CALL DISPLAY
        MOV AH,3
        MOV BH,0
        INT10H
        POP CX
        POP SI
        SUB DL,CL
        MOV AH,2
        INT10H
        MOV DH,0
        MOV DI,SI
        ADD DI,DX
        PUSH DI
        MOV BX,OFFSET BACKUP
INPUT0: MOV AL,[DI]
        MOV [BX],AL
        INC DI
        INC BX
        CMP AL,0
        JNZ INPUT0
        POP DI
        MOV BX,DI
        CSRON
        KEYSTROKE
        CMP AL,13
        JZ INPUT1
        CLEAR
        JMP INPUT3
INPUT1: CSROFF
        CLC
        RET
INPUT2: KEYSTROKE
INPUT3: CMP AL,13
        JZ INPUT1
        CMP AL,27
        JNZ INPUT4
        MOV BX,OFFSET BACKUP
        PUSH DI
INPUT7: MOV AL,[BX]    
        MOV [DI],AL
        INC BX
        INC DI
        CMP AL,0
        JNZ INPUT7
        POP DI
        CSROFF
        STC
        RET
INPUT4: CMP AL,8
        JNZ INPUT5
        CMP BX,DI
        JNA INPUT2
        DEC BX
        MOV BYTE PTR [BX],32
        MOV AH,14
        PUSH BX
        MOV BX,14
        INT10H
        MOV AL,32
        INT10H
        MOV AL,8
        INT10H
        POP BX
        JMP INPUT2
INPUT5: CMP AL,32
        JB INPUT2
        CMP AL,96
        JB INPUT6
        SUB AL,32
INPUT6: CMP BYTE PTR [BX],0
        JZ INPUT2
        MOV [BX],AL
        INC BX
        MOV AH,14
        PUSH BX
        MOV BX,14
        INT10H
        POP BX
        JMP INPUT2

;Display memory dump

SHOWMEM:
        MOV BL,MEMTYPE
        CMP BL,0
        JZ EXPLICIT1
        MOV BH,0
        ADD BX,BX
        MOV AX,REGPC[BX-2]
        MOV MEMADR,AX
EXPLICIT1:
        MOV AX,MEMADR
        MOV DX,21FH
        CMP BYTE PTR MEMTYPE,0
        JZ SHOWMEM2
        MOV AH,2
        MOV BX,7
        INT10H
        MOV AH,14
        MOV AL,'['
        INT10H
        MOV AL,MSG4A
        CMP AL,'A'
        JNZ SHOWMEM0
        MOV AL,'D'
SHOWMEM0:
        INT10H
        MOV AL,MSG4A
        CMP AL,'P'
        MOV CX,'C]'
        JZ SHOWMEM1
        MOV CX,'P]'
        CMP AL,'D'
        JZ SHOWMEM1
        MOV CX,'] '
SHOWMEM1:        
        MOV AL,CH
        INT10H
        MOV AL,CL
        INT10H
        JMP SHOWMEM3
SHOWMEM2:
        CALL BIT16
SHOWMEM3:
        MOV DX,312H
        MOV DI,MEMADR
SHOWMEM4:        
        MOV AX,DI
        CALL BIT16
        MOV AH,14
        MOV AL,':'
        MOV BX,7
        INT10H
        PUSH DI
        MOV DL,24
SHOWMEM5:
        GETWORD
        ADD DI,2
        CALL BIT16
        ADD DL,5
        CMP DL,64
        JB SHOWMEM5
        MOV AX,0E20H
        MOV BX,7
        INT10H
        POP DI
        MOV CX,16
SHOWMEM6:
        GETBYTE
        INC DI
        AND AL,127
        CMP AL,33
        JNB SHOWMEM7
        MOV AL,'.'
SHOWMEM7:
        MOV AH,14
        INT10H
        LOOP SHOWMEM6
        INC DH
        MOV DL,18
        CMP DH,11
        JB SHOWMEM4
        RET

;Display U and SP stack contents

SHOWSP:
        MOV DI,REGU
        MOV DX,1207H
SHOWSP1:
        GETWORD
        ADD DI,2
        CALL BIT16
        INC DH
        CMP DH,17H
        JB SHOWSP1
        MOV DI,REGSP
        MOV DX,120CH
SHOWSP2:
        GETWORD
        ADD DI,2
        CALL BIT16
        INC DH
        CMP DH,17H
        JB SHOWSP2
        RET

;Start of program, initialisation

COCO3ROM DB 0                   ;Non-zero to indicate CoCo 3 ROM loaded

RESTARTING DB 1

PLEASE_WAIT:
        MOV MENU_BACK,4
        MOV DI,OFFSET MSG51
        MOV DX,0B1EH
        MOV BX,8313H
        CALL MENU
        MOV MENU_BACK,1
        RET

START:  MOV AX,ES:[2CH]         ;Save environment segment
        MOV CS:ENVIRONMENT,AX
        MOV AH,3
        MOV BH,0
        INT 10H
        MOV CS:ORIGINAL_CURSOR,CX
        MOV CS:BASE_SEGMENT,ES

        MOV BX,SEG RAMHERE      ;Allocate program memory

        IF ENABLE_NATIVE_VIDEO
        ADD BX,3201H+2600H      ;plus 64K ROM + 128K RAM + 8K null write
                                ;+ 152K for extended video functions
        MOV CS:FREE_MEMORY,BX   ;Save address of first free segment
        MOV CS:NO_EMS_MEMORY,BX
        SUB BX,2601H            ;Record extended RAM base
        MOV CS:NATIVE_VIDEO,BX
        ADD BX,150*(1024/16)    ;Palette matrix
        MOV CS:NATIVE_PALETTE,BX
        ADD BX,768/16           ;Native keyboard
        MOV CS:NATIVE_KEYBOARD,BX

        ELSE

        ADD BX,3201H
        MOV CS:FREE_MEMORY,BX   ;Save address of first free segment
        MOV CS:NO_EMS_MEMORY,BX

        ENDIF

        PUSH DS
        MOV AX,CS
        MOV DS,AX
        MOV AX,3D00H
        MOV DX,OFFSET TWOMEGS
        INT 21H
        POP DS
        JB NOT_2MEGS
        MOV BX,AX
        MOV AH,3EH
        INT 21H
        MOV CS:MEM_LIMIT,120    ;Be more ambitious in allocating EMS!
        MOV CS:MEM_MESSAGE,OFFSET MSG50B
        MOV CS:MEM_COLOUR,4     ;2Mb help screen is *red*
        MOV CS:EMS_MASK,0FFH
NOT_2MEGS:
        PUSH DS
        MOV AX,CS
        MOV DS,AX
        MOV AX,3D00H
        MOV DX,OFFSET SIXTEENMEGS
        INT 21H
        POP DS
        JB NOT_16MEGS
        MOV BX,AX
        MOV AH,3EH
        INT 21H
        MOV CS:MEM_LIMIT,1016   ;Be more ambitious in allocating EMS!
        MOV CS:MEM_MESSAGE,OFFSET MSG50C
        MOV CS:MEM_COLOUR,5     ;16Mb help screen is magenta
        MOV CS:EMS_MASK,7FFH
NOT_16MEGS:
        CALL EMS_TEST           ;Set up 384K of EMS if possible
        MOV BX,CS:FREE_MEMORY   ;Get new free seg addr in case EMS added
        MOV AX,ES
        SUB BX,AX
        MOV CS:MEMORY_SIZE,BX
        MOV AH,4AH
        INT 21H
        JNB ENOUGH_MEMORY
        MOV AX,SEG MSG44A
        MOV DS,AX
        MOV DI,OFFSET MSG44A
        SUB BX,CS:MEMORY_SIZE   ;Calculate how short we were
        NEG BX
        MOV CL,6
        SHR BX,CL
        INC BX
        MOV AX,BX
        MOV BL,10
        DIV BL
        OR [DI+2],AH
        MOV AH,0
        DIV BL
        OR [DI],AX
        MOV AH,9
        MOV DX,OFFSET MSG44
        INT 21H
        MOV AX,CS
        MOV DS,AX
        CALL FREE_EMS
        MOV AX,4C00H
        INT 21H
ENOUGH_MEMORY:
        MOV SP,0E000H
        MOV SI,129              ;Get snapshot name if applicable
        MOV DI,OFFSET SNAP_NAME
        MOV BL,0                ;Reset extension found flag
PRELOAD:
        MOV AL,[SI]
        INC SI
        CMP AL,32               ;Skip leading spaces
        JZ PRELOAD
        CMP AL,13               ;If CR, no name given
        JZ RESTART
        DEC SI                  ;Something found in command line
PRELOAD1:
        MOV AL,[SI]
        CMP AL,13               ;If carriage return found, done
        JZ PRELOAD4
        CMP AL,' '              ;Same with space
        JZ PRELOAD4
        CMP AL,'\'              ;If backslash, reset "extension flag"
        JNZ PRELOAD2
        MOV BL,0
PRELOAD2:
        CMP AL,'.'              ;Period found, set "extension flag"
        JNZ PRELOAD3
        INC BL
PRELOAD3:
        MOV CS:[DI],AL
        INC SI
        INC DI
        CMP DI,OFFSET SNAP_NAME+28      ;Leave enough room for extension
        JB PRELOAD1
PRELOAD4:                       ;Extensinon needed?
        OR BL,BL
        JNZ PRELOAD5
        MOV word ptr CS:[DI],502EH       ;".PAK"
        MOV word ptr CS:[DI+2],4B41H
        ADD DI,4
PRELOAD5:                       ;Terminating 0
        MOV CS:BYTE PTR [DI],0
        MOV BYTE PTR CS:PRELOAD_FLAG,-1
RESTART:
        MOV SP,0E000H
        PUSH CS                 ;Set registers properly
        POP DS
        MOV RESTARTING,1

        IF ENABLE_NATIVE_VIDEO

        PUSH ES                 ;Clear video
        PUSH BX
        MOV ES,NATIVE_VIDEO
        MOV DI,0
        MOV AL,0
        STOSB
        MOV CX,-1
        REP STOSB
        MOV BX,ES
        ADD BX,1000H
        MOV ES,BX
        STOSB
        MOV CX,-1
        REP STOSB
        MOV BX,ES
        ADD BX,1000H
        MOV ES,BX
        MOV CX,5800H
        REP STOSB
        POP BX
        POP ES
        PUSH DS                 ;Make default palette equal to CoCo's
        PUSH ES                 ;colour set
        PUSH BX
        MOV AX,CS
        MOV DS,AX
        MOV ES,NATIVE_PALETTE
        MOV SI,OFFSET PALETTE_XLAT
        MOV DI,0
        MOV CX,2
MAKE_PALETTE:
        MOV AH,0
        LODSB
        MOV BX,AX
        ADD BX,AX
        ADD BX,AX
        MOV AX,SS:[BX+DAC_TABLE]
        STOSW
        MOV AL,SS:[BX+DAC_TABLE+2]
        STOSB
        CMP SI,OFFSET PALETTE_XLAT+128
        JNZ MAKE_PALETTE
        MOV SI,OFFSET PALETTE_XLAT
        LOOP MAKE_PALETTE
        POP BX
        POP ES
        POP DS

        ENDIF
                                ;Reset GIME 2Mb extensions
        AND BYTE PTR VIDEO_BLOCK,7
        MOV BYTE PTR NATIVE[2],0
        MOV WORD PTR MMU2,0
        MOV WORD PTR MMU2[2],0
        MOV WORD PTR MMU2[4],0
        MOV WORD PTR MMU2[6],0
        MOV WORD PTR MMU2[8],0
        MOV WORD PTR MMU2[10],0
        MOV WORD PTR MMU2[12],0
        MOV WORD PTR MMU2[14],0
        MOV CART_FLAG,0         ;Shut down cartridge-present interrupt
        MOV AX,SEG RAMHERE      ;Load RAM/ROM etc.
        MOV SS:ROMBANK,AX       ;Set PC segment for internal/external ROM
        SUB AH,8                ;Initialise 8000-FFFF to internal ROM
        MOV SS:BANK4R,AX
        MOV SS:BANK5R,AX
        MOV SS:BANK6R,AX
        MOV SS:BANK7R,AX
        ADD AH,18H
        MOV SS:RAMBANK,AX       ;Set PC segment for 64K RAM
        ADD AH,10H              ;Initialise RAM to top 64K
        MOV TOPRAM,AX
        MOV SS:BANK0R,AX
        MOV SS:BANK0W,AX
        MOV SS:BANK1R,AX
        MOV SS:BANK1W,AX
        MOV SS:BANK2R,AX
        MOV SS:BANK2W,AX
        MOV SS:BANK3R,AX
        MOV SS:BANK3W,AX
        ADD AH,8                ;Set ROM segment to null write
        MOV SS:BANK4W,AX
        SUB AH,2
        MOV SS:BANK5W,AX
        SUB AH,2
        MOV SS:BANK6W,AX
        SUB AH,2
        MOV SS:BANK7W,AX
        MOV AX,SS:RAMBANK
        ADD AH,10H
        MOV ES,AX               ;Clear RAM
        MOV CX,8000H
        MOV AX,-1
        MOV DI,0
        REP STOSW
        MOV ES,SS:ROMBANK       ;Clear ROM segment
        MOV CX,8000H
;        MOV AX,7E7EH
        REP STOSW
        MOV AH,1AH
        MOV DX,OFFSET DTA
        INT 21H
START1: MOV AH,11H
        MOV DX,OFFSET ROMSEARCH
        INT 21H
        INC AL
        JNZ START2
        PUSH DS
        MOV AX,SEG SINGLE
        MOV DS,AX
        MOV AH,9
        MOV DX,OFFSET MSG14
        INT 21H
        POP DS
        CALL FREE_EMS
        MOV AX,4C00H
        INT 21H
START2: MOV SI,OFFSET DTA+1
        MOV DI,OFFSET ROMNAME        
START2A: 
        MOV AL,[SI]
        CMP AL,' '
        JZ START3
        MOV [DI],AL
        INC SI
        INC DI
        CMP SI,OFFSET DTA+9
        JB START2A
START3: MOV WORD PTR [DI],522EH ;".ROM",0
        MOV WORD PTR [DI+2],4D4FH
        MOV BYTE PTR [DI+4],0
        MOV DX,OFFSET ROMNAME
        MOV AX,3D00H
        INT 21H
        MOV BX,AX
        JNB START4
ERROR:  MOV AH,3EH
        INT 21H
        MOV BYTE PTR [DI+4],'$'
        MOV DX,OFFSET MSG15
        MOV AH,9
        INT 21H
        CALL FREE_EMS
        MOV AX,4C00H
        INT 21H
START4: MOV AH,3FH
        MOV DX,OFFSET REGPC
        MOV CX,2
        INT 21H
        JB ERROR
        CMP AX,2
        JNZ ERROR
        MOV DX,REGPC
        MOV AX,SS:ROMBANK
        CMP WORD PTR ROMNAME,4F43H
        JNZ START4A             ;If name is "COCO3.ROM", load in internal ROM
        CMP WORD PTR ROMNAME[2],4F43H
        JNZ START4A
        CMP WORD PTR ROMNAME[4],2E33H
        JNZ START4A
        SUB AH,8
        MOV COCO3ROM,-1
START4A:
        MOV DS,AX
        MOV CX,1
        MOV AH,3FH
        INT 21H
        ADD DX,AX
        MOV CX,-1
        MOV AH,3FH
        INT 21H
        PUSH CS
        POP DS
        JB ERROR
        MOV AH,3EH
        INT 21H
        MOV AH,12H
        MOV DX,OFFSET ROMSEARCH
        INT 21H
        INC AL
        JZ START4B
        JMP START2
START4B:
        CMP COCO3ROM,0
        JNZ START4C
        PUSH DS
        MOV AX,SEG SINGLE
        MOV DS,AX
        MOV AH,9                ;If COCO3.ROM wasn't loaded specifically,
        MOV DX,OFFSET MSG14A    ;display error
        INT 21H
        POP DS
        CALL FREE_EMS
        MOV AX,4C00H
        INT 21H
START4C:
        MOV DI,0FFFEH
        GETWORD
        MOV BP,AX
        MOV AX,0                ;Test for presence of mouse
        INT 33H
        MOV MOUSE_HERE,AL
        PUSH ES
        MOV AX,3509H            ;Load old interrupt vectors
        INT 21H
        MOV KEY_LOW,BX
        MOV KEY_HI,ES
        MOV AX,3508H
        INT 21H
        MOV CLK_LOW,BX
        MOV CLK_HI,ES
        MOV AX,3523H
        INT 21H
        MOV BREAK_LO,BX
        MOV BREAK_HI,ES
        MOV AX,2509H
        MOV DX,OFFSET KEY_INTERCEPT
        INT 21H
        MOV AX,2523H
        MOV DX,OFFSET BREAK_INTERCEPT
        INT 21H
        PUSH CS
        POP ES
        MOV DX,OFFSET MOUSE_INTERCEPT
        MOV CX,47
        MOV AX,14H
        INT 33H
        MOV MOUSE_LO,DX
        MOV MOUSE_HI,ES
        MOV MOUSE_MK,CX
        POP ES
        MOV SI,OFFSET CUR_PATH  ;Save power-up path
        CALL SAVE_PATH
        MOV SI,OFFSET VIR_DIR   ;Also set it as default for virtual dir.
        CALL SAVE_PATH
        MOV SI,OFFSET CAS_DIR   ;the virtual cassette directory...
        CALL SAVE_PATH
        MOV SI,OFFSET SNAP_PATH ;and snapshots
        CALL SAVE_PATH
        MOV AX,3D00H            ;Read last virtual disk settings, if any
        MOV DX,OFFSET DISK_CONFIG
        INT 21H
        MOV BX,AX
        JB NO_DISK_CONFIG
        MOV AH,3FH
        MOV DX,OFFSET CFG1TOP
        MOV CX,OFFSET CFG1END-OFFSET CFG1TOP
        INT 21H
        MOV AH,3EH
        INT 21H
NO_DISK_CONFIG:
        MOV AX,3D00H            ;and general configurations file, if any
        MOV DX,OFFSET GENERAL_CONFIG
        INT 21H
        MOV BX,AX
        JB NO_GENERAL_CONFIG
        MOV AH,3FH
        MOV DX,OFFSET CFG2TOP
        MOV CX,OFFSET CFG2END-OFFSET CFG2TOP
        INT 21H
        PUSH DS
        MOV AX,SS
        MOV DS,AX
        MOV AH,3FH
        MOV DX,CUSTOM_LIST
        MOV CX,196
        INT 21H
        POP DS
        MOV AH,3EH
        INT 21H
NO_GENERAL_CONFIG:
        MOV SI,BP
        SAVEREG                 ;Enter standard 6809 interpreter loop
        MOV DX,OFFSET DTA+256
        CALL INITIALIZE
        MOV AL,60H
        MOV DI,400H
        MOV CX,512
        MOV ES,SS:BANK0W
        REP STOSB
        CALL CLOCK_SET          ;Load proper clock interrupt
        CALL SBINIT
        CALL JOYTEST
        CALL OPEN_CASSETTE      ;Open virtual cassette if any specified
        CALL GRAPHICS_MODE
        MOV DI,0FFDEH           ;Select ROM mode
        PUTBYTE
        MOV DI,0FF90H           ;Select 32K internal ROM, interrupts disabled
        MOV AL,8AH
        PUTBYTE
        INC DI
        PUTBYTE
        CSROFF
HELP:   CALL MENU_SCREEN        ;Display power-up screen
        MOV AL,HELP_COLOUR
        MOV MENU_BACK,AL
        MOV MENU_FRONT,15
        MOV DI,OFFSET MSG28
        MOV DX,0312H
        MOV BX,932BH
        CALL MENU
        MOV MENU_FRONT,10
        MOV MENU_BACK,1         ;Restore normal blue/cyan
        MOV AX,4                ;Position mouse, turn it on
        MOV CX,316
        MOV DX,96
        INT 33H
        MOV AX,1
        INT 33H
WAIT0:  MOV AH,1                ;Wait for keyboard or mouse button
        INT 16H
        JNZ WAIT1A
        CMP MOUSE_HERE,0
        JZ WAIT0
        MOV AX,3
        INT 33H
        TEST BL,7
        JZ WAIT0
WAIT1:  MOV AX,3                ;Make sure mouse button released
        INT 33H
        TEST BL,7
        JNZ WAIT1
        JMP WAIT2
WAIT1A: KEYSTROKE
        CMP AX,3B00H            ;If debugger requested, enter it directly
        JNZ WAIT2
        JMP DEBUG0
WAIT2:  MOV AX,2                ;Turn off mouse pointer
        INT 33H

        IF CLEAR_RAM
        CMP RESTARTING,1
        JNZ NO_RAM_CLEAR
        CALL PLEASE_WAIT
        MOV AL,0CAH             ;Enable MMU for clear routine
        MOV DI,0FF90H
        PUTBYTE
        MOV AL,8AH              ;Select TR=0
        INC DI
        PUTBYTE
        MOV DI,0FFDFH
        PUTBYTE
        MOV DX,0
        PUSH ES
WIPE_BANKS:
        MOV AL,DL
        MOV DI,0FFA0H
        PUTBYTE
        MOV AL,DH
        MOV DI,0FF70H
        PUTBYTE
        MOV ES,SS:[0]
        MOV DI,0
        MOV CX,2000H
        REP STOSB
        INC DX
        TEST DX,MEM_MASK
        JNZ WIPE_BANKS
        MOV AL,0
        MOV DI,0FF70H
        PUTBYTE
        MOV AL,38H
        MOV DI,0FFA0H
        PUTBYTE
        POP ES
        MOV DI,0FFDEH           ;Select ROM mode
        PUTBYTE
        MOV DI,0FF90H           ;Select 32K internal ROM, interrupts disabled
        MOV AL,8AH
        PUTBYTE
        INC DI
        PUTBYTE
NO_RAM_CLEAR:
        MOV RESTARTING,0

        ENDIF

        IF ENABLE_SNAPSHOTS
        CMP BYTE PTR PRELOAD_FLAG,0
        JNZ PRELOAD6
        JMP CONTINUE
PRELOAD6:
        JMP LSNAP1
        ELSE
        JMP CONTINUE
        ENDIF

PRELOAD_FLAG DB 0               ;Non-zero if snapshot name specified at prompt
MOUSE_HERE DB 0                 ;Non-zero => mouse present

;Debugger entrance, wait for command keystroke

DEBUG:  SAVEREG                 ;Save 6809 registers
DEBUG0: MOV BRKPT,-1            ;Reset break point interrupt
        MOV RETURN_ADDRESS,-1
        MOV AX,500H
        INT10H
        MOV AX,3
        INT10H
        CSROFF
        PUSH ES
        MOV AX,0B800H
        MOV ES,AX
        PUSH DS
        PUSH SS
        POP DS
        MOV SI,FRAME
        MOV DI,0
        MOV CX,4000
        CLD
        REP MOVSB
        POP DS
        POP ES
        CALL SHOWREG
        CALL SHOWSP
        CALL SOURCE
        CALL SHOWMEM
        CALL XLTFLAG
        CALL SHOWFL
DEBUG_PROMPT:
        MOV SI,DBGMSG
        CALL DISPLAYCS
        MOV DBGMSG,OFFSET MSG2
DEBUG1: KEYSTROKE
        AND AL,223
        MOV SI,OFFSET COMMANDS
DEBUG2: CMP BYTE PTR [SI],0        
        JZ DEBUG1
        ADD SI,3
        CMP AL,[SI-3]
        JNZ DEBUG2
        JMP word ptr [SI-2]

;Change flag registers

FLAGS:  MOV SI,OFFSET MSG1
        CALL DISPLAYCS
        CALL XLTFLAG
        MOV AL,REGFI
        PUSH AX
FLAGS1: CALL SHOWFL
        KEYSTROKE
        CMP AL,13
        JZ FLAGS2
        CMP AL,27
        JZ FLAGS3
        AND AL,223
        FIND FL_LIST,8
        JNZ FLAGS1
        MOV AL,1
        ROL AL,CL
        XOR REGFI,AL
        JMP FLAGS1
FLAGS2: CALL UPDFLAG
        POP AX
        MOV AL,REGFI
        PUSH AX
FLAGS3: POP AX
        MOV REGFI,AL
        CALL SHOWFL
        JMP DEBUG_PROMPT

;Quit emulator

RESTART_FLAG DB 0

QUIT:   MOV SI,OFFSET MSG3
        CALL DISPLAYCS
        KEYSTROKE
        AND AL,223
        CMP AL,'Y'
        JZ QUIT1
        JMP DEBUG_PROMPT
QUIT1:  MOV AH,3EH
        MOV BX,HDHANDLE
        INT 21H
        MOV HDHANDLE,-1
        MOV AX,3
        INT10H
QUIT1A: MOV AH,1
        MOV BH,0
        MOV CX,CS:ORIGINAL_CURSOR
        INT 10H
        MOV DX,MOUSE_LO         ;Restore mouse interrupt
        MOV ES,MOUSE_HI
        MOV CX,MOUSE_MK
        MOV AX,12
        INT 33H
        MOV AX,2509H            ;Restore keyboard interrupt
        MOV DX,KEY_LOW
        MOV DS,KEY_HI
        INT 21H
        MOV AX,2508H            ;Restore clock interrupt
        MOV DX,CS:CLK_LOW
        MOV DS,CS:CLK_HI
        INT 21H
        CLI
        MOV AL,36H              ;Slow down runaway clock
        OUT 43H,AL
        MOV AL,-1
        OUT 40H,AL
        OUT 40H,AL
        STI
        MOV AX,2523H            ;Restore CTRL-BREAK branch address
        MOV DX,CS:BREAK_LO
        MOV DS,CS:BREAK_HI
        INT 21H
        MOV AX,CS
        MOV DS,AX
        CALL SAVE_CONFIG        ;Update configurations files.
        MOV AH,3CH              ;Save virtual disk configuratons
        MOV DX,OFFSET DISK_CONFIG
        MOV CX,0
        INT 21H
        MOV BX,AX
        JB QUIT2
        MOV AH,40H
        MOV CX,OFFSET CFG1END-OFFSET CFG1TOP
        MOV DX,OFFSET CFG1TOP
        INT 21H
        MOV AH,3EH
        INT 21H
QUIT2:  CMP RESTART_FLAG,-1     ;If restarting, go back to beginning
        JZ QUIT3
        CALL FREE_EMS
        MOV AX,4C00H            ;Exit to DOS.  All's well.
        INT 21H
QUIT3:  MOV RESTART_FLAG,0
        JMP RESTART

;Memory dump

locate:
        mov si,offset msg4b
        call address
        jnc start_locate
        jmp debug_prompt
start_locate:
        cmp memadr,-1
        jnz start_off_boundary
        inc memadr
start_off_boundary:
        mov cx,ax
        mov di,memadr
locate_loop:
        cmp di,-1
        jnz locate_off_boundary
        inc di
        cmp di,memadr
        jz not_located
locate_off_boundary:
        call mem_r16
        cmp ax,cx
        jz located
        inc di
        cmp di,memadr
        jz not_located
        jmp locate_loop
not_located:
        mov ax,offset msg4d
        mov dbgmsg,ax
located:
        mov memadr,di
        call showmem
        jmp debug_prompt

MEMORY: MOV SI,OFFSET MSG4
        CALL ADDRESS
        JNC MEMORY1
        JMP DEBUG_PROMPT
MEMORY1:
        MOV MEMTYPE,CL
        MOV MEMADR,AX
        JZ MEMORY2
        MOV MEMTYPE,0
MEMORY2:        
        CALL SHOWMEM
        JMP DEBUG_PROMPT

;Disassemble

DISASM: MOV SI,OFFSET MSG8
        CALL ADDRESS
        JNC DISASM1
        JMP DEBUG_PROMPT
DISASM1:
        MOV DISTYPE,CL
        MOV DISADR,AX
        JZ DISASM2
        MOV DISTYPE,8
DISASM2:
        MOV AL,MSG8A
        MOV LASTDIS,AL
        CALL SOURCE
        JMP DEBUG_PROMPT

;Change registers

POINTER MACRO LEFT,RIGHT        
        MOV AH,2
        MOV BX,14
        INT10H
        MOV AX,LEFT
        MOV CX,1
        INT10H
        PUSH DX
        ADD DL,5
        MOV AH,2
        INT10H
        MOV AX,RIGHT
        INT10H
        POP DX
        ENDM

SETREG: MOV SI,OFFSET MSG5
        CALL DISPLAYCS
        MOV DX,403H
SETREG1:
        POINTER 910H,911H
        KEYSTROKE
        PUSH AX
        POINTER 920H,920H
        POP AX
        CMP AL,27
        JNZ SETREG2
        JMP DEBUG_PROMPT
SETREG2:
        CMP AL,13
        JZ SETREG6
        CMP AX,4800H
        JZ SETREG3
        CMP AL,8
        JNZ SETREG4
SETREG3:
        DEC DH
        CMP DH,4
        JNB SETREG1
        MOV DH,10
        JMP SETREG1
SETREG4:
        CMP AX,5000H
        JZ SETREG5
        CMP AL,32
        JNZ SETREG5A
SETREG5:
        INC DH
        CMP DH,11
        JB SETREG1
        MOV DH,4
SETREG1A:        
        JMP SETREG1
SETREG5A:
        AND AL,223
        FIND PTR_LIST,11
        JNZ SETREG1A
        MOV DH,CL
SETREG6:
        POINTER 910H,911H
        MOV SI,OFFSET MSG6
        PUSH DX
        CALL ADDRESS
        POP DX
        PUSHF
        PUSH AX
        PUSH CX
        POINTER 920H,920H
        POP CX
        POP AX
        POPF
        JNC SETREG8
        JMP DEBUG_PROMPT
SETREG8:
        JNZ SETREG7
        MOV BX,CX
        ADD BX,BX
        MOV AX,REGPC[BX-2]
SETREG7:
        SUB DH,4
        JNZ SETREG10
        MOV REGD,AX
SETREG9:
        CALL SHOWREG
        CALL SHOWSP
        CALL SHOWMEM
        CALL SOURCE
        JMP DEBUG_PROMPT
SETREG10:
        DEC DH
        JNZ SETREG11
        MOV REGX,AX
        JMP SETREG9
SETREG11:
        DEC DH
        JNZ SETREG12
        MOV REGY,AX
        JMP SETREG9
SETREG12:
        DEC DH
        JNZ SETREG13
        MOV REGU,AX
        JMP SETREG9
SETREG13:
        DEC DH
        JNZ SETREG14
        MOV REGSP,AX
        JMP SETREG9
SETREG14:
        DEC DH
        JNZ SETREG15
        MOV REGPC,AX
        JMP SETREG9
SETREG15:
        MOV REGDP,AL
        JMP SETREG9

;Edit current memory page

EDIT:   MOV SI,OFFSET MSG7
        CALL DISPLAYCS
        CSRON
        MOV DL,0
EDIT1:  PUSH DX
        MOV DH,DL
        AND DL,31
        MOV AL,DL
        SHR DL,1
        SHR DL,1
        ADD DL,AL
        ADD DL,24
        MOV CL,5
        SHR DH,CL
        ADD DH,3
        MOV AH,2
        INT10H
        POP DX
        KEYSTROKE
        CMP AL,13
        JNZ EDIT3
EDIT2:  CSROFF
        CALL SHOWSP
        CALL SOURCE
        JMP DEBUG_PROMPT      
EDIT3:  CMP AL,27
        JZ EDIT2
        CMP AL,32
        JZ EDIT4
        CMP AX,4D00H
        JNZ EDIT5
EDIT4:  INC DL
        JNZ EDIT1
        ADD MEMADR,128
EDIT4A: MOV MEMTYPE,0
        PUSH DX
        CALL SHOWMEM
        POP DX
EDIT1A: JMP EDIT1
EDIT5:  CMP AL,8
        JZ EDIT6
        CMP AX,4B00H
        JNZ EDIT7
EDIT6:  SUB DL,1
        JNB EDIT1A
        SUB MEMADR,128
        JMP EDIT4A
EDIT7:  CMP AL,9
        JNZ EDIT8
        ADD DL,4
        JNB EDIT1A
        ADD MEMADR,128
        JMP EDIT4A
EDIT8:  CMP AX,5000H
        JNZ EDIT9
        ADD DL,32
        JNB EDIT1A
        ADD MEMADR,128
        JMP EDIT4A
EDIT9:  CMP AX,4800H
        JNZ EDIT9A
        SUB DL,32
        JNB EDIT1A
        SUB MEMADR,128
        JMP EDIT4A
EDIT9A: CMP AX,5100H
        JNZ EDIT9B
        ADD MEMADR,128
        JMP EDIT4A
EDIT9B: CMP AX,4900H
        JNZ EDIT10
        SUB MEMADR,128
        JMP EDIT4A
EDIT10: CMP AL,96
        JB EDIT12
        SUB AL,32
EDIT12: FIND HEX_LIST,16
        JNZ EDIT1A
        PUSH AX
        MOV CH,CL
        MOV CL,4
        MOV AH,240
        PUSH DX
        SHR DL,1
        JB EDIT11
        SHL CH,CL
        ROL AH,CL
EDIT11: MOV DH,0
        ADD DX,MEMADR
        MOV DI,DX
        GETBYTE
        AND AL,AH
        OR AL,CH
        PUTBYTE
        CALL SHOWMEM
        POP DX
        JMP EDIT4

;Single step through instructions

STEPOVER:
        MOV AX,OFFSET MSG2
        MOV DBGMSG,AX
        LOADREG
        MOV BYTE PTR INST,0C3H
        CALL AUX
        SAVEREG
        MOV AX,RETURN_ADDRESS
        MOV WORD PTR RETURN_ADDRESS,-1
        CMP AX,-1
        JNZ STEPOVER1
        CALL SHOWMEM
        CALL SOURCE
        CALL SHOWREG
        CALL SHOWSP
        CALL XLTFLAG
        CALL SHOWFL
        JMP DEBUG_PROMPT
STEPOVER1:
        JMP BREAK2

STEP:   MOV AX,OFFSET MSG2
        MOV DBGMSG,AX
        LOADREG
        MOV BYTE PTR INST,0C3H
        CALL AUX
        SAVEREG
        CALL SHOWMEM
        CALL SOURCE
        CALL SHOWREG
        CALL SHOWSP
        CALL XLTFLAG
        CALL SHOWFL
        JMP DEBUG_PROMPT

;Hexidecimal calculator

        IF ENABLE_MATH

MATH:   MOV AX,WORD PTR MSG9B
        MOV WORD PTR MSG9A,AX
        MOV AX,WORD PTR MSG9B[2]
        MOV WORD PTR MSG9A[2],AX
        MOV SI,OFFSET MSG9
        MOV CX,4
        CALL ADDRESS
        JNC MATH1
        JMP DEBUG_PROMPT
MATH1:  JNZ MATH2
        MOV BX,CX
        ADD BX,BX
        MOV AX,REGPC[BX-2]
MATH2:  MOV CALCDATA,AX
MATH3:  MOV SI,OFFSET MSG10
        CALL DISPLAY
        MOV AX,CALCDATA
        MOV DX,1800H
        CALL BIT16
        PUSH ES
        MOV AX,0B800H
        MOV ES,AX
        MOV AL,ES:[0F00H]
        MOV MSG9B,AL
        MOV AL,ES:[0F02H]
        MOV MSG9B[1],AL
        MOV AL,ES:[0F04H]
        MOV MSG9B[2],AL
        MOV AL,ES:[0F06H]
        MOV MSG9B[3],AL
        POP ES
MATH4:  KEYSTROKE
        CMP AL,96
        JB MATH5
        SUB AL,32
MATH5:  FIND CALC_CMD,13
        JNZ MATH4
        SUB CL,2                ;ENTER or ESC
        JNB MATH6
        JMP DEBUG_PROMPT
MATH6:  SUB CL,2                ;'S' or 'R'
        JNB MATH12
        INC CL                  ;CL=-1 -> 'R', CL=0 -> 'S'
        MOV SI,OFFSET MSG11
        JZ MATH7
        MOV SI,OFFSET MSG12
MATH7:  PUSH CX
        PUSH SI
        CALL DISPLAY
        MOV AX,CALCDATA
        MOV DX,1800H
        CALL BIT16
        KEYSTROKE
        POP SI
        POP CX
        CMP AL,27
        JZ MATH3
        CMP AL,13
        JZ MATH3
        CMP AL,8
        JZ MATH10
        CMP AX,4D00H
        JZ MATH10
        CMP AL,32
        JZ MATH8
        CMP AX,4B00H
        JNZ MATH7
MATH8:  OR CL,CL
        JZ MATH9
        ROL CALCDATA,1
        JMP MATH7
MATH9:  SHL CALCDATA,1
        JMP MATH7
MATH10: OR CL,CL
        JZ MATH11
        ROR CALCDATA,1
        JMP MATH7
MATH11: SHR CALCDATA,1
        JMP MATH7
MATH12: JNZ MATH13
        NEG CALCDATA
        JMP MATH3
MATH13: CMP AL,'D'
        JZ MATH13B
        PUSH CX
        MOV MSG9B[5],AL
        MOV WORD PTR MSG9A,2020H
        MOV WORD PTR MSG9A[2],2020H
        MOV SI,OFFSET MSG9B
        CALL ADDRESS
        MOV BX,CX
        POP CX
        JNC MATH13A
        JMP MATH3
MATH13A:
        JNZ MATH13B
        ADD BX,BX
        MOV AX,REGPC[BX-2]
MATH13B:
        DEC CL
        JNZ MATH14
        XOR CALCDATA,AX
        JMP MATH3
MATH14: DEC CL
        JNZ MATH15
        OR CALCDATA,AX
        JMP MATH3
MATH15: DEC CL
        JNZ MATH16
        AND CALCDATA,AX
        JMP MATH3
MATH16: DEC CL
        JNZ MATH17
        AND AX,AX
        JZ MATH16A
        XCHG AX,CALCDATA
        MOV DX,0
        DIV CALCDATA
        MOV CALCDATA,AX
MATH16A:
        JMP MATH3
MATH17: DEC CL
        JNZ MATH18
        MUL CALCDATA
        MOV CALCDATA,AX
        JMP MATH3
MATH18: DEC CL
        JNZ MATH19
        SUB CALCDATA,AX
        JMP MATH3
MATH19: DEC CL
        JNZ MATH20
        ADD CALCDATA,AX
        JMP MATH3
MATH20: MOV AX,WORD PTR MSG9B
        MOV WORD PTR MSG13,AX
        MOV AX,WORD PTR MSG9B[2]
        MOV WORD PTR MSG13[2],AX
        MOV AX,CALCDATA
        MOV SI,OFFSET MSG13B-2
        MOV MSG13A[5],' '
;        TEST AH,128
;        MOV MSG13A,'+'
;        JZ MATH21
;        MOV MSG13A,'-'
;        NEG AX
MATH21: MOV DX,0
        DIV TEN
        ADD DL,30H
        MOV [SI],DL
        DEC SI
        CMP SI,OFFSET MSG13A-1
        JA MATH21
        MOV CX,6
        MOV SI,OFFSET MSG13
        CALL INPUT
        MOV SI,OFFSET MSG13A
        MOV AX,0
        MOV DH,AH
        MOV BH,AH
        JNB MATH22
        JMP MATH3
MATH22: MOV DL,[SI]
        CMP DL,'-'
        JNZ MATH24
        NOT BH
MATH24: SUB DL,'0'
        JB MATH23
        CMP DL,9
        JA MATH23
        PUSH DX
        MUL TEN
        POP DX
        MOV DH,0
        ADD AX,DX
MATH23: INC SI
        CMP SI,OFFSET MSG13B
        JB MATH22
        TEST BH,-1
        JZ MATH25
        NEG AX
MATH25: MOV CALCDATA,AX
        JMP MATH3

        ENDIF

TEN     DW 10

;Set break point and continue

BREAK:  MOV AX,OFFSET MSG2
        MOV DBGMSG,AX
        MOV SI,OFFSET MSG16
        CALL ADDRESS
        JZ BREAK1
        JNB BREAK2
BREAK1: JMP DEBUG_PROMPT
BREAK2: MOV BRKPT,AX
        MOV LASTKEY,0
        CALL FORCE_REVISE
        CALL RESETBRANCH
        LOADREG
        JMP MAIN

;Show-video mode

VIDEO:  MOV LASTKEY,0
        CALL FORCE_REVISE
        MOV LASTKEY,3BH
        KEYSTROKE
        LOADREG
        JMP DEBUG

;Rewrites current CoCo video RAM to character generator in order to redraw
;the screen

MMU2_SAVE DB 0
VIDEO_BANK_HI DB 0

SHOW:
        CMP CS:LASTKEY,3BH
        JNZ SHOW1
        RET
SHOW1:  PUSH DI
        PUSH BX

        IF ENABLE_NATIVE_VIDEO

        PUSH ES                 ;Clear native keyboard matrix
        PUSH CX
        MOV ES,CS:NATIVE_KEYBOARD
        MOV AL,0
        MOV DI,0
        MOV CX,256
        REP STOSB
        POP CX
        POP ES
        CMP WORD PTR NATIVE,JV
        JNZ NOT_NATIVE_SHOW
        TEST BYTE PTR NATIVE[2],VIDEO_MODE_BITMASK
        JZ NOT_NATIVE_SHOW
        MOV AL,NATIVE[2]
        TEST AL,VIDEO_MODE_BITMASK-1
        JNZ NOT_PAGED
        AND AL,PAGE_MASK
        MOV AX,1000H            ;Second bank?
        JNZ PAGE_SELECT
        MOV AX,0                ;First bank.
PAGE_SELECT:
        ADD AX,NATIVE_VIDEO
        PUSH DS
        PUSH ES
        PUSH SI
        PUSH CX
        PUSH DX
        PUSH AX
        CALL RESTORE_NATIVE_PALETTE
        POP DS
        MOV SI,0                ;Block move
        MOV DI,SI
        MOV AX,0A000H
        MOV ES,AX
        MOV CX,64000
        REP MOVSB
        POP DX
        POP CX
        POP SI
        POP ES
        POP DS
        JMP NATIVE_DONE
NOT_PAGED:
        CALL HIRES_SHOW
NATIVE_DONE:
        POP BX
        POP DI
        RET
NOT_NATIVE_SHOW:

        ENDIF

        MOV DI,0FFB0H
SHOW2:
        MOV AL,PALETTE[DI-0FFB0H]
        NOT BYTE PTR PALETTE[DI-0FFB0H]
        PUTBYTE                 ;Update colour palette
        INC DI
        CMP DI,0FFC0H
        JB SHOW2
        MOV DI,0FF9AH           ;Set border colour correctly
        MOV AL,OVERSCAN
        PUTBYTE
        MOV AL,MMU2
        MOV MMU2_SAVE,AL
        MOV AX,WORD PTR INIT0   ;Get original MMU settings
        MOV BL,MMU              ;Get original MMU bank 0
        MOV BH,ROM_STATUS       ;Get ROM enable state
        PUSH AX
        PUSH BX
        OR AL,64                ;Enable MMU for SHOW routine
        MOV DI,0FF90H
        PUTBYTE
        MOV AL,AH
        AND AL,254              ;Select TR=0
        INC DI
        PUTBYTE
        MOV DI,0FFDFH           ;Enable RAM
        PUTBYTE
        MOV AX,MEM_MASK         ;Make sure current 512K/2Mb mode is enforced
        SHR AX,1
        SHR AX,1
        SHR AX,1
        AND VIDEO_BLOCK,AL
        MOV AH,VIDEO_BLOCK      ;Get upper 6 bits of 512K address of RAM
        MOV BX,NEW_TOP
        MOV AL,BH
        PUSH CX
        MOV CL,5
        SHR AX,CL
        POP CX
        MOV VIDEO_BANK_HI,AH
        MOV AH,AL               ;This is MMU bank of video RAM
SHOW3:  MOV AL,AH               ;Select an 8K block of video memory
        MOV DI,0FFA0H
        PUTBYTE
        MOV AL,VIDEO_BANK_HI
        MOV DI,0FF70H
        PUTBYTE
        MOV ES,SS:[0]           ;Video RAM to be switched in to bank 0
        MOV DI,BX               ;Point to address within bank to start
        AND BH,1FH
SHOW4:  MOV AL,ES:[BX]          ;Get a byte from video RAM
        CALL CHARGEN
        INC BX
        INC DI
        CMP DI,NEW_BOTTOM       ;If bottom reached, end of display
        JZ SHOW5
        CMP BH,20H              ;Otherwise loop for remainder of bank
        JB SHOW4
        MOV BX,DI
        INC AH                  ;Then select next bank and repeat
        JNZ SHOW3
        INC VIDEO_BANK_HI
        JMP SHOW3
SHOW5:  MOV AL,MMU2_SAVE
        MOV DI,0FF70H
        PUTBYTE
        POP AX                  ;Reselect original MMU bank
        MOV DI,0FFA0H
        PUTBYTE
        MOV AL,AH               ;Reselect original ROM mode
        AND AL,1
        OR AX,0FFDEH
        MOV DI,AX
        PUTBYTE
        POP AX
        MOV DI,0FF90H           ;Reselect original MMU state
        PUTBYTE
        MOV AL,AH               ;and original Task Register
        INC DI
        PUTBYTE
        CALL FIX_VIDEO
        POP BX
        POP DI
        RET

;PALETTE_T0  DB 0,1,2,3,4,5,6,7,26,25,26,27,28,29,30,31,0
;PALETTE_T1  DB 0,1,0,3,4,5,6,7,26,25,6,27,28,29,30,31,0
;PALETTE_GC0 DB 26,1,2,30,1,5,7,4,24,25,26,27,25,29,30,28,0
;PALETTE_GC1 DB 31,1,0,27,4,5,7,0,24,25,6,27,29,29,30,6,0
;PALETTE_GR0 DB 0,1,2,3,4,5,6,7,24,25,26,27,28,29,30,26,0
;PALETTE_GR1 DB 0,1,2,3,4,5,6,7,24,25,26,27,28,29,30,15,0
;PALETTE_ART0 DB 0,1,2,25,4,5,6,7,24,25,26,27,28,29,30,31,0
;PALETTE_ART1 DB 0,1,2,28,4,5,6,7,24,25,26,27,25,29,30,31,0

;Checks for changes in video registers and revises screen if necessary

OLD_DRB2 DB 0
OLD_INIT0 DB 0
OLD_VMODE DB 0
OLD_VRES DB 0
OLD_TOP DW 0
OLD_BOTTOM DW 0
OLD_BLOCK DB 0

        IF ENABLE_NATIVE_VIDEO
OLD_NATIVE DB 0,0
        ENDIF

OLD_PAGE DB 0

REVISE:
        PUSH AX

        IF ENABLE_NATIVE_VIDEO

        MOV AL,NATIVE[2]                ;Get video mode
        AND AL,VIDEO_MODE_BITMASK
        MOV AH,0
        CMP WORD PTR NATIVE,JV          ;Get native enable state
        JNZ NATIVE_NOT_ENABLED
        MOV AH,1
NATIVE_NOT_ENABLED:
        XCHG AX,WORD PTR OLD_NATIVE
        XOR AX,WORD PTR OLD_NATIVE      ;Check for changes
        CMP AH,0                        ;Entering/exiting native mode?
        JZ NO_NATIVE_TOGGLE             ;Skip next bit if not
        OR AL,OLD_NATIVE                ;Did video mode change or were we not
        JZ NO_NATIVE_CHANGE             ;in emulation?  (Branch if no to both)
        CALL GRAPHICS_MODE              ;Yes to one or the other, so update
        CALL SHOW                       ;video
        POP AX   
        RET
NO_NATIVE_TOGGLE:                       ;Native mode stayed unchanged
        CMP OLD_NATIVE[1],0             ;Was it enabled?
        JZ NO_NATIVE_CHANGE             ;If not, skip next bit
        CMP AL,0                        ;Did video mode change?
        JZ NO_NATIVE_CHANGE0            ;If not, we're done
        CALL GRAPHICS_MODE              ;Otherwise update mode
        CALL SHOW
        POP AX
        RET
NO_NATIVE_CHANGE0:
        MOV AL,NATIVE[2]                ;If page changed, update video
        TEST AL,VIDEO_MODE_BITMASK-1
        JNZ NO_NATIVE_CHANGE            ;In a multi-page mode?
        TEST AL,1
        JZ NO_NATIVE_CHANGE
        AND AL,PAGE_MASK
        MOV AH,AL
        XCHG AL,OLD_PAGE
        CMP AH,AL
        JZ NO_NATIVE_CHANGE
        CALL SHOW
        POP AX
        RET
NO_NATIVE_CHANGE:

        ENDIF

        JMP MAIN_REVISE
FORCE_REVISE_0A:
        JMP FORCE_REVISE_0
MAIN_REVISE:
        MOV AH,INIT0
        MOV AL,OLD_INIT0        ;If CoCo bit changed new screen
        XOR AL,AH
        AND AL,128
        JNZ FORCE_REVISE_0A
        ROL AH,1
        SBB AH,AH               ;AH=-1 if in CoCo=1 mode, 0 if in CoCo=0
        MOV AL,VRES             ;If there's a change to VRES, new screen
        XOR AL,OLD_VRES
        AND AL,127
        JNZ FORCE_REVISE_0A
        MOV AL,DRB2             ;If changed from text to graphics mode
        XOR AL,OLD_DRB2         ;or back in CoCo=1, new screen
        AND AL,AH
        AND AL,128
        JNZ FORCE_REVISE_0A
        MOV AL,DRB2             ;If in CoCo=1 graphics and CSS changed or
        TEST AL,128             ;number of colours changed, new graphics mode
        JZ REVISE1
        XOR AL,OLD_DRB2
        AND AL,18H
        AND AL,AH
        JNZ FORCE_REVISE_0
REVISE1:
        NOT AH
        MOV AL,VMODE            ;If BP changed and CoCo=0, new graphics mode
        XOR AL,OLD_VMODE
        AND AL,AH
        AND AL,128
        JNZ FORCE_REVISE_0
        NOT AH
        MOV AL,DRB2             ;If graphics mode changed in CoCo=1, redraw
        AND AL,AH
        TEST AL,128
        JZ REVISE2
        XOR AL,OLD_DRB2
        AND AL,0E0H
        AND AL,AH
        JNZ REDRAW_ONLY
REVISE2:
        MOV AL,VIDEO_BLOCK      ;If video RAM start/end changed, redraw
        CMP AL,OLD_BLOCK
        JNZ REDRAW_ONLY
        MOV AX,NEW_TOP
        CMP AX,OLD_TOP
        JNZ REDRAW_ONLY
        MOV AX,NEW_BOTTOM
        CMP AX,OLD_BOTTOM
        JNZ REDRAW_ONLY
        MOV AL,DRB2             ;If in CoCo=1 text mode...
        NOT AL
        AND AL,INIT0
        AND AL,128
        JZ REVISE3
        MOV AL,DRB2             ;and CSS changed...
        XOR AL,OLD_DRB2
        TEST AL,8
        JNZ REDRAW_ONLY         ;redraw screen
REVISE3:
        POP AX
        RET
FORCE_REVISE:
        PUSH AX
FORCE_REVISE_0:
        CALL GRAPHICS_MODE
REDRAW_ONLY:
        CALL SHOW
        MOV AL,VRES
        MOV OLD_VRES,AL
        MOV AL,DRB2
        MOV OLD_DRB2,AL
        MOV AL,INIT0
        MOV OLD_INIT0,AL
        MOV AL,VMODE
        MOV OLD_VMODE,AL
        MOV AL,VIDEO_BLOCK
        MOV OLD_BLOCK,AL
        MOV AX,NEW_TOP
        MOV OLD_TOP,AX
        MOV AX,NEW_BOTTOM
        MOV OLD_BOTTOM,AX
        POP AX
        RET

;Continue with normal execution

CONTINUE:
        MOV LASTKEY,0
        MOV PRELOAD_FLAG,0
        CALL FORCE_REVISE
        CALL RESETBRANCH
        LOADREG
        JMP MAIN

;Main interpreter loop

SLOW:   MOV BX,CX
        MOV CX,DELAY
HOLD:   LOOP HOLD
        MOV CX,BX
MAIN:   CALL AUX
BRANCH  EQU $+1        
        JMP MAIN
BRANCH1:
        JMP KEYBOARD
BRANCH2:
        JMP TIMER
BRANCH3:
        JMP BREAK_TEST
;BRANCH4:
;        JMP INVALID_ABORT
BRANCH5:
        JMP CLOCK_IRQ
BRANCH6:
        JMP HSYNC_IRQ
BRANCH7:
        JMP TMR_IRQ

;CoCo 60Hz clock interrupt request handler

RETRY_CLOCK:
        MOV BYTE PTR BRANCH,OFFSET BRANCH5-OFFSET BRANCH1
        RET

CLOCK_IRQ:
        CALL RESETBRANCH
        TEST BYTE PTR REGFI,16          ;If I flag set, no IRQ interrupt
        JNZ CLOCK_IRQ_CHECK;TMR_IRQ_1
        TEST BYTE PTR CRB1,1            ;If disabled on PIA, ignore cycle
        JZ TMR_IRQ_0
        MOV MISSED_INTERRUPT,0
        CALL IRQ
        JMP MAIN

CLOCK_IRQ_CHECK:
        TEST BYTE PTR CRB1,1
        JZ TMR_IRQ_1
        MOV MISSED_INTERRUPT,-1
        JMP TMR_IRQ_1

;Additional breakpoint test in interpreter loop

BREAK_TEST:
        CMP SI,BRKPT
        JNZ BREAK_TEST_1
        MOV DBGMSG,OFFSET MSG18
        MOV LASTKEY,3BH
        JMP DEBUG
BREAK_TEST_1:
        MOV BX,CX
        MOV CX,DELAY
        AND CX,CX
        JNZ HOLD
        MOV CX,BX
        JMP MAIN

;CoCo 16kHz HSYNC interrupt request handler

HSYNC_IRQ:
        CALL RESETBRANCH
        TEST BYTE PTR REGFI,16          ;If I flag set, no IRQ interrupt
        JNZ TMR_IRQ_1
        TEST BYTE PTR CRA1,1            ;If disabled on PIA, ignore cycle
        JZ TMR_IRQ_0
        CALL IRQ
        JMP MAIN

;CoCo programmable interval timer interrupt request handler

TMR_IRQ:
        CALL RESETBRANCH
        TEST BYTE PTR REGFI,16          ;If I flag set, no IRQ interrupt
        JNZ TMR_IRQ_1
TMR_IRQ_0:
        TEST BYTE PTR INIT0,32          ;If chip IRQ enabled
        JZ TMR_IRQ_1
        TEST BYTE PTR IRQSET,63         ;and a IRQ has occurred
        JZ TMR_IRQ_1                    ;generate an IRQ
        CALL IRQ
        JMP MAIN
TMR_IRQ_1:
        TEST BYTE PTR REGFI,64          ;If F flag set, no FIRQ interrupt
        JNZ MAIN_A
        TEST BYTE PTR INIT0,16          ;If chip FIRQ enabled
        JZ MAIN_A
        TEST BYTE PTR FIRQSET,63        ;and an FIRQ has occurred
        JZ MAIN_A
        CALL FIRQ                       ;generate an IRQ
MAIN_A: JMP MAIN

;The following code is executed once per PC clock pulse

GAXPOS  DB 0
GAYPOS  DB 0
GBXPOS  DB 0
GBYPOS  DB 0
STICKCYCLE DB 0
BLINKCYCLE DB 0

TIMER:  INC STICKCYCLE
        AND STICKCYCLE,3
        CALL REVISE
        CMP BYTE PTR LJOYSTK,2
        JZ LREAD
        CMP BYTE PTR RJOYSTK,2
        JZ LREAD
        OR STICKCYCLE,2
        JMP NO_LREAD
LREAD:  PUSH CX
        PUSH DX
        CMP STICKCYCLE,0
        JNZ LREAD3
        MOV AH,1
        CALL JOYREAD
        SUB CX,LCALIB
        JNB LREAD1
        MOV CX,0
LREAD1: MOV AX,CX
        MOV DX,0
        DIV LCALIB[4]
        MOV GAXPOS,AL
LREAD3: CMP STICKCYCLE,1        
        JNZ LREAD4
        MOV AH,2
        CALL JOYREAD
        SUB CX,LCALIB[2]
        JNB LREAD2
        MOV CX,0
LREAD2: MOV AX,CX
        MOV DX,0
        DIV LCALIB[6]
        MOV GAYPOS,AL
LREAD4: MOV DX,201H
        IN AL,DX
        MOV AH,AL
        AND AX,2010H
        ROR AL,1
        OR AL,AH
        ROR AL,1
        ROR AL,1
        CMP LJOYSTK,2
        JNZ NO_LFIRE1
        AND FIRE,0F5H
        OR FIRE,AL
NO_LFIRE1:
        ROR AL,1
        CMP RJOYSTK,2
        JNZ NO_RFIRE1
        AND FIRE,0FAH
        OR FIRE,AL
NO_RFIRE1:
        POP DX
        POP CX
NO_LREAD:
        CMP BYTE PTR LJOYSTK,4
        JZ RREAD
        CMP BYTE PTR RJOYSTK,4
        JZ RREAD
        CMP STICKCYCLE,0
        JZ NO_RREAD_A
        MOV STICKCYCLE,3
NO_RREAD_A:
        JMP NO_RREAD
RREAD:  PUSH CX
        PUSH DX
        CMP STICKCYCLE,2
        JNZ RREAD3
        MOV AH,4
        CALL JOYREAD
        SUB CX,RCALIB
        JNB RREAD1
        MOV CX,0
RREAD1: MOV AX,CX
        MOV DX,0
        DIV RCALIB[4]
        MOV GBXPOS,AL
RREAD3: CMP STICKCYCLE,3
        JNZ RREAD4
        MOV AH,8
        CALL JOYREAD
        SUB CX,RCALIB[2]
        JNB RREAD2
        MOV CX,0
RREAD2: MOV AX,CX
        MOV DX,0
        DIV RCALIB[6]
        MOV GBYPOS,AL
RREAD4: MOV DX,201H
        IN AL,DX
        MOV AH,AL
        AND AX,8040H
        ROL AH,1
        OR AL,AH
        ROL AL,1
        ROL AL,1
        ROR AL,1
        CMP LJOYSTK,4
        JNZ NO_LFIRE2
        AND FIRE,0F5H
        OR FIRE,AL
NO_LFIRE2:
        ROR AL,1
        CMP RJOYSTK,4
        JNZ NO_RFIRE2
        AND FIRE,0FAH
        OR FIRE,AL
NO_RFIRE2:
        POP DX
        POP CX
NO_RREAD:
        CMP COUNTDOWN,0        
        JZ TIMER3
        DEC COUNTDOWN
        JNZ TIMER3
        MOV BX,HANDLE
        MOV AH,3EH
        INT 21H
        MOV HANDLE,-1
TIMER3: CALL RESETBRANCH
        JMP MAIN

;Summon debugger if an invalid instruction was executed

;INVALID_ABORT:
;        MOV DBGMSG,OFFSET MSG19
;        JMP DEBUG

BAD:
;        MOV AL,OFFSET BRANCH4-OFFSET BRANCH1
;        MOV BYTE PTR BRANCH,AL
;        MOV BYTE PTR CS:INST,0C3H
        JMP INST

;Keyboard handler

EXTENDED_KEY DB 0               ;Non-zero if processing extended keyboard key

KEYBOARD:
        CMP LASTKEY,3BH         ;F1=Debug
        JNZ FUNCTION1
        MOV DBGMSG,OFFSET MSG17
        JMP DEBUG
FUNCTION1:                      ;F2=Virtual disk menu
        CMP LASTKEY,3CH
        JNZ FUNCTION2
        JMP VDISK
FUNCTION2:                      ;F3=Snapshots/Paks
        IF ENABLE_SNAPSHOTS
        CMP LASTKEY,3DH
        JNZ FUNCTION3
        JMP SNAP
        ENDIF
FUNCTION3:
        CMP LASTKEY,7EH
        JZ OPTION_BRANCH_A
        CMP LASTKEY,44H         ;F10 or CTRL-F10
        JNZ FLUSH_BRANCH
        PUSH ES
        MOV AX,64
        MOV ES,AX
        TEST BYTE PTR ES:[23],4
        POP ES
        JNZ FUNCTION4
        SAVEREG
        CALL SHIFT_KEYS
        KEYSTROKE
        JMP HELP
OPTION_BRANCH_A:
        JMP OPTIONS
FLUSH_BRANCH:
        JMP FLUSH
FUNCTION4:                      ;Disable GIME 2Mb extension
        AND BYTE PTR VIDEO_BLOCK,7
        MOV BYTE PTR NATIVE[2],0
        MOV WORD PTR MMU2,0
        MOV WORD PTR MMU2[2],0
        MOV WORD PTR MMU2[4],0
        MOV WORD PTR MMU2[6],0
        MOV WORD PTR MMU2[8],0
        MOV WORD PTR MMU2[10],0
        MOV WORD PTR MMU2[12],0
        MOV WORD PTR MMU2[14],0
        MOV DI,0FFFEH           ;Load reset vector into PC
        GETWORD
        MOV SI,AX
        MOV DI,0FFDEH           ;Request SAM to switch in ROMs
        PUTBYTE
        MOV DI,0FF90H           ;Disable MMU, etc., select CoCo=1 mode
        MOV AL,138
        PUTBYTE
        INC DI
        PUTBYTE
        OR BYTE PTR REGFI,80    ;Set interrupt masks so no interrupts occur
FLUSH:        
        MOV AH,1
        INT 16H
        JNZ KEY1A
        JMP KEY1
PORT_BRANCH:
        JMP PORT
OPTION_BRANCH:
        JMP OPTIONS
KEY1A:
        KEYSTROKE
        CMP AX,3F00H            ;F5=Sound on/off
        JZ CHANGE_SOUND
        CMP AX,4100H            ;F7=Keyboard mode
        JZ CHANGE_MODE
        CMP AX,4300H            ;F9=Port utility
        JZ PORT_BRANCH
        CMP AX,4000H            ;F6=Option menu
        JZ OPTION_BRANCH
        CMP AX,4200H            ;F8=Customize keyboard
        JZ CUSTOMIZE
        CMP AX,3E00H            ;F4=Virtual cassette menu
        JNZ NO_CALIBRATE
        JMP VIRCAS
NO_CALIBRATE:
        JMP FLUSH
CHANGE_SOUND:
        XOR BYTE PTR SOUND,1
        TEST BYTE PTR SOUND,1
        JMP FLUSH
CHANGE_MODE:
        MOV AL,KEY_MODE
        INC AL
        AND AL,3
        MOV KEY_MODE,AL
        MOV AH,0
        JMP FLUSH
CUSTOMIZE:                      ;F7=Modify custom keyboard layout
        SAVEREG
        PUSH DS
        PUSH ES
        DB 9AH                  ;CALL FAR CUSTOMIZER_MENU
        DW 0
        DW SEG CUST_SEG
        PUSH CS
        POP ES
        MOV DI,OFFSET DRA1_MATRIX;Clear the CTRL key and any others that may
        MOV CX,256              ;have stuck
        MOV AL,-1
        REP STOSB
        MOV CX,8
        MOV DI,OFFSET KEY_MATRIX
        REP STOSB
        POP ES
        POP DS
        JMP CONTINUE
KEY1:   MOV EXTENDED_KEY,0
        MOV AL,LASTKEY
        CMP AL,0E0H             ;Set flag for extended keyboard code if
        JNZ KEY1C               ;applicable
        MOV EXTENDED_KEY,1
        CALL SHIFT_KEYS
        PUSH BX
        PUSH CX
        MOV BL,0
        MOV CX,0
KEY1D:  MOV AL,LASTKEY          ;Wait for the next key in case interrupt
        CMP AL,0                ;is slow
        LOOPZ KEY1D
        JNZ KEY1DA
        DEC BL
        JNZ KEY1D
KEY1DA:
        POP CX
        POP BX
KEY1C:

        IF ENABLE_NATIVE_VIDEO
        PUSH BX
        PUSH DS
        MOV BL,AL               ;Update native keyboard matrix
        AND BL,127
        MOV BH,EXTENDED_KEY
        ROR BH,1
        OR BL,BH
        MOV BH,0
        MOV DS,NATIVE_KEYBOARD
        MOV BYTE PTR [BX],0
        TEST AL,128
        JNZ NATIVE_RELEASE
        MOV BYTE PTR [BX],-1
NATIVE_RELEASE:
        POP DS
        POP BX
        ENDIF

        AND AL,127
        CMP AL,47H              ;Select numeric keypad settings if it's one
        JB KEY1B                ;of those keys
        CMP AL,4AH
        JZ KEY1B
        CMP AL,4EH
        JZ KEY1B
        CMP AL,53H
        JA KEY1E
        PUSH ES                 ;and NUM LOCK is on
        MOV BX,64
        MOV ES,BX
        TEST BYTE PTR ES:[17H],32
        POP ES
        JZ KEY1B
        TEST EXTENDED_KEY,-1    ;and it's not an extended key
        JNZ KEY1B
        ADD AL,13
        JMP KEY1B
KEY1E:  ADD AL,10
KEY1B:  MOV BX,ALT_LIST
        MOV AH,KEY_MODE
        DEC AH
        JZ KEY2
        MOV BX,CUSTOM_LIST
        DEC AH
        JZ KEY2
        MOV BX,OS9_LIST
        DEC AH
        JZ KEY2
        MOV BX,KEY_LIST
KEY2:   MOV AH,0
        DEC AL
        ADD BX,AX
        ADD BX,AX
        INC AL
        CMP AL,63H
        JB KEY3
        CALL SHIFT_KEYS
        CALL RESETBRANCH
        JMP MAIN
KEY8A:  JMP KEY8
KEY3:   SAVEREG
        MOV DI,BX
        PUSH ES                 ;Key translation found.
        MOV AX,64
        MOV ES,AX
        MOV AL,ES:[23]          ;Restore SHIFT keys to proper values
        MOV AH,AL               ;(LEFT and RIGHT are interchanged)
        mov bl,al
        SHR AH,1
        AND AX,101H
        OR AH,AL
        NOT AH
        ROR AH,1
        ROR AH,1
        AND BYTE PTR KEY_MATRIX[7],191
        OR KEY_MATRIX[7],AH
        mov cl,4                ;Bit 2 of PC flag reflects CTRL state, which
        not bl                  ;we want in bit 6
        and bl,cl               
        shl bl,cl
        and byte ptr KEY_MATRIX[4],0ffh-40h
        or KEY_MATRIX[4],bl
        TEST BYTE PTR LASTKEY,128;If key is released, go to release algorithm
        JNZ KEY6A
        MOV BX,0                ;Key pressed
        TEST BYTE PTR ES:[23],3 ;Select secondary definition if shift pressed
        JZ KEY4
        INC BX
KEY4:   MOV AL,SS:[DI+BX]       ;Get key binding definition
        cmp al,8                ;08H or 88H means undefined
        JZ KEY8A
        cmp al,88h
        jz key8a
        TEST AL,128             ;Highest bit indicates toggle SHIFT key
        JZ KEY6
        AND BYTE PTR KEY_MATRIX[7],191
        TEST BYTE PTR ES:[23],3
        JZ KEY6
        OR BYTE PTR KEY_MATRIX[7],64
KEY6:   MOV BL,AL
        mov ah,al
        AND BL,7                ;Lower three bits are address line
        MOV CL,4
        SHR AL,CL
        MOV CL,AL               ;Bits 4-6 are bit position
        AND CL,7
        IF ENABLE_DRAGON
        CMP BYTE PTR DRAGON,0   ;If Dragon keyboard selected, exchange alpha
        JZ KEY6C                ;and numeric
        PUSH BX
        MOV BL,CL
        MOV CL,DRAG_XLAT[BX]
        POP BX
        ENDIF
KEY6C:  MOV AL,0FEH
        ROL AL,CL
        AND KEY_MATRIX[BX],AL   ;If pressed, make bit high
        test ah,8
        jz key7                 ;Does this key also affect CTRL?
        and byte ptr key_matrix[4],0ffh-40h
        JMP KEY7
KEY6A:  MOV SI,0                ;Loop for primary and secondary definitions
KEY6B:  MOV BX,SI
        MOV AL,SS:[DI+BX]  
        MOV BL,AL
        AND BL,7
        MOV CL,4
        SHR AL,CL
        MOV CL,AL
        AND CL,7
        IF ENABLE_DRAGON
        CMP BYTE PTR DRAGON,0   ;If Dragon keyboard selected, exchange alpha
        JZ KEY6D                ;and numeric
        PUSH BX
        MOV BL,CL
        MOV CL,DRAG_XLAT[BX]
        POP BX
        ENDIF
KEY6D:  MOV AL,1
        ROL AL,CL
        OR KEY_MATRIX[BX],AL    ;Key released.  Make bit low.
        INC SI
        CMP SI,2
        JB KEY6B
KEY7:   MOV DI,0                ;Recalculate DRA1 matrix
KEY7B:  MOV BX,0
        MOV AX,0FF01H
KEY7C:  TEST DI,AX
        JNZ KEY7D
        AND AH,KEY_MATRIX[BX]
KEY7D:  INC BL
        ROL AL,1
        JNB KEY7C
        MOV DRA1_MATRIX[DI],AH
        INC DI
        CMP DI,256
        JB KEY7B
KEY8:   POP ES
        CALL SHIFT_KEYS
        CALL RESETBRANCH
        CALL EI1_CHECK          ;Revise $FF00 input and generate keyboard
        LOADREG                 ;interrupt if necessary
        JMP MAIN

;Check for pending keyboard interrupt on IRQ or FIRQ

EI1_CHECK:
        PUSH BX
        MOV BX,OFFSET DRA1_MATRIX
        MOV AL,DRB1     ;Set new keyboard input on PIA1's DRA based on DRB
        XLAT            ;output
        XCHG AL,DRA1
        NOT AL
        AND AL,127      ;If any of bit 0-6 previously, branch
        JNZ EI1_CHECK_2
        MOV AL,DRA1     ;If keys were released but now pressed, generate
        NOT AL          ;interrupt
        AND AL,127
        JZ EI1_CHECK_3
EI1_CHECK_1:            ;Generate interrupt
        MOV AL,IRQENR   ;Set IRQ bit if mask enabled
        AND AL,2
        OR IRQSET,AL
        MOV AL,FIRQENR  ;Set FIRQ bit if mask enabled
        AND AL,2
        OR FIRQSET,AL
        MOV BYTE PTR INST,0C3H  ;Load "RET" into instruction interpreter loop
        MOV BYTE PTR BRANCH,OFFSET BRANCH7-OFFSET BRANCH1
        POP BX
        RET
EI1_CHECK_2:
        MOV AL,DRA1     ;If keys were pressed but now released, also generate
        NOT AL          ;interrupt
        AND AL,127
        JZ EI1_CHECK_1
EI1_CHECK_3:
        POP BX
        RET

;Virtual disk menu controller

VDISK:  MOV AH,1
        INT 16H
        JZ VDISK1
        KEYSTROKE
        JMP VDISK
VDISK1: SAVEREG
        MOV AH,3EH
        MOV BX,HANDLE
        INT 21H
        MOV HANDLE,-1
        CALL MENU_SCREEN
        MOV SI,OFFSET VIR_DIR
        CALL RESTORE_DIR
        MOV DI,OFFSET MSG24
        MOV DX,0
        MOV BX,8E2BH
        CALL MENU
        MOV DI,OFFSET MSG25
        MOV DX,63
        MOV BX,1911H
        CALL MENU
        MOV DH,9
VDISK1A:                        ;Show write protect status
        ROR WR_PROT,1
        JNB VDISK1B
        PUSH BX
        MOV BX,18BH             ;Display inverse bar
        MOV DL,3
        MOV CX,1
        MOV AL,' '
        MOV DL,3
        CALL PC_CHAR
        INC DL
        MOV AL,DH
        ADD AL,39
        CALL PC_CHAR
        INC DL
        MOV AL,' '
        CALL PC_CHAR
        POP BX
VDISK1B:
        INC DH
        CMP DH,13
        JB VDISK1A
        MOV CL,4
        ROR WR_PROT,CL
REDISPLAY:
        MOV SI,OFFSET PATHS     ;Display current path names
        MOV DH,9
VDISK2: MOV DL,9
        MOV BX,0
VDISK3: MOV AL,[SI+BX]
        PUSH BX
        MOV BX,10BH
        MOV CX,1
        CALL PC_CHAR
        POP BX
        INC DL
        INC BX
        CMP BX,32
        JB VDISK3
VDISK4: INC DH
        ADD SI,32
        CMP DH,13        
        JB VDISK2
        MOV DX,OFFSET DSKSEARCH
        CALL DIR
VDISK5:        
        MOV AX,1                ;Enable mouse pointer
        INT 33H
VDISK5A: 
        MOV AH,1                ;Main keyboard/mouse read loop
        INT 16H
        JZ VDISK7B
        MOV AX,2
        INT 33H
        JMP VDISK7
VDISK7B:
        TEST BYTE PTR MOUSE_HERE,-1
        JZ VDISK5A
        MOV AX,3
        INT 33H
        TEST BL,1
        JZ VDISK5A
        CALL MOUSE_COORD
        MOV DH,DL
        MOV DL,CL
        PUSH DX
VDISK5B:        
        MOV AX,3
        INT 33H
        TEST BL,1
        JNZ VDISK5B
        MOV AX,2
        INT 33H
        POP DX
        CMP DL,63               ;Mouse scan (directory zone)
        JNA VDISK5C
        CALL DIR_WDW
        JMP VDISK5
VDISK5C:
        JZ VDISK5
        CMP DL,42               ;If outside windows, cancel
        JA VDISK6
        JZ VDISK5
        CMP DH,13
        JA VDISK6
        JZ VDISK5               ;Dead space part of window
        CMP DH,9
        JB VDISK5
        CMP DL,2
        JB VDISK5
        CMP DL,7                ;Write protect zone
        JNB VDISK8D
        JMP VDISK8
VDISK8D:
        CMP DL,9                ;Dead space
        JB VDISK5
        JMP VNAME               ;Drive name select
VDISK6: MOV LASTKEY,0
        MOV SI,OFFSET VIR_DIR   ;Save current path
        CALL SAVE_PATH
        MOV SI,OFFSET CUR_PATH  ;Restore power-up path
        CALL RESTORE_DIR
        CALL GRAPHICS_MODE
        CALL SHOW               ;Straighten up screens+branch, and re-enter
        LOADREG
        CALL RESETBRANCH
        JMP MAIN
VDISK7: KEYSTROKE               ;Keyboard read routine
        CMP AL,13               ;Change directory
        JNZ VDISK7A
        CALL CHANGE_DIR
        JMP VDISK5
VDISK7A:
        CMP AL,27               ;Escape
        JZ VDISK6               
        MOV DX,904H     
        CMP AL,')'              ;Write protect
        JZ VDISK8
        INC DH
        CMP AL,'!'
        JZ VDISK8
        INC DH
        CMP AL,'@'
        JZ VDISK8
        INC DH
        CMP AL,'#'
        JZ VDISK8        
        MOV DH,AL               ;Select drive
        SUB DH,'0'
        MOV DL,DH
        ADD DH,9
        CMP DL,4
        JB VNAME
        CALL DIR_CMD            ;Directory keys
        JMP VDISK5
VDISK8: MOV CL,DH
        SUB CL,9
        MOV AH,1
        SHL AH,CL
        XOR WR_PROT,AH
        MOV BX,10BH
        TEST WR_PROT,AH
        JZ VDISK9
        OR BL,128
VDISK9: MOV DL,3
        MOV AL,' '
        MOV CX,1
        CALL PC_CHAR
        INC DL
        MOV AL,DH
        ADD AL,39
        CALL PC_CHAR
        INC DL
        MOV AL,' '
        CALL PC_CHAR
        JMP VDISK5

;Specify new disk name

VNAME:  MOV DI,OFFSET FILE_BFR
        MOV CX,32
        PUSH DX
        CALL SET_NAME           ;Include current path, etc. in name
        POP DX
        MOV DL,9
        CALL GET_FILE
        JB VNAME1
        MOV BX,5344H            ;The extension, "DSK"
        MOV CH,4BH
        MOV DI,OFFSET PATHS
        MOV AL,DH
        SUB AL,9
        MUL BYTE PTR THIRTYTWO
        ADD DI,AX               ;DI=32 byte storage area
        SUB CURSOR,9
        CALL NEW_FILE
        MOV AL,[DI]             ;Ignore blank names
        AND AL,0DFH
        JZ VNAME1
        MOV AX,[DI+1]           ;or ones which are drive designations
        AND AH,0DFH
        CMP AX,3AH
        JZ VNAME1
        PUSH DI
        MOV SI,OFFSET VIR_DIR   ;Save current path and
        CALL SAVE_PATH
        MOV SI,OFFSET CUR_PATH
        CALL RESTORE_DIR        ;go to default dir. to get things right
        POP DI
        MOV DX,DI               ;Check to see if file exists
        MOV AX,3D00H
        INT 21H
        JB VNAME2
        MOV BX,AX
        MOV AH,3EH
        INT 21H
        MOV SI,OFFSET VIR_DIR   ;Restore current dir. path
        CALL RESTORE_DIR
VNAME1: JMP REDISPLAY        
VNAME2: PUSH DI                 ;File does not exist:  User must confirm
        MOV SI,DI
        MOV CX,32
        MOV DI,OFFSET MSG26A    ;Include diskname in message
        PUSH ES
        MOV AX,SEG SINGLE
        MOV ES,AX
        REP MOVSB
        POP ES
        MOV DX,716H
        MOV BX,8A23H
        MOV DI,OFFSET MSG26
        MOV MENU_BACK,4         ;Make this window red/yellow
        CALL MENU
        MOV MENU_BACK,1         ;Restore normal blue/cyan
        MOV AX,4                ;Set mouse cursor position
        MOV DX,112
        MOV CX,216
        INT 33H
VNAME3: MOV AX,1                ;Enable mousy pointy thingy
        INT 33H
VNAME3A:                        ;Wait for user response
        MOV AH,1
        INT 16H
        JNZ VNAME5
        CMP MOUSE_HERE,0
        JZ VNAME3A
        MOV AX,3
        INT 33H
        TEST BL,1
        JZ VNAME3A
        CALL MOUSE_COORD
        MOV DH,DL
        MOV DL,CL
VNAME4: PUSH DX                 ;Wait for button to be released
        MOV AX,3
        INT 33H
        POP DX
        TEST BL,1
        JNZ VNAME4
        MOV AX,2                ;Bye-bye mousy pointy thingy
        INT 33H
        CMP DH,15               ;Dead space of mouse
        JA VNAME3
        CMP DH,13
        JB VNAME3
        CMP DL,23
        JB VNAME3
        CMP DL,31               ;"Yes" zone
        JB VNAME6
        CMP DL,56
        JA VNAME3
        CMP DL,48               ;"No" zone
        JA VNAME8
        JMP VNAME3
VNAME5: MOV AX,2                ;Keyboard intercept.  Kill mouse pointer.
        INT 33H
        KEYSTROKE
        AND AL,223
        CMP AL,'Y'
        JZ VNAME6
        CMP AL,'N'
        JZ VNAME8
        JMP VNAME3
VNAME6: POP DX                  ;"Yes" handler.  Create file.
        PUSH DX
        MOV AH,3CH
        MOV CX,0
        INT 21H
        JB VNAME7
        MOV BX,AX               ;Create directory structure
        MOV DX,3300h
        MOV CX,1                ;Skip to "track 17, sector 2"
        MOV AX,4200H
        INT 21H
        MOV DI,OFFSET DTA
        PUSH ES
        MOV AX,DS
        MOV ES,AX
        MOV AL,-1
        MOV CX,256
        REP STOSB
;        MOV CX,188
;        INC AL
;        REP STOSB
        MOV AH,40H
        MOV CX,256
        MOV DX,OFFSET DTA
        INT 21H
        MOV DI,OFFSET DTA       ;Create directory entry sectors (sectors 3-18)
        MOV AL,-1
        MOV CX,256
        REP STOSB
        POP ES
        MOV CX,16
VNAME6A:
        PUSH CX
        MOV AH,40H
        MOV CX,256
        MOV DX,OFFSET DTA
        INT 21H
        POP CX
        JB VNAME7
        LOOP VNAME6A
        MOV AH,3EH
        INT 21H
        JNB VNAME9
VNAME7: MOV AH,3EH              ;Error abort.  Ensure file closed
        INT 21H
        MOV AH,2                ;Beep
        MOV DL,7
        INT 21H
VNAME8: POP DI                  ;"No" handler
        PUSH ES                 ;Clear diskname field
        MOV AX,DS
        MOV ES,AX
        MOV AL,32
        MOV CX,32
        REP STOSB
        POP ES
        PUSH DI
VNAME9: POP DI                  ;General return from warning window
        CALL SHOW               ;Reset windows
        LOADREG
        JMP VDISK

NEW_FILE:              ;Copy file name from buffer to DI
        MOV SI,OFFSET FILE_BFR
        PUSH ES
        MOV AX,DS
        MOV ES,AX
        PUSH CX
        MOV CX,32
        REP MOVSB
        POP CX
        POP ES
        SUB DI,32
        MOV CL,0
        MOV AL,FILE_BFR         ;Don't add extensions to null file names
        AND AL,0DFH
        JZ NEW_FILE0
        MOV AX,WORD PTR FILE_BFR[1]
        AND AH,0DFH             ;or ones which are drive designations
        CMP AX,3AH
        MOV AH,-1
        JNZ NEW_FILE1
NEW_FILE0:
        RET
NEW_FILE1:                      ;Check to see if extension already there
        CMP BYTE PTR [DI],'\'
        JNZ NEW_FILE2
        MOV AH,-1
NEW_FILE2:
        CMP BYTE PTR [DI],'.'
        JNZ NEW_FILE3
        MOV AH,CL
NEW_FILE3:
        INC DI
        INC CL
        CMP CL,31
        JB NEW_FILE1
        SUB DI,31
        INC AH
        JZ NEW_FILE4
        DEC AH
        MOV CURSOR,AH
NEW_FILE4:
        PUSH DI
        ADD DI,31
        MOV AL,CURSOR
        CMP AL,27
        JA NEW_FILE5
        POP DI
        PUSH DI
        MOV AH,0                ;Add extension if there is room
        ADD DI,AX
        MOV BYTE PTR [DI],'.'
        MOV [DI+1],BX
        MOV [DI+3],CH
        ADD DI,4
NEW_FILE5:                      ;Add terminator byte
        MOV BYTE PTR [DI],0
        POP DI
        RET

DIR_CMD:               ;Directory window keyboard handler
        CMP AX,4900H
        JNZ DIR_CMD1
        JMP DIR_UP
DIR_CMD1:
        CMP AX,5100H
        JNZ DIR_CMD2
        JMP DIR_DOWN
DIR_CMD2:
        CMP AX,5000H
        JNZ DIR_CMD4
        CMP DIR_PTR,-1
        JZ DIR_CMD2A
        CALL HILITE
        MOV AL,14
        MUL DIR_PTR
        MOV SI,AX
        MOV AX,294
        MUL DIR_PAGE
        ADD SI,AX
        CMP BYTE PTR SS:CUR_DIR[SI+14],' '
        JZ DIR_CMD3
        INC DIR_PTR
        MOV AL,DIR_PTR
        CMP AL,21
        JB DIR_CMD3
        CALL DIR_DOWN
DIR_CMD2A:        
        MOV DIR_PTR,0
DIR_CMD3:
        CALL HILITE
        RET
DIR_CMD4:
        CMP AX,4800H
        JNZ DIR_CMD5
        CMP DIR_PTR,-1
        JZ DIR_CMD2A
        CALL HILITE
        SUB DIR_PTR,1
        JNS DIR_CMD3
        INC DIR_PTR
        CMP DIR_PAGE,0
        JZ DIR_CMD3
        CALL DIR_UP
        MOV DIR_PTR,20
        CALL HILITE
        RET
DIR_CMD5:
        RET

DIR_WDW:               ;Directory window mouse handler
        CALL HILITE             ;Dehighlight last selected file
        MOV DIR_PTR,-1          ;Clear directory file pointer
        CMP DH,0                ;Dead space of directory window
        JZ DIR_WDW1
        CMP DH,2
        JZ DIR_WDW1
        CMP DH,24
        JZ DIR_WDW1
        CMP DH,1                ;File name zone
        JNZ DIR_WDW4
        CMP DL,79
        JZ DIR_WDW1
        CMP DL,66               ;Up arrow
        JNA DIR_WDW2
        CMP DL,76               ;Down arrow
        JNB DIR_WDW3
DIR_WDW1:
        RET
DIR_WDW2:
        CALL DIR_UP
        RET
DIR_WDW3:
        CALL DIR_DOWN
        RET
DIR_WDW4:
        SUB DH,3
        MOV DIR_PTR,DH
        CALL HILITE
        CALL CHANGE_DIR
        RET

DIR_PTR DB -1                   ;Line of file pointer within dir window

CHANGE_DIR:            ;Change to directory highlighted        
        MOV DH,DIR_PTR
        INC DH
        JNZ CHANGE_DIR0
        RET
CHANGE_DIR0:
        DEC DH
        MOV AL,14
        MUL DH
        MOV SI,AX
        MOV AX,294
        MUL DIR_PAGE
        ADD SI,AX
        ADD SI,CUR_DIR
        MOV DX,SI
        INC DX
        CMP BYTE PTR SS:[SI],'['
        JZ CHANGE_DIR1
        RET
CHANGE_DIR1:
        CMP BYTE PTR SS:[SI+2],':'
        JZ CHANGE_DIR2
        INC SI
        CMP BYTE PTR SS:[SI],']'
        JNZ CHANGE_DIR1
        MOV NEW_DIR,-1
        MOV DIR_PTR,-1
        PUSH DS
        MOV AX,SS
        MOV DS,AX
        MOV BYTE PTR [SI],0
        MOV AH,3BH
        INT 21H
        MOV BYTE PTR [SI],']'
        POP DS
        MOV DIR_PAGE,0
        MOV DX,LAST_DIR
        CALL DIR
        RET
CHANGE_DIR2:
        MOV NEW_DIR,-1
        MOV DIR_PTR,-1
        MOV DL,SS:[SI+1]
        SUB DL,'A'
        CMP DL,2
        JNB HARD_DRIVE
        PUSH ES
        MOV AX,DS
        MOV ES,AX
        MOV AX,201H             ;Verify that sector is readable by MS-DOS
        MOV DH,0                ;before allowing this disk to become the
        MOV CX,1                ;default directory
        MOV BX,OFFSET DTA
        INT 13H
        POP ES
        JB NOT_MSDOS
HARD_DRIVE:
        MOV AH,0EH
        INT 21H
NOT_MSDOS:
        MOV DIR_PAGE,0
        MOV DX,LAST_DIR
        CALL DIR
        RET

RESTORE_DIR:           ;Restore path to that at SI
        PUSH DX
        MOV AH,0EH
        MOV DL,[SI]
        INT 21H
        MOV DX,SI
        INC DX
        MOV AH,3BH
        INT 21H
        POP DX
        RET

SAVE_PATH:             ;Save path to SI
        PUSH DX
        MOV AH,19H              ;Save default drive
        INT 21H
        MOV [SI],AL
        MOV AH,0EH              ;Save total number of drives
        MOV DL,AL
        INT 21H
        MOV TOTAL_DRIVES,AL
        MOV BYTE PTR [SI+1],'\' ;Leading "\" for path
        ADD SI,2
        PUSH DI         
        INC DL
        MOV AH,47H              ;Retrieve path
        INT 21H
        POP DI
        SUB SI,2
        POP DX
        RET

NEW_DIR DB 0                    ;Non-zero if dir changed since last reset
LAST_DIR DW 0                   ;Offset to last directory search's mask

HILITE:                ;Toggle highlight from file DIR_PTR
        INC DIR_PTR
        JNZ HILITE1
        DEC DIR_PTR
        RET
HILITE1:
        MOV NEW_HILITE,-1
        DEC DIR_PTR
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        MOV DH,DIR_PTR
        ADD DH,3
        MOV AH,2
        MOV DL,64
        MOV BH,0
        INT10H
        MOV CX,15
        CALL PC_INVERT
        POP DX
        POP CX
        POP BX
        POP AX
        RET

NEW_HILITE DB 0                 ;Indicates hilight changed since last reset

DIR_UP:               ;Scroll directory page back one
        CMP DIR_PAGE,0
        JZ DIR_UP1
        DEC DIR_PAGE
        CALL SHOWDIR
DIR_UP1:
        RET

DIR_DOWN:              ;Scroll directory page down one
        MOV AX,294
        MUL DIR_PAGE
        ADD AX,CUR_DIR+294
        MOV SI,AX
        CMP BYTE PTR SS:[SI],0
        JZ DIR_DOWN1
        CMP BYTE PTR SS:[SI],32
        JZ DIR_DOWN1
        MOV AX,DIR_PAGE
        CMP AL,22
        JNB DIR_DOWN1
        INC DIR_PAGE
        CALL SHOWDIR
DIR_DOWN1:
        RET

;File name input routine.  Display FILE_BFR 31-byte field (plus terminator)
;at cursor location DX.  Returns upon ENTER/LEFT button second click (NC)
;or ESC/RIGHT button first click (C)

CURSOR  DB 0                    ;Current column position of cursor

GET_FILE:
        CMP DIR_PTR,-1
        JZ GETF1
        PUSH DX
        CALL SET_NAME           ;If file highlighted, take as default
        POP DX
GETF1:  PUSH DX
        MOV SI,OFFSET FILE_BFR
        MOV CURSOR,DL
GETF2:  MOV AL,[SI]             ;Display name
        MOV BX,10EH
        MOV CX,1
        CALL PC_CHAR
        INC SI
        INC DL
        MOV AL,[SI-1]
        CMP AL,' '
        JZ GETF3
        CMP AL,0
        JZ GETF3
        MOV CURSOR,DL
GETF3:  CMP SI,OFFSET FILE_BFR+31
        JB GETF2
        MOV DL,CURSOR           ;Display cursor
        MOV Al,0DBH
        MOV BX,10BH
        CALL PC_CHAR
        POP DX
GETF3A: MOV AX,1
        INT 33H
GETF4:  MOV AH,1
        INT 16H
        JZ GETF8A
        MOV AX,2
        INT 33H
        JMP GETF8
GETF8A: TEST BYTE PTR MOUSE_HERE,-1
        JZ GETF4
        PUSH DX
        MOV AX,3
        INT 33H
        CALL MOUSE_COORD
        MOV CH,DL
        POP DX
        TEST BL,3
        JZ GETF4
        TEST BL,2
        JZ GETF5
        MOV AX,2                ;Right button aborts.  Turn off mouse pointer
        INT 33H         
        MOV DL,CURSOR           ;and cursor
        MOV AL,' '
        MOV BX,10BH
        MOV CX,1
        CALL PC_CHAR
        STC                     ;and set abort flag
        RET
GETF5:  MOV AX,3                ;Wait for button to be released
        PUSH CX
        PUSH DX
        INT 33H
        POP DX
        POP CX
        TEST BL,1
        JNZ GETF5
        MOV AX,2
        INT 33H
        CMP CL,63
        JZ GETF3A
        JB GETF6
        PUSH DIR_PAGE
        PUSH WORD PTR DIR_PTR
        PUSH DX
        MOV NEW_DIR,0
        MOV NEW_HILITE,0
        MOV DX,CX
        CALL DIR_WDW            ;If mouse if directory window, handle it
        POP DX
        POP AX
        POP BX
        CMP NEW_HILITE,0
        JZ GETF5D
        CMP NEW_DIR,-1          ;If directory changed, set name appropriately
        JZ GETF5B
        CMP AL,DIR_PTR          ;If same highlight clicked a second time,
        JNZ GETF5B
        CMP AL,-1
        JZ GETF5B
        CMP BX,DIR_PAGE
        JNZ GETF5B
GETF5C: MOV DL,CURSOR           ;Turn off cursor
        MOV AL,' '
        MOV BX,10BH
        MOV CX,1
        CALL PC_CHAR
        CLC                     ;flag as "accept".
        RET
GETF5D: JMP GETF3A
GETF5B: PUSH DX
        CALL SET_NAME           ;If highlight changed, load new hilighted
        POP DX
        JMP GETF1               ;file into buffer.
GETF6:  CMP CH,DH               ;If clicked on other than current drive
        JZ GETF7                ;field, return ESCape flag
GETF6A: MOV DL,CURSOR
        MOV AL,' '
        MOV BX,10BH
        MOV CX,1
        CALL PC_CHAR
        STC
        RET
GETF7:  SUB CL,DL
        JB GETF6A
        CMP CL,32
        JA GETF6A
        JMP GETF5C              ;Otherwise return ENTER.
GETF8:  KEYSTROKE               ;Keyboard read routine
        CMP AL,13
        JNZ GETF9
        MOV NEW_DIR,0           ;ENTER: If directory highlighted, change it
        PUSH DX
        CALL CHANGE_DIR
        POP DX
        CMP NEW_DIR,0
        JNZ GETF8C
        JMP GETF5C              ;else return file name with NC
GETF8C: PUSH DX
        CALL SET_NAME
        POP DX
        JMP GETF1
GETF8B: JMP GETF3A
GETF9:  CMP AL,27               ;ESC: If buffer not empty, clear it
        JNZ GETF9A
        CMP FILE_BFR,32         ;else return with C set
        JZ GETF6A
        CMP FILE_BFR,0
        JZ GETF6A
        PUSH ES
        MOV AX,DS
        MOV ES,AX
        MOV DI,OFFSET FILE_BFR
        MOV AL,32
        MOV CX,32
        REP STOSB
        POP ES
        MOV CURSOR,DL
        JMP GETF1
GETF9A: CMP AL,8                ;Backspace
        JNZ GETF10
        CMP CURSOR,DL
        JNA GETF8B
        DEC CURSOR
        MOV AL,CURSOR
        MOV AH,0
        SUB AL,DL
        MOV SI,AX
        MOV FILE_BFR[SI],32
        PUSH DX
        MOV DL,CURSOR
        MOV AL,0DBH
        MOV BX,10BH
        MOV CX,1
        CALL PC_CHAR
        INC DL
        MOV AL,' '
        CALL PC_CHAR
        POP DX
        JMP GETF8B
GETF10: CMP AL,32               ;ASCII character input (spaces suppressed)
        JNA GETF11
        MOV AH,CURSOR
        SUB AH,DL
        CMP AH,31
        JNB GETF8B
        PUSH AX
        MOV AL,CURSOR
        MOV AH,0
        SUB AL,DL
        MOV SI,AX
        POP AX
        MOV FILE_BFR[SI],AL
        PUSH DX
        MOV DL,CURSOR
        MOV BX,10EH
        MOV CX,1
        MOV AL,FILE_BFR[SI]
        CALL PC_CHAR
        INC DL
        MOV AL,0DBH
        MOV BX,10BH
        CALL PC_CHAR
        POP DX
        INC CURSOR
        JMP GETF8B
GETF11: MOV NEW_HILITE,0        ;Check for directory commands
        PUSH DX
        CALL DIR_CMD
        POP DX
        CMP NEW_HILITE,0        ;If highlight changed, retrieve that file name
        JNZ GETF12
        JMP GETF8B
GETF12: PUSH DX
        CALL SET_NAME
        POP DX
        JMP GETF1

SET_NAME:              ;Set FILE_BFR to current hilighted path
        MOV DI,OFFSET FILE_BFR
        MOV CX,32
        PUSH ES
        MOV AX,DS
        MOV ES,AX
        MOV AL,32
        REP STOSB
        POP ES
        MOV SI,OFFSET FILE_BFR
        MOV AH,19H
        INT 21H
        PUSH DX
        MOV DL,AL
        INC DL
        CMP AL,CUR_PATH
        JZ SET_NAME1
        ADD AL,'A'
        MOV [SI],AL
        MOV BYTE PTR [SI+1],':'
        ADD SI,2
SET_NAME1:
        MOV AH,47H
        PUSH SI
        MOV SI,OFFSET DTA
        INT 21H
        POP SI
        POP DX
        MOV DI,0
SET_NAME2:
        MOV AL,DTA[DI]
        CMP AL,CUR_PATH[DI+2]
        JNZ SET_NAME3
        INC DI
        CMP AL,0
        JNZ SET_NAME2
        JMP SET_NAME5
SET_NAME3:        
        MOV BYTE PTR [SI],'\'
        INC SI
        MOV DI,OFFSET DTA
SET_NAME4:
        MOV AL,[DI]
        CMP AL,0
        JZ SET_NAME4A
        MOV [SI],AL
        INC DI
        INC SI
        CMP SI,OFFSET FILE_BFR+30
        JB SET_NAME4
        RET
SET_NAME4A:
        CMP BYTE PTR [SI-1],'\'
        JZ SET_NAME5
        MOV BYTE PTR [SI],'\'
        INC SI
SET_NAME5:
        CMP DIR_PTR,-1
        JNZ SET_NAME6
        RET
SET_NAME6:
        MOV AL,14
        MUL DIR_PTR
        MOV DI,AX
        MOV AX,294
        MUL DIR_PAGE
        ADD DI,AX
        CMP BYTE PTR SS:CUR_DIR[DI+2],':'
        JZ SET_NAME8
        CMP BYTE PTR SS:CUR_DIR[DI],'['
        MOV BX,0
        JZ SET_NAME9
SET_NAME7:
        MOV AL,SS:CUR_DIR[DI+BX]
        MOV [SI],AL
        INC SI
        INC BX
        CMP SI,OFFSET FILE_BFR+31
        JNB SET_NAME8
        CMP BX,14
        JB SET_NAME7
SET_NAME8:
        RET
SET_NAME9:
        MOV AL,SS:CUR_DIR[DI+BX+1]
        CMP AL,']'
        JZ SET_NAME10
        MOV [SI],AL
        INC SI
        INC BX
        CMP SI,OFFSET FILE_BFR+31
        JNB SET_NAME8
        CMP BX,13
        JB SET_NAME9
SET_NAME10:
        CMP SI,OFFSET FILE_BFR+31
        JZ SET_NAME8
        MOV BYTE PTR [SI],'\'
        RET

;Virtual cassette menu controller

CLOSE_CASSETTE:
        CMP CHANDLE,-1
        JZ CLOSE_CAS1
        MOV AH,3EH
        MOV BX,CHANDLE
        INT 21H
        MOV CHANDLE,-1
CLOSE_CAS1:
        MOV BYTE PTR CAS_BIT,0
        MOV BYTE PTR CAS_CYCLE,0
        RET

OPEN_CASSETTE:
        CMP CHANDLE,-1
        JNZ OPEN_CAS1
        MOV SI,OFFSET CUR_PATH
        CALL RESTORE_DIR
        MOV AX,3D02H
        MOV DX,OFFSET CAS_NAME
        INT 21H
        JB OPEN_CAS1
        MOV CHANDLE,AX
OPEN_CAS1:
        MOV AX,4201H            ;Save current position
        MOV BX,CHANDLE
        MOV CX,0
        MOV DX,0
        INT 21H
        PUSH DX
        PUSH AX
        MOV AX,4202H            ;FInd end of virtual cassette
        MOV DX,CX
        INT 21H
        MOV CAS_END,AX
        POP DX
        POP CX
        MOV AX,4200H            ;Restore current position
        INT 21H
        RET

CASSETTE_POS:          ;Display in .CAS file
        PUSH BX
        PUSH DX
        MOV AX,0
        CMP CHANDLE,-1
        JZ VCAS4
        MOV AX,4201H            ;Figure out current offset in file
        MOV BX,CHANDLE
        MOV CX,0
        MOV DX,CX
        INT 21H
        JNB VCAS4
        POP DX
        POP BX
        RET
VCAS4:  POP DX                  ;Position of first digit
        POP BX
        MOV CX,5
        MOV CAS_PTR,AX
VCAS5:  PUSH DX
        MOV DX,0                ;Convert to decimal
        MOV SI,10
        DIV SI
        MOV SI,DX
        POP DX
        PUSH AX
        PUSH CX
        MOV AX,SI
        ADD AL,30H
        MOV CX,1
        CALL PC_CHAR
        POP CX
        POP AX
        DEC DL
        LOOP VCAS5
        RET

CAS_STEP DW 1                   ;Number of bytes to inc/dec for FF/Rewind
CAS_PTR DW 0                    ;Last displayed counter reading
CAS_END DW 0                    ;Position of end of virtual cassette
CAS_BIT DB 0                    ;Bit within byte currently being processed
CAS_CYCLE DB 0                  ;Number of samples within bit

VIRCAS: MOV AH,1
        INT 16H
        JZ VCAS1
        KEYSTROKE
        JMP VIRCAS
VCAS1:  SAVEREG
        MOV AH,3EH
        MOV BX,HANDLE
        INT 21H
        MOV HANDLE,-1
        CALL MENU_SCREEN
        MOV SI,OFFSET CAS_DIR
        CALL RESTORE_DIR
        MOV DI,OFFSET MSG46
        MOV DX,0
        MOV BX,8C2BH
        CALL MENU
        MOV DI,OFFSET MSG25
        MOV DX,63
        MOV BX,1911H
        CALL MENU
VCAS1A: MOV CX,1
        MOV DX,708H
        MOV SI,OFFSET MSG47A
        MOV BX,10BH
        TEST BYTE PTR CASMODE,-1
        JZ VCAS2
        MOV SI,OFFSET MSG47B
        MOV BX,40EH
VCAS2:  LODSB                   ;Display cassette mode
        CALL PC_CHAR
        INC DL
        CMP DL,16
        JB VCAS2
        MOV DX,608H
        MOV SI,OFFSET CAS_NAME
VCAS3:  LODSB                   ;Display virtual cassette name
        MOV BX,10BH
        MOV CX,1
        CALL PC_CHAR
        INC DL
        CMP SI,OFFSET CAS_NAME+32
        JB VCAS3
        CALL OPEN_CASSETTE      ;Make sure virtual cassette open
        MOV DX,327H
        MOV BX,10BH
        CALL CASSETTE_POS
        MOV DX,OFFSET CASSEARCH
        CALL DIR
VCAS6:  MOV AX,1                ;Mouse pointer on
        INT 33H
VCAS7:  MOV AH,1
        INT 16H
        JZ VCAS8
        MOV AX,2                ;Key pressed, branch to key handler
        INT 33H
        JMP VCAS13
VCAS8:  CMP MOUSE_HERE,0
        JZ VCAS7
        MOV AX,3                ;If mouse present, test it
        INT 33H
        TEST BL,1
        JZ VCAS7
        CALL MOUSE_COORD
        MOV DH,DL
        MOV DL,CL
        MOV CAS_STEP,1
        CMP DH,9                ;If on Forward or Rewind, don't bother
        JNZ VCAS9               ;waiting for release
        CMP DL,12
        JB VCAS9
        CMP DL,31
        JB VCAS9A
VCAS9:  PUSH DX                 ;Wait for release of mouse button
        MOV AX,3
        INT 33H
        POP DX
        TEST BL,1
        JNZ VCAS9
        MOV AX,2
        INT 33H
VCAS9A: CMP DL,63
        JZ VCAS6
        JB VCAS10
        CALL DIR_WDW
        JMP VCAS6
VCAS10: CMP DL,43               ;Outside window ... cancel
        JNB VCAS12
        JZ VCAS6A
        CMP DH,12
        JNB VCAS12
        CMP DL,0
        JZ VCAS6A
        CMP DH,6                ;Name line
        MOV AL,'N'
        JZ VCAS11
        CMP DH,7
        MOV AL,'M'              ;Mode line
        JZ VCAS11
        CMP DH,9
        JNZ VCAS6A
        CMP DL,2
        JB VCAS6A
        MOV AL,'S'              ;"Start" button
        CMP DL,11
        JB VCAS11
        JZ VCAS6A
        MOV AL,'R'              ;"Rewind" button
        CMP DL,21
        JB VCAS11
        JZ VCAS6A
        MOV AL,'F'              ;"Forward" button
        CMP DL,31
        JB VCAS11
        JZ VCAS6A
        MOV AL,'E'              ;"End" button
        CMP DL,41
        JB VCAS11
VCAS6A: JMP VCAS6
VCAS11: JMP VCAS14
VCAS12: MOV LASTKEY,0
        MOV SI,OFFSET CAS_DIR   ;Save last selected virtual cassette dir.
        CALL SAVE_PATH
        MOV SI,OFFSET CUR_PATH  ;Restore power-up path
        CALL RESTORE_DIR
        CALL GRAPHICS_MODE
        CALL SHOW               ;Straighten up screens+branch, and re-enter
        LOADREG
        CALL RESETBRANCH
        JMP MAIN
VCAS13: KEYSTROKE               ;Key pressed, interpret it
        CMP AL,27               ;ESC=abort
        JZ VCAS12
        CMP AL,13               ;ENTER=change directory
        JNZ VCAS14
        CALL CHANGE_DIR
        JMP VCAS6
VCAS14: CALL DIR_CMD            ;Interpret keys for dir. window
        AND AL,223
        CMP AL,'M'              ;Change mode
        JNZ VCAS16
        NOT BYTE PTR CASMODE
        JMP VCAS1A
VCAS16: MOV BX,CHANDLE          ;Cassette buttons don't work if no .CAS open
        CMP BX,-1
        JZ VCAS22
        CMP AL,'S'
        JNZ VCAS19
        MOV AX,4200H            ;Rewind to start of virtual cassette
        MOV DX,0
VCAS17: MOV CX,0        
        INT 21H
        MOV BYTE PTR CAS_BIT,0
        MOV BYTE PTR CAS_CYCLE,0
        MOV DX,327H
        MOV BX,10BH
        CALL CASSETTE_POS
        CMP CAS_STEP,64
        JNB VCAS18
        SHL CAS_STEP,1
VCAS18: JMP VCAS6
VCAS19: CMP AL,'E'              ;Go to end of virtual cassette
        JNZ VCAS20
        MOV AX,4202H
        MOV DX,0
        JMP VCAS17
VCAS20: CMP AL,'R'              ;Rewind virtual cassette
        JNZ VCAS21
        MOV DX,CAS_PTR
        SUB DX,CAS_STEP
        MOV AX,4200H
        JNB VCAS17
        MOV DX,0
        JMP VCAS17
VCAS21: CMP AL,'F'              ;Fast forward
        JNZ VCAS22
        MOV DX,CAS_PTR
        ADD DX,CAS_STEP
        CMP DX,CAS_END
        MOV AX,4200H
        JB VCAS17
        MOV DX,CAS_END
        JMP VCAS17
VCAS22: CMP AL,'N'              ;Change virtual cassette name
        JZ VCNAME
        JMP VCAS6

VCNAME: MOV AX,4                ;Set mouse cursor position to name field
        MOV CX,80
        MOV DX,52
        INT 33H
        MOV SI,OFFSET CAS_NAME  ;Currrent name is default
        MOV DI,OFFSET FILE_BFR
        MOV CX,32
        PUSH ES
        MOV AX,DS
        MOV ES,AX
        REP MOVSB
        POP ES
        MOV DX,608H
        CALL GET_FILE           ;Get file name
        JNB VCNAME1
        JMP VCAS1A
VCNAME1: 
        MOV DI,OFFSET CAS_NAME  ;Set new name plus extension
        MOV BX,4143H            ;".CAS"
        MOV CH,53H
        SUB CURSOR,8
        CALL NEW_FILE
        CALL CLOSE_CASSETTE
        MOV AL,CAS_NAME
        AND AL,223
        JZ VCAS1B
        CALL OPEN_CASSETTE
        CMP CHANDLE,-1
        JZ VCNAME2
        MOV BYTE PTR CASMODE,0  ;If existing file, default to "playback"
VCAS1B: JMP VCAS1A
VCNAME2: 
        MOV SI,OFFSET CAS_NAME
        MOV CX,32
        MOV DI,OFFSET MSG48A    ;Include diskname in message
        PUSH ES
        MOV AX,SEG SINGLE
        MOV ES,AX
        REP MOVSB
        POP ES
        MOV DX,716H
        MOV BX,8A23H
        MOV DI,OFFSET MSG48
        MOV MENU_BACK,4         ;Make this window red/yellow
        CALL MENU
        MOV MENU_BACK,1         ;Restore normal blue/cyan
        MOV AX,4                ;Set mouse cursor position
        MOV DX,112
        MOV CX,216
        INT 33H
VCNAME3: 
        MOV AX,1                ;Enable mousy pointy thingy
        INT 33H
VCNAME3A:                       ;Wait for user response
        MOV AH,1
        INT 16H
        JNZ VCNAME5
        CMP MOUSE_HERE,0
        JZ VCNAME3A
        MOV AX,3
        INT 33H
        TEST BL,1
        JZ VCNAME3A
        CALL MOUSE_COORD
        MOV DH,DL
        MOV DL,CL
VCNAME4: 
        PUSH DX                 ;Wait for button to be released
        MOV AX,3
        INT 33H
        POP DX
        TEST BL,1
        JNZ VCNAME4
        MOV AX,2                ;Bye-bye mousy pointy thingy
        INT 33H
        CMP DH,15               ;Dead space of mouse
        JA VCNAME3
        CMP DH,13
        JB VCNAME3
        CMP DL,23
        JB VCNAME3
        CMP DL,31               ;"Yes" zone
        JB VCNAME6
        CMP DL,56
        JA VCNAME3
        CMP DL,48               ;"No" zone
        JA VCNAME8
        JMP VCNAME3
VCNAME5: 
        MOV AX,2                ;Keyboard intercept.  Kill mouse pointer.
        INT 33H
        KEYSTROKE
        AND AL,223
        CMP AL,'Y'
        JZ VCNAME6
        CMP AL,'N'
        JZ VCNAME8
        JMP VCNAME3
VCNAME6: 
        MOV DX,OFFSET CAS_NAME  ;"Yes" handler.  Create file.
        MOV AH,3CH
        MOV CX,0
        INT 21H
        JB VCNAME7
        MOV CHANDLE,AX
        MOV BYTE PTR CASMODE,-1 ;New file must mean "record"
        JMP VCNAME9
VCNAME7: 
        MOV AH,2                ;Error: Beep
        MOV DL,7
        INT 21H
VCNAME8:                        ;"No" handler
        PUSH ES                 ;Clear diskname field
        MOV DI,OFFSET CAS_NAME
        MOV AX,DS
        MOV ES,AX
        MOV AL,0
        MOV CX,32
        REP STOSB
        POP ES
VCNAME9: 
        CALL SHOW               ;Reset windows
        LOADREG
        JMP VIRCAS

        IF ENABLE_SNAPSHOTS

;Snapshot menu

SNAP:   MOV AH,1
        INT 16H
        JZ SNAP1
        KEYSTROKE
        JMP SNAP
SNAP1:  SAVEREG
        MOV AH,3EH              ;Close virtual disk
        MOV BX,HANDLE
        INT 21H
        MOV HANDLE,-1
        CALL CLOSE_CASSETTE
        MOV SI,OFFSET SNAP_PATH
        CALL RESTORE_DIR        ;Set snapshot path
        CALL MENU_SCREEN
        MOV DI,OFFSET MSG27
        MOV DX,0
        MOV BX,8729H
        CALL MENU
        MOV DI,OFFSET MSG25
        MOV DX,63
        MOV BX,1911H
        CALL MENU
SNAP2:  MOV SI,OFFSET SNAP_NAME
        MOV DX,508H
SNAP3:  LODSB                   ;Display snapshot name
        MOV BX,10BH
        MOV CX,1
        CALL PC_CHAR
        INC DL
        CMP SI,OFFSET SNAP_NAME+32
        JB SNAP3
        MOV DX,OFFSET PAKSEARCH
        CALL DIR
SNAP4:  MOV AX,1                ;Back by popular demand...
        INT 33H                 ;...the mouse pointer!
SNAP5:  MOV AH,1
        INT 16H
        JZ SNAP6
        MOV AX,2
        INT 33H
        JMP SNAP11
SNAP6:  CMP MOUSE_HERE,0
        JZ SNAP5
        MOV AX,3
        INT 33H
        TEST BL,1
        JZ SNAP5
        CALL MOUSE_COORD
        MOV DH,DL
        MOV DL,CL
SNAP7:  PUSH DX                 ;I should really have written a macro for
        MOV AX,3                ;this whole *tedious* mess, shouldn't I?
        INT 33H
        POP DX
        TEST BL,1
        JNZ SNAP7
        MOV AX,2
        INT 33H
        CMP DL,63
        JZ SNAP4
        JB SNAP8
        CALL DIR_WDW
        JMP SNAP4
SNAP8:  CMP DL,41               ;Outside window ... cancel
        JNB SNAP10
        CMP DH,7
        JNB SNAP10
        CMP DH,2                ;The "LOAD" and "SAVE" line
        JNZ SNAP4
        CMP DL,15
        JB SNAP4
        CMP DL,20
        JA SNAP9
        JMP LSNAP               ;Load zone
SNAP9:  CMP DL,23
        JB SNAP4
        CMP DL,28
        JA SNAP4
        JMP SSNAP
SNAP10: MOV LASTKEY,0           ;Exit for one reason or another
        MOV SI,OFFSET SNAP_PATH ;Save current path
        CALL SAVE_PATH
        MOV SI,OFFSET CUR_PATH  ;Restore old path
        CALL RESTORE_DIR
        CALL OPEN_CASSETTE
        MOV PRELOAD_FLAG,0
        CALL RESETBRANCH
        CALL FORCE_REVISE
        CALL JOYTEST
        LOADREG
        CALL CART_INT           ;Generate cartridge FIRQ if needed
        JMP MAIN
SNAP11: KEYSTROKE
        CMP AL,13
        JNZ SNAP13
        CALL CHANGE_DIR
        JMP SNAP4
SNAP13: CMP AL,27
        JZ SNAP10
        CMP AL,'L'
        JZ LSNAP
        CMP AL,'l'
        JZ LSNAP
        CMP AL,'S'
        JZ SNAP12
        CMP AL,'s'
        JZ SNAP12
        CALL DIR_CMD
        JMP SNAP4
SNAP12: JMP SSNAP

        ENDIF

CART_INT:              ;Generate a cartridge interrupt if CART_FLAG
        PUSH AX                 ;detected
        TEST CART_FLAG,128
        JZ CART_INT_2
        TEST BYTE PTR REGFI,16  ;If F flag set, interrupt suppressed
        JNZ CART_INT_1
        TEST CRB2,1             ;If FIRQ CART enabled on PIA2 CRB generate
        JZ CART_INT_1           ;it
        OR BYTE PTR REGFI,80
        CALL FIRQ
        POP AX
        RET
CART_INT_1:
        MOV AL,IRQENR           ;Set chip IRQ pending if enabled
        AND AL,1
        OR IRQSET,AL
        MOV AL,FIRQENR          ;Set chip FIRQ pending if enabled
        AND AL,1
        OR FIRQSET,AL
CART_INT_2:
        POP AX
        RET

        IF ENABLE_SNAPSHOTS

LSNAP:  MOV DX,20FH             ;Highlight "Load" and get new snapshot name
        CALL GSNAP
        JNB LSNAP1
        JMP SNAP2               ;Abort branch
LSNAP1: CALL PLEASE_WAIT
        MOV AL,DRB1
        MOV OLD_DRB1,AL
        MOV AL,CRB1
        MOV OLD_CRB1,AL
        MOV AX,3D00H
        MOV DX,OFFSET SNAP_NAME
        INT 21H
        MOV BX,AX
        JB ESNAP1

        MOV DI,OFFSET MMU2      ;Reset system, just in case
        MOV AL,0
        MOV CX,16
        REP STOSB
        MOV WORD PTR NATIVE,0
        MOV NATIVE[2],0

        MOV AH,3FH
        MOV DX,OFFSET DTA
        MOV CX,4
        INT 21H
        MOV CX,WORD PTR DTA
        OR CX,CX
        JZ LXSNAP               ;If starts with 00 00, it's an extended snap
        MOV DX,WORD PTR DTA[2]  ;Otherwise, consider it a Program Pak
        PUSH DS
        MOV DS,SS:ROMBANK
        MOV AH,3FH
        INT 21H
        POP DS
        JB ESNAP1
        MOV AH,3EH
        INT 21H
        MOV CART_FLAG,128       ;Set cartridge interrupt pending flag
        MOV DI,0FFFEH
        GETWORD
        MOV REGPC,AX
        JMP SNAP10
ESNAP1: JMP ESNAP

TARGET_BANK DB 0,0

LXSNAP: MOV AL,INIT0
        OR AL,64                ;Enable MMU for LOADX routine
        MOV DI,0FF90H
        PUTBYTE
        MOV AL,INIT1
        AND AL,254              ;Select TR=0
        INC DI
        PUTBYTE
        MOV DI,0FFDFH           ;Enable RAM
        PUTBYTE
        MOV AL,DTA[3]
        MOV DTA[3],0
        MOV TARGET_BANK,AL
        MOV TARGET_BANK[1],0
        CMP AL,7                ;16 megabyte snapshot?
        JNZ LXSNAP1
        MOV TARGET_BANK[1],AL
        MOV TARGET_BANK,0FFH
LXSNAP1:                        ;Set bank 0 to 8K of output address
        MOV AL,DTA[2]
        MOV DI,0FFA0H
        PUTBYTE
        MOV AL,DTA[3]           ;Make sure we're in MMU2 block 0
        MOV DI,0FF70H
        PUTBYTE
        PUSH DS
        MOV DS,SS:[0]
        MOV AH,3FH              ;Load 8192 bytes
        MOV CX,8192
        MOV DX,0
        INT 21H
        POP DS
        JB ESNAPAA
        MOV AX,WORD PTR DTA[2]
        CMP AX,WORD PTR TARGET_BANK
        JNB LXSNAP2
        INC WORD PTR DTA[2]     ;Increment to next bank
        JMP LXSNAP1
ESNAPAA:
        JMP ESNAP
LXSNAP2:
        MOV AH,3FH              ;Load snapshot data
        MOV CX,OFFSET SNPEND-OFFSET SNPTOP
        MOV DX,OFFSET SNPTOP
        INT 21H
        MOV AH,3FH              ;Save MMU2 state
        MOV DX,OFFSET MMU2
        MOV CX,16
        INT 21H
        MOV AH,3FH              ;Save NATIVE mode state
        MOV DX,OFFSET NATIVE
        MOV CX,3
        INT 21H

        IF ENABLE_NATIVE_VIDEO

        PUSH DS                 ;Save native interface banks
        MOV DS,NATIVE_VIDEO
        MOV AH,3FH
        MOV CX,0F000H
        MOV DX,0
        INT 21H
        MOV AX,DS
        ADD AX,0F00H
        MOV DS,AX
        MOV AH,3FH
        MOV CX,0F000H
        MOV DX,0
        INT 21H
        MOV AX,DS
        ADD AX,0F00H
        MOV DS,AX
        MOV AH,3FH
        MOV CX,07C00H
        MOV DX,0
        INT 21H
        POP DS

        ENDIF

        MOV AH,3EH              ;Close file
        INT 21H
        MOV DI,0FF90H
        MOV AL,INIT0            ;Update the INIT0 register thoroughly
        NOT INIT0               ;(this will also automatically update the
        PUTBYTE                 ;RAM banks correctly)
        MOV DI,0FF22H
        MOV AL,DRB2             ;Update the DRB2 register thoroughly
        PUTBYTE
        MOV DI,0FF98H           ;Update VMODE as well
        MOV AL,VMODE
        NOT VMODE
        PUTBYTE
        MOV DI,0FF99H           ;Update VRES also
        MOV AL,VRES
        NOT VRES
        PUTBYTE
        MOV DI,0FFD8H           ;Update CPU speed
        MOV AL,CPU_SPEED
        AND AX,1
        OR DI,AX
        PUTBYTE
        MOV DI,0FFDEH           ;Update MMU registers, etc.
        MOV AL,ROM_STATUS
        AND AX,1
        OR DI,AX
        NOT ROM_STATUS
        PUTBYTE
        MOV AL,OLD_DRB1
        MOV DRB1,AL
        MOV AL,OLD_CRB1
        MOV CRB1,AL
        JMP SNAP10

ESNAP:  MOV AH,3EH              ;Error abort
        INT 21H
        MOV AH,2
        MOV DL,7
        INT 21H
        CMP PRELOAD_FLAG,0
        JNZ ESNAPA
        JMP SNAP2
ESNAPA: JMP CONTINUE

SSNAP:  MOV DX,217H             ;Highlight "Save" and get new snapshot name
        CALL GSNAP
        JNB SSNAP1
        JMP SNAP2               ;Abort branch
SSNAP1: CALL PLEASE_WAIT
        MOV AH,3CH              ;Create file
        MOV CX,0
        MOV DX,OFFSET SNAP_NAME
        INT 21H
        MOV BX,AX
        JB ESNAP
        MOV CX,4
        MOV DX,OFFSET DTA
        MOV WORD PTR DTA[2],3F00H
        MOV AX,MEM_MASK
        MOV WORD PTR TARGET_BANK,AX
        CMP AH,0
        JNZ SSNAP_16MEG
        MOV AH,AL
SSNAP_16MEG:
        MOV DTA[3],AH
        MOV AH,40H
        MOV WORD PTR DTA,0
        TEST BYTE PTR EMS_ENABLE,-1
        JNZ SSNAP2
        MOV BYTE PTR DTA[2],30H
SSNAP2: INT 21H
        MOV AL,MMU2
        MOV MMU2_SAVE,AL
        MOV BYTE PTR DTA[3],0
        MOV AX,WORD PTR INIT0   ;Get original MMU settings
        MOV CL,MMU              ;Get original MMU bank 0
        MOV CH,ROM_STATUS       ;Get ROM enable state
        PUSH AX
        PUSH CX
        OR AL,64                ;Enable MMU for SSNAP routine
        MOV DI,0FF90H
        PUTBYTE
        MOV AL,AH
        AND AL,254              ;Select TR=0
        INC DI
        PUTBYTE
        MOV DI,0FFDFH           ;Enable RAM
        PUTBYTE
SSNAP3: MOV AL,DTA[2]           ;Load number of first MMU bank
        MOV DI,0FFA0H           ;Switch MMU bank 0 to current bank to write
        PUTBYTE
        MOV AL,DTA[3]
        MOV DI,0FF70H
        PUTBYTE
        PUSH DS
        MOV AH,40H
        MOV CX,8192
        MOV DS,SS:[0]        
        MOV DX,0
        INT 21H
        POP DS
        JB SSNAP4               ;If there's an error, abort now
        MOV AX,WORD PTR DTA[2]  ;Loop until all banks written
        CMP AX,WORD PTR TARGET_BANK
        JNB SSNAP4
        INC WORD PTR DTA[2]     ;Increment to next bank
        JMP SSNAP3
SSNAP4: LAHF                    ;Save flags
        MOV CL,AH
        MOV AL,MMU2_SAVE        ;Reselect original MMU2 bank
        MOV DI,0FF70H
        PUTBYTE
        POP AX                  ;Reselect original MMU bank
        MOV DI,0FFA0H
        PUTBYTE
        MOV AL,AH               ;Reselect original ROM mode
        AND AL,1
        OR AX,0FFDEH
        MOV DI,AX
        PUTBYTE
        POP AX
        MOV DI,0FF90H           ;Reselect original MMU state
        PUTBYTE
        MOV AL,AH               ;and original Task Register
        INC DI
        PUTBYTE
        MOV AH,CL               ;Restore flag to check for errors
        SAHF
        JB ESNAP2
        MOV AL,DRB1
        MOV OLD_DRB1,AL
        MOV AL,CRB1
        MOV OLD_CRB1,AL
        MOV AH,40H
        MOV DX,OFFSET SNPTOP
        MOV CX,OFFSET SNPEND-SNPTOP
        INT 21H
        JB ESNAP2
        MOV AH,40H              ;Save MMU2 state
        MOV DX,OFFSET MMU2
        MOV CX,16
        INT 21H
        JB ESNAP2
        MOV AH,40H              ;Save NATIVE mode state
        MOV DX,OFFSET NATIVE
        MOV CX,3
        INT 21H
        JB ESNAP2

        IF ENABLE_NATIVE_VIDEO

        PUSH DS                 ;Save native interface banks
        MOV DS,NATIVE_VIDEO
        MOV AH,40H
        MOV CX,0F000H
        MOV DX,0
        INT 21H
        POP DS
        JB ESNAP2
        PUSH DS            
        MOV AX,NATIVE_VIDEO
        ADD AX,0F00H
        MOV DS,AX
        MOV AH,40H
        MOV CX,0F000H
        MOV DX,0
        INT 21H
        POP DS
        JB ESNAP2
        PUSH DS            
        MOV AX,NATIVE_VIDEO
        ADD AX,1E00H
        MOV DS,AX
        MOV AH,40H
        MOV CX,07C00H
        MOV DX,0
        INT 21H
        POP DS
        JB ESNAP2

        ENDIF

        MOV AH,3EH
        INT 21H
        JMP SNAP10
ESNAP2: JMP ESNAP

GSNAP:               ;Get name of snapshot in buffer        
        PUSH DX                 ;Set mouse cursor to name field
        MOV AX,4
        MOV CX,192
        MOV DX,44
        INT 33H
        POP DX
        MOV AH,2                ;Highlight "Load"/"Save"
        PUSH DX
        MOV BH,0
        INT10H
        MOV CX,6
        CALL PC_INVERT
        MOV SI,OFFSET SNAP_NAME ;Currrent name is default
        MOV DI,OFFSET FILE_BFR
        MOV CX,32
        PUSH ES
        MOV AX,DS
        MOV ES,AX
        REP MOVSB
        POP ES
        MOV DX,508H
        CALL GET_FILE           ;Get file name
        POP DX
        PUSHF
        MOV CX,6
        CALL PC_INVERT          ;Clear highlight
        POPF
        JNB GSNAP1
        RET
GSNAP1: MOV DI,OFFSET SNAP_NAME ;Set new name plus extension
        MOV BX,4150H            ;".PAK"
        MOV CH,4BH
        SUB CURSOR,8
        CALL NEW_FILE
        CLC
        RET

        ENDIF

SAVE_CONFIG:           ;Save general configurations file
        MOV SI,OFFSET CUR_PATH
        CALL RESTORE_DIR
        MOV AH,3CH
        MOV CX,0
        MOV DX,OFFSET GENERAL_CONFIG
        INT 21H
        MOV BX,AX
        MOV AH,40H
        MOV CX,OFFSET CFG2END-CFG2TOP
        MOV DX,OFFSET CFG2TOP
        INT 21H
        PUSH DS
        MOV AX,SS
        MOV DS,AX
        MOV CX,196
        MOV DX,CUSTOM_LIST
        MOV AH,40H
        INT 21H
        POP DS
        MOV AH,3EH
        INT 21H
        RET

;Joystick calibration menu

CALIB_MENU DB 0

CALIB7A:
        JMP CALIB7
CALIB:  SAVEREG
        MOV AH,3EH
        MOV BX,HANDLE
        INT 21H
        MOV HANDLE,-1
CALIB0: CALL MENU_SCREEN
        CMP NO_GAME_PORT,0
        JNZ CALIB7A
        MOV DI,OFFSET MSG39A
        MOV CALIB_MENU,0
CALIB1: MOV DX,918H
        MOV BX,8720H
        CALL MENU
CALIB2: MOV AH,1
        INT 16H
        JZ CALIB3
        KEYSTROKE
        CMP AL,27
        JNZ CALIB3
        JMP OPTION14
CALIB3: MOV DX,201H
        IN AL,DX
        XOR AL,240
        TEST AL,240
        JZ CALIB2
        MOV DI,OFFSET LCALIB
        MOV AH,1
        TEST AL,0C0H
        JZ CALIB4
        MOV DI,OFFSET RCALIB
        MOV AH,4
CALIB4: CALL JOYREAD
        PUSH CX
        ROL AH,1
        CALL JOYREAD
        CMP CALIB_MENU,0
        JNZ CALIB5
        MOV [DI+2],CX
        POP AX
        MOV [DI],AX
        JMP CALIB6
CALIB5: MOV AX,CX
        SUB AX,[DI+2]
        MOV CL,6
        SHR AX,CL
        CMP AX,1
        ADC AX,0
        MOV [DI+6],AX
        POP AX
        SUB AX,[DI]
        SHR AX,CL
        CMP AX,1
        ADC AX,0
        MOV [DI+4],AX
CALIB6: MOV AH,1
        INT 16H
        JNZ CALIB6A
        MOV DX,201H
        IN AL,DX
        NOT AL
        TEST AL,0F0H
        JNZ CALIB6
CALIB6A:
        NOT CALIB_MENU
        MOV DI,OFFSET MSG39A
        CMP CALIB_MENU,0
        JZ CALIB1A
        MOV DI,OFFSET MSG39B
        JMP CALIB1
CALIB1A:
        JMP OPTION14
CALIB7: MOV DI,OFFSET MSG39C
        MOV DX,0A18H
        MOV BX,8620H
        CALL MENU
        KEYSTROKE
        JMP OPTION14

;Options menu

ITEM:               ;Display string length CX in DI at DX
        PUSH ES
        MOV AX,SEG SINGLE
        MOV ES,AX
        PUSH CX
        MOV BX,10BH
        MOV CX,1
        MOV AL,ES:[DI]
        INC DI
        CALL PC_CHAR
        POP CX
        POP ES
        INC DL
        LOOP ITEM
        RET

OPTIONS: MOV AH,1
        INT 16H
        JZ OPTION1
        KEYSTROKE
        JMP OPTIONS
OPTION1: 
        SAVEREG
        MOV AH,3EH
        MOV BX,HANDLE
        INT 21H
        MOV HANDLE,-1
OPTION1A:
        CALL MENU_SCREEN
        MOV DI,OFFSET MSG31     ;Display window
        MOV DX,20AH
        MOV BX,953BH
        CALL MENU
OPTION2:                        ;Display current settings        
        MOV DI,OFFSET MSG32A    ;Keyboard
        CMP Byte Ptr KEY_MODE,0
        JZ OPTION3
        MOV DI,OFFSET MSG32B
        CMP Byte Ptr KEY_MODE,1
        JZ OPTION3
        MOV DI,OFFSET MSG32G
        CMP Byte Ptr KEY_MODE,3
        JZ OPTION3
        MOV DI,OFFSET MSG32E
OPTION3:
        IF ENABLE_DRAGON
        CMP BYTE PTR DRAGON,0
        JZ OPTION3A
        ADD DI,36
        ENDIF
OPTION3A:
        MOV CX,9
        MOV DX,820H
        CALL ITEM
        MOV AL,LJOYSTK          ;Left joystick
        cmp al,8
        mov di,offset msg33e
        jz option4
        CMP AL,6
        MOV DI,OFFSET MSG33D
        JZ OPTION4
        CMP AL,4
        MOV DI,OFFSET MSG33C
        JZ OPTION4
        CMP AL,2
        MOV DI,OFFSET MSG33B
        JZ OPTION4
        MOV DI,OFFSET MSG33A
OPTION4:
        MOV CX,6
        MOV DX,0923H
        CALL ITEM
        MOV DI,OFFSET MSG33B    ;Right joystick
        MOV AL,RJOYSTK
        CMP AL,2
        JZ OPTION5
        CMP AL,4
        MOV DI,OFFSET MSG33C
        JZ OPTION5
        CMP AL,6
        MOV DI,OFFSET MSG33D
        JZ OPTION5
        cmp al,8
        mov di,offset msg33e
        jz option5
        MOV DI,OFFSET MSG33A
OPTION5:
        MOV CX,6
        MOV DX,0A23H
        CALL ITEM
        MOV DI,OFFSET MSG34A    ;Sound
        CMP SOUND,1
        JZ OPTION6
        MOV DI,OFFSET MSG34C
        CMP SOUND,3
        JZ OPTION6
        MOV DI,OFFSET MSG34B
OPTION6:
        MOV CX,8
        MOV DX,0B21H
        CALL ITEM
        MOV DI,OFFSET MSG38A    ;Colour set
        CMP COLSET,0
        JZ OPTION7A
        MOV DI,OFFSET MSG38B
OPTION7A:
        MOV CX,9
        MOV DX,0C20H
        CALL ITEM
        MOV DI,OFFSET MSG35A    ;Border colour
        CMP BORDER_ENABLE,0
        JZ OPTION7
        MOV DI,OFFSET MSG35B
OPTION7:
        MOV CX,8
        MOV DX,0D21H
        CALL ITEM
        MOV DI,OFFSET MSG40A    ;Add linefeeds
        CMP BYTE PTR ADDLF,0
        JZ OPTION8
        MOV DI,OFFSET MSG40C
        CMP BYTE PTR ADDLF,80H
        JZ OPTION8
        MOV DI,OFFSET MSG40B
OPTION8:
        MOV CX,8
        MOV DX,0E21H
        CALL ITEM
        MOV DI,OFFSET MSG41A    ;Clock frequency
        MOV AL,CLOCK_MODE
        MOV CX,10
        MUL CL
        ADD DI,AX
        MOV DX,0F1FH
        CALL ITEM
        MOV DI,OFFSET MSG42A    ;1.2Mb drive mode
        CMP BYTE PTR DOUBLE_STEP,1
        JZ OPTION9A
        MOV DI,OFFSET MSG42B
OPTION9A:
        MOV CX,8
        MOV DX,1021H
        CALL ITEM

        IF ENABLE_RS232
        MOV DI,OFFSET MSG43A    ;Comm port
        TEST BYTE PTR VOLUME,128
        JZ OPTION9B
        MOV DI,OFFSET MSG43B
OPTION9B:
        MOV CX,4
        MOV DX,1125H
        CALL ITEM
        ENDIF

        MOV AX,DELAY            ;Speed slider
        MOV DX,0
        DIV SPEED_SCALE
        MOV DH,20
        CALL SLIDER
        MOV AL,VOLUME           ;Volume slider
        AND AL,127
        MOV AH,5
        MUL AH
        MOV DH,21
        CALL SLIDER
OPTION10:                       ;Ready for user.  Turn on mouse pointer
        MOV AX,1                ;and wait for some kind of input
        INT 33H
OPTION11:
        MOV AH,1
        INT 16H
        JZ OPTION12
        MOV AX,2
        INT 33H
        JMP OPTIONK
OPTION12:
        CMP MOUSE_HERE,0
        JZ OPTION10
        MOV AX,3
        INT 33H
        TEST BL,1
        JZ OPTION10
        CALL MOUSE_COORD
        MOV DH,DL
        MOV DL,CL
        PUSH DX
OPTION13:                       ;Otherwise do
        MOV AX,3
        INT 33H
        TEST BL,1
        JNZ OPTION13
        MOV AX,2
        INT 33H
        POP DX
        CMP DH,2                ;Off of window
        JB OPTION14
OPTION10A:
        JZ OPTION10
        CMP DH,22
        JA OPTION14
        JZ OPTION10
        CMP DL,10
        JB OPTION14
        JZ OPTION10
        CMP DL,68
        JA OPTION14
        JZ OPTION10
        CMP DH,8                ;Dead zone
        JB OPTION10
        CMP DH,18
        JZ OPTION10
        CMP DH,19
        JZ OPTION10
        MOV CX,OFFSET MOUSE_LEFT
        JA OPTION13B
        CMP DL,42
        JZ OPTION10A
        CMP DL,43
        JZ OPTION10A
        JB OPTION13B
        MOV CX,OFFSET MOUSE_RIGHT
OPTION13B:
        MOV BL,DH               ;Branch to zone handler
        MOV BH,0
        SUB BL,8
        ADD BX,BX
        ADD BX,CX
        JMP word ptr [BX]
OPTION14:
        CALL CLOCK_SET          ;Fix interrupt handlers and constants
        MOV LASTKEY,0           ;Exit for one reason or another
        MOV AL,DRB2             ;Update VDG the thorough way
        NOT BYTE PTR DRB2
        MOV DI,0FF22H
        MOV DRB2,0
        PUTBYTE
        CALL RESETBRANCH
        LOADREG
        CALL FORCE_REVISE
        JMP MAIN

MOUSE_LEFT DW A_OPT,B_OPT,C_OPT,D_OPT,E_OPT,F_OPT,G_OPT,H_OPT
        IF ENABLE_RS232
        DW I_OPT,J1_OPT,OPTION2,OPTION2,S_OPT,V_OPT
        ELSE
        DW I_OPT,OPTION2,OPTION2,OPTION2,S_OPT,V_OPT
        ENDIF
MOUSE_RIGHT DW J_OPT,K_OPT,L_OPT,M_OPT,N_OPT,P_OPT,Q_OPT,R_OPT,O_OPT,T_OPT

A_OPT:  INC BYTE PTR KEY_MODE   ;Change keyboard and redisplay
        CMP BYTE PTR KEY_MODE,4
        JB A_OPT1
        MOV BYTE PTR KEY_MODE,0
        IF ENABLE_DRAGON
        NOT DRAGON
        ENDIF
A_OPT1: JMP OPTION2
B_OPT:  mov bl,ljoystk          ;Left joystick
        mov bh,0
        mov ax,joyorder[bx]
        and al,0feh
        cmp al,10
        jb b_opta
        mov al,6
b_opta:
        mov ljoystk,al
        CALL JOYTEST
        MOV BYTE PTR FIRE,-1
        JMP OPTION2
C_OPT:  mov bl,rjoystk          ;Right joystick
        mov bh,0
        mov ax,joyorder[bx]
        and al,0feh
        cmp al,10
        jb c_opta
        mov al,6
c_opta:
        mov rjoystk,al
        CALL JOYTEST
        MOV BYTE PTR FIRE,-1
        JMP OPTION2
D_OPT:  MOV AL,SOUND            ;Sound
        INC AL
        AND AL,SBMASK
        MOV SOUND,AL
        CMP AL,2
        JNZ A_OPT1
        MOV BYTE PTR SOUND,3
        JMP OPTION2
E_OPT:  XOR COLSET,1            ;Colour set 
        JMP OPTION2
F_OPT:  NOT BORDER_ENABLE       ;Border colour
        JMP OPTION2
G_OPT:  MOV AL,ADDLF            ;Add linefeeds
        OR AL,AL
        MOV BYTE PTR ADDLF,-1
        JZ G_OPT1
        MOV BYTE PTR ADDLF,80H
        INC AL
        JZ G_OPT1
        MOV BYTE PTR ADDLF,0
G_OPT1: JMP OPTION2
H_OPT:  INC BYTE PTR CLOCK_MODE ;Clock frequency
        CMP BYTE PTR CLOCK_MODE,4
        JNA G_OPT1
        MOV BYTE PTR CLOCK_MODE,0
        JMP OPTION2
I_OPT:  XOR BYTE PTR DOUBLE_STEP,1;40/80 track mode of 1.2Mb drive
        JMP OPTION2
        IF ENABLE_RS232
J1_OPT: XOR BYTE PTR VOLUME,128 ;Toggle COM port
        JMP OPTION2
        ENDIF
S_OPT:  CMP DL,64               ;Speed
        JA S_OPT2
        CMP DL,26
        JB S_OPT2
        MOV AL,64
        SUB AL,DL
        MOV AH,0
        PUSH AX
        MUL SPEED_SCALE
        MOV DELAY,AX
        POP AX
        MOV DH,20
        CALL SLIDER
S_OPT1: JMP OPTION10
OPTIONMA:
        JMP OPTIONM
OPTIONPA:
        JMP OPTIONP
S_OPT2: CMP DL,25
        JZ OPTIONMA
        CMP DL,66
        JZ OPTIONPA
        MOV AX,1
        INT 33H
S_OPT3: MOV AX,3                ;If outside slider, make sure button released
        INT 33H         
        TEST BL,1
        JNZ S_OPT3
        JMP OPTION11
V_OPT:  CMP DL,64               ;Volume
        JA V_OPT2
        CMP DL,26
        JB V_OPT2
        MOV AX,64
        SUB AL,DL
        MOV DL,5
        DIV DL
        AND BYTE PTR VOLUME,128
        OR VOLUME,AL
        MUL DL
        MOV DH,21
        CALL SLIDER
V_OPT1: JMP OPTION10
OPTIONLA:
        JMP OPTIONL
OPTIONGA:
        JMP OPTIONG
V_OPT2: CMP DL,25
        JZ OPTIONLA
        CMP DL,66
        JZ OPTIONGA
        MOV AX,1
        INT 33H
V_OPT3: MOV AX,3                ;If outside slider, make sure button released
        INT 33H         
        TEST BL,1
        JNZ V_OPT3
        JMP OPTION11
J_OPT:  LOADREG                 ;Debug
        MOV DBGMSG,OFFSET MSG17
        JMP DEBUG
K_OPT:  LOADREG                 ;Virtual disk menu
        JMP VDISK
L_OPT:  IF ENABLE_SNAPSHOTS
        LOADREG                 ;Snapshot menu
        JMP SNAP
        ELSE
        JMP OPTION2
        ENDIF
M_OPT:  LOADREG                 ;Customize keyboard
        JMP CUSTOMIZE
N_OPT:  JMP CALIB0              ;Calibrate joystick
O_OPT:  MOV AX,3                ;Shell call to DOS
        INT 10H
        PUSH DS
        PUSH ES
        MOV AX,SEG MSG43
        MOV DS,AX
        MOV AH,9
        MOV DX,OFFSET MSG43
        INT 21H
        MOV DS,CS:ENVIRONMENT   ;Look for COMSPEC= in environment
        MOV DI,0
        JMP O_OPT2
O_OPT1: INC DI
        CMP BYTE PTR [DI-1],0
        JNZ O_OPT1
        CMP BYTE PTR [DI],0
        JNZ O_OPT2
        MOV AX,CS
        MOV DS,AX
        MOV DX,OFFSET COMMAND_NAME
        JMP O_OPT3
O_OPT2: CMP WORD PTR [DI],4F43H ;"CO"
        JNZ O_OPT1
        CMP WORD PTR [DI+2],534DH
        JNZ O_OPT1              ;"MS"
        CMP WORD PTR [DI+4],4550H
        JNZ O_OPT1              ;"PE"
        CMP WORD PTR [DI+6],3D43H
        JNZ O_OPT1              ;"C="
        MOV DX,DI
        ADD DX,8
O_OPT3:
        CMP CS:EMS_ENABLE,0
        JZ NO_SHRINK
        PUSH DS
        PUSH ES
        MOV AX,CS
        MOV DS,AX
        MOV ES,AX
        MOV AX,4E01H            ;Restore memory map set up at entry time
        MOV SI,OFFSET ENTRY_MAP
        INT 67H
        MOV AX,BASE_SEGMENT     ;Shrink allocation to free EMS windows
        MOV ES,AX
        MOV BX,NO_EMS_MEMORY
        SUB BX,AX
        MOV AH,4AH          
        INT 21H
        POP ES
        POP DS
NO_SHRINK:
        MOV AX,CS               ;ES:BX is parameter block
        MOV ES,AX
        MOV BX,OFFSET PARAM_BLOCK
        MOV AX,4B00H
        INT 21H
        JNB O_OPT4
        CMP AL,8
        JZ OUT_OF_MEMORY
        MOV DL,7
        MOV AH,2
        INT 21H
        JMP O_OPT4
OUT_OF_MEMORY:
        MOV AX,3
        INT 10H
        MOV AX,SEG MSG52
        MOV DS,AX
        MOV AH,9
        MOV DX,OFFSET MSG52
        INT 21H
        KEYSTROKE
O_OPT4: MOV AX,CS
        MOV DS,AX
        MOV ES,AX
        CMP EMS_ENABLE,0
        JZ NO_GROW
        MOV AX,BASE_SEGMENT     ;Recover EMS windows
        MOV ES,AX
        MOV BX,FREE_MEMORY
        SUB BX,AX
        MOV AH,4AH          
        INT 21H
        JNB NO_RECOVERY_ERROR
        MOV AX,SEG MSG53
        MOV DS,AX
        MOV AH,9
        MOV DX,OFFSET MSG53
        INT 21H
        KEYSTROKE
        JMP QUIT1
NO_RECOVERY_ERROR:
        CALL FIX_BANKS
NO_GROW:
        POP ES
        POP DS
        MOV AH,1AH              ;Reset Disk Transfer Address
        MOV DX,OFFSET DTA
        INT 21H
        MOV SI,OFFSET CUR_PATH  ;Restore working directory so vdisks work
        CALL RESTORE_DIR
        PUSH ES                 ;Restore mouse driver after reset
        MOV AX,0
        INT 33H
        MOV AX,CS
        MOV ES,AX
        MOV DX,OFFSET MOUSE_INTERCEPT
        MOV CX,47
        MOV AX,0CH
        INT 33H
        POP ES
        JMP OPTION14            ;Redisplay options menu
PORT:   SAVEREG                 ;Standard preamble if PORT activated by F9
        MOV AH,3EH
        MOV BX,HANDLE
        INT 21H
        MOV HANDLE,-1
P_OPT:  MOV SI,OFFSET CUR_PATH  ;File import/export utility, call program
        CALL RESTORE_DIR        ;First select COCO.EXE's home directory
        MOV DX,OFFSET PORT_NAME ;then call the program
        PUSH DS
        PUSH ES
        JMP O_OPT3
Q_OPT:  MOV DI,OFFSET MSG36     ;Quit
        CALL CONFIRM
        JB R_OPT1
        JMP QUIT1
R_OPT:  MOV DI,OFFSET MSG37     ;Restart
        CALL CONFIRM
        JB R_OPT1
        MOV RESTART_FLAG,-1
        MOV LASTKEY,0
        JMP QUIT1
R_OPT1: JMP OPTION1A
T_OPT:  LOADREG                 ;Virtual cassette menu
        JMP VIRCAS
OPTIONLB:
        JMP OPTIONL
OPTIONK:                        ;Keyboard handler
        KEYSTROKE
        CMP AL,27
        JNZ OPTIONK1
        JMP OPTION14            ;ESC exit branch
OPTIONK1:
        CMP AL,'+'              ;Speed control keys
        JZ OPTIONP
        CMP AL,'-'
        JZ OPTIONM
        CMP AL,'<'              ;Volume control keys
        JZ OPTIONLB
        CMP AL,'>'
        JZ OPTIONG
        AND AL,223
        SUB AL,'A'              ;Letter options
        JB OPTIONK2
        CMP AL,20
        JNB OPTIONK2
        MOV BL,AL
        MOV BH,0
        ADD BX,BX
        JMP KEY_OPTION[BX]
OPTIONK2:
        JMP OPTION10
KEY_OPTION DW A_OPT,B_OPT,C_OPT,D_OPT,E_OPT,F_OPT,G_OPT,H_OPT,I_OPT
        IF ENABLE_RS232
        DW J1_OPT
        ELSE
        DW OPTION2
        ENDIF
        DW J_OPT,K_OPT,L_OPT,M_OPT,N_OPT,P_OPT,Q_OPT,R_OPT,O_OPT,T_OPT
OPTIONP:                        ;Increase speed by one step
        CMP DELAY,0
        JZ OPTIONP1
        MOV AX,SPEED_SCALE
        SUB DELAY,AX
        JNB OPTIONP1
        MOV DELAY,0
OPTIONP1:        
        JMP OPTION2
OPTIONM:                        ;Decrease speed by one step
        MOV AX,SPEED_SCALE
        ADD DELAY,AX
        MOV AX,DELAY
        MOV DX,0
        DIV SPEED_SCALE
        CMP AX,38
        JNA OPTIONP1
        MOV AX,38
        MUL SPEED_SCALE
        MOV DELAY,AX
        JMP OPTIONP1
OPTIONG:                        ;Increase volume by one step
        TEST BYTE PTR VOLUME,127
        JZ OPTIONG1
        SUB BYTE PTR VOLUME,1
OPTIONG1:        
        JMP OPTION2
OPTIONL:                        ;Decrease volume by one step
        ADD BYTE PTR VOLUME,1
        TEST BYTE PTR VOLUME,8
        JZ OPTIONG1
        SUB BYTE PTR VOLUME,1
        JMP OPTION2

SPEED_SCALE DW 1

CONFIRM:               ;Display confirmation window in DI
        MOV DX,916H
        MOV BX,8623H
        MOV MENU_BACK,4         ;Make this window red/yellow
        CALL MENU
        MOV MENU_BACK,1         ;Restore normal blue/cyan
        MOV AX,4                ;Set mouse cursor position
        MOV DX,96
        MOV CX,216
        INT 33H
CONFIRM1: 
        MOV AX,1                ;Enable mousy pointy thingy
        INT 33H
CONFIRM2:                       ;Wait for user response
        MOV AH,1
        INT 16H
        JNZ CONFIRM4
        CMP MOUSE_HERE,0
        JZ CONFIRM2
        MOV AX,3
        INT 33H
        TEST BL,1
        JZ CONFIRM2
        CALL MOUSE_COORD
        MOV DH,DL
        MOV DL,CL
CONFIRM3:
        PUSH DX                 ;Wait for button to be released
        MOV AX,3
        INT 33H
        POP DX
        TEST BL,1
        JNZ CONFIRM3
        MOV AX,2                ;Bye-bye mousy pointy thingy
        INT 33H
        CMP DH,13               ;Dead space of mouse
        JA CONFIRM1
        CMP DH,11
        JB CONFIRM1
        CMP DL,23
        JB CONFIRM1
        CMP DL,31               ;"Yes" zone
        JB CONFIRMY
        CMP DL,56
        JA CONFIRM1
        CMP DL,48               ;"No" zone
        JA CONFIRMN
        JMP CONFIRM1
CONFIRM4:
        MOV AX,2                ;Keyboard intercept.  Kill mouse pointer.
        INT 33H
        KEYSTROKE
        AND AL,223
        CMP AL,'Y'
        JZ CONFIRMY
        CMP AL,'N'
        JZ CONFIRMN
        JMP CONFIRM1
CONFIRMY:
        CLC
        RET
CONFIRMN:
        STC
        RET

SLIDER:               ;Display speed slider        
        MOV CX,38
        SUB CX,AX
        JZ SLIDER1
        PUSH AX
        MOV DL,1BH
        MOV AL,7
        MOV BX,10BH
        PUSH DX
        CALL PC_CHAR
        POP DX
        POP AX
SLIDER1:
        ADD CL,27
        MOV DL,CL
        MOV CX,AX
        CMP AX,0
        JZ SLIDER2
        MOV BX,100H
        MOV AL,7
        CALL PC_CHAR
SLIDER2:
        RET

;General lookup information

MSG4    DB 'Memory dump.  Enter an address or a register: '    
MSG4A   DB '    ',0
MSG4B   DB 'Locate word.  Enter word to find: '
MSG4C   DB '    ',0
MSG6    DB 'Enter new value for register:     ',0
MSG8    DB 'Disassemble.  Enter an address or a register: '
MSG8A   DB '    ',0
MSG9B   DB '     ? '

        IF ENABLE_MATH

MSG9    DB 'Hexidecimal number: '
MSG9A   DB '    ',0
MSG10   DB '       Options: + - * / And Or Xor Neg Shift Rot Dec.   ENTER '
        DB 'or ESC when done.',0
MSG11   DB '       Use arrows to shift.  Press ENTER or ESC to return to '
        DB 'options.',0
MSG12   DB '       Use arrows to rotate.  Press ENTER or ESC to return to '
        DB 'options.',0
MSG13   DB '       Decimal: '
MSG13A  DB '-00000'
MSG13B  DB 0

        ENDIF

MSG16   DB 'Breakpoint.  Enter address:     ',0

MSG47A  DB 'PLAYBACK'
MSG47B  DB '*RECORD*'

MSG15   DB 'Error loading '
ROMNAME DB '????????.ROM$'
PAKSEARCH DB -1,0,0,0,0,0,00H
        DB 0,'????????PAK'
        DB 20 DUP(?)
DSKSEARCH DB -1,0,0,0,0,0,00H
        DB 0,'????????DSK'
        DB 20 DUP(?)
CASSEARCH DB -1,0,0,0,0,0,00H
        DB 0,'????????CAS'
        DB 20 DUP(?)
DIRSEARCH DB -1,0,0,0,0,0,10H
        DB 0,'???????????'
        DB 20 DUP(?)
ROMSEARCH DB 0,'????????ROM'
        DB 20 DUP(?)
DISK_CONFIG DB 'DRIVES.CC3',0
GENERAL_CONFIG DB 'GENERALX.CC3',0
TWOMEGS DB '2MEGS',0
SIXTEENMEGS DB '16MEGS',0
COMMAND_NAME DB '\COMMAND.COM'
COMMAND_PARAM DB 0,13
PARAM_BLOCK DW 0
        DW OFFSET COMMAND_PARAM
        DW SEG COMMAND_PARAM
        DW OFFSET COMMAND_PARAM
        DW SEG COMMAND_PARAM
        DW OFFSET COMMAND_PARAM
        DW SEG COMMAND_PARAM
PORT_NAME DB 'PORT.EXE',0
FL_LIST DB 'EFHINZVC'
RG_LIST DB 'SUYXP'
HEX_LIST DB 'FEDCBA9876543210'
PTR_LIST DB 'DPSUYXADDDD'
CALC_CMD DB 'D+-*/AOXNSR',13,27
DBGMSG  DW OFFSET MSG2
COMMANDS:
        DB 'L'
        DW locate
        DB 'B'
        DW BREAK
        DB 'C'
        DW CONTINUE
        DB 'D'
        DW DISASM
        DB 'E'
        DW EDIT
        DB 'F'
        DW FLAGS
        IF ENABLE_MATH
        DB 'H'
        DW MATH
        ENDIF
        DB 'M'
        DW MEMORY
        DB 'Q'
        DW QUIT
        DB 'R'
        DW SETREG
        DB 'S'
        DW STEP
        DB 'V'
        DW VIDEO
        DB 'O'
        DW STEPOVER
        DB 0
LASTDIS DB 'P'

JOYORDER DW 8,4,6,0,2

;Emulator data -- not to be saved

KEY_MATRIX DB 8 DUP(-1)         ;Array representing each bit plane of PIA1
CALCDATA DW ?                   ;Used in Hex Math option
BRKPT   DW -1                   ;Break point address. -1=disable
BACKUP  DB 80 DUP(?)            ;Copy of keyboard buffer to restore if ESC
DTA     DB 6249 DUP(?)          ;Disk transfer address 
LASTKEY DB 16 DUP(?)            ;Last key caught by keyboard interrupt
VID_SEG DW 0A000H               ;Video segment
DRA1_MATRIX DB 256 DUP(-1)      ;Lookup table for DRA1 response to DRB1 set
FILE_BFR DB 32 DUP(?)           ;File name input field
HANDLE  DW -1                   ;Handle of currently open virtual drive file
COUNTDOWN DB 0                  ;Timer for closing virtual files
CUR_PATH DB 0,'\',64 DUP(0)     ;Power-up default directory
PULSE DB 0                      ;128=clock interrupt request
        IF ENABLE_DRAGON
DRAG_XLAT DB 2,3,4,5,0,1,6,7    ;Dragon keyboard column rearrangement
        ENDIF
ENVIRONMENT DW 0                ;Segment of DOS environment
BASE_SEGMENT DW 0               ;Segment of PSP
MEMORY_SIZE DW 0                ;Contains required memory alloc. in paragraphs

CHANDLE DW -1   ;Handle for virtual cassette file

MEMTYPE DB 0    ;Memory dump type: 0=explicit, 1=PC, 2=X, 3=Y, 4=U, 5=S, 6=DP,
                ;                  7=A/B
DISTYPE DB 1    ;Disassembly type: 1=PC, 2=X, 3=Y, 4=U, 5=S, 6=DP, 7=A/B, 
                ;                  8=explicit
MEMADR  DW 0    ;Explicit address for memory dump
DISADR  DW 0    ;Explicit address for disassembly
SBMASK  DB 1    ;1=no SoundBlaster, 3=SoundBlaster found
EMS_ENABLE DB 0 ;Non-zero if 384K EMS allocated
TOPRAM DW 0     ;Segment of upper 64K of RAM
EMS_BANKS DW 0,1,2,3,4,5,6,7    ;8 EMS banks corresponding to 8 required 
                                ;windows
EMS_WINDOWS DW 0D000H,0D000H,0D000H,0D000H,0D000H,0D000H,0D000H,0D000H
EMS_HANDLE DW 0 ;To hold handle number for allocated EMS memory
NEW_BOTTOM DW 600H
RETURN_ADDRESS DW -1
ORIGINAL_CURSOR DW 15
MISSED_INTERRUPT DB 0

;Emulation data -- to be saved

SNPTOP  EQU $

SNAP_NAME DB 33 DUP(0)
                ;Name of snapshot file
REGPC   DW ?    ;6809 PC register
REGX    DW ?    ;6809 X register
REGY    DW ?    ;6809 Y register
REGU    DW ?    ;6809 U register
REGSP   DW ?    ;6809 S register
        DB 0    ;Filler to make DP a 16-bit address for Mem dump and Disassem
REGDP   DB ?    ;6809 DP register
REGD    DW ?    ;6809 D register (MSB=A, LSB=B)
        DB 6 DUP(0)     ;Reserved for 6309 registers
REGF    DW ?    ;8086 flag registers
REGFI   DB 80   ;6809 flag registers

;This data stored in DRIVES.CFG

CFG1TOP EQU $
WR_PROT DB 0    ;Bit n set => drive n write protected
VIR_DIR DB 66 DUP(?)
                ;Last directory viewed by virtual disk menu
PATHS   DB 0,31 DUP(?),0,31 DUP(?),0,31 DUP(?),0,31 DUP(?)
                ;Virtual disk paths for drives 0 through 3
CFG1END EQU $

;This data stored in GENERAL.CFG

CFG2TOP EQU $
SNAP_PATH DB 66 DUP(?)
ADDLF   DB -1   ;0=No LFs added after CRs, -1=add LFs after CRs, 80H=disabled
KEY_MODE DB 0   ;Specify PC (0), CoCo (1), Custom (2) or OS9 (3) layout
DELAY   DW 0    ;Delay loop counter.  0=no delay
LJOYSTK DB 0    ;Left joystick: 0=mouse, 2=left game port, 4=right, 6=none
RJOYSTK DB 6    ;Right joystick input
SOUND   DB 1    ;Bit 0 set=sound on, bit 1 set=SoundBlaster
COLSET  DB 0    ;0=RGB colours, -1=composite
BORDER_ENABLE DB 0      ;0=black border, -1=variable
DRAGON  DB 0    ;0=CoCo keyboard, -1=Dragon keyboard
LCALIB  DW 0    ;Base to subtract from left joystick calibration (H)
        DW 0    ;(V)
        DW 1    ;Division factor for left scaling (H)
        DW 1    ;(V)
RCALIB  DW 0    ;Same for right joystick
        DW 0
        DW 1
        DW 1
CLOCK_MODE DB 0 ;Bit 0 is VSYNC: 0=60Hz, 1=50Hz; bit 1 set if HSYNC enabled
                ;Bit 2 set = sync locked
DOUBLE_STEP DB 1        ;1.2Mb track step (0=single, 1=double)
VOLUME  DB 0    ;Volume setting (0=loudest, 7=quietest)
CASMODE DB 0    ;0=cassette playback, -1=cassette record
CAS_DIR DB 66 DUP(?)
CAS_NAME DB 33 DUP(0)
                ;Name of last opened virtual cassette
CYCLE_COUNT DB 127
CFG2END EQU $

OLD_DRB1 DB -1          ;Last setting of DRB1, used in snapshot restore
OLD_CRB1 DB 4           ;Last setting of CRB1, used in snapshot restore
DRB2    DB 0            ;$FF22 write
INIT0   DB 8CH          ;$FF90 write
INIT1   DB 0            ;$FF91 write
IRQENR  DB 0            ;$FF92 write
IRQSET  DB 64           ;$FF92 read
FIRQENR DB 0            ;$FF93 write
FIRQSET DB 64           ;$FF93 read
CEILING DW 4095         ;$FF94/$FF95 write
VMODE   DB 1            ;$FF98 write
VRES    DB 1            ;$FF99 write
OVERSCAN DB 0           ;$FF9A write
VERT_SCROLL DB 0        ;$FF9C write
VERT_OFF_1 DB -1        ;$FF9D write
VERT_OFF_0 DB -1        ;$FF9E write
HORZ_OFF DB 0           ;$FF9F write
;Default contents of MMU bank switcher
MMU     DB 38H,39H,3AH,3BH,3CH,3DH,3EH,3FH,38H,39H,3AH,3BH,3CH,3DH,3EH,3FH
;16 palette registers
PALETTE DB 12H,36H,09H,24H,3FH,10H,2DH,26H,00H,12H,00H,3FH,00H,12H,00H,26H
V012    DW 0            ;$FFC0-$FFC5 SAM video length state
VIDEO_BLOCK DB 7        ;A18-A16 of current video memory
NEW_TOP DW 400H         ;$FFC6-$FFD3 SAM video base state
COCO_TOP DW 0400H       ;This register contains CoCo=1 TOP
ROM_STATUS DB 0DEH      ;0DEH if bank 1=ROM, 0DFH if bank 1=RAM
CPU_SPEED DB 0D8H       ;0D8H if in 0.89MHz mode, 0D9H if in 1.78MHz mode
SNPEND  EQU $

PROG    ENDS

RAMHERE SEGMENT PUBLIC 'RAMSEG'
RAMHERE ENDS

        END START

