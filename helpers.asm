.list

#include      macros.inc

              extrn     rundone

              org       0500h
              sep       r3             ; return to caller
helpers:      plo       re             ; save D
              lda       r3             ; get next byte from program
              plo       r9             ; jump to routine

; ********************************************
; ***** Get flags from fildes            *****
; ********************************************
getfdflags:   glo       rd             ; point to flags
              adi       8
              plo       rd
              ghi       rd
              adci      0
              phi       rd
              ldn       rd             ; get flags
              plo       re             ; set aside
              glo       rd             ; restore fildes pointer
              smi       8
              plo       rd
              ghi       rd
              smbi      0
              phi       rd
              glo       re             ; recover flags
              br        helpers-1;

; ********************************************
; ***** Set flags from fildes            *****
; ********************************************
setfdflags:   glo       rd             ; point to flags
              adi       8
              plo       rd
              ghi       rd
              adci      0
              phi       rd
              glo       re             ; get value
              str       rd             ; store into fildes
              glo       rd             ; restore fildes pointer
              smi       8
              plo       rd
              ghi       rd
              smbi      0
              phi       rd
              glo       re             ; recover flags
              br        helpers-1;

; ********************************************
; ***** Get flags from dirent (RA)       *****
; ********************************************
getdeflags:   inc       ra
              inc       ra
              inc       ra
              inc       ra
              inc       ra
              inc       ra
              ldn       ra             ; get flags
              dec       ra
              dec       ra
              dec       ra
              dec       ra
              dec       ra
              dec       ra
              br        helpers-1;

; ********************************************
; ***** Set flags from dirent (RA)       *****
; ********************************************
setdeflags:   inc       ra
              inc       ra
              inc       ra
              inc       ra
              inc       ra
              inc       ra
              str       ra             ; store into fildes
              dec       ra
              dec       ra
              dec       ra
              dec       ra
              dec       ra
              dec       ra
              br        helpers-1;

; *************************************
; ***** Add immediate value to RD *****
; *************************************
fdadd:        lda       r3             ; get next byte
              str       r2             ; store for add
              glo       rd             ; and add to rd
              add 
              plo       rd
              ghi       rd
              adci      0
              phi       rd
              br        helpers-1

; ********************************************
; ***** subtract immediate value from RD *****
; ********************************************
fdsub:        lda       r3             ; get next byte
              str       r2             ; store for add
              glo       rd             ; and add to rd
              sm 
              plo       rd
              ghi       rd
              smbi      0
              phi       rd
              br        helpers-1

; *************************************
; ***** Add immediate value to RA *****
; *************************************
deadd:        lda       r3             ; get next byte
              str       r2             ; store for add
              glo       ra             ; and add to rd
              add 
              plo       ra
              ghi       ra
              adci      0
              phi       ra
              br        helpers-1

; ********************************************
; ***** subtract immediate value from RA *****
; ********************************************
desub:        lda       r3             ; get next byte
              str       r2             ; store for add
              glo       ra             ; and add to rd
              sm 
              plo       ra
              ghi       ra
              smbi      0
              phi       ra
              br        helpers-1

; *************************************************
; ***** Retrieve starting AU from dirent (RA) *****
; *************************************************
startingau:   lda       ra
              phi       r8
              lda       ra
              plo       r8
              lda       ra
              phi       r7
              lda       ra
              plo       r7
              br        helpers-1

; ***********************************
; ***** Increment sector number *****
; ***********************************
incsec:       inc       r7
              ghi       r7
              str       r2
              glo       r7
              or
              bnz       helpers-1
              inc       r8
              br        helpers-1

; ******************************************
; ***** Load RF from immediate address *****
; ******************************************
loadrf:       lda       r3
              phi       rf
              lda       r3
              plo       rf
              lda       rf
              plo       re
              ldn       rf
              plo       rf
              glo       re
              phi       rf
              br        helpers-1

