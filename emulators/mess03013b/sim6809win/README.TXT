
    SIM6809 - Simulator fÅr das Motorola-6809-System des TI-Praktikums
              an der UniversitÑt Ulm


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



-------------------
WICHTIGER HINWEIS
-------------------

Der Simulator kann NICHT fÅr die Aufgaben 1 bis 3 des Versuchs 5 (Sieben-
Segment-Anzeige, WÅrfel, Stoppuhr) verwendet werden, da Timer-Interrupts
und externe Beschaltungen vom Simulator NICHT unterstÅtzt werden !


-------------------
INSTALLATION UND START
-------------------

Die gesamte Installation von SIM6809 besteht darin, die beiden Dateien
SIM6809.EXE und ROMIMAGE.BIN in ein gemeinsames Verzeichnis zu kopieren.
Gestartet wird das Programm mit SIM6809 <Ÿ

Dem Simulator kann Åber mehrere Kommandozeilenparameter mitgeteilt werden,
wie er sich im Falle eines Fehlers (im Assembler-Programm) verhalten soll.

SIM6809 kann im Moment drei verschiedene Fehlerklassen erkennen:
    - WR:  ein Programm versucht in den Speicherbereich des ROMs zu schreiben
    - IOP: die CPU ist auf einen ungÅltigen Maschinenbefehl gesto·en
    - RUR: Lesezugriff auf eine RAM-Speicherzelle, deren Wert undefiniert ist
           (da sie zuvor noch nicht geschrieben wurde)
           
Auf jeden dieser Fehler kann SIM6809 auf vier verschiedene Arten reagieren:
    - IGNORE: Fehler komplett ignorieren (Verhalten Original-6809)
    - REPORT: Fehler samt Registerinhalten melden
    - HALT:   Fehler melden und SIM6809 beenden
    - RESET:  Fehler melden und einen 6809-Reset ausgefÅhren
    
Um das gewÅnschte Fehlerverhalten zu spezifizieren, werden in der Kommando-
zeile eine oder mehrere der Fehlerklassen gefolgt von einem ":" sowie der
gewÅnschten Reaktion angegeben. Wird nur die Reaktion angegeben, so gilt
diese Angabe fÅr alle Fehlerklassen.

Also:
  SIM6809 {[(WR|IOP|RUR):](IGNORE|REPORT|HALT|RESET)}

Beispiele:
  SIM6809 WR:HALT IOP:HALT RUR:IGNORE
Standardverhalten, wenn keine Parameter angegeben werden

  SIM6809 IGNORE
Alle Fehler ignorieren, Original-6809 so weit wie mîglich nachahmen

  SIM6809 RESET RUR:IGNORE
Bei ungÅltigen Maschinenbefehlen und Schreibzugriffen aufs ROM einen Reset
des 6809 durchfÅhren, Lesezugriffe auf nicht-initialisiertes RAM ignorieren.
Diese Einstellung entspricht dem Kommandozeilen-Parameter "reset" frÅherer
SIM6809-Versionen.

Anmerkung:
Im Modus "RUR:REPORT" kann ein Memory-Dump (D-Befehl des Monitor-Programms)
etwas anders als erwartet aussehen....


-------------------
BEDIENUNG
-------------------

Der 6809-Simulator sollte sich exakt so verhalten wie sein Vorbild, das
6809-System des TI-Praktikums samt Terminalemulation TERM.COM. Bei allen
Fragen zur Bedienung sei deshalb auf die in der Praktikumsanleitung
enthaltenen Beschreibungen verwiesen.

Einige wenige Unterschiede zum Original gibt es dennoch:
 * da kein 6809-System am seriellen Port hÑngt, kann auf die Angabe eines
   seriellen Ports (1 oder 2) beim Aufruf verzichtet werden
 * dem Reset-Taster entspricht in der Simulation die Taste F10


-------------------
EINSCHRéNKUNGEN UND TECHNISCHE HINWEISE
-------------------

Es gibt logischerweise keine Garantie fÅr die fehlerfreie Funktion des
Simulators :-)  Trotzdem deuten Fehlermeldungen des Simulators (erkennbar
an Ausgaben, die mit "SIM6809:" beginnen) meistens auf einen Fehler im
Assemblerprogramm hin.

Hinweise zur Fehlersuche:
"Cannot write to ROM ..." bedeutet, da· das Assemblerprogramm versucht,
in den ROM-Speicherbereich $8000 - $FFFF zu SCHREIBEN. Es sollten v.a.
die STORE-(STx)-Befehle ÅberprÅft werden, insbesondere solche mit
indizierter und indirekter Adressierungsart.
"Illegal opcode ..." bedeutet, da· der (simulierte) Prozessor auf einen
unbekannten/ungÅltigen Maschinenbefehl gesto·en ist; es wird also z.B.
versucht, Daten als Maschinenbefehle zu interpretieren. Ursache kann ein
fehlendes RTS am Programmende sein oder Datendeklarationen (FCB,
RMB usw.) mitten zwischen normalen Assemblerbefehlen.

Zur Zeit werden folgende Merkmale des 6809-Vorbilds (noch ?) nicht
unterstÅtzt:
 * Anschlu· externer Hardware wie Ein-/Ausgabeplatinen, Interrupts
   (au·er SWIx)
   !!! SOMIT KANN DER SIMULATOR *NICHT* FöR DIE AUFGABEN 1 - 3 !!!
   !!! VON VERSUCH 5 BENUTZT WERDEN                            !!!

Der Simulator benutzt das Original-Monitorprogramm des Praktikumssystems,
copyright (C) 1997 by Jîrg Siedenburg.
Der SchlÅssel ist die 3968-($F80)-Bytes lange Datei ROMIMAGE.BIN, die ein
exaktes Abbild des (ROM-)Speicherbereichs $F080 - $FFFF enthÑlt.
Durch Austausch dieser Datei kann der Simulator jederzeit auch mit einer
neueren Version des Monitorprogramms arbeiten.

Auf sehr schnellen Rechnern kann es beim Programmstart zu einer
"Division by zero" kommen. Schuld daran ist ein Fehler in Borlands
CRT-Unit (Delay); weitere Hinweise und Bugfixes unter
http://www.brain.uni-freiburg.de/~klaus/pascal/runerr200/


-------------------
BUG REPORTS
-------------------

Bugreports sind jederzeit willkommen und kînnen (mîglichst samt Programm,
das den Fehler verursacht bzw. vom Fehler betroffen ist) an
                     raimund.specht@informatik.uni-ulm.de
gemailt werden.


                                                          ===================
              "Every 10 seconds, someone, somewhere contracts the HIV virus."
                                                          ===================
