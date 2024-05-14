.section .data
filename: .ascii "test.txt"    # Nome del file di testo da leggere
fd: .int 0 # file descriptor
buffer: .string ""       # Spazio per il buffer di input
newline: .byte 10        # Valore del simbolo di nuova linea
lines: .int 0            # Numero di linee 

err: .ascii "Errore apertura file\n"
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
    jl _exit
    
    mov %eax, fd      # Salva il file descriptor in ebx



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
