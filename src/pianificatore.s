.section .data # sezione variabili globali

str_algo: .ascii "1"
str_algo_len: .long . - str_algo


menu: .ascii "Selezionare l'algoritmo che si vuole utilizzare\n[1] -> Earliest Deadline First (EDF)\n[2] -> Highest Priority First (HPF)\n[3] -> Exit progam\n>" #stringa costante
menu_len: .long . - menu 

EDF_print: .ascii "Pianificazione EDF:\n"
EDF_len: .long . - EDF_print 

HPF_print: .ascii "Pianificazione HPF:\n"
HPF_len: .long . - HPF_print 

ALGO: .long 0
num_arg: .long 0


finish_print_str: .ascii "Finish\n"
finish_len: .long . - finish_print_str

switch_flag: .int 0


fst_arg: .long 0
snd_arg: .long 0


.section .text
.align 4

.global _start  # Punto inizio del programma

_start:

    movl (%esp), %edx
    movl %edx, num_arg # Contiene il valore arg_c "Non è salvato come stringa ma come decimale"
    cmp $1, %edx
    jle no_arg

    popl %ecx # Remove program path
	popl %ecx # and number of args from stack

    popl %ecx
    movl %ecx, fst_arg

    cmp $3, %edx
    jne read_orders
    popl %ecx
    movl %ecx, snd_arg


read_orders:
    xorl %edx, %edx

    movl fst_arg, %ebx
    call read_file
    movl $0, %ebp

main_loop:

    movl $4, %eax
    movl $1, %ebx
    leal menu, %ecx
    movl menu_len, %edx
    int $0x80 

    #scanf
    movl $3, %eax
    movl $1, %ebx
    leal str_algo, %ecx
    movl str_algo_len, %edx
    incl %edx
    int $0x80

    # Sezione che prende il valore che decide l'algoritmo da usare
    leal str_algo, %esi
    movb (%esi), %bl
    cmp $49, %bl
    movl %esp, %ebp
    je EDF_debug_print

    cmp $50, %bl
    je HPF_debug_print

    cmp $51, %bl
    je _exit
    jne algo_error

    
# Sezione dove viene effettuato il sorting degli ordini
sort:

    movl 16(%ebp), %eax
    cmp $-1, %eax
    je reset_ebp

    movl ALGO, %ecx
    cmp $1, %ecx
    je EDF_compare
    jmp HPF_compare

continue_sort:
    addl $16, %ebp
    jmp sort


EDF_debug_print:    
    movl $1, ALGO
    jmp sort
HPF_debug_print:    
    movl $2, ALGO
    jmp sort

reset_ebp:
    movl %esp, %ebp

    movl switch_flag, %ecx
    cmp $0, %ecx
    je end_sorting

    movl $0, switch_flag # Reset flag for bubble sort

    jmp sort    
EDF_compare:
    movl 20(%ebp), %ebx
    cmp 4(%ebp), %ebx
    jl switch_tag
    je EDF_compare_AND

    jmp continue_sort

HPF_compare:
    movl 16(%ebp), %ebx
    cmp (%ebp), %ebx
    jg switch_tag
    je HPF_compare_AND

    jmp continue_sort
HPF_compare_AND:
    movl 20(%ebp), %ebx
    cmp 4(%ebp), %ebx
    jl switch_tag

    jmp continue_sort


switch_tag:
    movl $1, switch_flag
    call swap
    jmp continue_sort

EDF_compare_AND:

    movl 16(%ebp), %ebx
    cmp (%ebp), %ebx
    jg switch_tag

    jmp continue_sort



end_sorting:

    movl snd_arg, %ebx
    movl ALGO, %eax

    call output
    jmp main_loop


no_arg:
    movl $3, %eax
    call error_handle

algo_error:
    movl $2, %eax
    call error_handle
    jmp main_loop

_exit:
    movl $-1, %eax
    call error_handle
