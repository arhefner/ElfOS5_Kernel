; *******************************************************************
; *** This software is copyright 2006 by Michael H Riley          ***
; *** You have permission to use, modify, copy, and distribute    ***
; *** this software so long as this copyright notice is retained. ***
; *** This software may not be used in commercial applications    ***
; *** without express written permission from the author.         ***
; *******************************************************************

#include macros.inc

; #define  ELF2K

         extrn   alloc
         extrn   append
         extrn   chdir
         extrn   coldboot
         extrn   close
         extrn   dealloc
         extrn   delete
         extrn   exec
         extrn   execbin
         extrn   fnddirent
         extrn   incofs1
         extrn   intdta
         extrn   kinit
         extrn   lmpsize
         extrn   mddta
         extrn   mkdir
         extrn   noopen
         extrn   open
         extrn   opendir
         extrn   read
         extrn   rdlump
         extrn   rdlump32
         extrn   reapheap
         extrn   rename
         extrn   rmdir
         extrn   lseek
         extrn   setdef
         extrn   warm3
         extrn   warmboot
         extrn   write
         extrn   wrlump
         extrn   lmptosec
         extrn   sectolmp
         extrn   savesys
         extrn   overinit
         extrn   loadover
         extrn   relsec
         extrn   inlineover
         extrn   loadnover
         extrn   wrlump32
         extrn   trunc
         extrn   delchain
         extrn   allocau
         extrn   freedirent


         org     300h
#include   bios.inc

keybuf:  equ     080h
dta:     equ     100h

vcursec:   equ     00f0h
vsecbuf:   equ     00f4h
vhighmem:  equ     00feh

errexists: equ     1
errnoffnd: equ     2
errinvdir: equ     3
errisdir:  equ     4
errdirnotempty: equ   5
errnotexec:     equ   6

ff_dir:       equ    1
ff_exec:      equ    2
ff_write:     equ    4
ff_hide:      equ    8
ff_archive:   equ    16

o_cdboot:     lbr    coldboot
o_wrmboot:    lbr    warmboot
o_open:       lbr    open
o_read:       lbr    read
o_write:      lbr    write
o_seek:       lbr    lseek
o_close:      lbr    close
o_opendir:    lbr    opendir
o_delete:     lbr    delete
o_rename:     lbr    rename
o_exec:       lbr    exec
o_mkdir:      lbr    mkdir
o_chdir:      lbr    chdir
o_rmdir:      lbr    rmdir
o_rdlump:     lbr    rdlump
o_wrtlump:    lbr    wrlump
o_type:       lbr    f_tty
o_msg:        lbr    f_msg
o_readkey:    lbr    f_read
o_input:      lbr    f_input
o_prtstat:    lbr    return
o_print:      lbr    return
o_execdef:    lbr    execbin
o_setdef:     lbr    setdef
o_kinit:      lbr    kinit
o_inmsg:      lbr    f_inmsg
o_getdev:     lbr    f_getdev
o_gettod:     lbr    f_gettod
o_settod:     lbr    f_settod
o_inputl:     lbr    f_inputl
o_boot:       lbr    f_boot
o_tty:        lbr    f_tty
o_setbd:      lbr    f_setbd
o_initcall:   lbr    f_initcall
o_brktest:    lbr    f_brktest
o_devctrl:    lbr    deverr
o_alloc:      lbr    alloc
o_dealloc:    lbr    dealloc
o_termctl:    lbr    error
o_nbread:     lbr    f_nbread
o_memctrl:    lbr    deverr
o_dirent:     lbr    fnddirent

deverr:       ldi    1                   ; error=0, device not found
              shr                         ; Set df to indicate error
return:       sep    sret                ; return to caller

error:        shl                         ; move error over
              ori    1                   ; signal error condition
              shr                         ; shift over and set DF
              sep    sret                ; return to caller

              org    3d0h                ; reserve some space for users
user:         db     0

              org    3f0h
intret:       sex    r2
              irx
              ldxa
              shr
              ldxa
              ret
iserve:       dec    r2
              sav
              dec    r2
              stxd
              shlc
              stxd
              db     0c0h
ivec:         dw     intret

              org    400h
version:      db     5,1,0

              dw     [build]
              db     [month],[day]
              dw     [year]

o_lmptosec:   lbr    lmptosec
o_sectolmp:   lbr    sectolmp
o_rdlump32:   lbr    rdlump32
o_overinit:   lbr    overinit
o_loadover:   lbr    loadover
o_relsec:     lbr    relsec
o_inlineover: lbr    inlineover
o_loadnover:  lbr    loadnover
o_wrlump32:   lbr    wrlump32
              db     0
def_lump:     dw     0,0
def_eof:      dw     0
lastsec:      dw     0,0
md_lump:      dw     0,0
md_eof:       dw     0
md_flags:     db     5
cwd_lump:     dw     0,0
cwd_eof:      dw     0
cwd_flags:    db     5
              db     0
file_au:      dw     0,0
himem:        dw     0                   ; should end up at $442
d_idereset:   lbr    f_idereset          ; jump to bios ide reset
d_ideread:    lbr    f_ideread           ; jump to bios ide read
d_idewrite:   lbr    f_idewrite          ; jump to bios ide write
d_reapheap:   lbr    reapheap            ; passthrough to heapreaper
d_progend:    lbr    warm3
d_delchain:   lbr    delchain            ; Delete an AU chain
o_video:      lbr    deverr              ; video driver
d_savesys:    lbr    savesys
drive:        db     0
fstype:       db     0                   ; fstype of current drive
d_allocau:    lbr    allocau
shelladdr:    dw     0
stackaddr:    dw     0
lowmem:       dw     04000h
retval:       db     0
heap:         dw     0
o_trunc:      lbr    trunc
d_freedirent: lbr    freedirent
clockfrq:     dw     4000
              db     0
scratch1:     dw     0
date_time:    db     [month],[day],[year]-1972
time:         db     [hour],[minute],[second]
secnum:       dw     0
secden:       dw     0


path:         ds     127
              db     0

              public d_ideread
              public d_idereset
              public d_idewrite
              public d_reapheap
              public d_progend
              public date_time
              public drive
              public dta
              public errdirnotempty
              public errexists
              public errinvdir
              public errisdir
              public errnoffnd
              public errnotexec
              public error
              public fstype
              public ff_archive
              public heap
              public himem
              public lowmem
              public keybuf
              public o_alloc
              public o_exec
              public o_getdev
              public o_gettod
              public o_initcall
              public o_msg
              public o_inputl
              public o_open
              public o_opendir
              public o_read
              public o_setbd
              public o_write
              public path
              public retval
              public stackaddr
              public cwd_lump
              public cwd_eof
              public md_lump
              public def_lump
              public lastsec
              public file_au


