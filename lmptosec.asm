.list

#include      macros.inc

; *****************************************
; ***** Convert lump to sector number *****
; ***** R8:R7 - Lump                  *****
; ***** Returns:                      *****
; *****   R8:R7 - Sector number       *****
; *****************************************
              proc      lmptosec

              ldi       3              ; need to perform 3 shifts
              plo       re             ; use re.0 for the counter
loop:         glo       r7             ; shift 32-bit value
              shl
              plo       r7
              ghi       r7
              shlc
              phi       r7
              glo       r8
              shlc
              plo       r8
              ghi       r8
              shlc
              phi       r8
              dec       re             ; decrement shift count
              glo       re             ; see if done
              lbnz      loop           ; loop until done
              rtn                      ; return to caller

              endp

