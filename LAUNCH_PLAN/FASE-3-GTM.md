# FASE 3 — Go-To-Market organico (+ test paid)

**Obiettivo:** primi 3.000-6.000 install e 100-250 abbonati entro 12 mesi dal lancio (SOM anno 1 della review 10/07/2026), a costo quasi zero, con carico ricorrente compatibile col vincolo low-effort (<5h/settimana founder, il resto automatizzabile da Claude).
**Prerequisiti:** Fase 2 completa (app live, share card, press kit).
**Periodo:** da ottobre 2026, continuativo.

## Azioni del founder (David) — ricorrenti
- Presenza fisica: Bologna (1 weekend, ottobre) + 1 raduno/evento al mese nella stagione
- Pubblicare i post che Claude prepara (gruppi FB richiedono account personale)
- 15 min/settimana: report KPI di Claude

---

## Canali, in ordine di priorità

### C1 — Auto e Moto d'Epoca, Bologna (fine ottobre 2026) — il momento GTM massimo
- David visita da visitatore (no stand: costo non giustificato al primo anno) con: QR card stampate, app rodata, pitch 10".
- Uso live: identificare auto esposte davanti ad altri visitatori = demo naturale.
- Preparazione (Claude, entro metà ottobre): QR cards A6 (fronte: claim + QR; retro: 3 feature), lista espositori/club presenti da contattare dopo (raccolta contatti al padiglione club).
- Target: 100-300 install nel weekend + 20-30 contatti club.

### C2 — "Noi del Toret" post-beta + espansione "Noi del…"
- Dopo la beta la community conosce già l'app. Proporre agli organizzatori (bozza DM/email di Claude): post/story di lancio + eventuale "CarLens challenge" a un evento (chi scansiona l'auto più rara vince lifetime).
- **Espansione**: mappare le community omologhe nelle altre città (il format "community locale motori/lifestyle su IG" esiste ovunque: Milano, Bologna, Roma…). Task ricorrente Claude: ricerca 2 community/mese, bozza outreach, David invia. Replicare il playbook Toret dove risponde.
- Caveat dal beta test: se i dati Fase 1 mostrano retention bassa del segmento Toret (generalista) vs appassionati, declassare C2 a canale awareness e concentrare la spesa di tempo su C3/C4 (appassionati puri).

### C3 — Gruppi Facebook auto d'epoca (canale dominante per la demografia 50+ IT)
- Claude mappa i 15-20 gruppi IT più grandi (auto storiche, marchi specifici: Alfa, Lancia, Fiat 500, youngtimer…), con regole di ogni gruppo.
- Cadenza: 2 post/settimana totali, MAI spam: formato valore ("Ho fotografato questa al raduno X, sapete che…" + scheda dall'app), rotazione gruppi, engagement nei commenti.
- Claude prepara il calendario editoriale mensile + bozze; David pubblica (o si valuta pagina FB CarLens che posta nei gruppi dove consentito).
- KPI: install con UTM/referral "fb" (proxy: picchi install nei giorni di post).

### C4 — Club ASI locali (~350 in Italia, iniziare dai ~30 piemontesi)
- Claude prepara: lista club Piemonte/Lombardia con email pubbliche, template email (proposta: app gratuita per i soci fino a fine anno / sconto convenzione 20% sull'annuale, demo al prossimo direttivo).
- David invia 5 email/settimana dal suo indirizzo. Follow-up gestito da Claude (bozze).
- Target: 5-10 club attivi in 6 mesi. Un club da 200 soci attivi vale più di 1.000 install freddi.

### C5 — Test paid Meta (€100-200, una tantum, mese 2-3 post-lancio)
- Setup (Claude prepara, David esegue su Ads Manager): 1 campagna install, target IT, 45-65 anni, interessi auto d'epoca/ASI/Ruoteclassiche/marchi storici, solo Android, creative = share card reale + video scan 15".
- Budget €10/giorno × 15-20 giorni. Misura: CPI e, con GA4, conversione install→paid.
- **Kill criterion (deciso): CAC per abbonato >€40 → stop paid definitivo, si resta organici.** Se <€25, valutare €100/mese continuativi.

### C6 — Contenuto "reveal" TikTok/Reels (opzionale, solo se David vuole)
- Format: video 15" scan dal vivo a un raduno → reveal della scheda. Frequenza sostenibile o zero: 1/settimana in stagione, girato ai raduni già previsti.
- Se David non vuole apparire/gestire social: SKIP senza sensi di colpa — non è il canale core per la demografia target.

## Ritmo operativo (dopo il setup)

| Cadenza | Claude | David |
|---|---|---|
| Settimanale | Report KPI (install, abbonati, MRR, retention, review), bozze post FB, follow-up club | Pubblica 2 post, invia 5 email club (30-45 min totali) |
| Mensile | Ricerca 2 community "Noi del…", refresh ASO keyword, analisi coorti | 1 evento/raduno (stagione) |
| Trimestrale | Review canali: rialloca sforzo su ciò che converte | Decisioni go/no-go (paid, iOS, DACH) |

## KPI e soglie di decisione

| Orizzonte | Verde | Giallo | Rosso |
|---|---|---|---|
| 3 mesi | 1.000+ install, 30+ abbonati | 500 install, 10-30 abbonati | <300 install o <10 abbonati |
| 6 mesi | 2.500 install, 80+ abbonati (~€500 MRR eq.) | 1.200 install, 40 abbonati | <800 install |
| 12 mesi | 5.000+ install, 150-250 abbonati (€8-20K ARR) | metà | <2.000 install → review strategica |

**Trigger di espansione (riaprono decisioni master, con dati):**
- 12 mesi in zona verde + richieste iOS ricorrenti nelle review → valutare iOS
- Conversion free→paid >4% stabile → valutare lancio DACH/UK (i18n EN/DE, store listing localizzati)

## Ripresa in sessione futura
Ogni attività di Claude qui è eseguibile standalone: "prepara il calendario FB del mese", "fai il report KPI settimanale", "prepara l'outreach per i club lombardi", "analizza i risultati della campagna Meta". Lo stato dei canali va tenuto in `LAUNCH_PLAN/GTM_LOG.md` (creare al primo ciclo: data, azione, canale, risultato).
