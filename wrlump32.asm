.list

#include      macros.inc

; *****************************************
; ***** Write lump                    *****
; ***** R8:R7 - Lump                  *****
; ***** RB:RA - Value                 *****
; *****************************************
              proc      wrlump32

              extrn     helpers
              extrn     writelump

              push      r9
              mov       r9,helpers
              call      writelump
              pop       r9
              rtn

              endp

