IDEAL
MODEL SMALL, PASCAL
STACK 100h
LOCALS __
P386

include "common.inc"

CODESEG
;***** Seed the PRNG with system time *****
PROC util_prng_seed
USES ax,cx,dx
                xor     ax,ax
                int     01Ah
                mov     [word ptr prng],dx
                ret
ENDP util_prng_seed

;***** Return a random number *****
PROC util_rand
USES bx
                mov     ax,[word ptr prng]
                mov     bx,ax
                shl     bx,7
                xor     ax,bx
                mov     bx,ax
                shr     bx,9
                xor     ax,bx
                mov     bx,ax
                shl     bx,8
                xor     ax,bx
                mov     [word ptr prng],ax
                ret
ENDP util_rand


END
