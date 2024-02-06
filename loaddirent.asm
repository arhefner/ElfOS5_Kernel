.list

#include      macros.inc

; *******************************************
; ***** Load directory entry for fildes *****
; ***** RD - fildes                     *****
; *****  D - Flags                      *****
; *****      1 - read AU into r8:r7     *****
; ***** Returns: Dir sector in sys DTA  *****
; *****          RA - offset in sector  *****
; *******************************************
              proc      loaddirent

              extrn     readsyssec

              stxd                     ; save flags
              glo       rd             ; need to point to directory sector
              adi       9
              plo       ra
              ghi       rd
              adci      0
              phi       ra             ; r7 now pointing to directory sector
              lda       ra             ; retrieve it
              phi       r8
              lda       ra
              plo       r8
              lda       ra
              phi       r7
              lda       ra
              plo       r7
              lda       ra             ; get dir offset
              adi       1              ; add in DTA offset
              plo       re
              lda       ra
              plo       ra
              glo       re
              phi       ra
              call      readsyssec     ; read directory sector
              irx                      ; recover flags
              ldx
              shr
              lbnf      return         ; jump if no request to read data
              lda       ra             ; read initial AU
              phi       r8
              lda       ra
              plo       r8
              lda       ra
              phi       r7
              lda       ra
              plo       r7             ; r8:r7 now have first lump
              lda       ra
              phi       rf
              ldn       ra
              plo       rf
              dec       ra
              dec       ra
              dec       ra
              dec       ra
              dec       ra
return:       rtn                      ; and return

              endp

