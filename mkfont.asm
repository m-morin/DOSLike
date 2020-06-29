;Create a font from a tga file.
;This program assumes the tga file is a data type 1 (indexed)
;tga of size 128x224. Only the least significant bit of the
;color index of each pixel is used.
IDEAL
MODEL SMALL, PASCAL
STACK 100h
LOCALS __
P386

include "mkutil.inc"

DATASEG
FONT_WIDTH              equ     8
FONT_HEIGHT             equ     8
FONT_CHARS_PER_ROW      equ     16


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
                        ;output all characters
                        xor     al,al
__loop:                 push    ax
                        call    write_char
                        pop     ax
                        inc     al
                        cmp     al,0
                        jne     __loop
__close:                mov     ah,03Eh
                        int     21h
__exit:                 mov     ax,04C00h
                        int     21h
ENDP main


;***** write_char *****
;Write character from TGA to output
;Parameters: al=char
PROC write_char
USES ax,cx,dx
                        ;calculate offset of character
                        movzx   cx,al
                        xor     dx,dx
                        ;cx=y*1024, FONT_WIDTH * FONT_CHARS_PER_ROW * FONT_HEIGHT
                        shr     cx,4
                        shl     cx,10
                        add     dx,cx
                        ;cx+=x*FONT_WIDTH+image_data_offset
                        movzx   cx,al
                        and     cx,00Fh
                        shl     cx,3
                        add     dx,cx
                        add     dx,[word ptr tga_image_data]
                        ;seek to beginning of char in image data
                        mov     ax,04200h
                        xor     cx,cx
                        int     21h
                        ;write FONT_HEIGHT rows of pixels
                        mov     cx,FONT_HEIGHT
__10:                   call    read_and_pack_byte
                        push    cx
                        mov     cl,FONT_HEIGHT
                        call    write_byte
                        pop     cx
                        ;seek forward to next row in char
                        push    cx
                        mov     dx,FONT_WIDTH*FONT_CHARS_PER_ROW-FONT_WIDTH
                        xor     cx,cx
                        mov     ax,04201h
                        int     21h
                        pop     cx
                        loop    __10
                        ret
ENDP write_char

END main
