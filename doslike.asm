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
SCREEN_HEIGHT           equ     28

GFX_PLAYER              equ     '@'

MAP_WIDTH               equ     SCREEN_WIDTH
MAP_HEIGHT              equ     SCREEN_HEIGHT
NUM_ENTITIES            equ     64


;*********************
;*****   Types   *****
;*********************
STRUC Entity
char                    db ?
x                       db ?
y                       db ?
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
map                     db      MAP_WIDTH*MAP_HEIGHT*3 dup(?)

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
                        ;initialize data
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
                        mov     [player_entity.char],'@'
                        mov     [player_entity.x],10
                        mov     [player_entity.y],3
__loop:                 call    clear_screen
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


;***** Draws all entities *****
PROC draw_entities
USES ax,si,di,es
                        mov     ax,VGA_MEM
                        mov     es,ax
                        ;iterate over entities
                        mov     si,offset entities_start
__10:                   cmp     [(Entity si).char],0
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
                        mov     al,[(Entity si).char]
                        mov     [byte ptr es:di],al
__20:                   add     si,size Entity
                        cmp     si,offset entities_end
                        jl      __10
                        ret
ENDP draw_entities


;***** Move the player *****
PROC move_player
USES ax
                        cmp     ah,SCAN_UP
                        jne     __10
                        dec     [player_entity.y]
                        jmp     __clamp
__10:                   cmp     ah,SCAN_DOWN
                        jne     __20
                        inc     [player_entity.y]
                        jmp     __clamp
__20:                   cmp     ah,SCAN_RIGHT
                        jne     __30
                        inc     [player_entity.x]
                        jmp     __clamp
__30:                   cmp     ah,SCAN_LEFT
                        jne     __ret
                        dec     [player_entity.x]
__clamp:                cmp     [player_entity.x],0
                        jge     __40
                        mov     [player_entity.x],0
__40:                   cmp     [player_entity.x],MAP_WIDTH
                        jb      __50
                        mov     [player_entity.x],MAP_WIDTH-1
__50:                   cmp     [player_entity.y],0
                        jge     __60
                        mov     [player_entity.y],0
__60:                   cmp     [player_entity.y],MAP_HEIGHT
                        jb      __ret
                        mov     [player_entity.y],MAP_HEIGHT-1
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
                        mov     cx,256
                        mov     dx,0
                        mov     bh,14
                        xor     bl,bl
                        mov     ax,01110h
                        int     10h
                        ret
ENDP set_font

END main
