.list

#include      macros.inc

; **************************************
; ***** Write lump (depricated)    *****
; ***** RA - Lump                  *****
; ***** RF - value                 *****
; **************************************
              proc      wrlump

              extrn     helpers
              extrn     writelump
              extrn     save
              extrn     restore

              push      r9
              mov       r9,helpers
              op2       save,r7_+r8_+rA_+rB_
              mov       r7,ra
              mov       ra,rf
              ldi       0
              phi       r8
              plo       r8
              phi       rb
              plo       rb
              call      writelump
              op2       restore,r7_+r8_+rA_+rB_
              pop       r9
              rtn

              endp

