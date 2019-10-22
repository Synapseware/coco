        TITLE 6809 Instruction Set Interpreter
        
        ASSUME CS:PROG,DS:PROG

PROG    SEGMENT PUBLIC 'CODE'

        PUBLIC INST,MEM_R8,MEM_R16,MEM_W8,NMI,IRQ,AUX,FIRQ

        EXTRN REGFI:BYTE,REGU:WORD,XLTFLAG:NEAR,BRANCH:BYTE,TOPRAM:WORD,REGY:WORD
        EXTRN UPDFLAG:NEAR,REGF:WORD,REGDP:BYTE,QUIT1:NEAR,INIT0:BYTE,REGX:WORD
        EXTRN BAD:NEAR,CHARGEN:NEAR,IRQSET:BYTE,FIRQSET:BYTE,CRB2:BYTE,REGSP:WORD
        EXTRN CART_FLAG:BYTE,NATIVE:BYTE,RETURN_ADDRESS:WORD,CYCLE_COUNT:BYTE
        EXTRN CLOCK_MODE:BYTE,RETRY_CLOCK:NEAR,MISSED_INTERRUPT:BYTE,REGD:WORD
		EXTRN REGPC:WORD

        EXTRN DEV_R8:NEAR,DEV_W8:NEAR,READ:WORD,WRITE:WORD

REGA	EQU REGD+1
REGB	EQU REGD

;General register maps during execution time:        
; D  -> REGD ( A -> REGA, B -> REGB )
; PC -> SI
; SP -> REGSP
; X  -> REGX
; Y  -> REGY

;Instruction set lookup tables

TABLE   DW Z00,BAD,BAD,Z03,Z04,BAD,Z06,Z07,Z08,Z09,Z0A,BAD,Z0C,Z0D,Z0E,Z0F
        DW bad,bad,Z12,Z13,BAD,BAD,Z16,Z17,BAD,Z19,Z1A,BAD,Z1C,Z1D,Z1E,Z1F
        DW Z20,Z21,Z22,Z23,Z24,Z25,Z26,Z27,Z28,Z29,Z2A,Z2B,Z2C,Z2D,Z2E,Z2F
        DW Z30,Z31,Z32,Z33,Z34,Z35,Z36,Z37,BAD,Z39,Z3A,Z3B,Z3C,Z3D,BAD,Z3F
        DW Z40,BAD,BAD,Z43,Z44,BAD,Z46,Z47,Z48,Z49,Z4A,BAD,Z4C,Z4D,BAD,Z4F
        DW Z50,BAD,BAD,Z53,Z54,BAD,Z56,Z57,Z58,Z59,Z5A,BAD,Z5C,Z5D,BAD,Z5F
        DW Z60,BAD,BAD,Z63,Z64,BAD,Z66,Z67,Z68,Z69,Z6A,BAD,Z6C,Z6D,Z6E,Z6F
        DW Z70,BAD,BAD,Z73,Z74,BAD,Z76,Z77,Z78,Z79,Z7A,BAD,Z7C,Z7D,Z7E,Z7F
        DW Z80,Z81,Z82,Z83,Z84,Z85,Z86,BAD,Z88,Z89,Z8A,Z8B,Z8C,Z8D,Z8E,BAD
        DW Z90,Z91,Z92,Z93,Z94,Z95,Z96,Z97,Z98,Z99,Z9A,Z9B,Z9C,Z9D,Z9E,Z9F
        DW ZA0,ZA1,ZA2,ZA3,ZA4,ZA5,ZA6,ZA7,ZA8,ZA9,ZAA,ZAB,ZAC,ZAD,ZAE,ZAF
        DW ZB0,ZB1,ZB2,ZB3,ZB4,ZB5,ZB6,ZB7,ZB8,ZB9,ZBA,ZBB,ZBC,ZBD,ZBE,ZBF
        DW ZC0,ZC1,ZC2,ZC3,ZC4,ZC5,ZC6,BAD,ZC8,ZC9,ZCA,ZCB,ZCC,BAD,ZCE,BAD
        DW ZD0,ZD1,ZD2,ZD3,ZD4,ZD5,ZD6,ZD7,ZD8,ZD9,ZDA,ZDB,ZDC,ZDD,ZDE,ZDF
        DW ZE0,ZE1,ZE2,ZE3,ZE4,ZE5,ZE6,ZE7,ZE8,ZE9,ZEA,ZEB,ZEC,ZED,ZEE,ZEF
        DW ZF0,ZF1,ZF2,ZF3,ZF4,ZF5,ZF6,ZF7,ZF8,ZF9,ZFA,ZFB,ZFC,ZFD,ZFE,ZFF
;10h instructions
        DW BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD
        DW BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD
        DW BAD,X21,X22,X23,X24,X25,X26,X27,X28,X29,X2A,X2B,X2C,X2D,X2E,X2F
        DW BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,X3F
        DW BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD
        DW BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD
        DW BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD
        DW BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD
        DW BAD,BAD,BAD,X83,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,X8C,BAD,X8E,BAD
        DW BAD,BAD,BAD,X93,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,X9C,BAD,X9E,X9F
        DW BAD,BAD,BAD,XA3,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,XAC,BAD,XAE,XAF
        DW BAD,BAD,BAD,XB3,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,XBC,BAD,XBE,XBF
        DW BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,XCE,BAD
        DW BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,XDE,XDF
        DW BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,XEE,XEF
        DW BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,XFE,XFF
;11h instructions
        DW BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD
        DW BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD
        DW BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD
        DW BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,Y3F
        DW BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD
        DW BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD
        DW BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD
        DW BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD
        DW BAD,BAD,BAD,Y83,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,Y8C,BAD,BAD,BAD
        DW BAD,BAD,BAD,Y93,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,Y9C,BAD,BAD,BAD
        DW BAD,BAD,BAD,YA3,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,YAC,BAD,BAD,BAD
        DW BAD,BAD,BAD,YB3,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,YBC,BAD,BAD,BAD
        DW BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD
        DW BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD
        DW BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD
        DW BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD,BAD
        DW YFE,YFF; <--- these instructions are powerful but more harm than good

;General processor activity macros

;Retrieve 8086 flags

GETFLAG MACRO
        PUSH REGF
        POPF
        ENDM

;Save 8086 flags

PUTFLAG MACRO
        PUSHF
        POP REGF
        ENDM

;Save 8086 flags except bits in FLAGS, destructive to BX

PROTECT MACRO FLAGS
        POP CX
        AND CX,-1-(FLAGS)
        AND REGF,FLAGS
        OR REGF,CX
        ENDM

CARRY   EQU 1
HALF    EQU 16
OVERFLOW EQU 800H
ZERO    EQU 64
NEGATIVE EQU 128

;Update 8086's half-carry flag based on bit 4 of AL, destructive to AH

SETHALF:
        MOV AH,AL
        AND AH,16
        AND BYTE PTR REGF,0EFH
        OR BYTE PTR REGF,AH
		RET
        
;Read byte at BX from CoCo's memory to AL

GETBYTE:
        PUSH BX
        AND BX,0E000H
        MOV ES,SS:[BX]
        POP BX
        MOV AL,ES:[BX]
        CMP BH,0FEH
        JB GB_NOT_DEVICE
        CALL DEV_R8
GB_NOT_DEVICE:
		RET

;Read at BX from CoCo's memory to AX

GETWORD:
        CALL GETBYTE
        MOV AH,AL
        INC BX
        CALL GETBYTE
        DEC BX
		RET

;Put byte AL to CoCo's memory at BX

PUTBYTE:
        PUSH DI
        CMP BH,0FEH
        JB PB_NOT_DEVICE
        CALL DEV_W8
		POP DI
		RET
PB_NOT_DEVICE:
        MOV DI,BX
        AND DI,0E000H
        MOV ES,SS:[DI+2]
        CMP BX,SS:[DI+6]
        JNB PB_NOT_VIDEO
        CMP BX,SS:[DI+4]
        JB PB_NOT_VIDEO
        CMP AL,ES:[BX]
        JZ PB_DONE
        MOV ES:[BX],AL
        CALL CHARGEN
        POP DI
		RET
