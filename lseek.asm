.list

#include      macros.inc

; *****************************************
; ***** Seek                          *****
; ***** RD - fildes                   *****
; ***** R8:R7 - Seek position         *****
; *****    RC - 0 - from beginning    *****
; *****         1 - from current      *****
; *****         2 - from end          *****
; ***** Returns: DF=0 - Successful    *****
; *****          R8:R7 - position     *****
; *****          DF=1 - Error         *****
; *****             D - Error code    *****
; *****************************************
              proc      lseek

              extrn     helpers
              extrn     seek

              push      r9
              mov       r9,helpers
              call      seek
              pop       r9
              rtn

              endp

