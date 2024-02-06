.list

#include      macros.inc

; *****************************************
; ***** Set default directory         *****
; ***** RF - pointer to path          *****
; ***** Returns: DF=0 - Successful    *****
; *****          DF=1 - Error         *****
; *****             D - Error code    *****
; *****************************************
              proc      setdef

              extrn     helpers
              extrn     save
              extrn     restore
              extrn     finddirent
              extrn     path
              extrn     getdeflags
              extrn     def_lump

              push      r9
              mov       r9,helpers
              op2       save,rA_+rB_+rF_

              ldn       rf             ; check for empty path
              lbnz      haspath        ; jump if a path is provided
              mov       ra,path        ; point to current path
copyloop:     lda       ra             ; read character from path
              str       rf             ; store into buffer
              inc       rf
              lbnz      copyloop       ; copy until terminator found
              adi       0              ; signal no error
              lbr       return         ; and return to caller
haspath:      smi       '/'            ; must be absolute path
              lbz       absolute       ; jump if so
              ldi       0x13           ; indicate error
              smi       0
              lbr       return         ; and return
absolute:     call      finddirent     ; find directory entry for path
              lbdf      return         ; return on error
              op        getdeflags     ; get flags from dirent
              ani       1              ; is dirent for a subdir
              lbnz      isdir          ; jump if it is a directory
              ldi       08h            ; signal non directory error
              smi       0
              lbr       return         ; and return
isdir:        mov       rb,path        ; pointer to path
copypath:     lda       rf             ; read byte from new path
              str       rb             ; store into path
              inc       rb
              lbnz      copypath       ; copy until terminator
              mov       rb,def_lump    ; point to def_lump
              ldi       6              ; 6 bytes to copy
              plo       re
copy:         lda       ra             ; read byte from dirent
              str       rb             ; store into def_lump
              inc       rb
              dec       re             ; decrement count
              glo       re             ; see if done
              lbnz      copy           ; loop back if not
              adi       0              ; signal no errors
return:       op2       restore,rA_+rB_+rF_
              pop       r9
              glo       re
              rtn                      ; and return to caller

              endp

