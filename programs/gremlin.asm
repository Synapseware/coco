ORG $0000
0000: 00 09       NEG   $09
0002: 32 10       LEAS  $FFF0,X
0004: 10 00       Illegal Opcode
0006: 00 04       NEG   $04
0008: 0A C3       DEC   $C3
000A: F8 59 00    EORB  $5900
000D: 04 00       LSR   $00
000F: 00 00       NEG   $00
0011: 00 00       NEG   $00
0013: 04 12       LSR   $12
0015: 9C FF       CPX   $FF
0017: 89 4C       ADCA  #$4C
0019: 00 00       NEG   $00
001B: 01          Illegal Opcode
001C: 3F          SWI   
001D: 3F          SWI   
001E: 3F          SWI   
001F: 3F          SWI   
0020: 3F          SWI   
0021: 3F          SWI   
0022: 3F          SWI   
0023: 3F          SWI   
0024: 3F          SWI   
0025: 3F          SWI   
0026: 3F          SWI   
0027: 3F          SWI   
0028: 3F          SWI   
0029: 3F          SWI   
002A: 3F          SWI   
002B: 3F          SWI   
002C: 3F          SWI   
002D: FC 01 12    LDD   $0112
0030: 2A 0C       BPL   $003E
0032: CC 00 00    LDD   #$0000
0035: FD 01 12    STD   $0112
0038: FD 10 13    STD   $1013
003B: 7E 13 14    JMP   $1314

003E: FC 10 13    LDD   $1013
0041: 7E 13 70    JMP   $1370

0044: 00 1A       NEG   $1A
0046: 50          NEGB  
0047: BE 01 0D    LDX   $010D
004A: BF 10 22    STX   $1022
004D: 8E 10 6F    LDX   #$106F
0050: BF 01 0D    STX   $010D
0053: 86 35       LDA   #$35
0055: B7 FF 03    STA   $FF03
0058: CC 00 00    LDD   #$0000
005B: FD 01 12    STD   $0112
005E: FD 10 13    STD   $1013
0061: 1C EF       ANDCC #$EF
0063: 39          RTS   

0064: FC 01 12    LDD   $0112
0067: C3 00 01    ADDD  #$0001
006A: FD 01 12    STD   $0112
006D: B6 FF 02    LDA   $FF02
0070: 3B          RTI   

0071: B7 FF C0    STA   $FFC0
0074: B7 FF C2    STA   $FFC2
0077: B7 FF C5    STA   $FFC5
007A: B6 FF 22    LDA   $FF22
007D: 8A E0       ORA   #$E0
007F: B7 FF 22    STA   $FF22
0082: 39          RTS   

0083: B7 FF C0    STA   $FFC0
0086: B7 FF C2    STA   $FFC2
0089: B7 FF C4    STA   $FFC4
008C: 34 02       PSHS  A
008E: B6 FF 22    LDA   $FF22
0091: 84 07       ANDA  #$07
0093: B7 FF 22    STA   $FF22
0096: 35 02       PULS  A
0098: 39          RTS   

0099: 34 76       PSHS  U,Y,X,B,A
009B: CE 00 00    LDU   #$0000
009E: BD 10 D6    JSR   $10D6
00A1: 35 76       PULS  A,B,X,Y,U
00A3: 39          RTS   

00A4: 34 76       PSHS  U,Y,X,B,A
00A6: CE 00 01    LDU   #$0001
00A9: BD 10 D6    JSR   $10D6
00AC: 35 76       PULS  A,B,X,Y,U
00AE: 39          RTS   

00AF: 34 76       PSHS  U,Y,X,B,A
00B1: CE 00 02    LDU   #$0002
00B4: BD 10 D6    JSR   $10D6
00B7: 35 76       PULS  A,B,X,Y,U
00B9: 39          RTS   

00BA: 34 74       PSHS  U,Y,X,B
00BC: CE 00 03    LDU   #$0003
00BF: 7F 11 A1    CLR   $11A1
00C2: BD 10 D6    JSR   $10D6
00C5: B6 11 A1    LDA   $11A1
00C8: 35 74       PULS  B,X,Y,U
00CA: 39          RTS   

00CB: BD 11 76    JSR   $1176
00CE: EC 81       LDD   ,X++
00D0: FD 11 9B    STD   $119B
00D3: 7F 11 9E    CLR   $119E
00D6: 4F          CLRA  
00D7: B0 10 18    SUBA  $1018
00DA: B7 11 9D    STA   $119D
00DD: 4F          CLRA  
00DE: E6 80       LDB   ,X+
00E0: 20 09       BRA   $00EB

00E2: A6 1F       LDA   $FFFF,X
00E4: 5F          CLRB  
00E5: 20 04       BRA   $00EB

00E7: A6 1F       LDA   $FFFF,X
00E9: E6 80       LDB   ,X+
00EB: 34 06       PSHS  B,A
00ED: B6 10 18    LDA   $1018
00F0: B7 11 9F    STA   $119F
00F3: B6 11 9D    LDA   $119D
00F6: 8B 08       ADDA  #$08
00F8: B7 11 9D    STA   $119D
00FB: 35 06       PULS  A,B
00FD: 7D 11 9F    TST   $119F
0100: 27 07       BEQ   $0109
0102: 44          LSRA  
0103: 56          RORB  
0104: 7A 11 9F    DEC   $119F
0107: 20 F4       BRA   $00FD

0109: BD 11 40    JSR   $1140
010C: B6 11 9D    LDA   $119D
010F: 8B 07       ADDA  #$07
0111: B1 11 9B    CMPA  $119B
0114: 2D D1       BLT   $00E7
0116: B6 11 9D    LDA   $119D
0119: B1 11 9B    CMPA  $119B
011C: 2D C4       BLT   $00E2
011E: 10 BE 11 97 LDY   $1197
0122: 31 A8 20    LEAY  $20,Y
0125: 10 BF 11 97 STY   $1197
0129: 7C 11 9E    INC   $119E
012C: F6 11 9E    LDB   $119E
012F: F1 11 9C    CMPB  $119C
0132: 2D A2       BLT   $00D6
0134: 39          RTS   

0135: 11 83 00 00 CMPU  #$0000
0139: 27 19       BEQ   $0154
013B: 11 83 00 01 CMPU  #$0001
013F: 27 1F       BEQ   $0160
0141: 11 83 00 02 CMPU  #$0002
0145: 27 0A       BEQ   $0151
0147: E4 A0       ANDB  ,Y+
0149: 27 05       BEQ   $0150
014B: C6 01       LDB   #$01
014D: F7 11 A1    STB   $11A1
0150: 39          RTS   

0151: E7 A0       STB   ,Y+
0153: 39          RTS   

0154: A6 A4       LDA   ,Y
0156: 53          COMB  
0157: F7 11 A0    STB   $11A0
015A: B4 11 A0    ANDA  $11A0
015D: A7 A0       STA   ,Y+
015F: 39          RTS   

0160: A6 A4       LDA   ,Y
0162: F7 11 A0    STB   $11A0
0165: BA 11 A0    ORA   $11A0
0168: A7 A0       STA   ,Y+
016A: 39          RTS   

016B: FD 11 99    STD   $1199
016E: 10 8E 04 00 LDY   #$0400
0172: 86 20       LDA   #$20
0174: 3D          MUL   
0175: 31 AB       LEAY  D,Y
0177: B6 11 99    LDA   $1199
017A: 44          LSRA  
017B: 44          LSRA  
017C: 44          LSRA  
017D: 31 A6       LEAY  A,Y
017F: 10 BF 11 97 STY   $1197
0183: B6 11 99    LDA   $1199
0186: 84 07       ANDA  #$07
0188: B7 10 18    STA   $1018
018B: 39          RTS   

