.section .data # sezione variabili globali

menu: .ascii "Selezionare l'algoritmo che si vuole utilizzare\n[1]->EDF\n[2]->HPF\n>" #stringa costante
menu_len: .long . - menu 

EDF_print: .ascii "Usiamo EDF\n"
EDF_len: .long . - EDF_print 

HPF_print: .ascii "Usiamo HPF\n"
HPF_len: .long . - HPF_print 

ALGO: .long 0
num_arg: .long 0

new_line_char: .byte 10



# Dynamic variable section
.section .bss
    str_algo: .string ""
    order_txt: .string ""
    output_txt: .string ""

.section .text
.align 4

.global _start  # Punto inizio del programma

_start:
    movl (%esp), %edx
    movl %edx, num_arg # Contiene il valore arg_c "Non è salvato come stringa ma come decimale"
    xorl %edx, %edx

    movl %esp, %ebp # Salva una copia di ESP in EBP per poter
    # modificare ESP senza problemi.
    # In questo punto dell'esecuzione ESP contiene
    # l'indirizzo di memoria della locazione in cui
    # si trova il numero di argomenti passati alla
    # riga di comando del programma.
    

    ancora:
    addl $4, %esp   # Somma 4 al valore di ESP. In tal modo ESP
                    # punta al prossimo elemento sulla cima dello
                    # stack, che contiene l'indirizzo di memoria
                    # del prossimo parametro della riga di comando.
                    # Alla prima iterazione, dopo questa
                    # istruzione, ESP punta all'elemento dello
                    # stack che contiene l'indirizzo della
                    # locazione di memoria che contiene il nome del
                    # programma.
    movl (%esp), %eax # Copia in EAX il contenuto della locazione
                      # di memoria puntata da ESP, cioè copia in EAX
                      # il puntatore al prossimo parametro della riga
                      # di comando (oppure NULL se non ci sono altri
                      # parametri).
    testl %eax, %eax # Controlla se EAX contiene NULL (cioè 0). In
                      # tal caso significa che ho già recuperato
                      # tutti i parametri.
    jz fine_ancora # Esce dal ciclo se non ci sono altri parametri
                    # da recuperare.
    call stampa_parametro # Richiama la funzione per stampare il
                            # parametro. ESP punta alla locazione di memoria
                            # che contiene l'indirizzo del parametro da
                            # considerare. Al posto di tale funzione si
                            # potrebbe inserire il codice che elabora il
                            # dato, invece di stamparlo.
    jmp ancora # Ricomincia il ciclo per recuperare gli altri
                # parametri.



    .type stampa_parametro, @function # Definizione della funzione
    # stampa_parametro per la stampa del parametro.
    stampa_parametro:
    pushl %ebp # Salva il contenuto di EBP sullo stack per
    # poter rendere disponibile il registro EBP.
    movl %esp, %ebp # Salva su EBP il valore di ESP per poter
    # rendere disponibile il registro ESP.

    movl 8(%ebp), %ecx # Carica ECX con il valore contenuto alla
    # locazione di memoria il cui indirizzo si
    # ottiene sommando 8 al valore contenuto in
    # EBP. Ora ECX contiene il puntatore alla
    # stringa da stampare. Bisogna sommare 8 poiché
    # sono state eseguite 2 operazioni sullo stack
    # che hanno incrementato il valore di ESP di 8:
    # una CALL e una PUSH!!!$4
    xorl %edx, %edx # azzera EDX
    conteggio_caratteri: # Vengono contati quanti sono i caratteri della
    # stringa corrispondente al parametro da
    # stampare.
    movb (%ecx,%edx), %al # Carica in AL il carattere puntato da
    # ECX+EDX.
    testb %al, %al # Controlla se la stringa è finita (tutte le
    # stringhe terminano con 0).
    jz finito_conteggio # Se la stringa è finita salta alla parte di
    # codice che esegue la stampa
    incl %edx # Se la stringa non è finita incrementa il
    # contatore dei caratteri.
    jmp conteggio_caratteri # Prosegui con il conteggio dei caratteri.

    finito_conteggio: # Blocco di codice che usa la funzione di
    # sistema write
    movl $4, %eax # EAX=4
    movl $1, %ebx # EBX=1 (cioé video)
    # ECX punta già alla stringa
    # EDX contiene già il numero di caratteri da
    int $0x80 # stampare
    movl $4, %eax # Blocco di codice che stampa il carattere di
    # ritorno a capo
    movl $1, %ebx # EBX=1 (cioé video)
    leal new_line_char, %ecx # ECX contiene l’indirizzo della variabile
    # che contiene il carattere “a capo”

    movl $1, %edx # stampo un solo carattere
    int $0x80
    movl %ebp, %esp # Riporta ESP al valore che aveva appena
    # entrati nella funzione.
    popl %ebp # Riporta EBP al valore che aveva appena
    # entrati nella funzione.
    Ret # Ritorna dalla chiamata a funzione. Se prima
    # della ret non si riporta ESP e EBP al valore
    # originario, sono guai!!! Ricordare che
    # l'istruzione CALL salva nello stack il valore
    # di ritorno per il program counter!!



    fine_ancora:
    movl $4, %eax # metto in EAX il codice della system call WRITE.
    movl $1, %ebx # Metti in EBX il file descritto del stdout. "Stream di output 1"
    leal menu, %ecx # Metto in ECX (deciso dalla documentazione), i'indirizzo di inizio della stringa. Si in questo registro l'indirizzo di quello che vogliamo stampare
    movl menu_len, %edx # carico il valore di hello nel registro EDX
    int $0x80 # Lancia l'interrupt generico 0x80 per eseguire quello che ho scritto. controlla i valori di eax,ebx e ecx quindi capisce di stampare

    movl $3, %eax         # Set system call READ
    movl $0, %ebx         # | <- keyboard
    leal str_algo, %ecx   # | <- destination
    movl $50, %edx        # | <- string length
    int $0x80             # Execute syscall

    leal str_algo, %esi
    movb (%esi), %bl
    cmp $49, %bl
    
    je EDF_algo
    jne HPF_algo

EDF_algo:
    movl $4, %eax # metto in EAX il codice della system call WRITE.
    movl $1, %ebx # Metti in EBX il file descritto del stdout. "Stream di output 1"
    leal EDF_print, %ecx # Metto in ECX (deciso dalla documentazione), i'indirizzo di inizio della stringa. Si in questo registro l'indirizzo di quello che vogliamo stampare
    movl EDF_len, %edx # carico il valore di hello nel registro EDX
    int $0x80 # Lancia l'interrupt generico 0x80 per eseguire quello che ho scritto. controlla i valori di eax,ebx e ecx quindi capisce di stampare
    movl $1, ALGO
    jmp continue
HPF_algo:
    movl $4, %eax # metto in EAX il codice della system call WRITE.
    movl $1, %ebx # Metti in EBX il file descritto del stdout. "Stream di output 1"
    leal HPF_print, %ecx # Metto in ECX (deciso dalla documentazione), i'indirizzo di inizio della stringa. Si in questo registro l'indirizzo di quello che vogliamo stampare
    movl HPF_len, %edx # carico il valore di hello nel registro EDX
    int $0x80 # Lancia l'interrupt generico 0x80 per eseguire quello che ho scritto. controlla i valori di eax,ebx e ecx quindi capisce di stampare
    movl $2, ALGO
    jmp continue


continue:



    # EXIT
	movl $1, %eax         # Set system call EXIT
	xorl %ebx, %ebx       # | <- no error (0)
	int $0x80             # Execute syscall