PB_NOT_VIDEO:
        MOV ES:[BX],AL
PB_DONE:   
		POP DI
		RET

;Put word AX to CoCo's memory at BX

PUTWORD:
        XCHG AH,AL
        CALL PUTBYTE
        XCHG AH,AL
        INC BX
        CALL PUTBYTE
        DEC BX
		RET

;Memory handlers for Debug Monitor

MEM_R8:
        PUSH BX
        MOV BX,DI
        CALL GETBYTE
        POP BX
        RET

MEM_W8:
        PUSH BX
        MOV BX,DI
        CALL PUTBYTE
        POP BX
        RET

MEM_R16:
        PUSH BX
        MOV BX,DI
        CALL GETWORD
        POP BX
        RET

;6809 meta-instruction set
;(b=8-bit register, w=16-bit register)

;LD8:   [BX]->b         (N,Z=X, V=0)

ZLD8:
        CALL GETBYTE
        MOV BYTE PTR [DI],AL
        AND AL,AL
        PUSHF
        PROTECT HALF+CARRY
        RET

;ST8:   b->[BX]         (N,Z=X, V=0)

ZST8:
        MOV AL,BYTE PTR [DI]
        AND AL,AL
        PUSHF
        CALL PUTBYTE
        PROTECT HALF+CARRY
        RET

;LD16:  [BX]->w         (N,Z=X, V=0)

ZLD16:
        CALL GETWORD
        MOV [DI],AX
        AND AX,AX
        PUSHF
        PROTECT HALF+CARRY
        RET

;ST16:  w->[BX]         (N,Z=X, V=0)

ZST16:
        MOV AX,[DI]
        AND AX,AX
        PUSHF
        CALL PUTWORD
        PROTECT HALF+CARRY
        RET

;ADC8:  b+[BX]+C->b     (H,N,Z,V,C=X)

ZADC8:
        CALL GETBYTE
        GETFLAG
        ADC BYTE PTR [DI],AL
        PUTFLAG
        RET

;ADD8:  b+[BX]->b       (H,N,Z,V,C=X)

ZADD8:
        CALL GETBYTE
        ADD BYTE PTR [DI],AL
        PUTFLAG
        RET

;ADDD:  D+[BX]->D       (N,Z,V,C=X)

ZADDD:
        CALL GETWORD
        ADD REGD,AX
        PUSHF
        PROTECT HALF
        RET

;AND8:  b and [BX]->b   (N,Z,V=X)

ZAND8:
        CALL GETBYTE
        AND BYTE PTR [DI],AL
        PUSHF
        PROTECT HALF+CARRY
        RET

;BIT8:  b^[BX]          (N,Z,V=X)

ZBIT8:
        CALL GETBYTE
        TEST BYTE PTR [DI],AL
        PUSHF
        PROTECT HALF+CARRY
        RET

;CMP8:  b-[BX]          (H,N,Z,V,C=X)

ZCMP8:
        CALL GETBYTE
        CMP BYTE PTR [DI],AL
        PUTFLAG
        RET

;CMP16: w-[BX]          (N,Z,V,C=X)

ZCMP16:
        CALL GETWORD
        CMP [DI],AX
        PUSHF
        PROTECT HALF
        RET

;EOR8:  b xor [BX]->b   (N,Z=X, V=0)

ZEOR8:
        CALL GETBYTE
        XOR BYTE PTR [DI],AL
        PUSHF
        PROTECT HALF+CARRY
        RET

;OR8:   b or [BX]->b    (N,Z=X, V=0)

ZOR8:
        CALL GETBYTE
        OR BYTE PTR [DI],AL
        PUSHF
        PROTECT HALF+CARRY
        RET

;SBC8:  b-[BX]-C->b     (H,N,Z,V,C=X)

ZSBC8:
        CALL GETBYTE
        GETFLAG
        SBB BYTE PTR [DI],AL
        PUTFLAG
        RET

;SUB8:  b-[BX]->b       (H,N,Z,V,C=X)

ZSUB8:
        CALL GETBYTE
        SUB BYTE PTR [DI],AL
        PUTFLAG 
        RET

;SUBD:  D-[BX]->D       (N,Z,V,C=X)

ZSUBD:
        CALL GETWORD
        SUB REGD,AX
        PUSHF
        PROTECT HALF
        RET

;ASL:   SHL [BX],1      (H,N,Z,V,C=X)

ZASL:
        CALL GETBYTE
        ADD AL,AL
        PUTFLAG
        CALL PUTBYTE
        RET

;ASR:   SAR [BX],1      (H,N,Z,C=X)

ZASR:
        CALL GETBYTE
        CALL SETHALF
        SAR AL,1
        PUSHF
        CALL PUTBYTE
        PROTECT OVERFLOW
        RET
        
;CLR:   0->[BX]         (Z=1, N,V,C=0)

ZCLR:
        AND REGF,-1-NEGATIVE-OVERFLOW-CARRY
        OR REGF,ZERO
        MOV AL,0
        CALL PUTBYTE
        RET

;COM:   not [BX]->[BX]  (N,Z=X, V=0, C=1)

ZCOM:
        CALL GETBYTE
        GETFLAG
        XOR AL,-1
        STC
        PUTFLAG
        CALL PUTBYTE
        RET

;DEC:   [BX]-1->[BX]    (N,Z,V=X)

ZDEC:
        CALL GETBYTE
        DEC AL
        PUSHF
        CALL PUTBYTE
        PROTECT HALF+CARRY
        RET

;INC:   [BX]+1->[BX]    (N,Z,V=X)

ZINC:
        CALL GETBYTE
        INC AL
        PUSHF
        CALL PUTBYTE
        PROTECT HALF+CARRY
        RET

;LSR:   SHR [BX],1      (Z,C=X, N=0)

ZLSR:
        CALL GETBYTE
        SHR AL,1
        PUSHF
        CALL PUTBYTE
        PROTECT HALF+OVERFLOW
        RET

;MEG:   NEG [BX]        (H,N,Z,V,C=X)

ZNEG:
        CALL GETBYTE
        NEG AL
        PUTFLAG
        CALL PUTBYTE
        RET

;ROL:   RCL [BX],1      (N,Z,V,C=X)

ZROL:
        CALL GETBYTE
        GETFLAG
        ADC AL,AL
        PUSHF
        CALL PUTBYTE
        PROTECT HALF
        RET

;ROR:   RCR [BX],1      (N,Z,C=X)

ZROR:
        CALL GETBYTE
        GETFLAG
        RCR AL,1
        PUSHF
        CALL PUTBYTE
        PROTECT HALF+OVERFLOW
        AND AL,AL
        PUSHF
        PROTECT OVERFLOW+CARRY
        RET

;TST:   CMP [BX],0      (N,Z=X, V=0)

ZTST:
        CALL GETBYTE
        CMP AL,0
        PUSHF
        PROTECT HALF+CARRY
        RET

;BRA:   [PC]+d+2->[PC]  

ZBRA:
		MOV BX,SI
		CALL GETBYTE
        INC SI
        CBW
        ADD SI,AX
        RET

;JMP:   [BX]->PC

ZJMP:
        MOV SI,BX
        RET

;LBRA:  PC+dd+3->PC

ZLBRA:
		MOV BX,SI
		CALL GETWORD
		ADD SI,2
        ADD SI,AX
        RET

;BSR:   SP-2->SP, PC->[SP], PC+d+2->PC

ZBSR:
		MOV BX,SI
		CALL GETBYTE
        CBW
        INC SI
        ADD AX,SI
        DEC REGSP
        DEC REGSP
        MOV BX,REGSP
        XCHG AX,SI
        MOV RETURN_ADDRESS,AX
        CALL PUTWORD
        RET

;JSR:   SP-2->SP, PC->[SP], [BX]->PC

ZJSR:
        MOV AX,SI
        MOV RETURN_ADDRESS,AX
        MOV SI,BX
        DEC REGSP
        DEC REGSP
        MOV BX,REGSP
        CALL PUTWORD
        RET

