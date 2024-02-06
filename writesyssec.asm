.list

#include      macros.inc
#include      bios.inc

; *****************************************
; ***** Write system sector to disk   *****
; ***** R8:R7 - sector                *****
; ***** Highest 4-bits of R8 are the  *****
; *****   device number               *****
; *****************************************
              proc      writesyssec

              extrn     d_idewrite
              extrn     dta
              extrn     lastsec
              extrn     save
              extrn     restore
              extrn     setr8r7_rd

              op2       save,r7_+r8_+rD_+rF_
              mov       rd,lastsec     ; point to last sector
              op        setr8r7_rd     ; write sector to last sector
              mov       rf,dta         ; point to system dta
              call      d_idewrite     ; call bios to write sector
              op2       restore,r7_+r8_+rD_+rF_
              rtn                      ; return to caller

              endp

