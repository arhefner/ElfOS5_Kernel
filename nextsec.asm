.list

#include      macros.inc

; **************************************************
; ***** Load next sector of a file being read  *****
; ***** RD - pointer to FILDES                 *****
; ***** Returns: DF=0 - success                *****
; *****          DF=1 - Error                  *****
; *****             D - Error code             *****
; **************************************************
              proc      nextsec

              extrn     d_ideread
              extrn     readlump
              extrn     sectolmp
              extrn     lmptosec
              extrn     save
              extrn     restore
              extrn     getr8r7_rd
              extrn     setr8r7_rd
              extrn     incsec
              extrn     finalau
              extrn     checkwrite
              extrn     fdadd
              extrn     fdsub
              extrn     setfileflags

              call      checkwrite     ; see if current sector needs to be written
              op2       save,r7_+r8_+rD_+rF_
              op2       fdadd,15       ; point to current sector
              op        getr8r7_rd     ; retrieve current sector
              ani       7              ; check for last sector of lump
              smi       7
              lbnz      inconly        ; jump if not

              call      sectolmp       ; convert sector to lump
              call      readlump       ; read next lump
              op        finalau        ; check if in final AU
              lbnf      notfinal       ; jump if not
              ldi       0ffh           ; signal error
              smi       0
              lbr       errexit
notfinal:     call      lmptosec       ; convert lump to sector
              lbr       readnext       ; and then continue
inconly:      op        incsec         ; increment sector number
readnext:     op        setr8r7_rd     ; write new sector back to fildes
              op2       fdsub,11       ; move to DTA
              lda       rd             ; get DTA address
              phi       rf
              ldn       rd
              plo       rf
              call      d_ideread      ; read in the sector
              op2       fdsub,5        ; move FILDES back to beginning
              call      setfileflags   ; and set file flags
              adi       0              ; signal no errors
errexit:      op2       restore,r7_+r8_+rD_+rF_
              glo       re             ; get return code
              rtn                      ; and return to caller

              endp

