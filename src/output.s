.section .data
EDF_print: .ascii "Pianificazione EDF:\n"
EDF_len: .long . - EDF_print 

HPF_print: .ascii "Pianificazione HPF:\n"
HPF_len: .long . - HPF_print 
new: .byte 10
sep: .byte 58

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

algo: .int 0
.section .text
.global output

# Questa funzione fa lo switch di due ordini direttamente sullo stack
#Inputs:
# @ %ebx: punta alla stringa del secondo argomento del programma
#
# Note: usare EBP per iterare l'array di valori
.type output, @function
output:
    movl %eax, algo
    cmp $0, %ebx
    jne _open

continue:
    pushl %ebp

    movl algo, %eax
    cmp $1, %eax
    je EDF
    jne HPF

    print_vals:

        movl (%ebp), %eax
        cmp $-1, %eax
        je _continue_end

        # Stampa ID
        movl  fd, %ebx
        movl 12(%ebp), %eax
        call itoa
        # Stampa ':'
        movl $4, %eax 
        movl fd, %ebx 
        leal sep, %ecx 
        movl $1, %edx
        int $0x80
        # Stampa time
        movl  fd, %ebx
        movl time, %eax
        call itoa
        # Stampa '\n'
        movl $4, %eax # sys_write
        movl fd, %ebx  # stram: 1 (stdout), file-descriptor
        leal new, %ecx 
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
    mull %ecx

    movl penality, %edx
    addl %edx, %eax
    movl %eax, penality

    jmp continue_sort

_end:

    
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
    leal new, %ecx 
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
    leal new, %ecx
    movl $1, %edx
    int $0x80

    movl fd, %eax
    cmp $1, %eax
    jne close_file

ret_function:
    popl %ebp
    movl $0, time
    movl $0, penality

    ret


close_file:
    movl $6, %eax        # syscall close
    movl fd, %ecx      # File descriptor
    int $0x80           # Interruzione del kernel
    jmp ret_function

_open:
    mov $5, %eax        # syscall open
    # EBX contiene gia l'indirizzo della stringa 
    movl $1089, %ecx        # Modalità di apertura (O_WRONLY)-> 1 O_APPEND-> 1024. O_WRONLY|O_CREAT|O_APPEND -> 1089 (1+64+1024)
    movl $0644, %edx
    int $0x80           # Interruzione del kernel
    

    # Se c'è un errore, esce
    cmp $0, %eax
    jl err

    mov %eax, fd      # Salva il file descriptor in ebx
    jmp continue

err:
    movl $4, %eax
    call error_handle

    jmp continue

EDF:
    movl $4, %eax 
    movl fd, %ebx 
    leal EDF_print, %ecx 
    movl EDF_len, %edx 
    int $0x80 

    jmp print_vals

HPF:
    movl $4, %eax 
    movl fd, %ebx 
    leal HPF_print, %ecx 
    movl HPF_len, %edx 
    int $0x80 

    jmp print_vals
