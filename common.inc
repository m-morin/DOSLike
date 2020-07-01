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
ENDS SChar

STRUC Entity
char                    SChar   ?
x                       db      ?
y                       db      ?
ENDS Entity

TFLAGS_SOLID            equ     00000001b
TFLAGS_OPAQUE           equ     00000010b
TFLAGS_SEEN             equ     00000100b
STRUC Tile
char                    db      ?
attributes              db      ?
flags                   db      ?
ENDS Tile

STRUC Rect
top                     db      ?
bottom                  db      ?
left                    db      ?
right                   db      ?
ENDS Rect


;*********************
;*****    Data   *****
;*********************
DATASEG
GLOBAL uninit_start
GLOBAL uninit_end
GLOBAL init_start
GLOBAL init_end

GLOBAL font_start
GLOBAL font_end

GLOBAL map:Tile:MAP_WIDTH*MAP_HEIGHT

GLOBAL entities_start
GLOBAL player_entity:Entity
GLOBAL other_entities:Entity:NUM_ENTITIES
GLOBAL entities_end

GLOBAL prng:word

GLOBAL palette_start
GLOBAL palette_end


;*********************
;*****    Code   *****
;*********************
CODESEG
GLOBAL data_init:PROC

GLOBAL util_prng_seed:PROC
GLOBAL util_rand:PROC

GLOBAL map_xy_to_ptr:PROC
GLOBAL map_draw:PROC
GLOBAL map_draw_room:PROC
GLOBAL map_clear:PROC
GLOBAL map_generate:PROC

GLOBAL screen_init:PROC
GLOBAL screen_clear:PROC
GLOBAL screen_set_font:PROC

GLOBAL entity_draw_all:PROC
GLOBAL entity_move_player:PROC
