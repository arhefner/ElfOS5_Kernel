.list

#include      macros.inc

; *****************************************
; ***** Execute a file from bin dir   *****
; ***** RF - point to filename        *****
; ***** Returns: DF=0 - Successful    *****
; *****          DF=1 - Error         *****
; *****             D - Error code    *****
; *****************************************
              proc      execbin

              extrn     splitpath
              extrn     opendef
              extrn     searchdir
              extrn     helpers
              extrn     save
              extrn     restore
              extrn     getdeflags
              extrn     loadbinary
              extrn     execreturn
              extrn     execgood

              push      r9             ; setup for calls
              mov       r9,helpers
              op2       save,rF_
              call      splitpath      ; get just filename
              call      opendef        ; open default directory
              mov       rf,ra          ; move name pointer to RF
              call      searchdir      ; and see if in default directory
              lbdf      execreturn     ; jump if name not found
              lbr       execgood       ; execute the file

              endp
