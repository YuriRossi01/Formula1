# Formula1
Elaborato Archittettura degli Elaboratori (ASSEMBLY)

Si descriva un programma che simula il sistema di telemetria del videogame F1.
Il sistema fornisce in input i dati grezzi di giri motore (rpm), temperatura motore e velocità
di tutti i piloti presenti in gara per ogni istante di tempo.
Id_ pilota rappresenta un valore numerico che
identifica univocamente un pilota, se il nome del
pilota inserito non è valido il programma deve
restituire la stringa Invalid seguita da un a capo.
OBIETTIVO:
Si descriva un programma Assembly che restituisca i dati relativi al solo pilota indicato
nella prima riga del file, in base alle soglie indicate.

DESCRIZIONE SCELTE PROCEDURALI FATTE:
Per la realizzazione del progetto abbiamo deciso di scrivere tutte le funzioni,
create per semplificare la scrittura del codice, nel file principale telemetry.s.
Le funzioni principali sono: Read_pilot, che usiamo per individuare il pilota da
monitorare scritto nella prima riga del file di input, Chech_id che conta le
occorenze e prepare il file di output con le dovute soglie per ogni valore e le due
funzioni che ci permettono di lavorare con stringhe e numeri facendo conversioni,
ovvero ITOA e ATOI



Prendi un file di testo con dei dati e poi fai il confronto
