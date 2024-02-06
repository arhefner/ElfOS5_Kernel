#include      macros.inc
#include      bios.inc

; **************************************
; ***** RD Pointer to OCB          *****
; ***** RF Pointer to overlay name *****
; ***** Returns: DF=0 - Success    *****
; *****          DF=1 - Error      *****
; *****             D - Error code *****
; **************************************
              proc      loadover

              extrn     helpers
              extrn     save
              extrn     restore
              extrn     fdadd
              extrn     incsec
              extrn     d_ideread
              extrn     lmptosec
              extrn     sectolmp
              extrn     readlump
              extrn     finalau

              push      r9             ; save consumed register
              mov       r9,helpers
              op2       save,r7_+r8_+rC_+rD_+rF_
              op2       fdadd,3        ; need symbol table
              lda       rd
              phi       r7
              ldn       rd
              plo       r7
              dec       rd             ; point to RAM area
              dec       rd
              dec       rd
              push      rd             ; save descriptor
              call      f_findtkn      ; find entry in table
              mov       rc,rd          ; move result
              pop       rd             ; and recover rd
              lbdf      found          ; jump if found
              smi       0              ; indicate error
              ldi       016h
return:       op2       restore,r7_+r8_+rC_+rD_+rF_
              pop       r9
              glo       re
              rtn
loadovly:
found:        lda       rd             ; get RAM address
              phi       rf
              lda       rd
              plo       rf
              op2       fdadd,4        ; move to beginnig of table
              ldi       3              ; 8 bytes per entry
              plo       re
mulloop:      glo       rc             ; multiply by 2
              shl
              plo       rc
              ghi       rc
              shlc
              phi       rc
              dec       re             ; decrement count
              glo       re             ; see if done
              lbnz      mulloop
              glo       rd             ; now add to table address
              str       r2
              glo       rc
              add
              plo       rd
              ghi       rd
              str       r2
              ghi       rc
              adc
              phi       rd             ; now pointing at entry
              lda       rd             ; retreive physcial sector
              phi       r8
              lda       rd
              plo       r8
              lda       rd
              phi       r7
              lda       rd
              plo       r7
              inc       rd             ; move past sector offset
              inc       rd
              inc       rd
              lda       rd             ; retrieve count of sectors to load
              plo       rc             ; place into count
              ghi       r8
              ani       0fh
              ori       0e0h
loadloop:     glo       rc             ; see if done
              lbz       loaddone       ; jump if so
              call      d_ideread      ; read next sector
              glo       r7             ; see if end of lump
              ani       7
              smi       7
              lbnz      inconly        ; jump if only need to increment
              call      sectolmp       ; get current lump
              call      readlump       ; read next lump
              op        finalau        ; see if was in final au
              lbdf      pastend        ; jump on error
              call      lmptosec       ; convert new lump to sector
              lbr       continue       ; then continue
pastend:      smi       0              ; signal an error
              ldi       015h
              lbr       return         ; and return
inconly:      op        incsec         ; increment sector
continue:     dec       rc             ; decrement sector count
              lbr       loadloop       ; load until done
loaddone:     adi       0              ; signal no errors
              lbr       return         ; and return

              public    loadovly

              endp


