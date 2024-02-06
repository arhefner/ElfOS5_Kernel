.list

#include      macros.inc

; ********************************************
; ***** Search directorr for empty entry *****
; ***** R8:R7 - first lump of dir        *****
; ***** Returns: DF=0 - Dir is empty     *****
; *****            RA - Address of entry *****
; *****          DF=1 - Disk full        *****
; ********************************************
              proc      freedirent

              extrn     dta
              extrn     readsyssec
              extrn     writesyssec
              extrn     lmptosec
              extrn     readlump
              extrn     writelump
              extrn     allocau
              extrn     zerolump
              extrn     save
              extrn     restore

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
              lbnz      notzero        ; jump if allocated entry 
              op2       restore,rA_    ; recover address
              adi       0              ; indicate entry found
              rtn                      ; and return to caller
notzero:      op2       restore,rC_    ; recover DTA position
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
              ghi       r8             ; were we in final lump
              str       r2
              glo       r8
              or
              lbnz      notfinal       ; jump if not final lump
              ghi       r7
              smi       0feh
              lbnz      notfinal
              glo       r7
              smi       0feh
              lbz       append         ; need to append new lump
notfinal:     mov       rb,r8          ; move lump to find next one
              mov       ra,r7
              lbr       oloop          ; and process next lump
append:       call      allocau        ; get a free au
              lbnf      noerror        ; jump if no error
              rtn                      ; return with error to caller
noerror:      call      zerolump       ; clear new lump
              op2       save,rA_+rB_   ; save old lump
              mov       rb,r8          ; move new lump
              mov       ra,r7
              op2       restore,r7_+r8_ ; recover old lump
              call      writelump      ; write new lump to end of chain

              mov       r8,rb          ; need to get starting sector now
              mov       r7,ra
              call      lmptosec       ; convert lump to sector

              call      readsyssec     ; and read it
              mov       ra,0           ; new entry is first entry in sector
              adi       0              ; indicate success
              rtn                      ; and return to caller

              endp



; R8:R7   - Sector
; RB:RA   - Next
; RC      - POS
; RF      - Name to search


