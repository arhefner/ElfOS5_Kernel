.list

#include      macros.inc
#include      bios.inc

; *****************************************
; ***** read system sector from disk  *****
; ***** R8:R7 - sector                *****
; ***** Highest 4-bits of R8 are      *****
; *****   device number               *****
; *****************************************
              proc      readsyssec

              extrn     dta
              extrn     d_ideread
              extrn     lastsec
              extrn     helpers
              extrn     save
              extrn     restore
              extrn     setr8r7_rd

              op2       save,r7_+r8_+rD_+rF_
              mov       rd,lastsec     ; point to last sector
              sex       rd             ; point x to last sector
              ghi       r8             ; compare addresses
              sm
              lbnz      needread
              irx
              glo       r8
              sm
              lbnz      needread
              irx
              ghi       r7
              sm
              lbnz      needread
              irx
              glo       r7
              sm
              lbnz      needread
              sex       r2             ; system dta holds requested sector
exit:         op2       restore,r7_+r8_+rD_+rF_
              rtn                      ; so just return to caller
needread:     mov       rd,lastsec     ; point to last sector
              op        setr8r7_rd     ; save sector
              mov       rf,dta         ; point to system dta
              call      d_ideread      ; call bios to read sector
              lbr       exit           ; then return to caller

              endp

