.list

#include      macros.inc

; *****************************************
; ***** Read lump                     *****
; ***** R8:R7 - Lump                  *****
; ***** Returns:                      *****
; *****   R8:R7 - New lump            *****
; *****************************************
              proc      readlump

              extrn     lmptosecofs
              extrn     readsyssec
              extrn     dta
              extrn     fstype
              extrn     save
              extrn     restore

              op2       save,rC_
              mov       rc,fstype      ; need to get fstype
              ldn       rc             ; retrieve it
              stxd                     ; save for now
              call      lmptosecofs    ; convert lump to LAT sec:ofs
              op2       save,rC_       ; save offset
              call      readsyssec     ; read LAT sector
              op2       restore,rC_    ; recover offset
              glo       rc             ; add in dta address
              adi       dta.0
              plo       rc
              ghi       rc
              adci      dta.1
              phi       rc             ; R9 now points to entry
              irx                      ; recover fstype
              ldx
              smi       1
              lbnz      type2          ; jump if not type 1
              ldi       0              ; high word is zero
              phi       r8
              plo       r8
getlow:       lda       rc             ; retrieve lump
              phi       r7
              lda       rc
              plo       r7
              op2       restore,rC_
              rtn                      ; return to caller
type2:        lda       rc             ; retrieve high word
              phi       r8
              lda       rc
              plo       r8
              lbr       getlow         ; then get low

              endp

