import sys

f = open(sys.argv[1])

keymap = {}

for line in f:
  scanCode,ascii = line.strip().split(' ',1)
  keymap[int(scanCode,16)] = ascii

f.close()

f = open("keymap.h",'w')

f.write("const char keymap[128] PROGMEM = {")

for i in range(128):

  if i != 0:
    f.write(',')

  if keymap.has_key(i):
    f.write("%s" % (keymap.get(i)))
  else:
    f.write("'?'");

f.write('};\n')

f.close()