018C: 04 C1       LSR   $C1
018E: 0C 02       INC   $02
0190: 08 04       ASL   $04
0192: 0C 04       INC   $04
0194: 00 C0       NEG   $C0
0196: 01          Illegal Opcode
0197: BD 11 BB    JSR   $11BB
019A: BD 11 D1    JSR   $11D1
019D: C6 98       LDB   #$98
019F: F7 10 15    STB   $1015
01A2: C6 59       LDB   #$59
01A4: F7 10 16    STB   $1016
01A7: C6 06       LDB   #$06
01A9: F7 10 17    STB   $1017
01AC: BD 11 EE    JSR   $11EE
01AF: 39          RTS   

01B0: C6 03       LDB   #$03
01B2: 8E 10 13    LDX   #$1013
01B5: 10 8E 10 27 LDY   #$1027
01B9: 1C FE       ANDCC #$FE
01BB: A6 82       LDA   ,-X
01BD: A9 A2       ADCA  ,-Y
01BF: 19          DAA   
01C0: A7 84       STA   ,X
01C2: 5A          DECB  
01C3: 26 F6       BNE   $01BB
01C5: 39          RTS   

01C6: C6 03       LDB   #$03
01C8: 8E 10 13    LDX   #$1013
01CB: 10 8E 10 1F LDY   #$101F
01CF: A6 82       LDA   ,-X
01D1: 84 0F       ANDA  #$0F
01D3: A7 A2       STA   ,-Y
01D5: A6 84       LDA   ,X
01D7: 84 F0       ANDA  #$F0
01D9: 46          RORA  
01DA: 46          RORA  
01DB: 46          RORA  
01DC: 46          RORA  
01DD: A7 A2       STA   ,-Y
01DF: 5A          DECB  
01E0: 26 ED       BNE   $01CF
01E2: 39          RTS   

01E3: 10 8E 10 19 LDY   #$1019
01E7: 7F 12 29    CLR   $1229
01EA: A6 A0       LDA   ,Y+
01EC: 4D          TSTA  
01ED: 27 05       BEQ   $01F4
01EF: 7C 12 29    INC   $1229
01F2: 20 0B       BRA   $01FF

01F4: F6 10 17    LDB   $1017
01F7: 5A          DECB  
01F8: 27 05       BEQ   $01FF
01FA: 7D 12 29    TST   $1229
01FD: 27 11       BEQ   $0210
01FF: 8E 12 A4    LDX   #$12A4
0202: C6 09       LDB   #$09
0204: 3D          MUL   
0205: 30 8B       LEAX  D,X
0207: B6 10 15    LDA   $1015
020A: F6 10 16    LDB   $1016
020D: BD 10 BA    JSR   $10BA
0210: B6 10 15    LDA   $1015
0213: 8B 10       ADDA  #$10
0215: B7 10 15    STA   $1015
0218: 7A 10 17    DEC   $1017
021B: 26 CD       BNE   $01EA
021D: 39          RTS   

021E: 01          Illegal Opcode
021F: 34 70       PSHS  U,Y,X
0221: BD 11 76    JSR   $1176
0224: BD 12 43    JSR   $1243
0227: A4 A4       ANDA  ,Y
0229: C6 06       LDB   #$06
022B: F0 10 18    SUBB  $1018
022E: 27 04       BEQ   $0234
0230: 44          LSRA  
0231: 5A          DECB  
0232: 20 FA       BRA   $022E

0234: 4C          INCA  
0235: 35 70       PULS  X,Y,U
0237: 39          RTS   

0238: B6 10 18    LDA   $1018
023B: 27 0C       BEQ   $0249
023D: 81 02       CMPA  #$02
023F: 27 0C       BEQ   $024D
0241: 81 04       CMPA  #$04
0243: 27 0C       BEQ   $0251
0245: 86 03       LDA   #$03
0247: 20 0A       BRA   $0253

0249: 86 C0       LDA   #$C0
024B: 20 06       BRA   $0253

024D: 86 30       LDA   #$30
024F: 20 02       BRA   $0253

0251: 86 0C       LDA   #$0C
0253: 39          RTS   

0254: 34 76       PSHS  U,Y,X,B,A
0256: F3 01 12    ADDD  $0112
0259: DD 8D       STD   $8D
025B: 5F          CLRB  
025C: BD A9 A2    JSR   $A9A2
025F: BD A9 76    JSR   $A976
0262: BE 10 1F    LDX   $101F
0265: 26 06       BNE   $026D
0267: 8E 12 9C    LDX   #$129C
026A: BF 10 1F    STX   $101F
026D: BE 10 1F    LDX   $101F
0270: D6 8C       LDB   $8C
0272: FB 10 21    ADDB  $1021
0275: D7 8C       STB   $8C
0277: C6 FF       LDB   #$FF
0279: E1 84       CMPB  ,X
027B: 27 F0       BEQ   $026D
027D: A6 80       LDA   ,X+
027F: BD A9 87    JSR   $A987
0282: DE 8D       LDU   $8D
0284: 11 B3 01 12 CMPU  $0112
0288: 26 ED       BNE   $0277
028A: 4F          CLRA  
028B: BD A9 78    JSR   $A978
028E: 35 76       PULS  A,B,X,Y,U
0290: 39          RTS   

0291: 02          Illegal Opcode
0292: 42          Illegal Opcode
0293: 7E FE C2    JMP   $FEC2

0296: 82 FF       SBCA  #$FF
0298: FF 08 07    STU   $0807
029B: 14          Illegal Opcode
029C: 41          Illegal Opcode
029D: 41          Illegal Opcode
029E: 41          Illegal Opcode
029F: 41          Illegal Opcode
02A0: 41          Illegal Opcode
02A1: 14          Illegal Opcode
02A2: 08 07       ASL   $07
02A4: 10 50       Illegal Opcode
02A6: 10 10       Illegal Opcode
02A8: 10 10       Illegal Opcode
02AA: 54          LSRB  
02AB: 08 07       ASL   $07
02AD: 14          Illegal Opcode
02AE: 41          Illegal Opcode
02AF: 01          Illegal Opcode
02B0: 01          Illegal Opcode
02B1: 04 10       LSR   $10
02B3: 55          Illegal Opcode
02B4: 08 07       ASL   $07
02B6: 14          Illegal Opcode
02B7: 41          Illegal Opcode
02B8: 01          Illegal Opcode
02B9: 04 01       LSR   $01
02BB: 41          Illegal Opcode
02BC: 14          Illegal Opcode
02BD: 08 07       ASL   $07
02BF: 40          NEGA  
02C0: 40          NEGA  
02C1: 44          LSRA  
02C2: 55          Illegal Opcode
02C3: 04 04       LSR   $04
02C5: 04 08       LSR   $08
02C7: 07 55       ASR   $55
02C9: 40          NEGA  
02CA: 54          LSRB  
02CB: 41          Illegal Opcode
02CC: 01          Illegal Opcode
02CD: 41          Illegal Opcode
02CE: 14          Illegal Opcode
02CF: 08 07       ASL   $07
02D1: 14          Illegal Opcode
02D2: 41          Illegal Opcode
02D3: 40          NEGA  
02D4: 54          LSRB  
02D5: 41          Illegal Opcode
02D6: 41          Illegal Opcode
02D7: 14          Illegal Opcode
02D8: 08 07       ASL   $07
02DA: 55          Illegal Opcode
02DB: 41          Illegal Opcode
02DC: 01          Illegal Opcode
02DD: 04 10       LSR   $10
02DF: 10 10       Illegal Opcode
02E1: 08 07       ASL   $07
02E3: 14          Illegal Opcode
02E4: 41          Illegal Opcode
02E5: 41          Illegal Opcode
02E6: 14          Illegal Opcode
02E7: 41          Illegal Opcode
02E8: 41          Illegal Opcode
02E9: 14          Illegal Opcode
02EA: 08 07       ASL   $07
02EC: 14          Illegal Opcode
02ED: 41          Illegal Opcode
02EE: 41          Illegal Opcode
02EF: 15          Illegal Opcode
02F0: 01          Illegal Opcode
02F1: 41          Illegal Opcode
02F2: 14          Illegal Opcode
02F3: FF 4A BD    STU   $4ABD
02F6: 10 50       Illegal Opcode
02F8: 86 02       LDA   #$02
02FA: B7 18 E4    STA   $18E4
02FD: BD 13 A0    JSR   $13A0
0300: CC 00 00    LDD   #$0000
0303: BD 14 C7    JSR   $14C7
0306: BD 13 BA    JSR   $13BA
0309: FC 01 12    LDD   $0112
030C: FD 10 13    STD   $1013
030F: BD 14 DD    JSR   $14DD
0312: 7D 18 F6    TST   $18F6
0315: 26 6D       BNE   $0384
0317: 7D 18 D5    TST   $18D5
031A: 26 05       BNE   $0321
031C: BD 16 76    JSR   $1676
031F: 20 03       BRA   $0324

