.list

#include      macros.inc

; *****************************************
; ***** Open file                     *****
; ***** RF - point to path            *****
; ***** RD - fildes                   *****
; ***** R7 - Flags                    *****
; ***** Returns: DF=0 - Successful    *****
; *****          DF=1 - Error         *****
; *****             D - Error code    *****
; *****************************************
              proc      open

              extrn     validfn
              extrn     finddirent
              extrn     setfildes
              extrn     readlump
              extrn     writelump
              extrn     delchain
              extrn     seek
              extrn     create
              extrn     helpers
              extrn     save
              extrn     restore
              extrn     startingau
              extrn     finalau
              extrn     sectolmp
              extrn     fdsub
              extrn     fdadd
              extrn     getdeflags
              extrn     getfdflags
              extrn     setfdflags

              push      r9
              mov       r9,helpers
              op2       save,r7_+r8_+rA_+rD_+rF_

              call      validfn        ; check for valid filename
              lbnf      valid          ; jump if good
              ldi       011h           ; indicate invalid filename
error:        smi       0              ; indicate error
return:       op2       restore,r7_+r8_+rA_+rD_+rF_
              pop       r9
              glo       re
              rtn                      ; and return to caller
valid:        call      finddirent     ; get directory entry for file
              lbnf      exists         ; jump if the file exists
              glo       r7             ; get open flags
              ani       1              ; check for create
              lbz       nofile         ; jump if no file error
              glo       r7             ; check for executable flag
              ani       8
              lbz       noexec         ; jump if not
              ldi       2              ; file will be executable
              lskp
noexec:       ldi       0              ; nothing special
              call      create         ; create the file
              lbdf      return         ; jump if there was an error
              lbr       exists         ; and then open the file
nofile:       ldi       0ch            ; signal file not found
              lbr       error
exists:       op        getdeflags     ; get file flags
              ani       1              ; check for directory
              lbz       notdir         ; jump if not
              ldi       012h           ; signal attempt to open directory
              lbr       error          ; and return
notdir:       glo       r7             ; get open flags
              stxd                     ; save flags for later
              ani       16             ; check for open for read only
              lsz                      ; jump if not
              ldi       2              ; indicate file opened read only
              call      setfildes      ; setup fildes for file
              irx                      ; recover flags
              ldx
              stxd                     ; keep flags on stack
              ani       2              ; check for truncate flag
              lbz       notruncate     ; jump if no truncation
              
              op2       fdadd,6        ; point to eof
              ldi       0              ; and zero it
              str       rd
              inc       rd
              str       rd
              op2       fdsub,7        ; move pointer back
              op2       save,r7_+r8_+rA_ ; save consumed registers
              call      sectolmp       ; convert sector to lump
              op2       save,r7_+r8_   ; save first lump
              call      readlump       ; read lump value
              op        finalau        ; check for final lump
              lbnf      notfinal       ; jump if not final
              lbr       finallmp
notfinal:     call      delchain
              op2       restore,r7_+r8_ ; recover first lump
              op2       save,rA_+rB_   ; save consumed registers
              ldi       0              ; need to write termination
              phi       rb
              plo       rb
              ldi       0feh
              phi       ra
              plo       ra
              call      writelump      ; write to lump
              op2       restore,rA_+rB_ ; recover consumed registers
              lbr       donetrunc      ; done with truncation
finallmp:     irx                      ; remove first lump from stack
              irx
              irx
              irx
donetrunc:    op2       restore,r7_+r8_+rA_ ; recover consumed registers
              op        getfdflags     ; get flags from FILDES
              ori       084h           ; inidicate last lump, last sector
              op        setfdflags     ; and put it back

notruncate:   irx                      ; recover flags
              ldx
              ani       4              ; check for append
              lbz       allgood        ; jump if not
              push      r7             ; save consumed registers

              push      r8
              glo       rc
              stxd
              ldi       0              ; seek offset 0
              phi       r8
              plo       r8
              phi       r7
              plo       r7
              ldi       2              ; from end of file
              plo       rc
              call      seek
              irx                      ; recover consumed registers
              ldx
              plo       rc
              pop       r8
              pop       r7

allgood:      adi       0              ; signal no errors
              lbr       return

              endp

