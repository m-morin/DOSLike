IDEAL
MODEL SMALL, PASCAL
STACK 100h
LOCALS __
P386

include "common.inc"

CODESEG
;***** Converts x,y to map pointer *****
;Parameters: bl=x,bh=y
;Returns:    si=pointer
PROC map_xy_to_ptr
USES ax,cx,dx
                        mov     si,offset map
                        ;si+=y*MAP_WIDTH*size Tile
                        movzx   ax,bh
                        mov     cx,MAP_WIDTH*size Tile
                        mul     cx
                        add     si,ax
                        ;si+=x*size Tile
                        movzx   ax,bl
                        mov     cx,size Tile
                        mul     cx
                        add     si,ax
                        ret
ENDP map_xy_to_ptr


;***** Draws the map *****
PROC map_draw
USES si,di,ax,cx
                        mov     ax,VGA_MEM
                        mov     es,ax
                        mov     si,offset map
                        xor     di,di
                        mov     cx,MAP_WIDTH*MAP_HEIGHT
__10:                   mov     ax,[word ptr (Entity si).char]
                        mov     [word ptr es:di],ax
                        add     si,size Tile
                        add     di,2
                        loop    __10
                        ret
ENDP map_draw
END
