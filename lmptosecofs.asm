.list

#include      macros.inc

; *****************************************
; ***** Convert lump to sector number *****
; ***** R8:R7 - Lump                  *****
; ***** Returns:                      *****
; *****   R8:R7 - LAT Sector number   *****
; *****      RC - LAT Offset          *****
; *****************************************
              proc      lmptosecofs

              extrn     fstype

              mov       rc,fstype      ; need to get file system type
              ldn       rc             ; retrieve it
              smi       2              ; check for type 2
              lbz      type2           ; jump if type 2
              glo       r7             ; get low byte of lump number
              shl                      ; multiply by 2
              plo       rc             ; and place into ra
              ldi       0              ; propagate carry to high byte
              plo       re             ; need this for later
              shlc
              phi       rc             ; R9 now has LAT offset
shift:        ghi       r7             ; shift lump number left 8 bits
              adi       17             ; add 17 while shifting the bits
              plo       r7
              glo       r8
              adci      0              ; propagate carry
              phi       r7
              ghi       r8
              adci      0              ; propagate carry
              plo       r8
              glo       re             ; get final bit
              adci      0              ; propagate carry
              phi       r8
              rtn                      ; return to caller

type2:        glo       r7             ; need low 7 bits of lump
              ani       $7f
              shl                      ; multiplied by 2
              shl                      ; multiplied by 4
              plo       rc
              ldi       0              ; propagate carry
              shlc
              phi       rc             ; RC now has LAT offset
              glo       r7             ; shift lump left 1 bit
              shl
              ghi       r7
              shlc
              phi       r7
              glo       r8
              shlc
              plo       r8
              ghi       r8
              shlc
              phi       r8
              ldi       0
              shlc
              plo       re
              lbr       shift          ; now perform final shift and add

              endp

