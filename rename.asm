.list

#include      macros.inc

; *************************************
; *** rename a file                 ***
; *** RF - filename                 ***
; *** RC - new filename             ***
; *** Returns:                      ***
; ***          DF=0 - success       ***
; ***          DF=1 - error         ***
; ***             D - Error code    ***
; *************************************
              proc      rename

              extrn     finddirent
              extrn     savesyssec
              extrn     helpers
              extrn     save
              extrn     restore

              push      r9
              mov       r9,helpers
              op2       save,rA_+rC_
              call      finddirent     ; find dirent for file
              lbnf      good           ; jump if entry was found
exit:         op2       restore,rA_+rC_
              pop       r9
              glo       re
              rtn                      ; return error
good:         glo       ra             ; move to filename
              adi       12
              plo       ra
              ghi       ra
              adci      0
              phi       ra
              ldi       19             ; max characters for name
              plo       re
loop:         lda       rc             ; get byte from new name
              str       ra             ; write to dirent
              inc       ra
              lbz       done           ; jump if terminator copied
              dec       re             ; decrement max characters
              glo       re             ; see if at max
              lbnz      loop           ; loop until done
              ldi       0              ; write a terminator
              str       ra
done:         call      savesyssec     ; write sector back to disk
              adi       0              ; indicate no errors
              lbr       exit           ; and return

              endp

