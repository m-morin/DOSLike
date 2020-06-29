T=descend

.asm.obj:
	tasm/zi/m2/l/t $*

$T.exe: main.obj map.obj screen.obj entity.obj
	tlink/v $**,$T.exe
run: $T.exe
	$T.exe
main.obj: main.asm font.inc common.inc
map.obj: map.asm common.inc
screen.obj: screen.asm common.inc
entity.obj: screen.asm common.inc

mkfont.exe: mkfont.obj
	tlink/v $*
font.inc: font.tga mkfont.exe
	mkfont.exe font.tga >font.inc

clean:
	del *.exe
	del	*.map
	del *.obj
	del *.lst
