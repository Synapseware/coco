
1 'REMOVE APOSTROPHE IN LINE 2 FOR MONOCHROME
2 'POKE &HFF9E,145 'MONOCHROME
3 WIDTH 32
5 CLS:PRINT@96,"PMODE4 PICTURE VIEWING UTILITY":PRINT"       (.MAX OR .BIN)
6 PRINT"BY DANIEL POIRIER (DIGITIZER)"
7 FOR I=0 TO 2000:NEXT I
10 CLS:PRINT"YOU MUST ENTER THE PICTURE'S    NAMES BETWEEN LINE 200 AND 219  (40 PICTURES MAXIMUM)"
20 PRINT:PRINT"WHEN THE PICTURES ARE LOADED----PRESS ANY KEY TO BEGIN"
30 PRINT:PRINT"USE RIGHT JOYSTICK (LEFT-RIGHT) TO ADJUST THE VIEWING SPEED IN  AUTOMATIC MODE"
40 PRINT"THIS PROGRAM REQUIRES 512K"
50 PRINT"=========================="
60 PRINT"PRESS ANY KEY TO BEGIN"
62 PRINT"garbage on screen"
63 PRINT"is normal during loading"
65 EXEC 44539
70 PALETTE 0,0:PALETTE 1,63
80 RESTORE
90 X=0
100 POKE &HFFA2,X
110 POKE &HFF90,124
120 READ A$:IF A$="END" THEN 230
130 LOADM A$,&H3200
140 X=X+1
150 IF X>40 THEN CLS:PRINT"THERE IS MORE THAN 40 PICTURES IN THE DATA LIST":STOP
160 GOTO 100
170 END
200 DATA "PICTURE1.EXT","PICTURE2.EXT","PICTURE3.EXT"
210 DATA "PICTURE4.EXT"
219 DATA"LAST PIC.EXT"
220 DATA "END"
230 WIDTH 32:PRINT"THE MEMORY CONTAINS ";X;" PICTURES...":A=X-1:FOR I=0 TO 1000:NEXT I
240 WIDTH 32:PRINT:INPUT"VIEWING MODE---(M)ANUAL OR (A)UTOMATIC";A$:IF A$="M" THEN 310
250 HSCREEN 2:POKE &HFF99,8
260 POKE &HFF9A,63
270 FOR X=0 TO (A*4) STEP 4
280 POKE &HFF9D,X:POKE &HFF90,124
290 FOR I=1 TO (JOYSTK(0)*30):NEXT I:NEXT X
300 SOUND 100,5:EXEC 44539:GOTO 240
310 HSCREEN 2:POKE &HFF99,8:POKE &HFF9A,63
320 X=0
330 FOR X=0 TO (A*4) STEP 4
340 POKE &HFF9D,X:EXEC 44539:NEXT X
350 SOUND 100,5:EXEC 44539:GOTO 240
                                                             