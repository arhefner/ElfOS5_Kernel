.list

#include      macros.inc

; *********************************************
; ***** Find dirent for name              *****
; ***** RF - path to find                 *****
; ***** Returns: DF=0 - entry found       *****
; *****          RA   - Address of dirent *****
; *****          DF=1 - Not found         *****
; *********************************************
              proc      fnddirent

              extrn     helpers
              extrn     finddirent

              push      r9
              mov       r9,helpers
              call      finddirent
              pop       r9
              rtn

              endp

