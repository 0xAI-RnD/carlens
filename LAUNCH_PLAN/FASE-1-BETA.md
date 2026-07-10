# FASE 1 — Beta Testing

**Obiettivo:** validare PMF e willingness-to-pay con 30-50 tester reali PRIMA di monetizzare; raccogliere i dati che oggi non esistono (il questionario di aprile non fu mai somministrato). La beta è **tutto gratis illimitato** (flag `BETA_MODE`); i tester che completano il feedback ricevono un promo code in omaggio DOPO il lancio (Fase 2).
**Durata:** 6 settimane (agosto - metà settembre 2026).
**Prerequisiti:** Fase 0 completa (serve: signing, account Play, BETA_MODE; il billing può essere in rifinitura durante le prime settimane).

## Azioni del founder (David): 3
1. Partecipare a 1-2 eventi "Noi del Toret" con QR di arruolamento (è il canale principale di reclutamento)
2. Invitare la cerchia attuale (~10 tester) al closed testing
3. 15 minuti/settimana: leggere il report settimanale di Claude e decidere eventuali aggiustamenti

---

## Setup (settimana 1 — Claude)

### S1 — Closed testing track su Play Console
- Caricare l'AAB (BETA_MODE=true, versione dedicata es. 0.16.0-beta) sul track "Closed testing".
- Arruolamento via link (email list o Google Group). Generare link opt-in + QR code stampabile (A5, con claim "Che auto è quella? Scoprilo in 3 secondi" + QR).
- Nota: con account organizzazione (Web3 SRL) il vincolo "12 tester × 14 giorni" degli account personali non si applica, ma teniamo ≥12 tester per 14 giorni come soglia di qualità comunque.

### S2 — Canale feedback
- **Google Form** che digitalizza il questionario esistente `CARLENS_BETA_FEEDBACK.pdf` (20 domande: profilo, uso, accuratezza, valore, Sean Ellis D15, WTP). Aggiornare la domanda WTP con i prezzi consolidati: testare €9,99/mese vs €39,99/anno vs €99,99 lifetime ("quale sceglieresti?" + "a che prezzo NON lo compreresti?" - Van Westendorp semplificato).
- Gruppo Telegram o WhatsApp "CarLens Beta" per feedback caldo (facoltativo ma consigliato: attrito basso per la demografia).
- Promessa esplicita all'ingresso: *"completa il questionario dopo 2 settimane d'uso → al lancio ricevi un codice omaggio Pro"* (tier: annuale in omaggio; lifetime ai 3-5 tester più attivi).

### S3 — Strumentazione
- Verificare che Firebase Analytics tracci: `scan_started` (per source), `scan_completed`, `garage_save`, `share`, sessioni. Aggiungere eventi mancanti se serve (GSD quick).
- Dashboard/report: query settimanale GA4 (Claude la esegue e sintetizza — non serve dashboard UI).

## Reclutamento (settimane 1-3)

### R1 — Pool "Noi del Toret" (canale primario)
- Community IG torinese ~10K follower, migliaia di presenze agli eventi. **Non è una community di auto d'epoca** → duplice valore: (a) reclutamento volume, (b) proxy del mercato allargato — misurare separatamente la retention di questo segmento vs appassionati veri (campo "come ci hai conosciuto" nel form + UTM/referral nel link opt-in: usare due link opt-in distinti se possibile, o codice sorgente nel form).
- Meccanica evento: David presente con QR; pitch da 10 secondi: "fotografa un'auto d'epoca e ti dice tutto: modello, storia, valore". Se agli eventi ci sono auto storiche esposte, demo dal vivo.
- Claude prepara: QR, mini-landing (una pagina statica con screenshot + link opt-in, hostabile su GitHub Pages), copy per eventuale post/story IG se gli organizzatori collaborano (DM di proposta: Claude scrive la bozza, David la invia dal suo account).
- Se la collaborazione IG non parte: il solo presidio fisico degli eventi basta per l'obiettivo beta (30-50 tester).

### R2 — Cerchia attuale
- Migrare i ~10 tester APK-diretto al closed testing Play (email invito). Vantaggio: da qui in poi update automatici via store.

### R3 — Gruppi Facebook auto d'epoca (riserva)
- Solo se dopo 3 settimane < 30 tester: post in 2-3 gruppi IT di auto storiche ("cerco beta tester, app italiana gratuita che identifica auto d'epoca, codice omaggio al lancio"). Claude scrive i post, David li pubblica.

## Esecuzione (settimane 2-6 — ciclo settimanale gestito da Claude)

Ogni settimana:
1. Analisi GA4: tester attivi, scan/utente, D7 retention, % garage save, share
2. Lettura risposte form nuove
3. Triage bug (Crashlytics + feedback) → fix via GSD (`/gsd:quick` o `/gsd:debug`), release beta aggiornata sul track
4. Report sintetico a David (formato: "Azioni tue: N" in cima, poi metriche vs target, insight, fix shippati)

A metà beta (settimana 3-4): sollecito questionario a chi usa l'app da ≥2 settimane.

## Metriche target (gate PMF — dai doc di marzo, ora misurate davvero)

| Metrica | Target | Rosso (ripensare) |
|---|---|---|
| Tester arruolati | ≥30 (ideale 50) | <15 |
| Questionari completati | ≥20 | <10 |
| D7 retention | >25% | <10% |
| Scan/utente primo mese | >5 | <2 |
| Salva in garage | >40% dei tester | <15% |
| Sean Ellis "molto deluso" | >40% | <20% |
| Crash-free sessions | >99% | <95% |
| Accuratezza percepita (form) | >70% "quasi sempre giusta" | <50% |

## Criteri di uscita dalla beta
- [ ] ≥14 giorni di closed testing con ≥12 tester attivi (soglia qualità)
- [ ] ≥20 questionari → decisione pricing CONFERMATA sui dati WTP (se i dati contraddicono €9,99/€39,99/€99,99, si aggiorna il master — unica decisione riapribile)
- [ ] Metriche ≥ soglia rossa su tutta la riga; se Sean Ellis <20% → STOP e review strategica prima di spendere sul lancio
- [ ] Bug critici chiusi, crash-free >99%
- [ ] Lista tester aventi diritto al codice omaggio congelata (nome/email + questionario completato)

**Output della fase:** `LAUNCH_PLAN/BETA_RESULTS.md` con metriche finali, verdetto PMF, pricing confermato, lista omaggi. È l'input della Fase 2.
