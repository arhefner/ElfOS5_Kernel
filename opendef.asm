.list

#include      macros.inc

; ********************************************
; ***** Open master directory            *****
; ***** Returns: R8:R7 first lump of dir *****
; ********************************************
              proc      opendef

              extrn     def_lump
              extrn     read_lump

              mov       r7,def_lump    ; point to info from master dirent
              lbr       read_lump      ; read the lump

              endp

