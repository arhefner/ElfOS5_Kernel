.list

#include      macros.inc

; *****************************************
; ***** Read lump                     *****
; ***** R8:R7 - Lump                  *****
; ***** Returns:                      *****
; *****   R8:R7 - New lump            *****
; *****************************************
              proc      rdlump32

              extrn     helpers
              extrn     readlump
              extrn     save
              extrn     restore

              push      r9
              mov       r9,helpers
              call      readlump
              pop       r9
              rtn

              endp