;LBSR:  SP-2->SP, PC->[SP], PC+dd+3->PC

ZLBSR:
		MOV BX,SI
		CALL GETWORD
		ADD SI,2
        ADD AX,SI
        DEC REGSP
        DEC REGSP
        MOV BX,REGSP
        XCHG SI,AX
        CALL PUTWORD
        RET

;RTS:   [SP]->PC, [SP]+2->[SP]

ZRTS:
		MOV BX,REGSP
		CALL GETWORD
		ADD REGSP,2
        MOV SI,AX
        RET

;CBRA:  PC+d+2->PC if CONDITION satisfied

ZCBRA:
		MOV BX,SI
		CALL GETBYTE
        CBW
        INC SI
        GETFLAG
		RET

;CLBRA: PC+dd+3->PC if CONDITION satisfied

ZCLBRA:
		MOV BX,SI
		CALL GETWORD
		ADD SI,2
        GETFLAG
		RET

;ABX:   ADD X,WORD B

ZABX:
        MOV AH,0
        MOV AL,BYTE PTR REGB
        ADD REGX,AX
        RET

;MUL:   A x B -> D      (Z,C=X)

ZMUL:
        MOV AL,BYTE PTR REGB
        MUL BYTE PTR REGA
        MOV REGD,AX
        AND AX,AX
        PUSHF
        PROTECT NEGATIVE+HALF+OVERFLOW+CARRY
        SHL AL,1
        PUSHF
        PROTECT NEGATIVE+ZERO+HALF+OVERFLOW
        RET

;SEX:   CBW DX          (N,Z=X)

ZSEX:
        MOV AL,BYTE PTR REGB
        CBW
        MOV BYTE PTR REGA,AH
        AND AX,AX
        PUSHF
        PROTECT CARRY+OVERFLOW+HALF
        RET

;ASL8:  SHL b,1         (H,N,Z,V,C=X)

ZASL8:
		MOV AL,BYTE PTR [DI]
        ADD BYTE PTR [DI],AL
        PUTFLAG
        RET

;ASR8:  SAR b,1         (H,N,Z,C=X)

ZASR8:
        MOV AL,BYTE PTR [DI]
        CALL SETHALF
        SAR BYTE PTR [DI],1
        PUSHF
        PROTECT HALF+OVERFLOW
        RET

;CLR8:  MOV b,0         (N,V,C=0, Z=1)

ZCLR8:
        GETFLAG
        AND BYTE PTR [DI],0
        PUTFLAG
        RET

;COM8:  not b->b        (N,Z=X, V=0, C=1)

ZCOM8:
        GETFLAG
        XOR BYTE PTR [DI],-1
        STC
        PUTFLAG
        RET

;DEC8:  b-1->b          (N,Z,V=X)

ZDEC8:
        DEC BYTE PTR [DI]
        PUSHF
        PROTECT HALF+CARRY
        RET

;INC8:  b+1->b          (N,Z,V=X)

ZINC8:
        INC BYTE PTR [DI]
        PUSHF
        PROTECT HALF+CARRY
        RET

;LSR8:  SHR b,1         (Z,C=X, N=0)

ZLSR8:
        SHR BYTE PTR [DI],1
        PUSHF
        PROTECT HALF+OVERFLOW
        RET

;NEG8:  NEG b           (H,N,Z,V,C=X)

ZNEG8:
        NEG BYTE PTR [DI]
        PUTFLAG
        RET

;ROL8:  RCL b,1         (N,Z,V,C=X)

ZROL8:
        GETFLAG
		MOV AL,BYTE PTR [DI]
        ADC BYTE PTR [DI],AL
        PUSHF
        PROTECT HALF
        RET

;ROR8:  RCR b,1         (N,Z,C=X)

ZROR8:
        GETFLAG
        RCR BYTE PTR [DI],1
        PUSHF
        PROTECT HALF+OVERFLOW
		MOV AL,BYTE PTR [DI]
        AND AL,AL
        PUSHF
        PROTECT OVERFLOW+CARRY
        RET

;TST8:  CMP b,0         (N,Z=X, V=0)

ZTST8:
        CMP BYTE PTR [DI],0
        PUSHF
        PROTECT HALF+CARRY
        RET

;LEAI:  BX->X/Y         (Z=X)

ZLEAI:
        MOV [DI],BX
        AND BX,BX
        PUSHF
        PROTECT HALF+NEGATIVE+OVERFLOW+CARRY
        RET

;LEAP:  BX->S/U

ZLEAP:
        MOV [DI],BX
        RET

;SWI:   Software Interrupt (using vector in VECTOR)
;       Set E flag, PSHS $FF, set flags CCM

ZSWI:
        OR REGFI,128
        CALL XLTFLAG
        CALL PUSH_ENTIRE
        OR REGFI,CL
        MOV BX,DI
        CALL GETWORD
        MOV SI,AX
        RET

ZSWIR:
        OR REGFI,128
        CALL XLTFLAG
        CALL PUSH_ENTIRE
        OR REGFI,CL
        MOV BX,DI
        CALL GETWORD
        MOV SI,AX
        RET

PUSH_ENTIRE:
        MOV BX,REGSP
        DEC BX
        DEC BX
        MOV AX,SI
        CALL PUTWORD
        DEC BX
        DEC BX
        MOV AX,REGU
        CALL PUTWORD
        DEC BX
        DEC BX
        MOV AX,REGY
        CALL PUTWORD
        DEC BX
        DEC BX
        MOV AX,REGX
        CALL PUTWORD
        DEC BX
        MOV AL,REGDP
        CALL PUTBYTE
        DEC BX
        DEC BX
        MOV AX,REGD
        CALL PUTWORD
        DEC BX
        MOV AL,REGFI
        CALL PUTBYTE
        MOV REGSP,BX
        RET

NMI:    MOV DI,0FFFCH			;NMI function
		MOV CL,16
		JMP ZSWIR
IRQ:    MOV DI,0FFF8H			;IRQ function
		MOV CL,16
		JMP ZSWIR
FIRQ:   TEST BYTE PTR REGFI,128 ;Push Entire?
        JZ FIRQ_0
        JMP FIRQ_1
FIRQ_0: CALL XLTFLAG
        MOV BX,REGSP            ;FIRQ function with E=0 (pshs CC,PC)
        DEC BX
        DEC BX
        MOV AX,SI
        CALL PUTWORD
        DEC BX
        MOV AL,REGFI
        CALL PUTBYTE
        MOV REGSP,BX
        OR REGFI,64
        MOV BX,0FFF6H
        CALL GETWORD
        MOV SI,AX
        RET
FIRQ_1: MOV DI,0FFF6H			;FIRQ function with E=1
		MOV CL,64
		JMP ZSWIR         

;ANDCC: CC and d -> CC

ZANDCC:
        CALL XLTFLAG
		MOV BX,SI
		CALL GETBYTE
        INC SI
        AND REGFI,AL
        CALL UPDFLAG
        RET

;ORCC: CC or d -> CC

ZORCC:
        CALL XLTFLAG
		MOV BX,SI
		CALL GETBYTE
        INC SI
        OR REGFI,AL
        CALL UPDFLAG
        RET

;ZNOP:  No operation (NOP/LBRN/BRN), SKIP bytes

ZNOP:
        ADD SI,BX
        RET

;Addressing modes

;Base page direct

DIRECT8:
		MOV BX,SI
		CALL GETBYTE
        INC SI
        MOV AH,REGDP
        MOV BX,AX
		RET

;Extended direct

DIRECT16:
		MOV BX,SI
		CALL GETWORD
		ADD SI,2
        MOV BX,AX
		RET

;Immediate, 8-bit

IMMED8:
        MOV BX,SI
        INC SI
		RET

;Immediate, 16-bit

IMMED16:
        MOV BX,SI
        INC SI
        INC SI
		RET

;Post-byte addressing

POST_MODE DW POST0,POST1,POST2,POST3,POST4,POST5,POST6,POST7
		DW POST8,POST9,POSTA,POSTB,POSTC,POSTD,POSTE,POSTF

