.section .data

pilot_0_str:
    .string   "Pierre Gasly\0"
pilot_1_str:
    .string   "Charles Leclerc\0"
pilot_2_str:
    .string   "Max Verstappen\0"
pilot_3_str:                       
    .string   "Lando Norris\0"
pilot_4_str:
    .string   "Sebastian Vettel\0"
pilot_5_str:
    .string   "Daniel Ricciardo\0"
pilot_6_str: 
    .string   "Lance Stroll\0"
pilot_7_str:
    .string   "Carlos Sainz\0"
pilot_8_str:
    .string   "Antonio Giovinazzi\0"
pilot_9_str:
    .string   "Kevin Magnussen\0"
pilot_10_str:
    .string  "Alexander Albon\0"
pilot_11_str:
    .string  "Nicholas Latifi\0"
pilot_12_str:
    .string  "Lewis Hamilton\0"
pilot_13_str:
    .string  "Romain Grosjean\0"
pilot_14_str:
    .string  "George Russell\0"
pilot_15_str:
    .string  "Sergio Perez\0"
pilot_16_str:
    .string  "Daniil Kvyat\0"
pilot_17_str:
    .string  "Kimi Raikkonen\0"
pilot_18_str:
    .string  "Esteban Ocon\0"
pilot_19_str:
    .string  "Valtteri Bottas\0"

invalid_pilota_str:	
.string "Invalid"

virgola_str:
.ascii ","

invio_str:
.ascii "\n"

contCaratteri:
.long 0

cont:                   # verrà usato come contatore, conterrà l'id del pilota e il numero di valori di una riga di input che ho letto 
.int 0

length_num:
.long 0

flag_err:
.int 1

cont_pilota:            # variabile in cui vengiono riportare le occorrenze del pilota che voglio monitorare
.long 0

id:
.int 20

rpmMax:
.long 0

tempMax:
.long 0

velocitaMax:
.long 0

velocita_media:         # variabile in cui verra' riportata la velocita' media finale
.long 0

ToPrint:                # variabile utilizzata per nella funzione ITOA per la stampa
.ascii "00000\0"

length_print:
.long 0

store_rpm:
.long 0

store_temperatura:
.long 0

store_velocita:
.long 0

id_str:
.ascii "\0\0\0"

tempo_str:
.ascii "\0\0\0\0\0\0\0\0\0\0\0"

tempo_length:
.long 0

# stringhe soglie (rmp/velocita/temperatura)
low_str:
.ascii "LOW"

medium_str:
.ascii "MEDIUM"

high_str:
.ascii "HIGH"


.section .text
    .global telemetry
telemetry:

#  LETTURA DEI PARAMETRI    ./telemetry input.txt output.txt

movl 4(%esp), %esi      # file testo ricevuto in input
movl 8(%esp), %edi      # file testo di output

# BACKUP REGISTRI: push nello stack
pushl %eax
pushl %ebx
pushl %ecx
pushl %edx

# azzeramento dei registri 
xorl %eax, %eax
xorl %ebx, %ebx
xorl %ecx, %ecx
xorl %edx, %edx


# ETICHETTA CHE EFFETTUA IL CICLO DI LETTURA DI TUTTO IL FILE
# al suo interno chiama:
# - la funzione read_pilot che si occupa di leggere il pilota scritto nella prima riga 
#   del file di input e di confrontarlo con i vari piloti statici per capire a quale corrisponde e salvarsi il rispettivo id.
#   Nel caso in cui il pilota richiesto non dovesse essere presente tra i piloti statici restituira' la stringa 'Invalid'

read_file:
    movb (%esi, %ecx), %al   # sposta in %al la stringa del pilota del file di input (carattere per carattere) 
    cmpb $0, %al             # controllo se sono arrivato alla fine del file ( \0 ) 
    je fine_read_file
    call read_pilot

    movl $0, cont          # azzerro il contatore

    # controllo che non ci siano stati errori durante la chiamate del read pilot 
    cmpl $0, flag_err
    je end_program

    # azzero registri
    xorl %edx, %edx
    xorl %ebx, %ebx


