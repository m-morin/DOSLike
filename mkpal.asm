;Create a palette from a tga file
;This program assumes the tga file is a data type 2 (RGB)
;tga of size 4x4.
IDEAL
MODEL SMALL, PASCAL
STACK 100h
LOCALS __
P386

include "mkutil.inc"

DATASEG
palette_indicies        db      0,  1,  2,  3,  4,  5,  20, 7
                        db      56, 57, 58, 59, 60, 61, 62, 63

CODESEG
PROC main
                        ;copy tail into DS
                        mov     ax,@data
                        mov     es,ax
                        call    copy_tail
                        mov     ds,ax
                        mov     dx,offset scratch
                        ;open file and initialize
                        call    tga_init
                        jc      __exit
                        ;output all palette entries
                        mov     cx,16
                        mov     si,offset palette_indicies
__loop:                 push    cx
                        mov     cl,4
                        lodsb
                        call    write_byte
                        REPT    3
                        call    read_byte
                        push    ax
                        ENDM
                        REPT    3
                        pop     ax
                        call    write_byte
                        ENDM
                        pop     cx
                        loop    __loop
__close:                mov     ah,03Eh
                        int     21h
__exit:                 mov     ax,04C00h
                        int     21h
ENDP main
END main
