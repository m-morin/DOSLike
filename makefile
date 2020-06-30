T=descend

.asm.obj:
	tasm/zi/m2/l/t $*

$T.exe: main.obj map.obj screen.obj entity.obj data.obj util.obj
	tlink/v $**,$T.exe
run: $T.exe
	$T.exe
main.obj: main.asm font.inc palette.inc common.inc
map.obj: map.asm common.inc
screen.obj: screen.asm common.inc
entity.obj: screen.asm common.inc

mkutil.obj: mkutil.inc

mkfont.exe: mkfont.obj mkutil.obj
	tlink/v $**
font.inc: font.tga mkfont.exe
	mkfont.exe font.tga >font.inc

mkpal.exe: mkpal.obj mkutil.obj
	tlink/v $**
palette.inc: palette.tga mkpal.exe
	mkpal.exe palette.tga >palette.inc

clean:
	del *.exe
	del	*.map
	del *.obj
	del *.lst
