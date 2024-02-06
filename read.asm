.list

#include      macros.inc

; *****************************************
; ***** Read from file                *****
; ***** RD - Fildes for file          *****
; ***** RC - Count of bytes to read   *****
; ***** RF - Destination buffer       *****
; *****************************************
              proc      read

              extrn     helpers
              extrn     save
              extrn     restore
              extrn     nextsec
              extrn     getr8r7_rd
              extrn     setr8r7_rd
              extrn     getfdflags
              extrn     fdadd
              extrn     fdsub
              extrn     filestats

              push      r9
              mov       r9,helpers
              op2       save,r7_+r8_+rA_+rB_+rD_
              op        getfdflags       ; get file flags
              plo       re               ; keep a copy
              ani       8                ; check for open descriptor
              lbnz      isopen           ; jump if open
              ldi       010h             ; signal file not open
              smi       0
              lbr       return
isopen:       op        getr8r7_rd       ; retrieve file offset
              ldi       0                ; clear bytes read
              phi       rb
              plo       rb
loop:         ghi       rc               ; see if done
              str       r2
              glo       rc
              or
              lbz       done
              op        getfdflags       ; get flags
              shl                        ; check if in last sector
              lbnf      notlast          ; jump if not last sector
              op2       fdadd,6          ; retrieve eof
              lda       rd
              ani       1
              phi       ra
              ldn       rd
              plo       ra
              op2       fdsub,7
              lbr       findsize
notlast:      mov       ra,512           ; size comes from 512
findsize:     glo       r7               ; size -= ptr
              str       r2
              glo       ra
              sm
              plo       ra
              ghi       r7
              ani       1
              str       r2
              ghi       ra
              smb
              phi       ra               ; RA now has size
continue:     str       r2               ; check size for zero
              glo       ra
              or
              lbz       done             ; if nothing left to read, then done
              glo       ra               ; check for count < size
              str       r2
              glo       rc
              sm
              ghi       ra
              str       r2
              ghi       rc
              smb
              lbdf      positive         ; jump if count >= size
              mov       ra,rc            ; otheriwse set size to count
positive:     op2       save,rD_         ; save fildes
              op2       fdadd,5          ; point to DTA
              ldn       rd               ; retrieve DTA address
              str       r2
              glo       r7               ; and add in ptr
              add
              plo       re
              dec       rd
              ldn       rd
              str       r2
              ghi       r7
              ani       1
              adc
              phi       rd
              glo       re
              plo       rd               ; rd now points to data in DTA
              op        filestats        ; update counters
copyloop:     lda       rd               ; read byte from sector
              str       rf               ; write to output
              inc       rf
              dec       ra               ; decrement size
              glo       ra               ; see if done
              lbnz      copyloop
              ghi       ra
              lbnz      copyloop         ; loop until all bytes copied
              op2       restore,rD_      ; recover fildes
              glo       r7               ; see if hit end of sector
              lbnz      loop
              ghi       r7
              ani       01h
              lbnz      loop             ; back to loop if not
              inc       rd               ; need to write sector portion of ofs
              inc       rd
              ghi       r7
              str       rd
              dec       rd
              dec       rd
              call      nextsec          ; load in next sector
              lbdf      return           ; return to caller on error
              lbr       loop             ; otherwise keep reading
done:         op        setr8r7_rd       ; write new offset back to FILDES
              mov       rc,rb            ; move bytes read
              adi       0                ; signal no errors
return:       op2       restore,r7_+r8_+rA_+rB_+rD_
              pop       r9
              glo       re
              rtn

              endp
