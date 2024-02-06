.list

#include      macros.inc

; *****************************************
; ***** Make directory                *****
; ***** RF - point to file            *****
; ***** Returns: DF=0 - Successful    *****
; *****          DF=1 - Error         *****
; *****             D - Error code    *****
; *****************************************
              proc      mkdir

              extrn     create
              extrn     helpers
              extrn     save
              extrn     restore

              push      r9
              mov       r9,helpers
              op2       save,rA_
              ldi       1              ; need to create directory
              call      create         ; create the file
              op2       restore,rA_
              pop       r9             ; recover consumed register
              glo       re
              rtn                      ; and return to caller

              endp

