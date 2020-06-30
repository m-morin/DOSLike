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


;***** Fills the map with solid opaque tiles ******
PROC map_clear
USES ax,bx,dx,si
                        mov     si,offset map
                        mov     ax,00020h
                        mov     bl,TFLAGS_SOLID OR TFLAGS_OPAQUE
__10:                   mov     [word ptr (Tile ptr si).char],ax
                        mov     [(Tile ptr si).flags],bl
                        add     si,size Tile
                        cmp     si,offset map + size Tile * MAP_WIDTH * MAP_HEIGHT
                        jl      __10
                        ret
ENDP map_clear


;***** Generate a random map using BSP algorithm *****
;Split the entire map into two rects
;For each of those rects, split those into two rects
;Repeat MAP_BSP_LEVELS times
;
;Total rects is 2^(MAP_BSP_LEVELS-1)-1. At 3 levels, this
;is 7 rects, or 28 bytes.
MAP_BSP_LEVELS          equ     3
PROC map_generate_bsp
LOCAL rects:byte:(((2 SHL (MAP_BSP_LEVELS-1))-1)*size Rect)
USES ax,bx,cx,dx,si,di
                        mov     si,bp
                        mov     [(Rect ptr ss:si).top],0
                        mov     [(Rect ptr ss:si).bottom],MAP_HEIGHT-1
                        mov     [(Rect ptr ss:si).left],0
                        mov     [(Rect ptr ss:si).right],MAP_WIDTH-1
                        xor     cx,cx
__10:                   
                        ret
;split a rect in si randomly into two rects
;starting at di
__split_rect:           
ENDP map_generate_bsp


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
