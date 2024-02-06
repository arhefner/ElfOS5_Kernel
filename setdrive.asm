.list

#include      macros.inc

; *****************************************
; ***** Set current drive             *****
; ***** D - drive number              *****
; *****************************************
              proc      setdrive

              extrn     drive
              extrn     fstype
              extrn     readsyssec
              extrn     dta
              extrn     save
              extrn     restore

              stxd                     ; save drive number
              op2       save,rF_
              mov       rf,drive       ; point to current drive
              ldn       rf
              irx                      ; point to passed drive number
              sm                       ; and see if the same4
              lbz       done           ; jump if the same drive
              ldx                      ; get new drive number
              str       rf             ; store into drive
              op2       save,R7_+r8_   ; need sector 0
              ldi       0
              phi       r8
              plo       r8
              phi       r7
              plo       r7
              call      readsyssec     ; read sector 0
              mov       rf,fstype      ; point to fstype
              mov       r7,dta+104h    ; point to drives fstype
              ldn       r7             ; retrieve it
              str       rf             ; and store
done:         op2       restore,rF_
              rtn                      ; and return to caller

              endp

