#include   macros.inc

           proc    kinit

scall:     equ     4
sret:      equ     5

           extrn   dta
           extrn   cwd_lump
           extrn   md_lump
           extrn   d_idereset
           extrn   o_alloc
           extrn   path
           extrn   stackaddr
           extrn   readsyssec
           extrn   strcpy
           extrn   setdef
           extrn   root
           extrn   cwd
           extrn   defdir
           extrn   lastsec
           extrn   fstype
           extrn   drive

           sep     scall               ; reset disk
           dw      d_idereset
           mov     rd,cwd              ; point to current working directory
           mov     rf,root             ; root directory
           op      strcpy
           
           mov     rf,lastsec          ; need to clear last sec
           ldi     0ffh                ; to something non-existant
           str     rf
           inc     rf
           str     rf
           inc     rf
           str     rf
           inc     rf
           str     rf

           ldi     0                   ; need to read sector 0
           phi     r8
           plo     r8
           phi     r7
           plo     r7
           call    readsyssec          ; read it
           mov     rf,drive            ; need to set drive and fstype
           ldi     0                   ; first drive always at start
           str     rf
           inc     rf
           mov     ra,dta+104h
           ldn     ra
           str     rf
           mov     rf,dta+012ch        ; point to md entry in dta
           mov     ra,cwd_lump         ; point to working directory pointer
           mov     rb,md_lump          ; point to master directory pointer
           ldi     6                   ; 6 bytes to copy
           plo     re                  ; setup counter
loop:      lda     rf                  ; get byte from MD reacord
           str     ra                  ; write to working directory
           inc     ra
           str     rb                  ; write to master directory
           inc     rb
           dec     re                  ; decrement count
           glo     re                  ; see if done
           lbnz    loop                ; loop until done

           mov     rc,252              ; want to allocate 252 bytes on the heap
           mov     r7,00004            ; allocate as a permanent block
           sep     scall               ; allocate the memory
           dw      o_alloc
           mov     r7,stackaddr+1      ; point to allocation pointer
           ldi     1                   ; mark interrupts enabled
           lsie                        ; skip if interrupts are enabled
           ldi     0                   ; mark interrupts disabled
           plo     re                  ; save IE flag
           ldi     023h                ; setup for DIS
           str     r2
           dis                         ; disable interrupts
           dec     r2
           glo     rf                  ; SP needs to be end of heap block
           adi     251
           str     r7                  ; write to pointer
           dec     r7
           plo     r2                  ; and into R2
           ghi     rf                  ; process high byte
           adci    0
           str     r7
           phi     r2
           glo     re                  ; recover IE flag
           lbz     kinit2              ; jump if interrupts disabled
           ldi     023h                ; setup for RET
           str     r2
           ret                         ; re-enable interrupts
           dec     r2
kinit2:    dec     r2                  ; need 2 less
           dec     r2
           mov     rf,defdir           ; default directory
           call    setdef              ; setup default directory
           sep     sret                ; return to caller

           endp

