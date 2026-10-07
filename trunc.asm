.list

#include      macros.inc

; *****************************************
; ***** Truncate file                 *****
; ***** RD - Pointer to FILDES        *****
; *****************************************
              proc      trunc

              extrn     helpers
              extrn     readlump
              extrn     writelump
              extrn     save
              extrn     restore
              extrn     fdadd
              extrn     getr8r7_rd
              extrn     sectolmp
              extrn     finalau
              extrn     delchain
              extrn     getfdflags

              push      r9
              mov       r9,helpers
              op2       save,r7_+r8_+rA_+rB_+rD_
              op        getfdflags     ; get flags
              ani       0ah            ; want only open and read only bits
              smi       8              ; only open bit is good
              lbz       good
              ldi       1              ; signal error
              smi       0
              lbr       return
good:         inc       rd             ; move to low 2 bytes
              inc       rd
              lda       rd             ; retrieve them
              ani       0fh            ; only low 4 bits of high byte
              phi       r7             ; set aside
              lda       rd             ; low byte
              plo       r7             ; set aside
              inc       rd             ; move past dta
              inc       rd
              ghi       r7             ; set eof as current position
              str       rd
              inc       rd
              glo       r7
              str       rd
              inc       rd             ; move to flags
              ldn       rd             ; retrieve flags
              ori       094h           ; set file modified, last lump, last sector
              str       rd             ; write flags back
              op2       fdadd,7        ; move to current sector
              op        getr8r7_rd     ; get current sector
              call      sectolmp       ; convert sector to lump
              op2       save,r7_+r8_   ; save lump
              call      readlump       ; read value of lump
              op        finalau        ; see if in final au
              lbdf      final          ; jump if so
              call      delchain       ; delete chain following current lump
              op2       restore,r7_+r8_ ; recover lump
              ldi       0              ; need to terminate chain
              phi       rb
              plo       rb
              ldi       0feh
              phi       ra
              plo       ra
              call      writelump      ; write terminator to lump
              adi       0
              lbr       return         ; all done
final:        op2       restore,r7_+r8_ ; remove these from the stack
return:       op2       restore,r7_+r8_+rA_+rB_+rD_
              pop       r9
              glo       re
              rtn                      ; return to caller

              endp

