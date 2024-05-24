# Variabili
EXES=bin/pianificatore bin/file_read bin/get_arg
AS=as --32
LD=ld -m elf_i386
FLAGS=-gstabs
OBJS_PIANIFICATORE=obj/pianificatore.o
OBJS_FILE_READ=obj/file_read.o
OBJS_get_arg=obj/get_arg.o
OBJS_read_file=obj/file_read.o
OBJS_swap=obj/swap.o
OBJS_itoa=obj/itoa.o
OBJS_output=obj/output.o
GCC=gcc

# Regole per creare le directory necessarie
.PHONY: all
all: dirs $(EXES)

# Regola per creare le directory
.PHONY: dirs
dirs:
	mkdir -p bin obj

# Regole per gli eseguibili
bin/pianificatore: $(OBJS_PIANIFICATORE) $(OBJS_get_arg) $(OBJS_read_file) $(OBJS_swap) $(OBJS_itoa) $(OBJS_output)
	$(LD) $(OBJS_read_file) $(OBJS_get_arg) $(OBJS_swap) $(OBJS_itoa) $(OBJS_output) $(OBJS_PIANIFICATORE) -o $@

bin/file_read: $(OBJS_FILE_READ)
	$(LD) -o $@ $(OBJS_FILE_READ)

bin/get_arg: $(OBJS_get_arg)
	$(LD) -o $@ $(OBJS_get_arg)

bin/swap: $(OBJS_swap)
	$(LD) -o $@ $(OBJS_swap)

bin/itoa: $(OBJS_itoa)
	$(LD) -o $@ $(OBJS_itoa)

bin/output: $(OBJS_output)
	$(LD) -o $@ $(OBJS_output)

# Regole per gli oggetti
obj/output.o: src/output.s
	$(AS) $(FLAGS) -o $@ $<

obj/itoa.o: src/itoa.s
	$(AS) $(FLAGS) -o $@ $<

obj/pianificatore.o: src/pianificatore.s
	$(AS) $(FLAGS) -o $@ $<

obj/file_read.o: src/file_read.s
	$(AS) $(FLAGS) -o $@ $<

obj/get_arg.o: src/get_arg.s
	$(AS) $(FLAGS) -o $@ $<

obj/swap.o: src/swap.s
	$(AS) $(FLAGS) -o $@ $<

# Regola per pulire i file compilati
.PHONY: clean
clean:
	rm -f obj/*.o $(EXES) core
