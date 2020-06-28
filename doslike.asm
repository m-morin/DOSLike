IDEAL
MODEL SMALL, PASCAL
STACK 100h
P386

DATASEG
font=$
include "font.inc"

VIDMEM          equ     0B800h


CODESEG
PROC main
                ;set up data segment
                mov     ax,@data
                mov     ds,ax
                mov     es,ax
                call    set_font
                ;wait for key
                ;xor     ax,ax
                ;int     16h
@@exit:         mov     ax,04C00h
                int     21h
ENDP


PROC set_font
USES bp,cx,dx,bx,ax
                mov     bp,offset font
                mov     cx,256
                mov     dx,0
                mov     bh,14
                xor     bl,bl
                mov     ax,01110h
                int     10h
                ret
ENDP

END main
