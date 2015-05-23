README.TXT
                               ************************
                               * The Gloom 3D project *
                               ************************

I hope making a subdirectory for Gloom will not be considered abuse of this
archive.  But, it's the only way I can see that will help this little
experiment.

It is my hope in putting all the data about this program here,  that it will
continue to be expanded upon and eventually turned into a game.   As of now,
I consider Gloom to be 'Openware'.  The sources and documentation for this
program are freely available so that any programmer may expand on them to make
it a better program.  Any revisions to the code are requested to be added back
to this archive so that others can see how things are progressing and so that
other programmers can also expand on these new additions.

Here is the breakdown of what I've uploaded here;
GLOOM.BIN    The executable demo - actually 3 files combined into one (Gloom
             the program, the MAP.BIN file, and RADAR.BIN)
GLOOM.ASM    The EDTASM assembly source code for Gloom.

MAP.BAS      A simple basic editor for the map.
MAP.BIN      The binary MAP file used by the Gloom demo.

MAKETABL.BAS The program I used to generate the RADAR table.
RADAR.BIN    The binary RADAR file used by the Gloom demo.

LSAVEM.BAS   basic utility I use to save binary files that load into high
             memory.

-------------------------------------------------------------------------------

MAP.BAS is a simple basic program to edit the MAP file.  It automatically
loads MAP.BIN, re-organizes it as a 2D display on the screen, and lets you edit
and re-save it.

Use U,H,K and N to move the cursor on the screen.  The J key toggles erase/draw
modes.  Pressing Q exits the editor and saves the file back to disk.  The
SPACEBAR lets you choose colors - after pressing space, type two numbers from
0-15, separated by commas and then press ENTER.  The two numbers represent the
two alternating colors that are used to simulate the more than 16 colors of the
walls.

The map is stored from $60000 to $63FFF.  Each square on the map is stored as
two bytes.  The second byte is the color of the location, and the first byte is
a code representing the minimum distance between that point and the closest
wall (0 to 15), OR 128 ($80) if there is a wall on that square.

(Expanded versions of this map editor will have to be created in order to
accomodate larger dimension maps.  It currently only allows 128x64 sized maps
which are too small to be useful for a game)

-------------------------------------------------------------------------------

MAKETABL.BAS simply creates a bunch of precalculated numbers that Gloom uses.
The whole table is only there to speed up execution of the program.  It would
run tremendously slower if it had to calculate these numbers in real time.

The table goes into memory locations $00000 to $17FFF.  Gloom actually
generates the second half of this table, making the whole table go from $00000
to $2FFFF.  It's simply 512 sequences of 96x2 entry subtables that represent
relative coordinates from the center point (player's point of view).  Each
sub-table contains 96 entries of two 16 bit words, one for X and one for Y.
This table is used by Gloom to scan a pie slice of the map that is immediately
in front of the player.

-------------------------------------------------------------------------------

GLOOM.ASM is the source for the program itself.  It assembles into less than 1K
of code at the moment, $0E00 to $1148.  All the program does is:

A- RADAR SCAN - Continually scan a pie slice of the map directly in front of
   the player's field of view.
B- Decode the scanned map into a table of 'what to draw' for the graphics
   routine.
C- BAR GRAPH - Draw the graphics that are stored in this table onto the screen.
D- Read the keyboard, and update your speed and heading as the key commands
   dictate.
E- do it all again.

Techniques are used to eliminate as many unneccessary CPU actions as possible:

1- Open spaces on the map have a number coded into them, this number tells the
   RADAR scanner to skip over parts of it's scan.
2- The graphics to be displayed are simplified into a 256 byte table.
3- The graphics TO BE displayed are compared to what IS displayed and only the
   differences are updated on the screen.
4- The video is set to 256 bytes per line mode, which simplifies calculating
   coordinates of the graphics on-screen.

Here are some notes about future expandability of Gloom.

- The program currently draws one copy of the screen, but it's probable that it
  will be necessary to draw two copies of the screen in memory to accomodate
  adding bit-mapped enemies to the game.  Luckily, Gloom uses the 256 bytes per
  line mode, and only draws onto 128 of these bytes.  It's simple to change it
  to use two screens side by side and only display one of them at a time.
- The map size is currently programmed to be 128x64.  Making the map larger
  will require a bit of extra program logic to switch parts of the map in and
  out of active memory.
- Interaction with the environment (open/closing doors, pressing switches,
  etc...) is possible to add.  Since the map is re-read and redrawn on the
  screen continually, changing the data in the map will immediately reflect on
  the screen.  (Example; opening a door can be as easy as erasing a wall from
  the map data.)
- Incorporating variable wall, floor and ceiling heights is a bit of a problem
  without slowing down the RADAR scanner significantly, but it ought to be
  possible.  The problem with adding variable wall heights is that if a short
  wall is in front of you, the scanner has to keep scanning what's BEHIND that
  wall because it's possible that there is a taller wall behind it.  The RADAR
  scanner is already one of the biggest slow-downs in Gloom.

-------------------------------------------------------------------------------

That's all for now.  Good luck!  I hope to see something good turn out from
this demo.  Unfortunately, I do not have the free time to pursue this any
further.  It's hoped that some of the programmers in the CoCo community are
interested in making further developments in this project and eventually
turning it into a good game - be it like Doom, or Dungeons of Daggorath - it's
bound to be something fantastic.


                                         John Kowalski (Sock Master)
                                         sock@axess.com
                                         http://users.axess.com/twilight/sock/
 
