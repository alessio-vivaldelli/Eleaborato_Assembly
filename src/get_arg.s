.section .data
newline: .byte 10        # Valore del simbolo di nuova linea

n_args: .int 0

err: .ascii "The argument in selected position desn't exist\n"
err_len: .long . - err

done: .ascii "Arg done\n"
done_len: .long . - done
str_len: .long 0

input_add: .long 0
input_add_len: .long 0


.section .text
.global get_arg 

# Questa funzione estrae il n-argomento (dove n è caricato nel registro %ecx)
# e poi mette il risultato nell'indirizzo caricato in %eax, e, nell'indirizzo caricato, in %ebx la lunghezza di quest'ultimo
#
#Inputs:
# @ %ecx: indice dell'argomento da estrarre (1-based)
#Outputs:
# @ %eax: indirizzo dove salvare la stringa
# @ %ebx: indirizzo dove salvare la lunghezza
# 
.type get_arg, @function
    
    get_arg:

    movl %eax, input_add
    movl %ebx, input_add_len

	movl %esp, %ebp # Save stack pointer 

	addl $4, %esp  # +4 for the function call  
                   

    # If no argument, exit
    cmpl $0, (%esp)
    je _exit
check:
	cmp $1, %ecx
	jl dec_esp
	je continue

dec_esp:
	popl %esi
	dec %ecx
	jmp check

continue:

	xor %eax, %eax # eax cleaning

    popl %ecx
    xor %edx, %edx

    test %ecx, %ecx
    jz _exit

    movl input_add, %eax
    movl %ecx, (%eax)
    xor %eax, %eax
    
    # Iterate all argument character 
    movl input_add, %ebx
    loop:
        movb (%ecx, %edx), %al
        test %al, %al 
        jz _done
        
        
        movb  %al, (%ebx, %edx)
        inc %edx
        
        jmp loop
	
_done:

    jmp finish


_exit:
    jmp finish

finish:

    movl input_add_len, %eax
    movl %edx, (%eax)

    movl %ebp, %esp

    ret