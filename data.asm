IDEAL
MODEL SMALL, PASCAL
STACK 100h
LOCALS __
P386

include "common.inc"

DATASEG
LABEL uninit_start

LABEL font_start
include "font.inc"
LABEL font_end

;overlay other data on top of font
;all of this data gets initialized to zero _after_
;the font is loaded, so it all must be ? initialized here
ORG uninit_start
map             Tile   MAP_WIDTH*MAP_HEIGHT dup(<?>)

LABEL entities_start
player_entity   Entity  <?>
other_entities  Entity  NUM_ENTITIES dup(<?>)
LABEL entities_end

prng            dw      ?

LABEL uninit_end

;move location pointer to end of font if uninit_data was
;less than the size of the font
IF uninit_end LT font_end
ORG font_end
ENDIF

;any initialized data must go here
LABEL palette_start
include "palette.inc"
LABEL palette_end

CODESEG
;Initialize uninitialized data area to 0s
PROC data_init
USES di,cx,ax
                mov     di,offset uninit_start
                mov     cx,offset uninit_end - offset uninit_start
                mov     al,0
                rep     stosb
                ret
ENDP data_init

END