0321: BD 16 A6    JSR   $16A6
0324: AD 9F A0 00 JSR   [$A000,X]
0328: 26 02       BNE   $032C
032A: 20 36       BRA   $0362

032C: B7 18 E5    STA   $18E5
032F: 81 20       CMPA  #$20
0331: 27 0D       BEQ   $0340
0333: 81 03       CMPA  #$03
0335: 27 3B       BEQ   $0372
0337: 81 53       CMPA  #$53
0339: 26 0A       BNE   $0345
033B: BD 13 A0    JSR   $13A0
033E: 20 22       BRA   $0362

0340: BD 18 54    JSR   $1854
0343: 20 1D       BRA   $0362

0345: 81 13       CMPA  #$13
0347: 27 13       BEQ   $035C
0349: 81 08       CMPA  #$08
034B: 25 15       BCS   $0362
034D: 81 5E       CMPA  #$5E
034F: 27 04       BEQ   $0355
0351: 81 0A       CMPA  #$0A
0353: 22 0D       BHI   $0362
0355: 86 01       LDA   #$01
0357: B7 18 E3    STA   $18E3
035A: 20 06       BRA   $0362

035C: AD 9F A0 00 JSR   [$A000,X]
0360: 27 FA       BEQ   $035C
0362: 7E 10 38    JMP   $1038

0365: F3 18 F2    ADDD  $18F2
0368: 25 9F       BCS   $0309
036A: 10 B3 01 12 CMPD  $0112
036E: 24 F2       BCC   $0362
0370: 20 97       BRA   $0309

0372: BD 10 8E    JSR   $108E
0375: 1A 50       ORCC  #$50
0377: 0F 8D       CLR   $8D
0379: 0F 8E       CLR   $8E
037B: BE 10 22    LDX   $1022
037E: BF 01 0D    STX   $010D
0381: 1C EF       ANDCC #$EF
0383: 39          RTS   

0384: AD 9F A0 00 JSR   [$A000,X]
0388: 27 FA       BEQ   $0384
038A: 81 03       CMPA  #$03
038C: 27 E4       BEQ   $0372
038E: 81 0D       CMPA  #$0D
0390: 26 F2       BNE   $0384
0392: 16 FF 6B    LBRA  $0300

0395: 7C 18 E4    INC   $18E4
0398: B6 18 E4    LDA   $18E4
039B: 84 03       ANDA  #$03
039D: 48          ASLA  
039E: 48          ASLA  
039F: 48          ASLA  
03A0: C6 E7       LDB   #$E7
03A2: F4 FF 22    ANDB  $FF22
03A5: F7 FF 22    STB   $FF22
03A8: BA FF 22    ORA   $FF22
03AB: B7 FF 22    STA   $FF22
03AE: 39          RTS   

03AF: BD 10 7C    JSR   $107C
03B2: 7F 18 F6    CLR   $18F6
03B5: 7F 18 E3    CLR   $18E3
03B8: 7F 10 1F    CLR   $101F
03BB: 7F 10 20    CLR   $1020
03BE: 86 FF       LDA   #$FF
03C0: B7 10 21    STA   $1021
03C3: 7F 10 10    CLR   $1010
03C6: 7F 10 11    CLR   $1011
03C9: 7F 10 12    CLR   $1012
03CC: BD 11 D1    JSR   $11D1
03CF: C6 98       LDB   #$98
03D1: F7 10 15    STB   $1015
03D4: C6 59       LDB   #$59
03D6: F7 10 16    STB   $1016
03D9: C6 06       LDB   #$06
03DB: F7 10 17    STB   $1017
03DE: BD 11 EE    JSR   $11EE
03E1: 86 03       LDA   #$03
03E3: B7 19 0C    STA   $190C
03E6: B7 10 19    STA   $1019
03E9: 86 08       LDA   #$08
03EB: B7 10 15    STA   $1015
03EE: C6 01       LDB   #$01
03F0: F7 10 17    STB   $1017
03F3: BD 11 EE    JSR   $11EE
03F6: 86 02       LDA   #$02
03F8: B7 19 0D    STA   $190D
03FB: B7 10 19    STA   $1019
03FE: 86 7D       LDA   #$7D
0400: B7 10 15    STA   $1015
0403: 86 01       LDA   #$01
0405: B7 10 17    STA   $1017
0408: BD 11 EE    JSR   $11EE
040B: CC 00 02    LDD   #$0002
040E: FD 18 F2    STD   $18F2
0411: 86 02       LDA   #$02
0413: B7 18 F4    STA   $18F4
0416: 86 F6       LDA   #$F6
0418: C6 52       LDB   #$52
041A: FD 18 F0    STD   $18F0
041D: 7F 18 FA    CLR   $18FA
0420: BD 14 37    JSR   $1437
0423: 86 04       LDA   #$04
0425: B7 18 FB    STA   $18FB
0428: BD 14 88    JSR   $1488
042B: 39          RTS   

042C: 86 AA       LDA   #$AA
042E: 97 B5       STA   $B5
0430: 86 01       LDA   #$01
0432: 97 B6       STA   $B6
0434: 86 20       LDA   #$20
0436: 97 B9       STA   $B9
0438: CC 04 00    LDD   #$0400
043B: DD BA       STD   $BA
043D: CE 19 0F    LDU   #$190F
0440: 4F          CLRA  
0441: E6 C0       LDB   ,U+
0443: C1 FF       CMPB  #$FF
0445: 27 2D       BEQ   $0474
0447: DD BD       STD   $BD
0449: E6 C0       LDB   ,U+
044B: DD BF       STD   $BF
044D: E6 C0       LDB   ,U+
044F: DD C3       STD   $C3
0451: E6 C0       LDB   ,U+
0453: DD C5       STD   $C5
0455: BD 14 80    JSR   $1480
0458: 96 BE       LDA   $BE
045A: 91 C4       CMPA  $C4
045C: 26 07       BNE   $0465
045E: 0C BE       INC   $BE
0460: 0C C4       INC   $C4
0462: BD 14 80    JSR   $1480
0465: 96 C0       LDA   $C0
0467: 91 C6       CMPA  $C6
0469: 26 D5       BNE   $0440
046B: 0C C0       INC   $C0
046D: 0C C6       INC   $C6
046F: BD 14 80    JSR   $1480
0472: 20 CC       BRA   $0440