# LETTURA DATI PILOTA
# <tempo>, <id_pilota>, <velocita'>, <rpm>, <temperatura>
read_data:
        # continuo a scorrere il file
        movb (%esi, %ecx), %al   # sposto in %al ogni singolo carattere e lo comparo a 0 per controllare se ho trovato la fine ( \0 )
        cmpb $0, %al             
        je fine_read_file        # se viene trovato lo 0 finisce la lettura

        cmpb $44, %al   # controllo se sono arrivato alla virgola (44 della tabella ASCII)
        je inc_cont     # incremento il numero di valori di una riga di input che ho letto

        cmpb $10, %al   # controllo se sono arrivato alla fine della riga (\n)
        je next_riga 


        # salto alla lettura del dato giusto
        cmpb $0, cont
        je read_tempo                # 0 --> tempo

        cmpb $1, cont
        je read_id                   # 1 --> id

        cmpb $2, cont
        je read_velocità             # 2 --> velocita

        cmpb $3, cont
        je read_rpm                  # 3 --> rpm

        cmpb $4, cont
        je read_temperatura          # 4 --> temperatura

        # LETTURA TEMPO
        read_tempo:                            # "0.01023" 
            leal tempo_str, %ebx     # carico la variabile tampo_str in %ebx 
            movb %al, (%ebx, %edx)   # carico il singolo carattere in %ebx 
            incl %edx                # incremento posizione della variabile  
            incl tempo_length        # incremento il numero di caratteri del tempo che ho letto       
            jmp inc_ecx              # incremento posizione 

        # LETTURA ID
        read_id:
            leal id_str, %ebx        # carico la variabile id_str in %ebx 
            movb %al, (%ebx, %edx)   # carico il singolo carattere in %ebx 
            incl %edx                # incremento posizione della variabile  
            jmp inc_ecx              # incremento ecx 

        # LETTURA VELOCITA
        read_velocità:
            pushl %ecx                  # salvo la posizione di dove sono arrivato nel file facendo la push 
            xorl %ecx, %ecx 
            subb $48, %al               # faccio -48 per avere il valore intero (0 = valore ascii 48) 
            movb %al, %cl               # sposto in %cl 

            # faccio *10 per aggiungere un carattere 
            movl store_velocita, %eax
            movl $10, %ebx              # sposto 10 per fare la moltiplicazione 
            mull %ebx                   # moltiplica %eax per %ebx e il risultato viene memorizzato in EDX:EAX 
           
            addl %ecx, %eax             # carico in %eax il carattere che ho letto ( %ecx ) 
            movl %eax, store_velocita   # carico il risultato 

            popl %ecx                   # riprendo la lettura da dove avevo lasciato 
            jmp inc_ecx

        # LETTURA RPM
        read_rpm:
            pushl %ecx                  # salvo la posizione di dove sono arrivato nel file facendo la push 
            xorl %ecx, %ecx
            subb $48, %al               # faccio -48 per avere il valore intero (0 = valore ascii 48) 
            movb %al, %cl               # sposto in %cl 

            # faccio *10 per aggiungere un carattere 
            movl store_rpm, %eax        
            movl $10, %ebx              # sposto 10 per fare la moltiplicazione 
            mull %ebx                   # moltiplica %eax per %ebx e il risultato viene memorizzato in EDX:EAX 

            addl %ecx, %eax             # carico in %eax il carattere che ho letto ( %ecx ) 
            movl %eax, store_rpm        # carico il risultato 

            popl %ecx                   # riprendo la lettura da dove avevo lasciato 
            jmp inc_ecx


        # LETTURA TEMPERATURA
        read_temperatura:
            pushl %ecx                  # salvo la posizione di dove sono arrivato nel file facendo la push 
            xorl %ecx, %ecx
            subb $48, %al               # faccio -48 per avere il valore intero (0 = valore ascii 48) 
            movb %al, %cl               # sposto in %cl 

            # faccio *10 per aggiungere un carattere 
            movl store_temperatura, %eax 
            movl $10, %ebx                  # sposto 10 per fare la moltiplicazione 
            mull %ebx                       # moltiplica %eax per %ebx e il risultato viene memorizzato in EDX:EAX 

            addl %ecx, %eax                 # carico in %eax il carattere che ho letto ( %ecx ) 
            movl %eax, store_temperatura    # carico il risultato 

            popl %ecx                       # riprendo la lettura da dove avevo lasciato 
            jmp inc_ecx


        # INCREMENTO CONT PER DIRE COSA STIAMO LEGGENDO , ED %ECX PER SCORRERE LA RIGA 
        inc_cont:
        incl cont           # aumento il numero di valori di una riga di input che ho letto (es. tmpo, id_pilota, velocità, rpm, temperatura) 
        xorl %edx, %edx     # azzerro  per lettura (ascii/ char)  
        xorl %ebx, %ebx     # azzerro  per la moltiplicazione 
        jmp inc_ecx

        next_riga:
            # HO FINITO DI LEGGERE UNA RIGA, CONTROLLO SE E' GIUSTA
            call check_id      # chiamo la funzione

            # RESET dell variabili e di cont(per individuare allo switch)
            movl $0, cont  
            movl $0, store_rpm
            movl $0, tempo_length
            movl $0, store_temperatura
            movl $0, store_velocita
            movl $00, id_str
            xorl %ebx, %ebx
            xorl %edx, %edx
    inc_ecx:
        incl %ecx           # incremento la posizione sulla riga per leggerla 
    jmp read_data           # continuo a leggere i dati


