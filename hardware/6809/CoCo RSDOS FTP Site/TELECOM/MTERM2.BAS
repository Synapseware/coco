
1 REM MTERM2/BAS
2 DEFUSR0=&H1E0
3 FOR I=&H1E0 TO &H1FC
4 READ H$:POKE I,VAL("&H"+H$):NEXT I
5 CLS:PRINT"POKING M/L...":PRINT:L=19:SA=&HA356
6 CK=0:L=L+1
7 FOR I=1 TO 32
8 READ H$:IF H$="X" THEN 17
9 PRINT@206,HEX$(SA)
10 X=VAL("&H"+H$):Y=USR0(X)
11 CK=CK+X:SA=SA+1
12 NEXT I
13 READ I
14 IF I=CK THEN 6
15 PRINT:PRINT"CHECKSUM ERROR IN LINE";L
16 STOP
17 PRINT:PRINT"LOAD AND RUN MTERM3/BAS"
18 END
19 DATA BD,B3,ED,34,40,EE,8D,0,12,1A,50,B7,FF,DF,E7,C0,EF,8D,0,7,B7,FF,DE,1C,AF,35,C0,A3,56
20 DATA DE,27,7F,FF,40,BD,43,61,21,8,86,20,B7,23,5E,7E,26,27,B6,18,57,B7,FF,22,BD,43,47,7F,FF,DE,BD,A9,3836
21 DATA 28,34,1,7F,FF,DF,35,1,7D,4D,8B,27,E,7F,4D,8B,86,1,B7,26,67,BD,43,54,7E,F,42,7D,26,67,26,5,2804
22 DATA 86,8,B7,FF,22,BD,25,9B,7D,26,67,26,6D,CC,9F,10,8E,4,0,A7,80,A7,80,BD,25,48,5A,26,F6,C6,E,30,3455
23 DATA 88,1F,A7,84,A7,1F,30,88,20,BD,25,48,5A,26,F3,C6,10,A7,84,A7,1F,30,1E,BD,25,48,5A,26,F4,30,88,E1,3417
24 DATA C6,E,A7,84,A7,1,30,88,E0,BD,25,48,5A,26,F3,21,5,86,20,B7,23,E5,5F,86,7,7D,FF,3,2A,FB,7D,FF,3699
25 DATA 2,4A,26,F5,8E,4,0,A6,80,2A,A,80,10,8A,8F,81,8F,27,F8,A7,1F,8C,6,0,26,ED,7D,26,66,26,8,BD,2954
26 DATA 27,D0,86,FF,B7,26,66,7F,FF,DE,AD,9F,A0,0,34,1,7F,FF,DF,35,1,84,7F,26,7,B6,26,67,27,B9,20,E7,3881
27 DATA 7F,26,66,BD,43,54,B7,26,67,BD,2D,C9,81,31,10,27,EA,FA,81,20,10,27,EA,F4,81,32,10,27,4,31,81,33,3244
28 DATA 10,27,2,A2,81,34,10,27,1,71,81,35,10,27,9,E5,7D,18,4F,26,6,81,36,10,27,10,88,81,37,10,27,E,1959
29 DATA 6,81,38,10,27,19,B6,81,2A,27,3,7E,25,51,BD,43,47,7F,FF,DE,BD,A9,28,34,1,7F,FF,DF,35,1,B6,18,3157
30 DATA 57,B7,FF,22,8E,4,2D,9F,88,BD,43,3E,BD,28,F,2A,45,78,69,74,2A,0,8E,4,67,9F,88,BD,43,3E,BD,26,3190
31 DATA 4F,7F,FF,DE,BD,A1,B1,34,1,7F,FF,DF,35,1,BD,2D,C9,81,59,10,26,FE,86,BD,43,25,7F,FF,DE,BD,A3,A,4276
32 DATA 34,1,7F,FF,DF,35,1,7D,18,4F,26,2F,CC,0,3,DD,EA,7D,4D,87,26,F,7F,FF,DE,BD,D5,FF,34,1,7F,FF,3773
33 DATA DF,35,1,20,D,7F,FF,DE,BD,D6,F2,34,1,7F,FF,DF,35,1,A,EB,2A,DB,B6,9,5A,97,EB,12,12,12,BD,43,3766
34 DATA 47,7F,FF,DE,BD,A9,28,34,1,7F,FF,DF,35,1,BE,48,BD,4F,A7,4,8E,25,3D,CE,2,0,A6,80,A7,C0,8C,25,3764
35 DATA 48,10,27,DC,C5,20,F3,1A,50,F,71,7F,FF,DE,6E,9F,FF,FE,8B,10,8A,8F,81,8F,27,F8,39,B6,18,57,B7,FF,4218
36 DATA 22,8D,32,BD,27,D0,8E,5,A7,9F,88,BD,43,3E,8E,26,68,A6,80,27,1A,7D,1,1A,27,3,BD,2D,C9,BD,43,25,3153
37 DATA 7F,FF,DE,BD,A3,A,34,1,7F,FF,DF,35,1,20,E2,BD,43,61,7E,24,1D,BD,43,47,7F,FF,DE,BD,A9,28,34,1,3862
38 DATA 7F,FF,DF,35,1,8E,4,28,9F,88,BD,43,3E,8E,26,7B,A6,80,27,A6,7D,1,1A,27,3,BD,2D,C9,BD,43,25,7F,3309
39 DATA FF,DE,BD,A3,A,34,1,7F,FF,DF,35,1,81,D,26,E0,DE,88,33,4A,DF,88,BD,43,3E,20,D5,B6,18,57,B7,FF,4091
40 DATA 22,BD,43,47,7F,FF,DE,BD,A9,28,34,1,7F,FF,DF,35,1,8E,4,29,9F,88,BD,43,3E,BD,28,F,2A,52,65,73,3459
41 DATA 65,74,20,42,75,66,66,65,72,2A,0,8E,4,67,9F,88,BD,43,3E,BD,26,4F,7F,FF,DE,BD,A1,B1,34,1,7F,FF,3627
42 DATA DF,35,1,BD,2D,C9,81,59,10,26,FD,31,86,1,B7,26,67,BE,26,FA,BF,4D,8E,BF,4D,8C,BF,4D,90,BF,4D,94,3869
43 DATA BF,4D,96,7F,4D,98,21,E,86,55,97,71,8E,25,11,9F,72,86,20,B7,26,3C,7E,23,53,BD,28,F,41,72,65,20,3020
44 DATA 79,6F,75,20,73,75,72,65,3F,20,28,59,29,20,0,39,0,0,2A,2D,49,6E,76,61,6C,69,64,20,4F,70,74,69,2424
45 DATA 6F,6E,2D,2A,0,4D,49,4B,45,59,20,20,2D,2A,2D,20,20,54,45,52,4D,D,D,31,20,43,6F,6D,62,61,74,D,1981
46 DATA 32,20,44,69,73,70,6C,61,79,D,33,20,4D,6F,64,65,6D,D,34,20,52,65,73,65,74,20,42,75,66,66,65,72,2648
47 DATA D,35,20,54,61,70,65,20,55,74,69,6C,69,74,79,D,36,20,44,69,73,6B,20,55,74,69,6C,69,74,79,D,37,2630
48 DATA 20,42,75,66,66,65,72,20,45,6E,74,72,79,D,38,20,43,68,61,6E,67,65,20,50,61,72,6D,73,D,2A,20,45,2582
49 DATA 78,69,74,0,56,80,7D,18,54,26,60,34,16,B6,23,2F,A7,9F,F,4,B6,23,30,A7,9F,F,6,30,8D,0,A5,E6,2801
50 DATA 8D,0,A0,34,4,20,10,86,1E,5F,5A,26,FD,4A,26,F9,35,4,5A,27,23,34,4,A6,9F,F,2,84,10,27,F8,A6,2626
51 DATA 80,A7,9F,F,0,86,1E,5F,5A,26,FD,4A,26,F9,A6,9F,F,2,A6,9F,F,0,20,CF,B6,17,B9,A7,9F,F,4,B6,3308
52 DATA 17,BA,A7,9F,F,6,35,16,7E,23,53,34,16,30,8D,0,53,E6,8D,0,4E,34,4,20,10,86,19,5F,5A,26,FD,4A,2483
53 DATA 26,F9,35,4,5A,27,1C,34,4,A6,80,8D,1B,5F,8D,1A,C6,8,34,4,5F,44,59,58,8D,10,35,4,5A,26,F3,8D,2609
54 DATA 7,20,D6,35,16,7E,23,53,C6,2,F7,FF,20,BF,27,B7,8D,0,8E,0,B4,12,12,30,1F,26,FC,12,12,BE,27,B7,3035
55 DATA 39,0,0,C,2A,2A,52,44,35,35,35,35,35,35,35,58,20,20,20,20,20,20,20,20,20,20,8E,5,D3,9F,88,BD,1924
56 DATA 43,3E,8D,35,46,72,65,65,0,FC,4D,92,B3,4D,8E,8E,5,D8,9F,88,BD,43,3E,8D,42,8E,5,C3,9F,88,BD,43,3658
57 DATA 3E,8D,16,55,73,65,64,0,FC,4D,8E,B3,4D,90,8E,5,C8,9F,88,BD,43,3E,8D,23,39,35,10,A6,80,27,1A,7D,3243
58 DATA 1,1A,27,3,BD,2D,C9,BD,43,25,7F,FF,DE,BD,A3,A,34,1,7F,FF,DF,35,1,20,E2,6E,84,ED,7E,27,2E,34,3475
59 DATA 16,8E,28,68,6F,E2,6F,E2,6F,E4,6C,E4,A3,84,24,FA,E3,81,34,6,A6,62,4A,1F,89,EA,63,E7,63,27,4,8B,4003
60 DATA 30,8D,1B,35,6,6D,1,26,DF,32,62,35,96,86,30,8D,D,39,27,10,3,E8,0,64,0,A,0,1,0,0,BD,43,2047
61 DATA 25,7F,FF,DE,BD,A3,A,34,1,7F,FF,DF,35,1,39,B6,18,57,B7,FF,22,7F,2E,26,7F,2E,4A,BD,43,61,BD,34,3589
62 DATA 68,BD,43,47,7F,FF,DE,BD,A9,28,34,1,7F,FF,DF,35,1,FE,4D,8C,FF,2E,21,FF,2E,23,BD,43,47,7F,FF,DE,4217
63 DATA BD,A9,28,34,1,7F,FF,DF,35,1,BD,43,61,11,B3,4D,8E,25,5,BD,2C,46,20,2E,7D,4D,88,26,26,A6,C0,7D,3198
64 DATA 17,C6,26,3,BD,2B,58,BD,43,25,7F,FF,DE,BD,A3,A,34,1,7F,FF,DF,35,1,9E,88,8C,5,DF,23,CF,8E,5,3604
65 DATA E0,9F,88,BD,2C,19,81,20,26,6,BD,34,87,7E,F,42,81,46,10,27,4,2C,81,57,26,8,73,17,C6,BD,2B,3D,2758
66 DATA 20,3C,81,4E,26,6,FE,2E,23,7E,2D,79,81,4D,10,27,0,4B,81,54,10,27,FF,69,7F,2E,25,81,5E,10,27,2,2424
67 DATA 81,C6,C,F7,2E,25,81,5F,10,27,2,76,81,3,10,27,2,C8,81,50,10,27,3,C,11,B3,4D,8E,26,6,FE,2E,2495
68 DATA 21,7E,28,B0,81,42,10,27,2,3E,81,A,10,27,2,42,81,5B,26,EA,FF,2E,21,FF,2E,23,7E,28,B0,BE,4D,90,2866
69 DATA BC,4D,8E,10,27,FF,D7,7D,17,C6,26,3A,73,17,C6,BD,43,47,7F,FF,DE,BD,A9,28,34,1,7F,FF,DF,35,1,FE,4005
70 DATA 2E,21,11,B3,4D,8E,24,19,A6,C0,BD,43,25,7F,FF,DE,BD,A3,A,34,1,7F,FF,DF,35,1,9E,88,8C,5,DF,23,3581
71 DATA E1,8E,4,0,9F,88,7F,2E,27,BE,2E,21,10,8E,4,0,34,16,BD,43,47,8E,4,0,C6,20,A6,80,81,1F,22,4,2578
72 DATA 8A,60,20,6,81,60,25,2,84,BF,BD,43,19,5A,26,C,86,D,BD,43,19,86,A,BD,43,19,C6,20,8C,6,0,25,2546
73 DATA D9,BD,43,6E,BD,43,54,35,16,A6,A4,F6,17,BE,E7,A4,34,2,34,60,34,10,9E,88,10,9F,88,BD,43,3E,9F,88,3670
74 DATA 35,10,7F,FF,DE,AD,9F,A0,0,34,1,7F,FF,DF,35,1,27,F0,BD,2D,C9,35,60,35,4,E7,A4,81,53,10,27,0,3459
75 DATA 1A,81,45,10,27,0,2D,81,5E,10,27,0,A5,81,A,10,27,0,BE,81,3,10,27,FF,5,20,AE,BC,4D,96,25,F,2271
76 DATA 34,10,BE,4D,8E,BF,4D,96,35,10,BC,4D,96,24,20,BF,4D,94,20,10,BC,4D,94,23,16,BC,4D,8E,23,3,BE,4D,3093
77 DATA 8E,BF,4D,96,86,FF,B7,4D,98,BD,2B,3D,7E,29,54,BD,43,47,7F,FF,DE,BD,A9,28,34,1,7F,FF,DF,35,1,BD,4135
78 DATA 34,87,8E,2D,FA,A6,80,27,1A,7D,1,1A,27,3,BD,2D,C9,BD,43,25,7F,FF,DE,BD,A3,A,34,1,7F,FF,DF,35,3582
79 DATA 1,20,E2,BE,4D,90,BF,4D,94,BE,4D,8E,BF,4D,96,7F,FF,DE,BD,A1,B1,34,1,7F,FF,DF,35,1,BD,43,47,7F,4210
80 DATA FF,DE,BD,A9,28,34,1,7F,FF,DF,35,1,BD,34,68,7E,29,54,10,8C,4,0,10,27,FF,F,31,A8,E0,7A,2E,27,3316
81 DATA B6,2E,27,48,34,20,10,8E,2E,28,AE,A6,35,20,7E,29,FF,10,8C,5,E0,10,27,FE,F0,31,A8,20,B6,2E,27,7C,3088
82 DATA 2E,27,48,34,20,10,8E,2E,28,AF,A6,35,20,C6,20,A6,80,81,D,27,7,81,20,25,6,5A,26,F3,7E,29,FF,BC,2808
83 DATA 4D,8E,25,EB,7E,29,FF,34,77,1A,50,10,8E,0,60,86,88,F6,FF,22,C8,2,F7,FF,22,4A,26,FD,31,3F,26,EF,3741
84 DATA 35,F7,34,16,9E,88,81,20,25,36,D6,89,C4,1F,10,26,0,30,D,68,27,2C,97,68,86,60,C6,14,A1,1F,27,20,2766
85 DATA A1,82,27,5,5A,26,F9,20,17,50,CB,14,D7,69,30,1,A6,84,A7,85,86,60,A7,80,A,69,26,F4,30,85,9F,88,3435
86 DATA 4F,8C,86,1,97,68,35,96,FE,4D,8E,C6,C,F7,2E,25,20,13,FE,2E,21,C6,20,A6,C0,81,D,27,3,5A,26,F7,3356
87 DATA 20,3D,FE,2E,21,33,5F,C6,20,A6,C4,33,5F,11,B3,4D,8C,10,23,FC,CC,81,D,27,5,5A,26,ED,20,13,A6,C4,3194
88 DATA 81,D,27,D,33,5F,11,B3,4D,8C,10,23,FC,B3,5A,26,ED,33,41,7D,2E,25,27,7,7A,2E,25,26,C8,20,0,11,2462
89 DATA B3,4D,8C,25,F,11,B3,4D,8E,22,9,FF,2E,21,FF,2E,23,7E,28,B0,FE,2E,21,7E,28,B0,BD,34,87,7F,2E,4A,3216
90 DATA 7E,23,53,7D,4D,88,27,B,7F,4D,88,86,FF,B7,2E,4A,86,42,39,7F,FF,DE,AD,9F,A0,0,34,1,7F,FF,DF,35,3728
91 DATA 1,27,F0,BD,2D,C9,81,3,27,E8,8E,4,0,9F,88,39,9E,88,8C,5,E0,24,CC,C6,60,E7,80,8C,5,E0,26,F9,3828
92 DATA 9F,88,20,BF,BD,43,47,7F,FF,DE,BD,A9,28,34,1,7F,FF,DF,35,1,F6,FF,22,54,25,5C,BE,4D,90,7D,4D,98,4072
93 DATA 27,3,BE,4D,94,7D,4D,98,27,7,BC,4D,96,27,2F,20,5,BC,4D,8E,27,28,7F,FF,DE,AD,9F,A0,0,34,1,7F,3157
94 DATA FF,DF,35,1,81,3,27,16,A6,80,BD,43,25,7F,FF,DE,BD,A3,A,34,1,7F,FF,DF,35,1,8D,8,20,C7,86,D,3517
95 DATA 8D,2,20,68,81,A,27,D,7F,FF,DE,BD,A2,BF,34,1,7F,FF,DF,35,1,39,BD,43,47,7F,FF,DE,BD,A9,28,34,3766
96 DATA 1,7F,FF,DF,35,1,8E,2D,D4,A6,80,7D,1,1A,27,3,BD,2D,C9,BD,43,25,7F,FF,DE,BD,A3,A,34,1,7F,FF,3676
97 DATA DF,35,1,8C,2D,ED,26,E1,7F,FF,DE,BD,A1,B1,34,1,7F,FF,DF,35,1,81,3,27,13,BD,43,47,7F,FF,DE,BD,4115
98 DATA A9,28,34,1,7F,FF,DF,35,1,7E,2C,5A,BD,43,47,7F,FF,DE,BD,A9,28,34,1,7F,FF,DF,35,1,FE,2E,21,7E,3681
99 DATA 28,B0,BD,43,47,7F,FF,DE,BD,A9,28,34,1,7F,FF,DF,35,1,8E,2D,ED,A6,80,27,1A,7D,1,1A,27,3,BD,2D,3468
100 DATA C9,BD,43,25,7F,FF,DE,BD,A3,A,34,1,7F,FF,DF,35,1,20,E2,BD,43,AA,25,B4,C1,2,25,B0,5A,F7,2E,26,3902
101 DATA FE,4D,8C,8E,2,DD,F6,2E,26,27,A1,31,C4,A6,C4,20,15,11,B3,4D,8E,24,95,5A,27,1C,33,41,11,B3,4D,8E,3314
102 DATA 24,8A,30,1,A6,C4,A1,84,27,E7,33,41,11,B3,4D,8E,10,24,FF,78,20,CD,33,41,FF,2E,23,33,A4,FF,2E,21,3344
103 DATA BD,43,47,7F,FF,DE,BD,A9,28,34,1,7F,FF,DF,35,1,7E,28,B0,81,60,23,6,81,7A,22,2,84,5F,39,50,72,3414
104 DATA 69,6E,74,65,72,20,6E,6F,74,20,72,65,61,64,79,2C,20,52,65,74,72,79,3F,53,65,61,72,63,68,20,66,6F,2996
105 DATA 72,3A,D,0,53,74,61,72,74,2F,45,6E,64,20,70,6F,69,6E,74,73,20,63,6F,6E,66,6C,69,63,74,D,48,69,2810
106 DATA 74,20,61,6E,79,20,6B,65,79,20,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,869
107 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,40,F2,0,B6,18,57,B7,FF,22,BD,2B,3D,B6,1,1547
108 DATA 1A,B7,32,7B,BD,43,47,7F,FF,DE,BD,A9,28,34,1,7F,FF,DF,35,1,8E,31,94,BD,31,5D,7F,FF,DE,BD,A1,B1,4224
109 DATA 34,1,7F,FF,DF,35,1,81,3,10,27,2,FB,81,31,10,27,1,C7,81,32,27,2,20,CB,BD,43,47,7F,FF,DE,BD,3160
110 DATA A9,28,34,1,7F,FF,DF,35,1,8E,32,1,BD,31,5D,7F,FF,DE,BD,A1,B1,34,1,7F,FF,DF,35,1,81,3,10,27,3475
111 DATA 2,C6,81,31,27,4,81,32,26,CF,BD,43,25,7F,FF,DE,BD,A3,A,34,1,7F,FF,DF,35,1,80,30,B7,1,E2,8E,3544
112 DATA 32,13,BD,31,5D,8E,1,DA,C6,8,86,20,A7,80,5A,26,FB,B6,1,1A,B7,32,7B,86,FF,B7,1,1A,BD,43,AA,10,3413
113 DATA 25,2,85,C1,2,10,25,2,7F,5A,8E,2,DD,CE,1,DA,A6,80,A7,C0,5A,26,F9,B6,1,E2,81,2,10,26,0,76,3171
114 DATA 8E,32,1F,BD,31,5D,9E,88,BF,32,76,BE,32,76,9F,88,BD,43,3E,BD,43,AA,10,25,2,4E,8E,0,0,7D,2,DD,3227
115 DATA 27,D,8E,2,DD,BD,42,1E,27,5,BD,31,87,20,DC,BF,1,E7,8E,32,4B,BD,31,5D,9E,88,BF,32,76,BE,32,76,3403
116 DATA 9F,88,BD,43,3E,BD,43,AA,10,25,2,1C,8E,0,0,7D,2,DD,27,D,8E,2,DD,BD,42,1E,27,5,BD,31,87,20,2763
117 DATA DC,BF,1,E5,86,D,BD,43,25,7F,FF,DE,BD,A3,A,34,1,7F,FF,DF,35,1,8E,0,0,F6,1,E2,C1,2,27,2,3610
118 DATA 30,1F,BF,1,E3,8E,31,D3,BD,31,5D,7F,FF,DE,BD,A1,B1,34,1,7F,FF,DF,35,1,81,3,10,27,1,CA,CC,0,3668
119 DATA F,DD,7C,8E,1,DA,9F,7E,7F,FF,DE,BD,A7,E5,34,1,7F,FF,DF,35,1,BE,4D,90,7D,4D,98,27,3,BE,4D,94,4129
120 DATA BF,32,76,5F,30,1,5C,27,F,7D,4D,98,27,5,BC,4D,96,20,3,BC,4D,8E,23,EC,5A,F7,32,7A,BE,32,76,10,3058
121 DATA 8E,3D,33,10,9F,7E,A6,80,A7,A0,5A,26,F9,F6,32,7A,8D,3E,86,1,97,7C,D7,7D,7F,FF,DE,BD,A7,E5,34,1,4166
122 DATA 7F,FF,DF,35,1,BE,32,76,F6,32,7A,3A,7D,4D,98,27,5,BC,4D,96,20,3,BC,4D,8E,25,A5,CC,FF,0,DD,7C,3754
123 DATA 7F,FF,DE,BD,A7,E5,34,1,7F,FF,DF,35,1,7E,31,7E,10,8E,0,0,31,3F,12,26,FB,39,BD,43,47,7F,FF,DE,3767
124 DATA BD,A9,28,34,1,7F,FF,DF,35,1,8E,4,9,9F,88,BD,43,3E,8E,31,C4,BD,31,5D,7F,FF,DE,BD,A1,B1,34,1,3780
125 DATA 7F,FF,DF,35,1,81,3,10,27,0,FD,7F,4D,98,BD,43,47,7F,FF,DE,BD,A9,28,34,1,7F,FF,DF,35,1,8E,31,3687
126 DATA F8,BD,31,5D,8E,1,DA,9F,7E,7F,FF,DE,BD,A7,1,34,1,7F,FF,DF,35,1,DA,7C,26,EF,8E,4,0,9F,88,BD,4147
127 DATA 43,3E,8E,31,FA,BD,31,5D,86,80,B7,1,E2,8E,1,DA,BD,31,5D,8E,3D,33,9F,7E,BE,4D,90,BF,32,76,7F,FF,3956
128 DATA DE,BD,A7,7C,34,1,7F,FF,DF,35,1,7F,FF,DE,BD,A7,B,34,1,7F,FF,DF,35,1,D6,81,26,35,BF,32,78,10,3908
129 DATA 8E,3D,33,10,9F,7E,BE,32,76,A6,A0,A7,80,BC,4D,92,22,17,10,BC,32,78,25,F1,BF,32,76,D6,7C,2A,CC,30,3645
130 DATA 1F,BF,4D,8E,BF,4D,96,20,1C,8E,31,FC,BD,31,5D,20,5,8E,31,F0,8D,31,7F,FF,DE,BD,A7,E9,34,1,7F,FF,3979
131 DATA DF,35,1,8D,F,7F,FF,DE,BD,A7,E9,34,1,7F,FF,DF,35,1,20,34,8E,31,E1,8D,E,7F,FF,DE,BD,A1,B1,34,4176
132 DATA 1,7F,FF,DF,35,1,39,A6,84,84,7F,7D,1,1A,27,3,BD,2D,C9,BD,43,25,7F,FF,DE,BD,A3,A,34,1,7F,FF,3597
133 DATA DF,35,1,6D,80,2A,E0,39,B6,32,7B,B7,1,1A,7E,23,53,BE,32,76,86,60,A7,80,8C,6,0,25,F9,39,D,D,3044
134 DATA 31,20,54,61,70,65,20,74,6F,20,62,75,66,66,65,72,D,32,20,42,75,66,66,65,72,20,74,6F,20,74,61,70,2713
135 DATA 65,D,D,53,65,6C,65,63,74,69,6F,6E,3F,A0,54,61,70,65,20,74,6F,20,62,75,66,66,65,72,D,52,65,61,2896
136 DATA 64,79,20,63,61,73,73,65,74,74,65,20,50,72,65,73,73,20,61,6E,79,20,6B,65,79,A0,D,D,45,72,72,6F,2985
137 DATA 72,A0,53,A0,46,A0,D,46,55,4C,CC,31,3D,41,53,43,49,49,2C,20,32,3D,42,49,4E,41,52,59,A0,D,D,46,2562
138 DATA 69,6C,65,6E,61,6D,65,3A,A0,D,D,53,74,61,72,74,20,61,64,64,72,65,73,73,20,69,6E,20,68,65,78,D,2892
139 DATA 6F,72,20,3C,45,4E,54,45,52,3E,20,66,6F,72,20,7A,65,72,6F,3A,A0,D,45,78,65,63,20,20,61,64,64,72,2695
140 DATA 65,73,73,20,69,6E,20,68,65,78,D,6F,72,20,3C,45,4E,54,45,52,3E,20,66,6F,72,20,7A,65,72,6F,3A,A0,2766
141 DATA 0,0,0,0,0,0,0,B6,18,57,B7,FF,22,BD,34,68,BD,43,47,7F,FF,DE,BD,A9,28,34,1,7F,FF,DF,35,1,3151
142 DATA 7F,FF,DE,AD,9F,A0,0,34,1,7F,FF,DF,35,1,27,F0,B7,34,65,81,5C,10,27,1,48,81,3,10,27,1,39,81,3146
143 DATA A,10,27,0,E7,81,5E,10,27,0,EF,81,9,10,27,0,F7,81,8,10,27,0,FE,81,D,27,15,81,5B,27,C1,81,2482
144 DATA C,26,7,86,5B,B7,34,65,20,63,81,20,25,B2,20,5D,9E,88,BF,34,66,86,FF,A7,84,86,9F,BD,43,19,1F,10,3198
145 DATA C4,1F,C1,1F,27,F,30,1,86,60,A7,84,8D,30,86,20,BD,43,19,20,E9,30,1,9F,88,BD,43,3E,30,88,E0,C6,3252
146 DATA 1F,86,FF,A1,84,26,10,BC,34,66,24,64,86,60,A7,84,8D,C,86,20,BD,43,19,30,1,5A,26,E5,20,52,34,20,2978
147 DATA 10,9E,88,9F,88,BD,43,3E,10,9F,88,35,A0,9E,88,1F,10,C4,3F,C1,20,27,8,C1,0,27,4,30,1F,20,F0,86,3040
148 DATA FF,9C,88,27,15,A1,84,26,D,86,60,A7,84,8D,CF,86,20,BD,43,19,20,4,30,1,20,E7,BD,43,3E,B6,34,65,3276
149 DATA BD,43,25,7F,FF,DE,BD,A3,A,34,1,7F,FF,DF,35,1,9E,88,A6,84,B7,34,64,8C,5,E0,25,7,8E,5,DF,9F,3840
150 DATA 88,20,ED,86,EF,A7,84,8D,95,7E,32,96,9E,88,30,88,20,8C,5,DF,10,22,FE,E8,20,26,9E,88,30,88,E0,8C,4019
151 DATA 4,0,10,25,FE,DA,20,18,9E,88,30,1,8C,5,DF,10,22,FE,CD,20,B,9E,88,30,1F,8C,4,0,10,25,FE,C0,2864
152 DATA A6,84,F6,34,64,E7,9F,0,88,B7,34,64,9F,88,86,EF,A7,84,BD,43,3E,7E,32,96,B6,34,64,A7,9F,0,88,8D,4105
153 DATA 6,BD,34,87,7E,23,53,8E,5,DF,86,60,A1,84,26,8,30,1F,8C,3,FF,26,F5,39,30,1,BF,34,62,FE,4D,8E,3245
154 DATA 11,B3,4D,92,27,F1,10,8E,4,0,A6,A0,81,FF,26,19,10,BC,34,62,24,F,1F,20,C4,3F,C1,20,27,7,5D,27,2764
155 DATA 4,31,21,20,EB,86,D,20,E,81,1F,22,4,8A,60,20,6,81,60,25,2,84,BF,11,B3,4D,92,24,8,A7,C0,10,2441
156 DATA BC,34,62,25,C5,FF,4D,8E,FF,4D,96,39,0,0,60,0,0,0,1A,50,BE,1,D,8C,34,9A,27,12,BF,34,F5,8E,3024
157 DATA 34,9A,BF,1,D,86,34,B7,FF,1,4C,B7,FF,3,1C,AF,39,1A,50,BE,1,D,8C,34,9A,26,6,BE,34,F5,BF,1,3192
158 DATA D,1C,AF,39,B6,FF,3,2A,55,B6,FF,2,B6,9,85,27,10,7A,9,85,26,B,B6,9,86,84,B0,B7,9,86,B7,FF,3368
159 DATA 40,8E,1,52,A6,80,81,FF,26,17,8C,1,5A,26,F5,7C,34,F7,B6,34,F7,81,6,26,25,7F,34,F7,7F,34,F8,20,3541
160 DATA 1D,7C,34,F8,B6,34,F8,81,28,26,13,80,4,B7,34,F8,8E,1,52,A6,84,8A,3F,A7,80,8C,1,5A,26,F5,3B,0,3368
161 DATA 0,0,0,B6,18,57,B7,FF,22,10,DE,27,BD,43,47,7F,FF,DE,BD,A9,28,34,1,7F,FF,DF,35,1,BE,1,8F,8C,3557
162 DATA 3B,71,27,17,B6,1,8E,B7,3B,B8,BE,1,8F,BF,3B,B9,86,7E,B7,1,8E,8E,3B,71,BF,1,8F,7F,FF,DE,BD,A4,3946
163 DATA 2D,34,1,7F,FF,DF,35,1,F,78,8E,3C,ED,BD,3B,52,7F,FF,DE,BD,A1,B1,34,1,7F,FF,DF,35,1,81,3,27,3675
164 DATA 21,BD,43,25,7F,FF,DE,BD,A3,A,34,1,7F,FF,DF,35,1,8E,4,60,81,31,27,19,8E,4,40,81,32,27,52,7E,3124
165 DATA 34,FF,B6,3B,B8,B7,1,8E,BE,3B,B9,BF,1,8F,7E,23,53,9F,88,86,D,BD,43,25,7F,FF,DE,BD,A3,A,34,1,3825
166 DATA 7F,FF,DF,35,1,8E,5,0,9F,88,BD,43,3E,BD,39,10,BD,37,C4,10,27,FF,52,BE,4D,90,BF,3B,B6,BF,4D,94,3772
167 DATA 7F,4D,98,BD,38,88,BE,3B,B6,BF,4D,8E,BF,4D,96,20,B1,9F,88,86,D,BD,43,25,7F,FF,DE,BD,A3,A,34,1,3959
168 DATA 7F,FF,DF,35,1,8E,5,0,9F,88,BD,43,3E,BD,39,10,8D,60,10,27,FF,13,BE,4D,90,7D,4D,98,27,3,BE,4D,3321
169 DATA 94,BF,3B,B6,34,16,86,D,7D,4D,98,27,14,BE,4D,96,BF,3B,B3,E6,84,F7,3B,B5,BC,4D,92,25,2,30,1,20,3440
170 DATA 12,BE,4D,8E,BF,3B,B3,E6,84,F7,3B,B5,BC,4D,92,25,2,30,1,A7,84,35,16,BD,37,80,BE,3B,B3,7D,4D,98,3732
171 DATA 27,5,BF,4D,96,20,3,BF,4D,8E,F6,3B,B5,E7,84,7E,35,78,7D,3B,BB,10,27,2,AD,7D,4D,87,26,F,7F,FF,3428
172 DATA DE,BD,C6,5F,34,1,7F,FF,DF,35,1,20,D,7F,FF,DE,BD,C6,8C,34,1,7F,FF,DF,35,1,7D,9,73,27,1C,8E,3762
173 DATA 3C,C4,BD,3B,52,7F,FF,DE,BD,A1,B1,34,1,7F,FF,DF,35,1,BD,2D,C9,81,59,27,2,4F,39,BD,43,47,7F,FF,3968
174 DATA DE,BD,A9,28,34,1,7F,FF,DF,35,1,8E,4,40,9F,88,BD,43,3E,8E,3B,C0,BD,3B,52,8E,9,4C,C6,8,A6,80,3605
175 DATA BD,43,25,7F,FF,DE,BD,A3,A,34,1,7F,FF,DF,35,1,5A,26,EB,86,2F,BD,43,25,7F,FF,DE,BD,A3,A,34,1,3827
176 DATA 7F,FF,DF,35,1,8E,9,54,C6,3,A6,80,BD,43,25,7F,FF,DE,BD,A3,A,34,1,7F,FF,DF,35,1,5A,26,EB,8E,3865
177 DATA 3B,CB,BD,3B,52,7F,FF,DE,BD,A1,B1,34,1,7F,FF,DF,35,1,81,3,10,27,FD,F1,BD,43,25,7F,FF,DE,BD,A3,4365
178 DATA A,34,1,7F,FF,DF,35,1,34,2,86,D,BD,43,25,7F,FF,DE,BD,A3,A,34,1,7F,FF,DF,35,1,35,2,8E,0,3091
179 DATA FF,81,31,27,1E,8E,0,0,81,32,27,17,8E,2,0,81,33,27,10,8E,1,FF,81,34,27,9,8E,1,0,81,35,10,2232
180 DATA 26,FF,38,BF,9,57,7D,4D,87,26,F,7F,FF,DE,BD,C9,56,34,1,7F,FF,DF,35,1,20,D,7F,FF,DE,BD,CA,4,3862
181 DATA 34,1,7F,FF,DF,35,1,7E,39,D,BE,3B,B6,A6,80,7D,4D,98,27,5,BC,4D,96,20,3,BC,4D,8E,10,22,1,6A,3045
182 DATA BF,3B,B6,7D,4D,87,26,F,7F,FF,DE,BD,CB,52,34,1,7F,FF,DF,35,1,20,D,7F,FF,DE,BD,CC,24,34,1,7F,3870
183 DATA FF,DF,35,1,D,70,27,C2,8E,3C,92,7E,38,DD,7D,3B,BB,10,27,1,31,7D,4D,87,26,F,7F,FF,DE,BD,C6,5F,3593
184 DATA 34,1,7F,FF,DF,35,1,20,D,7F,FF,DE,BD,C6,8C,34,1,7F,FF,DF,35,1,7D,9,73,26,6,8E,3C,73,7E,38,3392
185 DATA DF,7D,4D,87,26,F,7F,FF,DE,BD,C9,59,34,1,7F,FF,DF,35,1,20,D,7F,FF,DE,BD,CA,7,34,1,7F,FF,DF,4113
186 DATA 35,1,FE,9,57,8E,3B,E2,C6,11,11,83,0,FF,27,31,8E,3B,F6,C6,16,11,83,0,0,27,26,8E,3C,F,C6,14,2864
187 DATA 11,83,2,0,27,1B,8E,3C,26,C6,B,11,83,1,FF,27,10,8E,3C,34,C6,B,11,83,1,0,27,5,8E,3C,42,C6,2246
188 DATA 11,A6,80,7D,1,1A,27,3,BD,2D,C9,BD,43,25,7F,FF,DE,BD,A3,A,34,1,7F,FF,DF,35,1,5A,26,E3,C6,2,3466
189 DATA 10,8E,0,0,31,3F,26,FC,10,8E,0,0,5A,26,F5,86,1,39,8D,27,BE,3B,B6,A7,80,BC,4D,92,22,5,BF,3B,2889
190 DATA B6,20,EF,8E,38,A3,34,10,8E,3C,82,20,3C,7F,FF,DE,BD,A1,B1,34,1,7F,0,0,0,0,0,0,0,0,0,0,2617
191 DATA "X"