0474: 39          RTS   

0475: 34 40       PSHS  U
0477: BD 94 A1    JSR   $94A1
047A: 35 40       PULS  U
047C: 39          RTS   

047D: B6 18 FA    LDA   $18FA
0480: 8E 18 FC    LDX   #$18FC
0483: C6 08       LDB   #$08
0485: 3D          MUL   
0486: 30 8B       LEAX  D,X
0488: BF 18 F7    STX   $18F7
048B: CE 19 89    LDU   #$1989
048E: 8E 04 02    LDX   #$0402
0491: B6 18 F4    LDA   $18F4
0494: F6 18 FB    LDB   $18FB
0497: F7 19 0E    STB   $190E
049A: CB 01       ADDB  #$01
049C: AF C1       STX   ,U++
049E: A7 C0       STA   ,U+
04A0: 30 89 0A 00 LEAX  $0A00,X
04A4: 40          NEGA  
04A5: 5A          DECB  
04A6: 26 F4       BNE   $049C
04A8: C6 80       LDB   #$80
04AA: E7 C2       STB   ,-U
04AC: 7C 18 FA    INC   $18FA
04AF: B6 18 FA    LDA   $18FA
04B2: B1 18 F9    CMPA  $18F9
04B5: 25 04       BCS   $04BB
04B7: 7F 18 FA    CLR   $18FA
04BA: 4F          CLRA  
04BB: 39          RTS   

04BC: 8E 04 00    LDX   #$0400
04BF: ED 81       STD   ,X++
04C1: 8C 10 00    CMPX  #$1000
04C4: 25 F9       BCS   $04BF
04C6: 39          RTS   

04C7: 8E 04 00    LDX   #$0400
04CA: ED 81       STD   ,X++
04CC: 8C 0E E0    CMPX  #$0EE0
04CF: 25 F9       BCS   $04CA
04D1: 39          RTS   

04D2: CE 19 89    LDU   #$1989
04D5: A6 42       LDA   $0002,U
04D7: 10 27 00 71 LBEQ  $054C
04DB: EC C4       LDD   ,U
04DD: FD 18 DE    STD   $18DE
04E0: BE 18 F7    LDX   $18F7
04E3: BD 10 A4    JSR   $10A4
04E6: 86 80       LDA   #$80
04E8: A5 42       BITA  $0002,U
04EA: 26 10       BNE   $04FC
04EC: A6 42       LDA   $0002,U
04EE: 48          ASLA  
04EF: AB C4       ADDA  ,U
04F1: A7 C4       STA   ,U
04F3: EC C4       LDD   ,U
04F5: BD 10 C5    JSR   $10C5
04F8: 26 17       BNE   $0511
04FA: 20 42       BRA   $053E

04FC: A6 42       LDA   $0002,U
04FE: 48          ASLA  
04FF: 47          ASRA  
0500: AB 41       ADDA  $0001,U
0502: A7 41       STA   $0001,U
0504: 81 00       CMPA  #$00
0506: 2D 09       BLT   $0511
0508: EC C4       LDD   ,U
050A: BD 10 C5    JSR   $10C5
050D: 26 02       BNE   $0511
050F: 20 2D       BRA   $053E

0511: BD 15 62    JSR   $1562
0514: FC 18 DE    LDD   $18DE
0517: ED C4       STD   ,U
0519: C6 80       LDB   #$80
051B: F5 10 14    BITB  $1014
051E: 27 08       BEQ   $0528
0520: A6 42       LDA   $0002,U
0522: 88 80       EORA  #$80
0524: A7 42       STA   $0002,U
0526: 20 16       BRA   $053E

0528: A6 42       LDA   $0002,U
052A: 48          ASLA  
052B: 40          NEGA  
052C: 47          ASRA  
052D: 34 04       PSHS  B
052F: AA E0       ORA   ,S+
0531: A7 42       STA   $0002,U
0533: C6 01       LDB   #$01
0535: F5 10 13    BITB  $1013
0538: 27 04       BEQ   $053E
053A: 88 80       EORA  #$80
053C: A7 42       STA   $0002,U
053E: C6 54       LDB   #$54
0540: E1 41       CMPB  $0001,U
0542: 25 39       BCS   $057D
0544: EC C4       LDD   ,U
0546: BE 18 F7    LDX   $18F7
0549: BD 10 AF    JSR   $10AF
054C: 33 43       LEAU  $0003,U
054E: 86 80       LDA   #$80
0550: A1 42       CMPA  $0002,U
0552: 10 26 FF 7F LBNE  $04D5
0556: 39          RTS   

0557: FC 18 F0    LDD   $18F0
055A: 8B 04       ADDA  #$04
055C: 25 04       BCS   $0562
055E: A1 C4       CMPA  ,U
0560: 25 1A       BCS   $057C
0562: CB 02       ADDB  #$02
0564: 25 0C       BCS   $0572
0566: E1 41       CMPB  $0001,U
0568: 25 12       BCS   $057C
056A: 80 08       SUBA  #$08
056C: 25 04       BCS   $0572
056E: A1 C4       CMPA  ,U
0570: 22 0A       BHI   $057C
0572: C0 05       SUBB  #$05
0574: 25 04       BCS   $057A
0576: E1 41       CMPB  $0001,U
0578: 22 02       BHI   $057C
057A: 20 01       BRA   $057D

057C: 39          RTS   

057D: FC 18 DE    LDD   $18DE
0580: BE 18 F7    LDX   $18F7
0583: BD 10 AF    JSR   $10AF
0586: BD 15 C0    JSR   $15C0
0589: 86 E0       LDA   #$E0
058B: 97 8C       STA   $8C
058D: CC 00 40    LDD   #$0040
0590: BD 12 5F    JSR   $125F
0593: BD 15 C0    JSR   $15C0
0596: 7A 19 0C    DEC   $190C
0599: F6 19 0C    LDB   $190C
059C: F7 10 19    STB   $1019
059F: C6 08       LDB   #$08
05A1: F7 10 15    STB   $1015
05A4: C6 01       LDB   #$01
05A6: F7 10 17    STB   $1017
05A9: BD 11 EE    JSR   $11EE
05AC: F6 19 0C    LDB   $190C
05AF: 26 03       BNE   $05B4
05B1: 7C 18 F6    INC   $18F6
05B4: 39          RTS   

05B5: 39          RTS   

05B6: 7D 18 E3    TST   $18E3
05B9: 27 2E       BEQ   $05E9
05BB: B6 18 E5    LDA   $18E5
05BE: 81 08       CMPA  #$08
05C0: 26 05       BNE   $05C7
05C2: 7F 01 5A    CLR   $015A
05C5: 20 20       BRA   $05E7

05C7: 81 09       CMPA  #$09
05C9: 26 07       BNE   $05D2
05CB: 86 3F       LDA   #$3F
05CD: B7 01 5A    STA   $015A
05D0: 20 15       BRA   $05E7

05D2: 81 5E       CMPA  #$5E
05D4: 26 05       BNE   $05DB
05D6: 7F 01 5B    CLR   $015B
05D9: 20 0C       BRA   $05E7

05DB: 81 0A       CMPA  #$0A
05DD: 26 07       BNE   $05E6
05DF: 86 3F       LDA   #$3F
05E1: B7 01 5B    STA   $015B
05E4: 20 01       BRA   $05E7

05E6: 39          RTS   

05E7: 20 04       BRA   $05ED

