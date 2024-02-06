
#include      macros.inc

; *******************************************
; ***** Allocate memory                 *****
; ***** RC - requested size             *****
; ***** R7.0 - Flags                    *****
; *****      0 - Non-permanent block    *****
; *****      4 - Permanent block        *****
; ***** R7.1 - Alignment                *****
; *****      0 - no alignment           *****
; *****      1 - Even address           *****
; *****      3 - 4-byte boundary        *****
; *****      7 - 8-byte boundary        *****
; *****     15 - 16-byte boundary       *****
; *****     31 - 32-byte boundary       *****
; *****     63 - 64-byte boundary       *****
; *****    127 - 128-byte boundary      *****
; *****    255 - Page boundary          *****
; ***** Returns: RF - Address of memory *****
; *****          RC - Size of block     *****
; *******************************************
 
              proc      alloc

              extrn     heap
              extrn     himem
              extrn     lowmem
              extrn     helpers
              extrn     save
              extrn     restore
              extrn     updhimem

              push      r9
              mov       r9,helpers
              op2       save,rA_
              mov       rf,heap        ; point to heap address
              lda       rf             ; and retrieve it
              phi       ra
              ldn       rf
              plo       ra             ; RA now points to start of heap
              ghi       r7             ; check for request for aligned block
              lbnz      aligned        ; jump if request for aligned block
loop:         ldn       ra             ; get byte from header
              lbz       neednew        ; jump if end of heap reached
              ani       3              ; keep only bottom bitts
              smi       1              ; is it a free block
              lbnz      notfree        ; jump if not
              inc       ra             ; point to msb of block size
              lda       ra             ; retrieve it
              phi       rf             ; into RF
              ldn       ra             ; get lsb
              plo       rf
              glo       rc             ; see if block is large enough
              str       r2
              glo       rf
              sm
              ghi       rc
              str       r2
              ghi       rf
              smb
              dec       ra             ; move back to block header
              dec       ra
              lbnf      notfree        ; jump if block is too small
              glo       r7             ; get flags
              ani       4              ; keep only permanent flag
              ori       2              ; mark as used block 
              str       ra             ; and set block header
              glo       rc             ; subtract requested size from block size
              str       r2
              glo       rf
              sm
              plo       rf
              ghi       rc
              str       r2
              ghi       rf
              smb
              phi       rf             ; RF now has difference between requested and block
              glo       rf             ; see if difference > 16
              smi       16
              ghi       rf
              smbi      0
              lbnf      toosmall       ; jump if block too small to split
              inc       ra             ; move to msb of block size
              op2       save,rA_
              ghi       rc             ; and store size of new block
              stxd                     ; store for later add
              str       ra
              inc       ra             ; point to lsb
              glo       rc
              str       r2
              str       ra
              inc       ra             ; point to data 
              glo       ra             ; now add in size to find new header position
              add
              plo       ra
              irx
              ghi       ra
              adc
              phi       ra             ; ra now points at new header
              ldi       1              ; mark block as free
              str       ra
              inc       ra
              dec       rf             ; account for header in remaining size
              dec       rf
              dec       rf
              ghi       rf             ; write block size to block
              str       ra
              inc       ra
              glo       rf
              str       ra
              op2       restore,rF_    ; recover allocated block address
              inc       rf             ; move to actual data
              inc       rf
              adi       0              ; indicate no error
              lbr       return         ; and return
toosmall:     inc       ra             ; move to actually allocated block
              inc       ra
              inc       ra
              mov       rf,ra          ; move to return register
              adi       0              ; indicate no error in DF
              lbr       return         ; all done
notfree:      inc       ra             ; point to msb of block size
              lda       ra             ; retrieve it
              stxd                     ; store for add
              lda       ra             ; retrieve lsb
              str       r2
              glo       ra             ; now add size to address
              add
              plo       ra
              irx
              ghi       ra
              adc
              phi       ra             ; RA now points to next block header
              lbr       loop           ; check next block
neednew:      mov       rf,heap        ; point to heap address
              lda       rf             ; and retrieve it
              phi       ra
              ldn       rf
              plo       ra             ; RA now points to start of heap
aligned:      glo       rc             ; subtract size from heap start address
              str       r2
              glo       ra
              sm
              plo       rf
              ghi       rc
              str       r2
              ghi       ra
              smb
              phi       rf             ; RF now has address of new block
              ghi       r7             ; was aligned block requested
              lbz       notalign       ; jump if not
              xri       255            ; invert the bits
              str       r2             ; store to combine with position
              glo       rf             ; get low byte of block
              and                      ; and combine with mask
              plo       rf             ; put back into RF
notalign:     glo       ra             ; get new size
              str       r2
              glo       rf
              sd
              plo       rc             ; and set into rc
              ghi       ra
              str       r2
              ghi       rf
              sdb
              phi       rc             ; RC has new size of block
              mov       ra,lowmem+1    ; get lowest allowed address
              ldn       ra             ; retrieve lowmem lsb
              str       r2             ; store for subtract
              glo       rf             ; subtract from new allocation address
              sm
              dec       ra             ; propagate through msb
              ldn       ra
              str       r2
              ghi       rf
              smb
              lbnf      error          ; jump if new address is below lowmem
              mov       ra,rf          ; move address to ra
              dec       ra             ; lsb of size
              glo       rc             ; store size
              str       ra
              dec       ra             ; point to msb
              ghi       rc             ; high of size
              str       ra
              dec       ra             ; point to block header
              glo       r7             ; get flags byte
              ani       4              ; strip all but permanent flag
              ori       2              ; set used flag
              str       ra             ; write into header
              glo       ra             ; save this address
              stxd
              ghi       ra
              str       r2
              mov       ra,heap        ; point to heap address
              ldxa                     ; and set to new start of heap
              str       ra
              inc       ra
              ldx
              str       ra
              call      updhimem
              adi       0              ; indicate no error
return:       op2       restore,rA_
              pop       r9
              rtn                      ; and return to caller
error:        smi       0              ; indicate error
              lbr       return         ; and return

              endp


              proc      updhimem

              extrn     heap
              extrn     himem
              extrn     save
              extrn     restore

              op2       save,rA_+rF_
              mov       rf,heap
              lda       rf
              phi       ra
              lda       rf
              plo       ra
              mov       rf,himem
              dec       ra
              ghi       ra
              str       rf
              inc       rf
              glo       ra
              str       rf
              op2       restore,rA_+rF_
              rtn

              endp

