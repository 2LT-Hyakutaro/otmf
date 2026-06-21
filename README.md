[![en](https://img.shields.io/badge/README-english-blue.svg)](https://github.com/2LT-Hyakutaro/otmf/blob/main/README.en.md)

# `otmf` - One Tap, Multi Feature 

Questo plugin per QField permette di inserire feature in un Layer vettore in modo istantaneo, premendo un solo tasto sullo schermo del proprio dispositivo.

## Installazione

#### Installazione tramite QR

- Assicurarsi che l'app di QField sul proprio dispositivo abbia l'autorizzazione per l'uso della fotocamera.
- Su un altro dispositivo, aprire [questa pagina](https://github.com/2LT-Hyakutaro/otmf/releases/tag/v0.1) per visualizzare il codice QR.
- Aprire le impostazioni di QField. Nel tab `Generale`, cliccare su `Gestisci plugin`.
- Cliccare su `Installa plugin da URL`, cliccare sul simbolo QR e inquadrare il codice QR aperto sull'altro dispositivo.
- Cliccare su OK, spuntare `Ricorda la mia scelta` e poi Yes per attivare il plugin.

#### Installazione tramite link

- Sul proprio dispositivo mobile, copiare il link del file `otmf.zip` da [questa pagina](https://github.com/2LT-Hyakutaro/otmf/releases/tag/v0.1).
- Aprire le impostazioni di QField. Nel tab `Generale`, cliccare su `Gestisci plugin`. 
- Cliccare su `Installa plugin da URL` e incollare il link copiato.
- Cliccare su OK, spuntare `Ricorda la mia scelta` e poi Yes per attivare il plugin.

## Utilizzo

Questo plugin permette di inserire feature in un layer vettore senza utilizzare ogni volta il form di creazione feature; per farlo è sufficiente:
- creare una feature con tutti i suoi attributi una sola volta attraverso il plugin;
- replicare quella feature quante volte si vuole, usando un solo tasto.


#### Creare una feature 'standard'

1. Premere sul pulsante con il logo OTMF nell'angolo in alto a destra; questo aprirà il menu `Create a new replicable feature`
2. Selezionare tramite il menu a tendina il layer cui si vuole aggiungere la feature; questo farà comparire i vari campi disponibili per le feature di quel layer
3. Compilare i campi; i valori inseriti saranno condivisi da tutte le feature di questo layer create in questo modo
4. Cliccare su OK; nella parte bassa dello schermo comparirà un tasto cliccabile con il nome scelto per la featurem che permette di replicarla quante volte si vuole

#### Replicare una feature

Una volta che una feature 'standard' è stata creata, può essere replicata semplicamente cliccando sul tasto con il nome selezionato durante la creazione.
Di default, la feature viene posizionata sulla posizione corrente del dispositivo
