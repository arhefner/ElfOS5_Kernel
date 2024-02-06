.list

#include      macros.inc

; ******************************************
; ***** Search directorr for empty     *****
; ***** R8:R7 - first lump of dir      *****
; ***** Returns: DF=0 - Dir is empty   *****
; *****          DF=1 - Not empty      *****
; ******************************************
              proc      dirempty

              extrn     dta
              extrn     readsyssec
              extrn     lmptosec
              extrn     readlump
              extrn     save
              extrn     restore
              extrn     finalau

              op2       save,r7_+r8_+rA_+rB_+rC_
oloop:        mov       rb,r8          ; copy lump
              mov       ra,r7
              call      lmptosec       ; convert lump to sector
seconly:      call      readsyssec     ; read directory sector
              mov       rc,dta         ; point to DTA
iloop:        op2       save,rC_       ; save DTA position
              lda       rc             ; see if lump is non-zero
              str       r2
              lda       rc
              or
              str       r2
              lda       rc
              or
              str       r2
              lda       rc
              or
              lbz       iszero         ; jump if non-allocated entry 
              irx                      ; remove rc from stack
              irx
              smi       0              ; indicate dir is not empty
exit:         op2       restore,r7_+r8_+rA_+rB_+rC_
              rtn                      ; and return to caller
iszero:       op2       restore,rC_    ; recover DTA position
              glo       rc             ; point to next entry
              adi       32
              plo       rc
              ghi       rc             ; propagat carry
              adci      0
              phi       rc
              smi       3              ; check for end of DTA
              lbnz      iloop          ; jump if not
              inc       r7             ; increment sector
              glo       r7             ; check for roll
              str       r2
              ghi       r7
              or
              lsnz                     ; jump if no roll
              inc       r8             ; otherwise increment high word
              nop                      ; padding for the long skip
              glo       r7             ; need to see if still in lump
              ani       7              ; 8 sectors per lump
              lbnz      seconly        ; still in lump, so read next sector
              mov       r8,rb          ; move lump to find next one
              mov       r7,ra
              call      readlump       ; read next lump
              op        finalau        ; see if in final au
              lbnf      notfinal       ; jump if not final lump
              adi       0              ; indicate name was not found
              lbr       exit           ; and return to caller
notfinal:     mov       rb,r8          ; move lump to find next one
              mov       ra,r7
              lbr       oloop          ; and process next lump

              endp



; R8:R7   - Sector
; RB:RA   - Next
; RC      - POS
; RF      - Name to search


