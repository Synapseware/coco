RUNME1STBAS   ��&W 
�40:�5:�"   This is just a note for those of you who have the complete ARC file." &� �"   This ARC should contain this little  program (RUNME1ST/BAS), the loader (PLAY/BAS) and the main program	 (PLAYMAIN/BAS) as well as three sample" ') �"Exec-Music files for your enjoyment." '� (�:�"   Two of the music files I found on various BBSs and were not programmed by myself.  One, however: 'FANFARE/BIN' is" ( 2�"a piece of my own composition that I wrote way back in high school.  I hope  you enjoy it." (� <�:�"   Please feel free to upload or give   this to a friend.  All I ask is that if you do so, please keep it as an ARCed   file, with all 6 files included, even   this one.  Thanks, and enjoy!!" ) F�:�"Now   RUN 'PLAY/BAS' to start..."   PLAY    BAS   L��& 
�40:�5 &} �" Loader for LDG Free Software's":�" Exec-Music Auto Player.":�" (c) 1995 LDG Free Software" ' �:�"This program acts like a jukebox, and   will automatically play all Exec-Music  files on a disk for you, one after the  other." '� (�:�"IMPORTANT!  All Exec-Music files on the disk to be loaded MUST have a /BIN extention to be recognized as a music   file, and all /BIN files on the disk" '� 2�"*MUST* be Exec-Music files!!":� (� <�"If you want to skip using this loader inthe future, just remember that you MUST MANUALLY DO A 'PCLEAR1' before loading  the main program, or the computer will  crash if you load a longer music file." (� F�"<This loader performs a PCLEAR1>" (� P�:��" Hit <ENTER> ";A$ )� Z�:�" NOTE:":�"This program will play most Exec-Music  files that are 6 disk grans and smaller in size.  Having an Exec-Music file that's over 6 disk grans on the disk to" *{ d�"be loaded will probably cause the program to crash. Therefore, before running this program, make sure you havetransferred any Exec-Music files that   are over 6 disk grans in size onto " *� n�"another disk and taken them off the diskyou wish to load." +e x�:�"Also, note that all Exec-Music files forthis program *MUST* be located (start)  higher in memory than 11,000.  So an Exec-Music file that starts at 12288 or" ,
 ��"24576 or similar number will work just  fine with this program, but one that starts low in memory, like 4096 will cause the program to crash (since the" ,1 ��"program resides in low memory)." ,X ��:��" Hit <ENTER> ";A$ ,� ��:�"You can get around this by examining theExec-Music file to find out the START,  END, and EXEC addresses for it.  Then   just do something like this:" -� ��"Say for example, the current START is   4096, the END is 6170, and the EXEC address is 4619.  Do this to move the   start from 4096 to 12288 (a safe place):"; .� ��"FOR X=4096 TO 6170:POKE X+8192,PEEK(X): NEXT   That will copy the program into ahigher spot in memory starting at 12288.Then when finished, do this to save: SAVEM'name',12288,12288+(6170-4096), 12288+(4619-4096)   and it'll save it" /4 ��"on disk so that when you load it later, it'll have a 12288 start.  Of course thenumbers will be different with each file -- this is just an example." /� ȇ"Hopefully you'll know the routines on   how to find out the START/END/EXEC addresses.  I don't want to get too deepinto this now.  If you're stuck, you canalways write me for help." 0 һ�" Hit <ENTER> ";A$ 0s ܞ:�"Again, in order for the program to work properly, you must observe these rules:" 1E �:�"*All Exec-Music files on disk must have  a /BIN extention":�"*All /BIN files on disk MUST be
 Exec-Music Files":�"*All Exec-Music files must be 6 disk grans or less.  If a larger one is on" 2* ��" the disk, it must be transferred off onto another disk.":�"*All Exec-Music files must reside in memory at or higher than approx 11000.  Files that reside in low memory like 4096 must be moved into higher memory" 2� ��" (anything above 11000 is fine) and saved as such on the disk).":�"*You must do a PCLEAR1 before loading the main program if you skip this loader in the future." 3�:��" Hit <ENTER> ";A$ 3��:�"If you have files on your disk that won't work with this program (ie, over  6 disk grans, or too low in memory, etc)and you don't want to move them to" 4Q�"another disk, an easy solution is just  to give those files that the program won't load right a different extention. As long as you change the extention to" 4�"�"something other than /BIN, the player   will skip past such files." 4�,�:��" Hit <ENTER> ";A$ 5�6�:�"Note that this isn't a polished program.I made it up in a very short time just  for myself, but later thought others might find it useful.  Feel free to tinker around with it yourself.  That's what's so fun about the CoCo..." 6-@�:�"If you skip this loader in the future,  remember again to always do a PCLEAR1   before loading the main program!" 6RJ�:�"Larry Greenfield, Oct. 1995" 6�T�"17300 Santa Clara St.":�"Fountain Valley, Ca. 92708 USA":�"Email: lgreenf@cati.csufresno.edu" 75^�"(Note: I live nowhere near Fresno.  Theywere just nice enough to give me a free email-only account that I telnet into)." 7Eh�:�"Enjoy!" 7xr�:��"Hit BREAK to abort or ENTER to start ";A$ 7�|�"PCLEAR1ing and LOADing main program..." 7���1 7���"PLAYMAIN/BAS"   PLAYMAINBAS   0�f&u 
�&HE046,117:�&HFE05,28:�&HFE06,&H32:�&HFE07,&H80:�&HF688,&H32:�&HF689,&H80:�&HF875,&H30:�&HF876,&HE0:�&HF8F4,28 &� �80:�:�4:�3,2:�12,63:�13,0 &� �&HF688,&H31:�&HFE06,&H31:�&HF6C6,183:�&HF6D6,0:�&HF6D7,191:�&HFFD8,0:�&HF6D5,32 ' (�&HF670,141:�&HF671,26 '� 2�:�"If not using the loader, did you remember to PCLEAR1 first before loading this?":�"If not, BREAK now, PCLEAR1, and load again.":��"Hit BREAK to stop or ENTER to begin ";A$ (t <�:�" Larry Greenfield's Automatic EXEC-music Player":�" (c) 1995 LDG Free Software":�:�"Make sure all /BIN files on disk are EXEC music files." (� F��"Insert a disk and press ENTER to begin... ";A$ (� P� 0,3:�X�1 � 24:�:�:� 0,3 (� Z�1000 (� d� P9$(50,10),PR$(50) ) n�"/BIN files on this disk..." )K x�"--->> Order of play is left to right, row by row --->>" )[ �� Z9�3 � 11 )p ��D,17,Z9,A9$,B9$ )� �X9$�A9$:��190 )� �X9$�B9$:��190 )� ��Z9 )� ��� 280 )� �� J9�1 � 128 � 32 )� �R9�R9�1 )� �P9$(R9,1)���(X9$,J9,8) * ܅ ��(P9$(R9,1),1)���(255)� R9�R9�1:��280 *= � ��(P9$(R9,1),1)���(0) � R9�R9�1:��260 *Z �P9$(R9,2)���(X9$,J9�8,3) *{ �� P9$(R9,2)��"BIN" � R9�R9�1 *�� J9 *�� *�� XX�1 � R9 *�"PR$(XX)�P9$(XX,1) *�,� *�6:�* PR$()=FILE NAMES, R9=THE NUMBER OF FILES *�@� X�1 � R9 +J��TB);PR$(X); +(T� TB�19 � TB�0:�:��360 +4^TB�TB�7 +:h� +Rr:�*** START LOADING +�|� 0,20:��"Hit ENTER to start concert ";AG$:�0,20:� +��� X�1 � R9 +��� 0,23:�:�:�:�0,23 +���"Song: ";:�PR$(X) +��� 37,23:�"Loading" +���M PR$(X) +��� RR�1 � 2000:� ,�� 37,23:�"Playing" ,1�EX���(157)�256���(158) ,:֢ EX ,G�� 0,23:� ,M� ,��� 0,23:�:�0,23:�" Concert Finished.  Another Disk? (Y/N)" ,��AA$���:�AA$�""�510 ,�� AA$�"Y" � AA$�"y" � � 60 ,�� AA$�"N" � AA$�"n" � 550 ,���500 -e&� 0,3:� X�1 � 24:�:�:� 0,3:�" Thanks For Using LDG Free Software's Automatic EXEC Music Player."   FANFARE BIN  r@   0   f b�"�c���d���eU�� 356�4h �P�&��L�
L�L�L_����0������7���' ����' ��7�7�7�7�4�F�FF�F�FF�	������������O_������:&�0���:&�0������������5� f����
��!  �������� ������������1?'
!  !   �
&��9�����4���>��#977770� �5���7��#5h9  LDA@ #$FF@	 STA@ 0,X@ A PORT OUTPUT@	 STA@ 2,X@ B PORT OUTPUT@	 LDA@ #4@	 STA@ 1,X@	 STA@ 3,X@	 LDA@ # !#%')+-.0235679:;<<=>>@?>>=<<;:987653210.-,+)('&%#"!  @  !"#$$%&''()**++,,@-,,++*))('&%$##"! @ !!""###@$###""! 
	@ 	
 "%'*,.024689;<=>>@?>>=<;:98764320/.,+*)('&&%$$$@#@$@	%@$@#@"@!@ @@@@@	@@	@ 	 !"#$%'()*+,-./01234567889::;;<<==@>@
?@>===<<;;::9988766544322100/..-,,+**))(''&&%%%$$###"""@!@
 @	@
 @
@
		@@
 @	
  !"##$%&&'())*+,,-../001223345566778899::;;;<<<@=@>@?@>@=<<<;;;::998877665543322100/..-,,+*))('&&%$##"!  

		@@@ @@		

,x�X,x�X3,x�X,x�X,x�X"�Q�	� ��)�,��'7,�
c"�aQ�3"�aQZ"�aQ�"�aQ�'7,��"�Qx)�,x�.�ax�.�ax�f,��
cf"�����@ 3@ ,@ a@ ,@ "�@  @ a@ aQxX,�},@ a@ ,@ "�@  @ a@ aQxX,�},@ a@ ,@ ���Q@ �@ ��
c�@ x@ x��Xx@ x@ x@ x��	A���	Ax����	A���	A���	A���	A�x^"�
c	A�
c��
c�"�
c�"Q���"x���x���Q���Q���"�x��"�x��Q
cX�"x
cX�x
cX�x
cX�Q
cX�Q�
c�"�x�
c"�x�
c'7@ '7@ �   	�� ��	�'7��	�.���1"����"����"����'7@ �'7�  �'7�	��'7���"�Q��"�x��"�x��"'7Q��".� ��.� ��.� ��"�a��Q��XQ���Qx�
c���  ����Q	��Q	��Q	��a��  a���a���a��X����3������������x���������
c�������	����	���	��Q��Q��Q��a  ��aX��a���a���,}	��3,}	��,}	��,}	��,}
c�Q}
c��}
c�Q}
c�,}	��",}	�E,}	�E,}	�E,}	�Ea���,���"���� ���a���Q���,}�,	�}>Q��XQX�X,	�}�a���aX��,}	��",@ ",}
c�Q}
c��}
c�Q}
c�,}	��"  }@ ",}
c�,x
c�,�
c�,x
c�,}	��",@ ",}
c�Q}
c��}
c�Q}
c�,}	��"  }@ ",}
c�,x
c�,�
c�,x
c�}	�>�	�>�	�>�	�>�	�>�	�>�	�>�	�>�	�>�	�>�	�>�	�>����	����	����	����	����	�	�>�	�>�	�>�	�>�	�>�x�
c�x�
c�x�
c�x�
c�x�
c��}	���	���	���	���	��>��>��}>���������>��	�>�>>�}�>�}��}��^����x����>E�>E�>E�^����x���>�>�}>��>�>��}>���������>��	�>�>>�}�>�}��}��^��,�,�,��>�E>�E>�E>�E>�E>�E�^�",�^�,�^� �Z
cXD"��^,��  
,��  
"�  ,x�Qx	�  
,�  
ax��
ax	��
,x��
,x�
,	�  
,�  
,x�  
,x�  
,�X
,�X
,�	�  
,�  
,�>�
,���
,��
,��
,x��
,��
,��,��,���
,}��
,x��,�^,��
,�^
,�^,�^+,�^aQx^
aQ��
aQ}�
aQx�
,���}��
}�
Q}	��
Q}��
x�x�^"�x�^
"��^
"���^
,x��
x��
��
x�^
x^
�}E
xE
Qx	�E
Q}	�E
x�^
��^
�^
�^
�	��E	��E
	��E
	��E�	��Ex��
