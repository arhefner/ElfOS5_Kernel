PROJECT = kernel
OBJS= \
	alloc.prg \
	allocau.prg \
	chdir.prg \
	checkwrite.prg \
	close.prg \
	coldboot.prg \
	create.prg \
	dealloc.prg \
	delchain.prg \
	delete.prg \
	dirempty.prg \
	exec.prg \
	execbin.prg \
	extendfile.prg \
	final.prg \
	finddirent.prg \
	findsec.prg \
	fnddirent.prg \
	freedirent.prg \
	helpers.prg \
	hgc.prg \
	inlineover.prg \
	kinit.prg \
	lmptosec.prg \
	lmptosecofs.prg \
	loadbinary.prg \
	loaddirent.prg \
	loadover.prg \
	loadnover.prg \
	lseek.prg \
	main.prg \
	mkdir.prg \
	nextsec.prg \
	open.prg \
	opencd.prg \
	opendef.prg \
	opendir.prg \
	openmd.prg \
	overinit.prg \
	rdlump.prg \
	rdlump32.prg \
	read.prg \
	readlump.prg \
	readsyssec.prg \
	reapheap.prg \
	relsec.prg \
	rename.prg \
	rmdir.prg \
	savesys.prg \
	savesyssec.prg \
	searchdir.prg \
	sectolmp.prg \
	seek.prg \
	seekend.prg \
	setdatetime.prg \
	setdef.prg \
	setdrive.prg \
	setfileflags.prg \
	splitpath.prg \
	start.prg \
	trunc.prg \
	validchar.prg \
	validfn.prg \
	write.prg \
	writelump.prg \
	writesyssec.prg \
	wrlump.prg \
	wrlump32.prg \
	zerolump.prg

.SUFFIXES: .asm .prg

$(PROJECT): $(OBJS)
	asm02 -l -L main.asm
	-rm $(PROJECT).prg
	link02 @kernel.lnk -s -S kernel.sym -h -o $(PROJECT).prg
	link02 @kernel.lnk -s -S kernel.sym -b -o $(PROJECT).bin

run:
	run02 -boot

debug:
	run02 -boot -v

lists:
	./adjlst alloc.lst alloc
	./adjlst allocau.lst allocau
	./adjlst chdir.lst chdir
	./adjlst close.lst close
	./adjlst coldboot.lst coldboot
	./adjlst create.lst create
	./adjlst dirempty.lst dirempty
	./adjlst exec.lst exec
	./adjlst execbin.lst execbin
	./adjlst extendfile.lst extendfile
	./adjlst final.lst final
	./adjlst finddirent.lst finddirent
	./adjlst freedirent.lst freedirent
	./adjlst helpers.lst helpers
	./adjlst lmptosecofs.lst lmptosecofs
	./adjlst loadbinary.lst loadbinary
	./adjlst loaddirent.lst loaddirent
	./adjlst loadover.lst loadover
	./adjlst loadnover.lst loadnover
	./adjlst mkdir.lst mkdir
	./adjlst kinit.lst kinit
	./adjlst nextsec.lst nextsec
	./adjlst open.lst open
	./adjlst opencd.lst opencd
	./adjlst opendir.lst opendir
	./adjlst openmd.lst openmd
	./adjlst overinit.lst overinit
	./adjlst rdlump.lst rdlump
	./adjlst read.lst read
	./adjlst readlump.lst readlump
	./adjlst readsyssec.lst readsyssec
	./adjlst reapheap.lst reapheap
	./adjlst rename.lst rename
	./adjlst rmdir.lst rmdir
	./adjlst searchdir.lst searchdir
	./adjlst seek.lst seek
	./adjlst setdatetime.lst setdatetime
	./adjlst setdef.lst setdef
	./adjlst setfileflags.lst setfileflags
	./adjlst splitpath.lst splitpath
	./adjlst trunc.lst trunc
	./adjlst start.lst start
	./adjlst validchar.lst validchar
	./adjlst validfn.lst validfn
	./adjlst write.lst write
	./adjlst writelump.lst writelump
	./adjlst zerolump.lst zerolump

.asm.prg:
	asm02 -l -L $<

clean:
	-rm *.prg
	-rm $(PROJECT)

