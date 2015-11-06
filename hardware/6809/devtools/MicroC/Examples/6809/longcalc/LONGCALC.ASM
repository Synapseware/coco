*#fun ltoa 14 ?1
ltoa LEAS -14,S
 LDU #temp2
 TFR U,D
 PSHS A,B
 LDD 20,S
 PSHS A,B
 JSR longcpy
 LEAS 4,S
 LDU #temp1
 TFR U,D
 PSHS A,B
 LDB 19,S
 CLRA
 PSHS A,B
 JSR longset
 LEAS 4,S
 LDD #0
 STD 0,S
?1 EQU *
 LDU #temp2
 TFR U,D
 PSHS A,B
 LDU #temp1
 TFR U,D
 PSHS A,B
 JSR longdiv
 LEAS 4,S
 LDD 0,S
 ADDD #1
 STD 0,S
 SUBD #1
 LEAU 3,S
 LEAU D,U
 PSHS U
 LDU #Longreg
 TFR U,D
 TFR D,U
 LDB ,U
 STB 4,S
 CLRA
 TFR D,X
 LDB #9
 CLRA
 JSR ?ugt
 BEQ ?5
 LDB 4,S
 ADDB #55
 BRA ?4
?5 EQU *
 LDB 4,S
 ADDB #48
?4 EQU *
 STB [,S++]
?2 EQU *
 LDU #temp2
 TFR U,D
 PSHS A,B
 JSR longtst
 LEAS 2,S
 CMPD #0
 LBNE ?1
?3 EQU *
?6 EQU *
 LDD 20,S
 ADDD #1
 STD 20,S
 SUBD #1
 TFR D,U
 PSHS U
 LDD 2,S
 SUBD #1
 STD 2,S
 LEAU 5,S
 LEAU D,U
 LDB ,U
 STB [,S++]
?7 EQU *
 LDD 0,S
 LBNE ?6
?8 EQU *
 LDU 20,S
 LDB #0
 STB ,U
 LDD 20,S
?9 EQU *
 LEAS 14,S
 RTS
*#lcl stack 33160 3 1 11
*#lcl c 33152 2
*#lcl sp 33024 0
*#lcl base 41344 0
*#lcl n1 41345 2
*#lcl string 41345 4
*#end
*#fun atol 1 ?2
atol LEAS -1,S
 LDD 5,S
 PSHS A,B
 LDD #0
 PSHS A,B
 JSR longset
 LEAS 4,S
?10 EQU *
 LDD 7,S
 ADDD #1
 STD 7,S
 SUBD #1
 TFR D,U
 LDB ,U
 STB 0,S
 LBEQ ?11
 LDB 0,S
 CLRA
 PSHS A,B
 JSR isdigit
 LEAS 2,S
 CMPD #0
 LBEQ ?12
 LDB 0,S
 SUBB #48
 STB 0,S
 JMP ?13
?12 EQU *
 LDB 0,S
 CLRA
 TFR D,X
 LDB #97
 CLRA
 JSR ?uge
 LBEQ ?14
 LDB 0,S
 SUBB #87
 STB 0,S
 JMP ?15
?14 EQU *
 LDB 0,S
 CLRA
 TFR D,X
 LDB #65
 CLRA
 JSR ?uge
 LBEQ ?16
 LDB 0,S
 SUBB #55
 STB 0,S
 JMP ?17
?16 EQU *
 JMP ?11
?17 EQU *
?15 EQU *
?13 EQU *
 LDB 0,S
 CLRA
 TFR D,X
 LDB 4,S
 CLRA
 JSR ?uge
 LBEQ ?18
 JMP ?11
?18 EQU *
 LDU #temp1
 TFR U,D
 PSHS A,B
 LDB 6,S
 CLRA
 PSHS A,B
 JSR longset
 LEAS 4,S
 LDD 5,S
 PSHS A,B
 LDU #temp1
 TFR U,D
 PSHS A,B
 JSR longmul
 LEAS 4,S
 LDU #temp1
 TFR U,D
 PSHS A,B
 LDB 2,S
 CLRA
 PSHS A,B
 JSR longset
 LEAS 4,S
 LDD 5,S
 PSHS A,B
 LDU #temp1
 TFR U,D
 PSHS A,B
 JSR longadd
 LEAS 4,S
 JMP ?10
?11 EQU *
 LDB 0,S
 CLRA
?19 EQU *
 LEAS 1,S
 RTS
*#lcl c 33152 0
*#lcl base 41344 0
*#lcl n1 41345 2
*#lcl string 41345 4
*#end
*#fun main 4 ?3
main LEAS -4,S
?20 EQU *
 LDD #?0+0
 PSHS A,B
 JSR putstr
 LEAS 2,S
 LDB #61
 STB 1,S
?21 EQU *
 LDU #buffer
 TFR U,D
 STD 2,S
?22 EQU *
?23 EQU *
 JSR getch
 STB 0,S
 PSHS A,B
 JSR isdigit
 LEAS 2,S
 CMPD #0
 LBEQ ?24
 LDB 0,S
 CLRA
 PSHS A,B
 JSR putch
 LEAS 2,S
 LDD 2,S
 ADDD #1
 STD 2,S
 SUBD #1
 TFR D,U
 LDB 0,S
 STB ,U
 JMP ?23
