AS=as --32
LD=ld -m elf_i386
FLAGS=-gstabs
OBJS_PIANIFICATORE=obj/pianificatore.o
OBJS_FILE_READ=obj/file_read.o
OBJS_read_file=obj/file_read.o
OBJS_swap=obj/swap.o
OBJS_itoa=obj/itoa.o
OBJS_output=obj/output.o
OBJS_errs=obj/errs_handle.o
GCC=gcc


# Regole per gli eseguibili
bin/pianificatore: $(OBJS_PIANIFICATORE) $(OBJS_read_file) $(OBJS_swap) $(OBJS_itoa) $(OBJS_output) $(OBJS_errs)
	$(LD) $(OBJS_read_file) $(OBJS_swap) $(OBJS_itoa) $(OBJS_output) $(OBJS_errs) $(OBJS_PIANIFICATORE) -o $@

bin/file_read: $(OBJS_FILE_READ) $(OBJS_errs)
	$(LD) -o $@ $(OBJS_FILE_READ) $(OBJS_errs)

bin/swap: $(OBJS_swap)
	$(LD) -o $@ $(OBJS_swap)

bin/itoa: $(OBJS_itoa)
	$(LD) -o $@ $(OBJS_itoa)

bin/output: $(OBJS_output) $(OBJS_errs)
	$(LD) -o $@ $(OBJS_output) $(OBJS_errs)

bin/errs_handle: $(OBJS_errs)
	$(LD) -o $@ $(OBJS_errs)

# Regole per gli oggetti
obj/errs_handle.o: src/errs_handle.s
	$(AS) $(FLAGS) -o $@ $<

obj/output.o: src/output.s
	$(AS) $(FLAGS) -o $@ $<

obj/itoa.o: src/itoa.s
	$(AS) $(FLAGS) -o $@ $<

obj/pianificatore.o: src/pianificatore.s
	$(AS) $(FLAGS) -o $@ $<

obj/file_read.o: src/file_read.s
	$(AS) $(FLAGS) -o $@ $<


obj/swap.o: src/swap.s
	$(AS) $(FLAGS) -o $@ $<


clean:
	rm -f obj/*.o bin/*
