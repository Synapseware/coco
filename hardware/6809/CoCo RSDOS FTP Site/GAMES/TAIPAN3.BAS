
1 HBUFF1,2099
2 CLEAR200:WIDTH40:CMP:CLS1:FORI=0TO6:FORJ=0TO1:READ S(I,J):NEXTJ,I:ATTR4,0:PRINT:PRINT:PRINT"     Want to use the Hi-speed poke";:INPUTQ$:IFQ$="Y"ORQ$="y"THEN POKE65497,0 ELSE POKE65496,0
3 LOCATE10,5:PRINT"[R]GB OR [C]OMPOSITE?";:PR$="T2V31O4L32C":PLAYPR$
4 MR$=INKEY$
5 IF MR$="R"OR MR$="r"THEN RGB ELSE IF MR$="C"OR MR$="c"THEN CMP ELSE 4
6 PALETTE0,0:IF MR$="C"OR MR$="c"THEN PALETTE2,59:PALETTE3,38:PALETTE5,0
7 FORX=&HFFB1 TO &HFFB7:POKEX+8,PEEK(X)-64:NEXTX
8 LO$(1)="Hong Kong ":LO$(2)="Shanghai "
9 LO$(3)="Nagasaki ":LO$(4)="Saigon   "
10 LO$(5)="Manila   ":LO$(6)="Singapore":LO$(7)="Batavia  ":LO$(8)="At sea   ":GOTO15
11 FORT=0TO2000:NEXT
12 FORT=0TO1000:NEXT
13 FORT=0TO500:NEXT:RETURN
14 FORT=0TO100:NEXT:RETURN
15 GOSUB275:GOSUB289
16 A1$=STRING$(13," "):S$=STRING$(40,CHR$(124))
17 HSCREEN0:CLS3:ATTR1,0:CLS:LOCATE10,7:PRINT"Enter level of experience:":PRINT:PRINTTAB(10)"1=Land lubber":PRINTTAB(10)"2=Apprentice seaman":PRINTTAB(10)"3=Old sea dog":PRINTTAB(10);:PLAYPR$:INPUTDL:IFDL<1 OR DL>3 THEN17ELSEDL=64/2^DL
18 L=1:D0=5000:MO=1:YE=1860:CA=500:MW=50:SH=MW
19 ATTR4,0:CLS:LOCATE10,7:PRINT"What will you name":PRINTTAB(10)"your hong (firm)":PRINTTAB(10);:PLAYPR$:INPUTA$:A$=A$+RIGHT$(A1$,LEN(A1$)-LEN(A$))
20 GOSUB263:CLS:ATTR2,5:GOSUB257:GOTO39
21 ATTR0,0:FORX=15TO21:LOCATE0,X:PRINT STRING$(40," ");:NEXTX:LOCATE0,0:ATTR2,5
22 LOCATE0,12:PRINTS$;
23 LOCATE0,0:PRINT"Hong: ";A$;:LOCATE20,0:PRINT"Date:";
24 LOCATE0,1:ATTR2,0,U:PRINT"Warehouse";:LOCATE20,1:ATTR1,0,U:PRINT"Hold";:ATTR3,0:PRINT"       Guns:"
25 LOCATE2,3:ATTR2,0:PRINT"Opium:":LOCATE22,3:ATTR1,0:PRINT"Opium:"
26 LOCATE2,4:ATTR2,0:PRINT"Silk:":LOCATE22,4:ATTR1,0:PRINT"Silk:"
27 LOCATE2,6:ATTR2,0:PRINT"Arms:":LOCATE22,6:ATTR1,0:PRINT"Arms:"
28 LOCATE2,7:ATTR2,0:PRINT"General:":LOCATE22,7:ATTR1,0:PRINT"General:"
29 LOCATE0,9:ATTR4,0:PRINT"Bank:":LOCATE20,9:PRINT"Cash:"
30 LOCATE0,10:ATTR7,0:PRINT"Debt:":LOCATE20,10:ATTR4,0:PRINT"Location:"
31 RETURN
32 GP=GP*10: PRINT"Famine in South China, Taipan!":PRINT"General cargo prices":PRINT"have risen toward Heaven!!";:RETURN
33 OK=OK*10:PRINT"Taipan!! A fire has swept":PRINT LO$(L);" and the price of":PRINT"opium has leaped because of":PRINT"hospital use!";:RETURN
34 SP=SP*10:PRINT"The ";LO$(L);" wharves have":PRINT"been burned by rebel samurai,":PRINT"Taipan!! All silk was destroyed";:RETURN
35 SP=SP/5:PRINT"A rival hong has dumped surplus":PRINT"silk on the market in":PRINT LO$(L);"!!";:RETURN
36 AP=AP*10:PRINT"Taipan, an agent for the Moro":PRINT"rebels is buying arms at high":PRINT"prices!! Arms are sky-high here!";:RETURN
37 OK=OK/5:PRINT"Taipan, a Yankee captian is":PRINT"selling Turkish opium below":PRINT"the British price in ";LO$(L);"!";:RETURN
38 GP=GP/10:PRINT"Malay pirates have flooded ":PRINT LO$(L);" with cheap general":PRINT"cargo from their booty, Taipan!";:RETURN
39 BA=INT(BA+(BA/24)):D0=INT(D0+(D0/10)):MO=MO+1:TI=TI+1:IF MO>12 THEN YE=YE+1:MO=1:GOTO48:ELSE48
40 LOCATE26,0:ATTR2,5:PRINT MO;"/";YE;"  ";
41 LOCATE11,3:ATTR2,0:PRINT OW;:LOCATE31,3:ATTR1,0:PRINT OC;
42 LOCATE11,4:ATTR2,0:PRINT SW;:LOCATE31,4:ATTR1,0:PRINT SC;
43 LOCATE11,6:ATTR2,0:PRINT AW;:LOCATE31,6:ATTR1,0:PRINT AC;
44 LOCATE11,7:ATTR2,0:PRINT GW;:LOCATE31,7:ATTR1,0:PRINT GC;
45 LOCATE5,9:ATTR4,0:PRINT BA;:LOCATE5,10:ATTR7,0:PRINT D0;:LOCATE25,9:ATTR4,0:PRINT INT(CA);:LOCATE30,10:PRINT LO$(L);
46 LOCATE25,1:ATTR1,0:PRINT MW;:LOCATE36,1:ATTR3,0:PRINT GN;:ATTR4,0
47 RETURN
48 ON L GOSUB 53,54,55,56,57,58,59
49 IFL=8THENGOSUB176:L=LD:LOCATE30,10:PRINT LO$(L);:ON L GOSUB53,54,55,56,57,58,59
50 IFL=1THENGOSUB154
51 GOSUB241:GOSUB52:GOSUB212:GOTO60
52 IF RND(100)<8 THEN LOCATE0,15:PRINT"";:ON L GOSUB 32,33,34,35,36,37,38:GOSUB11:GOSUB257:RETURN ELSE RETURN
53 OK=15000:SP=1300:AP=150:GP=10:RETURN
54 OK=16000:SP=1400:AP=160:GP=11:RETURN
55 OK=14000:SP=1500:AP=100:GP=12:RETURN
56 OK=13000:SP=1600:AP=110:GP=13:RETURN
57 OK=12000:SP=1000:AP=120:GP=14:RETURN
58 OK=10000:SP=1100:AP=130:GP=15:RETURN
59 OK=11000:SP=1200:AP=140:GP=16:RETURN
60 IFRND(DL)=1THENBR=0:GOSUB202 :GOSUB152ELSEGOSUB152
61 LOCATE0,19:PRINT"Shall I buy, sell, or quit";:INPUTQ$:IF Q$="B"ORQ$="b"THEN62 ELSEIFQ$="S"ORQ$="s"THEN63 ELSEIFQ$="Q"ORQ$="q"THEN90 ELSE61
62 LOCATE0,19:PRINT"What do you wish me to buy ";:INPUTQ$:IFQ$="O"ORQ$="o"THEN64ELSEIFQ$="S"ORQ$="s"THEN72ELSEIFQ$="A"ORQ$="a"THEN78ELSEIFQ$="G"ORQ$="g"THEN84ELSE62
63 LOCATE0,19:PRINT"What item shall I sell     ";:INPUTQ$:IFQ$="O"ORQ$="o"THEN68ELSEIFQ$="S"ORQ$="s"THEN74ELSEIFQ$="A"ORQ$="a"THEN80ELSEIFQ$="G"ORQ$="g"THEN86ELSE63
64 TG$="opium":TP=OK:GOSUB248:INPUTOB$
65 IF OB$="A"OR OB$="a" THEN OB=INT(CA/OK):GOTO67 ELSE OB=VAL(OB$)
66 IF OB*OK>CA OR OB<0 THEN64
67 CA=CA-OB*OK:OC=OC+OB:MW=MW-OB:GOSUB255:GOTO61
68 TG$="opium":GOSUB251:INPUTOS$
69 IF OS$="A"OR OS$="a" THEN OS=OC:GOTO71 ELSE OS=VAL(OS$)
70 IF OS>OC OR OS<0 THEN68
71 CA=CA+OS*OK:OC=OC-OS:MW=MW+OS:GOSUB255:GOTO61
72 TG$="silk":TP=SP:GOSUB248:INPUTSB$:IFS$="A"OR SB$="a"THEN SB=INT(CA/SP)ELSE SB=VAL(SB$):IFSB*SP>CA OR SB<0THEN72
73 CA=CA-SB*SP:SC=SC+SB:MW=MW-SB:GOSUB255:GOTO61
74 TG$="silk":GOSUB251:INPUTSS$
75 IF SS$="A"ORSS$="a" THEN SS=SC: GOTO77 ELSE SS=VAL(SS$)
76 IF SS>SC OR SS<0 THEN74
77 CA=CA+SS*SP:SC=SC-SS:MW=MW+SS:GOSUB255:GOTO61
78 TG$="arms":TP=AP:GOSUB248:INPUTAY$:IFAY$="A"ORAY$="a"THENAY=INT(CA/AP)ELSEAY=VAL(AY$):IFAY*AP>CA ORAY<0THEN78
79 CA=CA-AY*AP:AC=AC+AY:MW=MW-AY:GOSUB255:GOTO61
80 TG$="arms":GOSUB251:INPUTAZ$
81 IF AZ$="A"ORAZ$="a" THEN AZ=AC: GOTO83 ELSE AZ=VAL(AZ$)
82 IF AZ>AC OR AZ<0 THEN80
83 CA=CA+AZ*AP:AC=AC-AZ:MW=MW+AZ:GOSUB255:GOTO61
84 TG$="general":TP=GP:GOSUB248:INPUTGB$:IFGB$="A"OR GB$="a"THENGB=INT(CA/GP)ELSEGB=VAL(GB$):IFGB*GP>CA OR GB<0THEN84
85 CA=CA-GB*GP:GC=GC+GB:MW=MW-GB:GOSUB255:GOTO61
86 TG$="general":GOSUB251:INPUTGS$
87 IF GS$="A"ORGS$="a" THEN GS=GC: GOTO89 ELSE GS=VAL(GS$)
88 IF GS>GC OR GS<0 THEN86
89 CA=CA+GS*GP:GC=GC-GS:MW=MW+GS:GOSUB255:GOTO61
90 IF OW=0 AND SW=0 AND AW=0 AND GW=0 AND OC=0 AND SC=0 AND AC=0 AND GC=0 OR L<>1 THEN 125
91 LOCATE0,19:PRINT"Do you wish to transfer cargo";:INPUTTR$:IFTR$<>"Y"AND TR$<>"y"THEN125
92 IF OC=0 THEN96 ELSE TG$="opium":GOSUB252:INPUTO1$
93 IF O1$="A"OR O1$="a" THEN O1=OC: GOTO95 ELSE O1=VAL(O1$)
94 IF O1>OC THEN 92
95 OW=OW+O1:OC=OC-O1:MW=MW+O1:GOSUB255
96 IF OW=0 THEN100 ELSE TG$="opium": GOSUB253: INPUTO2$
97 IF O2$="A"OR O2$="a" THEN O2=OW: GOTO99 ELSE O2=VAL(O2$)
98 IF O2>OW THEN96
99 OC=OC+O2:OW=OW-O2:MW=MW-O2:GOSUB255
100 IF SC=0 THEN104 ELSE TG$="silk":GOSUB252:INPUTS3$
101 IF S3$="A"OR S3$="a" THEN S3=SC:GOTO103 ELSE S3=VAL(S3$)
102 IF S3>SC THEN 100
103 SW=SW+S3:SC=SC-S3:MW=MW+S3:GOSUB255
104 IF SW=0 THEN108 ELSE TG$="silk":GOSUB253:INPUTS4$
105 IF S4$="A"OR S4$="a" THEN S4=SW:GOTO107 ELSE S4=VAL(S4$)
106 IF S4>SW THEN 104
107 SW=SW-S4:SC=SC+S4:MW=MW-S4:GOSUB255
108 IF AC=0 THEN112 ELSE TG$="arms":GOSUB252:INPUTA1$
109 IF A1$="A"OR A1$="a" THEN A1=AC:GOTO111 ELSE A1=VAL(A1$)
110 IF A1>AC THEN108
111 AW=AW+A1:AC=AC-A1:MW=MW+A1:GOSUB255
112 IF AW=0 THEN116 ELSE TG$="arms":GOSUB253:INPUTA2$
113 IF A2$="A"OR A2$="a" THEN A2=AW:GOTO115 ELSE A2=VAL(A2$)
114 IF A2>AW THEN112
115 AW=AW-A2:AC=AC+A2:MW=MW-A2:GOSUB255
116 IF GC=0 THEN120 ELSE TG$="general":GOSUB252:INPUTG1$
117 IF G1$="A"OR G1$="a" THEN G1=GC: GOTO119 ELSE G1=VAL(G1$)
118 IF G1>GC THEN 116
119 GW=GW+G1:GC=GC-G1:MW=MW+G1:GOSUB255
120 IF GW=0 THEN124 ELSE TG$="general":GOSUB253:INPUTG2$
121 IF G2$="A"OR G2$="a" THEN G2=GW:GOTO123 ELSE G2=VAL(G2$)
122 IF G2>GW THEN120
123 GW=GW-G2:GC=GC+G2:MW=MW-G2:GOSUB255
124 GOSUB153:GOTO61
125 IFL=8THEN132 ELSEIF L=1 THENLOCATE0,19:PRINT"Do you wish to return to the bank";:INPUTQ$: IF Q$="Y"OR Q$="y" THENGOSUB155
126 IF MW<0 THENLOCATE0,19:ATTR1,0,B:PRINT"Your ship is overloaded!":ATTR4,0:GOSUB12:GOSUB153:GOTO61
127 GOSUB257:LOCATE0,15:PRINT"Do you wish to go to-":PRINT"1) Hong Kong  2) Shanghai   3) Nagasaki 4) Saigon     5) Manila     6) Singapore7) Batavia";
128 INPUTLD: LD=INT(LD)
129 IF LD=L OR LD<1 OR LD>7 THEN 127
130 L=8: GOTO39
131 L=8
132 IFLD=8THEN39ELSEL=LD:GOTO39
133 CLS:IFCK=1 THENCK=0:RETURN
134 IF SN=0 THEN CK=1:GOSUB133:RETURN
135 HSCREEN2:IFMR$="R"OR MR$="r"THEN PALETTE9,36 ELSE PALETTE9,38
136 IFSN>0THENP1=0:P2=0:GOSUB260
137 IFSN>1THENP1=106:P2=0:GOSUB260
138 IFSN>2THENP1=211:P2=0:GOSUB260
139 IFSN>3THENP1=0:P2=42:GOSUB260
140 IFSN>4THENP1=106:P2=42:GOSUB260
141 IFSN>5THENP1=211:P2=42:GOSUB260
142 IFSN>6THENP1=0:P2=84:GOSUB260
143 IFSN>7THENP1=106:P2=84:GOSUB260
144 IFSN>8THENP1=211:P2=84:GOSUB260:HCOLOR11,0:HPRINT(30,18),"PLUS MORE!"
145 LOCATE0,15:PRINT"";:RETURN
146 FORJ=1TO3:IFMR$="R"OR MR$="r"THENPALETTE9,54 ELSE PALETTE9,36
147 GOSUB268:IFMR$="R"OR MR$="r"THENPALETTE9,36 ELSE PALETTE9,38
148 GOSUB13:NEXTJ:RETURN
149 RETURN
150 FORJ=1TO1
151 LOCATE0,15:PRINT"";: GOSUB270: RETURN
152 OK=(OK/2)*RND(3):SP=(SP/2)*RND(3):AP=(AP/2)*RND(3):GP=(GP/2)*RND(3)
153 LOCATE0,15:PRINT"Present prices per unit are:":PRINT"[O]pium:";OK:LOCATE20,16:PRINT"   [S]ilk:";SP:PRINT" [A]rms:";AP:LOCATE20,17:PRINT"[G]eneral:";GP:RETURN
154 GOSUB189:GOSUB193:GOSUB163:GOSUB257:LOCATE0,15:PRINT"Do you wish to visit the bank";:INPUTQ$:IFQ$<>"Y"AND Q$<>"y"THENRETURN
155 GOSUB257:LOCATE0,15:PRINT"How much will you deposit ([A]ll)";:INPUTD$
156 IFD$="A"OR D$="a"THEND=CA:GOTO158:ELSED=VAL(D$)
157 IF D>CA THEN LOCATE0,15:PRINT"You only have";CA;"in cash.":GOSUB11:GOTO155
158 BA=BA+D:CA=CA-D
159 GOSUB257:LOCATE0,15:PRINT"How much will you withdraw ([A]ll)";:INPUTW$
160 IF W$="A"OR W$="a" THENW=BA ELSE W=VAL(W$)
161 IF W>BA THEN LOCATE0,15:PRINT"You only have";BA;"in the bank.":GOSUB11:GOTO159
162 BA=BA-W:CA=CA+W:GOSUB257:RETURN
163 IFD0>10000ANDWN<>1THEN164ELSE165
164 WN=1:GOSUB257:LOCATE0,15:PRINT"Elder Brother Wu has sent";RND(100)+50:PRINT"braves to escort you to the Wu":PRINT"mansion, Taipan.":GOSUB12:GOSUB12:GOSUB187
165 GOSUB257:LOCATE0,15:PRINT"Do you have business with Elder Brother":PRINT"Wu, the moneylender";:INPUTQ$:IFQ$<>"Y" AND Q$<>"y"THEN174
166 R=0:R$="":IF D0>0 THENGOSUB257:LOCATE0,15:PRINT"How much do you wish to repay ([A]ll)":INPUTR$:IFR$="A"OR R$="a"THEN IFCA>=D0 THEN R=D0 ELSE R=CA
167 IFR$<>"A"AND R$<>"a"THENR=VAL(R$)
168 IF R>D0 OR R<0 OR R>CA THEN166
169 D0=D0-R:CA=CA-R
170 GOSUB257:LOCATE0,15:PRINT"How much do you wish to borrow ([A]ll)":INPUTB$
171 IFB$="A"OR B$="a"THENB=2*CA:GOTO173 ELSE B=VAL(B$)
172 IF B<0 THEN170 ELSEIFB>(BA+CA)*2 THENLOCATE0,15:PRINT"He won't lend you that much!":GOSUB12:GOTO170
173 D0=D0+B:CA=CA+B
174 IFD0>20000ANDRND(5)=2THENCA=0ELSERETURN
175 GOSUB257:LOCATE0,15:ATTR3,0:PRINT"Bad joss!!!":PRINT"Two of your bodyguards have been killed":PRINT"by cutthroats and you have lost":PRINT"your cash!!!":ATTR4,0:GOSUB11:GOSUB257:RETURN
176 M1=SH:GOSUB214:IF RND(10)<9THEN179
177 GOSUB257:LOCATE0,15:ATTR3,0:PRINT"Li Yuen's pirates, Taipan!":ATTR4,0:GOSUB290:GOSUB12
178 IFBR=1THENPRINT"Good joss!! They let us be!!":GOSUB12:GOTO179ELSEGOSUB216
179 IFRND(100)<95 THEN185
180 GOSUB257:LOCATE0,15:ATTR3,0:PRINT"Storm, Taipan!!":ATTR4,0:IFRND(100)<75THEN184
181 GOSUB12:ATTR1,0,B:PRINT"We're going down!!":ATTR4,0:GOSUB25:GOSUB12
182 LOCATE0,19:PRINT"Want to give it another go";:INPUTQ$
183 IF Q$="Y"OR Q$="y" THEN GOTO2 ELSECLS:GOTO291
184 GOSUB12:PRINT"We made it!!":GOSUB12:IFRND(5)>3THENGOSUB13:L=RND(7):LD=L:PRINT"We've been blown off course to":PRINTLO$(L):GOSUB12
185 L=LD:GOSUB257:LOCATE0,15:PRINT"Arriving at ";LO$(L):GOSUB13:IFRND(5)=1THENGOSUB198
186 RETURN
187 GOSUB257:LOCATE0,15:PRINT"Elder Brother Wu reminds you to":PRINT"pay your debts."
188 GOSUB11:RETURN
189 TM=CA+BA-D0:IFTM>=1000000THENLOCATE0,15:PRINT"Do you wish to retire";:INPUTQ$ ELSE RETURN
190 IF Q$="Y"ORQ$="y" THEN LOCATE0,15:ATTR0,1,B:PRINT"Y O U ' R E   A   M I L L I O N A I R E ";:GOSUB289:ELSERETURN
191 ATTR4,0:PRINT"Your rating is";INT(TM/TI/100):PRINT"Play again";:INPUTQ$
192 IFQ$="Y"ORQ$="y"THEN GOTO2 ELSE CLS:GOTO291
193 IFBR=1THENRETURN
194 BB=INT(CA*RND(100)/100):BR=0
195 LOCATE0,15:PRINT"Li Yuen asks";BB;"in donation to the":PRINT"temple of Tin Hau, the sea goddess."
196 PRINT"Will you pay";:INPUTQ$
197 IFQ$="Y"ORQ$="y"THENCA=CA-BB:BR=1:RETURN ELSE RETURN
198 PS=1000+RND(500): IF CA>PS THEN LOCATE0,15:PRINT"Do you wish to trade your ship for one":PRINT"with 50 more capacity by paying";PS;:INPUTQ$
199 IF CA<PS THENRETURN
200 IF Q$="N"ORQ$="n"THEN201 ELSE CA=CA-PS:MW=MW+50:SH=SH+50
201 GOSUB257:RETURN
202 IF L=8 OR RND(10)<7 THEN 207
203 RB=INT(CA*RND(100)/100):CA=CA-RB:GOSUB257
204 LOCATE0,15:ATTR3,0:PRINT"Taipan, you've been beaten up"
205 PRINT"and robbed of";RB;"in cash!!":ATTR4,0
206 GOSUB11:GOSUB13:GOSUB257:RETURN
207 IF OC=0 OR L=8 THEN 213
208 OF=INT(CA*RND(100)/100): CA=CA-OF
209 LOCATE0,15:ATTR1,0:PRINT"Locals seize your opium and"
210 PRINT"fine you";OF;", Taipan!":MW=MW+OC:OC=0:GOSUB11
211 GOSUB257:RETURN
212 IFBR=0 AND RND(10)>6 AND L<>1 THEN LOCATE0,15:ATTR3,0:PRINT"Li Yuen has sent a lieutenant.":PRINT"He says his admiral wishes to see you":PRINT"in Hong Kong posthaste.":ATTR4,0:GOSUB11:GOSUB257
213 RETURN
214 IFRND(10)>1+(WZ-1)*2THENRETURN
215 SN=INT(RND(SH/20)+1):SA=SN:LOCATE0,19:ATTR3,0:PRINT"Hostile ships approaching!!":ATTR3,0:GOSUB290:GOSUB12:GOSUB133:GOTO217
216 SN=RND(SH+GN)+1:SA=SN:M1=SH:LOCATE0,15:ATTR1,0:PRINT"Ships of Li Yuen's pirate fleet":GOSUB290:GOSUB12:GOSUB133
217 GOSUB258:IFRND(2)=1THEN224
218 GOSUB13:GOSUB287:HPRINT(5,22),"They're firing on us, Taipan!":GOSUB146:GOSUB14
219 IFRND(SN)<RND(4)THENGOSUB287:HPRINT(13,22),"They missed!!":GOTO224
220 GOSUB261
221 SH=SH-RND(30):DM=INT((SH/M1)*100):GOSUB259:GOSUB287:HPRINT(12,22),"We've been hit!!":GOSUB288:HPRINT(8,23),"State of repair is"+STR$(INT(DM))+"%":GOSUB13
222 IF DM=<0 AND SH=<0 THENGOSUB13:GOSUB287:GOSUB288:HPRINT(6,22),"The buggers got us, Taipan!!":GOSUB13:HPRINT(10,23),"It's all over now!!":GOSUB270ELSE224
223 CK=1:GOSUB133:GOSUB257:GOSUB286:GOSUB287:GOSUB288:HPRINT(11,21),"Want to try again?":INPUTQ$:IFQ$="Y"ORQ$="y"THEN GOTO2 ELSE CLS:GOTO291
224 GOSUB13:IF RND(WZ*20)=1 AND BR=1 THENSN=0:GOSUB258:CK=1:GOSUB133:GOSUB287:HPRINT(4,22),"Li Yuen's fleet drove 'em off!!":GOSUB12:HSCREEN0:CLS3:ATTR0,0:CLS:GOSUB239:RETURN
225 IF GN=0THENGOSUB287:HPRINT(12,22),"Shall we [r]un?" ELSE GOSUB287:HPRINT(7,22),"Shall we [r]un or [f]ight?"
226 SOUND200,1:Q1$=INKEY$
227 Q1$="":FORT=0TO80:Q1$=INKEY$:IFQ1$=""THEN NEXT ELSET=81
228 IFQ1$="R"ORQ1$="r"THENIFRND(3)>RND(SN)THENSN=0:GOSUB287:HPRINT(9,22),"We got away from 'em!!":GOSUB12:CK=1:GOSUB133:HSCREEN0:CLS3:ATTR0,0:CLS:GOSUB239:RETURN
229 IFQ1$="R"OR Q1$="r"THEN GOSUB287:HPRINT(7,22),"Can't get away from 'em!!":GOSUB13
230 GOSUB258:IFQ1$<>"R" AND Q1$<>"r" THEN232
231 IFSN>2 AND RND(10)>9THENPU=RND(SN-1):SN=SN-PU:SA=SN:GOSUB133:GOSUB287:GOSUB288:HPRINT(0,22),"But we escaped from"+STR$(PU)+" of 'em, Taipan!!":HPRINT(7,23),"Only"+STR$(SN)+" still attacking!!":GOSUB258:GOSUB13:GOTO218
232 IFGN>0 AND(Q1$="F"ORQ1$="f")THENGOSUB287:HPRINT(8,22),"We're firing on 'em!!":GOTO233:ELSEIFGN=0 AND(Q1$="F"ORQ1$="f")THENGOSUB287:HPRINT(10,22),"With what, Taipan?!?":GOTO218ELSE233
233 IFGN=0 OR(Q1$<>"F"AND Q1$<>"f")THEN218
234 IF RND(GN)>=RND(4)/WZ THENGOSUB13:GOSUB150:GOSUB287:HPRINT(14,22),"We hit 'em!!"ELSEGOSUB13:GOSUB287:HPRINT(14,22),"Missed 'em!!":GOTO237
235 IF RND(100)>25-GN THENSN=SN-1:GOSUB13:GOSUB287:HPRINT(4,22),"The bugger's joining Davy Jones!":GOSUB12:GOSUB133:GOSUB256:GOTO237
236 GOSUB13:GOSUB287:HPRINT(12,22),"Still floating!!"
237 GOSUB258:GOSUB13:IFSN=0THENGOSUB287:HPRINT(8,22),"We've done for 'em all!!":GOSUB13:GOSUB257 ELSE218
238 GOSUB12:GOSUB287:GOSUB288:HPRINT(7,22),"We've captured some bootle,":CB=RND(10000)*SA:CA=CA+CB:HPRINT(11,23),"It's worth"+STR$(CB)+"!!":GOSUB12:HSCREEN0:CLS3:ATTR0,0:CLS:GOSUB239:RETURN
239 Q1$="":HCOLOR0,0:IFMR$="R" OR MR$="r"THENPALETTE9,54 ELSE PALETTE9,36
240 IFRND(10)<2THEN214 ELSE RETURN
241 G1=RND(1000)+500:IF G1>CA OR RND(4)>1THENRETURN
242 LOCATE0,15:PRINT"Do you wish to buy a ship's gun":PRINT"for";G1;:INPUTQ$
243 IFQ$<>"Y"AND Q$<>"y"THENRETURN
244 IFMW-10<0THENGOSUB247:RETURN
245 CA=CA-G1:GN=GN+1:MW=MW-10
246 GOSUB257:RETURN
247 LOCATE0,15:ATTR1,0:PRINT"Your ship would be overburdened":ATTR4,0:GOSUB12:RETURN
248 GOSUB255
249 LOCATE0,19:PRINT"How much ";TG$;" shall I buy"
250 LOCATE0,21:PRINT"(You can afford";INT(CA/TP);")";:RETURN
251 LOCATE0,19:PRINT"How much shall I sell [A]ll)";:RETURN
252 LOCATE0,19:PRINT"How many units of ";TG$:PRINT"move to warehouse";:RETURN
253 LOCATE0,19:PRINT"How many units of "TG$:PRINT"move aboard ship";:RETURN
254 GOTO257
255 GOSUB257:GOSUB153:RETURN
256 IFRND(10)>5 AND SN<(SA/4) AND SN>1 THEN SR=RND(SN):SN=SN-SR:GOSUB133:SA=SN:GOSUB287:HPRINT(11,22),"Ran away, Taipan!!":RETURNELSERETURN
257 GOSUB21:GOSUB40:IFL=8THENLOCATE0,13:PRINT"Captain's report:";:RETURN ELSE LOCATE0,13:PRINT"Comprador's report:";:RETURN
258 GOSUB286:HCOLOR11,0:HPRINT(0,21),"Ships attacking:"+STR$(SN):HPRINT(20,21),"Your ship's guns:"+STR$(GN):RETURN
259 IFDM<=0THENDM=0:RETURNELSERETURN
260 HPUT(P1,P2)-(98+P1,41+P2),1,PSET:RETURN:'FORI=0TO4:PRINT@PP+I*32,S$(I+1);:NEXTI:RETURN
261 CLS8:SOUND100,15
262 CLS 0: GOSUB133: RETURN
263 ATTR3,0:CLS:LOCATE10,7:PRINT"Do you want to be-":PRINTTAB(12);"1) A trader":PRINTTAB(12);"2) A pirate"
264 PRINTTAB(12);
265 PLAYPR$:INPUTWZ:IFWZ=1THENRETURN
266 IFWZ=2THEND0=0:GN=5:MW=0:CA=0:RETURN
267 GOTO263
268 SOUND10,3:RETURN
269 SOUND100,15:RETURN
270 FORII=0TO6:SOUND S(II,0),S(II,1)
271 FORJJ=1TO50:NEXT
272 IFII=3THENFORJJ=1TO100:NEXT
273 NEXTII:RETURN
274 DATA 40,8,20,4,80,20,40,8,20,4,80,4,120,20
275 HSCREEN2:CLS1
276 HSCREEN2:HCLS0:HCOLOR10:HLINE(5,70)-(100,70),PSET:HCOLOR11:HLINE(88,70)-(93,67),PSET:HLINE-(96,63),PSET:HLINE-(98,60),PSET:HLINE-(90,61),PSET:HLINE-(83,63),PSET:HLINE-(57,63),PSET:HLINE-(38,61),PSET
277 HLINE-(35,58),PSET:HLINE-(30,55),PSET:HLINE-(22,53),PSET:HLINE-(16,53),PSET:HLINE-(16,57),PSET:HLINE-(17,59),PSET:HLINE-(19,62),PSET:HLINE-(20,66),PSET:HLINE-(22,70),PSET:HLINE(18,63)-(18,67),PSET
278 HLINE-(16,70),PSET:HLINE-(87,70),PSET:HPAINT(87,67),11,11:HLINE(62,63)-(63,33),PSET:HLINE-(63,63),PSET:HCOLOR12:HLINE(70,60)-(38,57),PSET:HLINE-(45,30),PSET:HLINE-(72,38),PSET:HLINE-(70,60),PSET:HPAINT(67,54),12,12
279 HCOLOR11:HLINE(85,61)-(86,39),PSET:HLINE-(86,61),PSET:HCOLOR12:HLINE(97,58)-(87,59),PSET:HLINE-(73,57),PSET:HLINE-(79,37),PSET:HLINE-(99,46),PSET:HLINE-(98,57),PSET:HPAINT(94,53),12,12:HCOLOR11
280 HLINE(24,53)-(25,39),PSET:HLINE-(25,53),PSET:HCOLOR12:HLINE(29,49)-(12,52),PSET:HLINE-(13,37),PSET:HLINE-(30,42),PSET:HLINE-(30,49),PSET:HPAINT(28,45),12,12:HCOLOR13:HLINE(42,36)-(29,54),PSET:HLINE-(40,43),PSET
281 HLINE-(42,42),PSET:HCOLOR11:HLINE(84,63)-(86,39),PSET:HLINE(86,44)-(86,60),PSET:HLINE-(85,56),PSET:HCOLOR13:HLINE(26,39)-(40,45),PSET:HCOLOR11:HLINE(15,54)-(8,53),PSET:HCOLOR13
282 HLINE(8,52)-(11,48),PSET:HLINE(7,54)-(15,57),PSET:HLINE(72,44)-(75,47),PSET:HLINE(20,55)-(25,65),PSET:HLINE-(47,66),PSET:HLINE-(59,67),PSET:HLINE-(73,66),PSET:HLINE-(82,65),PSET
283 HLINE-(87,64),PSET:HLINE(21,54)-(23,54),PSET:HLINE-(28,63),PSET:HLINE-(43,64),PSET:HLINE-(57,65),PSET:HLINE-(72,64),PSET:HLINE-(80,63),PSET:HLINE-(88,63),PSET:HLINE-(95,61),PSET:HCOLOR9
284 HDRAW"BM61,63U1R1D1;BM67,63U1R1D1;BM51,63U1R1D1;BM56,63U1R1D1"
285 HGET(4,30)-(102,71),1:HPUT(106,0)-(204,41),1,PSET:FORX=1TO500:NEXT:HPRINT(16,10),"TAIPAN":RETURN
286 HLINE(0,168)-(320,175),PRESET,BF:RETURN
287 HLINE(0,176)-(320,183),PRESET,BF:RETURN
288 HLINE(0,184)-(320,200),PRESET,BF:RETURN
289 PLAY"T8;V31;O3;L2.;D;L4;C;O2;B-;O3;C;L2.;B-;B-;O4;B-;L4;G;E-;G;L2.;F;F;L4;B-;G;B-;A;F;A;G;E-;G;L2.;F;D;O3;L4;C;B-;C;L2.;B-;L2;B-":RETURN
290 PLAY"L8O3BCBCBCBCBC":RETURN
291 POKE65496,0:SOUND1,1:ATTR0,0:IFMR$="R"THEN RGB ELSE CMP
292 END

              