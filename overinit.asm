.list

#include      macros.inc
#include      bios.inc

; ************************************
; ***** Initialize overlay table *****
; ***** RD    Pointer to OCB     *****
; ************************************
              proc      overinit

              extrn     helpers
              extrn     fdadd
              extrn     fdsub
              extrn     save
              extrn     restore
              extrn     findsec
              extrn     file_au

              push      r9             ; save consumed register
              mov       r9,helpers
              op2       save,r7_+r8_+rA_+rB_+rC_+rD_
              mov       rc,file_au
              lda       rc
              phi       r8
              lda       rc
              plo       r8
              lda       rc
              phi       r7
              lda       rc
              plo       r7
              ldi       0              ; zero initialized field
              str       rd
              op2       fdadd,5        ; move to count field
              lda       rd             ; and retrieve it
              phi       rc
              lda       rd
              plo       rc
loop:         glo       rc             ; see if done
              str       r2
              ghi       rc
              or
              lbz       done           ; jump if so
              op2       save,r7_+r8_   ; save initial au
              op2       fdadd,4        ; point to sector offset
              lda       rd             ; and retrieve it
              plo       rb
              lda       rd
              phi       ra
              ldn       rd
              plo       ra
              ldi       0
              phi       rb
              op2       fdsub,6        ; move back to sector entry
              call      findsec        ; find corresponding sector
              lbdf      error          ; jump if error
              ghi       r8             ; write sector to OCB
              str       rd
              inc       rd
              glo       r8
              str       rd
              inc       rd
              ghi       r7
              str       rd
              inc       rd
              glo       r7
              str       rd
              op2       restore,r7_+r8_ ; recover initial au
              op2       fdadd,5        ; point to next entry
              dec       rc             ; decrement entry count
              lbr       loop           ; and loop until done
error:        op2       restore,r7_+r8_
              lbr       return
done:         adi       0              ; signal all good
return:       op2       restore,r7_+r8_+rA_+rB_+rC_+rD_
              lbdf      errored        ; jump if result was an error
              ldi       1              ; otherwise flag OCB ad initialized
              str       rd
errored:      pop       r9             ; recover consumed register
              rtn                      ; and return to caller

              endp

; Overlay Control Block (OCB)
; 1-byte   - Flags
;            1 - Table is initialized
; 2-bytes  - Overlay area in RAM
; 2-bytes  - Offset to name table
; 2-bytes  - number of overlay entries
; n-bytes  - entries
             4 bytes - physical sector
             3 bytes - sector offset
             1 byte  - sectors to load
