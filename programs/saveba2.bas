1 REM SAVE ASCII PGM
2 REM SAVEBA2.BAS
3 REM READS/APPENDS CHUNKS <=16K
4 REM 980301.1745
10 CLEAR 1024,12287 : PCLEAR 1
100 PRINT "FILENAME: ";
110 LINE INPUT F$
120 OPEN "O",#1,F$
130 PRINT #1,""
150 LOADM "COMM4.BIN"
200 PRINT "PRESS 'ENTER', THEN SEND DATA,"
201 PRINT "OR ENTER 'Q' TO QUIT: ";
210 LINE INPUT Q$
220 IF Q$<>"Q" THEN 250
230 CLOSE #1
240 GOTO 400
250 EXEC
260 A0=&H4000
270 A1=PEEK(&H3100)*256+PEEK(&H3101)
280 IF A1<>A0 THEN 300
290 PRINT "NO DATA RECEIVED!"
295 GOTO 200
300 A=A0
310 P$=""
320 B=PEEK(A)
330 A=A+1
340 IF B=10 OR B=13 THEN 370
350 P$=P$+CHR$(B)
360 IF A<A1 THEN 320
370 IF P$="" THEN 380
372 PRINT #1,P$
375 PRINT "  "+LEFT$(P$,29)
380 IF A<A1 THEN 310
390 GOTO 200
400 D=INSTR(F$,".")
410 IF D<1 THEN 450
420 FL$=LEFT$(F$,D-1)
430 FR$=RIGHT$(F$,LEN(F$)-D)
440 GOTO 500
450 FL$=F$
460 FR$=""
500 FL$=LEFT$(FL$+"        ",8)
510 FR$=LEFT$(FR$+"   ",3)
520 F$=FL$+FR$
550 PRINT "ADJUSTING FILE TYPE"
600 FOR S=3 TO 11
610 M=0
620 DSKI$ 0,17,S,A$,B$
630 T$=A$:GOSUB 1000:A$=T$
640 T$=B$:GOSUB 1000:B$=T$
650 IF M=0 THEN 670
660 DSKO$ 0,17,S,A$,B$
670 NEXT S
680 END
1000 FOR E=0 TO 3
1010 TF$=MID$(T$,E*32+1,11)
1020 IF TF$<>F$ THEN 1070
1025 PRINT "FOUND '"+F$+"' IN 17,";S
1030 TL$=LEFT$(T$,E*32+11)
1040 TR$=RIGHT$(T$,(3-E)*32+19)
1050 T$=TL$+CHR$(0)+CHR$(255)+TR$
1060 M=M+1
1070 NEXT E
1080 RETURN
