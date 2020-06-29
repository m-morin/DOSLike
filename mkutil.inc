IDEAL
MODEL SMALL, PASCAL
STACK 100h
LOCALS __
P386


;*********************
;***** Constants *****
;*********************
TGA_ID_FIELD_LENGTH     equ     0
TGA_COLOR_MAP_LENGTH    equ     5
TGA_COLOR_MAP_ENT_SIZE  equ     7
TGA_ID_FIELD            equ     18


;*********************
;*****    Data   *****
;*********************
DATASEG
GLOBAL db_str:byte
GLOBAL com_str:byte
GLOBAL nl_str:byte
GLOBAL num:byte
GLOBAL scratch:byte:128
GLOBAL tga_image_data:word
GLOBAL bytes_written:byte:1


;*********************
;*****    Code   *****
;*********************
CODESEG
GLOBAL copy_tail:PROC
GLOBAL tga_init:PROC
GLOBAL write_byte:PROC
GLOBAL read_byte:PROC
GLOBAL read_and_pack_byte:PROC