fine_read_file:
    # controllo di aver trovato il pilota rchiesto nel file di input tra i piloti statici, se non c'e' stampo invalid
    cmpl $20, id          # se id = 20 vuol dire che non corrisponde a nessun pilota
    jne output_finale
    call stampa_su_file 

    jmp end_program


# OUTPUT FINALE:
# <tempo, soglia_RPM, soglia_temperatura, soglia_velocita>
# <rpm_MAX, temperatura_MAX, velocita_MAX, velocita_MEDIA>    <-- ultima riga

output_finale:
    # ho la stringa su %ecx e la sua lunghezza in %edx
    # (la funzione stampa_su_file richiede questi due parametri)

    # stampa rpm_MAX
    movl rpmMax, %ecx          # output rpmMax
    call ITOA                  # converte in ascii per la stampa
    # ho il valore convertito
    leal ToPrint, %ecx          # ho finito di convertire ed ora carico in %ecx
    movl length_print, %edx     # carico la lunghezza di stringa
    call stampa_su_file         

    # STAMPO VIRGOLA
    leal virgola_str, %ecx
    movl $1, %edx               # lunghezza virgola
    call stampa_su_file

    # STAMPO temperatura_MAX
    movl tempMax, %ecx         # passo in %ecx il numero da convertire
    movl $0, length_print
    call ITOA
    # ho il valore convertito
    leal ToPrint, %ecx          # carico tempMax
    movl length_print, %edx     # carico la sua lunghezza
    call stampa_su_file

    # STAMPO VIRGOLA
    leal virgola_str, %ecx
    movl $1, %edx               # lunghezza stringa
    call stampa_su_file

    # STAMPA velocita_MAX
    movl velocitaMax, %ecx     # passo in %ecx il numero da convertire
    movl $0, length_print
    call ITOA
    # ho il valore convertito
    leal ToPrint, %ecx         # carico velocita_MAX
    movl length_print, %edx    # carico la sua lunghezza
    call stampa_su_file

    # STAMPO VIRGOLA
    leal virgola_str, %ecx
    movl $1, %edx              # lunghezza stringa
    call stampa_su_file


    # velocita_MEDIA
    calcolo_velocita_media:
        xorl %edx, %edx
        xorl %ebx, %ebx
        movl cont_pilota, %ebx        # sposto il numero di occorrenze del pilota da monitorare su %ebx (UTILIZZATO COME DIVISORE per la media)
        movl velocita_media, %eax     # somma delle velocita monitorate
        divl %ebx                     # calcolo %eax / %ebx  (div op -> %eax / op,  quoziente in %eax, resto in %edx)
        movl %eax, velocita_media     # salvo il risultato della div in velocita_media

    movl velocita_media, %ecx         # carico il risultato in %ecx
    movl $0, length_print             # azzerro
   
    call ITOA
     # ho il valore convertito
    
    leal ToPrint, %ecx            # carico velocita media
    movl length_print, %edx       # lunghezza
    
    call stampa_su_file           # stampa velocita' media

    # stampa a capo \n
    leal invio_str, %ecx          # carico \n
    movl $1, %edx                 # lunghezza \n
    call stampa_su_file

