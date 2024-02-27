.list

#include      macros.inc

; ************************************************
; ***** Create new file                      *****
; ***** RF - name                            *****
; *****  D - Flags                           *****
; ***** Returns: DF=0 - entry found          *****
; *****          RA   - Address of dirent    *****
; *****          DF=1 - Not found            *****
; ************************************************
              proc      create

              extrn     validfn
              extrn     finddirent
              extrn     splitpath
              extrn     writelump
              extrn     freedirent
              extrn     allocau
              extrn     savesyssec
              extrn     zerolump
              extrn     lastsec
              extrn     readsyssec
              extrn     setdatetime
              extrn     opencd
              extrn     openmd
              extrn     helpers
              extrn     save
              extrn     restore
              extrn     startingau

              plo       re             ; set flags aside (REVISIT!!!)
              op2       save,r7_+r8_+rB_+rC_+rF_
              glo       re
              stxd                     ; save flags to stack
              call      validfn        ; check for valid path name
              lbdf      invalid        ; jump if invalid name
              call      finddirent     ; find dirent for file
              lbdf      good           ; jump if entry was not found
              ldi       0eh            ; signal error
              smi       0
              irx
return:       op2       restore,r7_+r8_+rB_+rC_+rF_
              glo       re
              rtn                      ; return error
good:         call      splitpath      ; separate dir and filename
              ldn       ra             ; get first byte of name
              lbnz      valid          ; jump if filename is not null
invalid:      ldi       011h           ; signal bad filename
              smi       0              ; indicate an error
              lbr       return         ; return to caller
valid:        lbnf      current        ; jump if no directory specified
              ldn       rf             ; get first byte of directory
              lbz       master         ; jump if no actual directory
              op2       save,rA_       ; save name position
              call      finddirent     ; search for directory
              lbnf      dirfound       ; jump if directory is found
              irx                      ; remove ra from stack
              irx
              irx
              lbr       return         ; return to caller
dirfound:     op        startingau     ; read directory starting lump
              op2       restore,rF_    ; recover name address
              lbr       go             ; and create it
master:       call      openmd         ; open master directory
              lbr       go             ; and create the file
current:      call      opencd         ; open current directory
              mov       rf,ra          ; move name to rf

go:           op2       save,r7_+r8_   ; save dir lump
              call      allocau        ; get a free AU
              lbnf      gotau          ; jump if acquired an AU
              op2       restore,r7_+r8_ ; recover values
              irx                      ; ignore d
gotau:        op2       restore,rA_+rB_ ; recover dir lump
              op2       save,r7_+r8_   ; save new lump
              mov       r8,rb          ; setup for dir search
              mov       r7,ra
              call      freedirent     ; Find a free entry in directory
              lbnf      found          ; jump if found a free entry
              op2       restore,r7_+r8_ ; recover new lump
              ldi       0              ; need to deallocate it
              phi       rb
              plo       rb
              phi       ra
              plo       ra
              call      writelump
              smi       0              ; indicate error occurred
              ldi       0fh            ; indicate disk full
              lbr       return         ; return to caller
found:        op2       restore,r7_+r8_
              irx                      ; recover create flags
              ldx
              op2       save,rA_       ; save address of dirent
              ghi       r8             ; write lump to dirent
              str       ra
              inc       ra
              glo       r8
              str       ra
              inc       ra
              ghi       r7
              str       ra
              inc       ra
              glo       r7
              str       ra
              inc       ra
              glo       re             ; set aside
              shr                      ; are we creating a directory
              lbnf      notdir         ; jump if not
              ldi       0fh            ; dir always has eof at end of final sector
              str       ra
              inc       ra
              ldi       0ffh
              str       ra
              inc       ra
              lbr       continue       ; then continue
notdir:       ldi       0              ; set EOF to beginning byte
              str       ra
              inc       ra
              str       ra
              inc       ra
continue:     glo       re             ; recover flags
              str       ra             ; and store
              inc       ra
              call      setdatetime    ; set date/time for file
              ldi       0
              str       ra
              inc       ra
              ldi       20             ; maximum 20 bytes for filename
              plo       re
fname:        lda       rf             ; get next byte from name
              str       ra             ; write into dirent
              inc       ra
              lbz       fnamedone      ; jump if terminator copied
              dec       re             ; decrement allowed character count
              glo       re             ; see if done
              lbnz      fname          ; jump if not
              ldi       0              ; need to write a terminator
              str       ra
fnamedone:    call      savesyssec     ; write dirent back to disk
              mov       rf,lastsec     ; need to remember directory sector
              lda       rf
              stxd
              lda       rf
              stxd
              lda       rf
              stxd
              ldn       rf
              stxd
              call      zerolump       ; zero new file
              irx                      ; need to read directory sector back in
              ldxa
              plo       r7
              ldxa
              phi       r7
              ldxa
              plo       r8
              ldx
              phi       r8
              call      readsyssec
              op2       restore,rA_    ; recover address of dirent
              adi       0              ; signal no error
              lbr       return         ; return to caller

              endp