?24 EQU *
 LDU 2,S
 LDB #0
 STB ,U
 LDU #buffer
 TFR U,D
 PSHS A,B
 LDU #temp2
 TFR U,D
 PSHS A,B
 LDD #10
 PSHS A,B
 JSR atol
 LEAS 6,S
 LDB 1,S
 CLRA
 LDU #?26
 JMP ?switch
?27 EQU *
 LDU #reg
 TFR U,D
 PSHS A,B
 LDU #temp2
 TFR U,D
 PSHS A,B
 JSR longcpy
 LEAS 4,S
 JMP ?25
?28 EQU *
 LDU #reg
 TFR U,D
 PSHS A,B
 LDU #temp2
 TFR U,D
 PSHS A,B
 JSR longadd
 LEAS 4,S
 JMP ?25
?29 EQU *
 LDU #reg
 TFR U,D
 PSHS A,B
 LDU #temp2
 TFR U,D
 PSHS A,B
 JSR longsub
 LEAS 4,S
 JMP ?25
?30 EQU *
 LDU #reg
 TFR U,D
 PSHS A,B
 LDU #temp2
 TFR U,D
 PSHS A,B
 JSR longmul
 LEAS 4,S
 JMP ?25
?31 EQU *
 LDU #reg
 TFR U,D
 PSHS A,B
 LDU #temp2
 TFR U,D
 PSHS A,B
 JSR longdiv
 LEAS 4,S
 JMP ?25
?32 EQU *
 LDU #reg
 TFR U,D
 PSHS A,B
 LDU #temp2
 TFR U,D
 PSHS A,B
 JSR longdiv
 LEAS 4,S
 LDU #reg
 TFR U,D
 PSHS A,B
 LDU #Longreg
 TFR U,D
 PSHS A,B
 JSR longcpy
 LEAS 4,S
 JMP ?25
?26 EQU *
 FDB ?32,37,?31,47,?30,42,?29,45,?28,43,?27,61,0
 FDB ?25
?25 EQU *
?33 EQU *
 LDB 0,S
 CLRA
 PSHS A,B
 JSR putch
 LEAS 2,S
 LDB 0,S
 CLRA
 LDU #?35
 JMP ?switch
?36 EQU *
 LDD #?0+8
 PSHS A,B
 JSR putstr
 LEAS 2,S
?37 EQU *
?38 EQU *
 JMP ?20
?39 EQU *
 LDU #buffer
 TFR U,D
 PSHS A,B
 LDU #reg
 TFR U,D
 PSHS A,B
 LDD #10
 PSHS A,B
 JSR ltoa
 LEAS 6,S
 LDU #buffer
 TFR U,D
 PSHS A,B
 JSR putstr
 LEAS 2,S
 JSR getch
 STB 0,S
 PSHS A,B
 JSR isdigit
 LEAS 2,S
 CMPD #0
 LBEQ ?40
 LDB #61
 STB 1,S
 LDD #10
 PSHS A,B
 JSR putch
 LEAS 2,S
 LDB 0,S
 CLRA
 PSHS A,B
 JSR putch
 LEAS 2,S
 LDU #buffer
 TFR U,D
 STD 2,S
 LDD 2,S
 ADDD #1
 STD 2,S
 SUBD #1
 TFR D,U
 LDB 0,S
 STB ,U
 JMP ?22
?40 EQU *
 JMP ?33
?41 EQU *
?42 EQU *
?43 EQU *
?44 EQU *
?45 EQU *
 LDB 0,S
 STB 1,S
 JMP ?34
?35 EQU *
 FDB ?45,37,?44,47,?43,42,?42,45,?41,43,?39,61,?38
 FDB 67,?37,99,0,?36
?34 EQU *
 JMP ?21
 LEAS 4,S
 RTS
*#lcl operate 32816 33
*#lcl next1 32816 22
*#lcl next 32816 21
*#lcl clear 32816 20
*#lcl ptr 32897 2
*#lcl op 33152 1
*#lcl c 33152 0
*#end
?0 FCB 10,82,101,97,100,121,10,0,32,85,115,101,58,32,43,32
 FCB 45,32,42,32,47,32,37,32,61,32,67,0
$DD:reg 4
$DD:temp1 4
$DD:temp2 4
$DD:buffer 11
$EX:Longreg
$EX:longcpy
$EX:longset
$EX:longdiv
$EX:longtst
$EX:isdigit
$EX:longmul
$EX:longadd
$EX:putstr
$EX:getch
$EX:putch
$EX:longsub
*#gbl printf 5168 0
*#gbl sprintf 5168 0
*#gbl concat 5168 0
*#gbl reg 32904 0 1 4
*#gbl temp1 32904 0 1 4
*#gbl temp2 32904 0 1 4
*#gbl buffer 32904 0 1 11
*#gbl Longreg 37000 0 1 0
*#gbl ltoa 32945 0
*#gbl longcpy 36912 0
*#gbl longset 36912 0
*#gbl longdiv 36912 0
*#gbl longtst 36912 0
*#gbl atol 32944 0
*#gbl isdigit 36912 0
*#gbl longmul 36912 0
*#gbl longadd 36912 0
*#gbl main 48 0
*#gbl putstr 36912 0
*#gbl getch 36912 0
*#gbl putch 36912 0
*#gbl longsub 36912 0
