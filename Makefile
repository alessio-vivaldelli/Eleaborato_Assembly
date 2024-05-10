EXE_C=build/main.o
EXE_S=build/test

AS=as --32
LD=ld -m elf_i386
FLAGS=-gstabs
OBJ_C=main.c
OBJ_S=build/main_S.o

GCC=gcc



$(EXE_C): $(OBJ_C)
	$(GCC) $(FLAGS) $(OBJ_C) -o $(EXE_C)

$(OBJ_S): ASM/test.s
	$(AS) $(FLAGS) -o $(OBJ_S) ASM/test.s

$(EXE_S): $(OBJ_S)
	$(LD) -o $(EXE_S) $(OBJ_S)


clean:
	rm -f *.o $(EXE_C) core