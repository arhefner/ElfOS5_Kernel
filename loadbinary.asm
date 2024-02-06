.list

#include      macros.inc

; ********************************************
; ***** Load binary executable           *****
; ***** RA - Pointer to DIRENT           *****
; ***** R9 - pointing to helpers         *****
; ********************************************
              proc      loadbinary

              extrn     helpers
              extrn     startingau
              extrn     save
              extrn     restore
              extrn     lmptosec
              extrn     d_ideread
              extrn     incsec
              extrn     loadrf
              extrn     loadrc
              extrn     readlump
              extrn     finalau
              extrn     file_au

              op2       save,r7_+r8_+rA_+rC_+rF_
              op        startingau     ; retrieve starting lump
              mov       rf,file_au     ; store files starting au
              ghi       r8
              str       rf
              inc       rf
              glo       r8
              str       rf
              inc       rf
              ghi       r7
              str       rf
              inc       rf
              glo       r7
              str       rf
              op2       save,r7_+r8_   ; save AU
              call      lmptosec       ; convert lump to sector
              mov       rf,01ffah      ; initial load address
              call      d_ideread
              op        incsec         ; increment sector
              op        loadrf         ; get loading address
              dw        01ffah
              glo       rf             ; check for nonstandard address
              lbnz      nonstd
              ghi       rf
              smi       020h
              lbz       standard
nonstd:       glo       rf             ; move to end of range
              adi       0f9h
              plo       rf
              ghi       rf
              adci      1
              phi       rf             ; RF now has destination
              mov       ra,021f9h      ; source
              mov       rc,506         ; 506 bytes to move
copyloop:     ldn       ra             ; read byte from source
              str       rf             ; write to destination
              dec       ra             ; decrement pointers
              dec       rf
              dec       rc             ; decrement count
              glo       rc             ; check for done
              lbnz      copyloop       ; keep copying if not
              ghi       rc             ; check high byte
              lbnz      copyloop
              inc       rf
standard:     glo       rf             ; account for bytes already loaded
              adi       0fah
              plo       rf
              ghi       rf
              adci      1
              phi       rf
              op        loadrc         ; get count of bytes to load
              dw        01ffch
              glo       rc             ; account for bytes already loaded
              smi       0fah
              plo       rc
              ghi       rc
              smbi      1
              phi       rc
loadloop:     ghi       rc             ; check for all bytes read
              shl
              lbdf      done           ; jump if all bytes have been read
              call      d_ideread      ; read next sector
              ghi       rc             ; subtract 512 bytes from count
              smi       2
              phi       rc
              op        incsec         ; increment sector
              glo       r7             ; see if new lump needs to loaded
              ani       7
              lbnz      loadloop       ; jump if not
              op2       restore,r7_+r8_ ; recover last AU
              call      readlump       ; read next lump
              op2       save,r7_+r8_   ; save AU
              op        finalau        ; check for final au
              call      lmptosec       ; convert lump to sector
              lbnf      loadloop       ; and keep reading
done:         irx                      ; remove AU from the stack
              irx
              irx
              irx
              op2       restore,r7_+r8_+rA_+rC_+rF_
              rtn                      ; return to caller

              endp

; RF
