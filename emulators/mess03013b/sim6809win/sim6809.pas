//{$A+,B-,D-,E-,F+,G+,I-,L-,N-,O-,P-,Q-,R-,S-,T+,V+,X+}
//{$M 16384,0,655360}

{ SIM6809 - Simulator fÅr das Motorola-6809-System des TI-Praktikums
	    an der UniversitÑt Ulm
  Version 0.24 vom 05.02.2000

  Copyright (C) 1998-2000 by Raimund Specht
	   raimund.specht@informatik.uni-ulm.de
	   http://home.primusnetz.de/rspecht/computer/studium/sim6809.htm

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation.
  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRENTY; without even the implied warrenty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  6809 monitor program (*):
    Copyright (C) 1997 by Jîrg Siedenburg
	   joerg.siedenburg@informatik.uni-ulm.de

  (*) may not be under GPL license

  ---
  Changes / Bug fixes:

  v0.24: * bugfix: SUBD (overflow flag) ("udivmd" and "sdivmd" now ok)
         * bugfix: EXG (was executed as TFR instead)
         * RAM is initially filled with random values (instead of zero's)
         * 6809-reset no longer clears RAM either
         * SIM6809 can now report read access to uninitialized RAM cells
         * new command line switches control behaviour on errors (see readme.txt)

  v0.23: * bugfix: long branch (LBRA) inserted - forgotten :-(

  v0.22: * program output can now be logged to a file
	 * supports new V1.2 monitor program (GotoXY and ClrScr)
	 * minor changes (put stuff from HandleKeyboard into new procs)

  v0.21: * bugfix: DAA (carry flag)
	 * counts 6809 CPU cycles

  v0.2:  * bugfix: long simple conditional branches (opcodes 1024 .. 102B)
	 * bugfix: DAA - hope it works now
	 * some constants renamed, some new constants added

  v0.1:  * first public release

  ---
  Known bugs / limitations:

  * CWAI and SYNC not fully implemented
  * hardware interrupts not supported
}

unit SIM6809;

interface

procedure HandleKeyboard(c, d: Char; datei: String);
procedure Sim6809Main;

implementation

//uses Crt, Dos;
uses win6809, SysUtils;

type TOpcode = Byte;
     TRegs6809 = record  { MC6809 registers }
		   X, Y, U, S, PC: Word;
		   DP: Byte;
		   CFlag, VFlag, ZFlag, NFlag, IFlag,
		    HFlag, FFlag, EFlag: Boolean;
		   case Byte of
		     0: (B, A: Byte);
		     1: (D: Word);
		 end;
     TOpcodeHandler = procedure(const OpC: TOpcode);
     TMem32K = array[0..$7FFF] of Byte;
     TOnSimError = (none, stop, doreset, ignore, report);


const C_FLAG = 1;    { carry flag }
      V_FLAG = 2;    { overflow flag }
      Z_FLAG = 4;    { zero flag }
      N_FLAG = 8;    { negative flag }
      I_FLAG = 16;   { IRQ mask }
      H_FLAG = 32;   { half carry flag (BCD) }
      F_FLAG = 64;   { FIRQ mask }
      E_FLAG = 128;  { entire flag }

      INPUTBUFFERSIZE = 15360;   { 15 kB }

      RESET_VEC = $FFFE;   { 6809 interrupt vector locations }
      NMI_VEC = $FFFC;
      IRQ_VEC = $FFF8;
      FIRQ_VEC = $FFF6;
      SWI_VEC = $FFFA;
      SWI2_VEC = $FFF4;
      SWI3_VEC = $FFF2;
      RSVD_VEC = $FFF0;

      ACIA_BASE = $F06C;   { ACIA registers }
      ACIA_LENGTH = $4;

      VIA_BASE = $F070;   { VIA 6522 registers }
      VIA_LENGTH = $10;
      VIA_INOUT_B = $0;
      VIA_INOUT_A = $1;
      VIA_DATADIR_B = $2;
      VIA_DATADIR_A = $3;
      VIA_TIM1_CL_LOW = $4;
      VIA_TIM1_C_HIGH = $5;
      VIA_TIM1_L_LOW = $6;
      VIA_TIM1_L_HIGH = $7;
      VIA_TIM2_CL_LOW = $8;
      VIA_TIM2_C_HIGH = $9;
      VIA_SHIFTREG = $A;
      VIA_AUXCONTROL = $B;
      VIA_PERIPHCONTROL = $C;
      VIA_INTFLAG = $D;
      VIA_INTENABLE = $E;
      VIA_INOUT_A_2 = $F;

      SIM6809_COLOR = 0; //LightCyan;
      STANDARD_COLOR = 1; //LightGray;
      VERSION = '0.24';


var Regs: TRegs6809;
    Mem1, Mem2: ^TMem32K;  { 2 * 32kB = 64kB 6809-RAM/ROM }
    RAMInited: ^TMem32K;  { speichern, welche RAM-Speicherzellen initialisiert }
    OpcodeHandler: array[$00..$FF] of TOpcodeHandler;
    PCOfOpcode: Word;
    InputBuffer: array[0..INPUTBUFFERSIZE] of Byte;
    InputEndPtr, InputActPtr: Word;
    Downloading: Boolean;
    OnIOPError, OnRURError, OnWRError: TOnSimError;
    TaktCounter, StartTime: LongInt;
    LogFile: File of Byte;
    Logging: Boolean;
    ExtCmdStatus: Byte;   { 0: normal; 1: ESC read; 2: read params }
    ExtCMdParam: array [1..8] of Integer;
    ExtCmdParamIndx: Integer;

  { --------------------------------------------------------------------- }

procedure Reset6809; forward;


function HexB(const b: Byte): String;
const HEXZIFF: array[0..15] of Char = '0123456789ABCDEF';
begin
  HexB:=HEXZIFF[b SHR 4] + HEXZIFF[b AND 15];
end;  { HexB }


function HexW(const b: Word): String;
begin
  HexW:=HexB(Hi(b)) + HexB(Lo(b));
end;  { HexW }


function ReadTime: LongInt;
var h, m, s, s100: Word;
begin
  GetTime(h, m, s, s100);
  ReadTime:=s100 + 100*s + 6000*m + 360000*h;
end;  { ReadTime }


function GetRegsCC: Byte;
var CC: Byte;
begin
  CC:=0;
  with Regs do
  begin
    if CFlag then Inc(CC, C_FLAG);
    if VFlag then Inc(CC, V_FLAG);
    if ZFlag then Inc(CC, Z_FLAG);
    if NFlag then Inc(CC, N_FLAG);
    if IFlag then Inc(CC, I_FLAG);
    if HFlag then Inc(CC, H_FLAG);
    if FFlag then Inc(CC, F_FLAG);
    if EFlag then Inc(CC, E_FLAG);
  end;
  GetRegsCC:=CC;
end;  { GetRegsCC }


procedure SetRegsCC(const CC: Byte);
begin
  with Regs do
  begin
    CFlag:=(CC AND C_FLAG)<>0;
    VFlag:=(CC AND V_FLAG)<>0;
    IFlag:=(CC AND I_FLAG)<>0;
    NFlag:=(CC AND N_FLAG)<>0;
    FFlag:=(CC AND F_FLAG)<>0;
    EFlag:=(CC AND E_FLAG)<>0;
    HFlag:=(CC AND H_FLAG)<>0;
    ZFlag:=(CC AND Z_FLAG)<>0;
  end;
end;  { SetRegsCC }


procedure Print6809State;
begin
  WriteLn('A: '+HexB(Regs.A)+'      B: '+HexB(Regs.B)+'      D: '+HexW(Regs.D));
  WriteLn('X: '+HexW(Regs.X)+'    Y: '+HexW(Regs.Y)+'    DP: '+HexB(Regs.DP));
  WriteLn('U: '+HexW(Regs.U)+'    S: '+HexW(Regs.S));
  Write('CC: ');
  with Regs do
  begin
    if EFlag then Write('E')
	     else Write('-');
    if FFlag then Write('F')
	     else Write('-');
    if HFlag then Write('H')
	     else Write('-');
    if IFlag then Write('I')
	     else Write('-');
    if NFlag then Write('N')
	     else Write('-');
    if ZFlag then Write('Z')
	     else Write('-');
    if VFlag then Write('V')
	     else Write('-');
    if CFlag then WriteLn('C')
	     else WriteLn('-');
  end;
end;  { Print6809State }


procedure IncTakte(const t: Byte);
begin
  Inc(TaktCounter, t);
end;  { IncTakte }


procedure SetFlagsB(const v, Flags: Byte);
begin
  if (Flags and Z_FLAG)<>0 then Regs.ZFlag:=(v = 0);
  if (Flags and N_FLAG)<>0 then Regs.NFlag:=(ShortInt(v) < 0);
end;  { SetFlagsB }


procedure SetFlagsW(const v: Word; const Flags: Byte);
begin
  if (Flags and Z_FLAG)<>0 then Regs.ZFlag:=(v = 0);
  if (Flags and N_FLAG)<>0 then Regs.NFlag:=(Integer(v) < 0);
end;  { SetFlagsW }


function GetMem6809(const Addr: Word): Byte;
begin
{  if (Addr>=$F06C) and (Addr<=$F06F) and
     (Addr<>$F06D) and (Addr<>$F06C) then
  begin
    WriteLn('Read from ACIA $' + HexW(Addr));
    Print6809State;
    WriteLn;
    ReadKey;
  end;

  if (Addr>=$f070) and (Addr<=$f07f) then
  begin
    WriteLn('Read from VIA $' + HexW(Addr));
    Print6809State;
    WriteLn;
    ReadKey;
  end; }

  if Addr < $8000 then
  begin
    if RAMInited^[Addr]=0 then
    begin
      if OnRURError <> ignore then
      begin
        //TextColor(SIM6809_COLOR);
        WriteLn('SIM6809: Read from uninitialized RAM ' + HexW(Addr) +
	        ' at PC '+HexW(PCOfOpcode));
        Print6809State;
        //TextColor(STANDARD_COLOR);
        WriteLn('');
      end;
      case OnRURError of
        doreset: Reset6809;
        stop: MyHalt;
      end;
    end;
    GetMem6809:=Mem1^[Addr];
  end else GetMem6809:=Mem2^[Addr AND $7FFF];

  { memory mapped IO }
  if Addr = $F06D then GetMem6809:=$10 +  { ACIA: Host ready (?) }
				   8*Ord(InputEndPtr>0);  { ACIA: Input available }
  if Addr = $F06C then
  begin
    GetMem6809:=InputBuffer[InputActPtr];  { Read from host }
    Inc(InputActPtr);
    if InputActPtr >= InputEndPtr then
    begin  { end of input }
      InputEndPtr:=0;
      InputActPtr:=0;
      Downloading:=False;
    end;
  end;
end;  { GetMem6809 }


procedure SetMem6809(const Addr: Word; value: Byte);
var IsExtChar: Boolean;
begin
  if Addr < $8000 then
  begin  { RAM }
    Mem1^[Addr]:=value;
    RAMInited^[Addr]:=1;
  end else
  begin  { ROM }
    if (Addr>=$F06C) and (Addr<=$F06F) then
     begin  { handle ACIA }
       if Addr = $F06C then
       begin
	 if Logging and not Downloading then FWrite(value);// Write(LogFile, value);

	 { support for extended commands (GotoXY, ClrScr) }
	 IsExtChar:=False;
	 case value of
	   $1B: begin
		  ExtCmdStatus:=1;   { ESC }
		  IsExtChar:=True;
		end;
	   $5B: if ExtCmdStatus=1 then   { [ }
		begin
		  ExtCmdStatus:=2;
		  ExtCmdParamIndx:=1;
		  ExtCmdParam[1]:=0;
		  IsExtChar:=True;
		end;
	   $30..$39: if ExtCmdStatus=2 then
		begin   { 0 - 9: read parameter (may have >1 digits) }
		  ExtCmdParam[ExtCmdParamIndx]:=ExtCmdParam[ExtCmdParamIndx]*10 +
						Ord(value)-$30;
		  IsExtChar:=True;
		end;
	   $3B: if ExtCmdStatus=2 then
		begin   { ; - end of _this_ parameter }
		  if ExtCmdParamIndx<8 then Inc(ExtCmdParamIndx);
		  ExtCmdParam[ExtCmdParamIndx]:=0;
		  IsExtChar:=True;
		end;
	   $48: begin   { H - command: GotoXY }
		  if (ExtCmdStatus=2) and (ExtCmdParamIndx=2) then
		  begin
		    GotoXY(ExtCmdParam[1], ExtCmdParam[2]);
		    IsExtChar:=True;
		  end;
		  ExtCmdStatus:=0;
		end;
	   $4A: begin   { J - command: ClrScr }
		  if (ExtCmdStatus=2) and (ExtCmdParamIndx=1) then
		  begin
		    if ExtCmdParam[1]=2 then ClrScr;
		    IsExtChar:=True;
		  end;
		  ExtCmdStatus:=0;
		end;
	 end;

	 if not Downloading and not IsExtChar then
	   Write(Chr(value));  { output to host }
       end;
     end else
     if (Addr>=VIA_BASE) and (Addr<VIA_BASE+VIA_LENGTH) then
     begin  { handle VIA }
       Mem2^[Addr AND $7FFF]:=value;   { ROM can be writeable :-) }
     end else
     begin
       if OnWRError <> ignore then
       begin
         //TextColor(SIM6809_COLOR);
  	 WriteLn('SIM6809: Cannot write to ROM ' + HexW(Addr) +
  		 ' at PC '+HexW(PCOfOpcode));
 	 Print6809State;
         //TextColor(STANDARD_COLOR);
	 WriteLn('');
       end;
       case OnWRError of
         doreset: Reset6809;
         stop: MyHalt;
       end;
     end;
  end;
end;  { SetMem6809 }


procedure SetMem6809W(const Addr, val: Word);
begin
  SetMem6809(Addr, val div 256);
  SetMem6809(Addr+1, val mod 256);
end;  { SetMem6809W }


function GetMem6809W(const Addr: Word): Word;
begin
  GetMem6809W:=GetMem6809(Addr)*Word(256) + GetMem6809(Addr + 1);
end;  { GetMem6809W }

  { --------------------------------------------------------------------- }
  { 6809 addressing modes:
	 imm - immediate         direct - direct
	 indx - indexed          ext - extended
    use Regs.PC as implicit address }

function GetByteImm: Byte;
begin
  GetByteImm:=GetMem6809(Regs.PC);
  Inc(Regs.PC);
end;  { GetByteImm }


function GetWordImm: Word;
begin
  GetWordImm:=GetMem6809W(Regs.PC);
  Inc(Regs.PC, 2);
end;  { GetWordImm }


function GetAddrDirect: Word;
begin
  GetAddrDirect:=Word(256)*Regs.DP + GetByteImm;
end;  { GetAddrDirect }


function GetByteDirect: Byte;
begin
  GetByteDirect:=GetMem6809(GetAddrDirect);
end;  { GetByteDirect }


function GetWordDirect: Word;
begin
  GetWordDirect:=GetMem6809W(GetAddrDirect);
end;  { GetWordDirect }


function GetAddrExt: Word;
begin
  GetAddrExt:=GetWordImm;
end;  { GetAddrExt }


function GetByteExt: Byte;
begin
  GetByteExt:=GetMem6809(GetAddrExt);
end;  { GetByteExt }


function GetWordExt: Word;
begin
  GetWordExt:=GetMem6809W(GetAddrExt);
end;  { GetWordExt }


function GetAddrIndx: Word;
var PostbyteOpC: TOpcode;
    RegCode, FktCode, b: Byte;
    Indirect: Boolean;
    Int8: ShortInt;
    Int16: Integer;
    Reg: Word;
begin
  PostbyteOpC:=GetByteImm;
  RegCode:=(PostbyteOpC AND $60) SHR 5;
  FktCode:=PostbyteOpC AND $F;
  Indirect:=(PostbyteOpC AND 16) <> 0;

  case RegCode of
    0: Reg:=Regs.X;
    1: Reg:=Regs.Y;
    2: Reg:=Regs.U;
    3: Reg:=Regs.S;
  end;

  if (PostbyteOpC and $80)=0 then
  begin  { n,R - 5 bit constant offset }
    b:=PostbyteOpC AND $1F;  { 5 bit offset is never indirect ! }
    b:=b + $E0*Ord((PostbyteOpC and 16)=16);  { sign extend 5 -> 8 bit }
    GetAddrIndx:=Reg + ShortInt(b);
    IncTakte(1);
  end else
  begin
    case FktCode of
      0,1: begin  { ,R+ and ,R++ (non) indirect - [,R+] is accepted although not allowed }
	     case RegCode of
	       0: begin
		    if Indirect then GetAddrIndx:=GetMem6809W(Regs.X)
				else GetAddrIndx:=Regs.X;
		    Inc(Regs.X, FktCode+1);
		  end;
	       1: begin
		    if Indirect then GetAddrIndx:=GetMem6809W(Regs.Y)
				else GetAddrIndx:=Regs.Y;
		    Inc(Regs.Y, FktCode+1);
		  end;
	       2: begin
		    if Indirect then GetAddrIndx:=GetMem6809W(Regs.U)
				else GetAddrIndx:=Regs.U;
		    Inc(Regs.U, FktCode+1);
		  end;
	       3: begin
		    if Indirect then GetAddrIndx:=GetMem6809W(Regs.S)
				else GetAddrIndx:=Regs.S;
		    Inc(Regs.S, FktCode+1);
		  end;
	     end;

	     IncTakte(2);
	     if FktCode=1 then IncTakte(1);
	     if Indirect then IncTakte(3);
	   end;
      2,3: begin  { ,-R and ,--R (non) indirect - [,-R] is accepted although not allowed }
	     case RegCode of
	       0: begin
		    Dec(Regs.X, FktCode-1);
		    if Indirect then GetAddrIndx:=GetMem6809W(Regs.X)
				else GetAddrIndx:=Regs.X;
		  end;
	       1: begin
		    Dec(Regs.Y, FktCode-1);
		    if Indirect then GetAddrIndx:=GetMem6809W(Regs.Y)
				else GetAddrIndx:=Regs.Y;
		  end;
	       2: begin
		    Dec(Regs.U, FktCode-1);
		    if Indirect then GetAddrIndx:=GetMem6809W(Regs.U)
				else GetAddrIndx:=Regs.U;
		  end;
	       3: begin
		    Dec(Regs.S, FktCode-1);
		    if Indirect then GetAddrIndx:=GetMem6809W(Regs.S)
				else GetAddrIndx:=Regs.S;
		  end;
	     end;

	     IncTakte(2);
	     if FktCode=1 then IncTakte(1);
	     if Indirect then IncTakte(3);
	   end;
      5: begin  { B,R and [B,R] }
	   if Indirect then
	   begin
	     GetAddrIndx:=GetMem6809W(Reg + ShortInt(Regs.B));
	     IncTakte(3);
	   end else GetAddrIndx:=Reg + ShortInt(Regs.B);
	   IncTakte(1);
	 end;
      6: begin  { A,R and [A,R] }
	   if Indirect then
	   begin
	     GetAddrIndx:=GetMem6809W(Reg + ShortInt(Regs.A));
	     IncTakte(3);
	   end else GetAddrIndx:=Reg + ShortInt(Regs.A);
	   IncTakte(1);
	 end;
      11: begin  { D,R and [D,R] }
	   if Indirect then
	   begin
	     GetAddrIndx:=GetMem6809W(Reg + Integer(Regs.D));
	     IncTakte(3);
	   end else GetAddrIndx:=Reg + Integer(Regs.D);
	   IncTakte(4);
	  end;
      8: begin  { n,R and [n,R] - 8 bit constant offset }
	   Int8:=ShortInt(GetByteImm);
	   if Indirect then
	   begin
	     GetAddrIndx:=GetMem6809W(Reg + Int8);
	     IncTakte(3);
	   end else GetAddrIndx:=Reg + Int8;
	   IncTakte(1);
	 end;
      4: begin  { ,R and [,R] - no offset }
	   if Indirect then
	   begin
	     GetAddrIndx:=GetMem6809W(Reg);
	     IncTakte(3);
	   end else GetAddrIndx:=Reg;
	 end;
      9: begin  { n,R and [n,R] - 16 bit constant offset }
	   Int16:=Integer(GetWordImm);
	   if Indirect then
	   begin
	     GetAddrIndx:=GetMem6809W(Reg + Int16);
	     IncTakte(3);
	   end else GetAddrIndx:=Reg + Int16;
	   IncTakte(4);
	 end;
      12: begin  { n,PCR and [n,PCR] - 8 bit offset from PC }
	    Int8:=ShortInt(GetByteImm);
	    if Indirect then
	    begin
	      GetAddrIndx:=GetMem6809W(Regs.PC + Int8);
	      IncTakte(3);
	    end else GetAddrIndx:=Regs.PC + Int8;
	   IncTakte(1);
	  end;
      13: begin  { n,PCR and [n,PCR] - 16 bit offset from PC }
	    Int16:=Integer(GetWordImm);
	    if Indirect then
	    begin
	      GetAddrIndx:=GetMem6809W(Regs.PC + Int16);
	      IncTakte(3);
	    end else GetAddrIndx:=Regs.PC + Int16;
	   IncTakte(5);
	  end;
      15: begin
	    GetAddrIndx:=GetMem6809W(GetWordImm);  { [n] - 16 bit address, extended indirect }
	    IncTakte(5);
	  end;
    end;
  end;
end;  { GetAddrIndx }


function GetByteIndx: Byte;
begin
  GetByteIndx:=GetMem6809(GetAddrIndx);
end;  { GetByteIndx }


function GetWordIndx: Word;
begin
  GetWordIndx:=GetMem6809W(GetAddrIndx);
end;  { GetWordIndx }

  { --------------------------------------------------------------------- }

procedure PushSysStackB(const b: Byte);
begin
  Dec(Regs.S);
  SetMem6809(Regs.S, b);
end;  { PushSysStackB }


function PullSysStackB: Byte;
begin
  PullSysStackB:=GetMem6809(Regs.S);
  Inc(Regs.S);
end;  { PullSysStackB }


procedure PushSysStackW(const w: Word);
begin
  Dec(Regs.S, 2);
  SetMem6809W(Regs.S, w);
end;  { PushSysStackW }


function PullSysStackW: Word;
begin
  PullSysStackW:=GetMem6809W(Regs.S);
  Inc(Regs.S, 2);
end;  { PullSysStackW }


procedure PushUserStackB(const b: Byte);
begin
  Dec(Regs.U);
  SetMem6809(Regs.U, b);
end;  { PushUserStackB }


procedure PushUserStackW(const w: Word);
begin
  Dec(Regs.U, 2);
  SetMem6809W(Regs.U, w);
end;  { PushUserStackW }


function PullUserStackB: Byte;
begin
  PullUserStackB:=GetMem6809(Regs.U);
  Inc(Regs.U);
end;  { PullUserStackB }


function PullUserStackW: Word;
begin
  PullUserStackW:=GetMem6809W(Regs.U);
  Inc(Regs.U, 2);
end;  { PullUserStackW }

  { --------------------------------------------------------------------- }

procedure CompareB(Reg, Mem: Byte);
var Mem2: Byte;
begin  { Reg - Mem ! }
  Mem2:=Byte(-Mem);
  with Regs do
  begin
    ZFlag:=(Reg=Mem);
    NFlag:=ShortInt(Reg + Mem2) < 0;
    CFlag:=(Reg < Mem);
    VFlag:=((ShortInt(Reg) < 0) and (ShortInt(Mem2) < 0) and
	    (ShortInt(Reg+Mem2) > 0)) or
	   ((ShortInt(Reg) > 0) and (ShortInt(Mem2) > 0) and
	    (ShortInt(Reg+Mem2) < 0));
  end;
end;  { CompareB }


procedure CompareW(const Reg, Mem: Word);
var Mem2: Word;
begin  { Reg - Mem ! }
  Mem2:=Word(-Mem);
  with Regs do
  begin
    ZFlag:=(Reg=Mem);
    NFlag:=Integer(Reg+Mem2) < 0;
    CFlag:=(Reg < Mem);
    VFlag:=((Integer(Reg)<0) and (Integer(Mem2)<0) and (Integer(Reg+Mem2)>0)) or
	   ((Integer(Reg)>0) and (Integer(Mem2)>0) and (Integer(Reg+Mem2)<0));
  end;
end;  { CompareW }

  { --------------------------------------------------------------------- }

procedure Reset6809;
var ROMFile: File;
begin
  Assign(ROMFile, 'romimage.bin');
  FileMode:=0;
  {$I-}  Reset(ROMFile, 1);  {$I+}
  if IOResult<>0 then
  begin
    //TextColor(SIM6809_COLOR);
    WriteLn('SIM6809: Cannot find ROMIMAGE.BIN');
    WriteLn('');
    //TextColor(STANDARD_COLOR);
    MyHalt;
  end;
  if FileSize(ROMFile)<>$0F80 then
  begin
    //TextColor(SIM6809_COLOR);
    WriteLn('SIM6809: ROMIMAGE.BIN size mismatch (not $F80 bytes)');
    WriteLn('');
    //TextColor(STANDARD_COLOR);
    MyHalt;
  end;
			 { $F080 - start of monitor program }
  BlockRead(ROMFile, Mem2^[28800], FileSize(ROMFile));
  Close(ROMFile);

  with Regs do
  begin
    D:=0;   X:=0;   Y:=0;   S:=0;   U:=0;
    DP:=0;  CFlag:=False;   VFlag:=False;   ZFlag:=False;   NFlag:=False;
    IFlag:=False;   FFlag:=False;   HFlag:=False;   EFlag:=False;
    PC:=GetMem6809W(RESET_VEC);  { RESET interrupt vector }
  end;
  ExtCmdStatus:=0;

  Delay(1500);  { simulated reset is too fast :) }
end;  { Reset6809 }

  { --------------------------------------------------------------------- }

procedure OpIllegalOpcode(const OpC: TOpcode);
begin
  if OnIOPError <> ignore then
  begin
    //TextColor(SIM6809_COLOR);
    WriteLn('SIM6809: Illegal opcode '+HexB(OpC)+' at PC '+HexW(PCOfOpcode));
    Print6809State;
    //TextColor(STANDARD_COLOR);
    WriteLn('');
  end;
  case OnIOPError of
    doreset: Reset6809;
    stop: MyHalt;
  end;
end;  { OpIllegalOpcode }


procedure OpABX(const OpC: TOpcode);
begin
  Inc(Regs.X, Regs.B);
  IncTakte(3);
end;  { OpABX }


procedure OpADC(const OpC: TOpcode);
var b, Carry: Byte;

  procedure SetVFlagB(const Reg, Mem: Byte);
  begin
    Regs.VFlag:=((ShortInt(Reg)<0) and (ShortInt(Mem)<0) and (ShortInt(Reg+Mem+Carry)>0)) or
		((ShortInt(Reg)>0) and (ShortInt(Mem)>0) and (ShortInt(Reg+Mem+Carry)<0));
  end;

begin
  Carry:=Ord(Regs.CFlag);

  case OpC of
    $89: begin  { ADCA Imm. }
	   b:=GetByteImm;
	   Regs.HFlag:=(((Regs.A AND 15) + (b AND 15) + Carry) > 15);
	   SetVFlagB(Regs.A, b);
	   Regs.CFlag:=(Word(Regs.A) + Word(b) + Carry > 255);
	   Regs.A:=Regs.A + b + Carry;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $99: begin  { ADCA Direct }
	   b:=GetByteDirect;
	   Regs.HFlag:=(((Regs.A AND 15) + (b AND 15) + Carry) > 15);
	   SetVFlagB(Regs.A, b);
	   Regs.CFlag:=(Word(Regs.A) + Word(b) + Carry > 255);
	   Regs.A:=Regs.A + b + Carry;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $A9: begin  { ADCA Indx. }
	   b:=GetByteIndx;
	   Regs.HFlag:=(((Regs.A AND 15) + (b AND 15) + Carry) > 15);
	   SetVFlagB(Regs.A, b);
	   Regs.CFlag:=(Word(Regs.A) + Word(b) + Carry > 255);
	   Regs.A:=Regs.A + b + Carry;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $B9: begin  { ADCA Ext. }
	   b:=GetByteExt;
	   Regs.HFlag:=(((Regs.A AND 15) + (b AND 15) + Carry) > 15);
	   SetVFlagB(Regs.A, b);
	   Regs.CFlag:=(Word(Regs.A) + Word(b) + Carry > 255);
	   Regs.A:=Regs.A + b + Carry;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
    $C9: begin  { ADCB Imm. }
	   b:=GetByteImm;
	   Regs.HFlag:=(((Regs.B AND 15) + (b AND 15) + Carry) > 15);
	   SetVFlagB(Regs.B, b);
	   Regs.CFlag:=(Word(Regs.B) + Word(b) + Carry > 255);
	   Regs.B:=Regs.B + b + Carry;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $D9: begin  { ADCB Direct }
	   b:=GetByteDirect;
	   Regs.HFlag:=(((Regs.B AND 15) + (b AND 15) + Carry) > 15);
	   SetVFlagB(Regs.B, b);
	   Regs.CFlag:=(Word(Regs.B) + Word(b) + Carry > 255);
	   Regs.B:=Regs.B + b + Carry;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $E9: begin  { ADCB Indx. }
	   b:=GetByteIndx;
	   Regs.HFlag:=(((Regs.B AND 15) + (b AND 15) + Carry) > 15);
	   SetVFlagB(Regs.B, b);
	   Regs.CFlag:=(Word(Regs.B) + Word(b) + Carry > 255);
	   Regs.B:=Regs.B + b + Carry;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $F9: begin  { ADCB Ext. }
	   b:=GetByteExt;
	   Regs.HFlag:=(((Regs.B AND 15) + (b AND 15) + Carry) > 15);
	   SetVFlagB(Regs.B, b);
	   Regs.CFlag:=(Word(Regs.B) + Word(b) + Carry > 255);
	   Regs.B:=Regs.B + b + Carry;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
  end;
end;  { OpADC }


procedure OpADD(const OpC: TOpcode);
var Mem8: Byte;
    Mem16: Word;

  procedure SetVFlagB(const Reg, Mem: Byte);
  begin
    Regs.VFlag:=((ShortInt(Reg)<0) and (ShortInt(Mem)<0) and (ShortInt(Reg+Mem)>0)) or
		((ShortInt(Reg)>0) and (ShortInt(Mem)>0) and (ShortInt(Reg+Mem)<0));
  end;

  procedure SetVFlagW(const Reg, Mem: Word);
  begin
    Regs.VFlag:=((Integer(Reg)<0) and (Integer(Mem)<0) and (Integer(Reg+Mem)>0)) or
		((Integer(Reg)>0) and (Integer(Mem)>0) and (Integer(Reg+Mem)<0));
  end;

begin
  case OpC of
    $8B: begin  { ADDA Imm. }
	   Mem8:=GetByteImm;
	   Regs.HFlag:=(((Regs.A AND 15) + (Mem8 AND 15)) > 15);
	   SetVFlagB(Regs.A, Mem8);
	   Regs.CFlag:=(Word(Regs.A) + Word(Mem8) > 255);
	   Regs.A:=Regs.A + Mem8;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $9B: begin  { ADDA Direct }
	   Mem8:=GetByteDirect;
	   Regs.HFlag:=(((Regs.A AND 15) + (Mem8 AND 15)) > 15);
	   SetVFlagB(Regs.A, Mem8);
	   Regs.CFlag:=(Word(Regs.A) + Word(Mem8) > 255);
	   Regs.A:=Regs.A + Mem8;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $AB: begin  { ADDA Indx. }
	   Mem8:=GetByteIndx;
	   Regs.HFlag:=(((Regs.A AND 15) + (Mem8 AND 15)) > 15);
	   SetVFlagB(Regs.A, Mem8);
	   Regs.CFlag:=(Word(Regs.A) + Word(Mem8) > 255);
	   Regs.A:=Regs.A + Mem8;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $BB: begin  { ADDA Ext. }
	   Mem8:=GetByteExt;
	   Regs.HFlag:=(((Regs.A AND 15) + (Mem8 AND 15)) > 15);
	   SetVFlagB(Regs.A, Mem8);
	   Regs.CFlag:=(Word(Regs.A) + Word(Mem8) > 255);
	   Regs.A:=Regs.A + Mem8;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
    $CB: begin  { ADDB Imm. }
	   Mem8:=GetByteImm;
	   Regs.HFlag:=(((Regs.B AND 15) + (Mem8 AND 15)) > 15);
	   SetVFlagB(Regs.B, Mem8);
	   Regs.CFlag:=(Word(Regs.B) + Word(Mem8) > 255);
	   Regs.B:=Regs.B + Mem8;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $DB: begin  { ADDB Direct }
	   Mem8:=GetByteDirect;
	   Regs.HFlag:=(((Regs.B AND 15) + (Mem8 AND 15)) > 15);
	   SetVFlagB(Regs.B, Mem8);
	   Regs.CFlag:=(Word(Regs.B) + Word(Mem8) > 255);
	   Regs.B:=Regs.B + Mem8;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $EB: begin  { ADDB Indx. }
	   Mem8:=GetByteIndx;
	   Regs.HFlag:=(((Regs.B AND 15) + (Mem8 AND 15)) > 15);
	   SetVFlagB(Regs.B, Mem8);
	   Regs.CFlag:=(Word(Regs.B) + Word(Mem8) > 255);
	   Regs.B:=Regs.B + Mem8;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $FB: begin  { ADDB Ext. }
	   Mem8:=GetByteExt;
	   Regs.HFlag:=(((Regs.B AND 15) + (Mem8 AND 15)) > 15);
	   SetVFlagB(Regs.B, Mem8);
	   Regs.CFlag:=(Word(Regs.B) + Word(Mem8) > 255);
	   Regs.B:=Regs.B + Mem8;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
    $C3: begin  { ADDD Imm. }
	   Mem16:=GetWordImm;
	   SetVFlagW(Regs.D, Mem16);
	   Regs.CFlag:=(LongInt(Regs.D) + LongInt(Mem16) > $FFFF);
	   Regs.D:=Regs.D + Mem16;
	   SetFlagsW(Regs.D, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $D3: begin  { ADDD Direct }
	   Mem16:=GetWordDirect;
	   SetVFlagW(Regs.D, Mem16);
	   Regs.CFlag:=(LongInt(Regs.D) + LongInt(Mem16) > $FFFF);
	   Regs.D:=Regs.D + Mem16;
	   SetFlagsW(Regs.D, N_FLAG + Z_FLAG);
	   IncTakte(6);
	 end;
    $E3: begin  { ADDD Indx. }
	   Mem16:=GetWordIndx;
	   SetVFlagW(Regs.D, Mem16);
	   Regs.CFlag:=(LongInt(Regs.D) + LongInt(Mem16) > $FFFF);
	   Regs.D:=Regs.D + Mem16;
	   SetFlagsW(Regs.D, N_FLAG + Z_FLAG);
	   IncTakte(6);
	 end;
    $F3: begin  { ADDD Ext. }
	   Mem16:=GetWordExt;
	   SetVFlagW(Regs.D, Mem16);
	   Regs.CFlag:=(LongInt(Regs.D) + LongInt(Mem16) > $FFFF);
	   Regs.D:=Regs.D + Mem16;
	   SetFlagsW(Regs.D, N_FLAG + Z_FLAG);
	   IncTakte(7);
	 end;
  end;
end;  { OpADD }


procedure OpAND(const OpC: TOpcode);
begin
  case OpC of
    $1C: begin
	   SetRegsCC(GetRegsCC AND GetByteImm);  { ANDCC }
	   IncTakte(3);
	 end;
    $84: begin  { ANDA Imm. }
	   Regs.A:=Regs.A AND GetByteImm;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $94: begin  { ANDA Direct }
	   Regs.A:=Regs.A AND GetByteDirect;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $A4: begin  { ANDA Indx. }
	   Regs.A:=Regs.A AND GetByteIndx;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $B4: begin  { ANDA Ext. }
	   Regs.A:=Regs.A AND GetByteExt;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
    $C4: begin  { ANDB Imm. }
	   Regs.B:=Regs.B AND GetByteImm;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $D4: begin  { ANDB Direct }
	   Regs.B:=Regs.B AND GetByteDirect;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $E4: begin  { ANDB Indx. }
	   Regs.B:=Regs.B AND GetByteIndx;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $F4: begin  { ANDB Ext. }
	   Regs.B:=Regs.B AND GetByteExt;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
  end;

  if OpC<>$1C then Regs.VFlag:=False;
end;  { OpAND }


procedure OpASR(const OpC: TOpcode);
var a: Word;
    b: Byte;
begin
  case OpC of
    $07: begin  { ASR Direct }
	   a:=GetAddrDirect;
	   b:=GetMem6809(a);
	   Regs.CFlag:=Odd(b);
	   b:=(b SHR 1) + (b and 128);
	   SetMem6809(a, b);
	   SetFlagsB(b, Z_FLAG + N_FLAG);
	   IncTakte(6);
	 end;
    $47: begin  { ASRA }
	   Regs.CFlag:=Odd(Regs.A);
	   Regs.A:=(Regs.A SHR 1) + (Regs.A and 128);
	   SetFlagsB(Regs.A, Z_FLAG + N_FLAG);
	   IncTakte(2);
	 end;
    $57: begin  { ASRB }
	   Regs.CFlag:=Odd(Regs.B);
	   Regs.B:=(Regs.B SHR 1) + (Regs.B and 128);
	   SetFlagsB(Regs.B, Z_FLAG + N_FLAG);
	   IncTakte(2);
	 end;
    $67: begin  { ASR Indx. }
	   a:=GetAddrIndx;
	   b:=GetMem6809(a);
	   Regs.CFlag:=Odd(b);
	   b:=(b SHR 1) + (b and 128);
	   SetMem6809(a, b);
	   SetFlagsB(b, Z_FLAG + N_FLAG);
	   IncTakte(6);
	 end;
    $77: begin  { ASR Ext. }
	   a:=GetAddrExt;
	   b:=GetMem6809(a);
	   Regs.CFlag:=Odd(b);
	   b:=(b SHR 1) + (b and 128);
	   SetMem6809(a, b);
	   SetFlagsB(b, Z_FLAG + N_FLAG);
	   IncTakte(7);
	 end;
  end;
end;  { OpASR }


procedure OpBIT(const OpC: TOpcode);
begin
  case OpC of
    $85: begin
	   SetFlagsB(Regs.A AND GetByteImm, N_FLAG + Z_FLAG);  { BITA Imm. }
	   IncTakte(2);
	 end;
    $95: begin
	   SetFlagsB(Regs.A AND GetByteDirect, N_FLAG + Z_FLAG);  { BITA Direct }
	   IncTakte(4);
	 end;
    $A5: begin
	   SetFlagsB(Regs.A AND GetByteIndx, N_FLAG + Z_FLAG);  { BITA Indx. }
	   IncTakte(4);
	 end;
    $B5: begin
	   SetFlagsB(Regs.A AND GetByteExt, N_FLAG + Z_FLAG);  { BITA Ext. }
	   IncTakte(5);
	 end;
    $C5: begin
	   SetFlagsB(Regs.B AND GetByteImm, N_FLAG + Z_FLAG);  { BITB Imm. }
	   IncTakte(2);
	 end;
    $D5: begin
	   SetFlagsB(Regs.B AND GetByteDirect, N_FLAG + Z_FLAG);  { BITB Direct }
	   IncTakte(4);
	 end;
    $E5: begin
	   SetFlagsB(Regs.B AND GetByteIndx, N_FLAG + Z_FLAG);  { BITB Indx. }
	   IncTakte(4);
	 end;
    $F5: begin
	   SetFlagsB(Regs.B AND GetByteExt, N_FLAG + Z_FLAG);  { BITB Ext. }
	   IncTakte(5);
	 end;
  end;

  Regs.VFlag:=False;
end;  { OpBIT }


procedure OpSimpleBRA(const OpC: TOpcode);
var Offset: LongInt;
begin
  Offset:=ShortInt(GetByteImm);
  if ((OpC=$24) and (not Regs.CFlag)) or     { BCC / BHS }
     ((OpC=$25) and (Regs.CFlag)) or         { BCS / BLO }
     ((OpC=$26) and (not Regs.ZFlag)) or     { BNE }
     ((OpC=$27) and (Regs.ZFlag)) or         { BEQ }
     ((OpC=$28) and (not Regs.VFlag)) or     { BVC }
     ((OpC=$29) and (Regs.VFlag)) or         { BVS }
     ((OpC=$2A) and (not Regs.NFlag)) or     { BPL }
     ((OpC=$2B) and (Regs.NFlag)) then Inc(Regs.PC, Offset);
  IncTakte(3);
end;  { OpSimpleBRA }


procedure OpBSR(const OpC: TOpcode);
var Offset: LongInt;
begin
  case OpC of
    $17: begin
	   Offset:=Integer(GetWordImm);   { LBSR }
	   IncTakte(2);
	 end;
    $8D: Offset:=ShortInt(GetByteImm);  { BSR }
  end;

  PushSysStackW(Regs.PC);
  Inc(Regs.PC, Offset);
  IncTakte(7);
end;  { OpBSR }


procedure OpCondBRA(const OpC: TOpcode);
var Offset: ShortInt;
begin
  Offset:=ShortInt(GetByteImm);
  case OpC of
    $2C: begin  { BGE -  N xor V = 0 }
	   if NOT (Regs.NFlag XOR Regs.VFlag) then
	     Inc(Regs.PC, Offset);
	 end;
    $2E: begin  { BGT -  Z or (N xor V) = 0 }
	   if NOT (Regs.ZFlag OR (Regs.NFlag XOR Regs.VFlag)) then
	     Inc(Regs.PC, Offset);
	 end;
    $2F: begin  { BLE -  Z or (N xor V) = 1 }
	   if Regs.ZFlag OR (Regs.NFlag XOR Regs.VFlag) then
	     Inc(Regs.PC, Offset);
	 end;
    $22: begin  { BHI -  Z or C = 0 }
	   if NOT (Regs.ZFlag OR Regs.CFlag) then
	     Inc(Regs.PC, Offset);
	 end;
    $23: begin  { BLS -  Z or C = 1 }
	   if Regs.ZFlag OR Regs.CFlag then
	     Inc(Regs.PC, Offset);
	 end;
    $2D: begin  { BLT -  N xor V = 1 }
	   if Regs.NFlag XOR Regs.VFlag then
	     Inc(Regs.PC, Offset);
	 end;
    $20: begin  { BRA }
	   Inc(Regs.PC, Offset);
	 end;
    $21: begin  { BRN }
	   { branch never }
	 end;
  end;
  IncTakte(3);
end;  { OpCondBRA }


procedure OpCLR(const OpC: TOpcode);
begin
  case OpC of
    $0F: begin
	   SetMem6809(GetAddrDirect, 0);  { CLR Direct }
	   IncTakte(6);
	 end;
    $4F: begin
	   Regs.A:=0;  { CLRA }
	   IncTakte(2);
	 end;
    $5F: begin
	   Regs.B:=0;  { CLRB }
	   IncTakte(2);
	 end;
    $6F: begin
	   SetMem6809(GetAddrIndx, 0);  { CLR Indx. }
	   IncTakte(6);
	 end;
    $7F: begin
	   SetMem6809(GetAddrExt, 0);  { CLR Ext. }
	   IncTakte(7);
	 end;
  end;

  with Regs do
  begin
    NFlag:=False;   VFlag:=False;   CFlag:=False;   ZFlag:=True;
  end;
end;  { OpCLR }


procedure OpCMP(const OpC: TOpcode);
begin
  case OpC of
    $81: begin
	   CompareB(Regs.A, GetByteImm);     { CMPA Imm. }
	   IncTakte(2);
	 end;
    $91: begin
	   CompareB(Regs.A, GetByteDirect);  { CMPA Direct }
	   IncTakte(4);
	 end;
    $A1: begin
	   CompareB(Regs.A, GetByteIndx);    { CMPA Indx. }
	   IncTakte(4);
	 end;
    $B1: begin
	   CompareB(Regs.A, GetByteExt);     { CMPA Ext. }
	   IncTakte(5);
	 end;
    $C1: begin
	   CompareB(Regs.B, GetByteImm);     { CMPB Imm. }
	   IncTakte(2);
	 end;
    $D1: begin
	   CompareB(Regs.B, GetByteDirect);  { CMPB Direct }
	   IncTakte(4);
	 end;
    $E1: begin
	   CompareB(Regs.B, GetByteIndx);    { CMPB Indx. }
	   IncTakte(4);
	 end;
    $F1: begin
	   CompareB(Regs.B, GetByteExt);     { CMPB Ext. }
	   IncTakte(5);
	 end;
    $8C: begin
	   CompareW(Regs.X, GetWordImm);     { CMPX Imm. }
	   IncTakte(4);
	 end;
    $9C: begin
	   CompareW(Regs.X, GetWordDirect);  { CMPX Direct }
	   IncTakte(6);
	 end;
    $AC: begin
	   CompareW(Regs.X, GetWordIndx);    { CMPX Indx. }
	   IncTakte(6);
	 end;
    $BC: begin
	   CompareW(Regs.X, GetWordExt);     { CMPX Ext. }
	   IncTakte(7);
	 end;
  end;
end;  { OpCMP }


procedure OpCOM(const OpC: TOpcode);
var a: Word;
    b: Byte;
begin
  case OpC of
    $03: begin  { COM Direct }
	   a:=GetAddrDirect;
	   b:=NOT GetMem6809(a);
	   SetMem6809(a, b);
	   SetFlagsB(b, N_FLAG + Z_FLAG);
	   IncTakte(6);
	 end;
    $43: begin  { COMA }
	   Regs.A:=NOT Regs.A;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $53: begin  { COMB }
	   Regs.B:=NOT Regs.B;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $63: begin  { COM Indx. }
	   a:=GetAddrIndx;
	   b:=NOT GetMem6809(a);
	   SetMem6809(a, b);
	   SetFlagsB(b, N_FLAG + Z_FLAG);
	   IncTakte(6);
	 end;
    $73: begin  { COM Ext. }
	   a:=GetAddrExt;
	   b:=NOT GetMem6809(a);
	   SetMem6809(a, b);
	   SetFlagsB(b, N_FLAG + Z_FLAG);
	   IncTakte(7);
	 end;
  end;

  Regs.CFlag:=True;
  Regs.VFlag:=False;
end;  { OpCOM }


procedure OpCWAI(const OpC: TOpcode);
begin
  { Wait for interrupt ?!? }
  //TextColor(SIM6809_COLOR);
  WriteLn('CWAI: Oops');
  //TextColor(STANDARD_COLOR);
  { push all regs on stack }
  SetRegsCC(GetRegsCC and GetByteImm);
  IncTakte(20);  { at least }
end;  { OpCWAI }


procedure OpDAA(const OpC: TOpcode);
var KorrLSD, KorrMSD: Boolean;
begin
  { Skript p. 103: }
  KorrLSD:=Regs.HFlag or ((Regs.A and $F) > 9);
  KorrMSD:=Regs.CFlag or (((Regs.A and $F0) shr 4) > 9) or
	   ((((Regs.A and $F0) shr 4) > 8) and ((Regs.A and $F) > 9));

  if KorrLSD then
  begin
    Regs.A:=((Regs.A and $F0) + ((Regs.A and 15) + 6) and 15) +
	    $10 * Ord((Regs.A and $F) > 9);
  end;

  Regs.CFlag:=False;
  if KorrMSD then
  begin
    Regs.CFlag:=(Word(Regs.A and $F0) + Word($60)) > 255;
    Regs.A:=(Regs.A and $F) + ((Regs.A and $F0) + $60) and $F0;
  end;

  SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
  Regs.VFlag:=False;

  IncTakte(2);
end;  { OpDAA }


procedure OpDEC(const OpC: TOpcode);
var a: Word;
    b: Byte;
begin
  case OpC of
    $0A: begin  { DEC Direct }
	   a:=GetAddrDirect;
	   b:=GetMem6809(a);
	   Regs.VFlag:=(b=$80);
	   Dec(b);
	   SetFlagsB(b, N_FLAG + Z_FLAG);
	   SetMem6809(a, b);
	   IncTakte(6);
	 end;
    $4A: begin  { DECA }
	   Regs.VFlag:=(Regs.A=$80);
	   Dec(Regs.A);
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $5A: begin  { DECB }
	   Regs.VFlag:=(Regs.B=$80);
	   Dec(Regs.B);
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $6A: begin  { DEC Indx. }
	   a:=GetAddrIndx;
	   b:=GetMem6809(a);
	   Regs.VFlag:=(b=$80);
	   Dec(b);
	   SetFlagsB(b, N_FLAG + Z_FLAG);
	   SetMem6809(a, b);
	   IncTakte(6);
	 end;
    $7A: begin  { DEC Ext. }
	   a:=GetAddrExt;
	   b:=GetMem6809(a);
	   Regs.VFlag:=(b=$80);
	   Dec(b);
	   SetFlagsB(b, N_FLAG + Z_FLAG);
	   SetMem6809(a, b);
	   IncTakte(7);
	 end;
  end;
end;  { OpDEC }


procedure OpEOR(const OpC: TOpcode);
begin
  case OpC of
    $88: begin  { EORA Imm. }
	   Regs.A:=Regs.A XOR GetByteImm;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $98: begin  { EORA Direct }
	   Regs.A:=Regs.A XOR GetByteDirect;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $A8: begin  { EORA Indx. }
	   Regs.A:=Regs.A XOR GetByteIndx;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $B8: begin  { EORA Ext. }
	   Regs.A:=Regs.A XOR GetByteExt;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
    $C8: begin  { EORB Imm. }
	   Regs.B:=Regs.B XOR GetByteImm;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $D8: begin  { EORB Direct }
	   Regs.B:=Regs.B XOR GetByteDirect;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $E8: begin  { EORB Indx. }
	   Regs.B:=Regs.B XOR GetByteIndx;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $F8: begin  { EORB Ext. }
	   Regs.B:=Regs.B XOR GetByteExt;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
  end;

  Regs.VFlag:=False;
end;  { OpEOR }


procedure OpEXG(const OpC: TOpcode);
var Postbyte: Byte;
    s, t: Word;
begin
  Postbyte:=GetByteImm;

  { grauslig :-( }
  case (Postbyte AND $F0) SHR 4 of
    0: s:=Regs.D;
    1: s:=Regs.X;
    2: s:=Regs.Y;
    3: s:=Regs.U;
    4: s:=Regs.S;
    5: s:=Regs.PC;
    8: s:=Regs.A;
    9: s:=Regs.B;
    10: s:=GetRegsCC;
    11: s:=Regs.DP;
  end;

  case Postbyte AND $F of
    0: begin
	 t:=Regs.D;
	 Regs.D:=s;
       end;
    1: begin
	 t:=Regs.X;
	 Regs.X:=s;
       end;
    2: begin
	 t:=Regs.Y;
	 Regs.Y:=s;
       end;
    3: begin
	 t:=Regs.U;
	 Regs.U:=s;
       end;
    4: begin
	 t:=Regs.S;
	 Regs.S:=s;
       end;
    5: begin
	 t:=Regs.PC;
	 Regs.PC:=s;
       end;
    8: begin
	 t:=Regs.A;
	 Regs.A:=s;
       end;
    9: begin
	 t:=Regs.B;
	 Regs.B:=s;
       end;
    10: begin
	 t:=GetRegsCC;
	 SetRegsCC(s);
       end;
    11: begin
	 t:=Regs.DP;
	 Regs.DP:=s;
       end;
  end;

  case (Postbyte AND $F0) SHR 4 of
    0: Regs.D:=t;
    1: Regs.X:=t;
    2: Regs.Y:=t;
    3: Regs.U:=t;
    4: Regs.S:=t;
    5: Regs.PC:=t;
    8: Regs.A:=t;
    9: Regs.B:=t;
    10: SetRegsCC(t);
    11: Regs.DP:=t;
  end;

  IncTakte(8);
end;  { OpEXG }


procedure OpINC(const OpC: TOpcode);
var a: Word;
    b: Byte;
begin
  case OpC of
    $0C: begin  { INC Direct }
	   a:=GetAddrDirect;
	   b:=GetMem6809(a);
	   Regs.VFlag:=(b = $7F);
	   Inc(b);
	   SetFlagsB(b, N_FLAG + Z_FLAG);
	   SetMem6809(a, b);
	   IncTakte(6);
	 end;
    $4C: begin  { INCA }
	   Regs.VFlag:=(Regs.A = $7F);
	   Inc(Regs.A);
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $5C: begin  { INCB }
	   Regs.VFlag:=(Regs.B = $7F);
	   Inc(Regs.B);
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $6C: begin  { INC Indx. }
	   a:=GetAddrIndx;
	   b:=GetMem6809(a);
	   Regs.VFlag:=(b = $7F);
	   Inc(b);
	   SetFlagsB(b, N_FLAG + Z_FLAG);
	   SetMem6809(a, b);
	   IncTakte(6);
	 end;
    $7C: begin  { INC Ext. }
	   a:=GetAddrExt;
	   b:=GetMem6809(a);
	   Regs.VFlag:=(b = $7F);
	   Inc(b);
	   SetFlagsB(b, N_FLAG + Z_FLAG);
	   SetMem6809(a, b);
	   IncTakte(7);
	 end;
  end;
end;  { OpINC }


procedure OpJMP(const OpC: TOpcode);
var Target: Word;
begin
  case OpC of
    $0E: begin
	   Target:=GetAddrDirect;  { JMP Direct }
	   IncTakte(3);
	 end;
    $6E: begin
	   Target:=GetAddrIndx;    { JMP Indx. }
	   IncTakte(3);
	 end;
    $7E: begin
	   Target:=GetAddrExt;     { JMP Ext. }
	   IncTakte(4);
	 end;
  end;

  Regs.PC:=Target;
end;  { OpJMP }


procedure OpJSR(const OpC: TOpcode);
var Target: Word;
begin
  case OpC of
    $9D: begin
	   Target:=GetAddrDirect;  { JSR Direct }
	   IncTakte(7);
	 end;
    $AD: begin
	   Target:=GetAddrIndx;    { JSR Indx. }
	   IncTakte(7);
	 end;
    $BD: begin
	   Target:=GetAddrExt;     { JSR Ext. }
	   IncTakte(8);
	 end;
  end;

  PushSysStackW(Regs.PC);
  Regs.PC:=Target;
end;  { OpJSR }


procedure OpLBRA(const OpC: TOpcode);
var Offset: LongInt;
begin
  Offset:=Integer(GetWordImm);
  Inc(Regs.PC, Offset);
  IncTakte(5);
end;  { OpLBRA }


procedure OpLD(const OpC: TOpcode);
begin
  case OpC of
    $86: begin  { LDA Imm. }
	   Regs.A:=GetByteImm;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $96: begin  { LDA Direct }
	   Regs.A:=GetByteDirect;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $A6: begin  { LDA Indx. }
	   Regs.A:=GetMem6809(GetAddrIndx);
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $B6: begin  { LDA Ext. }
	   Regs.A:=GetByteExt;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
    $C6: begin  { LDB Imm. }
	   Regs.B:=GetByteImm;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $D6: begin  { LDB Direct }
	   Regs.B:=GetByteDirect;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $E6: begin  { LDB Indx. }
	   Regs.B:=GetMem6809(GetAddrIndx);
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $F6: begin  { LDB Ext. }
	   Regs.B:=GetByteExt;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
    $8E: begin  { LDX Imm. }
	   Regs.X:=GetWordImm;
	   SetFlagsW(Regs.X, N_FLAG + Z_FLAG);
	   IncTakte(3);
	 end;
    $9E: begin  { LDX Direct }
	   Regs.X:=GetWordDirect;
	   SetFlagsW(Regs.X, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
    $AE: begin  { LDX Indx. }
	   Regs.X:=GetWordIndx;
	   SetFlagsW(Regs.X, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
    $BE: begin  { LDX Ext. }
	   Regs.X:=GetWordExt;
	   SetFlagsW(Regs.X, N_FLAG + Z_FLAG);
	   IncTakte(6);
	 end;
    $CE: begin  { LDU Imm. }
	   Regs.U:=GetWordImm;
	   SetFlagsW(Regs.U, N_FLAG + Z_FLAG);
	   IncTakte(3);
	 end;
    $DE: begin  { LDU Direct }
	   Regs.U:=GetWordDirect;
	   SetFlagsW(Regs.U, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
    $EE: begin  { LDU Indx. }
	   Regs.U:=GetWordIndx;
	   SetFlagsW(Regs.U, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
    $FE: begin  { LDU Ext. }
	   Regs.U:=GetWordExt;
	   SetFlagsW(Regs.U, N_FLAG + Z_FLAG);
	   IncTakte(6);
	 end;
    $CC: begin  { LDD Imm. }
	   Regs.D:=GetWordImm;
	   SetFlagsW(Regs.D, N_FLAG + Z_FLAG);
	   IncTakte(3);
	 end;
    $DC: begin  { LDD Direct }
	   Regs.D:=GetWordDirect;
	   SetFlagsW(Regs.D, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
    $EC: begin  { LDD Indx. }
	   Regs.D:=GetWordIndx;
	   SetFlagsW(Regs.D, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
    $FC: begin  { LDD Ext. }
	   Regs.D:=GetWordExt;
	   SetFlagsW(Regs.D, N_FLAG + Z_FLAG);
	   IncTakte(6);
	 end;
  end;

  Regs.VFlag:=False;
end;  { OpLD }


procedure OpLEA(const OpC: TOpcode);
var EffAddr: Word;
begin
  EffAddr:=GetAddrIndx;
  case OpC of
    $30: Regs.X:=EffAddr;  { LEAX }
    $31: Regs.Y:=EffAddr;  { LEAY }
    $32: Regs.S:=EffAddr;  { LEAS }
    $33: Regs.U:=EffAddr;  { LEAU }
  end;

  if OpC IN [$30, $31] then SetFlagsW(EffAddr, Z_FLAG);  { LEAX / LEAY }
  IncTakte(4);
end;  { OpLEA }


procedure OpLSR(const OpC: TOpcode);
var a: Word;
    b: Byte;
begin
  case OpC of
    $04: begin  { LSR Direct }
	   a:=GetAddrDirect;
	   b:=GetMem6809(a);
	   Regs.CFlag:=Odd(b);
	   b:=b SHR 1;
	   SetMem6809(a, b);
	   SetFlagsB(b, Z_FLAG);
	   IncTakte(6);
	 end;
    $44: begin  { LSRA }
	   Regs.CFlag:=Odd(Regs.A);
	   Regs.A:=Regs.A SHR 1;
	   SetFlagsB(Regs.A, Z_FLAG);
	   IncTakte(2);
	 end;
    $54: begin  { LSRB }
	   Regs.CFlag:=Odd(Regs.B);
	   Regs.B:=Regs.B SHR 1;
	   SetFlagsB(Regs.B, Z_FLAG);
	   IncTakte(2);
	 end;
    $64: begin  { LSR Indx. }
	   a:=GetAddrIndx;
	   b:=GetMem6809(a);
	   Regs.CFlag:=Odd(b);
	   b:=b SHR 1;
	   SetMem6809(a, b);
	   SetFlagsB(b, Z_FLAG);
	   IncTakte(6);
	 end;
    $74: begin  { LSR Ext. }
	   a:=GetAddrExt;
	   b:=GetMem6809(a);
	   Regs.CFlag:=Odd(b);
	   b:=b SHR 1;
	   SetMem6809(a, b);
	   SetFlagsB(b, Z_FLAG);
	   IncTakte(7);
	 end;
  end;

  Regs.NFlag:=False;
end;  { OpLSR }


procedure OpMUL(const OpC: TOpcode);
begin
  Regs.D:=Word(Regs.A) * Word(Regs.B);
  SetFlagsW(Regs.D, Z_FLAG);
  Regs.CFlag:=((Regs.B and 128)<>0);  { special case -
					Carry set if b7 is SET }
  IncTakte(11);
end;  { OpMUL }


procedure OpNEG(const OpC: TOpcode);
var a: Word;
    b: Byte;
begin
  case OpC of
    $00: begin  { NEG Direct }
	   a:=GetAddrDirect;
	   b:=(NOT GetMem6809(a)) + 1;
	   Regs.VFlag:=(b = $80);
	   Regs.CFlag:=(b <> 0);
	   SetMem6809(a, b);
	   SetFlagsB(b, N_FLAG + Z_FLAG);
	   IncTakte(6);
	 end;
    $40: begin  { NEGA }
	   Regs.A:=(NOT Regs.A) + 1;
	   Regs.VFlag:=(Regs.A = $80);
	   Regs.CFlag:=(Regs.A <> 0);
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $50: begin  { NEGB }
	   Regs.B:=(NOT Regs.B) + 1;
	   Regs.VFlag:=(Regs.B = $80);
	   Regs.CFlag:=(Regs.B <> 0);
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $60: begin  { NEG Indx. }
	   a:=GetAddrIndx;
	   b:=(NOT GetMem6809(a)) + 1;
	   Regs.VFlag:=(b = $80);
	   Regs.VFlag:=(b <> 0);
	   SetMem6809(a, b);
	   SetFlagsB(b, N_FLAG + Z_FLAG);
	   IncTakte(6);
	 end;
    $70: begin  { NEG Ext. }
	   a:=GetAddrExt;
	   b:=(NOT GetMem6809(a)) + 1;
	   Regs.VFlag:=(b = $80);
	   Regs.VFlag:=(b <> 0);
	   SetMem6809(a, b);
	   SetFlagsB(b, N_FLAG + Z_FLAG);
	   IncTakte(7);
	 end;
  end;
end;  { OpNEG }


procedure OpNOP(const OpC: TOpcode);
begin
  { No OPeration }
  IncTakte(2);
end;  { OpNOP }


procedure OpOR(const OpC: TOpcode);
begin
  case OpC of
    $1A: begin
	   SetRegsCC(GetRegsCC OR GetByteImm);  { ORCC }
	   IncTakte(3);
	 end;
    $8A: begin  { ORA Imm. }
	   Regs.A:=Regs.A OR GetByteImm;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $9A: begin  { ORA Direct }
	   Regs.A:=Regs.A OR GetByteDirect;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $AA: begin  { ORA Indx. }
	   Regs.A:=Regs.A OR GetByteIndx;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $BA: begin  { ORA Ext. }
	   Regs.A:=Regs.A OR GetByteExt;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
    $CA: begin  { ORB Imm. }
	   Regs.B:=Regs.B OR GetByteImm;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $DA: begin  { ORB Direct }
	   Regs.B:=Regs.B OR GetByteDirect;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $EA: begin  { ORB Indx. }
	   Regs.B:=Regs.B OR GetByteIndx;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $FA: begin  { ORB Ext. }
	   Regs.B:=Regs.B OR GetByteExt;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
  end;

  if OpC<>$1A then Regs.VFlag:=False;
end;  { OpOR }


procedure OpPSH(const OpC: TOpcode);
var RegCode: Byte;
    UserStack: Boolean;
begin
  RegCode:=GetByteImm;
  UserStack:=(OpC = $36);

  if (RegCode and 128)=128 then
  begin
    if UserStack then PushUserStackW(Regs.PC)
		 else PushSysStackW(Regs.PC);
    IncTakte(2);
  end;
  if (RegCode and 64)=64 then
  begin
    if UserStack then PushUserStackW(Regs.S)  { ! }
		 else PushSysStackW(Regs.U);  { ! }
    IncTakte(2);
  end;
  if (RegCode and 32)=32 then
  begin
    if UserStack then PushUserStackW(Regs.Y)
		 else PushSysStackW(Regs.Y);
    IncTakte(2);
  end;
  if (RegCode and 16)=16 then
  begin
    if UserStack then PushUserStackW(Regs.X)
		 else PushSysStackW(Regs.X);
    IncTakte(2);
  end;
  if (RegCode and 8)=8 then
  begin
    if UserStack then PushUserStackB(Regs.DP)
		 else PushSysStackB(Regs.DP);
    IncTakte(1);
  end;
  if (RegCode and 4)=4 then
  begin
    if UserStack then PushUserStackB(Regs.B)
		 else PushSysStackB(Regs.B);
    IncTakte(1);
  end;
  if (RegCode and 2)=2 then
  begin
    if UserStack then PushUserStackB(Regs.A)
		 else PushSysStackB(Regs.A);
    IncTakte(1);
  end;
  if (RegCode and 1)=1 then
  begin
    if UserStack then PushUserStackB(GetRegsCC)
		 else PushSysStackB(GetRegsCC);
    IncTakte(1);
  end;

  IncTakte(5);
end;  { OpPSH }


procedure OpPUL(const OpC: TOpcode);
var RegCode: Byte;
    UserStack: Boolean;
begin
  RegCode:=GetByteImm;
  UserStack:=(OpC = $37);

  if (RegCode and 1)=1 then
  begin
    if UserStack then SetRegsCC(PullUserStackB)
		 else SetRegsCC(PullSysStackB);
    IncTakte(1);
  end;
  if (RegCode and 2)=2 then
  begin
    if UserStack then Regs.A:=PullUserStackB
		 else Regs.A:=PullSysStackB;
    IncTakte(1);
  end;
  if (RegCode and 4)=4 then
  begin
    if UserStack then Regs.B:=PullUserStackB
		 else Regs.B:=PullSysStackB;
    IncTakte(1);
  end;
  if (RegCode and 8)=8 then
  begin
    if UserStack then Regs.DP:=PullUserStackB
		 else Regs.DP:=PullSysStackB;
    IncTakte(1);
  end;
  if (RegCode and 16)=16 then
  begin
    if UserStack then Regs.X:=PullUserStackW
		 else Regs.X:=PullSysStackW;
    IncTakte(2);
  end;
  if (RegCode and 32)=32 then
  begin
    if UserStack then Regs.Y:=PullUserStackW
		 else Regs.Y:=PullSysStackW;
    IncTakte(2);
  end;
  if (RegCode and 64)=64 then
  begin
    if UserStack then Regs.S:=PullUserStackW   { ! }
		 else Regs.U:=PullSysStackW;   { ! }
    IncTakte(2);
  end;
  if (RegCode and 128)=128 then
  begin
    if UserStack then Regs.PC:=PullUserStackW
		 else Regs.PC:=PullSysStackW;
    IncTakte(2);
  end;

  IncTakte(5);
end;  { OpPUL }


procedure OpROL(const OpC: TOpcode);
var b: Byte;
    a: Word;
    Carry, Sign2: Boolean;
begin
  case OpC of
    $09: begin  { ROL Direct }
	   a:=GetAddrDirect;
	   b:=GetMem6809(a);
	   Carry:=(b and 128)=128;
	   b:=(b SHL 1) + Ord(Regs.CFlag);
	   Sign2:=(b and 128)=128;
	   Regs.CFlag:=Carry;
	   SetFlagsB(b, N_FLAG + Z_FLAG);
	   SetMem6809(a, b);
	   IncTakte(6);
	 end;
    $49: begin  { ROLA }
	   Carry:=(Regs.A and 128)=128;
	   Regs.A:=(Regs.A SHL 1) + Ord(Regs.CFlag);
	   Sign2:=(Regs.A and 128)=128;
	   Regs.CFlag:=Carry;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $59: begin  { ROLB }
	   Carry:=(Regs.B and 128)=128;
	   Regs.B:=(Regs.B SHL 1) + Ord(Regs.CFlag);
	   Sign2:=(Regs.B and 128)=128;
	   Regs.CFlag:=Carry;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $69: begin  { ROL Indx. }
	   a:=GetAddrIndx;
	   b:=GetMem6809(a);
	   Carry:=(b and 128)=128;
	   b:=(b SHL 1) + Ord(Regs.CFlag);
	   Sign2:=(b and 128)=128;
	   Regs.CFlag:=Carry;
	   SetFlagsB(b, N_FLAG + Z_FLAG);
	   SetMem6809(a, b);
	   IncTakte(6);
	 end;
    $79: begin  { ROL Ext. }
	   a:=GetAddrExt;
	   b:=GetMem6809(a);
	   Carry:=(b and 128)=128;
	   b:=(b SHL 1) + Ord(Regs.CFlag);
	   Sign2:=(b and 128)=128;
	   Regs.CFlag:=Carry;
	   SetFlagsB(b, N_FLAG + Z_FLAG);
	   SetMem6809(a, b);
	   IncTakte(7);
	 end;
  end;

  Regs.VFlag:=(Carry <> Sign2);
end;  { OpROL }


procedure OpROR(const OpC: TOpcode);
var b: Byte;
    a: Word;
    Carry: Boolean;
begin
  case OpC of
    $06: begin  { ROR Direct }
	   a:=GetAddrDirect;
	   b:=GetMem6809(a);
	   Carry:=(b and 1)=1;
	   b:=(b SHR 1) + 128*Ord(Regs.CFlag);
	   Regs.CFlag:=Carry;
	   SetFlagsB(b, N_FLAG + Z_FLAG);
	   SetMem6809(a, b);
	   IncTakte(6);
	 end;
    $46: begin  { RORA }
	   Carry:=(Regs.A and 1)=1;
	   Regs.A:=(Regs.A SHR 1) + 128*Ord(Regs.CFlag);
	   Regs.CFlag:=Carry;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $56: begin  { RORB }
	   Carry:=(Regs.B and 1)=1;
	   Regs.B:=(Regs.B SHR 1) + 128*Ord(Regs.CFlag);
	   Regs.CFlag:=Carry;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $66: begin  { ROR Indx. }
	   a:=GetAddrIndx;
	   b:=GetMem6809(a);
	   Carry:=(b and 1)=1;
	   b:=(b SHR 1) + 128*Ord(Regs.CFlag);
	   Regs.CFlag:=Carry;
	   SetFlagsB(b, N_FLAG + Z_FLAG);
	   SetMem6809(a, b);
	   IncTakte(6);
	 end;
    $76: begin  { ROR Ext. }
	   a:=GetAddrExt;
	   b:=GetMem6809(a);
	   Carry:=(b and 1)=1;
	   b:=(b SHR 1) + 128*Ord(Regs.CFlag);
	   Regs.CFlag:=Carry;
	   SetFlagsB(b, N_FLAG + Z_FLAG);
	   SetMem6809(a, b);
	   IncTakte(7);
	 end;
  end;
end;  { OpROR }


procedure OpRTI(const OpC: TOpcode);
var Entire: Boolean;
begin
  with Regs do
  begin
    Entire:=EFlag;
    SetRegsCC(PullSysStackB);
    if Entire then
    begin
      A:=PullSysStackB;      B:=PullSysStackB;
      DP:=PullSysStackB;     X:=PullSysStackW;
      Y:=PullSysStackW;      U:=PullSysStackW;
      IncTakte(9);
    end;
    PC:=PullSysStackW;
  end;

  IncTakte(6);
end;  { OpRTI }


procedure OpRTS(const OpC: TOpcode);
begin
  Regs.PC:=PullSysStackW;
  IncTakte(5);
end;  { OpRTS }


procedure OpSBC(const OpC: TOpcode);
var b, Carry: Byte;

  procedure SetVFlagB(const Reg, Mem: Byte);
  begin
    Regs.VFlag:=((ShortInt(Reg)<0) and (ShortInt(Mem)<0) and (ShortInt(Reg-Mem-Carry)>0)) or
		((ShortInt(Reg)>0) and (ShortInt(Mem)>0) and (ShortInt(Reg-Mem-Carry)<0));
  end;

begin
  Carry:=Ord(Regs.CFlag);

  case OpC of
    $82: begin  { SBCA Imm. }
	   b:=GetByteImm;
	   SetVFlagB(Regs.A, b);
	   Regs.CFlag:=(Word(Regs.A) < Word(b) + Carry);
	   Regs.A:=Regs.A - b - Carry;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $92: begin  { SBCA Direct }
	   b:=GetByteDirect;
	   SetVFlagB(Regs.A, b);
	   Regs.CFlag:=(Word(Regs.A) < Word(b) + Carry);
	   Regs.A:=Regs.A - b - Carry;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $A2: begin  { SBCA Indx. }
	   b:=GetByteIndx;
	   SetVFlagB(Regs.A, b);
	   Regs.CFlag:=(Word(Regs.A) < Word(b) + Carry);
	   Regs.A:=Regs.A - b - Carry;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $B2: begin  { SBCA Ext. }
	   b:=GetByteExt;
	   SetVFlagB(Regs.A, b);
	   Regs.CFlag:=(Word(Regs.A) < Word(b) + Carry);
	   Regs.A:=Regs.A - b - Carry;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
    $C2: begin  { SBCB Imm. }
	   b:=GetByteImm;
	   SetVFlagB(Regs.B, b);
	   Regs.CFlag:=(Word(Regs.B) < Word(b) + Carry);
	   Regs.B:=Regs.B - b - Carry;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $D2: begin  { SBCB Direct }
	   b:=GetByteDirect;
	   SetVFlagB(Regs.B, b);
	   Regs.CFlag:=(Word(Regs.B) < Word(b) + Carry);
	   Regs.B:=Regs.B - b - Carry;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $E2: begin  { SBCB Indx. }
	   b:=GetByteIndx;
	   SetVFlagB(Regs.B, b);
	   Regs.CFlag:=(Word(Regs.B) < Word(b) + Carry);
	   Regs.B:=Regs.B - b - Carry;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $F2: begin  { SBCB Ext. }
	   b:=GetByteExt;
	   SetVFlagB(Regs.B, b);
	   Regs.CFlag:=(Word(Regs.B) < Word(b) + Carry);
	   Regs.B:=Regs.B - b - Carry;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
  end;
end;  { OpSBC }


procedure OpSEX(const OpC: TOpcode);
begin
  Regs.A:=255*Ord((Regs.B and 128)=128);
  SetFlagsB(Regs.A, N_FLAG);
  SetFlagsB(Regs.B, Z_FLAG);
  Regs.VFlag:=False;
  IncTakte(2);
end;  { OpSEX }


procedure OpXSL(const OpC: TOpcode);
var b, Sign1, Sign2: Byte;
    a: Word;
begin
  case OpC of
    $08: begin  { ASL/LSL Direct }
	   a:=GetAddrDirect;
	   b:=GetMem6809(a);
	   Sign1:=b and 128;
	   Regs.CFlag:=((b AND 128)=128);
	   b:=(b AND 127) SHL 1;
	   SetFlagsB(b, N_FLAG + Z_FLAG);
	   SetMem6809(a, b);
	   Sign2:=b and 128;
	   IncTakte(6);
	 end;
    $48: begin  { ASLA/LSLA }
	   Regs.CFlag:=((Regs.A AND 128)=128);
	   Sign1:=Regs.A and 128;
	   Regs.A:=(Regs.A AND 127) SHL 1;
	   Sign2:=Regs.A and 128;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $58: begin  { ASLB/LSLB }
	   Regs.CFlag:=((Regs.B AND 128)=128);
	   Sign1:=Regs.B and 128;
	   Regs.B:=(Regs.B AND 127) SHL 1;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   Sign2:=Regs.B and 128;
	   IncTakte(2);
	 end;
    $68: begin  { ASL/LSL Indx. }
	   a:=GetAddrIndx;
	   b:=GetMem6809(a);
	   Sign1:=b and 128;
	   Regs.CFlag:=((b AND 128)=128);
	   b:=(b AND 127) SHL 1;
	   SetFlagsB(b, N_FLAG + Z_FLAG);
	   SetMem6809(a, b);
	   Sign2:=b and 128;
	   IncTakte(6);
	 end;
    $78: begin  { ASL/LSL Ext. }
	   a:=GetAddrExt;
	   b:=GetMem6809(a);
	   Sign1:=b and 128;
	   Regs.CFlag:=((b AND 128)=128);
	   b:=(b AND 127) SHL 1;
	   SetFlagsB(b, N_FLAG + Z_FLAG);
	   SetMem6809(a, b);
	   Sign2:=b and 128;
	   IncTakte(7);
	 end;
  end;

  Regs.VFlag:=(Sign1 <> Sign2);
end;  { OpXSL }


procedure OpSUB(const OpC: TOpcode);
var Data: Byte;
    Data16: Word;

  procedure SetVFlagB(const Reg, Mem: Byte);
  begin
    Regs.VFlag:=((ShortInt(Reg)<0) and (ShortInt(Mem)<0) and (ShortInt(Reg-Mem)>0)) or
		((ShortInt(Reg)>0) and (ShortInt(Mem)>0) and (ShortInt(Reg-Mem)<0));
  end;

  procedure SetVFlagW(const Reg, Mem: Word);
  begin
    Regs.VFlag:=((Integer(Reg)<0) and (Integer(Mem)<0) and (Integer(Reg-Mem)>0)) or
		((Integer(Reg)>0) and (Integer(Mem)>0) and (Integer(Reg-Mem)<0));
  end;

begin
  case OpC of
    $80: begin  { SUBA Imm. }
	   Data:=GetByteImm;
	   Regs.CFlag:=(Regs.A < Data);
	   SetVFlagB(Regs.A, Data);
	   Regs.A:=Regs.A - Data;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $90: begin  { SUBA Direct }
	   Data:=GetByteDirect;
	   Regs.CFlag:=(Regs.A < Data);
	   SetVFlagB(Regs.A, Data);
	   Regs.A:=Regs.A - Data;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $A0: begin  { SUBA Indx. }
	   Data:=GetByteIndx;
	   Regs.CFlag:=(Regs.A < Data);
	   SetVFlagB(Regs.A, Data);
	   Regs.A:=Regs.A - Data;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $B0: begin  { SUBA Ext. }
	   Data:=GetByteExt;
	   Regs.CFlag:=(Regs.A < Data);
	   SetVFlagB(Regs.A, Data);
	   Regs.A:=Regs.A - Data;
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
    $C0: begin  { SUBB Imm. }
	   Data:=GetByteImm;
	   Regs.CFlag:=(Regs.B < Data);
	   SetVFlagB(Regs.B, Data);
	   Regs.B:=Regs.B - Data;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(2);
	 end;
    $D0: begin  { SUBB Direct }
	   Data:=GetByteDirect;
	   Regs.CFlag:=(Regs.B < Data);
	   SetVFlagB(Regs.B, Data);
	   Regs.B:=Regs.B - Data;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $E0: begin  { SUBB Indx. }
	   Data:=GetByteIndx;
	   Regs.CFlag:=(Regs.B < Data);
	   SetVFlagB(Regs.B, Data);
	   Regs.B:=Regs.B - Data;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $F0: begin  { SUBB Ext. }
	   Data:=GetByteExt;
	   Regs.CFlag:=(Regs.B < Data);
	   SetVFlagB(Regs.B, Data);
	   Regs.B:=Regs.B - Data;
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
    $83: begin  { SUBD Imm. }
	   Data16:=GetWordImm;
	   Regs.CFlag:=(Regs.D < Data16);
	   SetVFlagW(Regs.D, Data16);
	   Regs.D:=Regs.D - Data16;
	   SetFlagsW(Regs.D, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $93: begin  { SUBD Direct }
	   Data16:=GetWordDirect;
	   Regs.CFlag:=(Regs.D < Data16);
	   SetVFlagW(Regs.D, Data16);
	   Regs.D:=Regs.D - Data16;
	   SetFlagsW(Regs.D, N_FLAG + Z_FLAG);
	   IncTakte(6);
	 end;
    $A3: begin  { SUBD Indx. }
	   Data16:=GetWordIndx;
	   Regs.CFlag:=(Regs.D < Data16);
	   SetVFlagW(Regs.D, Data16);
	   Regs.D:=Regs.D - Data16;
	   SetFlagsW(Regs.D, N_FLAG + Z_FLAG);
	   IncTakte(6);
	 end;
    $B3: begin  { SUBD Ext. }
	   Data16:=GetWordExt;
	   Regs.CFlag:=(Regs.D < Data16);
	   SetVFlagW(Regs.D, Data16);
	   Regs.D:=Regs.D - Data16;
	   SetFlagsW(Regs.D, N_FLAG + Z_FLAG);
	   IncTakte(7);
	 end;
  end;
end;  { OpSUB }


procedure OpST(const OpC: TOpcode);
begin
  case OpC of
    $97: begin  { STA Direct }
	   SetMem6809(GetAddrDirect, Regs.A);
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $A7: begin  { STA Indx. }
	   SetMem6809(GetAddrIndx, Regs.A);
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $B7: begin  { STA Ext. }
	   SetMem6809(GetAddrExt, Regs.A);
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
    $D7: begin  { STB Direct }
	   SetMem6809(GetAddrDirect, Regs.B);
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $E7: begin  { STB Indx. }
	   SetMem6809(GetAddrIndx, Regs.B);
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(4);
	 end;
    $F7: begin  { STB Ext. }
	   SetMem6809(GetAddrExt, Regs.B);
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
    $9F: begin  { STX Direct }
	   SetMem6809W(GetAddrDirect, Regs.X);
	   SetFlagsW(Regs.X, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
    $AF: begin  { STX Indx. }
	   SetMem6809W(GetAddrIndx, Regs.X);
	   SetFlagsW(Regs.X, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
    $BF: begin  { STX Ext. }
	   SetMem6809W(GetAddrExt, Regs.X);
	   SetFlagsW(Regs.X, N_FLAG + Z_FLAG);
	   IncTakte(6);
	 end;
    $DF: begin  { STU Direct }
	   SetMem6809W(GetAddrDirect, Regs.U);
	   SetFlagsW(Regs.U, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
    $EF: begin  { STU Indx. }
	   SetMem6809W(GetAddrIndx, Regs.U);
	   SetFlagsW(Regs.U, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
    $FF: begin  { STU Ext. }
	   SetMem6809W(GetAddrExt, Regs.U);
	   SetFlagsW(Regs.U, N_FLAG + Z_FLAG);
	   IncTakte(6);
	 end;
    $DD: begin  { STD Direct }
	   SetMem6809W(GetAddrDirect, Regs.D);
	   SetFlagsW(Regs.D, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
    $ED: begin  { STD Indx. }
	   SetMem6809W(GetAddrIndx, Regs.D);
	   SetFlagsW(Regs.D, N_FLAG + Z_FLAG);
	   IncTakte(5);
	 end;
    $FD: begin  { STD Ext. }
	   SetMem6809W(GetAddrExt, Regs.D);
	   SetFlagsW(Regs.D, N_FLAG + Z_FLAG);
	   IncTakte(6);
	 end;
  end;

  Regs.VFlag:=False;
end;  { OpST }


procedure OpSYNC(const OpC: TOpcode);
begin
  { Synchronize to Interrupt -
    don't know what to do :-(( }
  //TextColor(SIM6809_COLOR);
  WriteLn('SYNC: Oops.');
  //TextColor(STANDARD_COLOR);
  IncTakte(4);   { at least }
end;  { OpSYNC }


procedure OpSWI(const OpC: TOpcode);
begin
  with Regs do
  begin
    PushSysStackW(PC);    PushSysStackW(U);
    PushSysStackW(Y);     PushSysStackW(X);
    PushSysStackB(DP);    PushSysStackB(B);
    PushSysStackB(A);     PushSysStackB(GetRegsCC);

    EFlag:=True;   IFlag:=True;   FFlag:=True;
    PC:=GetMem6809W(SWI_VEC);  { SWI interrupt vector }
  end;

  IncTakte(19);
end;  { OpSWI }


procedure OpTFR(const OpC: TOpcode);
var Postbyte: Byte;
    s: Word;
begin
  Postbyte:=GetByteImm;

  case ((Postbyte AND $F0) SHR 4) of
    0: s:=Regs.D;
    1: s:=Regs.X;
    2: s:=Regs.Y;
    3: s:=Regs.U;
    4: s:=Regs.S;
    5: s:=Regs.PC;
    8: s:=Regs.A;
    9: s:=Regs.B;
    10: s:=GetRegsCC;
    11: s:=Regs.DP;
  end;

  case (Postbyte AND $F) of
    0: Regs.D:=s;
    1: Regs.X:=s;
    2: Regs.Y:=s;
    3: Regs.U:=s;
    4: Regs.S:=s;
    5: Regs.PC:=s;
    8: Regs.A:=s;
    9: Regs.B:=s;
    10: SetRegsCC(s);
    11: Regs.DP:=s;
  end;

  IncTakte(6);
end;  { OpTFR }


procedure OpTST(const OpC: TOpcode);
begin
  case OpC of
    $0D: begin
	   SetFlagsB(GetByteDirect, N_FLAG + Z_FLAG);  { TST Direct }
	   IncTakte(6);
	 end;
    $4D: begin
	   SetFlagsB(Regs.A, N_FLAG + Z_FLAG);         { TSTA }
	   IncTakte(2);
	 end;
    $5D: begin
	   SetFlagsB(Regs.B, N_FLAG + Z_FLAG);         { TSTB }
	   IncTakte(2);
	 end;
    $6D: begin
	   SetFlagsB(GetByteIndx, N_FLAG + Z_FLAG);    { TST Indx. }
	   IncTakte(6);
	 end;
    $7D: begin
	   SetFlagsB(GetByteExt, N_FLAG + Z_FLAG);     { TST Ext. }
	   IncTakte(7);
	 end;
  end;

  Regs.VFlag:=False;
end;  { OpTST }


procedure OpPrefix10(const OpC: TOpcode);
var OpCErw: TOpcode;
    Offset: LongInt;
begin
  OpCErw:=GetByteImm;

  case OpCErw of
    $CE: begin  { LDS Imm. }
	   Regs.S:=GetWordImm;
	   SetFlagsW(Regs.S, N_FLAG + Z_FLAG);
	   Regs.VFlag:=False;
	   IncTakte(4);
	 end;
    $DE: begin  { LDS Direct }
	   Regs.S:=GetWordDirect;
	   SetFlagsW(Regs.S, N_FLAG + Z_FLAG);
	   Regs.VFlag:=False;
	   IncTakte(6);
	 end;
    $EE: begin  { LDS Indx. }
	   Regs.S:=GetWordIndx;
	   SetFlagsW(Regs.S, N_FLAG + Z_FLAG);
	   Regs.VFlag:=False;
	   IncTakte(6);
	 end;
    $FE: begin  { LDS Ext. }
	   Regs.S:=GetWordExt;
	   SetFlagsW(Regs.S, N_FLAG + Z_FLAG);
	   Regs.VFlag:=False;
	   IncTakte(7);
	 end;
    $DF: begin  { STS Direct }
	   SetMem6809W(GetAddrDirect, Regs.S);
	   SetFlagsW(Regs.S, N_FLAG + Z_FLAG);
	   Regs.VFlag:=False;
	   IncTakte(6);
	 end;
    $EF: begin  { STS Indx. }
	   SetMem6809W(GetAddrIndx, Regs.S);
	   SetFlagsW(Regs.S, N_FLAG + Z_FLAG);
	   Regs.VFlag:=False;
	   IncTakte(6);
	 end;
    $FF: begin  { STS Ext. }
	   SetMem6809W(GetAddrExt, Regs.S);
	   SetFlagsW(Regs.S, N_FLAG + Z_FLAG);
	   Regs.VFlag:=False;
	   IncTakte(7);
	 end;
    $8E: begin  { LDY Imm. }
	   Regs.Y:=GetWordImm;
	   SetFlagsW(Regs.Y, N_FLAG + Z_FLAG);
	   Regs.VFlag:=False;
	   IncTakte(4);
	 end;
    $9E: begin  { LDY Direct }
	   Regs.Y:=GetWordDirect;
	   SetFlagsW(Regs.Y, N_FLAG + Z_FLAG);
	   Regs.VFlag:=False;
	   IncTakte(6);
	 end;
    $AE: begin  { LDY Indx. }
	   Regs.Y:=GetWordIndx;
	   SetFlagsW(Regs.Y, N_FLAG + Z_FLAG);
	   Regs.VFlag:=False;
	   IncTakte(6);
	 end;
    $BE: begin  { LDY Ext. }
	   Regs.Y:=GetWordExt;
	   SetFlagsW(Regs.Y, N_FLAG + Z_FLAG);
	   Regs.VFlag:=False;
	   IncTakte(7);
	 end;
    $9F: begin  { STY Direct }
	   SetMem6809W(GetAddrDirect, Regs.Y);
	   SetFlagsW(Regs.Y, N_FLAG + Z_FLAG);
	   Regs.VFlag:=False;
	   IncTakte(6);
	 end;
    $AF: begin  { STY Indx. }
	   SetMem6809W(GetAddrIndx, Regs.Y);
	   SetFlagsW(Regs.Y, N_FLAG + Z_FLAG);
	   Regs.VFlag:=False;
	   IncTakte(6);
	 end;
    $BF: begin  { STY Ext. }
	   SetMem6809W(GetAddrExt, Regs.Y);
	   SetFlagsW(Regs.Y, N_FLAG + Z_FLAG);
	   Regs.VFlag:=False;
	   IncTakte(7);
	 end;
    $83: begin
	   CompareW(Regs.D, GetWordImm);     { CMPD Imm. }
	   IncTakte(5);
	 end;
    $93: begin
	   CompareW(Regs.D, GetWordDirect);  { CMPD Direct }
	   IncTakte(7);
	 end;
    $A3: begin
	   CompareW(Regs.D, GetWordIndx);    { CMPD Indx. }
	   IncTakte(7);
	 end;
    $B3: begin
	   CompareW(Regs.D, GetWordExt);     { CMPD Ext. }
	   IncTakte(8);
	 end;
    $8C: begin
	   CompareW(Regs.Y, GetWordImm);     { CMPY Imm. }
	   IncTakte(5);
	 end;
    $9C: begin
	   CompareW(Regs.Y, GetWordDirect);  { CMPY Direct }
	   IncTakte(7);
	 end;
    $AC: begin
	   CompareW(Regs.Y, GetWordIndx);    { CMPY Indx. }
	   IncTakte(7);
	 end;
    $BC: begin
	   CompareW(Regs.Y, GetWordExt);     { CMPY Ext. }
	   IncTakte(8);
	 end;
    $3F: begin  { SWI2 }
	   with Regs do
	   begin
	     PushSysStackW(PC);     PushSysStackW(U);
	     PushSysStackW(Y);      PushSysStackW(X);
	     PushSysStackB(DP);     PushSysStackB(B);
	     PushSysStackB(A);      PushSysStackB(GetRegsCC);
	     EFlag:=True;
	     PC:=GetMem6809W(SWI2_VEC);  { SWI2 interrupt vector }
	     IncTakte(20);
	   end;
	 end;
    $24..$2B: begin  { Long SimpleBRA }
		Offset:=Integer(GetWordImm);
		IncTakte(5);
		if ((OpCErw=$24) and (not Regs.CFlag)) or  { LBCC / LBHS }
		   ((OpCErw=$25) and (Regs.CFlag)) or      { LBCS / LBLO }
		   ((OpCErw=$26) and (not Regs.ZFlag)) or  { LBNE }
		   ((OpCErw=$27) and (Regs.ZFlag)) or      { LBEQ }
		   ((OpCErw=$28) and (not Regs.VFlag)) or  { LBVC }
		   ((OpCErw=$29) and (Regs.VFlag)) or      { LBVS }
		   ((OpCErw=$2A) and (not Regs.NFlag)) or  { LBPL }
		   ((OpCErw=$2B) and (Regs.NFlag)) then
		   begin
		     Inc(Regs.PC, Offset);
		     IncTakte(1);
		   end;
	      end;
    $2C: begin  { LBGE -  N xor V = 0 }
	   Offset:=Integer(GetWordImm);
	   IncTakte(5);
	   if NOT (Regs.NFlag XOR Regs.VFlag) then
	   begin
	     Inc(Regs.PC, Offset);
	     IncTakte(1);
	   end;
	 end;
    $2E: begin  { LBGT -  Z or (N xor V) = 0 }
	   Offset:=Integer(GetWordImm);
	   IncTakte(5);
	   if NOT (Regs.ZFlag OR (Regs.NFlag XOR Regs.VFlag)) then
	   begin
	     Inc(Regs.PC, Offset);
	     IncTakte(1);
	   end;
	 end;
    $2F: begin  { LBLE -  Z or (N xor V) = 1 }
	   IncTakte(5);
	   Offset:=Integer(GetWordImm);
	   if Regs.ZFlag OR (Regs.NFlag XOR Regs.VFlag) then
	   begin
	     Inc(Regs.PC, Offset);
	     IncTakte(1);
	   end;
	 end;
    $22: begin  { LBHI -  Z or C = 0 }
	   Offset:=Integer(GetWordImm);
	   IncTakte(5);
	   if NOT (Regs.ZFlag OR Regs.CFlag) then
	   begin
	     Inc(Regs.PC, Offset);
	     IncTakte(1);
	   end;
	 end;
    $23: begin  { LBLS -  Z or C = 1 }
	   Offset:=Integer(GetWordImm);
	   IncTakte(5);
	   if Regs.ZFlag OR Regs.CFlag then
	   begin
	     Inc(Regs.PC, Offset);
	     IncTakte(1);
	   end;
	 end;
    $2D: begin  { LBLT -  N xor V = 1 }
	   Offset:=Integer(GetWordImm);
	   IncTakte(5);
	   if Regs.NFlag XOR Regs.VFlag then
	   begin
	     Inc(Regs.PC, Offset);
	     IncTakte(1);
	   end;
	 end;
    $21: begin  { LBRN }
	   Offset:=Integer(GetWordImm);
	   { long branch never }
	   IncTakte(5);
	 end;
  end;
end;  { OpPrefix10 }


procedure OpPrefix11(const OpC: TOpcode);
var OpCErw: TOpcode;
begin
  OpCErw:=GetByteImm;

  case OpCErw of
    $83: begin
	   CompareW(Regs.U, GetWordImm);     { CMPU Imm. }
	   IncTakte(5);
	 end;
    $93: begin
	   CompareW(Regs.U, GetWordDirect);  { CMPU Direct }
	   IncTakte(7);
	 end;
    $A3: begin
	   CompareW(Regs.U, GetWordIndx);    { CMPU Indx. }
	   IncTakte(7);
	 end;
    $B3: begin
	   CompareW(Regs.U, GetWordExt);     { CMPU Ext. }
	   IncTakte(8);
	 end;
    $8C: begin
	   CompareW(Regs.S, GetWordImm);     { CMPS Imm. }
	   IncTakte(5);
	 end;
    $9C: begin
	   CompareW(Regs.S, GetWordDirect);  { CMPS Direct }
	   IncTakte(7);
	 end;
    $AC: begin
	   CompareW(Regs.S, GetWordIndx);    { CMPS Indx. }
	   IncTakte(7);
	 end;
    $BC: begin
	   CompareW(Regs.S, GetWordExt);     { CMPS Ext. }
	   IncTakte(8);
	 end;
    $3F: begin  { SWI3 }
	   with Regs do
	   begin
	     PushSysStackW(PC);     PushSysStackW(U);
	     PushSysStackW(Y);      PushSysStackW(X);
	     PushSysStackB(DP);     PushSysStackB(B);
	     PushSysStackB(A);      PushSysStackB(GetRegsCC);
	     EFlag:=True;
	     PC:=GetMem6809W(SWI3_VEC);  { SWI3 interrupt vector }
	     IncTakte(20);
	   end;
	 end;
  end;
end;  { OpPrefix11 }

  { --------------------------------------------------------------------- }

procedure PrintHelpMessage;
begin
  WriteLn('');
  WriteLn('<F1> help (this text)        <F5> download file');
  WriteLn('<F3> exit program            <F7> protocol file');
  WriteLn('');
end;  { PrintHelpMessage }


procedure InitSim;
var i, j: Integer;
    ParamString: String;
    SimError: TOnSimError;
begin
  InputActPtr:=0;   InputEndPtr:=0;
  Downloading:=False;

  OnRURError:=ignore;   OnIOPError:=stop;   OnWRError:=stop;
  for i:=1 to ParamCount do
  begin
    ParamString:=ParamStr(i);
    for j:=1 to Length(ParamString) do
      ParamString[j]:=UpCase(ParamString[j]);

    SimError:=none;
    if Pos('HALT', ParamString) > 0 then SimError:=stop;
    if Pos('RESET', ParamString) > 0 then SimError:=doreset;
    if Pos('IGNORE', ParamString) > 0 then SimError:=ignore;
    if Pos('REPORT', ParamString) > 0 then SimError:=report;

    if SimError <> none then
    begin
      if Pos(':', ParamString) = 0 then
      begin
        OnWRError:=SimError;
        OnIOPError:=SimError;
        OnRURError:=SimError;
      end;
      if Pos('WR:', ParamString) = 1 then OnWRError:=SimError;
      if Pos('IOP:', ParamString) = 1 then OnIOPError:=SimError;
      if Pos('RUR:', ParamString) = 1 then OnRURError:=SimError;
    end;
  end;

  if MemAvail < $18000 then
  begin
    //TextColor(SIM6809_COLOR);
    WriteLn('SIM6809: Out of memory.');
    WriteLn('');
    //TextColor(STANDARD_COLOR);
    MyHalt;
  end;
  New(Mem1);
  New(Mem2);
  New(RAMInited);

  Randomize;
  for i:=0 to $7FFF do
  begin
    Mem1^[i]:=Random(256);
    RAMInited^[i]:=0;
  end;
  RAMInited^[$86]:=1;   { "random" seed value ?? }
  RAMInited^[$87]:=1;   { "random" seed value ?? }

  for i:=$00 to $FF do
    OpcodeHandler[i]:=OpIllegalOpcode;

  OpcodeHandler[$3A]:=OpABX;

  OpcodeHandler[$89]:=OpADC;   OpcodeHandler[$99]:=OpADC;
  OpcodeHandler[$A9]:=OpADC;   OpcodeHandler[$B9]:=OpADC;
  OpcodeHandler[$C9]:=OpADC;   OpcodeHandler[$D9]:=OpADC;
  OpcodeHandler[$E9]:=OpADC;   OpcodeHandler[$F9]:=OpADC;

  OpcodeHandler[$8B]:=OpADD;   OpcodeHandler[$9B]:=OpADD;
  OpcodeHandler[$AB]:=OpADD;   OpcodeHandler[$BB]:=OpADD;
  OpcodeHandler[$CB]:=OpADD;   OpcodeHandler[$DB]:=OpADD;
  OpcodeHandler[$EB]:=OpADD;   OpcodeHandler[$FB]:=OpADD;
  OpcodeHandler[$C3]:=OpADD;   OpcodeHandler[$D3]:=OpADD;
  OpcodeHandler[$E3]:=OpADD;   OpcodeHandler[$F3]:=OpADD;

  OpcodeHandler[$84]:=OpAND;   OpcodeHandler[$94]:=OpAND;
  OpcodeHandler[$A4]:=OpAND;   OpcodeHandler[$B4]:=OpAND;
  OpcodeHandler[$C4]:=OpAND;   OpcodeHandler[$D4]:=OpAND;
  OpcodeHandler[$E4]:=OpAND;   OpcodeHandler[$F4]:=OpAND;
  OpcodeHandler[$1C]:=OpAND;

  OpcodeHandler[$47]:=OpASR;   OpcodeHandler[$57]:=OpASR;
  OpcodeHandler[$67]:=OpASR;   OpcodeHandler[$77]:=OpASR;
  OpcodeHandler[$07]:=OpASR;

  OpcodeHandler[$85]:=OpBIT;   OpcodeHandler[$95]:=OpBIT;
  OpcodeHandler[$A5]:=OpBIT;   OpcodeHandler[$B5]:=OpBIT;
  OpcodeHandler[$C5]:=OpBIT;   OpcodeHandler[$D5]:=OpBIT;
  OpcodeHandler[$E5]:=OpBIT;   OpcodeHandler[$F5]:=OpBIT;

  OpcodeHandler[$2A]:=OpSimpleBRA;   OpcodeHandler[$2B]:=OpSimpleBRA;
  OpcodeHandler[$26]:=OpSimpleBRA;   OpcodeHandler[$27]:=OpSimpleBRA;
  OpcodeHandler[$28]:=OpSimpleBRA;   OpcodeHandler[$29]:=OpSimpleBRA;
  OpcodeHandler[$24]:=OpSimpleBRA;   OpcodeHandler[$25]:=OpSimpleBRA;

  OpcodeHandler[$17]:=OpBSR;   OpcodeHandler[$8D]:=OpBSR;

  OpcodeHandler[$0F]:=OpCLR;   OpcodeHandler[$4F]:=OpCLR;
  OpcodeHandler[$5F]:=OpCLR;   OpcodeHandler[$6F]:=OpCLR;
  OpcodeHandler[$7F]:=OpCLR;

  OpcodeHandler[$81]:=OpCMP;   OpcodeHandler[$91]:=OpCMP;
  OpcodeHandler[$A1]:=OpCMP;   OpcodeHandler[$B1]:=OpCMP;
  OpcodeHandler[$C1]:=OpCMP;   OpcodeHandler[$D1]:=OpCMP;
  OpcodeHandler[$E1]:=OpCMP;   OpcodeHandler[$F1]:=OpCMP;
  OpcodeHandler[$8C]:=OpCMP;   OpcodeHandler[$9C]:=OpCMP;
  OpcodeHandler[$AC]:=OpCMP;   OpcodeHandler[$BC]:=OpCMP;

  OpcodeHandler[$03]:=OpCOM;   OpcodeHandler[$43]:=OpCOM;
  OpcodeHandler[$53]:=OpCOM;   OpcodeHandler[$63]:=OpCOM;
  OpcodeHandler[$73]:=OpCOM;

  OpcodeHandler[$2C]:=OpCondBRA;   OpcodeHandler[$2E]:=OpCondBRA;
  OpcodeHandler[$22]:=OpCondBRA;   OpcodeHandler[$2F]:=OpCondBRA;
  OpcodeHandler[$23]:=OpCondBRA;   OpcodeHandler[$2D]:=OpCondBRA;
  OpcodeHandler[$20]:=OpCondBRA;   OpcodeHandler[$21]:=OpCondBRA;

  OpcodeHandler[$3C]:=OpCWAI;
  OpcodeHandler[$19]:=OpDAA;

  OpcodeHandler[$0A]:=OpDEC;   OpcodeHandler[$4A]:=OpDEC;
  OpcodeHandler[$5A]:=OpDEC;   OpcodeHandler[$6A]:=OpDEC;
  OpcodeHandler[$7A]:=OpDEC;

  OpcodeHandler[$88]:=OpEOR;   OpcodeHandler[$98]:=OpEOR;
  OpcodeHandler[$A8]:=OpEOR;   OpcodeHandler[$B8]:=OpEOR;
  OpcodeHandler[$C8]:=OpEOR;   OpcodeHandler[$D8]:=OpEOR;
  OpcodeHandler[$E8]:=OpEOR;   OpcodeHandler[$F8]:=OpEOR;

  OpcodeHandler[$1E]:=OpEXG;

  OpcodeHandler[$0C]:=OpINC;   OpcodeHandler[$4C]:=OpINC;
  OpcodeHandler[$5C]:=OpINC;   OpcodeHandler[$6C]:=OpINC;
  OpcodeHandler[$7C]:=OpINC;

  OpcodeHandler[$0E]:=OpJMP;   OpcodeHandler[$6E]:=OpJMP;
  OpcodeHandler[$7E]:=OpJMP;

  OpcodeHandler[$9D]:=OpJSR;   OpcodeHandler[$AD]:=OpJSR;
  OpcodeHandler[$BD]:=OpJSR;

  OpcodeHandler[$16]:=OpLBRA;

  OpcodeHandler[$86]:=OpLD;   OpcodeHandler[$96]:=OpLD;
  OpcodeHandler[$A6]:=OpLD;   OpcodeHandler[$B6]:=OpLD;
  OpcodeHandler[$C6]:=OpLD;   OpcodeHandler[$D6]:=OpLD;
  OpcodeHandler[$E6]:=OpLD;   OpcodeHandler[$F6]:=OpLD;
  OpcodeHandler[$8E]:=OpLD;   OpcodeHandler[$9E]:=OpLD;
  OpcodeHandler[$AE]:=OpLD;   OpcodeHandler[$BE]:=OpLD;
  OpcodeHandler[$CE]:=OpLD;   OpcodeHandler[$DE]:=OpLD;
  OpcodeHandler[$EE]:=OpLD;   OpcodeHandler[$FE]:=OpLD;
  OpcodeHandler[$CC]:=OpLD;   OpcodeHandler[$DC]:=OpLD;
  OpcodeHandler[$EC]:=OpLD;   OpcodeHandler[$FC]:=OpLD;

  OpcodeHandler[$30]:=OpLEA;   OpcodeHandler[$31]:=OpLEA;
  OpcodeHandler[$32]:=OpLEA;   OpcodeHandler[$33]:=OpLEA;

  OpcodeHandler[$44]:=OpLSR;   OpcodeHandler[$54]:=OpLSR;
  OpcodeHandler[$64]:=OpLSR;   OpcodeHandler[$74]:=OpLSR;
  OpcodeHandler[$04]:=OpLSR;

  OpcodeHandler[$3D]:=OpMUL;

  OpcodeHandler[$00]:=OpNEG;   OpcodeHandler[$40]:=OpNEG;
  OpcodeHandler[$50]:=OpNEG;   OpcodeHandler[$60]:=OpNEG;
  OpcodeHandler[$70]:=OpNEG;

  OpcodeHandler[$12]:=OpNOP;

  OpcodeHandler[$8A]:=OpOR;   OpcodeHandler[$9A]:=OpOR;
  OpcodeHandler[$AA]:=OpOR;   OpcodeHandler[$BA]:=OpOR;
  OpcodeHandler[$CA]:=OpOR;   OpcodeHandler[$DA]:=OpOR;
  OpcodeHandler[$EA]:=OpOR;   OpcodeHandler[$FA]:=OpOR;
  OpcodeHandler[$1A]:=OpOR;

  OpcodeHandler[$34]:=OpPSH;   OpcodeHandler[$36]:=OpPSH;
  OpcodeHandler[$35]:=OpPUL;   OpcodeHandler[$37]:=OpPUL;

  OpcodeHandler[$09]:=OpROL;   OpcodeHandler[$49]:=OpROL;
  OpcodeHandler[$59]:=OpROL;   OpcodeHandler[$69]:=OpROL;
  OpcodeHandler[$79]:=OpROL;

  OpcodeHandler[$06]:=OpROR;   OpcodeHandler[$46]:=OpROR;
  OpcodeHandler[$56]:=OpROR;   OpcodeHandler[$66]:=OpROR;
  OpcodeHandler[$76]:=OpROR;

  OpcodeHandler[$3B]:=OpRTI;
  OpcodeHandler[$39]:=OpRTS;

  OpcodeHandler[$82]:=OpSBC;   OpcodeHandler[$92]:=OpSBC;
  OpcodeHandler[$A2]:=OpSBC;   OpcodeHandler[$B2]:=OpSBC;
  OpcodeHandler[$C2]:=OpSBC;   OpcodeHandler[$D2]:=OpSBC;
  OpcodeHandler[$E2]:=OpSBC;   OpcodeHandler[$F2]:=OpSBC;

  OpcodeHandler[$1D]:=OpSEX;

  OpcodeHandler[$08]:=OpXSL;   OpcodeHandler[$48]:=OpXSL;
  OpcodeHandler[$58]:=OpXSL;   OpcodeHandler[$68]:=OpXSL;
  OpcodeHandler[$78]:=OpXSL;

  OpcodeHandler[$80]:=OpSUB;   OpcodeHandler[$90]:=OpSUB;
  OpcodeHandler[$A0]:=OpSUB;   OpcodeHandler[$B0]:=OpSUB;
  OpcodeHandler[$C0]:=OpSUB;   OpcodeHandler[$D0]:=OpSUB;
  OpcodeHandler[$E0]:=OpSUB;   OpcodeHandler[$F0]:=OpSUB;
  OpcodeHandler[$83]:=OpSUB;   OpcodeHandler[$93]:=OpSUB;
  OpcodeHandler[$A3]:=OpSUB;   OpcodeHandler[$B3]:=OpSUB;

  OpcodeHandler[$97]:=OpST;
  OpcodeHandler[$A7]:=OpST;   OpcodeHandler[$B7]:=OpST;
  OpcodeHandler[$D7]:=OpST;
  OpcodeHandler[$E7]:=OpST;   OpcodeHandler[$F7]:=OpST;
  OpcodeHandler[$9F]:=OpST;
  OpcodeHandler[$AF]:=OpST;   OpcodeHandler[$BF]:=OpST;
  OpcodeHandler[$DF]:=OpST;
  OpcodeHandler[$EF]:=OpST;   OpcodeHandler[$FF]:=OpST;
  OpcodeHandler[$DD]:=OpST;
  OpcodeHandler[$ED]:=OpST;   OpcodeHandler[$FD]:=OpST;

  OpcodeHandler[$13]:=OpSYNC;
  OpcodeHandler[$3F]:=OpSWI;
  OpcodeHandler[$1F]:=OpTFR;

  OpcodeHandler[$4D]:=OpTST;   OpcodeHandler[$5D]:=OpTST;
  OpcodeHandler[$0D]:=OpTST;   OpcodeHandler[$6D]:=OpTST;
  OpcodeHandler[$7D]:=OpTST;

  OpcodeHandler[$10]:=OpPrefix10;
  OpcodeHandler[$11]:=OpPrefix11;

  //TextColor(SIM6809_COLOR);
  WriteLn('SIM6809 v' + VERSION);
  //TextColor(STANDARD_COLOR);
  PrintHelpMessage;
end;  { InitSim }


procedure CheckFileExtension(var s: String; const Extension: String);
{ written by Jîrg Siedenburg, copied with permission }
{ minor changes by Raimund Specht }
var i: Integer;
begin
  if s<>'' then
  begin
    if Length(s) > 250 then
    begin
      WriteLn('The Filename is too long');
      s:='';
    end else
    begin
      i:=Length(s);
      while i>0 do
      begin
	if s[i]='\' then
	begin
	  i:=0;
	end else if s[i]='.' then i:=-1
			     else Dec(i);
      end;
      if i=0 then s:=s + Extension;
    end;
  end;
end;  { CheckFileExtension }


procedure Protocol;
{ written by Jîrg Siedenburg, copied with permission }
{ minor changes by Raimund Specht }
var s: String;
    AdjustTime: LongInt;
begin
  WriteLn('');
  if Logging then
  begin
    {$I-} Close(LogFile); {$I+}
    Logging:=False;
    WriteLn('Protocol file closed');
  end;

  AdjustTime:=ReadTime;
  Write('Filename[.log]? ');
  ReadLn(s);
  CheckFileExtension(s, '.log');

  if s<>'' then
  begin
    Assign(LogFile, s);
    {$I-} Rewrite(LogFile); {$I+}
    if IOResult<>0 then WriteLn('Problems accessing file')
		   else Logging:=True;
  end;
  Inc(StartTime, ReadTime - AdjustTime);
end;  { Protocol }


procedure Download(datei: String);
var AdjustTime: LongInt;
    s: String;
    InFile: File;
    //len: Word;
    len: Integer;
begin
  AdjustTime:=ReadTime;
  WriteLn('');
  Write('Filename[.hex]? '+datei);
  //ReadLn(s);
  s:=datei;
  CheckFileExtension(s, '.hex');

  if s<>'' then
  begin
    Assign(InFile, s);
    FileMode:=0;  { read-only }
    {$I-}  Reset(InFile, 1);  {$I+}
    if IOResult=0 then
    begin
      WriteLn('Programm wird geladen');
      BlockRead(InFile, InputBuffer[InputEndPtr], FileSize(InFile), len);
      //BlockRead(InFile, InputBuffer[InputEndPtr],
		// INPUTBUFFERSIZE-InputEndPtr, len);
      Inc(InputEndPtr, len);
      Close(InFile);
      InputBuffer[InputEndPtr]:=Ord('E');   Inc(InputEndPtr);
      InputBuffer[InputEndPtr]:=13;   Inc(InputEndPtr);
      Downloading:=True;
    end else WriteLn('Problems accessing file');
  end;
  Inc(StartTime, ReadTime - AdjustTime);
end;  { Download }


procedure HandleKeyboard(c, d: Char; datei: String);
var //c: Char;
    Special: Boolean;
begin
  //c:=ReadKey;
  Special:=(c=#0);
  if Special then c:=d; //ReadKey;

  if Special then
  begin
    case c of
      ';': PrintHelpMessage;  { F1 }
      '=': begin  { F3 }
	     Dispose(Mem1);
	     Dispose(Mem2);
	     if Logging then CloseFile(LogFile);
	     WriteLn('');
	     WriteLn('');
             //TextColor(SIM6809_COLOR);
	     Write('SIM6809: '+IntToStr(TaktCounter)+' CPU cycles');
	     if (TaktCounter > 0) and (ReadTime - StartTime > 0) then
	     begin
	       //WriteLn(', ', (TaktCounter / 10000) / ((ReadTime - StartTime) / 100):1:0,
	       //	       '% of 6809 speed (1 MHz)');
               Write(', ');
               Write(Format('%.0f', [(TaktCounter / 10000) / ((ReadTime - StartTime) / 100)]));
               WriteLn('% of 6809 speed (1 MHz)');
	     end else WriteLn('');
	     WriteLn('');
             //TextColor(STANDARD_COLOR);
	     MyHalt;  { terminate here please }
	   end;
      '?': Download(datei);  { F5 }
      'A': Protocol;  { F7 }
      'D': Reset6809;  { F10 }
    end;
  end else
  begin
    InputBuffer[InputEndPtr]:=Ord(c);
    Inc(InputEndPtr);
  end;
end;  { HandleKeyboard }

procedure Sim6809Main;
var Opcode: TOpcode;
begin  { main }
  InitSim;

  Reset6809;
  StartTime:=ReadTime;
  while True do
  begin
    //if KeyPressed then HandleKeyboard;
    { interrupts.... }

    PCOfOpcode:=Regs.PC;
    Opcode:=GetMem6809(Regs.PC);                  { fetch... }
    Inc(Regs.PC);
    OpcodeHandler[Opcode](Opcode);                { ...and execute }
  end;
end;

end.  { Program SIM6809 }
