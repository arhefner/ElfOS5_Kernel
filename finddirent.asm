.list

#include      macros.inc

; *********************************************
; ***** Find dirent for name              *****
; ***** RF - path to find                 *****
; ***** Returns: DF=0 - entry found       *****
; *****          RA   - Address of dirent *****
; *****          DF=1 - Not found         *****
; *********************************************
              proc      finddirent

              extrn     searchdir
              extrn     opencd
              extrn     openmd
              extrn     validchar
              extrn     scratch
              extrn     save
              extrn     restore
              extrn     getdeflags
              extrn     desub

              op2       save,r7_+r8_+rF_       ; save consumed registers
              ldn       rf             ; get first byte
              smi       '/'            ; check for absolute path
              lbnz      relative       ; jump if relative path
              inc       rf             ; move past slash
              call      openmd         ; open master directory
              lbr       continue       ; then continue
relative:     call      opencd         ; open current directory
continue:     ldn       rf             ; get first byte of path
              call      validchar      ; check for valid filename char
              lbnf      loop           ; jump if first character is good
              ldi       011h           ; signal bad filename
              smi       0              ; signal an error
return:       op2       restore,r7_+r8_+rF_
              glo       re
              rtn                      ; and return
loop:         ldn       rf             ; get byte from path
              lbz       done           ; jump if terminator
              smi       ' '            ; or space
              lbz       done
              mov       ra,scratch     ; point to name storage
nameloop:     lda       rf             ; get next byte from path
              plo       re             ; keep a copy
              smi       '/'            ; slash is not valid
              lbz       namedone       ; done if slash
              glo       re             ; otherwise check further
              call      validchar      ; see if valid
              lbdf      namedone       ; jump if done with name
              str       ra             ; store into name
              inc       ra
              lbr       nameloop       ; loop until invalid character found
namedone:     ldi       0              ; terminate name
              str       ra
              dec       rf             ; move back to invalid char
              op2       save,rF_       ; save path position
              mov       rf,scratch     ; point to name
              call      searchdir      ; search for entry
              op2       restore,rF_    ; recover position
              lbdf      notfound       ; jump if entry not found
              ldn       rf             ; get next byte
              smi       '/'            ; check for slash
              lbnz      loop           ; jump to check for proper conclusion
              op        getdeflags     ; get dirent flags
              ani       1              ; check is directory flag
              lbnz      isdir          ; jump if valid directory
              ldi       8              ; signal invalid directory
              smi       0              ; signal error
              lbr       return         ; return to caller
isdir:        inc       rf             ; move past slash              
              lda       ra             ; set lump
              phi       r8
              lda       ra
              plo       r8
              lda       ra
              phi       r7
              lda       ra
              plo       r7
              op2       desub,4
              lbr       loop           ; and check next path component
notfound:     ldi       0ch            ; indicate not found error
              smi       0              ; indicate error
              lbr       return         ; return to caller

done:         adi       0              ; signal path was found
              lbr       return         ; return to caller

              endp