���
x�����E�	��E
��E
��E���Ex��
Q��
,x��}	�E�}�E
�}�E
�}�E�}	�Ex�
�	�}
x��
x��
���E�>�E
���E
�	��E��E���E�>�E"�� "��
 �>,>ax��
,�
Q�	��,�+�}	��
}	��
}	��}	���}	��x^
�	��
x���>E+"�^ "�^
 ���,Q>'7,}	� ��}� ��>"��ZX ��>V�>�b��qQ���xX��
x���
x��XQ���,x�
aQ��
 ,x�
 x�
aQ��+.�ax�
.�aQ�
.�ax�
.�ax�
,,x�
,,�
"� �
"��x�
'7 ��
"�ax�
 ,�
 x�
"�a��
"����
"�Q��
"�x��
Q���xX��
x���
x��XQ���,x�
aQ��
 ,x�
 x�
aQ��+'7Q�� a���
a�	�XQ�	�	�,	AX
aQ	�X
 ,X
 	AX
aQ��Q����  �� ��	A�
��	����X���
���X
���
���
��	����	��  ��
  ���
  ��  ���  �X�  ��
�  ��
�  ��  ���  X�  ��
  x��
  ��
  �	��
  xX�
  x��
  ���
  ���
�  �
x  ��
�  �
�  	��
x  X�
x  ��
�  ��
�  ��
����
�x��
Q���
Q���
x�������
����
����
�x��
Q���
Q���
x��������	�����������	���x���
����
�x��
x���
����Q���Q���Qx��Q���Q���Q���
Qx��
Q���
Qx��
Q���Q���Q���Q�
c�Q�	��Q���Q�	��
Q�
c�
Q���
Q�	��
Q�����@ �	��� ����
	����	����
