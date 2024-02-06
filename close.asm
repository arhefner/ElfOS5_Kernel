.list

#include      macros.inc

; *****************************************
; ***** close file                    *****
; ***** RD - fildes                   *****
; ***** Returns: DF=0 - Successful    *****
; *****          DF=1 - Error         *****
; *****             D - Error code    *****
; *****************************************
              proc      close

              extrn     helpers
              extrn     checkwrite
              extrn     getfdflags
              extrn     setfdflags
              extrn     loaddirent
              extrn     fdadd
              extrn     deadd
              extrn     setdatetime
              extrn     savesyssec
              extrn     save
              extrn     restore

              push      r9
              mov       r9,helpers
              op2       save,r7_+r8_+rA_+rD_
              op        getfdflags     ; get flags
              ani       8              ; check for open file
              lbnz      isopen         ; jump if open fildes
              ldi       010h           ; signal file not open
              smi       0              ; signal error
return:       plo       re
              op2       restore,r7_+r8_+rA_+rD_
              pop       r9
              glo       re
              rtn                      ; and return
isopen:       call      checkwrite     ; see if current sector needs writing
              op        getfdflags     ; get fdflags
              ani       0f7h           ; clear open flag
              stxd                     ; save the flags
              op        setfdflags     ; save flags back to fildes
              irx                      ; recover flags
              ldx
              ani       010h           ; check for file written
              lbnz      written        ; jump if file was written
              adi       0              ; signal no error
              lbr       return         ; and return
written:      ldi       0              ; read in dirent for file
              call      loaddirent
              op2       fdadd,6
              op2       deadd,4
              lda       rd             ; copy eof from fildes to dirent
              str       ra
              inc       ra
              lda       rd
              str       ra
              inc       ra
              ldn       ra             ; mark file has having been written
              ori       010h 
              str       ra
              inc       ra             ; move to date/time field
              call      setdatetime    ; set new date/time
              call      savesyssec     ; save dir sector back to disk
              adi       0              ; signal no error
              lbr       return         ; then return to caller

              endp

