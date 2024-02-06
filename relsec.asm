.list

#include      macros.inc
#include      bios.inc

; ********************************************
; ***** Find sector                      *****
; ***** R8:R7 - initial AU               *****
; ***** RB:RA - Sector number            *****
; ***** Returns: DF=0 - no errors        *****
; *****          R8:R7 - Physcial sector *****
; *****          DF=1 - erorr            *****
; ********************************************
              proc      relsec

              extrn     findsec
              extrn     helpers

              push      r9             ; save consumed register
              mov       r9,helpers
              call      findsec
              pop       r9             ; recover consumed register
              rtn                      ; and return to caller

              endp
