ml 6809.asm /Fo 6809.obj /c
ml stack.asm keyboard.asm keydata.asm 6809.obj coco3.asm disk.asm hardware.asm /Fe coco3x.exe /link /e
ml port.asm portmask.asm disk.asm /Fe port.exe /link /e
ml casin.asm /link /e
ml casout.asm /link /e
ml cas2rom.asm /link /e
ml drivechk.asm /link /e
ml vgacheck.asm /link /e
ml dskini.asm disk.asm /Fe dskini.exe /link /e
ml retrieve.asm disk.asm /Fe retrieve.exe /link /e
