.list

#include      macros.inc

; *****************************************
; ***** Convert sector to lump number *****
; ***** R8:R7 - Sector                *****
; ***** Returns:                      *****
; *****   R8:R7 - Lump number         *****
; *****************************************
              proc      sectolmp

              ldi       3              ; need to perform 3 shifts
              plo       re             ; use re.0 for the counter
loop:         ghi       r8             ; shift 32-bit value
              shr
              phi       r8
              glo       r8
              shrc
              plo       r8
              ghi       r7
              shrc
              phi       r7
              glo       r7
              shrc
              plo       r7
              dec       re             ; decrement shift count
              glo       re             ; see if done
              lbnz      loop           ; loop until done
              rtn                      ; return to caller

              endp

