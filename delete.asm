.list

#include      macros.inc

; *****************************************
; ***** Delete file                   *****
; ***** RF - point to file            *****
; ***** Returns: DF=0 - Successful    *****
; *****          DF=1 - Error         *****
; *****             D - Error code    *****
; *****************************************
              proc      delete

              extrn     finddirent
              extrn     savesyssec
              extrn     delchain
              extrn     helpers
              extrn     save
              extrn     restore

              push      r9
              mov       r9,helpers
              op2       save,r7_+r8_+rA_
              call      finddirent     ; find dirent for file
              lbnf      good           ; jump if entry was found
exit:         plo       re             ; save result code
              op2       restore,r7_+r8_+rA_
              pop       r9
              glo       re
              rtn                      ; return error
good:         inc       ra             ; need flags
              inc       ra
              inc       ra
              inc       ra
              inc       ra
              inc       ra
              ldn       ra             ; retrieve flags
              dec       ra             ; restore address
              dec       ra
              dec       ra
              dec       ra
              dec       ra
              dec       ra
              ani       1              ; see if directory flag is set
              lbz       notdir         ; jump if not a directory
              ldi       013h           ; set error code
              smi       0              ; indicate error
              lbr       exit           ; and return to caller
notdir:       lda       ra             ; retrieve starting lump
              phi       r8
              lda       ra
              plo       r8
              lda       ra
              phi       r7
              ldn       ra
              plo       r7
              ldi       0              ; zero the entry
              str       ra
              dec       ra
              str       ra
              dec       ra
              str       ra
              dec       ra
              str       ra
              push      r8             ; save lump
              push      r7
              call      savesyssec     ; save sector back to disk
              pop       r7             ; recover lump
              pop       r8
              call      delchain       ; and delete files au chain
              adi       0              ; signal no error
              lbr       exit           ; and return

              endp

