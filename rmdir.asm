.list

#include      macros.inc

; *****************************************
; ***** Delete directory              *****
; ***** RF - point to file            *****
; ***** Returns: DF=0 - Successful    *****
; *****          DF=1 - Error         *****
; *****             D - Error code    *****
; *****************************************
              proc      rmdir

              extrn     finddirent
              extrn     savesyssec
              extrn     delchain
              extrn     lastsec
              extrn     dirempty
              extrn     readsyssec
              extrn     helpers
              extrn     save
              extrn     restore
              extrn     getdeflags
              extrn     startingau

              push      r9
              mov       r9,helpers
              op2       save,r7_+r8_+rA_
              call      finddirent     ; find dirent for file
              lbdf      exit           ; jump if entry not found
good:         op        getdeflags
              ani       1              ; see if directory flag is set
              lbnz      isdir          ; jump if not a directory
              ldi       013h           ; set error code
              smi       0              ; indicate error
              lbr       exit           ; then return to caller
isdir:        push      ra             ; save dirent address
              op        startingau     ; retreive au
              mov       ra,lastsec     ; need directory sector number
              lda       ra             ; retrieve it
              stxd                     ; and set it aside
              lda       ra
              stxd
              lda       ra
              stxd
              lda       ra
              stxd
              call      dirempty       ; see if directory has files
              lbnf      nofiles        ; jump if there are no files
              irx                      ; remove sector from stack
              irx
              irx
              irx
              pop       ra             ; remove dirent address
              ldi       014h           ; signal directory not empty
              smi       0              ; signal error
              lbr       exit           ; and return to caller
nofiles:      call      delchain       ; deallocate AUs assigned to directory
              irx                      ; recover lastsec
              ldxa
              plo       r7
              ldxa
              phi       r7
              ldxa
              plo       r8
              ldx
              phi       r8
              call      readsyssec     ; read directory sector back in
              pop       ra             ; recover dirent address
              ldi       0              ; zero starting lump in dirent
              str       ra
              inc       ra
              str       ra
              inc       ra
              str       ra
              inc       ra
              str       ra
              call      savesyssec     ; save system sector back to disk
              adi       0              ; indicate no errors
exit:         plo       re             ; save result code
              op2       restore,r7_+r8_+rA_
              pop       r9
              glo       re             ; recover result code
              rtn                      ; and return to caller

              endp

