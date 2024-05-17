.section .data
    filename:
        .ascii "ordini.txt"

file_descr:
    .int 0
buffer: .string ""
newline: .byte 10
lines: .int 0

.section .bss

.section .text
    .globl _start

# file opening

_open:
    movl $5, %eax
    movl $filename, %ebx
    movl $0, %ecx
    int $0x80

# error on file opening

    cmp $0, %eax
    jl _exit


movl %eax, file_descr

_read_loop:
    movl $3, %eax
    movl file_descr, %ebx
    movl $buffer, %ecx
    movl $1, %edx
    int $0x80

    # controllo errori file
    cmp $0, %eax
    jle _close_file 

    # controllo se ho una nuova linea
    movb buffer, %al
    cmpb newline, %al 
    jne _print_line
    incw lines 


_print_line:
    movl $4, %eax
    movl $1, %ebx
    leal buffer, %ecx
    movl $1, %edx
    int $0x80

    jmp _read_loop

# file close 
_close_file:
    movl $6, %eax
    xorl %ebx, %ebx
    int $0x80

    _exit:
    mov $1, %eax       
    xor %ebx, %ebx      
    int $0x80

_start:
    jmp _open

    # end 
    jmp _exit    
