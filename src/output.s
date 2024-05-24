.section .data

new: .byte 10	

fd: .int 1
time: .int 0
penality: .int 0

err_str: .ascii "Errore nell'apertura del file dove salvare i risultati, controllare che esista\n"
err_len: .long . - err_str

ID_Inizio: .ascii ""
ID_Inizio_len: .long . - ID_Inizio

Conclusione: .ascii "Conclusione: "
Conclusione_len: .long . - Conclusione

Penality_str: .ascii "Penality: "
Penality_len: .long . - Penality_str

.section .text
.global output

# Questa funzione fa lo switch di due ordini direttamente sullo stack
#Inputs:
# @ %ebx: punta alla stringa del secondo argomento del programma
# @ %ecx: punta alla lunghezza della stringa del parametro
#
# Note: usare EBP per iterare l'array di valori
.type output, @function
output:
    cmp $0, %ecx
    jne _open

    print_vals:

        movl (%ebp), %eax
        cmp $-1, %eax
        je _end

        # Stampa ID
        movl  fd, %ebx
        movl 12(%ebp), %eax
        call itoa
        # Stampa ':'
        movl $4, %eax 
        movl fd, %ebx 
        movb $58, %cl 
        movl $1, %edx
        int $0x80
        # Stampa time
        movl  fd, %ebx
        movl time, %eax
        call itoa
        # Stampa '\n'
        movl $4, %eax 
        movl fd, %ebx 
        movl new, %ecx 
        movl $1, %edx
        int $0x80

        movl time, %eax
        addl 8(%ebp), %eax
        movl %eax, time

        # scadenza
        movl 4(%ebp), %ebx
        
        subl %ebx, %eax
        cmp $0, %eax
        jg calc_penality        

    continue_sort:
        addl $16, %ebp
        jmp print_vals


calc_penality:
    movl (%ebp), %ecx # -> carico la priorita dell'ordine in ECX
    mul %cl

    movl penality, %eax
    addl %eax, %ecx
    movl %ecx, penality


_end:
    movl fd, %eax
    cmp $1, %eax
    jne close_file
_continue_end:
    # Print conclusione: .. .. 
    movl $4, %eax 
    movl fd, %ebx 
    leal Conclusione, %ecx 
    movl Conclusione_len, %edx
    int $0x80
    # Print time
    movl  fd, %ebx
    movl time, %eax
    call itoa
    # New Line
    movl $4, %eax 
    movl fd, %ebx 
    movb $10, %cl 
    movl $1, %edx
    int $0x80


    # Print conclusione: .. .. 
    movl $4, %eax 
    movl fd, %ebx 
    leal Penality_str, %ecx 
    movl Penality_len, %edx
    int $0x80
    # Print time
    movl  fd, %ebx
    movl penality, %eax
    call itoa
    # New Line
    movl $4, %eax 
    movl fd, %ebx 
    movb $10, %cl 
    movl $1, %edx
    int $0x80

    ret


close_file:
    movl $6, %eax        # syscall close
    movl fd, %ecx      # File descriptor
    int $0x80           # Interruzione del kernel
    jmp _continue_end

_open:
    mov $5, %eax        # syscall open
    # EBX contiene gia l'indirizzo della stringa 
    mov $1, %ecx        # Modalità di apertura (O_WRONLY)
    int $0x80           # Interruzione del kernel

    # Se c'è un errore, esce
    cmp $0, %eax
    jl _exit

    mov %eax, fd      # Salva il file descriptor in ebx


_exit:
    movl $4, %eax 
    movl $2, %ebx 
    leal err_str, %ecx 
    movl err_len, %edx
    int $0x80

    # EXIT
	movl $1, %eax         # Set system call EXIT
	xorl %ebx, %ebx       # | <- no error (0)
	int $0x80             # Execute syscall

    ret