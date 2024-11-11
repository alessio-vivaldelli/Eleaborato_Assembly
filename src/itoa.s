.section .data

car: .byte 0			
new: .byte 10
sep: .byte 10

stream: .int 1
.section .text
	.global itoa

.type itoa, @function	
itoa:  
	movl %ebx, stream
	movl   $0, %ecx		# carica il numero 0 in %ecx

continua_a_dividere:

	cmpl   $10, %eax	# confronta 10 con il contenuto di %eax
	jge dividi			

	pushl %eax			# salva nello stack il contenuto di %eax
	incl %ecx			# contare quante push eseguo
	movl  %ecx, %ebx	# copia in %ebx il valore di %ecx

	jmp stampa			

dividi:

	movl  $0, %edx		# carica il numero 0 in %edx
	movl $10, %ebx		# carica il numero 10 in %ebx
	divl  %ebx			# divide per %ebx (10) il numero ottenuto 

	pushl  %edx			# salva il resto della divisione nello stack
	incl   %ecx			# incrementa il contatore delle cifre 

	jmp	continua_a_dividere 
	
stampa:

	cmpl   $0, %ebx		# controlla se ci sono ancora caratteri da 
						# stampare
	je fine_itoa		# se %ebx=0 ho stampato tutto salto alla 
						# fine della funzione
	popl  %eax			# preleva l'elemento da stampare dallo stack

	movb  %al, car		# memorizza nella variabile car il valore 
						# contenuto negli 8 bit meno significativi 
	addb  $48, car		# somma al valore car il codice ascii dello 0
  
	decl   %ebx			# decrementa di 1 il numero di cifre da printare
	pushw %bx			# salviamo il valore di %bx nello stack per no farlo modificare dalla sys_call

	movl   $4, %eax
	movl   stream, %ebx
	leal  car, %ecx		
	movl    $1, %edx
	int $0x80

	popw   %bx
	jmp   stampa	

fine_itoa:

	ret
