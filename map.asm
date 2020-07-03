IDEAL
MODEL SMALL, PASCAL
STACK 100h
LOCALS __
P386

include "common.inc"

DATASEG
map_floor               Tile  <176,004h,0>

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


;***** Draws a room *****
;Parameters:  di=ptr to Rect
;Reads rects from ds, writes map to es
PROC map_draw_room
USES ax,bx,si,cx
                        ;cache floor tile in registers
                        mov     ax,[word ptr es:map_floor.char]
                        mov     ch,[es:map_floor.flags]
                        mov     bh,[(Rect ptr ds:di).top]
__10:                   mov     bl,[(Rect ptr ds:di).left]
                        call    map_xy_to_ptr
__20:                   mov     [word ptr (Tile ptr es:si).char],ax
                        mov     [(Tile ptr es:si).flags],ch
                        add     si,size Tile
                        inc     bl
                        cmp     bl,[(Rect ptr ds:di).right]
                        jne     __20
                        inc     bh
                        cmp     bh,[(Rect ptr ds:di).bottom]
                        jne     __10
                        ret
ENDP map_draw_room


;***** Generate a random map using BSP algorithm *****
;Split the entire map into two rects
;For each of those rects, split those into two rects
;Repeat BSP_LEVELS times
;
;Total rects is 2^(BSP_LEVELS-1)-1. At 3 levels, this
;is 7 rects, or 28 bytes.
BSP_LEVELS              equ     5
BSP_RECTBUF_SIZE        equ     ((2 SHL (BSP_LEVELS-1))-1) * size Rect
BSP_RECTBUF_LASTGEN     equ     (2 SHL (BSP_LEVELS-2)) * size Rect
PROC map_generate_bsp
LOCAL rects:byte:BSP_RECTBUF_SIZE
USES ax,bx,cx,dx,si,di,es,ds
                        push    es
                        ;rects are on the stack segment
                        mov     ax,ss
                        mov     ds,ax
                        mov     es,ax
                        ;si = rects[0]
                        mov     si,bp
                        sub     si,BSP_RECTBUF_SIZE
                        ;rects[0] = whole screen
                        mov     [(Rect ptr si).top],0
                        mov     [(Rect ptr si).bottom],MAP_HEIGHT
                        mov     [(Rect ptr si).left],0
                        mov     [(Rect ptr si).right],MAP_WIDTH
                        ;di = rects[1]
                        mov     di,si
                        add     di,size Rect
                        ;split the screen rect vertically
                        ;call    map_generate_bsp_split_vertical
                        ;split the two new rects horizontally
                        ;call    map_generate_bsp_split_horizontal
                        ;call    map_generate_bsp_split_horizontal
                        ;keep generating rects until we run out of space
__10:                   call    map_generate_bsp_split
                        cmp     di,bp
                        jb      __10
                        ;the last generation make 2^(BSP_LEVELS-1) rooms
                        ;shrink them all by 2 in each direction and draw
                        ;them onto the map
                        mov     di,bp
                        sub     di,BSP_RECTBUF_LASTGEN
                        pop     es
__20:                   inc     [(Rect ptr di).left]
                        dec     [(Rect ptr di).right]
                        inc     [(Rect ptr di).top]
                        dec     [(Rect ptr di).bottom]
                        call    map_draw_room
                        add     di,size Rect
                        cmp     di,bp
                        jb      __20
                        ret
ENDP map_generate_bsp

PROC map_generate_bsp_split
                        call    util_rand
                        test    al,1
                        jz      map_generate_bsp_split_vertical
map_generate_bsp_split_horizontal:
                        mov     bh,[(Rect ptr si).right]
                        sub     bh,[(Rect ptr si).left]
                        shr     bh,1
                        add     bh,[(Rect ptr si).left]
                        ;first rect
                        mov     dx,si
                        mov     cx,size Rect
                        rep     movsb
                        mov     [(Rect ptr di-size Rect).right],bh
                        ;second rect
                        mov     si,dx
                        mov     cx,size Rect
                        rep     movsb
                        mov     [(Rect ptr di-size Rect).left],bh
                        ret
map_generate_bsp_split_vertical:
                        mov     bh,[(Rect ptr si).bottom]
                        sub     bh,[(Rect ptr si).top]
                        shr     bh,1
                        add     bh,[(Rect ptr si).top]
                        ;call    util_rand
                        ;and     ah,00Fh
                        ;sub     ah,2
                        ;add     ah,bh
                        mov     ah,bh
                        ;first rect
                        mov     dx,si
                        mov     cx,size Rect
                        rep     movsb
                        mov     [(Rect ptr di-size Rect).bottom],ah
                        ;second rect
                        mov     si,dx
                        mov     cx,size Rect
                        rep     movsb
                        mov     [(Rect ptr di-size Rect).top],ah
                        ret
ENDP map_generate_bsp_split


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