05E9: AD 9F A0 0A JSR   [$A00A,X]
05ED: FC 18 F0    LDD   $18F0
05F0: 8E 19 02    LDX   #$1902
05F3: BD 10 A4    JSR   $10A4
05F6: FE 18 F0    LDU   $18F0
05F9: B6 01 5A    LDA   $015A
05FC: 84 F0       ANDA  #$F0
05FE: 81 10       CMPA  #$10
0600: 27 29       BEQ   $062B
0602: 81 00       CMPA  #$00
0604: 27 0C       BEQ   $0612
0606: B6 18 F5    LDA   $18F5
0609: 48          ASLA  
060A: BB 18 F0    ADDA  $18F0
060D: B7 18 F0    STA   $18F0
0610: 20 0B       BRA   $061D

0612: B6 18 F5    LDA   $18F5
0615: 48          ASLA  
0616: 40          NEGA  
0617: BB 18 F0    ADDA  $18F0
061A: B7 18 F0    STA   $18F0
061D: FC 18 F0    LDD   $18F0
0620: 8E 19 02    LDX   #$1902
0623: BD 10 C5    JSR   $10C5
0626: 27 03       BEQ   $062B
0628: FF 18 F0    STU   $18F0
062B: FE 18 F0    LDU   $18F0
062E: B6 01 5B    LDA   $015B
0631: 84 F0       ANDA  #$F0
0633: 81 10       CMPA  #$10
0635: 27 19       BEQ   $0650
0637: 81 00       CMPA  #$00
0639: 27 0B       BEQ   $0646
063B: B6 18 F5    LDA   $18F5
063E: BB 18 F1    ADDA  $18F1
0641: B7 18 F1    STA   $18F1
0644: 20 0A       BRA   $0650

0646: B6 18 F5    LDA   $18F5
0649: 40          NEGA  
064A: BB 18 F1    ADDA  $18F1
064D: B7 18 F1    STA   $18F1
0650: FC 18 F0    LDD   $18F0
0653: 8E 19 02    LDX   #$1902
0656: BD 10 C5    JSR   $10C5
0659: 27 03       BEQ   $065E
065B: FF 18 F0    STU   $18F0
065E: FC 18 F0    LDD   $18F0
0661: 8E 19 02    LDX   #$1902
0664: BD 10 AF    JSR   $10AF
0667: FD 18 F0    STD   $18F0
066A: 39          RTS   

066B: B6 FF 00    LDA   $FF00
066E: 85 01       BITA  #$01
0670: 26 22       BNE   $0694
0672: 7D 18 E2    TST   $18E2
0675: 26 20       BNE   $0697
0677: 7C 18 E2    INC   $18E2
067A: 86 01       LDA   #$01
067C: B7 18 D5    STA   $18D5
067F: BE 18 F0    LDX   $18F0
0682: BF 18 D6    STX   $18D6
0685: 86 F0       LDA   #$F0
0687: 97 8C       STA   $8C
0689: CC 00 03    LDD   #$0003
068C: BD 12 5F    JSR   $125F
068F: BD 16 B7    JSR   $16B7
0692: 20 06       BRA   $069A

0694: 7F 18 E2    CLR   $18E2
0697: BD 15 C1    JSR   $15C1
069A: 39          RTS   

069B: 7F 18 D5    CLR   $18D5
069E: B6 FF 00    LDA   $FF00
06A1: 85 01       BITA  #$01
06A3: 27 03       BEQ   $06A8
06A5: 7F 18 E2    CLR   $18E2
06A8: BD 17 85    JSR   $1785
06AB: 39          RTS   

06AC: CC 18 E8    LDD   #$18E8
06AF: FD 18 E6    STD   $18E6
06B2: 7F 18 DA    CLR   $18DA
06B5: C6 FF       LDB   #$FF
06B7: F7 18 DB    STB   $18DB
06BA: BD 17 1C    JSR   $171C
06BD: BD 17 12    JSR   $1712
06C0: 86 02       LDA   #$02
06C2: B7 18 DA    STA   $18DA
06C5: 7F 18 DB    CLR   $18DB
06C8: BD 17 29    JSR   $1729
06CB: BD 17 12    JSR   $1712
06CE: 7F 18 DA    CLR   $18DA
06D1: C6 01       LDB   #$01
06D3: F7 18 DB    STB   $18DB
06D6: BD 17 38    JSR   $1738
06D9: BD 17 12    JSR   $1712
06DC: 86 FE       LDA   #$FE
06DE: B7 18 DA    STA   $18DA
06E1: 7F 18 DB    CLR   $18DB
06E4: BD 17 47    JSR   $1747
06E7: CC 18 E8    LDD   #$18E8
06EA: FD 18 E6    STD   $18E6
06ED: EC 9F 18 E6 LDD   [$18E6,X]
06F1: BD 12 2A    JSR   $122A
06F4: 81 04       CMPA  #$04
06F6: 26 03       BNE   $06FB
06F8: BD 18 03    JSR   $1803
06FB: BD 17 12    JSR   $1712
06FE: 8E 18 F0    LDX   #$18F0
0701: BC 18 E6    CPX   $18E6
0704: 26 E7       BNE   $06ED
0706: 39          RTS   

0707: FC 18 E6    LDD   $18E6
070A: C3 00 02    ADDD  #$0002
070D: FD 18 E6    STD   $18E6
0710: 39          RTS   

0711: FC 18 D6    LDD   $18D6
0714: 8B 02       ADDA  #$02
0716: ED 9F 18 E6 STD   [$18E6,X]
071A: BD 17 54    JSR   $1754
071D: 39          RTS   

071E: FC 18 D6    LDD   $18D6
0721: 8B 04       ADDA  #$04
0723: CB 01       ADDB  #$01
0725: ED 9F 18 E6 STD   [$18E6,X]
0729: BD 17 54    JSR   $1754
072C: 39          RTS   

072D: FC 18 D6    LDD   $18D6
0730: 8B 02       ADDA  #$02
0732: CB 02       ADDB  #$02
0734: ED 9F 18 E6 STD   [$18E6,X]
0738: BD 17 54    JSR   $1754
073B: 39          RTS   

073C: FC 18 D6    LDD   $18D6
073F: CB 01       ADDB  #$01
0741: ED 9F 18 E6 STD   [$18E6,X]
0745: BD 17 54    JSR   $1754
0748: 39          RTS   

0749: B6 18 DC    LDA   $18DC
074C: B7 18 DD    STA   $18DD
074F: EC 9F 18 E6 LDD   [$18E6,X]
0753: BB 18 DA    ADDA  $18DA
0756: FB 18 DB    ADDB  $18DB
0759: ED 9F 18 E6 STD   [$18E6,X]
075D: 4D          TSTA  
075E: 27 19       BEQ   $0779
0760: 5D          TSTB  
0761: 27 16       BEQ   $0779
0763: 7A 18 DD    DEC   $18DD
0766: 27 11       BEQ   $0779
0768: 8E 19 07    LDX   #$1907
076B: BD 10 C5    JSR   $10C5
076E: 26 09       BNE   $0779
0770: EC 9F 18 E6 LDD   [$18E6,X]
0774: BD 10 AF    JSR   $10AF
0777: 20 D6       BRA   $074F

0779: 39          RTS   

077A: CC 18 E8    LDD   #$18E8
077D: FD 18 E6    STD   $18E6
0780: 7F 18 DA    CLR   $18DA
0783: C6 FF       LDB   #$FF
0785: F7 18 DB    STB   $18DB
0788: BD 17 C1    JSR   $17C1
078B: BD 17 12    JSR   $1712
078E: 86 02       LDA   #$02
0790: B7 18 DA    STA   $18DA
0793: 7F 18 DB    CLR   $18DB
0796: BD 17 CA    JSR   $17CA
0799: BD 17 12    JSR   $1712
079C: 7F 18 DA    CLR   $18DA
079F: C6 01       LDB   #$01
07A1: F7 18 DB    STB   $18DB
07A4: BD 17 D5    JSR   $17D5
07A7: BD 17 12    JSR   $1712
07AA: 86 FE       LDA   #$FE
07AC: B7 18 DA    STA   $18DA
07AF: 7F 18 DB    CLR   $18DB
07B2: BD 17 E0    JSR   $17E0
07B5: 39          RTS   

