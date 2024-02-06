#include      macros.inc
#include      bios.inc

; **************************************
; ***** RD Pointer to OCB          *****
; ***** Returns: DF=0 - Success    *****
; *****          DF=1 - Error      *****
; *****             D - Error code *****
; **************************************
              proc      inlineover

              extrn     loadover
              extrn     scratch

              mov       rf,scratch
loop:         lda       r6
              str       rf
              inc       rf
              lbnz      loop
              mov       rf,scratch
              lbr       loadover

              endp

