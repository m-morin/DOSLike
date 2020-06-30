IDEAL
MODEL SMALL, PASCAL
STACK 100h
LOCALS __
P386

include "common.inc"

CODESEG
PROC main
                        ;set up data segment
                        mov     ax,@data
                        mov     ds,ax
                        mov     es,ax
                        ;initialize screen
                        call    screen_init
                        ;initialize data
                        call    data_init
                        call    map_clear
			call	util_prng_seed
                        ;create player
                        mov     [player_entity.char.char],'@'
                        mov     [player_entity.char.attributes],00fh
                        mov     [player_entity.x],10
                        mov     [player_entity.y],3
__loop:                 call    screen_clear
                        call    map_draw
                        call    entity_draw_all
                        ;wait for key
                        xor     ax,ax
                        int     16h
                        cmp     ah,SCAN_ESCAPE
                        je      __exit
                        call    entity_move_player
                        jmp     __loop
__exit:                 ;reset screen
                        mov     ax,00003h
                        int     10h
                        ;exit
                        mov     ax,04C00h
                        int     21h
ENDP main




END main