07B6: FC 18 D6    LDD   $18D6
07B9: 8B 02       ADDA  #$02
07BB: BD 17 E9    JSR   $17E9
07BE: 39          RTS   

07BF: FC 18 D6    LDD   $18D6
07C2: 8B 04       ADDA  #$04
07C4: CB 01       ADDB  #$01
07C6: BD 17 E9    JSR   $17E9
07C9: 39          RTS   

07CA: FC 18 D6    LDD   $18D6
07CD: 8B 02       ADDA  #$02
07CF: CB 02       ADDB  #$02
07D1: BD 17 E9    JSR   $17E9
07D4: 39          RTS   

07D5: FC 18 D6    LDD   $18D6
07D8: CB 01       ADDB  #$01
07DA: BD 17 E9    JSR   $17E9
07DD: 39          RTS   

07DE: BB 18 DA    ADDA  $18DA
07E1: 27 14       BEQ   $07F7
07E3: FB 18 DB    ADDB  $18DB
07E6: 27 0F       BEQ   $07F7
07E8: 10 A3 9F 18 E6 CMPD[$18E6,X]
07ED: 27 08       BEQ   $07F7
07EF: 8E 19 07    LDX   #$1907
07F2: BD 10 A4    JSR   $10A4
07F5: 20 E7       BRA   $07DE

07F7: 39          RTS   

07F8: 86 D0       LDA   #$D0
07FA: 97 8C       STA   $8C
07FC: CC 00 05    LDD   #$0005
07FF: BD 12 5F    JSR   $125F
0802: BD 11 A2    JSR   $11A2
0805: CE 19 89    LDU   #$1989
0808: 6D 42       TST   $0002,U
080A: 27 31       BEQ   $083D
080C: EC 9F 18 E6 LDD   [$18E6,X]
0810: 8B 02       ADDA  #$02
0812: 25 04       BCS   $0818
0814: A1 C4       CMPA  ,U
0816: 25 25       BCS   $083D
0818: E1 41       CMPB  $0001,U
081A: 25 21       BCS   $083D
081C: 80 06       SUBA  #$06
081E: 25 04       BCS   $0824
0820: A1 C4       CMPA  ,U
0822: 22 19       BHI   $083D
0824: C0 03       SUBB  #$03
0826: 25 04       BCS   $082C
0828: E1 41       CMPB  $0001,U
082A: 22 11       BHI   $083D
082C: EC C4       LDD   ,U
082E: BE 18 F7    LDX   $18F7
0831: BD 10 A4    JSR   $10A4
0834: 6F 42       CLR   $0002,U
0836: 7A 19 0E    DEC   $190E
0839: 27 51       BEQ   $088C
083B: 20 0B       BRA   $0848

083D: 33 43       LEAU  $0003,U
083F: 86 80       LDA   #$80
0841: A1 42       CMPA  $0002,U
0843: 26 C3       BNE   $0808
0845: BD 18 97    JSR   $1897
0848: 39          RTS   

0849: 7D 19 0D    TST   $190D
084C: 27 3D       BEQ   $088B
084E: CE 19 89    LDU   #$1989
0851: A6 42       LDA   $0002,U
0853: 27 15       BEQ   $086A
0855: EC C4       LDD   ,U
0857: BE 18 F7    LDX   $18F7
085A: BD 10 A4    JSR   $10A4
085D: BD 11 A2    JSR   $11A2
0860: 86 E0       LDA   #$E0
0862: 97 8C       STA   $8C
0864: CC 00 06    LDD   #$0006
0867: BD 12 5F    JSR   $125F
086A: 33 43       LEAU  $0003,U
086C: 86 80       LDA   #$80
086E: A1 42       CMPA  $0002,U
0870: 26 DF       BNE   $0851
0872: 7A 19 0D    DEC   $190D
0875: B6 19 0D    LDA   $190D
0878: B7 10 19    STA   $1019
087B: 86 01       LDA   #$01
087D: B7 10 17    STA   $1017
0880: 86 7D       LDA   #$7D
0882: B7 10 15    STA   $1015
0885: BD 11 EE    JSR   $11EE
0888: BD 18 97    JSR   $1897
088B: 39          RTS   

088C: CC 00 00    LDD   #$0000
088F: BD 14 D2    JSR   $14D2
0892: 7F 18 E2    CLR   $18E2
0895: BD 14 37    JSR   $1437
0898: 8E 19 0A    LDX   #$190A
089B: BF 10 1F    STX   $101F
089E: CC 00 80    LDD   #$0080
08A1: BD 12 5F    JSR   $125F
08A4: 8E 00 00    LDX   #$0000
08A7: BF 10 1F    STX   $101F
08AA: 86 E0       LDA   #$E0
08AC: 97 8C       STA   $8C
08AE: CC 00 03    LDD   #$0003
08B1: BD 12 5F    JSR   $125F
08B4: 86 F6       LDA   #$F6
08B6: C6 52       LDB   #$52
08B8: FD 18 F0    STD   $18F0
08BB: B6 18 FB    LDA   $18FB
08BE: 4C          INCA  
08BF: 81 18       CMPA  #$18
08C1: 22 03       BHI   $08C6
08C3: B7 18 FB    STA   $18FB
08C6: BD 14 88    JSR   $1488
08C9: 39          RTS   

08CA: 00 B6       NEG   $B6
08CC: 28 00       BVC   $08CE
08CE: 00 FE       NEG   $FE
08D0: 00 14       NEG   $14
08D2: 07 0C       ASR   $0C
08D4: 02          Illegal Opcode
08D5: 00 00       NEG   $00
08D7: 00 01       NEG   $01
08D9: 07 03       ASR   $03
08DB: 18          Illegal Opcode
08DC: EE B8 14    LDU   [$14,Y]
08DF: E2 29       SBCB  $0009,Y
08E1: B8 2B 9C    EORA  $2B9C
08E4: 29 F6       BVS   $08DC
08E6: 53          COMB  
08E7: 00 02       NEG   $02
08E9: 02          Illegal Opcode
08EA: 01          Illegal Opcode
08EB: 00 18       NEG   $18
08ED: FC 01 00    LDD   $0100
08F0: 05          Illegal Opcode
08F1: 08 04       ASL   $04
08F3: 30 FC 30    LEAX  [$30,S]
08F6: CC 08 03    LDD   #$0803
08F9: 20 A8       BRA   $08A3

08FB: 20 08       BRA   $0905

08FD: 01          Illegal Opcode
08FE: C0 00       SUBB  #$00
0900: FF 03 02    STU   $0302
0903: 05          Illegal Opcode
0904: 00 00       NEG   $00
0906: 00 57       NEG   $57
0908: 00 56       NEG   $56
090A: 7F 56 7E    CLR   $567E
090D: 57          ASRB  
090E: 7E 00 7F    JMP   $007F

0911: 00 00       NEG   $00
0913: 00 10       NEG   $10
0915: 10 6F       Illegal Opcode
0917: 10 10       Illegal Opcode
0919: 47          ASRA  
091A: 6F 47       CLR   $0007,U
091C: 00 2B       NEG   $2B
091E: 2F 2B       BLE   $094B
0920: 4F          CLRA  
0921: 2B 7F       BMI   $09A2
0923: 2B 3F       BMI   $0964
0925: 10 3F 20    SWI2  20
0928: 3F          SWI   
0929: 37 3F       PULU  CC,A,B,DP,X,Y
092B: 47          ASRA  
092C: FF FF 23    STU   $FF23
092F: 20 22       BRA   $0953

