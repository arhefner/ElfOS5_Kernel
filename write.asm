.list

#include      macros.inc

; *****************************************
; ***** write to file                 *****
; ***** RD - Fildes for file          *****
; ***** RC - Count of bytes to read   *****
; ***** RF - Destination buffer       *****
; *****************************************
              proc      write

              extrn     helpers
              extrn     save
              extrn     restore
              extrn     nextsec
              extrn     getr8r7_rd
              extrn     setr8r7_rd
              extrn     getfdflags
              extrn     setfdflags
              extrn     fdadd
              extrn     fdsub
              extrn     extendfile
              extrn     filestats

              push      r9
              mov       r9,helpers
              op2       save,r7_+r8_+rA_+rB_+rD_
              op        getfdflags       ; get file flags
              plo       re               ; keep a copy
              ani       8                ; check for open descriptor
              lbnz      isopen           ; jump if open
              ldi       010h             ; signal file not open
error:        smi       0
              lbr       return
isopen:       glo       re               ; retrieve flags
              ani       2                ; check for write only
              lbz       writeok          ; jump if write ok
              ldi       1                ; indicate read only file
              lbr       error
writeok:      op        getr8r7_rd       ; retrieve file offset
              ldi       0                ; clear bytes read
              phi       rb
              plo       rb
loop:         ghi       rc               ; see if done
              str       r2
              glo       rc
              or
              lbz       done
              glo       r7               ; size = 512 - ptr
              sdi       0
              plo       ra
              ghi       r7
              ani       1
              sdbi      2
              phi       ra               ; RA now has size
              str       r2               ; check size for zero
              glo       ra
              or
              lbz       done             ; if nothing left to write, then done
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
positive:     op        getfdflags       ; get flags
              shl                        ; check if in last sector
              lbnf      continue         ; jump if not last sector
; ***** This section under construction
              op2       save,rA_+rD_     ; save size
              glo       r7               ; size += ptr
              str       r2          
              glo       ra
              add
              plo       ra
              ghi       r7
              ani       1
              str       r2
              ghi       ra
              adc
              phi       ra
              op2       fdadd,7          ; point to lsb of eof
              ldn       rd               ; check size+ptr >= eof
              str       r2
              glo       ra
              sm
              dec       rd
              ldn       rd               ; leave rd pointing to lsb of eof
              ani       1
              str       r2
              ghi       ra
              smb
              lbnf      beloweof         ; jump if below eof
              lda       rd
              ani       0eh
              stxd
              glo       ra               ; eof = (eof & $e00) + ptr+size
              str       rd
              dec       rd
              ldn       rd
              ani       0eh
              str       r2
              ghi       ra
              add
              str       rd
              ani       0eh              ; strip offset
              irx                        ; point back to old msb of eof
              sm                         ; and compare
              lbz       beloweof         ; jump if no change in sector
              inc       rd               ; move to flags
              inc       rd
              ldn       rd               ; retreive flags
              ani       07fh             ; clear last sector bit
              str       rd               ; and put back
              dec       rd               ; move back to msb of eof
              dec       rd
              ldn       rd               ; and retrieve it
              ani       0f0h             ; keep only bits above sector
              lbz       beloweof         ; jump if does not extend into next lump
              op2       restore,rA_+rD_  ; recover registers
              call      extendfile       ; extend the file
              lbr       continue         ; and then continue
beloweof:     op2       restore,rA_+rD_  ; restore registers
; **********************************
continue:     op2       save,rD_         ; save fildes
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
copyloop:     lda       rf               ; read byte from input
              str       rd               ; write to output
              inc       rd
              dec       ra               ; decrement size
              glo       ra               ; see if done
              lbnz      copyloop
              ghi       ra
              lbnz      copyloop         ; loop until all bytes copied
              op2       restore,rD_      ; recover fildes
              op        getfdflags       ; get file flags
              ori       011h             ; indicate written
              op        setfdflags       ; and write them back
              glo       r7               ; see if hit end of sector
              lbnz      loop
              ghi       r7
              ani       1
              lbnz      loop             ; back to loop if not
              inc       rd               ; need to write sector portion of ofs
              inc       rd
              ghi       r7
              str       rd
              dec       rd
              dec       rd
              call      nextsec          ; load in next sector
              lbdf      return           ; return on error
              lbr       loop             ; else continue
done:         op        setr8r7_rd       ; write new offset back to FILDES
              mov       rc,rb            ; move bytes read
              adi       0                ; signal no errors
return:       op2       restore,r7_+r8_+rA_+rB_+rD_
              pop       r9
              glo       re
              rtn

              endp
