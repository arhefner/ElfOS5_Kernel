.list

#include      macros.inc

; *****************************************
; ***** Check fildes to see if        *****
; ***** current sector needs writing  *****
; ***** RD - fildes                   *****
; *****************************************
              proc      checkwrite

              extrn     d_idewrite
              extrn     save
              extrn     restore

              op2       save,r7_+r8_+rD_+rF_
              inc       rd             ; move to DTA
              inc       rd
              inc       rd
              inc       rd
              lda       rd             ; get DTA
              phi       rf
              lda       rd
              plo       rf
              inc       rd             ; move past EOF
              inc       rd
              ldn       rd             ; retrieve flags
              ani       1              ; see if sector needs writing
              lbnz      needwrite      ; jump if write is needed
return:       op2       restore,r7_+r8_+rD_+rF_
              rtn                      ; return to caller
needwrite:    ldn       rd             ; recover flags
              ani       0feh           ; clear sector written flag
              str       rd
              inc       rd             ; move to sector field
              inc       rd
              inc       rd
              inc       rd
              inc       rd
              inc       rd
              inc       rd
              lda       rd             ; retrieve sector
              phi       r8
              lda       rd
              plo       r8
              lda       rd
              phi       r7
              ldn       rd
              plo       r7
              call      d_idewrite     ; write sector to disk
              lbr       return         ; and return to caller

              endp

