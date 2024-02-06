.list

#include      macros.inc

; **************************************
; ***** Consilidate free blocks on *****
; ***** heap                       *****
; **************************************

              proc      hgc

              extrn     heap
              extrn     save
              extrn     restore
              extrn     updhimem

              op2       save,rA_+rF_
              mov       ra,heap        ; point to heap address
              lda       ra             ; retrieve start of heap
              plo       re             ; save for a moment
              ldn       ra
              plo       ra             ; set RA to start of heap
              glo       re
              phi       ra             ; RA now points to start of heap
loop:         ldn       ra             ; get header byte
              lbz       done1          ; jump if end of heap
              ani       3              ; keep only bottom 2 bits
              smi       2              ; see if allocated
              lbnz      free           ; Jump if current block is used
              call      skip           ; skip to next header
              lbr       loop           ; check next header
free:         inc       ra             ; point to size
              lda       ra             ; retrieve msb of size
              stxd                     ; store for add
              ldn       ra             ; get lsb of size
              str       r2             ; store for add
              glo       ra             ; add size to position
              add
              plo       rf             ; put into rf
              irx                      ; point to lsb
              ghi       ra             ; and add to pointer
              adc
              phi       rf
              inc       rf             ; RF now points to next header
              ldn       rf             ; get header byte
              smi       1              ; is it a free block
              lbnz      notfree        ; jump if not
              inc       rf             ; point to block size
              lda       rf             ; retrieve it
              stxd                     ; store for add
              ldn       rf             ; get lsb
              str       r2
              ldn       ra             ; retrieve lsb of first block
              add                      ; add in second block size
              plo       rf             ; put here for now
              dec       ra             ; point to msb
              lda       ra             ; retrieve it
              irx                      ; point to msb of second block size
              adc
              phi       rf             ; rf now has combines sizes
              inc       rf             ; plus 3 for deleted header
              inc       rf
              inc       rf
              glo       rf             ; store new size into first block
              str       ra
              dec       ra
              ghi       rf
              str       ra
              dec       ra
              lbr       loop           ; and loop back for next block
notfree:      mov       ra,rf          ; move next header address into current
              lbr       loop           ; and check next entry
done1:        mov       rf,heap        ; point to heap address
              lda       rf             ; retrieve it
              phi       ra             ; into RA
              ldn       rf
              plo       ra             ; RA now points to start of heap
loop2:        ldn       ra             ; get byte from header
              smi       1              ; check if free block
              lbnz      done2          ; jump if now
              call      skip           ; skip to next block
              lbr       loop2          ; loop until no more free blocks
done2:        glo       ra             ; store new start of heap
              str       rf
              dec       rf
              ghi       ra
              str       rf
              call      updhimem
              op2       restore,rA_+rF_
              rtn                      ; and return to caller

skip:         inc       ra             ; point to msb of size
              lda       ra             ; retrieve it
              stxd                     ; place on stack
              lda       ra             ; get lsb
              str       r2             ; store for add
              glo       ra             ; add size to current address
              add
              plo       ra
              irx
              ghi       ra
              adc
              phi       ra             ; RA now points to next header
              rtn                      ; return to caller

              endp

