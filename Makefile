EXE=bin/pianificatore
AS= as --32
LD= ld -m elf_i386
FLAGS=-gstabs
OBJ=obj/pianificatore.o
GCC=gcc


$(EXE) bin/file_read: $(OBJ) obj/file_read.o
	$(LD) -o $(EXE) $(OBJ)
	$(LD) -o bin/file_read obj/file_read.o	

obj/pianificatore.o: src/pianificatore.s
	$(AS) $(FLAGS) -o obj/pianificatore.o src/pianificatore.s

obj/file_read.o: src/file_read.s
	$(AS) $(FLAGS) -o obj/file_read.o src/file_read.s

clean:
	rm -f *.o $(EXE) core