POSTBYTE:
		MOV BX,SI
		CALL GETBYTE
        INC SI
		CMP AL,80H
		JB CONSTANT_OFFSET
		MOV CL,AL
		ROL AL,1
		MOV BX,AX
		ROL AL,1
		ROL AL,1
		ROL AL,1
		MOV DI,AX
		AND DI,6
		MOV DI,POST_REGISTER[DI]
		AND BX,1EH
		CALL POST_MODE[BX]
		TEST CL,10H
		JZ NOT_INDIRECT
		CALL GETWORD
		MOV BX,AX
NOT_INDIRECT:
		RET

POST_REGISTER DW REGX,REGY,REGU,REGSP

CONSTANT_OFFSET:
		ROL AL,1
		ROL AL,1
		ROL AL,1
		CBW
		MOV BX,AX
		ROL BL,1
		AND BX,6
		MOV BX,POST_REGISTER[BX]
		MOV BX,[BX]
		SAR AX,1
		SAR AX,1
		SAR AX,1
		ADD BX,AX
		RET

;Subroutines

;Main instruction interpreter

INST:   PUSH SI					;DON'T CHANGE THIS LINE!
		POP SI					;(Legacy code for compatibility with previous 6809 core)
MAIN:	
		CMP BYTE PTR INST,0C3H
		JZ RETURN_TO_SHELL
AUX:
		MOV BX,SI
		CALL GETBYTE
		MOV BL,AL
        INC SI
        MOV BH,0
		SUB AL,10H
		CMP AL,2
		JNB NOT_MULTI_BYTE
		MOV CL,AL
		INC CL
		MOV BX,SI
		CALL GETBYTE
		MOV BL,AL
		INC SI
		MOV BH,CL
NOT_MULTI_BYTE:
        MOV AL,SS:[05000H+BX]
        SUB CYCLE_COUNT,AL
SyncBranch:
        JB INTERRUPT_MAIN
MAIN_INT_DONE:
        ADD BX,BX
        CALL TABLE[BX]
		JMP MAIN

RETURN_TO_SHELL:
		MOV CX,REGX				;(Legacy code for compatibility with previous 6809 core)
		MOV DX,REGD
		MOV DI,REGY
		MOV BP,REGSP
		RET

INTERRUPT_MAIN:
        CMP CYCLE_COUNT,0       ;Has HSync reset cycle count?
        JS INTERRUPT_MAIN       ;No, then hang around
        JMP MAIN_INT_DONE

        PUBLIC UpdateSyncLock

UpdateSyncLock:                 ;Sets sync lock flag according to bit 2 of AL
        TEST AL,4
        JNZ SyncLockOn
        MOV BYTE PTR SyncBranch[1],0
        RET                     ;Turn off sync lock
SyncLockOn:
        MOV BYTE PTR SyncBranch[1],OFFSET INTERRUPT_MAIN-OFFSET MAIN_INT_DONE
        RET

;The instruction set

Z00:    CALL DIRECT8
		JMP ZNEG
Z03:    CALL DIRECT8
		JMP ZCOM
Z04:    CALL DIRECT8
		JMP ZLSR
Z06:    CALL DIRECT8
		JMP ZROR
Z07:    CALL DIRECT8
		JMP ZASR
Z08:    CALL DIRECT8
		JMP ZASL
Z09:    CALL DIRECT8
		JMP ZROL
Z0A:    CALL DIRECT8
		JMP ZDEC
Z0C:    CALL DIRECT8
		JMP ZINC
Z0D:    CALL DIRECT8
		JMP ZTST
Z0E:    CALL DIRECT8
		JMP ZJMP
Z0F:    CALL DIRECT8
		JMP ZCLR
Z12:    MOV BX,0
		JMP ZNOP
Z13:    CMP BRANCH,0            ;SYNC
        JL Z13
        RET
Z16:    JMP ZLBRA
Z17:    JMP ZLBSR
Z19:    MOV AH,BYTE PTR REGF    ;DAA
        AND AH,1
        GETFLAG
        MOV AL,BYTE PTR REGA
        DAA
        MOV BYTE PTR REGA,AL
        PUSHF
        PROTECT HALF
        OR BYTE PTR REGF,AH
        RET
Z1A:    JMP ZORCC
Z1C:    JMP ZANDCC
Z1D:    JMP ZSEX
Z1E:    MOV BX,SI				;EXG
		CALL GETBYTE
		INC SI
		CALL GET_TFREXG_REG
		TEST AL,88H
		JNZ Z1E_BYTE
		MOV REGPC,SI
		MOV AX,[DI]
		XCHG AX,[BX]
		MOV [DI],AX
		MOV SI,REGPC
		RET
Z1E_BYTE:
		CALL XLTFLAG
		MOV AL,[DI]
		XCHG AL,[BX]
		MOV [DI],AL
		CALL UPDFLAG
		RET
Z1F:    MOV BX,SI				;TFR
		CALL GETBYTE
		INC SI
		CALL GET_TFREXG_REG
		TEST AL,88H
		JNZ Z1F_BYTE
		MOV REGPC,SI
		MOV AX,[BX]
		MOV [DI],AX
		MOV SI,REGPC
		RET
Z1F_BYTE:
		CALL XLTFLAG
		MOV AL,[BX]
		MOV [DI],AL
		CALL UPDFLAG
		RET

CONDITION_TRUE:   
		ADD SI,AX
        RET

Z20:    JMP ZBRA
Z21:    MOV BX,1                ;BRN
		JMP ZNOP
Z22:    CALL ZCBRA              ;BHI
		JA CONDITION_TRUE
		RET
Z23:    CALL ZCBRA              ;BLS
		JNA CONDITION_TRUE
		RET
Z24:    CALL ZCBRA              ;BCC
		JNB CONDITION_TRUE
		RET
Z25:    CALL ZCBRA              ;BCS
		JB CONDITION_TRUE
		RET
Z26:    CALL ZCBRA              ;BNE
		JNZ CONDITION_TRUE
		RET
Z27:    CALL ZCBRA              ;BEQ
		JZ CONDITION_TRUE
		RET
Z28:    CALL ZCBRA              ;BVC
		JNO CONDITION_TRUE
		RET
Z29:    CALL ZCBRA              ;BVS
		JO CONDITION_TRUE
		RET
Z2A:    CALL ZCBRA              ;BPL
		JNS CONDITION_TRUE
		RET
Z2B:    CALL ZCBRA              ;BMI
		JS CONDITION_TRUE
		RET
Z2C:    CALL ZCBRA              ;BGE
		JGE CONDITION_TRUE
		RET
Z2D:    CALL ZCBRA              ;BLT
		JL CONDITION_TRUE
		RET
Z2E:    CALL ZCBRA              ;BGT
		JG CONDITION_TRUE
		RET
Z2F:    CALL ZCBRA              ;BLE
		JLE CONDITION_TRUE
		RET
Z30:    CALL POSTBYTE
		MOV DI,OFFSET REGX
		JMP ZLEAI
Z31:    CALL POSTBYTE
		MOV DI,OFFSET REGY
		JMP ZLEAI
Z32:    CALL POSTBYTE
		MOV DI,OFFSET REGSP
		JMP ZLEAP
Z33:    CALL POSTBYTE
		MOV DI,OFFSET REGU
		JMP ZLEAP
Z34:    MOV BX,SI               ;PSHS
		CALL GETBYTE
		MOV AH,AL
		MOV BX,REGSP
        INC SI
        MOV BP,AX
        ROL BP,1                ;bit 7=PC
        JNB Z34_A
        MOV AX,SI
        DEC BX
        DEC BX
        CALL PUTWORD
Z34_A:  ROL BP,1                ;bit 6=U
        JNB Z34_B
        MOV AX,REGU
        DEC BX
        DEC BX
        CALL PUTWORD
Z34_B:  ROL BP,1                ;bit 5=Y
        JNB Z34_C
        MOV AX,REGY
        DEC BX
        DEC BX
        CALL PUTWORD
Z34_C:  ROL BP,1                ;bit 4=X
        JNB Z34_D
        MOV AX,REGX
        DEC BX
        DEC BX
        CALL PUTWORD
