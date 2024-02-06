.list

#include      macros.inc

; *****************************************
; ***** change directory              *****
; ***** RF - pointer to path          *****
; ***** Returns: DF=0 - Successful    *****
; *****          DF=1 - Error         *****
; *****             D - Error code    *****
; *****************************************
              proc      chdir

              extrn     helpers
              extrn     save
              extrn     restore
              extrn     finddirent
              extrn     getdeflags
              extrn     md_lump
              extrn     cwd_lump
              extrn     cwd
              extrn     strcpy

              push      r9
              mov       r9,helpers
              op2       save,rA_+rB_+rD_+rF_

              ldn       rf             ; check for empty path
              lbnz      haspath        ; jump if a path is provided
              mov       ra,cwd         ; point to current directory
copyloop:     lda       ra             ; read character from path
              str       rf             ; store into buffer
              inc       rf
              lbnz      copyloop       ; copy until terminator found
              adi       0              ; signal no error
              lbr       return         ; and return to caller
haspath:      smi       '/'            ; check for root dire
              lbnz      notroot        ; jump if not
              inc       rf             ; need next byte
              ldn       rf
              dec       rf
              lbnz      notroot        ; jump if not 
              mov       ra,md_lump     ; point to master dir lump
              mov       rb,cwd_lump    ; point to cwd lump
              ldi       6              ; 6 bytes to copy
              plo       re
mdloop:       lda       ra             ; get byte from md entry
              str       rb             ; store into cwd
              inc       rb
              dec       re             ; decrement count
              glo       re             ; see if done
              lbnz      mdloop         ; loop until done
              mov       ra,cwd         ; point to cwd
              ldi       '/'            ; write new path
              str       ra
              inc       ra
              ldi       0
              str       ra
              adi       0              ; signal no error
              lbr       return         ; and return
notroot:      call      finddirent     ; search for diretory entry
              lbdf      return         ; jump on error
              op        getdeflags     ; get flags from dirent
              ani       1              ; check for subdir
              lbnz      isdir          ; jump if is directory
              ldi       08h            ; signal an error
              smi       0
              lbr       return         ; and return to caller
isdir:        mov       rb,cwd_lump    ; point to cwd entry
              ldi       6              ; need to copy 6 bytes
              plo       re
copyau:       lda       ra             ; get byte from dirent
              str       rb             ; store into cwd
              inc       rb
              dec       re             ; decrement count
              glo       re             ; see if done
              lbnz      copyau         ; copy until done
              ldn       rf             ; get byte from path
              smi       '/'            ; check for absolute path
              lbz       absolute       ;jump if so
              mov       rd,cwd         ; point to cwd path
cwdloop:      lda       rd             ; need to find end
              lbnz      cwdloop        ; loop until terminator
              dec       rd             ; move back to last character
              dec       rd
              lda       rd             ; and retrieve it
              smi       '/'            ; does it end in a slash
              lbz       docopy         ; copy if so
              ldi       '/'            ; need to add a slash
              str       rd
              inc       rd
              lbr       docopy         ; and then copy
absolute:     mov       rd,cwd         ; point to cwd path
docopy:       op        strcpy         ; and copy
              adi       0              ; indicate no error
return:       op2       restore,rA_+rB_+rD_+rF_
              pop       r9
              glo       re
              rtn

              endp

