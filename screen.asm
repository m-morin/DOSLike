IDEAL
MODEL SMALL, PASCAL
STACK 100h
LOCALS __
P386

include "common.inc"

CODESEG
;***** Clear the screen *****
PROC screen_clear
USES ax,cx,di,es
                        mov     ax,VGA_MEM
                        mov     es,ax
                        mov     ax,00f00h
                        mov     cx,SCREEN_WIDTH*SCREEN_HEIGHT
                        xor     di,di
                        rep     stosw
                        ret
ENDP screen_clear


;***** Sets the custom font *****
PROC screen_set_font
USES bp,cx,dx,bx,ax
                        mov     bp,offset font_start
                        mov     cx,128
                        mov     dx,0
                        mov     bh,8
                        xor     bl,bl
                        mov     ax,01110h
                        int     10h
                        ret
ENDP screen_set_font

END
