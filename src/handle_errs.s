.section .data

# ID: 1
orders_str: .ascii "Errore nell'apertura del file ordini.\nIl file specificato potrebbe non esistere.\n"
orders_len: .long . - orders_str

# ID: 2
algo_str: .ascii "Selezione dell'algoritmo da usare non valida. Inserire un nuovo valore.\n\n"
algo_len: .long . - algo_str

# ID: 3
param_str: .ascii "Non e' stato inserito nessun file degli ordini, specificarne uno con la sintassi './pianificatore <file_path>'\n"
param_len: .long . - param_str

# ID: 4
output_str: .ascii "Errore nella creazione/apertura del file dove salvare il risultato dell'algoritmo\n"
output_len: .long . - output_str

# ID: 5
vals_str: .ascii "Il file degli ordini contiene un errore, ricontrollarlo e verificare che i valori, e la sintassi, siano validi\n"
vals_len: .long . - vals_str

str: .string ""
str_len: .int 0

input_add: .long 0
input_add_len: .long 0


.section .text
.global error_handle 

# Funzione per printare gli errori che possono presentarsi
#Inputs:
# @ %eax: tipologia di errore

.type error_handle, @function
    
error_handle:
    cmp $1, %eax
    je orders

    cmp $2, %eax
    je algo_select

    cmp $3, %eax
    je param

    cmp $4, %eax
    je _output

    cmp $5, %eax
    je order_vals

    cmp $-1, %eax
    je _exit

orders:
    movl $4, %eax 
    movl $1, %ebx 
    leal orders_str, %ecx
    movl orders_len, %edx
    int $0x80 
    jmp _exit

algo_select:
    movl $4, %eax 
    movl $1, %ebx 
    leal algo_str, %ecx
    movl algo_len, %edx
    int $0x80
    
    ret 

param:
    movl $4, %eax 
    movl $1, %ebx 
    leal param_str, %ecx
    movl param_len, %edx
    int $0x80 
    jmp _exit

_output:
    movl $4, %eax 
    movl $1, %ebx 
    leal output_str, %ecx
    movl output_len, %edx
    int $0x80 

    ret

order_vals:
    movl $4, %eax 
    movl $1, %ebx 
    leal vals_str, %ecx
    movl vals_len, %edx
    int $0x80 
    jmp _exit
_exit:
	movl $1, %eax
	xorl %ebx, %ebx
	int $0x80

