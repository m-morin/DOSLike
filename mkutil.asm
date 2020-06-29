IDEAL
MODEL SMALL, PASCAL
STACK 100h
LOCALS __
P386

include "mkutil.inc"


DATASEG
db_str                  db      "db $"
com_str                 db      ", $"
nl_str                  db      13,10,'$'
num                     db      "0??h$"
scratch                 db      128 dup(?)
tga_image_data          dw      0
bytes_written           db      0



CODESEG
;***** copy_tail *****
;Copy the command tail excluding the first character
;into scratch and terminate it with $.
;This assumes DS points to the PSP and ES to the
;the data segment.
PROC copy_tail
USES ax,cx,si,di
                        movzx   cx,[byte ptr 80h]
                        cmp     cx,1
                        jg      __10
                        stc
                        ret
__10:                   dec     cx
                        mov     si,82h
                        mov     di,offset scratch
                        rep     movsb
                        mov     [byte ptr es:di],'$'
                        ret
ENDP copy_tail

;***** tga_init *****
;Read TGA header and calculate offset to image data
;Parameters: dx=offset to filename
;Returns:    cf set on error
;            bx=file descriptor
;            ax=file offset of image data
PROC tga_init
USES ax,cx,dx
                        ;open file
                        mov     ax,03D00h
                        int     21h
                        jc      __ret
                        mov     bx,ax
                        ;read header into scratch
                        mov     ax,03F00h
                        mov     cx,18
                        mov     dx,offset scratch
                        int     21h
                        jc      __ret
                        ;calculate offset to image data
                        mov     ax,[word ptr scratch + TGA_COLOR_MAP_LENGTH]
                        mov     cx,[word ptr scratch + TGA_COLOR_MAP_ENT_SIZE]
                        shr     cx,3
                        mul     cx
                        movzx   cx,[byte ptr scratch + TGA_ID_FIELD_LENGTH]
                        add     ax,cx
                        add     ax,TGA_ID_FIELD
                        mov     [word ptr tga_image_data],ax
__ret:                  ret;
ENDP tga_init


;***** write_byte *****
;Write db directive for byte
;Parameters: al=byte
;            cl=line length
PROC write_byte
USES ax,dx
                        ;convert byte to ASCII
                        ;high nibble
                        mov     ah,0
                        shl     ax,4
                        add     ah,'0'
                        cmp     ah,'9'
                        jle     __10
                        add     ah,'A'-'9'-1
__10:                   mov     [byte ptr num+1],ah
                        ;low nibble
                        shr     al,4
                        add     al,'0'
                        cmp     al,'9'
                        jle     __20
                        add     al,'A'-'9'-1
__20:                   mov     [byte ptr num+2],al
                        mov     ah,009h
                        ;first byte on line?
                        cmp     [byte ptr bytes_written],0
                        jnz     __30
                        ;output line prefix
                        mov     dx,offset db_str
                        int     21h
__30:                   ;output byte
                        mov     dx,offset num
                        int     21h
                        inc     [byte ptr bytes_written]
                        ;output newline or comma
                        mov     dx,offset com_str
                        cmp     [byte ptr bytes_written],cl
                        jne     __40
                        mov     [byte ptr bytes_written],0
                        mov     dx,offset nl_str
__40:                   int     21h
                        ret
ENDP write_byte


;***** read_byte *****
;Read byte from file descriptor
;Parameters: bx=fd
;Returns: cf=error, al=byte
;Mangles: ah
PROC read_byte
USES cx,dx
                        mov     ax,03F00h
                        mov     cx,1
                        mov     dx,offset scratch
                        int     21h
                        mov     al,[byte ptr scratch]
                        ret
ENDP read_byte


;***** read_and_pack_byte *****
;Read 8 bytes from file descriptor and pack into 1 byte
;Parameters: bx=fd
;Returns: cf=error, al=byte
;Mangles: ah
PROC read_and_pack_byte
USES cx,dx,si
                        ;read 8 bytes
                        mov     ax,03F00h
                        mov     cx,8
                        mov     dx,offset scratch
                        int     21h
                        ;shift LSB of each into ah
                        xor     ah,ah
                        mov     si,offset scratch
__1:                    lodsb
                        rcr     al,1
                        rcl     ah,1
                        loop    __1
                        mov     al,ah
                        ret
ENDP read_and_pack_byte

END