Z34_D:  ROL BP,1                ;bit 3=DP
        JNB Z34_E
        MOV AL,REGDP
        DEC BX
        CALL PUTBYTE
Z34_E:  ROL BP,1                ;bit 2=B
        JNB Z34_F
        MOV AL,BYTE PTR REGB
        DEC BX
        CALL PUTBYTE
Z34_F:  ROL BP,1                ;bit 1=A
        JNB Z34_G
        MOV AL,BYTE PTR REGA
        DEC BX
        CALL PUTBYTE
Z34_G:  ROL BP,1                ;bit 0=CC
        JNB Z34_H
        CALL XLTFLAG
        MOV AL,REGFI
        DEC BX
        CALL PUTBYTE
Z34_H:  MOV REGSP,BX
        RET
Z35:    MOV BX,SI               ;PULS
        CALL GETBYTE
		MOV BX,REGSP
        MOV BP,AX
        INC SI
        ROR BP,1                ;bit 0=CC
        JNB Z35_A
        CALL GETBYTE
        INC BX
        MOV REGFI,AL
        CALL UPDFLAG
Z35_A:  ROR BP,1                ;bit 1=A
        JNB Z35_B
        CALL GETBYTE
        INC BX
        MOV BYTE PTR REGA,AL
Z35_B:  ROR BP,1                ;bit 2=B
        JNB Z35_C
        CALL GETBYTE
        INC BX
        MOV BYTE PTR REGB,AL
Z35_C:  ROR BP,1                ;bit 3=DP
        JNB Z35_D
        CALL GETBYTE
        INC BX
        MOV REGDP,AL
Z35_D:  ROR BP,1                ;bit 4=X
        JNB Z35_E
        CALL GETWORD
        INC BX
        INC BX
        MOV REGX,AX
Z35_E:  ROR BP,1                ;bit 5=Y
        JNB Z35_F
        CALL GETWORD
        INC BX
        INC BX
        MOV REGY,AX
Z35_F:  ROR BP,1                ;bit 6=U
        JNB Z35_G
        CALL GETWORD
        INC BX
        INC BX
        MOV REGU,AX
Z35_G:  ROR BP,1                ;bit 7=PC
        JNB Z35_H
        CALL GETWORD
        INC BX
        INC BX
        MOV SI,AX
Z35_H:  MOV REGSP,BX
CHECK_INTERRUPT:
        CMP MISSED_INTERRUPT,0
        JNZ RETRY_INTERRUPT
        RET
RETRY_INTERRUPT:
        JMP RETRY_CLOCK
Z36:    MOV BX,SI               ;PSHU
		CALL GETBYTE
		MOV AH,AL
		MOV BX,REGU
        INC SI
        PUSH SI
        MOV SI,AX
        ROL SI,1                ;bit 7=PC
        JNB Z36_A
        POP AX
        PUSH AX
        DEC BX
        DEC BX
        CALL PUTWORD
Z36_A:  ROL SI,1                ;bit 6=S
        JNB Z36_B
        MOV AX,REGSP
        DEC BX
        DEC BX
        CALL PUTWORD
Z36_B:  ROL SI,1                ;bit 5=Y
        JNB Z36_C
        MOV AX,REGY
        DEC BX
        DEC BX
        CALL PUTWORD
Z36_C:  ROL SI,1                ;bit 4=X
        JNB Z36_D
        MOV AX,REGX
        DEC BX
        DEC BX
        CALL PUTWORD
Z36_D:  ROL SI,1                ;bit 3=DP
        JNB Z36_E
        MOV AL,REGDP
        DEC BX
        CALL PUTBYTE
Z36_E:  ROL SI,1                ;bit 2=B
        JNB Z36_F
        MOV AL,BYTE PTR REGB
        DEC BX
        CALL PUTBYTE
Z36_F:  ROL SI,1                ;bit 1=A
        JNB Z36_G
        MOV AL,BYTE PTR REGA
        DEC BX
        CALL PUTBYTE
Z36_G:  ROL SI,1                ;bit 0=CC
        JNB Z36_H
        CALL XLTFLAG
        MOV AL,REGFI
        DEC BX
        CALL PUTBYTE
Z36_H:  MOV REGU,BX
        POP SI
        RET
Z37:    MOV BX,SI               ;PULU
		CALL GETBYTE
		MOV BX,REGU
        INC SI
        PUSH SI
        MOV SI,AX
        ROR SI,1                ;bit 0=CC
        JNB Z37_A
        CALL GETBYTE
        INC BX
        MOV REGFI,AL
        CALL UPDFLAG
Z37_A:  ROR SI,1                ;bit 1=A
        JNB Z37_B
        CALL GETBYTE
        INC BX
        MOV BYTE PTR REGA,AL
Z37_B:  ROR SI,1                ;bit 2=B
        JNB Z37_C
        CALL GETBYTE
        INC BX
        MOV BYTE PTR REGB,AL
Z37_C:  ROR SI,1                ;bit 3=DP
        JNB Z37_D
        CALL GETBYTE
        INC BX
        MOV REGDP,AL
Z37_D:  ROR SI,1                ;bit 4=X
        JNB Z37_E
        CALL GETWORD
        INC BX
        INC BX
        MOV REGX,AX
Z37_E:  ROR SI,1                ;bit 5=Y
        JNB Z37_F
        CALL GETWORD
        INC BX
        INC BX
        MOV REGY,AX
Z37_F:  ROR SI,1                ;bit 6=S
        JNB Z37_G
        CALL GETWORD
        INC BX
        INC BX
        MOV REGSP,AX
Z37_G:  ROR SI,1                ;bit 7=PC
        POP SI
        JNB Z37_H
        CALL GETWORD
        INC BX
        INC BX
        MOV SI,AX
Z37_H:  MOV REGU,BX
        JMP CHECK_INTERRUPT
Z39:    JMP ZRTS
Z3A:    JMP ZABX
Z3B:    MOV BX,REGSP               ;RTI
        CALL GETBYTE
        INC BX
        MOV REGFI,AL
        CALL UPDFLAG
        TEST BYTE PTR REGFI,128
        JNZ Z3B_B
        JMP Z3B_A
Z3B_B:  CALL GETBYTE
        INC BX
        MOV BYTE PTR REGA,AL
        CALL GETBYTE
        INC BX
        MOV BYTE PTR REGB,AL
        CALL GETBYTE
        INC BX
        MOV REGDP,AL
        CALL GETWORD
        INC BX
        INC BX
        MOV REGX,AX
        CALL GETWORD
        INC BX
        INC BX
        MOV REGY,AX
        CALL GETWORD
        INC BX
        INC BX
        MOV REGU,AX
Z3B_A:  CALL GETWORD
        INC BX
        INC BX
        MOV SI,AX
        MOV REGSP,BX
        TEST BYTE PTR IRQSET,63 ;Another chip IRQ pending?
        JZ Z3B_1
        TEST BYTE PTR INIT0,32  ;Chip IRQs enabled?
        JZ Z3B_1
        TEST BYTE PTR REGFI,16  ;Flag I reset?
        JNZ Z3B_1
        CALL IRQ                ;Generate the IRQ
        RET
Z3B_1:  TEST REGFI,64           ;Flag F reset?
        JNZ Z3B_3
        TEST CART_FLAG,128      ;If CART interrupt pending...
        JZ Z3B_2
        TEST CRB2,1             ;and CART IRQ enabled...
        JZ Z3B_2
        CALL FIRQ               ;generate the FIRQ
        RET
Z3B_2:  TEST FIRQSET,63         ;Another chip FIRQ pending?
        JZ Z3B_3
        TEST INIT0,16           ;Chip FIRQs enabled?
        JZ Z3B_3
Z3B_3:  RET
Z3C:    CALL XLTFLAG            ;CWAI
		MOV BX,SI
		CALL GETBYTE
        INC SI
        AND REGFI,AL
        OR REGFI,128
        JMP Z13
Z3D:    JMP ZMUL
Z3F:    MOV DI,0FFFAH
		MOV CL,50H
		JMP ZSWI
Z40:    MOV DI,OFFSET REGA
		JMP ZNEG8
