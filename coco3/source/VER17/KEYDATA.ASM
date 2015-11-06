        TITLE Data Tables for CoCo 3 Emulator Keyboard Customizer

        ASSUME CS:CUST_SEG,DS:CUST_SEG

        PUBLIC NAMES,COORDS,USED,COORDS_END

CUST_SEG SEGMENT PUBLIC 'B1_MENU'

;Names of PC keys.  1=skip scan code, 2=end of list
NAMES   DB 'ESCape',0,'1 !',0,'2 @',0,'3 #',0,'4 $',0,'5 %',0,'6 ^',0,'7 &',0
        DB '8 *',0,'9 (',0,'0 )',0,'- _',0,'= +',0,'Back space',0,'TAB',0
        DB 'Q',0,'W',0,'E',0,'R',0,'T',0,'Y',0,'U',0,'I',0,'O',0,'P',0
        DB '[ {',0,'] }',0,'ENTER',0,'CTRL',0,'A',0,'S',0,'D',0,'F',0,'G',0
        DB 'H',0,'J',0,'K',0,'L',0,'; :',0,39,' "',0,'` ~',0,1,0,'\ |',0
        DB 'Z',0,'X',0,'C',0,'V',0,'B',0,'N',0,'M',0,', <',0,'. >',0,'/ ?',0
        DB 1,0,'* PRINT SCREEN',0,'ALT',0,'Space bar',0,'CAPS',0,1,0
        DB 1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,'SCROLL LOCK',0
        DB 'HOME',0,'Up arrow',0,'PG UP',0,'Num -',0
        DB 'Left arrow',0,'Num 5 (LOCK off)',0,'Right arrow',0,'Num +',0
        DB 'END',0,'Down arrow',0,'PG DN',0,'INSert',0
        DB 'DELete',0
        DB 'Num 7',0,'Num 8',0,'Num 9',0,1,0,'Num 4',0
        DB 'Num 5',0,'Num 6',0,1,0
        DB 'Num 1',0,'Num 2',0,'Num 3',0,'Num 0',0,'Num .'
        DB 0,'F11',0,'F12',0,' ',0,' ',0,' ',0

;Used scancodes
USED    DB 01H,02H,03H,04H,05H,06H,07H,08H,09H,0AH,0BH,0CH,0DH,0EH,0FH,10H,11H
        DB 12H,13H,14H,15H,16H,17H,18H,19H,1AH,1BH,1CH,1DH,1EH,1FH,20H,21H,22H
        DB 23H,24H,25H,26H,27H,28H,29H,2BH,2CH,2DH,2EH,2FH,30H,31H,32H,33H,34H
        DB 35H,37H,38H,39H,3AH,46H,47H,48H,4AH,49H,4BH,4CH,4DH,4EH,4FH,50H,51H
        DB 52H,53H,54H,55H,56H,58H,59H,5AH,5CH,5DH,5EH,5FH,60H,61H,62H,63H,64H

;Keyboard icon's key coordinates.  byte 0=X, 1=Y, 2=width, 3-5=name, 6=matrix
; coordinate
COORDS  DB 49,3,7,'N/A',8
        DB 5,6,3,'1 !',41H
        DB 9,6,3,'2 "',42H
        DB 13,6,3,'3 #',43H
        DB 17,6,3,'4 $',44H
        DB 21,6,3,'5 %',45H
        DB 25,6,3,'6 &',46H
        DB 29,6,3,'7 ',39,47H
        DB 33,6,3,'8 (',50H
        DB 37,6,3,'9 )',51H
        DB 41,6,3,' 0 ',40H
        DB 45,6,3,': *',52H
        DB 49,6,3,'- =',55H
        DB 53,6,3,'BRK',62H
        DB 1,8,3,'ALT',63H
        DB 5,8,3,' Q ',21H
        DB 9,8,3,' W ',27H
        DB 13,8,3,' E ',05H
        DB 17,8,3,' R ',22H
        DB 21,8,3,' T ',24H
        DB 25,8,3,' Y ',31H
        DB 29,8,3,' U ',25H
        DB 33,8,3,' I ',11H
        DB 37,8,3,' O ',17H
        DB 41,8,3,' P ',20H
        DB 45,8,3,' @ ',00H
        DB 49,8,3,'CLR',61H
        DB 53,8,3,' ',24,' ',33H
        DB 1,10,3,'CTL',64H
        DB 5,10,3,' A ',01H
        DB 9,10,3,' S ',23H
        DB 13,10,3,' D ',04H
        DB 17,10,3,' F ',06H
        DB 21,10,3,' G ',07H
        DB 25,10,3,' H ',10H
        DB 29,10,3,' J ',12H
        DB 33,10,3,' K ',13H
        DB 37,10,3,' L ',14H
        DB 41,10,3,'; +',53H
        DB 45,10,3,'ENT',60H
        DB 49,10,3,' ',27,' ',35H
        DB 53,10,3,' ',26,' ',36H
        DB 5,12,3,' Z ',32H
        DB 9,12,3,' X ',30H
        DB 13,12,3,' C ',03H
        DB 17,12,3,' V ',26H
        DB 21,12,3,' B ',02H
        DB 25,12,3,' N ',16H
        DB 29,12,3,' M ',15H
        DB 33,12,3,', <',54H
        DB 37,12,3,'. >',56H
        DB 41,12,3,'/ ?',57H
        DB 53,12,3,' ',25,' ',34H
        DB 13,14,23,'SPC',37H
        DB 49,14,3,'F1 ',65H
        DB 53,14,3,'F2 ',66H
COORDS_END DB 0

CUST_SEG ENDS

        END

