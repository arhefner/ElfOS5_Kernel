.list

#include      macros.inc

; *****************************************
; ***** Set file flags                *****
; ***** RD - fildes                   *****
; *****************************************
              proc      setfileflags

              extrn     readlump
              extrn     sectolmp
              extrn     save
              extrn     restore
              extrn     fdadd
              extrn     fdsub
              extrn     getr8r7_rd
              extrn     finalau

              op2       save,r7_+r8_+rA_+rB_+rD_

              op2       fdadd,8        ; point to flags
              ldn       rd             ; retrieve them
              ani       07bh           ; clear last lump/sector flags
              str       rd
              op2       fdadd,7        ; point to sector field
              op        getr8r7_rd     ; retreive sector
              call      sectolmp       ; convert to lump number
              call      readlump       ; read lump
              op        finalau        ; see if in final au
              lbnf      notfinal       ; jump if not final
              op2       fdsub,7        ; move to flags
              ldn       rd             ; retrieve flags
              ori       04             ; indicate final lump
              str       rd
              dec       rd             ; move to msb of eof
              dec       rd
              ldn       rd             ; retrieve it
              ani       0eh            ; keep only sector bits
              stxd                     ; store for compare
              op2       fdsub,4        ; move to 2nd byte of position
              irx                      ; move back to eof msb
              ldn       rd             ; get byte
              ani       0eh            ; keep only sector bits
              sm                       ; compare against eof
              lbnz      notfinal       ; jump if not final sector
              op2       fdadd,6        ; move back to flags
              ldn       rd             ; get flags
              ori       080h           ; set final sector flag
              str       rd             ; and store back
notfinal:     op2       restore,r7_+r8_+rA_+rB_+rD_
              rtn                      ; and return to caller

              endp
