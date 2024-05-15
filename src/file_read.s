.section .data
filename: .ascii "test.txt"    # Nome del file di testo da leggere
fd: .int 0 # file descriptor
buffer: .string ""       # Spazio per il buffer di input
newline: .byte 10        # Valore del simbolo di nuova linea
lines: .int 0            # Numero di linee 

n_args: .int 0
f_arg: .long 0
char_prt: .ascii  "-"

err: .ascii "Errore apertura file - \n"
err_len: .long . - err

done: .ascii "FILE aperto\n"
done_len: .long . - done


.section .text
.global _start

_start:

    mov $5, %eax        # syscall open
    mov $filename, %ebx # Nome del file
    mov $0, %ecx        # Modalità di apertura (O_RDONLY)
    int $0x80           # Interruzione del kernel

    test %eax, %eax
    jz _exit
    
    mov %eax, fd      # Salva il file descriptor in fd

    popl %edx
    popl %edx

    _args:

    popl %ecx
    xor %edx, %edx

    test %ecx, %ecx
    jz _done

    loop:
        movb (%ecx, %edx), %al
        test %al, %al 
        jz _args

        inc %edx

        pushl %edx
        pushl %ecx
        pushl %eax


        movb %al, char_prt

        leal char_prt, %ecx
        ; movl $4, %ecx
        ; movl %eax, %ecx # load character in ecx 
        ; leal char_prt, %ecx    

        movl $4, %eax
        movl $1, %ebx
        movl $1, %edx # lenght
        int $0x80
        
        popl %eax
        xor %eax, %eax

        popl %ecx
        popl %edx
        
        jmp loop


_done:
    movl $4, %eax
    movl $1, %ebx
    leal done, %ecx
    movl done_len, %edx
    int $0x80
    movl $1, %eax         # Set system call EXIT
	xorl %ebx, %ebx       # | <- no error (0)
	int $0x80             # Execute syscall



_exit:
    movl $4, %eax
    movl $1, %ebx
    leal err, %ecx
    movl err_len, %edx
    int $0x80
    movl $1, %eax         # Set system call EXIT
	xorl %ebx, %ebx       # | <- no error (0)
	int $0x80             # Execute syscall