end_program:
    # FINISCE IL PROGRAMMA
    popl %edx
    popl %ecx
    popl %ebx
    popl %eax
ret



# FUNZIONE LEGGI PILOTA:  
# leggere il pilota scritto nella prima riga del file di input e di confrontarlo
# con i vari piloti statici per capire a quale corrisponde e salvarsi il rispettivo id.
# Nel caso in cui il pilota richiesto non dovesse essere presente tra i piloti statici restituirà la stringa 'Invalid'

.type read_pilot, @function
read_pilot:

    # CERCO IL PILOTA 

    # **** PILOTA 0 ****
    pilota_0:
    movb (%esi, %ecx), %al          # sposta carattere per carattere la stringa del pilota dato nel file di input in %al 
    cmpb $10, %al                   # controllo di non essere arrivati al carattere di capo linea ( \n ) 
    je fine_lettura

    cmpl $0, cont                   # se la differenza tra cont e $id_pilota (in questo caso 0) è 0, è il pilota giusto 
    jnz pilota_1                    # se è diverso vado al prossimo pilota  
    leal pilot_0_str, %edx          # carico l'indirizzo del pilota 0 in edx 
    cmpb %al, (%edx,%ecx)           # confronto il carattere del pilota in input col carattere del pilota statico 
    jne reset_cont                  # se non sono uguali salta al reset e ricomincio col prossimo pilota 
    
    # se sono uguali proseguo 
    incl %ecx                       # incremento %ecx per scorrere la stringa 
    jmp pilota_0   


    # **** PILOTA 1 ****
    pilota_1:                       # non comentato perchè praticamente ugauale a pilota_0
    movb (%esi, %ecx), %al        
    cmpb $10, %al                 
    je fine_lettura

    cmpl $1, cont                 
    jnz pilota_2                  
    leal pilot_1_str, %edx        
    cmpb %al, (%edx,%ecx)         
    jne reset_cont              

    incl %ecx     
    jmp pilota_1  


    # **** PILOTA 2 ****
    pilota_2:

    movb (%esi, %ecx), %al     
    cmpb $10, %al               
    je fine_lettura

    cmpl $2, cont              
    jne pilota_3                
    leal pilot_2_str, %edx      
    cmpb %al, (%edx,%ecx)       
    jne reset_cont             

    incl %ecx                   
    jmp pilota_2   


    # **** PILOTA 3 ****
    pilota_3:
  
    movb (%esi, %ecx), %al      
    cmpb $10, %al               
    je fine_lettura            

    cmpl $3, cont               
    jne pilota_4                
    leal pilot_3_str, %edx      
    cmpb %al, (%edx,%ecx)       
    jne reset_cont             

    incl %ecx
    jmp pilota_3  
    

    # **** PILOTA 4 ****
    pilota_4:
  
    movb (%esi, %ecx), %al     
    cmpb $10, %al              
    je fine_lettura

    cmpl $4, cont
    jnz pilota_5
    leal pilot_4_str, %edx
    cmpb %al, (%edx,%ecx)
    jne reset_cont

    incl %ecx
    jmp pilota_4     


    # **** PILOTA 5 ****
    pilota_5:
  
    movb (%esi, %ecx), %al     
    cmpb $10, %al              
    je fine_lettura

    cmpl $5, cont              
    jnz pilota_6               
    leal pilot_5_str, %edx     
    cmpb %al, (%edx,%ecx)      
    jne reset_cont            

    incl %ecx                  
    jmp pilota_5               


    # **** PILOTA 6 ****
    pilota_6:

    movb (%esi, %ecx), %al     
    cmpb $10, %al              
    je fine_lettura

    cmpl $6, cont              
    jnz pilota_7               
    leal pilot_6_str, %edx     
    cmpb %al, (%edx,%ecx)      
    jne reset_cont          

    incl %ecx                  
    jmp pilota_6               


    # **** PILOTA 7 ****
    pilota_7:
    
    movb (%esi, %ecx), %al     
    cmpb $10, %al              
    je fine_lettura

    cmpl $7, cont              
    jnz pilota_8               
    leal pilot_7_str, %edx     
    cmpb %al, (%edx,%ecx)      
    jne reset_cont

    incl %ecx                  
    jmp pilota_7               


    # **** PILOTA 8 ****
    pilota_8:
      
    movb (%esi, %ecx), %al     
    cmpb $10, %al              
    je fine_lettura

    cmpl $8, cont              
    jnz pilota_9               
    leal pilot_8_str, %edx     
    cmpb %al, (%edx,%ecx)      
    jne reset_cont           

    incl %ecx                  
    jmp pilota_8               


    # **** PILOTA 9 ****
    pilota_9:
      
    movb (%esi, %ecx), %al     
    cmpb $10, %al              
    je fine_lettura

    cmpl $9, cont              
    jnz pilota_10              
    leal pilot_9_str, %edx     
    cmpb %al, (%edx,%ecx)      
    jne reset_cont
    incl %ecx                  
    jmp pilota_9               


    # **** PILOTA 10 ****
    pilota_10:
    movb (%esi, %ecx), %al     
    cmpb $10, %al              
    je fine_lettura

   
    cmpl $10, cont             
    jnz pilota_11              
    leal pilot_10_str, %edx    
    cmpb %al, (%edx,%ecx)      
    jne reset_cont           

    incl %ecx                  
    jmp pilota_10              


    # **** PILOTA 11 ****
    pilota_11:
      
    movb (%esi, %ecx), %al      
    cmpb $10, %al               
    je fine_lettura

    cmpl $11, cont             
    jnz pilota_12               
    leal pilot_11_str, %edx     
    cmpb %al, (%edx,%ecx)       
    jne reset_cont            

    incl %ecx                   
    jmp pilota_11               


    # **** PILOTA 12 ****
    pilota_12:
      
    movb (%esi, %ecx), %al      
    cmpb $10, %al               
    je fine_lettura

    cmpl $12, cont             
    jnz pilota_13               
    leal pilot_12_str, %edx     
    cmpb %al, (%edx,%ecx)       
    jne reset_cont            

    incl %ecx                   
    jmp pilota_12               


    # **** PILOTA 13 ****
    pilota_13:
      
    movb (%esi, %ecx), %al      
    cmpb $10, %al               
    je fine_lettura

    cmpl $13, cont             
    jnz pilota_14               
    leal pilot_13_str, %edx     
    cmpb %al, (%edx,%ecx)       
    jne reset_cont         

    incl %ecx                   
    jmp pilota_13               


    # **** PILOTA 14 ****
    pilota_14:
      
    movb (%esi, %ecx), %al      
    cmpb $10, %al               
    je fine_lettura

    cmpl $14, cont             
    jnz pilota_15               
    leal pilot_14_str, %edx     
    cmpb %al, (%edx,%ecx)       
    jne reset_cont

    incl %ecx                   
    jmp pilota_14               


    # **** PILOTA 15 ****
    pilota_15:
      
    movb (%esi, %ecx), %al      
    cmpb $10, %al               
    je fine_lettura

    cmpl $15, cont             
    jnz pilota_16               
    leal pilot_15_str, %edx     
    cmpb %al, (%edx,%ecx)       
    jne reset_cont

    incl %ecx
    jmp pilota_15  


    # **** PILOTA 16 ****
    pilota_16:
      
    movb (%esi, %ecx), %al      
    cmpb $10, %al               
    je fine_lettura

    cmpl $16, cont             
    jnz pilota_17               
    leal pilot_16_str, %edx     
    cmpb %al, (%edx,%ecx)       
    jne reset_cont

    incl %ecx                   
    jmp pilota_16               


    # **** PILOTA 17 ****
    pilota_17:
      
    movb (%esi, %ecx), %al      
    cmpb $10, %al               
    je fine_lettura

    cmpl $17, cont             
    jnz pilota_18               
    leal pilot_17_str, %edx     
    cmpb %al, (%edx,%ecx)       
    jne reset_cont

    incl %ecx                   
    jmp pilota_17         


    # **** PILOTA 18 ****
    pilota_18:
      
    movb (%esi, %ecx), %al      
    cmpb $10, %al               
    je fine_lettura

    cmpl $18, cont             
    jnz pilota_19               
    leal pilot_18_str, %edx     
    cmpb %al, (%edx,%ecx)       
    jne reset_cont

    incl %ecx 
    jmp pilota_18              


    # **** PILOTA 19 ****
    pilota_19:
      
    movb (%esi, %ecx), %al      
    cmpb $10, %al              
    je fine_lettura

    cmpl $19, cont              
    jnz errore_pilota                   # invece che saltare al pilota successivo salta a errore_pilota
    leal pilot_19_str, %edx     
    cmpb %al, (%edx,%ecx)       
    jne errore_pilota                   # invece che saltare al reset_cont successivo salta a errore_pilota

    incl %ecx
    jmp pilota_19                       # continuo il ciclo


    # **** ERRORE PILOTA ****
    errore_pilota:                      # se sono arrivato qui, significa che non è stato trovato il pilota giusto 
    leal invalid_pilota_str, %ecx       # carico in %ecx l'indirizzo della invalid_pilota_str 
    movl $7, %edx                       # carico la lunghezza di Invalid in %edx 

    call stampa_su_file                    

    leal invio_str, %ecx                # stampo a capo
    movl $2, %edx                       # carico la lunghezza di invio_str on %edx
    call stampa_su_file

    movl $0, flag_err                   # modifico il valore di flag_err
    jmp end_read_pilot                  # fine della funzione 


    reset_cont:    
    incl cont                           # incremento cont per proseguire coi piloti 
    xorl %ecx, %ecx                     # azzerro ecx (ricomincio dalla prima lettera del prossimo pilota)
    jmp read_pilot    


