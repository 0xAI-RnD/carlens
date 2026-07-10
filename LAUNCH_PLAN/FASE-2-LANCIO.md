# FASE 2 — Lancio su Google Play

**Obiettivo:** app pubblica in produzione con billing attivo, ASO ottimizzata, beta tester premiati coi codici omaggio. Live entro fine settembre 2026 (buffer sulla review Google) per arrivare a Bologna (fine ottobre) con l'app rodata.
**Prerequisiti:** Fase 1 chiusa con gate PMF superati; `BETA_RESULTS.md` esistente con pricing confermato.

## Azioni del founder (David): 2
1. Approvare store listing (testi + screenshot) prima della submission
2. Post di ringraziamento/annuncio al gruppo beta (Claude scrive la bozza)

---

## Task

### L1 — Feature pre-lancio: share card brandizzata (1-2 giorni — il motore virale della Fase 3)
- RepaintBoundary → immagine: foto scansionata + "Alfa Romeo Giulia Sprint GT 1965" + 2-3 spec chiave + logo CarLens + "Identificata con CarLens" (approccio già documentato in CLAUDE.md § Branded Share Cards; `share_plus` già presente).
- Trigger: bottone share nella schermata risultati. Evento GA4 `share_card`.
- Via GSD (`/gsd:quick`), test inclusi. Se i tempi stringono, è l'UNICA task sacrificabile a post-lancio.

### L2 — Spegnere BETA_MODE, accendere il billing
- Build produzione con BETA_MODE=false: free tier = 5 scan/mese reset automatico, paywall attivo (prezzi confermati in `BETA_RESULTS.md`).
- Migrazione utenti beta: al primo avvio post-update, chi era nel closed testing si trova nel free tier finché non riscatta il codice omaggio — comunicarlo nel post al gruppo beta PRIMA del rollout (gestione aspettative).
- Versione: bump minor (es. 0.17.0 → o direttamente 1.0.0: decidere; raccomandato **1.0.0** — segnale psicologico e ASO).

### L3 — Store listing + ASO (base: `ASO_STRATEGY.md`, adattato Italia-first)
- Titolo: "CarLens: Auto d'Epoca AI" (keyword IT primarie: "auto d'epoca", "riconoscere auto", "auto storiche valore"). Short description + full description con posizionamento consolidato ("identifica, valuta, archivia").
- Screenshot: 6-8 (scan in azione, scheda tecnica, valore di mercato, garage, share card). Claude li genera da emulatore/device con dati demo; David approva.
- Feature graphic + icona verificata. Categoria: Auto e veicoli.
- Data Safety form (da bozza Fase 0), content rating questionnaire, target audience.

### L4 — Submission + rollout
- Rollout production al 100% (utenza minuscola, staged rollout non serve). Review Google: 1-7 giorni; sottomettere con ≥2 settimane di buffer su Bologna.
- Day-1 checks (Claude): install da store pulito, acquisto reale di verifica (poi rimborso), Crashlytics silente, eventi GA4 che fluiscono.

### L5 — Codici omaggio ai beta tester
- Generare promo codes in Play Console (limite: 500/trimestre, ampiamente sufficiente): annuale gratis per chi ha completato il questionario; lifetime ai 3-5 top tester (lista congelata in `BETA_RESULTS.md`).
- Claude scrive il messaggio di ringraziamento con istruzioni riscatto; David lo invia al gruppo.
- I tester premiati sono i primi advocate: nel messaggio, chiedere esplicitamente (a) recensione 5★ sul Play Store se l'app piace, (b) una condivisione. Le prime 15-20 recensioni sono decisive per l'ASO.

### L6 — Kit lancio minimo
- Mini press/media kit in `LAUNCH_PLAN/assets/`: logo, screenshot, boilerplate 100 parole, link store — servirà per club ASI, gruppi FB e stampa di settore in Fase 3.
- Dismissione canale APK-diretto: ultimo appcast che punta gli utenti legacy allo store (o mantenere il Gist con nota di migrazione).

## Criteri di completamento
- [ ] App live in produzione su Google Play, versione 1.0.0
- [ ] Acquisto reale end-to-end verificato; paywall attivo; free tier 5/mese operativo
- [ ] Store listing ASO completo; ≥10 recensioni nei primi 14 giorni (spinta dai beta tester)
- [ ] Codici omaggio distribuiti a tutti gli aventi diritto
- [ ] Crash-free >99% nella prima settimana
- [ ] Share card live (o esplicitamente rinviata con data)