Z43:    MOV DI,OFFSET REGA
		JMP ZCOM8
Z44:    MOV DI,OFFSET REGA
		JMP ZLSR8
Z46:    MOV DI,OFFSET REGA
		JMP ZROR8
Z47:    MOV DI,OFFSET REGA
		JMP ZASR8
Z48:    MOV DI,OFFSET REGA
		JMP ZASL8
Z49:    MOV DI,OFFSET REGA
		JMP ZROL8
Z4A:    MOV DI,OFFSET REGA
		JMP ZDEC8
Z4C:    MOV DI,OFFSET REGA
		JMP ZINC8
Z4D:    MOV DI,OFFSET REGA
		JMP ZTST8
Z4F:    MOV DI,OFFSET REGA
		JMP ZCLR8
Z50:    MOV DI,OFFSET REGB
		JMP ZNEG8
Z53:    MOV DI,OFFSET REGB
		JMP ZCOM8
Z54:    MOV DI,OFFSET REGB
		JMP ZLSR8
Z56:    MOV DI,OFFSET REGB
		JMP ZROR8
Z57:    MOV DI,OFFSET REGB
		JMP ZASR8
Z58:    MOV DI,OFFSET REGB
		JMP ZASL8
Z59:    MOV DI,OFFSET REGB
		JMP ZROL8
Z5A:    MOV DI,OFFSET REGB
		JMP ZDEC8
Z5C:    MOV DI,OFFSET REGB
		JMP ZINC8
Z5D:    MOV DI,OFFSET REGB
		JMP ZTST8
Z5F:    MOV DI,OFFSET REGB
		JMP ZCLR8
Z60:    CALL POSTBYTE
		JMP ZNEG
Z63:    CALL POSTBYTE
		JMP ZCOM
Z64:    CALL POSTBYTE
		JMP ZLSR
Z66:    CALL POSTBYTE
		JMP ZROR
Z67:    CALL POSTBYTE
		JMP ZASR
Z68:    CALL POSTBYTE
		JMP ZASL
Z69:    CALL POSTBYTE
		JMP ZROL
Z6A:    CALL POSTBYTE
		JMP ZDEC
Z6C:    CALL POSTBYTE
		JMP ZINC
Z6D:    CALL POSTBYTE
		JMP ZTST
Z6E:    CALL POSTBYTE
		JMP ZJMP
Z6F:    CALL POSTBYTE
		JMP ZCLR
Z70:    CALL DIRECT16
		JMP ZNEG
Z73:    CALL DIRECT16
		JMP ZCOM
Z74:    CALL DIRECT16
		JMP ZLSR
Z76:    CALL DIRECT16
		JMP ZROR
Z77:    CALL DIRECT16
		JMP ZASR
Z78:    CALL DIRECT16
		JMP ZASL
Z79:    CALL DIRECT16
		JMP ZROL
Z7A:    CALL DIRECT16
		JMP ZDEC
Z7C:    CALL DIRECT16
		JMP ZINC
Z7D:    CALL DIRECT16
		JMP ZTST
Z7E:    CALL DIRECT16
		JMP ZJMP
Z7F:    CALL DIRECT16
		JMP ZCLR
Z80:    CALL IMMED8 
		MOV DI,OFFSET REGA
		JMP ZSUB8
Z81:    CALL IMMED8 
		MOV DI,OFFSET REGA
		JMP ZCMP8
Z82:    CALL IMMED8
		MOV DI,OFFSET REGA
		JMP ZSBC8
Z83:    CALL IMMED16
		JMP ZSUBD
Z84:    CALL IMMED8
		MOV DI,OFFSET REGA
		JMP ZAND8
Z85:    CALL IMMED8
		MOV DI,OFFSET REGA
		JMP ZBIT8
Z86:    CALL IMMED8
		MOV DI,OFFSET REGA
		JMP ZLD8
Z88:    CALL IMMED8
		MOV DI,OFFSET REGA
		JMP ZEOR8
Z89:    CALL IMMED8
		MOV DI,OFFSET REGA
		JMP ZADC8
Z8A:    CALL IMMED8
		MOV DI,OFFSET REGA
		JMP ZOR8
Z8B:    CALL IMMED8 
		MOV DI,OFFSET REGA
		JMP ZADD8
Z8C:    CALL IMMED16
		MOV DI,OFFSET REGX
		JMP ZCMP16
Z8D:    JMP ZBSR
Z8E:    CALL IMMED16
		MOV DI,OFFSET REGX
		JMP ZLD16
Z90:    CALL DIRECT8
		MOV DI,OFFSET REGA
		JMP ZSUB8
Z91:    CALL DIRECT8
		MOV DI,OFFSET REGA
		JMP ZCMP8
Z92:    CALL DIRECT8
		MOV DI,OFFSET REGA
		JMP ZSBC8
Z93:    CALL DIRECT8
		JMP ZSUBD
Z94:    CALL DIRECT8
		MOV DI,OFFSET REGA
		JMP ZAND8
Z95:    CALL DIRECT8
		MOV DI,OFFSET REGA
		JMP ZBIT8
Z96:    CALL DIRECT8
		MOV DI,OFFSET REGA
		JMP ZLD8
Z97:    CALL DIRECT8
		MOV DI,OFFSET REGA
		JMP ZST8
Z98:    CALL DIRECT8
		MOV DI,OFFSET REGA
		JMP ZEOR8
Z99:    CALL DIRECT8
		MOV DI,OFFSET REGA
		JMP ZADC8
Z9A:    CALL DIRECT8
		MOV DI,OFFSET REGA
		JMP ZOR8
Z9B:    CALL DIRECT8
		MOV DI,OFFSET REGA
		JMP ZADD8
Z9C:    CALL DIRECT8
		MOV DI,OFFSET REGX
		JMP ZCMP16
Z9D:    CALL DIRECT8
		JMP ZJSR
Z9E:    CALL DIRECT8
		MOV DI,OFFSET REGX
		JMP ZLD16
Z9F:    CALL DIRECT8
		MOV DI,OFFSET REGX
		JMP ZST16
ZA0:    CALL POSTBYTE
		MOV DI,OFFSET REGA
		JMP ZSUB8
ZA1:    CALL POSTBYTE
		MOV DI,OFFSET REGA
		JMP ZCMP8
ZA2:    CALL POSTBYTE
		MOV DI,OFFSET REGA
		JMP ZSBC8
ZA3:    CALL POSTBYTE
		JMP ZSUBD
ZA4:    CALL POSTBYTE
		MOV DI,OFFSET REGA
		JMP ZAND8
ZA5:    CALL POSTBYTE
		MOV DI,OFFSET REGA
		JMP ZBIT8
ZA6:    CALL POSTBYTE
		MOV DI,OFFSET REGA
		JMP ZLD8
ZA7:    CALL POSTBYTE
		MOV DI,OFFSET REGA
		JMP ZST8
ZA8:    CALL POSTBYTE
		MOV DI,OFFSET REGA
		JMP ZEOR8
ZA9:    CALL POSTBYTE
		MOV DI,OFFSET REGA
		JMP ZADC8
ZAA:    CALL POSTBYTE
		MOV DI,OFFSET REGA
		JMP ZOR8
ZAB:    CALL POSTBYTE
		MOV DI,OFFSET REGA
		JMP ZADD8
ZAC:    CALL POSTBYTE
		MOV DI,OFFSET REGX
		JMP ZCMP16
ZAD:    CALL POSTBYTE
		JMP ZJSR
ZAE:    CALL POSTBYTE
		MOV DI,OFFSET REGX
		JMP ZLD16
ZAF:    CALL POSTBYTE
		MOV DI,OFFSET REGX
		JMP ZST16
ZB0:    CALL DIRECT16
		MOV DI,OFFSET REGA
		JMP ZSUB8
ZB1:    CALL DIRECT16
		MOV DI,OFFSET REGA
		JMP ZCMP8
ZB2:    CALL DIRECT16
		MOV DI,OFFSET REGA
		JMP ZSBC8
ZB3:    CALL DIRECT16
		JMP ZSUBD
