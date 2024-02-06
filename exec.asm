.list

#include      macros.inc

; *****************************************
; ***** Execute a file                *****
; ***** RF - point to filename        *****
; ***** Returns: DF=0 - Successful    *****
; *****          DF=1 - Error         *****
; *****             D - Error code    *****
; *****************************************
              proc      exec

              extrn     finddirent
              extrn     helpers
              extrn     save
              extrn     restore
              extrn     getdeflags
              extrn     loadbinary
              extrn     retval
              extrn     d_reapheap
              extrn     run
              extrn     jump

              push      r9             ; setup for calls
              mov       r9,helpers
              op2       save,rF_
              call      finddirent     ; search for dirent for file
              lbnf      execgood       ; jump if entry found
execreturn:   op2       restore,rF_
execdone:     pop       r9
              glo       re
              rtn                      ; return to caller
execgood:     op        getdeflags     ; get flags from dirent
              ani       2              ; check for executable flag
              lbnz      executable     ; jump if set
              ldi       3              ; signal file is not executable
              smi       0              ; set error flag
              lbr       execreturn     ; and return in error
executable:   call      loadbinary     ; load binary file
              pop       ra             ; retrieve original filename
nameloop:     lda       ra             ; look for end of command name
              lbz       cmddone        ; jump if found
              smi       32             ; space also terminates
              lbnz      nameloop       ; loop until space or terminator
cmddone:      dec       ra             ; move ra back to last character
spaceloop:    lda       ra             ; move past any spaces
              smi       32
              lbz       spaceloop
              dec       ra             ; ra now has command line arguments
              mov       r9,01ffeh      ; need to get executable address
              mov       rf,jump        ; where to put the call
              lda       r9             ; transfer start address
              str       rf
              inc       rf
              lda       r9
              str       rf
        lbr   run
;              sep       r4             ; call user program
;jump:         dw        0
rundone:      plo       re             ; save return value
              mov       rf,retval      ; point to retval
              glo       re             ; store value
              str       rf
              adi       0              ; clear df
              lbr       execdone       ; and return to caller

              public    execgood
              public    execreturn
              public    rundone

              endp


