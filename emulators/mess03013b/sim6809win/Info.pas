{
  SIM6809WIN - Simulator für das Motorola-6809-System des TI-Praktikums
	       an der Universität Ulm

  Simulatorkern Version 0.24 vom 05.02.2000

  Copyright (C) 1998-2000 by Raimund Specht
	   raimund.specht@informatik.uni-ulm.de
	   http://home.primusnetz.de/rspecht/computer/studium/sim6809.htm

  Win32 GUI Versionsinformationen siehe unten

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

  Sim6809win (Win32 GUI for sim6809) Version history:

  Version 0.02 02/07/2000 (unstable):
  -Second quick and dirty portation of the simulator to delphi 4
  -Uses now sim6809 v0.24 instead of v0.22

  Version 0.01 02/02/2000 (unstable):
  -First quick and dirty portation of the simulator to delphi 4

  Known problem:
  -New versions of the sim6809 can be integrade in 30 minutes, but it's
   not possible to port it 1:1 yet. I'm working on a unit that takes all
   the I/O and GUI stuff out of sim6809.pas. This unit will be portable
  -There is an exception when exiting the simulator
  -It's not everthing tested and there may be many bugs left from the portation
}

unit Info;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TInfoForm = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  InfoForm: TInfoForm;

implementation

{$R *.DFM}

end.
