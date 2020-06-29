IDEAL
MODEL SMALL, PASCAL
STACK 100h
LOCALS __
P386

;*********************
;***** Constants *****
;*********************
VGA_MEM                 equ     0B800h

VGA_INPUT_STATUS_0      equ     003DAh
VGA_ATC_REGISTER        equ     003C0h
VGA_ATC_PALETTE         equ     000h
VGA_ATC_MODE            equ     010h

SCAN_ESCAPE             equ     1
SCAN_LEFT               equ     75
SCAN_RIGHT              equ     77
SCAN_UP                 equ     72
SCAN_DOWN               equ     80

SCREEN_WIDTH            equ     80
SCREEN_HEIGHT           equ     50

GFX_PLAYER              equ     '@'

MAP_WIDTH               equ     SCREEN_WIDTH
MAP_HEIGHT              equ     SCREEN_HEIGHT
NUM_ENTITIES            equ     64


;*********************
;*****   Types   *****
;*********************
STRUC SChar
char                    db      ?
attributes              db      ?
ENDS

STRUC Entity
char                    SChar   ?
x                       db      ?
y                       db      ?
ENDS

TFLAGS_SOLID            equ     0
TFLAGS_SOLID_MASK       equ     00000001b
STRUC Tile
char                    SChar   ?
flags                   db      ?
ENDS


;*********************
;*****    Data   *****
;*********************
DATASEG
LABEL uninit_start

LABEL font_start
include "font.inc"
LABEL font_end

;overlay other data on top of font
;all of this data gets initialized to zero _after_
;the font is loaded, so it all must be ? initialized here
ORG uninit_start
map                     Tile    MAP_WIDTH*MAP_HEIGHT dup(<?>)

LABEL entities_start
player_entity           Entity  <?>
other_entities          Entity  NUM_ENTITIES dup(<?>)
LABEL entities_end

LABEL uninit_end

;move location pointer to end of font if uninit_data was
;less than the size of the font
IF uninit_end LT font_end
ORG font_end
ENDIF

;any initialized data must go here


;*********************
;*****    Code   *****
;*********************
CODESEG
PROC main
                        ;set up data segment
                        mov     ax,@data
                        mov     ds,ax
                        mov     es,ax
                        ;set font and initialize data
                        call    set_font
                        mov     di,offset uninit_start
                        mov     cx,offset uninit_end - offset uninit_start
                        mov     al,0
                        rep     stosb
                        ;disable blink
                        mov     dx,VGA_INPUT_STATUS_0
                        in      al,dx
                        mov     dx,VGA_ATC_REGISTER
                        mov     al,VGA_ATC_MODE
                        out     dx,al
                        mov     al,0
                        out     dx,al
                        ;hide cursor
                        mov     ah,002h
                        mov     bh,0
                        mov     dx,0FFFFh
                        int     10h
                        ;create player
                        mov     [player_entity.char.char],'@'
                        mov     [player_entity.char.attributes],00fh
                        mov     [player_entity.x],10
                        mov     [player_entity.y],3
                        ;create wall
                        mov     di,offset map
                        mov     [(Tile ptr di).char.char],'#'
                        mov     [(Tile ptr di).char.attributes],00fh
                        mov     [(Tile ptr di).flags],1 SHL TFLAGS_SOLID
__loop:                 call    clear_screen
                        call    draw_map
                        call    draw_entities
                        ;wait for key
                        xor     ax,ax
                        int     16h
                        cmp     ah,SCAN_ESCAPE
                        je      __exit
                        call    move_player
                        jmp     __loop
__exit:                 ;reset font
                        mov     ax,01101h
                        mov     bl,0
                        int     10h
                        ;clear screen
                        mov     ax,00003h
                        int     10h
                        ;exit
                        mov     ax,04C00h
                        int     21h
ENDP main


;***** Draws the map *****
PROC draw_map
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
ENDP draw_map


;***** Draws all entities *****
PROC draw_entities
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
ENDP draw_entities


;***** Move the player *****
PROC move_player
USES ax,bx,cx,si
                        movzx   bx,[player_entity.x]
                        movzx   cx,[player_entity.y]
                        cmp     ah,SCAN_UP
                        jne     __10
                        dec     cx
                        jmp     __clamp
__10:                   cmp     ah,SCAN_DOWN
                        jne     __20
                        inc     cx
                        jmp     __clamp
__20:                   cmp     ah,SCAN_RIGHT
                        jne     __30
                        inc     bx
                        jmp     __clamp
__30:                   cmp     ah,SCAN_LEFT
                        jne     __ret
                        dec     bx
__clamp:                cmp     bx,0
                        jge     __40
                        mov     bx,0
__40:                   cmp     bx,MAP_WIDTH
                        jb      __50
                        mov     bx,MAP_WIDTH-1
__50:                   cmp     cx,0
                        jge     __60
                        mov     cx,0
__60:                   cmp     cx,MAP_HEIGHT
                        jb      __collide
                        mov     cx,MAP_HEIGHT-1
__collide:              push    cx
                        push    bx
                        ;si=cx*MAP_WIDTH*size Tile
                        mov     ax,cx
                        mov     bx,MAP_WIDTH*size Tile
                        mul     bx
                        mov     si,ax
                        ;si+=dx*size Tile
                        ;get cached bx
                        pop     ax
                        push    ax
                        mov     bx,size Tile
                        mul     bx
                        add     si,ax
                        pop     bx
                        pop     cx
                        ;is that tile walkable?
                        test    [(Tile ptr si).flags],TFLAGS_SOLID_MASK
                        jnz     __ret
                        mov     [player_entity.x],bl
                        mov     [player_entity.y],cl
__ret:                  ret
ENDP move_player


;***** Clear the screen *****
PROC clear_screen
USES ax,cx,di,es
                        mov     ax,VGA_MEM
                        mov     es,ax
                        mov     ax,00f00h
                        mov     cx,SCREEN_WIDTH*SCREEN_HEIGHT
                        xor     di,di
                        rep     stosw
                        ret
ENDP clear_screen


;***** Sets the custom font *****
PROC set_font
USES bp,cx,dx,bx,ax
                        mov     bp,offset font_start
                        mov     cx,128
                        mov     dx,0
                        mov     bh,8
                        xor     bl,bl
                        mov     ax,01110h
                        int     10h
                        ret
ENDP set_font

END main