ZB4:    CALL DIRECT16
		MOV DI,OFFSET REGA
		JMP ZAND8
ZB5:    CALL DIRECT16
		MOV DI,OFFSET REGA
		JMP ZBIT8
ZB6:    CALL DIRECT16
		MOV DI,OFFSET REGA
		JMP ZLD8
ZB7:    CALL DIRECT16
		MOV DI,OFFSET REGA
		JMP ZST8
ZB8:    CALL DIRECT16
		MOV DI,OFFSET REGA
		JMP ZEOR8
ZB9:    CALL DIRECT16
		MOV DI,OFFSET REGA
		JMP ZADC8
ZBA:    CALL DIRECT16
		MOV DI,OFFSET REGA
		JMP ZOR8
ZBB:    CALL DIRECT16
		MOV DI,OFFSET REGA
		JMP ZADD8
ZBC:    CALL DIRECT16
		MOV DI,OFFSET REGX
		JMP ZCMP16
ZBD:    CALL DIRECT16
		JMP ZJSR
ZBE:    CALL DIRECT16
		MOV DI,OFFSET REGX
		JMP ZLD16
ZBF:    CALL DIRECT16
		MOV DI,OFFSET REGX
		JMP ZST16
ZC0:    CALL IMMED8
		MOV DI,OFFSET REGB
		JMP ZSUB8
ZC1:    CALL IMMED8
		MOV DI,OFFSET REGB
		JMP ZCMP8
ZC2:    CALL IMMED8
		MOV DI,OFFSET REGB
		JMP ZSBC8
ZC3:    CALL IMMED16
		JMP ZADDD
ZC4:    CALL IMMED8
		MOV DI,OFFSET REGB
		JMP ZAND8
ZC5:    CALL IMMED8
		MOV DI,OFFSET REGB
		JMP ZBIT8
ZC6:    CALL IMMED8
		MOV DI,OFFSET REGB
		JMP ZLD8
ZC8:    CALL IMMED8
		MOV DI,OFFSET REGB
		JMP ZEOR8
ZC9:    CALL IMMED8
		MOV DI,OFFSET REGB
		JMP ZADC8
ZCA:    CALL IMMED8
		MOV DI,OFFSET REGB
		JMP ZOR8
ZCB:    CALL IMMED8
		MOV DI,OFFSET REGB
		JMP ZADD8
ZCC:    CALL IMMED16
		MOV DI,OFFSET REGD
		JMP ZLD16
ZCE:    CALL IMMED16
		MOV DI,OFFSET REGU
		JMP ZLD16
ZD0:    CALL DIRECT8
		MOV DI,OFFSET REGB
		JMP ZSUB8
ZD1:    CALL DIRECT8
		MOV DI,OFFSET REGB
		JMP ZCMP8
ZD2:    CALL DIRECT8
		MOV DI,OFFSET REGB
		JMP ZSBC8
ZD3:    CALL DIRECT8
		JMP ZADDD
ZD4:    CALL DIRECT8
		MOV DI,OFFSET REGB
		JMP ZAND8
ZD5:    CALL DIRECT8
		MOV DI,OFFSET REGB
		JMP ZBIT8
ZD6:    CALL DIRECT8
		MOV DI,OFFSET REGB
		JMP ZLD8
ZD7:    CALL DIRECT8
		MOV DI,OFFSET REGB
		JMP ZST8
ZD8:    CALL DIRECT8
		MOV DI,OFFSET REGB
		JMP ZEOR8
ZD9:    CALL DIRECT8
		MOV DI,OFFSET REGB
		JMP ZADC8
ZDA:    CALL DIRECT8
		MOV DI,OFFSET REGB
		JMP ZOR8
ZDB:    CALL DIRECT8
		MOV DI,OFFSET REGB
		JMP ZADD8
ZDC:    CALL DIRECT8
		MOV DI,OFFSET REGD
		JMP ZLD16
ZDD:    CALL DIRECT8
		MOV DI,OFFSET REGD
		JMP ZST16
ZDE:    CALL DIRECT8
		MOV DI,OFFSET REGU
		JMP ZLD16
ZDF:    CALL DIRECT8
		MOV DI,OFFSET REGU
		JMP ZST16
ZE0:    CALL POSTBYTE
		MOV DI,OFFSET REGB
		JMP ZSUB8
ZE1:    CALL POSTBYTE
		MOV DI,OFFSET REGB
		JMP ZCMP8
ZE2:    CALL POSTBYTE
		MOV DI,OFFSET REGB
		JMP ZSBC8
ZE3:    CALL POSTBYTE
		JMP ZADDD
ZE4:    CALL POSTBYTE
		MOV DI,OFFSET REGB
		JMP ZAND8
ZE5:    CALL POSTBYTE
		MOV DI,OFFSET REGB
		JMP ZBIT8
ZE6:    CALL POSTBYTE
		MOV DI,OFFSET REGB
		JMP ZLD8
ZE7:    CALL POSTBYTE
		MOV DI,OFFSET REGB
		JMP ZST8
ZE8:    CALL POSTBYTE
		MOV DI,OFFSET REGB
		JMP ZEOR8
ZE9:    CALL POSTBYTE
		MOV DI,OFFSET REGB
		JMP ZADC8
ZEA:    CALL POSTBYTE
		MOV DI,OFFSET REGB
		JMP ZOR8
ZEB:    CALL POSTBYTE
		MOV DI,OFFSET REGB
		JMP ZADD8
ZEC:    CALL POSTBYTE
		MOV DI,OFFSET REGD
		JMP ZLD16
ZED:    CALL POSTBYTE
		MOV DI,OFFSET REGD
		JMP ZST16
ZEE:    CALL POSTBYTE
		MOV DI,OFFSET REGU
		JMP ZLD16
ZEF:    CALL POSTBYTE
		MOV DI,OFFSET REGU
		JMP ZST16
ZF0:    CALL DIRECT16
		MOV DI,OFFSET REGB
		JMP ZSUB8
ZF1:    CALL DIRECT16
		MOV DI,OFFSET REGB
		JMP ZCMP8
ZF2:    CALL DIRECT16
		MOV DI,OFFSET REGB
		JMP ZSBC8
ZF3:    CALL DIRECT16
		JMP ZADDD
ZF4:    CALL DIRECT16
		MOV DI,OFFSET REGB
		JMP ZAND8
ZF5:    CALL DIRECT16
		MOV DI,OFFSET REGB
		JMP ZBIT8
ZF6:    CALL DIRECT16
		MOV DI,OFFSET REGB
		JMP ZLD8
ZF7:    CALL DIRECT16
		MOV DI,OFFSET REGB
		JMP ZST8
ZF8:    CALL DIRECT16
		MOV DI,OFFSET REGB
		JMP ZEOR8
ZF9:    CALL DIRECT16
		MOV DI,OFFSET REGB
		JMP ZADC8
ZFA:    CALL DIRECT16
		MOV DI,OFFSET REGB
		JMP ZOR8
ZFB:    CALL DIRECT16
		MOV DI,OFFSET REGB
		JMP ZADD8
ZFC:    CALL DIRECT16
		MOV DI,OFFSET REGD
		JMP ZLD16
ZFD:    CALL DIRECT16
		MOV DI,OFFSET REGD
		JMP ZST16
ZFE:    CALL DIRECT16
		MOV DI,OFFSET REGU
		JMP ZLD16
ZFF:    CALL DIRECT16
		MOV DI,OFFSET REGU
		JMP ZST16

;Indirect addressing post byte interpretation

POST0:	MOV BX,[DI]
		ADD WORD PTR [DI],1
		RET
POST1:	MOV BX,[DI]
		ADD WORD PTR [DI],2
		RET
POST2:	SUB WORD PTR [DI],1
		MOV BX,[DI]
		RET
POST3:	SUB WORD PTR [DI],2
		MOV BX,[DI]
		RET
POST4:	MOV BX,[DI]
		RET
POST5:	MOV BX,[DI]
		MOV AL,BYTE PTR REGB
		CBW
		ADD BX,AX
		RET