fine_lettura:
    movl cont, %eax     
    movl %eax, id                       # sposto cont in id in modo da segnare quale id pilota ho nel file

    # prendo il prossimo carattere per il return
    xorl %eax, %eax
    incl %ecx
    movb (%esi, %ecx), %al              # prendo il carattere che mi servirà una volta fatta la ret

end_read_pilot:
ret


# CONTROLLA SE L'ID LETTO E' UGUALE A QUELLO DEL PILOTA CHE SI VUOLE MONITORARE,
# SE SI, CONTA LE OCCORRENZE DEL PILOTA E PREPARA LE STAMPE PER IL FILE DI OUTPUT (stampa il tempo e calcola le soglie dei dati)
# SE NO, NON PRENDE IN CONSIDERAZIONE QUELLA RIGA
.type check_id, @function
check_id:
    pushl %eax
    pushl %ebx
    pushl %ecx
    pushl %edx

    leal id_str, %eax                   # carico id letto in %eax  
    call ATOI   
    cmpl %ecx, id                       # confronto l'id con quello salvato
    jne id_diverso                      # se è diverso "scarto quel pilota"

    # se sono uguali    
    incl cont_pilota                    # conto le occorrenze del pilota che voglio monitorare


    # STAMPA  tempo su file_output
    tempo:
        # stampa tempo
        leal tempo_str, %ecx            # carico in %ecx l'indirizzo della stringa che voglio stampare 
        movl tempo_length, %edx         # dico quanto dovrà essere lungo il messaggio 
        call stampa_su_file         

    # stampa rpm
    rpm:
        # STAMPA VIRGOLA   
        leal virgola_str, %ecx          # carico %ecx il codice ascii della virgola 
        movl $1, %edx                   # carico lunghezza virgola
        call stampa_su_file             # STAMPA virgola su file_output

        movl store_rpm, %ecx            # Sposto il valore di rpm in %ecx
        cmpl rpmMax, %ecx               # confronto rpm >= rpm_max
        jng replace_rpm                 # se MINORE salto a sostituire con LOW MEDIUM HIGH
        movl %ecx, rpmMax               # se MAGGIORE, diventa rpm MAX

        # DEFINIZIONE DELLE SOGLIE di RPM
        replace_rpm:
            # LOW RPM
            cmpl $5000, %ecx
            jg rpm_medium
            
            leal low_str, %ecx          # carico in %ecx la stringa LOW
            movl $3, %edx               # carico lunghezza della stringa LOW
            call stampa_su_file      
            jmp temperatura             # vado a confrontare temperatura

            rpm_medium:
                cmpl $10000, %ecx
                jg rpm_max
                
                leal medium_str, %ecx           # carico in ecx la stringa MEDIUM
                movl $6, %edx                   # carico lunghezza stringa
                call stampa_su_file     
                jmp temperatura                 # vado a confrontare temperatura

                # RPM HIGH output
                rpm_max:
                    leal high_str, %ecx         # carico in ecx la stringa HIGH
                    movl $4, %edx               # dico quanto dovrà essere lungo il messaggio
                    call stampa_su_file         # stampa su FILE_OUT  


    # STAMPA TEMPERATURA 
    temperatura:
        # STAMPA LA VIRGOLA
        leal virgola_str, %ecx              # carico %ecx il codice ascii della virgola 
        movl $1, %edx                       # carico lunghezza virgola
        call stampa_su_file                 # STAMPA virgola su file_output

        movl store_temperatura, %ecx
        cmpl tempMax, %ecx                  # controllo se temp >= tempMax
        jng replace_temperature             # se no salto e faccio la sostituzione con LOW MEDIUM HIGH
        movl %ecx, tempMax                  # se si , questo dato è temp Max

        # DEFINIZIONE DELLE SOGLIE di temperatura
        replace_temperature:
            # LOW temperatura
            cmpl $90, %ecx                  # confronto 
            jg temp_medium
          
            leal low_str, %ecx              # carico la stringa LOW per la stampa
            movl $3, %edx                   # carico la lunghezza della stringa LOW
            call stampa_su_file             # stampa su FILE_OUT
            jmp velocita                    # vado a controllare la velocità 

            temp_medium:
                cmpl $110, %ecx
                jg temp_high

                leal medium_str, %ecx       # carico la stringa MEDIUM per la stampa
                movl $6, %edx               # carico la lunghezza di stringa
                call stampa_su_file         
                jmp velocita                # vado a controllare velocità

                temp_high:
                leal high_str, %ecx         # carico la stringa HIGH per la stampa
                movl $4, %edx               # carico la lunghezza di stringa
                call stampa_su_file    


    # STAMPA VELOCITA
    velocita:
        # STAMPA LA VIRGOLA
        leal virgola_str, %ecx              # carico %ecx il codice ascii della virgola 
        movl $1, %edx                       # carico lunghezza virgola
        call stampa_su_file                 # STAMPA virgola su file_output

        movl store_velocita, %ecx
        addl %ecx, velocita_media           # sommo la velocità alla velocità media

        cmpl velocitaMax, %ecx              # controllo se velocità >= velocitàMax
        jng replace_velocita                # se no salto e faccio la sostituzione con LOW MEDIUM HIGH
        movl %ecx, velocitaMax              # se si , questo dato è velocità Max

        # DEFINIZIONE DELLE SOGLIE di velocità
        replace_velocita:
            cmpl $100, %ecx                 # confronto
            jg velocita_medium
            # output low
           
            leal low_str, %ecx              # carico la stringa low per la stampa
            movl $3, %edx                   # carico la lunghezza di stringa
            call stampa_su_file             # stampa su FILE_OUT
            jmp stampa_invio                # vado a calcolare la velocità media

            velocita_medium:
                cmpl $250, %ecx
                jg velocita_high
                # output medium
                leal medium_str, %ecx       # carico la stringa medium per la stampa
                movl $6, %edx               # carico la lunghezza di stringa
                call stampa_su_file         # stampa su FILE_OUT
                jmp stampa_invio

                velocita_high:
                # output high
                leal high_str, %ecx         # carico la stringa high per la stampa
                movl $4, %edx               # carico la lunghezza
                call stampa_su_file         # stampa su FILE_OUT
    

    stampa_invio:    # stampa \n
        leal invio_str, %ecx                # carico la stringa \n in ecx
        movl $1, %edx                       # carico la lunghezza 
        call stampa_su_file                 # scrivo l'output sul file


    id_diverso:
        popl %edx
        popl %ecx
        popl %ebx
        popl %eax
