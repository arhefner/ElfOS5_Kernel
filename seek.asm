.list

#include      macros.inc

; *****************************************
; ***** Seek                          *****
; ***** RD - fildes                   *****
; ***** R8:R7 - Seek position         *****
; *****    RC - 0 - from beginning    *****
; *****         1 - from current      *****
; *****         2 - from end          *****
; ***** Returns: DF=0 - Successful    *****
; *****          R8:R7 - position     *****
; *****          DF=1 - Error         *****
; *****             D - Error code    *****
; *****************************************
              proc      seek

              extrn     readlump
              extrn     checkwrite
              extrn     readsyssec
              extrn     loaddirent
              extrn     allocau
              extrn     writelump
              extrn     lmptosec
              extrn     d_ideread
              extrn     setfileflags
              extrn     save
              extrn     restore
              extrn     setr8r7_rd
              extrn     fdadd
              extrn     fdsub
              extrn     seekend
              extrn     finalau

              op2       save,rA_+rB_+rC_

              call      checkwrite     ; check if write needs to occur
              glo       rc             ; check mode 0
              lbz       continue       ; from beginnign of file
              smi       1              ; check for mode 1
              lbz       current        ; from current position
              smi       1              ; check for mode 2
              lbz       fromend        ; from end of file
              ldi       09             ; signal invalid option
              smi       0              ; signal an error
              rtn                      ; and return to caller

fromend:      op2       save,r7_+r8_   ; save offset
              call      seekend        ; find end of file
              op2       restore,r7_+r8_ ; recover offset
              glo       r7             ; add to file size
              str       r2
              glo       ra
              add 
              plo       r7
              ghi       r7
              str       r2
              ghi       ra
              adc
              phi       r7
              glo       r8
              str       r2
              glo       rb
              adc
              plo       r8
              ghi       r8
              str       r2
              ghi       rb
              adc
              phi       r8
              lbr       continue       ; and continue

current:      inc       rd             ; move to lsb of pos
              inc       rd
              inc       rd
              ldn       rd             ; get byte
              dec       rd
              str       r2
              glo       r7 
              add
              plo       r7
              ldn       rd             ; get byte
              dec       rd
              str       r2
              ghi       r7 
              adc
              phi       r7
              ldn       rd             ; get byte
              dec       rd
              str       r2
              glo       r8 
              adc
              plo       r8
              ldn       rd             ; get byte
              str       r2
              ghi       r8 
              adc
              phi       r8             ; r8:r7 now has final offset
              lbr       continue       ; continue

continue:     ghi       r8             ; r8:r7 has final position
              shl                      ; check for negative offset
              lbnf      good           ; jump if positive offset
              ldi       6              ; signal error
              smi       0
return:       op2       restore,rA_+rB_+rC_
              glo       re
              rtn
good:         op        setr8r7_rd     ; write new position to fildes
              push      rd             ; save fildes
              ldi       0              ; indicate no change in EOF
              stxd
              op2       save,r7_+r8_
              ldi       1              ; load dirent, setting R8:r7 to inital AU
              call      loaddirent
              op2       restore,rC_+rD_ ; recover position
seekloop:     ghi       rc             ; see if count < 4096
              smi       010h
              glo       rd
              smbi      0
              ghi       rd
              smbi      0
              lbnf      seekdone       ; jump if no more lumps to read
              mov       rb,r8          ; save current lump
              mov       ra,r7
              call      readlump       ; read in next lump
              op        finalau        ; see if on final lump
              lbnf      noappend       ; jump if not on final lump
              call      allocau        ; allocate another au
              mov       rf,r8          ; swap new with current
              mov       r8,rb
              mov       rb,rf
              mov       rf,r7
              mov       r7,ra
              mov       ra,rf
              call      writelump      ; write new lump
              irx                      ; update flag for appended lump
              ldi       1
              stxd
              mov       r8,rb          ; move new lump to current
              mov       r7,ra
noappend:     ghi       rc             ; subtract 4096 from pos
              smi       010h
              phi       rc
              glo       rd
              smbi      0
              plo       rd
              ghi       rd
              smbi      0
              phi       rd
              lbr       seekloop       ; loop to check next lump

seekdone:     ghi       rc             ; keep only low 12 bits of post
              ani       0fh
              phi       rc
              irx                      ; recover append flag
              ldx 
              plo       re             ; set aside for a moment
              pop       rd             ; recover fildes
              push      rd             ; and keep on stack
              glo       re
              op2       fdadd,6        ; move rd to EOF
              glo       re             ; check append flag
              lbz       notappend      ; jump if file was not appended
              ldi       0              ; clear EOF
              str       rd
              inc       rd
              str       rd
              inc       rd
              ldn       rd             ; get file flags
              ori       010h           ; indicate file was modified
              str       rd             ; and write back
              dec       rd             ; move back to eof
              dec       rd
notappend:    inc       rd             ; move to lsb of eof
              op2       save,r7_+r8_   ; save consumed registers
              call      readlump       ; need to see if in final lump
              op        finalau        ; see if final au
              shlc                     ; save df
              op2       restore,r7_+r8_ ; restore lump
              glo       re              ; now check for final lump
              shr
              lbnf      nochange        ; jump if not in last lump
              glo       rc             ; subtract pos from eof
              str       r2
              ldn       rd
              sm
              dec       rd
              ghi       rc
              str       r2
              lda       rd
              smb
              lbdf      nochange       ; jump if no change to EOF
              dec       rd
              ghi       rc             ; write new EOF
              str       rd
              inc       rd
              glo       rc
              str       rd
              inc       rd             ; point to flags
              ldn       rd             ; retrieve them
              ori       010h           ; indicate file is modified
              str       rd             ; and write back
              dec       rd
nochange:     dec       rd
              call      lmptosec       ; convert lump to sector number
              ghi       rc             ; need to get sector number
              shr
              ani       7              ; keep only bottom 7 bits
              str       r2             ; need to combine with sector
              glo       r7
              or
              plo       r7             ; r8:r7 now has actual sector
              op2       fdadd,9        ; move to sector field
              op        setr8r7_rd     ; store sector
              op2       fdsub,11       ; point to DTA
              lda       rd             ; retrieve DTA
              phi       rf
              ldn       rd
              plo       rf
              call      d_ideread      ; read the sector
              pop       rd             ; recover rd
              call      setfileflags   ; set file flags
              adi       0              ; indicate no errors
              lbr       return         ; and return




             

              endp

