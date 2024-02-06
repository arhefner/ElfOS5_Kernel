.list

#include      bios.inc
#include      macros.inc

; ****************************************************
; ***** Write date time                          *****
; ***** RA - Pointer to date/time dest           *****
; ***** Returns - RA - following date/time field *****
; ****************************************************
              proc      setdatetime

              extrn     date_time
              extrn     save
              extrn     restore

              op2       save,rF_
              op2       save,rA_+rF_
              call      f_getdev       ; see if RTC installed
              glo       rf             ; get device map
              ani       010h           ; see if 
              lbz       nortc          ; jump if no rtc present
              mov       rf,date_time   ; point to date/time storage
              call      f_gettod       ; retreive date/time from RTC
nortc:        op2       restore,rA_+rF_
              mov       rf,date_time   ; point to date/time
              lda       rf             ; get month
              shl                      ; shift left 5 times
              shl
              shl
              shl
              shl
              str       r2             ; set aside for now
              ldi       0              ; set high bit of month
              shlc
              str       ra             ; store into dirent
              lda       rf             ; get day
              ani       01fh           ; keep only low 5 bits
              or                       ; combine with month
              plo       re             ; and set aside
              lda       rf             ; get year
              shl                      ; shift left
              str       r2             ; store to combine with month
              ldn       ra             ; retrieve high bit of month
              or                       ; combine with year
              str       ra             ; and write to dirent
              inc       ra             ; move to next byte
              glo       re             ; retrieve day
              str       ra             ; and store
              inc       ra
              lda       rf             ; get hour
              str       ra             ; and store it
              lda       rf             ; get minutes
              shl                      ; shift left twice
              shl
              shl                      ; now start compound shift
              plo       re             ; save minutes
              ldn       ra             ; get hours
              shlc                     ; and shift in
              str       ra
              glo       re             ; 2nd shift
              shl
              plo       re
              ldn       ra
              shlc
              str       ra
              glo       re             ; 3ra shift
              shl
              str       r2
              ldn       ra
              shlc
              str       ra
              inc       ra             ; move to second byte
              lda       rf             ; get seconds
              shr                      ; divide by 2
              or                       ; combine with minutes
              str       ra             ; and store into dirent
              inc       ra
              op2       restore,rF_
              rtn                      ; and return to caller

              endp