c���
�	���

cX�
�1�
�	����	���
c��1
�	��1

cX1
�X1
�	���
c���
	����
�X���X��	����+�	��� ����
	����	����
c���
�	���

cX�
�1�
�	����	���
c���
�	���

cX�
�X�
�����	���

c��
�
cX��
cX��	���+��X� ��X�
��XX�	�X�X�
��X�
�X���X��	�X�>	��	�>	��
	�>	��
	�>	��}	��x�	��
}	��
�	�	���>E�	�>E
�	�>E
�	�>E�}�E�xX�
�}��
������E��E
��E
��E�>E��E�>E�XE�>�E�@ �������[	�>��	�>��[������[}	��E}	��E[x���x���[}	��}	��[x���x���[�}	���}	��[��
c�}Q���},x�XF,x�X,x�X,x�X,x�XQx�X,��Xa��X
a��X
,�^F,�^,�^,�^,��	AQ��	A�x�	AQx�	A,x�F,x�,x�,x�,x
c�Qx
c��x�Qx�%,x�XF,x�X,x�X,��X"�Q�	� ��)�,��'7,�
c
"�aQ�F"�aQ�"�aQ�"�aQ�'7,��"�Qx)�,x�(.�ax�
.�ax�x@ ,��1x@ "�@ ("�  ^  ("�  �  ("���  ("������� ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��@ ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  � ��@ �����A�3���o� ��M�R�ѱf �C��Y�
�&��   ��  ���  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  ��  �FANFARE�  0 BLACKEYSBIN  �8 M  !#$%'()*+-./01233455677788776665543321100/..-,,++**))(('''8&8'8(8)8('''&&%%$$##""!! 88888


		8			
  o���?q��V��(v�!�J�/�	0	�
P
��C���s_X`w��&���+� �"�$�&�)@+�.M13�7:W=�A|E`I�M�R�Wi\�b ��L��?��#P0��j�ßƟɟ�0� ���9������91��P����Ϧ���Ѧ���Ӧ���՟�9� D��Lë�LƩ�Lɩ�L̷� ������������������������1�&
�' Ǧ�       �9�u��� &O�9���� �&P  F4>NL  F4>N&P  F4>NL      ^  *2>\Z  *2>\ ^  *2>\Z  *2> Z  H4<^$d  H4<^Z  H4<^$d  H4< L  N   P  $T  &V  F4>VF4>V8 &V  F4>VV  F4>V&V  F4>VV  X   Z  *2>ZZ  *2>Z Z  *2>    *2> T  H4<T$T  H4< T  H4<T$T  H4< L  N   P  $T  &V  F4>VF4>V8 &V  F4>Z^  F4>d&V  F4>Z^  d   ^  *2>ZV  *2>P ^  *2>ZV  *2>PV  H4<Z$^  H4<dV  H4<Z$^  H4<dL  N   P  $T  &V  F4>VF4>V8 �  N�HAPPYD  BIN  
�G 6*  "#&')*+-.012457889;;<<>>>G?>>><<;;987754210..-+*)'&$#" G  G"G#G"   
GG GGGGGG	G
G

  o���?q��V��(v�!�J�/�	0	�
P
��C���s_X`w��&���+� �"�$�&�)@+�.M13�7:W=�A|E`I�M�R�Wi\�b�$�$�$�$�$�$�$�$�$�$�$�$�$�$� � � � � � � � � � � � � � � � �$�$�$�$�$�$�$�$�$�$�$�$�$�$�$�$� � � � � � � � � � � � � � � � �?��#�* �)ÿ)ƿ)ɿ)̎- �)�~,��)����)�91��֦���)Ϧ���)Ѧ���)Ӧ���)տ)�9� h��)ë�)Ʃ�)ɩ�)̷� �)��)��)��)��)��)��)��)��)��)��)��)�1?&z)�' ���       �9�� &9���� ������������%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�%�����������������
   G    G 2,<,D2$J2$
N<,R<,N<,   6.@.F6(N6(
R:(T:(R:(   :4"D4"L:,R:,
T<,X<,T<,   6
NF<. F<.NF<.R@:2   (
NF<. F<.NF<.R@:2   (
RJ: J:
RJ: J:RJ:TN<
VP>XR@XR@XR@      
TJD 
TJD   TJD
XJD

\  
\  
XD  
XD T   
XND
T  T  
N<  
N<    N  G 
N< 
R  R  
R@: 
R@:R  G J@:   
TJD 
TJD   TJD
XJD

\  
\  
XD  
XD T  
XND

T  
T  
N<  
N<    N  G 
N< 
R  R  
R@: 
R@:R  G J@:
<,
G <   G <   G <   G 
D2 G D   G @   G <   G 
<   
F6$ G 
F   G 
F   G F   G F   G 
N   
NF6 F6
NF6
JF6
JD4(
F   
FB2&
F   
@6.
@   G 
@   G @   G @   
H@0
H   G 
H   D   @   
J:(
J   G 
J   G 
J   
J:(G J   XJ:.
R  
R  
J  J        
TJD 
TJD   TJD
XJD

\  
\  
XD  
XD T   
XND
T  T  
N<  
N<    N  G 
N< 
R  R  
R@: 
R@:R  G J@:   
TJD 
TJD   TJD
XJD

\  
\  
XD  
XD T  
XND

T  
T  
N<  
N<    N  G 
N< 
R  R  
R@: 
R@:R  G J@:
<,
G <   G <   G <   G 
D2 G D   G @   G <   G 
<   
F6$ G 
F   G 
F   G F   G F   G 
N   
NF6 F6
NF6
JF6
JD4(
F   
FB2&
F   
@6.
@   G 
@   G @   G @   
H@0
H   G 
H   D   @   
J:(
J   G 
J   G 
J   
J:(G J   XJ:.
R  
R  
J  J     2,<,D2$J2$
N<,R<,N<,   6.@.F6(N6(
R:(T:(R:(   :4"D4"L:,R:,
T<,X<,T<,   6
NF<. F<.NF<.R@:2   (
NF<. F<.NF<.R@:2   (
RJ: J:
RJ: J:RJ:TN<
VP>XR@XR@XR@      
TJD 
TJD   TJD
XJD

\  
\  
XD  
XD T   
XND
T  T  
N<  
N<    N  G 
N< 
R  R  
R@: 
R@:R  G J@:   
TJD 
TJD   TJD
XJD

\  
\  
XD  
XD T  
XND

T  
T  
N<  
N<    N  G 
N< 
R  R  
R@: 
R@:R  G J@:   
TJD 
TJD   TJD
XJD

\  
\  
XD  
XD T  
XND
T  T  
N<  
N<    N  G 
N< 
R  R  G 
RJ@ 
RJ@T  
XR@2TN<RJ:N :(J<.(B6$�D2,G �  ,GA                             