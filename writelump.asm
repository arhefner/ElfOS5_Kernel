.list

#include      macros.inc

; *****************************************
; ***** Write lump                    *****
; ***** R8:R7 - Lump                  *****
; ***** RB:RA - value                 *****
; *****************************************
              proc      writelump

              extrn     lmptosecofs
              extrn     readsyssec
              extrn     writesyssec
              extrn     dta
              extrn     fstype
              extrn     save
              extrn     restore

              op2       save,r7_+r8_+rC_
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
writelow:     ghi       ra             ; write low word
              str       rc
              inc       rc
              glo       ra
              str       rc 
              call      writesyssec    ; write sector back to disk
              op2       restore,r7_+r8_+rC_
              rtn                      ; return to caller
type2:        ghi       rb             ; write high word
              str       rc
              inc       rc
              glo       rb
              str       rc
              inc       rc
              lbr       writelow       ; then write low word

              endp

