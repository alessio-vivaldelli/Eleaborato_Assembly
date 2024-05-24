.section .data
    filename:
        .ascii "/home/alessio/Documents/Architettura/ASSEMBLY/Eleaborato/Ordini/atoi_test.txt"

file_descr:
    .int 0
buffer: .string ""
num_buffer: .string ""
num_int: .int 0

num: .int 0

line_len: .int 0
newline: .byte 10
lines: .int 0

.section .bss

.section .text
    .globl read_file

# file opening

# L'indirizzo del file path si trova in ebx
.type read_file, @function
    
read_file:
    movl (%esp), %ebp
    popl %eax
    movl $-1, (%esp)
    
    movl $5, %eax # Open file
    #movl $filename, %ebx # Filename
    movl $0, %ecx  # 'r' mode
    int $0x80

    # 44 -> ','

    # error on file opening
    cmp $0, %eax
    jl _exit


movl %eax, file_descr

pushl $0

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

    cmpb $44, %al
    je new_num
    cmpb $10, %al
    je new_num
    cmpb $3, %al
    je new_num


    jmp atoi_num1

    
# file close 
_close_file:

    movl $6, %eax
    xorl %ebx, %ebx
    int $0x80

    _exit:
    pushl %ebp
    
    ret


atoi_num1:  				

    leal buffer, %esi 		# metto indirizzo della stringa in esi 


    xorl %eax,%eax			# Azzero registri General Purpose
    xorl %ebx,%ebx           
    xorl %ecx,%ecx           
    xorl %edx,%edx
    

    movb (%ecx,%esi,1), %bl

    cmp $10, %bl             # vedo se e' stato letto il carattere '\n'
    je fine_atoi1

    subb $48, %bl            # converte il codice ASCII della cifra nel numero corrisp.



    fine_atoi1:
        xor %eax, %eax
        popl %eax
        movl $10, %ecx 
        mulb %cl    # -> eax = eax*10

        addl %ebx, %eax # eax + bl
        pushl %eax

        jmp _read_loop
        


new_num:
    pushl $0
    jmp _read_loop