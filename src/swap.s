.section .data

tmp_id: .int 0
tmp_durata: .int 0
tmp_scadenza: .int 0
tmp_priority: .int 0

.section .bss

.section .text
.global swap

# Questa funzione fa lo switch di due ordini direttamente sullo stack
#Inputs:
# @ %ebp: puntatore dell'ordine sullos tack, il secondo con cui switchare
#         sara' %ebp+16
.type swap, @function
swap:
    movl 12(%ebp), %ecx
    movl %ecx, tmp_id
    movl 8(%ebp), %ecx
    movl %ecx, tmp_durata
    movl 4(%ebp), %ecx
    movl %ecx, tmp_scadenza
    movl (%ebp), %ecx
    movl %ecx, tmp_priority

    #ID
    movl 28(%ebp), %ecx
    movl %ecx, 12(%ebp)
    # Durata
    movl 24(%ebp), %ecx
    movl %ecx, 8(%ebp)
    # Scadenza
    movl 20(%ebp), %ecx
    movl %ecx, 4(%ebp)
    # Priorita
    movl 16(%ebp), %ecx
    movl %ecx, (%ebp)


    #ID
    movl tmp_id, %ecx
    movl %ecx, 28(%ebp)
    # Durata
    movl tmp_durata, %ecx
    movl %ecx, 24(%ebp)
    # Scadenza
    movl tmp_scadenza, %ecx
    movl %ecx, 20(%ebp)
    # Priorita
    movl tmp_priority, %ecx
    movl %ecx, 16(%ebp)    

    ret
