.list

#include      macros.inc

; ********************************************
; ***** Open master directory            *****
; ***** Returns: R8:R7 first lump of dir *****
; ********************************************
              proc      openmd

              extrn     md_lump
              extrn     read_lump

              mov       r7,md_lump     ; point to info from master dirent
              lbr       read_lump      ; read the lump

              endp