0931: 20 22       BRA   $0955

0933: 18          Illegal Opcode
0934: 22 18       BHI   $094E
0936: 00 FF       NEG   $FF
0938: 00 00       NEG   $00
093A: 13          SYNC  
093B: 00 1A       NEG   $1A
093D: 1A 1A       ORCC  #$1A
093F: 1A 1A       ORCC  #$1A
0941: 1A 1A       ORCC  #$1A
0943: 1A 1A       ORCC  #$1A
0945: 1A 1A       ORCC  #$1A
0947: 1A 1A       ORCC  #$1A
0949: 1A 1A       ORCC  #$1A
094B: 1A 1A       ORCC  #$1A
094D: 1A 1A       ORCC  #$1A
094F: 1A 1A       ORCC  #$1A
0951: 1A 1A       ORCC  #$1A
0953: 1A 1A       ORCC  #$1A
0955: 1A 1A       ORCC  #$1A
0957: 1A 1A       ORCC  #$1A
0959: 1A 1A       ORCC  #$1A
095B: 1A 1A       ORCC  #$1A
095D: 1A 1A       ORCC  #$1A
095F: 1A 1A       ORCC  #$1A
0961: 1A 1A       ORCC  #$1A
0963: 1A 1A       ORCC  #$1A
0965: 1A 1A       ORCC  #$1A
0967: 1A 1A       ORCC  #$1A
0969: 1A 1A       ORCC  #$1A
096B: 1A 1A       ORCC  #$1A
096D: 1A 1A       ORCC  #$1A
096F: 1A 1A       ORCC  #$1A
0971: 1A 1A       ORCC  #$1A
0973: 1A 1A       ORCC  #$1A
0975: 1A 1A       ORCC  #$1A
0977: 1A 1A       ORCC  #$1A
0979: 1A 1A       ORCC  #$1A
097B: 1A 1A       ORCC  #$1A
097D: 1A 1A       ORCC  #$1A
097F: 1A 0D       ORCC  #$0D
0981: 0D 00       TST   $00
0983: 00 00       NEG   $00
0985: 00 00       NEG   $00
0987: 00 00       NEG   $00
0989: 00 00       NEG   $00
098B: 00 00       NEG   $00
098D: 00 00       NEG   $00
098F: 00 00       NEG   $00
0991: 00 00       NEG   $00
0993: 00 00       NEG   $00
0995: 00 00       NEG   $00
0997: 00 00       NEG   $00
0999: 00 00       NEG   $00
099B: 00 00       NEG   $00
099D: 00 00       NEG   $00
099F: 00 00       NEG   $00
09A1: 00 00       NEG   $00
09A3: 00 00       NEG   $00
09A5: 00 00       NEG   $00
09A7: 00 00       NEG   $00
09A9: 00 00       NEG   $00
09AB: 00 00       NEG   $00
09AD: 00 00       NEG   $00
09AF: 00 00       NEG   $00
09B1: 00 00       NEG   $00
09B3: 00 00       NEG   $00
09B5: 00 00       NEG   $00
09B7: 00 00       NEG   $00
09B9: 00 00       NEG   $00
09BB: 00 00       NEG   $00
09BD: 00 00       NEG   $00
09BF: 00 00       NEG   $00
09C1: 00 00       NEG   $00
09C3: 00 00       NEG   $00
09C5: 00 00       NEG   $00
09C7: 00 00       NEG   $00
09C9: 00 00       NEG   $00
09CB: 00 00       NEG   $00
09CD: 00 00       NEG   $00
09CF: 00 00       NEG   $00
09D1: 00 00       NEG   $00
09D3: 00 00       NEG   $00
09D5: 00 00       NEG   $00
09D7: 00 00       NEG   $00
09D9: 00 00       NEG   $00
09DB: 00 00       NEG   $00
09DD: 00 00       NEG   $00
09DF: 00 00       NEG   $00
09E1: 00 00       NEG   $00
09E3: 00 00       NEG   $00
09E5: 00 00       NEG   $00
09E7: 00 00       NEG   $00
09E9: 00 00       NEG   $00
09EB: 00 00       NEG   $00
09ED: 00 00       NEG   $00
09EF: 00 00       NEG   $00
09F1: 00 00       NEG   $00
09F3: 00 00       NEG   $00
09F5: 00 00       NEG   $00
09F7: 00 00       NEG   $00
09F9: 00 00       NEG   $00
09FB: 00 00       NEG   $00
09FD: 00 00       NEG   $00
09FF: 00 00       NEG   $00
0A01: 00 00       NEG   $00
0A03: 00 00       NEG   $00
0A05: 00 00       NEG   $00
0A07: 00 00       NEG   $00
0A09: 00 00       NEG   $00
0A0B: 00 00       NEG   $00
0A0D: 00 00       NEG   $00
0A0F: 00 00       NEG   $00
0A11: 00 00       NEG   $00
0A13: 00 00       NEG   $00
0A15: 00 00       NEG   $00
0A17: 00 00       NEG   $00
0A19: 00 00       NEG   $00
0A1B: 00 00       NEG   $00
0A1D: 00 00       NEG   $00
0A1F: 00 00       NEG   $00
0A21: 00 00       NEG   $00
0A23: 00 00       NEG   $00
0A25: 00 00       NEG   $00
0A27: 00 00       NEG   $00
0A29: 00 00       NEG   $00
0A2B: 00 00       NEG   $00
0A2D: 00 00       NEG   $00
0A2F: 00 00       NEG   $00
0A31: 00 00       NEG   $00
0A33: 00 00       NEG   $00
0A35: 00 00       NEG   $00
0A37: 00 00       NEG   $00
0A39: 00 00       NEG   $00
0A3B: 00 00       NEG   $00
0A3D: 00 00       NEG   $00
0A3F: 00 00       NEG   $00
0A41: 00 00       NEG   $00
0A43: 00 00       NEG   $00
0A45: 00 00       NEG   $00
0A47: 00 00       NEG   $00
0A49: 00 00       NEG   $00
0A4B: 00 00       NEG   $00
0A4D: 00 00       NEG   $00
0A4F: 00 00       NEG   $00
0A51: 00 00       NEG   $00
0A53: 00 00       NEG   $00
0A55: 00 00       NEG   $00
0A57: 00 00       NEG   $00
0A59: 00 00       NEG   $00
0A5B: 00 00       NEG   $00
0A5D: 00 00       NEG   $00
0A5F: 00 00       NEG   $00
0A61: 00 00       NEG   $00
0A63: 00 00       NEG   $00
0A65: 00 00       NEG   $00
0A67: 00 00       NEG   $00
0A69: 00 00       NEG   $00
0A6B: 00 00       NEG   $00
0A6D: 00 00       NEG   $00
0A6F: 00 00       NEG   $00
0A71: 00 00       NEG   $00
0A73: 00 00       NEG   $00
0A75: 00 00       NEG   $00
0A77: 00 00       NEG   $00
0A79: 00 00       NEG   $00
0A7B: 00 00       NEG   $00
0A7D: 00 00       NEG   $00
0A7F: 00 00       NEG   $00
0A81: 00 00       NEG   $00
0A83: 00 00       NEG   $00
0A85: 00 00       NEG   $00
0A87: 00 00       NEG   $00
0A89: 00 00       NEG   $00
0A8B: 00 00       NEG   $00
0A8D: 00 00       NEG   $00
0A8F: 00 00       NEG   $00
0A91: 00 00       NEG   $00
0A93: 00 00       NEG   $00
0A95: 00 00       NEG   $00
0A97: 00 00       NEG   $00
0A99: 00 00       NEG   $00
0A9B: 00 00       NEG   $00
0A9D: 00 00       NEG   $00
0A9F: 00 00       NEG   $00
0AA1: 00 00       NEG   $00
0AA3: 00 00       NEG   $00
0AA5: 00 00       NEG   $00
0AA7: 00 00       NEG   $00
0AA9: 00 00       NEG   $00
0AAB: 00 00       NEG   $00
0AAD: 00 00       NEG   $00
0AAF: 00 00       NEG   $00
0AB1: 00 00       NEG   $00
0AB3: 00 00       NEG   $00
0AB5: 00 00       NEG   $00
0AB7: 00 00       NEG   $00
0AB9: 00 00       NEG   $00
0ABB: 00 00       NEG   $00
0ABD: 00 00       NEG   $00
0ABF: 00 00       NEG   $00
0AC1: 00 00       NEG   $00
0AC3: 00 00       NEG   $00
0AC5: 00 00       NEG   $00
0AC7: 00 00       NEG   $00
0AC9: 00 00       NEG   $00
0ACB: 00 00       NEG   $00
0ACD: 00 00       NEG   $00
0ACF: 00 00       NEG   $00
0AD1: 00 00       NEG   $00
0AD3: 00 00       NEG   $00
0AD5: 00 00       NEG   $00
0AD7: 00 00       NEG   $00
0AD9: 00 00       NEG   $00
0ADB: 00 00       NEG   $00
0ADD: 00 00       NEG   $00
0ADF: 00 00       NEG   $00
0AE1: 00 00       NEG   $00
0AE3: 00 00       NEG   $00
0AE5: 00 00       NEG   $00
0AE7: 00 00       NEG   $00
0AE9: 00 00       NEG   $00
0AEB: 00 00       NEG   $00
0AED: 00 00       NEG   $00
0AEF: 00 00       NEG   $00
0AF1: 00 00       NEG   $00
0AF3: 00 00       NEG   $00
0AF5: 00 00       NEG   $00
0AF7: 00 00       NEG   $00
0AF9: 00 00       NEG   $00
0AFB: 00 00       NEG   $00
0AFD: 00 00       NEG   $00
0AFF: 00 00       NEG   $00
0B01: 00 00       NEG   $00
0B03: 00 00       NEG   $00
0B05: 00 00       NEG   $00
0B07: 00 00       NEG   $00
0B09: 00 00       NEG   $00
0B0B: 00 00       NEG   $00
0B0D: 00 00       NEG   $00
0B0F: 00 00       NEG   $00
0B11: 00 00       NEG   $00
0B13: 00 00       NEG   $00
0B15: 00 00       NEG   $00
0B17: 00 00       NEG   $00
0B19: 00 00       NEG   $00
0B1B: 00 00       NEG   $00
0B1D: 00 00       NEG   $00
0B1F: 00 00       NEG   $00
0B21: 00 00       NEG   $00
0B23: 00 00       NEG   $00
0B25: 00 00       NEG   $00
0B27: 00 00       NEG   $00
0B29: 00 00       NEG   $00
0B2B: 00 00       NEG   $00
0B2D: 00 00       NEG   $00
0B2F: 00 00       NEG   $00
0B31: 00 00       NEG   $00
0B33: 00 00       NEG   $00
0B35: 00 00       NEG   $00
0B37: 00 00       NEG   $00
0B39: 00 00       NEG   $00
0B3B: 00 00       NEG   $00
0B3D: 00 00       NEG   $00
0B3F: 00 00       NEG   $00
0B41: 00 00       NEG   $00
0B43: 00 00       NEG   $00
0B45: 00 00       NEG   $00
0B47: 00 00       NEG   $00
0B49: 00 00       NEG   $00
0B4B: 00 00       NEG   $00
0B4D: 00 00       NEG   $00
0B4F: 00 00       NEG   $00
0B51: 00 00       NEG   $00
0B53: 00 00       NEG   $00
0B55: 00 00       NEG   $00
0B57: 00 00       NEG   $00
0B59: 00 00       NEG   $00
0B5B: 00 00       NEG   $00
0B5D: 00 00       NEG   $00
0B5F: 00 00       NEG   $00
0B61: 00 00       NEG   $00
0B63: 00 00       NEG   $00
0B65: 00 00       NEG   $00
0B67: 00 00       NEG   $00
0B69: 00 00       NEG   $00
0B6B: 00 00       NEG   $00
0B6D: 00 00       NEG   $00
0B6F: 00 00       NEG   $00
0B71: 00 00       NEG   $00
0B73: 00 00       NEG   $00
0B75: 00 00       NEG   $00
0B77: 00 00       NEG   $00
0B79: 00 00       NEG   $00
0B7B: 00 00       NEG   $00
0B7D: 00 00       NEG   $00
0B7F: 00 00       NEG   $00
0B81: 00 00       NEG   $00
0B83: 00 00       NEG   $00
0B85: 00 00       NEG   $00
0B87: 00 00       NEG   $00
0B89: 00 00       NEG   $00
0B8B: 00 00       NEG   $00
0B8D: 00 00       NEG   $00
0B8F: 00 00       NEG   $00
0B91: 00 00       NEG   $00
0B93: 00 00       NEG   $00
0B95: 00 00       NEG   $00
0B97: 00 00       NEG   $00
0B99: 00 00       NEG   $00
0B9B: 00 00       NEG   $00
0B9D: 00 00       NEG   $00
0B9F: 00 00       NEG   $00
0BA1: 00 00       NEG   $00
0BA3: 00 00       NEG   $00
0BA5: 00 00       NEG   $00
0BA7: 00 00       NEG   $00
0BA9: 00 00       NEG   $00
0BAB: 00 00       NEG   $00
0BAD: 00 00       NEG   $00
0BAF: 00 00       NEG   $00
0BB1: 00 00       NEG   $00
0BB3: 00 00       NEG   $00
0BB5: 00 00       NEG   $00
0BB7: 00 00       NEG   $00
0BB9: 00 00       NEG   $00
0BBB: 00 00       NEG   $00
0BBD: 00 00       NEG   $00
0BBF: 00 00       NEG   $00
0BC1: 00 00       NEG   $00
0BC3: 00 00       NEG   $00
0BC5: 00 00       NEG   $00
0BC7: 00 00       NEG   $00
0BC9: 00 00       NEG   $00
0BCB: 00 00       NEG   $00
0BCD: 00 00       NEG   $00
0BCF: 00 00       NEG   $00
0BD1: 00 00       NEG   $00
0BD3: 00 00       NEG   $00
0BD5: 00 00       NEG   $00
0BD7: 00 00       NEG   $00
0BD9: 00 00       NEG   $00
0BDB: 00 00       NEG   $00
0BDD: 00 00       NEG   $00
0BDF: 00 00       NEG   $00
0BE1: 00 00       NEG   $00
0BE3: 00 00       NEG   $00
0BE5: 00 00       NEG   $00
0BE7: 00 00       NEG   $00
0BE9: 00 00       NEG   $00
0BEB: 00 00       NEG   $00
0BED: 00 00       NEG   $00
0BEF: 00 00       NEG   $00
0BF1: 00 00       NEG   $00
0BF3: 00 00       NEG   $00
0BF5: 00 00       NEG   $00
0BF7: 00 00       NEG   $00
0BF9: 00 00       NEG   $00
0BFB: 00 00       NEG   $00
0BFD: 00 00       NEG   $00
0BFF: 00 FF       NEG   $FF
