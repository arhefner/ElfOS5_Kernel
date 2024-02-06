.list

#include      macros.inc
#include      bios.inc

; *****************************************
; ***** Write system sector to disk   *****
; *****************************************
              proc      savesys

              extrn     helpers
              extrn     savesyssec

              push      r9
              mov       r9,helpers
              call      savesyssec
              pop       r9
              rtn

              endp

