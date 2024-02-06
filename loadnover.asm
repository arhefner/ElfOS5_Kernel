#include      macros.inc
#include      bios.inc

; **************************************
; ***** RD Pointer to OCB          *****
; ***** Returns: DF=0 - Success    *****
; *****          DF=1 - Error      *****
; *****             D - Error code *****
; **************************************
              proc      loadnover

              extrn     helpers
              extrn     save
              extrn     loadovly

              ldn       rd             ; see if valid ocb
              smi       1
              lbnz      error          ; jump if error
              push      r9             ; save consumed register
              mov       r9,helpers
              op2       save,r7_+r8_+rC_+rD_+rF_
              lda       r6
              plo       rc
              ldi       0
              phi       rc
              inc       rd             ; move to ram field
              lbr       loadovly       ; and load overlay
error:        ldi       18             ; signal an er
              smi       0
              rtn

              endp