ret


# ATOI:   CONTINUO A DIVIDERE PER 10, E CARICO IL RESTO IN %ECX E MOLTIPLICO PER 10
# in %EAX ho l'id letto / %ECX ho il resto
.type ATOI, @function
ATOI:
    xorl %ecx, %ecx 

    pushl %eax
    pushl %ebx
    pushl %edx
    pushl %esi

    movl %eax, %esi                 # carico id letto in %esi per la conversione 
    movl $0, length_num             # reset per la lunghezza num 

    conversione_atoi:
        pushl %ecx                  
        movl length_num, %ecx       # metto temporaneamente il valore di length_num in ecx
        movb (%esi,%ecx), %dl       # prendo il carattere nella posizione di ecx(length_num) 
        popl %ecx                   # restore

        cmpb $0, %dl                # controllo se è 0, se si, finisce
        je end_atoi

        subb $48, %dl               # sottraggo 48 a %dl, per avere il numero 
        pushl %edx                  # carico %edx dove ho il numero da caricare in ecx
        movl $10, %ebx              

        movl %ecx, %eax             # sposto il numero intero in %eax, per aggiungergli un altro pezzo
        mull %ebx                   # ebx * eax = NUMERO SIGNIFICATIVO IN EDX
        popl %edx                   
        addb %dl, %al               # sommo il numero convertito
        movl %eax, %ecx             # metto il numero che sto convertendo il %ecx

        incl length_num             # incremento la lunghezza del numero
        jmp conversione_atoi        # continuo a fare la conversione 

    end_atoi: 
    # FINE CONVERSIONE
    popl %esi
    popl %edx
    popl %ebx
    popl %eax
