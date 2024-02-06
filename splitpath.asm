.list

#include      macros.inc

; ********************************************
; ***** Slit path                        *****
; ***** RF - full path                   *****
; ***** Returns: DF=0 - No directory     *****
; *****            RA - Pointer to name  *****
; *****            RF - Pointer to dir   *****
; *****          DF=1 - Dir valid        *****
; ********************************************
              proc      splitpath

              extrn     scratch

              ldn       rf             ; check for null name
              lbz       error          ; jump if null name
              mov       ra,scratch     ; point to scratch space
              ldi       0              ; character count
              plo       re
loop:         lda       rf             ; get byte from source path
              str       ra             ; write to scracth
              smi       32             ; was it a space
              lbz       space          ; jump if so
              ldn       ra
              inc       ra
              lbz       copydn         ; jump if done copying
              inc       re             ; increment count
              glo       re             ; check length
              smi       128
              lbnz      loop           ; jump if not too many
error:        ldi       011h           ; indicate invalid name
              smi       0              ; signal error
              rtn                      ; and return to caller
space:        ldi       0              ; terminate name
              str       ra
              inc       ra
copydn:       dec       ra             ; move back to final character
              dec       ra
              dec       re             ; decrement count
dirlp:        glo       re             ; see if at beginning
              lbz       nodir          ; jump if no directory
              ldn       ra             ; get byte
              smi       '/'            ; check for slash
              lbz       isdir          ; jump if directory
              dec       ra             ; move to prior character
              dec       re             ; decrement count
              lbr       dirlp          ; and keep looking
nodir:        adi       0              ; signal no directory
              rtn                      ; and return
isdir:        ldi       0              ; terminate directory
              str       ra
              inc       ra             ; point ra back to name
              mov       rf,scratch     ; point to directory name
              smi       0              ; signal directory present
              rtn                      ; and return

              endp

