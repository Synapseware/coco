
10 'BINTOBAS
20 'by L. Todd Knudsen
30 'Copyright 1988
40 'shareware
50 '
60 CLEAR5000
70 C=0:B=0:Q$=CHR$(34)
80 WIDTH40:PALETTE0,0:PALETTE8,63
90 LOCATE10,0:ATTR3,2:PRINT" B I N  T O  B A S ";:ATTR0,0:PRINT
100 PRINT"             Copyright 1988"
110 PRINT
120 PRINT"          by L. Todd knudsen"
130 PRINT"             - shareware -"
140 PRINT
150 PRINT"This program duplicates binary programs"
160 PRINT"on disk, including programs with multi-"
170 PRINT"ple  originates etc.  A  BASIC  program"
180 PRINT"will be constructed with the same  name"
190 PRINT"but with a BAS extention.  When you RUN"
200 PRINT"the the resulting  BASIC  program  make"
210 PRINT"sure it is on a different disk than the"
220 PRINT"original  BIN file  or it will be  over"
230 PRINT"written as the BASIC  program  uses the"
240 PRINT"same file name.  The resulting programs"
250 PRINT"would  be most  useful  for transfering"
260 PRINT"files on BBS's,  other  online services"
270 PRINT"and the printing of drivers for machine"
280 PRINT"code programs in newsletters, etc."
290 PRINT
300 LINEINPUT"FILENAME no extention:";F$
310 IF F$="" OR LEN(F$)>8 OR INSTR(1,F$,".")>0 THEN 90
320 CLS
330 OPEN"O",#2,F$+".BAS"
340 OPEN"D",#1,F$+".BIN",1
350 L=LOF(1)
360 D=0:GOSUB670
370 D=2:GOSUB670
380 FOR R=1 TO L
390 GET#1,R
400 FIELD#1,1 AS B$
410 GOSUB 510
420 NEXT
430 '
440 IFB<115 THEN B=115:GOSUB 520
450 AR$=MID$(STR$(LN),2,LEN(STR$(LN))-1)
460 PRINT#2,STR$(LN+1000)+" "+"B$("+AR$+")="+Q$+"END"+Q$
470 PRINT#2,STR$(LN+1001)+" RETURN"
480 CLOSE
490 END
500 '
510 B=B+1
520 IF B=115 THEN GOSUB 580
530 H$=HEX$(ASC(B$))
540 IF LEN(H$)=1 THEN Z$="0" ELSE Z$=""
550 LN$=LN$+Z$+H$
560 RETURN
570 '
580 B=1
590 AR$=MID$(STR$(LN),2,LEN(STR$(LN))-1)
600 LN$=STR$(LN+1000)+" "+"B$("+AR$+")="+Q$+LN$+Q$
610 LN=LN+1
620 PRINT LN$ : PRINT#2,LN$
630 LN$="":AR$=MID$(STR$(LN),2,LEN(STR$(LN))-1)
640 RETURN
650 '
660 '
670 PRINT#D,"5 'Driver for "F$".BIN"
680 PRINT#D,"10 CLEAR"255*INT(L/114)":LN=0:DIMB$("INT(L/114)+1"):CLS:GOSUB1000"
690 PRINT#D,"15 SAVEM "Q$;F$".BIN"Q$",0,0,0"
700 PRINT#D,"20 OPEN"Q$"D"Q$",#1,"Q$;F$".BIN"Q$",1"
710 PRINT#D,"30 FIELD#1,1 AS A$"
720 PRINT#D,"40 IF B$(LN)="Q$"END"Q$" THEN 150"
730 PRINT#D,"50 PRINT"Q$"PROCESSING DATA BLOCK "Q$"LN"
740 PRINT#D,"60 FOR L=1 TO LEN(B$(LN)) STEP 2"
750 PRINT#D,"70 B$=MID$(B$(LN),L,2)"
760 PRINT#D,"80 B$=CHR$(VAL("Q$"&H"Q$"+B$))"
770 PRINT#D,"90 LSET A$ = B$
780 PRINT#D,"100 R=R+1"
790 PRINT#D,"110 PUT#1,R"
800 PRINT#D,"120 NEXT L"
810 PRINT#D,"130 LN=LN+1"
820 PRINT#D,"140 GOTO 40"
830 PRINT#D,"150 CLOSE"
840 PRINT#D,"160 PRINT:PRINT"Q$"All done..."Q$
850 PRINT#D,"170 END"
860 PRINT#D,"180 '"
870 RETURN
                                                                                      