.list

#include      macros.inc

; *****************************************
; ***** Clear temp blocks from heap   *****
; ***** R9 must be $501               *****
; *****************************************
              proc      reapheap

              extrn   heap
              extrn   hgc
              extrn   save
              extrn   restore

              op2     save,rD_+rF_
              ldi     heap.0              ; need start of heap
              plo     rd
              ldi     heap.1
              phi     rd
              lda     rd                  ; retrieve heap start address
              phi     rf
              ldn     rd
              plo     rf
hpcull_lp:    ldn     rf                  ; get flags byte
              lbnz    next
              op2     restore,rD_+rF_
              lbr     hgc                 ; garbage collect the heap
next:         ani     4                   ; check for permanent block
              lbnz    hpcull_nx           ; jump if allocated and permanent
              ldi     1                   ; mark block as free
              str     rf
hpcull_nx:    inc     rf                  ; get block size
              lda     rf
              plo     re
              lda     rf
              str     r2                  ; and add to pointer
              glo     rf
              add
              plo     rf
              glo     re
              str     r2
              ghi     rf
              adc
              phi     rf
              lbr     hpcull_lp           ; loop until end of heap

              endp

