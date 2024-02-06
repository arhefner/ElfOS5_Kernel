.list

#include      macros.inc
#include      bios.inc

; *****************************************
; ***** Write system sector to disk   *****
; *****************************************
              proc      savesyssec

              extrn     d_idewrite
              extrn     dta
              extrn     lastsec
              extrn     save
              extrn     restore

              op2       save,r7_+r8_+rF_
              mov       rf,lastsec     ; point to last sector
              lda       rf             ; retrieve last sector
              phi       r8
              lda       rf
              plo       r8
              lda       rf
              phi       r7
              ldn       rf
              plo       r7
              mov       rf,dta         ; point to system dta
              call      d_idewrite     ; call bios to write sector
              op2       restore,r7_+r8_+rF_
              rtn                      ; return to caller

              endp