; ******************************************
; ***** Load RC from immediate address *****
; ******************************************
loadrc:       lda       r3
              phi       rc
              lda       r3
              plo       rc
              lda       rc
              plo       re
              ldn       rc
              plo       rc
              glo       re
              phi       rc
              br        helpers-1

; ****************************************
; ***** Test lump in R8:R7 for final *****
; ***** DF=1 if final lump           *****
; ****************************************
finalau:      ghi       r8
              str       r2
              glo       r8
              or
              bnz       notfinal
              ghi       r7
              smi       0feh
              bnz       notfinal
              glo       r7
              smi       0feh
              bnz       notfinal
              smi       0
              br        helpers-1
notfinal:     adi       0
              br        helpers-1

getr8r7_rd:   lda       rd
              phi       r8
              lda       rd
              plo       r8
              lda       rd
              phi       r7
              ldn       rd
              plo       r7
decrdx3:      dec       rd
              dec       rd
              dec       rd
              br        helpers-1

setr8r7_rd:   ghi       r8
              str       rd
              inc       rd
              glo       r8
              str       rd
              inc       rd
              ghi       r7
              str       rd
              inc       rd
              glo       r7
              str       rd
              br        decrdx3

strcpy:       lda       rf
              str       rd
              inc       rd
              bnz       strcpy
              br        helpers-1

strcat:       lda       rd
              bnz       strcat
              dec       rd
              br        strcpy

save:         lbr       lsave
restore:      lbr       lrestore
filestats:    lbr       filestat
ltrim:        lbr       l_trim

              org       0600h

lsave:        ldn       r3
              ani       1
              bz        save_1
              push      r7
save_1:       ldn       r3
              ani       2
              bz        save_2
              push      r8
save_2:       ldn       r3
              ani       4
              bz        save_3
              push      ra
save_3:       ldn       r3
              ani       8
              bz        save_4
              push      rb
save_4:       ldn       r3
              ani       16
              bz        save_5
              push      rc
save_5:       ldn       r3
              ani       32
              bz        save_6
              push      rd
save_6:       lda       r3
              ani       64
              lbz       helpers-1
              push      rf
              lbr       helpers-1

lrestore:     ldn       r3
              ani       64
              bz        restore_1
              pop       rf
restore_1:    ldn       r3
              ani       32
              bz        restore_2
              pop       rd
restore_2:    ldn       r3
              ani       16
              bz        restore_3
              pop       rc
restore_3:    ldn       r3
              ani       8
              bz        restore_4
              pop       rb
restore_4:    ldn       r3
              ani       4
              bz        restore_5
              pop       ra
restore_5:    ldn       r3
              ani       2
              bz        restore_6
              pop       r8
restore_6:    lda       r3
              ani       1
              lbz       helpers-1
              pop       r7
              lbr       helpers-1

filestat:     glo       ra               ; count -= size
              str       r2
              glo       rc
              sm
              plo       rc
              ghi       ra
              str       r2
              ghi       rc
              smb
              phi       rc
              glo       ra               ; bytesWritten += size
              str       r2
              glo       rb
              add
              plo       rb
              ghi       ra
              str       r2
              ghi       rb
              adc
              phi       rb
              glo       ra               ; offset += size
              str       r2
              glo       r7
              add
              plo       r7
              ghi       ra
              str       r2
              ghi       r7
              adc
              phi       r7
              glo       r8
              adci      0
              plo       r8
              ghi       r8
              adci      0
              phi       r8
              lbr       helpers-1

run:          sep       r4
jump:         dw        0
              lbr       rundone

l_trim:       lda       rf
              smi       32
              lbz       ltrim
              dec       rf
              lbr       helpers-1

              public    helpers
              public    getfdflags
              public    setfdflags
              public    getdeflags
              public    setdeflags
              public    save
              public    restore
              public    fdadd
              public    fdsub
              public    deadd
              public    desub
              public    startingau
              public    incsec
              public    loadrf
              public    loadrc
              public    finalau
              public    getr8r7_rd
              public    setr8r7_rd
              public    strcpy
              public    strcat
              public    filestats
              public    run
              public    jump
              public    ltrim


