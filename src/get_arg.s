.section .data
newline: .byte 10        # Valore del simbolo di nuova linea

n_args: .int 0

err: .ascii "The argument in selected position desn't exist\n"
err_len: .long . - err

done: .ascii "Arg done\n"
done_len: .long . - done
str_len: .long 0

# Dynamic variable section
.section .bss
    arg_str: .string ""


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

	movl %esp, %ebp # Save stack pointer and base pointer

	addl $4, %esp # Return to argument position, +4 after pushls
                   # +4 for the function call  

    # If no argument, exit
    cmpl $0, (%esp)
    je _exit

	#xor %ecx, %ecx

	# movl $1, %ecx		# Simulate n_args as funztion parameter passed 

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

    leal arg_str, %ebx

    # Iterate all argument character 
    loop:
        movb (%ecx, %edx), %al
        test %al, %al 
        jz _done

        movb %al, (%ebx, %edx)
        inc %edx
        
        jmp loop
	
_done:
    leal arg_str, %eax
    movl %edx, str_len

    movb $0, (%ebx, %edx) # Add terminator char to arg_str
    # Print argument (for debugging)
	movl $4, %eax 
    movl $1, %ebx
    leal arg_str, %ecx
    movl %edx, %edx
    int $0x80


    movl $4, %eax
    movl $1, %ebx
    leal done, %ecx
    movl done_len, %edx
    int $0x80
    
    jmp finish


_exit:

    movl $4, %eax
    movl $1, %ebx
    leal err, %ecx
    movl err_len, %edx
    int $0x80

    jmp finish

finish:
    movl %ebp, %esp
    ret