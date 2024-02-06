.list

#include      macros.inc

; *******************************************
; ***** Check path for valid characters *****
; ***** D - Character to check          *****
; ***** Returns: DF=0 char is valid     *****
; *****          DF-1 char is invalid   *****
; *******************************************
              proc      validchar

              plo       re             ; save character
              lbz       nogood         ; jump if terminator found
              smi       '$'            ; check for dollar sign
              lbz       good           ; valid character
              smi       9              ; check if below '-'
              lbnf      nogood         ; jump if character is invalid
              smi       13             ; check for -,.,/,0-9
              lbnf      good           ; jump if in range
              smi       7              ; check if below UC
              lbnf      nogood         ; jump if no good
              smi       26             ; check for uc letter
              lbnf      good           ; valid if so
              smi       4              ; check for _
              lbz       good           ; jump if so
              smi       2              ; check if below lc
              lbnf      nogood         ; jump if invalid
              smi       26             ; check for lc letter
              lbnf      good           ; keep checking if so
nogood:       smi       0              ; signal invalid filename
              glo       re             ; recover character
              rtn                      ; and return
good:         adi       0              ; signal valid filename
              glo       re             ; recover character
              rtn                      ; and return

              endp

