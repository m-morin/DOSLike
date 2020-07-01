IDEAL
MODEL SMALL, PASCAL
STACK 100h
LOCALS __
P386

include "common.inc"

CODESEG
;***** Initialize the screen *****
PROC screen_init
USES bp,cx,dx,bx,ax
                        ;set screen font
                        mov     bp,offset font_start
                        mov     cx,128
                        mov     dx,0
                        mov     bh,8
                        xor     bl,bl
                        mov     ax,01110h
                        int     10h
                        ;set palette
                        mov     dx,003C6h
                        mov     al,0ffh
                        out     dx,al
                        mov     cx,16
                        mov     si,offset palette_start
__5:                    lodsb
                        mov     dx,003C8h
                        out     dx,al
                        mov     dx,003C9h
                        REPT    3
                        lodsb
                        shr     al,2
                        out     dx,al
                        ENDM
                        loop    __5
                        ;disable blink
			;This breaks Windows XP DOS mode
                        ;mov     dx,VGA_INPUT_STATUS_0
                        ;in      al,dx
                        ;mov     dx,VGA_ATC_REGISTER
                        ;mov     al,VGA_ATC_MODE
                        ;out     dx,al
                        ;mov     al,0
                        ;out     dx,al
                        ;hide cursor
                        mov     ah,002h
                        mov     bh,0
                        mov     dx,0FFFFh
                        int     10h
                        ret
ENDP screen_init


;***** Clear the screen *****
PROC screen_clear
USES ax,cx,di,es
                        mov     ax,VGA_MEM
                        mov     es,ax
                        mov     ax,01300h
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
