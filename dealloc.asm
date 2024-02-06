.list

#include      macros.inc

; **************************************
; ***** Deallocate memory          *****
; ***** RF - address to deallocate *****
; **************************************

              proc      dealloc

              extrn     hgc
              extrn     helpers

              push      r9
              mov       r9,helpers
              dec       rf             ; point to header
              dec       rf
              dec       rf
              ldi       1              ; indicate block is free
              str       rf
              inc       rf             ; restore rf
              inc       rf
              inc       rf
              call      hgc            ; perform garbage collection
              pop       r9
              rtn

              endp

