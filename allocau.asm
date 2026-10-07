.list

#include      macros.inc

; *****************************************
; ***** allocate a free AU            *****
; ***** Returns: DF=0 - AU found      *****
; *****          R8:R7 - AU           *****
; *****          DF=1 - Error         *****
; *****             D - Error code    *****
; *****************************************
              proc      allocau

              extrn     readsyssec
              extrn     savesyssec
              extrn     dta
              extrn     fstype
              extrn     save
              extrn     restore
              
              op2       save,rA_+rB_+rC_+rD_
              mov       rc,fstype      ; need to get filesystem type
              lda       rc
              plo       rd             ; save it here
              ldi       0ffh           ; flag not to check for end of LAT
              phi       rd
              ldi       17             ; set starting sector
              plo       r7
              ldi       0
              phi       r7
              plo       r8
              phi       r8
loop:         call      readsyssec     ; read next LAT sector
              mov       rc,dta         ; point to beginning of dta
              glo       rd             ; check filesystem type
              smi       2              ; check for Elf/OS type 2
              lbz       type2          ; jump if type 2 filesystem
loop1:        lda       rc             ; check if lump is free
              str       r2
              ldn       rc
              dec       rc             ; back to msb of lump
              or
              lbnz      notfree1       ; jump if not free
              ldi       0feh           ; allocate the lump
              str       rc
              inc       rc
              str       rc
              dec       rc
              call      savesyssec
              call      sub17          ; subtract 17 from sector
              glo       r8             ; multiply by 256
              phi       r8
              ghi       r7
              plo       r8
              glo       r7
              phi       r7
              ghi       rc             ; now convert position
              smi       1              ; subtract dta start
              shr                      ; then shift right
              glo       rc
              shrc                     ; now have lump offset
              plo       r7             ; now have full lump
              adi       0              ; signal no error
return:       op2       restore,rA_+rB_+rC_+rD_
              glo       re             ; recover result code
              rtn                      ; and return to caller
notfree1:     lda       rc             ; get byte from lump
              plo       re             ; save for a moment
              lda       rc             ; get next
              smi       0ffh           ; check for ff
              lbnz      notff1         ; jump if not ff
              glo       re             ; check msb
              smi       0ffh           ; check for ff
              lbnz      notff1         ; jump if not
              ghi       rd             ; do we need to check for end of LAT
              lbnz      next1          ; jump if not
              ldi       0fh            ; indicate no free lumps
              smi       0              ; indicate error
              lbr       return         ; then return to caller
notff1:       ldi       0              ; clear LAT flag
              phi       rd
next1:        ghi       rc             ; need to see if at end of sector
              smi       3
              lbnz      loop1          ; jump if not
incsec:       inc       r7             ; increment the sector
              glo       r7             ; check for roll
              str       r2
              ghi       r7
              or
              lbnz      loop           ; read next sector if no roll
              inc       r8             ; increment high word
              lbr       loop           ; and read next sector


type2:        lda       rc             ; check if lump is free
              str       r2
              lda       rc
              or
              str       r2
              lda       rc
              or
              str       r2
              ldn       rc
              or
              dec       rc             ; back to msb of lump
              dec       rc
              dec       rc
              lbnz      notfree2       ; jump if not free
              inc       rc             ; allocate the lump
              inc       rc
              ldi       0feh
              str       rc
              inc       rc
              str       rc
              dec       rc
              dec       rc
              dec       rc
              call      savesyssec
              ghi       rc             ; convert position
              smi       1              ; subtract dta start
              shr                      ; then shift right
              glo       rc
              shrc                     ; now have lump offset
              shr 
              stxd                     ; store for later
              call      sub17          ; subtract 17 from sector
              glo       r8             ; multiply by 256
              phi       r8
              ghi       r7
              plo       r8
              glo       r7
              phi       r7
              ghi       r8             ; now divide by 2
              shr
              phi       r8
              glo       r8
              shrc
              plo       r8
              ghi       r7
              shrc
              phi       r7
              ldi       0
              shrc
              irx                      ; point x back to position
              or                       ; and combine
              plo       r7
              adi       0              ; signal no error
              lbr       return         ; return to caller
notfree2:     lda       rc             ; retrieve high word from lump
              phi       rb
              lda       rc
              plo       rb
              lda       rc             ; get byte from lump
              plo       re             ; save for a moment
              lda       rc             ; get next
              smi       0ffh           ; check for ff
              lbnz      notff2         ; jump if not ff
              glo       re             ; check msb
              smi       0ffh           ; check for ff
              lbnz      notff2         ; jump if not
              ghi       rb             ; check high word
              smi       0ffh
              lbnz      notff2
              glo       rb
              smi       0ffh
              lbnz      notff2
              ghi       rd             ; do we need to check for end of LAT
              lbnz      next2          ; jump if not
              ldi       0fh            ; indicate no free lumps
              smi       0              ; indicate error
              lbr       return         ; return to caller
notff2:       ldi       0              ; clear LAT flag
              phi       rd
next2:        ghi       rc             ; need to see if at end of sector
              smi       3
              lbnz      type2          ; jump if not
              lbr       incsec         ; increment sector and load next sector

sub17:        glo       r7             ; subtract 17 from sector
              smi       17
              plo       r7
              ghi       r7
              smbi      0
              phi       r7
              glo       r8
              smbi      0
              plo       r8
              ghi       r8
              smbi      0
              phi       r8
              rtn                      ; return to caller

              endp

; RD.0 - fstype
; RD.1 - flag to check for end of LAT (0=check)
