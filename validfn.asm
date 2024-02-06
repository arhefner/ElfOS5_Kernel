.list

#include      macros.inc

; *******************************************
; ***** Check path for valid characters *****
; ***** RF - pointer to path            *****
; ***** Returns: DF=0 path is valid     *****
; *****          DF-1 path is invalid   *****
; *******************************************
              proc      validfn

              extrn     validchar

              push      rf             ; save path
loop:         lda       rf             ; get byte from path
              lbz       done           ; jump if terminator found

              call      validchar      ; check for valid character
              lbnf      loop           ; loop if character is good

               lbdf      nogood        ; jump if bad character

;              smi       '$'            ; check for dollar sign
;              lbz       loop           ; valid character
;              smi       9              ; check if below '-'
;              lbnf      nogood         ; jump if so
;              smi       13             ; check for -,.,/,0-9
;              lbnf      loop           ; jump if so
;              smi       7              ; check if below UC
;              lbnf      nogood
;              smi       26             ; check for UC
;              lbnf      loop
;              smi       4              ; check for _
;              lbz       loop
;              smi       2              ; check for below LC
;              lbnf      nogood
;              smi       26             ; check for lc
;              lbnf      loop
nogood:       pop       rf             ; recover original pointer
              smi       0              ; signal invalid filename
              rtn                      ; and return
done:         pop       rf             ; recover original pointer
              adi       0              ; signal valid filename
              rtn                      ; and return

              endp

