.list

#include      macros.inc

; ******************************************
; ***** Search directorr for name      *****
; ***** RF - pointer to name to find   *****
; ***** R8:R7 - first lump of dir      *****
; ***** Returns: DF=0 - Entry found    *****
; *****          RA   - Address in DTA *****
; ******************************************
              proc      searchdir

              extrn     dta
              extrn     readsyssec
              extrn     lmptosec
              extrn     readlump
              extrn     helpers
              extrn     save
              extrn     restore
              extrn     finalau

              op2       save,r7_+r8_+rB_+rC_+rF_
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
              inc       rc             ; point to filename
              inc       rc
              inc       rc
              inc       rc
              inc       rc
              inc       rc
              inc       rc
              inc       rc
              op2       save,rF_       ; save name position
nloop:        lda       rc             ; character from fildes
              lbz       term           ; jump if terminator
              str       r2             ; store for compare
              plo       re             ; keep a copy
              lda       rf             ; get byte from search name
              sm                       ; and compare
              lbnz      nope           ; jump if not
              glo       re             ; get last character
              lbnz      nloop          ; loop until terminator
found:        op2       restore,rF_    ; recover name
              op2       restore,rA_    ; pop address of dirent
              adi       0              ; indicate no error
exit:         op2       restore,r7_+r8_+rB_+rC_+rF_
              glo       re
              rtn                      ; and return to caller
term:         ldn       rf             ; see if end of name
              lbz       found          ; if so, then found
              smi       32             ; space also terminates name
              lbz       found
nope:         op2       restore,rF_    ; recover name address
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
              op        finalau        ; see if in final lump
              lbnf      notfinal       ; jump if not
              smi       0              ; indicate name was not found
              ldi       0ch
              lbr       exit           ; and return to caller
notfinal:     mov       rb,r8          ; move lump to find next one
              mov       ra,r7
              lbr       oloop          ; and process next lump

              endp



; R8:R7   - Sector
; RB:RA   - Next
; RC      - POS
; RF      - Name to search


