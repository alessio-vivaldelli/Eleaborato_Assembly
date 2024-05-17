.section .data # sezione variabili globali

menu: .ascii "Selezionare l'algoritmo che si vuole utilizzare\n[1]->EDF\n[2]->HPF\n>" #stringa costante
menu_len: .long . - menu 

EDF_print: .ascii "Usiamo EDF\n"
EDF_len: .long . - EDF_print 

HPF_print: .ascii "Usiamo HPF\n"
HPF_len: .long . - HPF_print 

ALGO: .long 0
num_arg: .long 0

new_line_char: .byte 10

fst_arg_len: .long 0
snd_arg_len: .long 0

# Dynamic variable section
.section .bss
    str_algo: .string ""
    fst_arg: .string ""
    snd_arg: .string ""
.section .text
.align 4

.global _start  # Punto inizio del programma

_start:

    movl (%esp), %edx
    movl %edx, num_arg # Contiene il valore arg_c "Non è salvato come stringa ma comstr_lene decimale"
    xorl %edx, %edx

    popl %ecx # Remove program path
	popl %ecx # and number of args from stack

    # Ges first parameter
    movl $1, %ecx
    leal fst_arg, %eax
    leal fst_arg_len, %ebx
    call get_arg

 

    # Get second parameter
    movl $2, %ecx
    leal snd_arg, %eax
    leal snd_arg_len, %ebx
    call get_arg


    movl $4, %eax # metto in EAX il codice della system call WRITE.
    movl $1, %ebx # Metti in EBX il file descritto del stdout. "Stream di output 1"
    leal menu, %ecx # Metto in ECX (deciso dalla documentazione), i'indirizzo di inizio della stringa. Si in questo registro l'indirizzo di quello che vogliamo stampare
    movl menu_len, %edx # carico il valore di hello nel registro EDX
    int $0x80 # Lancia l'interrupt generico 0x80 per eseguire quello che ho scritto. controlla i valori di eax,ebx e ecx quindi capisce di stampare

    movl $3, %eax         # Set system call READ
    movl $0, %ebx         # | <- keyboard
    leal str_algo, %ecx   # | <- destination
    movl $50, %edx        # | <- string length
    int $0x80             # Execute syscall

    leal str_algo, %esi
    movb (%esi), %bl
    cmp $49, %bl
    
    je EDF_algo
    jne HPF_algo

EDF_algo:
    movl $4, %eax # metto in EAX il codice della system call WRITE.
    movl $1, %ebx # Metti in EBX il file descritto del stdout. "Stream di output 1"
    leal EDF_print, %ecx # Metto in ECX (deciso dalla documentazione), i'indirizzo di inizio della stringa. Si in questo registro l'indirizzo di quello che vogliamo stampare
    movl EDF_len, %edx # carico il valore di hello nel registro EDX
    int $0x80 # Lancia l'interrupt generico 0x80 per eseguire quello che ho scritto. controlla i valori di eax,ebx e ecx quindi capisce di stampare
    movl $1, ALGO
    jmp continue
HPF_algo:
    movl $4, %eax # metto in EAX il codice della system call WRITE.
    movl $1, %ebx # Metti in EBX il file descritto del stdout. "Stream di output 1"
    leal HPF_print, %ecx # Metto in ECX (deciso dalla documentazione), i'indirizzo di inizio della stringa. Si in questo registro l'indirizzo di quello che vogliamo stampare
    movl HPF_len, %edx # carico il valore di hello nel registro EDX
    int $0x80 # Lancia l'interrupt generico 0x80 per eseguire quello che ho scritto. controlla i valori di eax,ebx e ecx quindi capisce di stampare
    movl $2, ALGO
    jmp continue


continue:
    # EXIT
	movl $1, %eax         # Set system call EXIT
	xorl %ebx, %ebx       # | <- no error (0)
	int $0x80             # Execute syscall
