.list

#include      macros.inc
#include      bios.inc

; ********************************************
; ***** Find sector                      *****
; ***** R8:R7 - initial AU               *****
; ***** RB:RA - Sector number            *****
; ***** Returns: DF=0 - no errors        *****
; *****          R8:R7 - Physcial sector *****
; *****          DF=1 - erorr            *****
; ********************************************
              proc      findsec

              extrn     finalau
              extrn     lmptosec
              extrn     readlump

auloop:       glo       ra             ; see if in final lump
              ani       0f8h           ; keep only lump number
              str       r2
              ghi       ra
              or
              str       r2
              glo       rb
              or
              str       r2
              ghi       rb
              or
              lbz       final          ; jump if now in final lump
              glo       ra             ; subtract 8 sectors for lump
              smi       8
              plo       ra
              ghi       ra
              smbi      0
              phi       ra
              glo       rb
              smbi      0
              plo       rb
              ghi       rb
              smbi      0
              phi       rb
              call      readlump       ; read next lump
              op        finalau        ; see if final au
              lbnf      auloop         ; keep searching if not
              smi       0              ; otherwise error
              ldi       015h
              rtn                      ; and return
final:        call      lmptosec       ; convert lump to sector
              glo       ra             ; add in remaining sector number
              str       r2
              glo       r7
              add
              plo       r7
              ghi       r7
              adci      0
              phi       r7
              glo       r8
              adci      0
              plo       r8
              ghi       r8
              adci      0
              phi       r8
              adi       0              ; signal no errors
              rtn                      ; and return to caller

              endp
