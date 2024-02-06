.list

#include      macros.inc

; ********************************************
; ***** Zero lump contents               *****
; ***** R8:R7 - Lump to zero             *****
; ********************************************
              proc      zerolump

              extrn     lmptosec
              extrn     dta
              extrn     writesyssec
              extrn     helpers
              extrn     save
              extrn     restore

              op2       save,r7_+r8_+rC_+rF_
              mov       rc,512         ; 512 bytes to clear
              mov       rf,dta         ; point to system dta
loop1:        ldi       0              ; zero the dta
              str       rf
              inc       rf
              dec       rc             ; decrement count
              glo       rc             ; check if done
              str       r2
              ghi       rc
              or
              lbnz      loop1          ; loop until DTA is cleared
              call      lmptosec       ; convert lump to first sector
              ldi       8              ; 8 sectors to write
              plo       rc
loop2:        call      writesyssec    ; write system sector
              dec       rc             ; decrement count
              glo       rc             ; see if done
              lbz       done           ; jump if so
              inc       r7             ; increment sector
              glo       r7             ; check for roll
              str       r2
              ghi       r7
              or
              lbnz      loop2          ; keep writing sectors
              inc       r8
              lbr       loop2
done:         op2       restore,r7_+r8_+rC_+rF_
              rtn                      ; and return to caller

              endp

