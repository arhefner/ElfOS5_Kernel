.list

#include      macros.inc

; *****************************************
; ***** Delete AU chain               *****
; ***** R8:R7 - Head AU to delete     *****
; *****************************************
              proc      delchain

              extrn     readlump
              extrn     writelump
              extrn     save
              extrn     restore
              extrn     finalau

              op2       save,r7_+r8_+rA_+rB_+rC_+rD_
loop:         op        finalau        ; check for final au
              lbnf      notdone        ; jump if not done yet
              op2       restore,r7_+r8_+rA_+rB_+rC_+rD_
              rtn                      ; last lump, so return
notdone:      op2       save,r7_+r8_   ; save current lump
              call      readlump       ; get next lump
              mov       rd,r8          ; save next lump
              mov       rc,r7
              op2       restore,r7_+r8_ ; recover last lump
              ldi       0              ; need to zero it
              phi       rb
              plo       rb
              phi       ra
              plo       ra
              call      writelump      ; write to LAT
              mov       r8,rd          ; move next lump to R8:R7
              mov       r7,rc
              lbr       loop           ; loop until last lump found

              endp