POST6:	MOV BX,[DI]
		MOV AL,BYTE PTR REGA
		CBW
		ADD BX,AX
		RET
POST7:	RET
POST8:	MOV BX,SI
		CALL GETBYTE
        CBW
        INC SI
        ADD AX,[DI]
        MOV BX,AX
        RET
POST9:	MOV BX,SI
		CALL GETWORD
		ADD SI,2
        ADD AX,[DI]
        MOV BX,AX
        RET
POSTA:	RET
POSTB:  MOV BX,[DI]
        ADD BX,REGD
        RET
POSTC:	MOV BX,SI
		CALL GETBYTE
        CBW
        INC SI
        ADD AX,SI
        MOV BX,AX
        RET
POSTD:	MOV BX,SI
		CALL GETWORD
		ADD SI,2
        ADD AX,SI
        MOV BX,AX
        RET
POSTE:	RET
POSTF:	MOV BX,SI
		CALL GETWORD
		ADD SI,2
        MOV BX,AX
        RET

;EXG and TFR instructions

NOREG	DW 0

TFREXG_LIST DW REGD,REGX,REGY,REGU,REGSP,REGPC,NOREG,NOREG
	DW REGA,REGB,REGFI,REGDP,NOREG,NOREG,NOREG,NOREG

GET_TFREXG_REG:
		MOV BL,AL
		AND BX,0FH
		SHL BX,1
		MOV DI,TFREXG_LIST[BX]
		MOV BL,AL
		AND BX,0F0H
		SHR BX,1
		SHR BX,1
		SHR BX,1
		MOV BX,TFREXG_LIST[BX]
		RET

;10h prefixed instructions

LONG_CONDITION_TRUE:   
		ADD SI,AX
        RET

X21:    MOV BX,2                ;LBRN
		JMP ZNOP
X22:    CALL ZCLBRA             ;LBHI
		JA LONG_CONDITION_TRUE
		RET
X23:    CALL ZCLBRA             ;LBLS
		JNA LONG_CONDITION_TRUE
		RET
X24:    CALL ZCLBRA             ;LBCC
		JNB LONG_CONDITION_TRUE
		RET
X25:    CALL ZCLBRA             ;LBCS
		JB LONG_CONDITION_TRUE
		RET
X26:    CALL ZCLBRA             ;LBNE
		JNZ LONG_CONDITION_TRUE
		RET
X27:    CALL ZCLBRA             ;LBEQ
		JZ LONG_CONDITION_TRUE
		RET
X28:    CALL ZCLBRA             ;LBVC
		JNO LONG_CONDITION_TRUE
		RET
X29:    CALL ZCLBRA             ;LBVS
		JO LONG_CONDITION_TRUE
		RET
X2A:    CALL ZCLBRA             ;LSIL
		JNS LONG_CONDITION_TRUE
		RET
X2B:    CALL ZCLBRA             ;LBMI
		JS LONG_CONDITION_TRUE
		RET
X2C:    CALL ZCLBRA             ;LBGE
		JGE LONG_CONDITION_TRUE
		RET
X2D:    CALL ZCLBRA             ;LBLT
		JL LONG_CONDITION_TRUE
		RET
X2E:    CALL ZCLBRA             ;LBGT
		JG LONG_CONDITION_TRUE
		RET
X2F:    CALL ZCLBRA             ;LBLE
		JLE LONG_CONDITION_TRUE
		RET
X3F:    MOV DI,0FFF4H
		MOV CL,0
		JMP ZSWI
X83:    CALL IMMED16
		MOV DI,OFFSET REGD
		JMP ZCMP16
X8C:    CALL IMMED16
		MOV DI,OFFSET REGY
		JMP ZCMP16
X8E:    CALL IMMED16
		MOV DI,OFFSET REGY
		JMP ZLD16
X93:    CALL DIRECT8
		MOV DI,OFFSET REGD
		JMP ZCMP16
X9C:    CALL DIRECT8
		MOV DI,OFFSET REGY
		JMP ZCMP16
X9E:    CALL DIRECT8
		MOV DI,OFFSET REGY
		JMP ZLD16
X9F:    CALL DIRECT8
		MOV DI,OFFSET REGY
		JMP ZST16
XA3:    CALL POSTBYTE
		MOV DI,OFFSET REGD
		JMP ZCMP16
XAC:    CALL POSTBYTE
		MOV DI,OFFSET REGY
		JMP ZCMP16
XAE:    CALL POSTBYTE
		MOV DI,OFFSET REGY
		JMP ZLD16
XAF:    CALL POSTBYTE
		MOV DI,OFFSET REGY
		JMP ZST16
XB3:    CALL DIRECT16
		MOV DI,OFFSET REGD
		JMP ZCMP16
XBC:    CALL DIRECT16
		MOV DI,OFFSET REGY
		JMP ZCMP16
XBE:    CALL DIRECT16	
		MOV DI,OFFSET REGY
		JMP ZLD16
XBF:    CALL DIRECT16
		MOV DI,OFFSET REGY
		JMP ZST16
XCE:    CALL IMMED16
		MOV DI,OFFSET REGSP
		JMP ZLD16
XDE:    CALL DIRECT8
		MOV DI,OFFSET REGSP
		JMP ZLD16
XDF:    CALL DIRECT8
		MOV DI,OFFSET REGSP
		JMP ZST16
XEE:    CALL POSTBYTE
		MOV DI,OFFSET REGSP
		JMP ZLD16
XEF:    CALL POSTBYTE
		MOV DI,OFFSET REGSP
		JMP ZST16
XFE:    CALL DIRECT16
		MOV DI,OFFSET REGSP
		JMP ZLD16
XFF:    CALL DIRECT16
		MOV DI,OFFSET REGSP
		JMP ZST16

;11h prefixed instructions

Y3F:    MOV DI,0FFF2H
		MOV CL,0
		JMP ZSWI
Y83:    CALL IMMED16
		MOV DI,OFFSET REGU
		JMP ZCMP16
Y8C:    CALL IMMED16
		MOV DI,OFFSET REGSP
		JMP ZCMP16
Y93:    CALL DIRECT8
		MOV DI,OFFSET REGU
		JMP ZCMP16
Y9C:    CALL DIRECT8
		MOV DI,OFFSET REGSP
		JMP ZCMP16
YA3:    CALL POSTBYTE
		MOV DI,OFFSET REGU
		JMP ZCMP16
YAC:    CALL POSTBYTE
		MOV DI,OFFSET REGSP
		JMP ZCMP16
YB3:    CALL DIRECT16
		MOV DI,OFFSET REGU
		JMP ZCMP16
YBC:    CALL DIRECT16
		MOV DI,OFFSET REGSP
		JMP ZCMP16

;This is a special opcode to exit the emulator

YFE:    CALL VALIDATE_NATIVE
        JMP QUIT1

;This special opcode is an external call to 8086 instructions
;Registers: D <-> REGD, PC <-> SI, SP <-> BP, X <-> CX, Y <-> DI
;           U <-> BX, DP <-> AH
;           CS alligned to 8086 code, DS, ES set to 64K of RAM
;           Return from this with a RETF.

YFF:    CALL VALIDATE_NATIVE
        PUSH DS
        PUSH ES
        PUSH CS
        MOV AX,OFFSET YFF_RETURN
        PUSH AX
        MOV BX,REGU
		MOV CX,REGX
		MOV DX,REGD
		MOV DI,REGY
		MOV BP,REGSP
        PUSH ES                 ;Save FAR address
        PUSH SI
        MOV AX,TOPRAM           ;Get RAMBANK
        MOV DS,AX
        MOV ES,AX
        MOV AH,CS:REGDP
        DB 0CBH                 ;RETF
YFF_RETURN:
        POP ES
        POP DS
        MOV REGU,BX
		MOV REGX,CX
		MOV REGD,DX
		MOV REGY,DI
		MOV REGSP,BP
        MOV REGDP,AH
        RET

VALIDATE_NATIVE:
        CMP WORD PTR NATIVE,564AH
        JNZ NATIVE_OFF
        RET
NATIVE_OFF:
        POP AX
        RET

PROG    ENDS
        END
