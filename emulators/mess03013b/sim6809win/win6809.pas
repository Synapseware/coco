{
  SIM6809WIN - Simulator für das Motorola-6809-System des TI-Praktikums
	       an der Universität Ulm

  Simulatorkern Version 0.24 vom 05.02.2000

  Copyright (C) 1998-2000 by Raimund Specht
	   raimund.specht@informatik.uni-ulm.de
	   http://home.primusnetz.de/rspecht/computer/studium/sim6809.htm

  Win32 GUI Versionsinformationen siehe Info.pas

  Copyright (C) 2000 by Volker Janzen
            volker.janzen@informatik.uni-ulm.de
            http://www.uni-ulm.de/~s_vjanze/index.html

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation.
  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRENTY; without even the implied warrenty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  6809 monitor program (*):
    Copyright (C) 1997 by J”rg Siedenburg
	   joerg.siedenburg@informatik.uni-ulm.de

  (*) may not be under GPL license
}

unit win6809;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, thread, Menus;

type
  TSimForm = class(TForm)
    Screen: TMemo;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Help1: TMenuItem;
    Help2: TMenuItem;
    Download1: TMenuItem;
    Protfile1: TMenuItem;
    N1: TMenuItem;
    Restart1: TMenuItem;
    AboutSim6809forWin321: TMenuItem;
    OpenDialog: TOpenDialog;
    procedure ScreenKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure Help2Click(Sender: TObject);
    procedure Download1Click(Sender: TObject);
    procedure Protfile1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Restart1Click(Sender: TObject);
    procedure AboutSim6809forWin321Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private-Deklarationen }
    machine: TSim6809;
  public
    { Public-Deklarationen }
  end;

var
  SimForm: TSimForm;

procedure Write(s: String);
procedure WriteLn(s: String);
procedure GetTime(var h, m, s, s100: Word);
procedure GotoXY(x, y: Word);
procedure ClrScr;
procedure Delay(sec: LongInt);
function MemAvail: LongInt;
procedure FWrite(b: Byte);
procedure MyHalt;

implementation

uses sim6809, Info;

{$R *.DFM}

procedure MyHalt;
begin
     SimForm.machine.Terminate;
end;

// Ins Logfile schreiben
procedure FWrite(b: Byte);
begin
end;

function MemAvail: LongInt;
begin
     // Es gibt kein MemAvail! Also sagen wir mal pauschal wir haben genug...
     Result:=1000000;
end;

procedure Delay(sec: LongInt);
begin
end;

procedure ClrScr;
begin
     SimForm.Screen.Lines.Clear;
end;

procedure GotoXY(x, y: Word);
begin
     // Not yet implemented
end;

procedure GetTime(var h, m, s, s100: Word);
begin
     DecodeTime(Time, h, m, s, s100);
end;

procedure Write(s: String);
begin
     // Kann man ein Linefeed ohne CR irgendwie für das Memo umsetzen?
     //if s[1]=#13 then s:='#'+#13;
     //if s[1]=#10 then s:='*'+#10;
     //if s[1]<#32 then ShowMessage(IntToStr(Integer(s[1])));
     //SimForm.Screen.Lines.Add(s);
     SimForm.Screen.SetSelTextBuf(PChar(s));
end;

procedure WriteLn(s: String);
begin
     SimForm.Screen.SetSelTextBuf(PChar(s+#13+#10));
end;

procedure TSimForm.ScreenKeyPress(Sender: TObject; var Key: Char);
begin
     HandleKeyboard(Key, #0, '');
     Key:=#0;
end;

procedure TSimForm.FormShow(Sender: TObject);
begin
     machine:=TSim6809.Create(False);
end;

procedure TSimForm.Help2Click(Sender: TObject);
begin
     HandleKeyboard(#0, ';', '');
end;

procedure TSimForm.Download1Click(Sender: TObject);
begin
     if OpenDialog.Execute then
     begin
          HandleKeyboard(#0, '?', OpenDialog.FileName);
     end;
end;

procedure TSimForm.Protfile1Click(Sender: TObject);
begin
     HandleKeyboard(#0, 'A', '');
end;

procedure TSimForm.Exit1Click(Sender: TObject);
begin
     HandleKeyboard(#0, '=', '');
     //Close;
end;

procedure TSimForm.Restart1Click(Sender: TObject);
begin
     HandleKeyboard(#0, 'D', '');
end;

procedure TSimForm.AboutSim6809forWin321Click(Sender: TObject);
begin
     InfoForm.ShowModal;
end;

procedure TSimForm.FormCreate(Sender: TObject);
begin
     OpenDialog.InitialDir:=ExtractFileDir(ParamStr(0));
end;

end.
