IDEAL
MODEL SMALL, PASCAL
STACK 100h
LOCALS __
P386

include "common.inc"

CODESEG
;***** Draws all entities *****
PROC entity_draw_all
USES ax,si,di,es
                        mov     ax,VGA_MEM
                        mov     es,ax
                        ;iterate over entities
                        mov     si,offset entities_start
__10:                   cmp     [(Entity si).char.char],0
                        je      __20
                        ;di=y*SCREEN_WIDTH*2
                        movzx   ax,[(Entity si).y]
                        shl     ax,5
                        mov     di,ax
                        shl     ax,2
                        add     di,ax
                        ;di+=x*2
                        movzx   ax,[(Entity si).x]
                        shl     ax,1
                        add     di,ax
                        ;draw character
                        mov     ax,[word ptr (Entity si).char]
                        mov     [word ptr es:di],ax
__20:                   add     si,size Entity
                        cmp     si,offset entities_end
                        jl      __10
                        ret
ENDP entity_draw_all


;***** Move the player *****
;Parameters: ah:key input
PROC entity_move_player
USES ax,bx,cx,si
                        mov     bl,[player_entity.x]
                        mov     bh,[player_entity.y]
                        cmp     ah,SCAN_UP
                        jne     __10
                        ;move up unless already at 0
                        cmp     bh,0
                        je      __ret
                        dec     bh
                        jmp     __collide
__10:                   cmp     ah,SCAN_DOWN
                        jne     __20
                        ;move down unless already at MAP_HEIGHT-1
                        cmp     bh,MAP_HEIGHT-1
                        jge     __ret
                        inc     bh
                        jmp     __collide
__20:                   cmp     ah,SCAN_RIGHT
                        jne     __30
                        ;move right unless already at MAP_WIDTH-1
                        cmp     bl,MAP_WIDTH-1
                        jge     __ret
                        inc     bl
                        jmp     __collide
__30:                   cmp     ah,SCAN_LEFT
                        jne     __ret
                        ;move left unless already at 0
                        cmp     bl,0
                        je      __collide
                        dec     bl
__collide:              ;is that tile walkable?
                        call    map_xy_to_ptr
                        test    [(Tile ptr si).flags],TFLAGS_SOLID_MASK
                        jnz     __ret
                        mov     [player_entity.x],bl
                        mov     [player_entity.y],bh
__ret:                  ret
ENDP entity_move_player

END
