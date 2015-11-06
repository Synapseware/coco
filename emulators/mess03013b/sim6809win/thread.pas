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

unit thread;

interface

uses
  Classes;

type
  TSim6809 = class(TThread)
  private
    { Private-Deklarationen }
  protected
    procedure Execute; override;
  end;

implementation

uses sim6809, Dialogs;

{Wichtig: Objektmethoden und -eigenschaften in der VCL können in Methoden
verwendet werden, die mit Synchronize aufgerufen werden, z.B.:

      Synchronize(UpdateCaption);

  wobei UpdateCaption so aussehen könnte:

    procedure TSim6809.UpdateCaption;
    begin
      Form1.Caption := 'Aktualisiert im Thread';
    end; }

{ TSim6809 }

procedure TSim6809.Execute;
begin
  { Plazieren Sie den Thread-Quelltext hier }
  Sim6809Main;
end;

end.
 