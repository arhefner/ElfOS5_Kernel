.list

#include      macros.inc

; *****************************************
; ***** extend file                   *****
; ***** RD - fildes                   *****
; ***** Returns: R8:R7 - Final AU     *****
; *****          RB:RA - size         *****
; *****************************************
              proc      extendfile

              extrn     save
              extrn     restore
              extrn     seekend
              extrn     allocau
              extrn     writelump
              extrn     fdadd

              op2       save,r7_+r8_+rA_+rB_+rD_+rF_
              call      seekend        ; get last AU of file
              op2       save,r7_+r8_   ; save last lump
              call      allocau        ; allocate an AU
              lbnf      allocated      ; jump if no error
              op2       restore,r7_+r8_
return:       op2       restore,r7_+r8_+rA_+rB_+rD_+rF_
              glo       re
              rtn
allocated:    mov       rb,r8          ; move new lump
              mov       ra,r7
              op2       restore,r7_+r8_ ; recover final lump
              call      writelump      ; and write new lump to it
              op2       fdadd,6        ; move to EOF of fildes
              ldi       0              ; and zero it
              str       rd
              inc       rd
              str       rd
              inc       rd
              ldn       rd             ; retrieve flags
              ani       07bh           ; clear last sector, last lump
              ori       16             ; indicate file is altered
              str       rd             ; write flags back
              adi       0              ; signal no error
              lbr       return         ; and return to caller

              endp

