
           proc    final

scratch:   dw      0
           ds      128
bootmsg:   db      'Starting Elf/OS ...',10,13
           db      'V5.0.4'
crlf:      db      10,13,0
prompt:    db      10,13,'Ready',10,13,': ',0
errnf:     db      'File not found.',10,13,0
initprg:   db      '/bin/init',0
shellprg:  db      '/bin/shell',0
defdir:    db      '/bin/',0
root:      db      '/',0
cwd:       ds      127
           db      0

           public  bootmsg
           public  prompt
           public  crlf
           public  errnf
           public  initprg
           public  shellprg
           public  defdir
           public  scratch
           public  cwd
           public  root

           endp
