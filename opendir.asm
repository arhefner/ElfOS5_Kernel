.list

#include      macros.inc

; *****************************************
; ***** Open directory                *****
; ***** RF - point to path            *****
; ***** RD - fildes                   *****
; ***** Returns: DF=0 - Successful    *****
; *****          DF=1 - Error         *****
; *****             D - Error code    *****
; *****************************************
              proc      opendir

              extrn     finddirent
              extrn     d_ideread
              extrn     lmptosec
              extrn     lastsec
              extrn     helpers
              extrn     save
              extrn     restore
              extrn     getdeflags
              extrn     setfileflags
              extrn     cwd_lump
              extrn     md_lump

              push      r9
              mov       r9,helpers
              op2       save,r7_+r8_+rA_+rD_+rF_
              ldn       rf             ; get first byte
              lbnz      notcwd         ; jump if not current directory
              mov       ra,cwd_lump    ; point to current working dir lump
              lbr       found
notcwd:       smi       '/'            ; check for root dir
              lbnz      go             ; jump if not
              inc       rf             ; get next byte
              ldn       rf
              dec       rf
              lbnz      go             ; jump if not terminator
              mov       ra,md_lump     ; point to master dir lump
              lbr       found          ; then continue
go:           call      finddirent     ; search for directory
              lbnf      found          ; jump if entry was found
invalid:      ldi       8              ; signal invalid directory
              smi       0              ; signal an error
return:       plo       re
              op2       restore,r7_+r8_+rA_+rD_+rF_
              pop       r9
              glo       re
              rtn
found:        op        getdeflags
              ani       1              ; check if subdir
              lbz       invalid        ; jump if not a directory
              ldi       32             ; indicate file is a direcotry
              plo       re             ; set flags
              call      setfildes
              lbr       return

; ***************************************************************
; ***** This expects to be jumped to with the following set *****
; ***** system DTA contains directory sector                *****
; ***** RA - pointer to dirent                              *****
; ***** RD - pointer to fildes                              *****
; *****  D - flags                                          *****
; ***************************************************************
setfildes:    plo       re             ; save flags
              push      rd
              ldi       0              ; initial file position
              str       rd
              inc       rd
              str       rd
              inc       rd
              str       rd
              inc       rd
              str       rd
              inc       rd
              lda       rd             ; retrieve DTA
              phi       rf
              lda       rd
              plo       rf
              lda       ra             ; retrieve starting lump
              phi       r8
              lda       ra
              plo       r8
              lda       ra
              phi       r7
              lda       ra
              plo       r7
              lda       ra             ; transfer EOF to fildes
              str       rd
              inc       rd
              lda       ra
              str       rd
              inc       rd
              ldn       ra             ; get file flags
              dec       ra             ; then move ra back
              shr                      ; shift write protected bit
              ani       2              ; keep only write protected bit
              str       r2
              glo       re             ; write flags to fildes
              or                       ; combine with file flags
              ori       8              ; signal open fildes
              str       rd
              inc       rd
              push      rf             ; save DTA
              mov       rf,lastsec     ; need directory sector
              lda       rf             ; write to fildes
              str       rd
              inc       rd
              lda       rf
              str       rd
              inc       rd
              lda       rf
              str       rd
              inc       rd
              lda       rf
              str       rd
              inc       rd
              pop       rf             ; recover DTA
              dec       ra             ; move ra back to beginning of dirent
              dec       ra
              dec       ra
              dec       ra
              dec       ra
              ghi       ra             ; write dir offset to fildes
              smi       1              ; remove DTA
              str       rd
              inc       rd
              glo       ra
              str       rd
              inc       rd
              call      lmptosec       ; convert starting lump to sector
              ghi       r8             ; write sector to fildes
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
              call      d_ideread      ; read first sector
              adi       0              ; signal no errors
              pop       rd
              call      setfileflags
              rtn

              public    setfildes

              endp

