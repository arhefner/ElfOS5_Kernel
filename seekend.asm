.list

#include      macros.inc

; *****************************************
; ***** Seek end of file              *****
; ***** RD - fildes                   *****
; ***** Returns: R8:R7 - Final AU     *****
; *****          RB:RA - size         *****
; *****************************************
              proc      seekend

              extrn     save
              extrn     restore
              extrn     loaddirent
              extrn     deadd
              extrn     startingau
              extrn     finalau
              extrn     readlump

              op2       save,rD_
              ldi       1              ; load AU into r8:r7
              call      loaddirent     ; get dirent for file
              op2       deadd,4        ; point to eof
              lda       ra             ; eof is initial size
              plo       re
              lda       ra
              plo       ra
              glo       re
              phi       ra
              ldi       0
              phi       rb
              plo       rb
loop:         op2       save,r7_+r8_   ; save current lump
              call      readlump       ; read next lump
              op        finalau        ; see if in final AU
              lbdf      isfinal        ; jump if final lump
              irx                      ; remove last lump from stack
              irx
              irx
              irx
              ghi       ra             ; add 4096 to count
              adi       010h
              phi       ra
              glo       rb
              adci      0
              plo       rb
              ghi       rb
              adci      0
              phi       rb
              lbr       loop           ; read next lump
isfinal:      op2       restore,r7_+r8_ ; recover final lump of file
              op2       restore,rD_
              rtn

              endp

