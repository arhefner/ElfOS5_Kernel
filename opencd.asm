.list

#include      macros.inc

; ********************************************
; ***** Open current directory           *****
; ***** Returns: R8:R7 first lump of dir *****
; ********************************************
              proc      opencd

              extrn     cwd_lump

              mov       r7,cwd_lump    ; point to info from current dirent
read_lump:    lda       r7             ; retrieve lump
              phi       r8
              lda       r7
              plo       r8
              lda       r7
              plo       re
              lda       r7
              plo       r7
              glo       re
              phi       r7
              rtn                      ; and return to caller

              public    read_lump

              endp

