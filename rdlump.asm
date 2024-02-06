.list

#include      macros.inc

; **************************************
; ***** Read lump (depricated)     *****
; ***** RA - Lump                  *****
; ***** Returns:                   *****
; *****   RA - New lump            *****
; **************************************
              proc      rdlump

              extrn     helpers
              extrn     readlump
              extrn     save
              extrn     restore

              push      r9
              mov       r9,helpers
              op2       save,r7_+r8_
              mov       r7,ra
              ldi       0
              phi       r8
              plo       r8
              call      readlump
              mov       ra,r7
              op2       restore,r7_+r8_
              pop       r9
              rtn

              endp