ret


.type ITOA, @function
ITOA:
    # CONTINUO A DIVIDERE PER 10, E CARICO RESTO IN %ECX. 
    # aggiungo offset 48 per avere il valore in ascii

    leal ToPrint, %esi
    movl %ecx, %eax                 # in %ecx ho il numero da convertire 

    # CONTA IL NUMERO DI CARATTERI DA CONVERTIRE
    contatore:
    cmpl $0, %eax                   # se il risultato della divisione tra i 2 numeri è 0
    jz ho_zero                      # ho solo 0, quindi stampo quellp

    xorl %edx, %edx                 # reset il registro dove contiene mio resto(num) da stampare

    movl $10, %ebx                  # sposto 10 nel divisore
    divl %ebx                       # cosi ho il risultato in eax 

    incl length_print               # aumento il cont length per stampare sul file

    cmpl $0, %eax                   # controllo se sono arrivato a ultimo carattere
    jz end_contatore                # FINISCE

    jmp contatore

    ho_zero:
    # ho solo un carattere 0
    movl $0, %ecx
    movl $1, length_print

    end_contatore:
    # sposto il risultato in eax
    movl %ecx, %eax
    pushl length_print

    # CONVERSIONE DA ECX E LI CONVERTO IN ASCII 
    conversione:


    # memorizzo in eax il numero 

    movl length_print, %ecx         # carico la lunghezza contata prima
    cmpl $0, %ecx                   # controllo se ho ancora caratteri da stampare

    jz end_conversione_ITOA

    xorl %edx, %edx                 # resetto il registro in modo tale che non interferisca con la divisione

    movl $10, %ebx                  # sposto 10 per fare la divisione
    divl %ebx                       # ho edx come mio resto
    addl $48, %edx                  # ho il valore convertito in edx


    movl length_print, %ecx
    decl %ecx                       # decremento la posizione per dopo inserire il carattere
                                
    movb %dl, (%esi,%ecx)           # inserisci il carattere utilizzando movb, perchè cosi non va a inserire cose strane

    decl length_print               # decremento il numero di carattere da convertire ancora
    
    jmp conversione

    end_conversione_ITOA:
    popl length_print               # ripristino il numero per stampare
ret


.type stampa_su_file, @function    

    # FUNZIONE STAMPA SU FILE 
    # dove ho la stringa che voglio stampare in %ECX e la sua lunghezza in %EDX 
    stampa_su_file:
    xorl %eax, %eax
    xorl %ebx, %ebx

    carico:
    cmpl $0, %edx               # controllo se sono arrivato alla fine della stringa 
    je end_stampa

    # backup 
    pushl %edx                  # salvo il numero di caratteri della stringa Invalid 
    xorl %edx, %edx

    movl contCaratteri, %edx
    movb (%ecx, %eax), %bl      # prendo il singolo carattere e lo metto dentro %bl 
    movb %bl, (%edi, %edx)      # SCRITTURA: scrivo nel file di output 

    popl %edx                   # restore
    
    incl %eax                   # incremento contatore posizione (%eax) 
    incl contCaratteri          # incremento il contatore dei caratteri scritti in output 
    decl %edx                   # decremento il numero di caratteri che mi restano da stampare 
    jmp carico

    end_stampa:
    ret
    
    
    
