# CarLens — Launch Plan Master

**Creato:** 2026-07-10 · **Stato:** Fase 0 non iniziata
**Come usare questo piano:** ogni fase ha il suo file `FASE-N-*.md`, auto-contenuto ed eseguibile da Claude in una sessione futura senza rifare la strategia. Riprendi dicendo: *"esegui la Fase N del launch plan CarLens"*. Aggiorna le checkbox di stato qui sotto man mano.

---

## Decisioni strategiche consolidate (NON rimettere in discussione)

| Decisione | Valore | Data/razionale |
|---|---|---|
| **Target beachhead** | Appassionati auto d'epoca Italia (SAM ~200-300K Android) | Review 10/07/2026 — zero competitor, WTP alta |
| **Espansione futura** | Geografica (DACH/UK), NON auto moderne | i18n slang già pronta; auto moderne = valore percepito basso |
| **Piattaforma** | Solo Android + Google Play Store. No iOS per ora | Vincolo low-effort del founder |
| **Pricing** | Free: 5 scan/mese (reset automatico) · Pro mensile **€9,99** · Pro annuale **€39,99** · Lifetime **€99,99** | Mensile caro per neutralizzare l'arbitraggio stagionale (stagione mag-set: 5×9,99=€50 > 39,99) |
| **Account Google Play** | Nuovo, intestato a **Web3 SRL** | Ricavi in SRL, no obbligo 12-tester, credibilità |
| **Beta = validazione PRE-produzione, NO Play Store** | Fake-door test su APK diretto: landing (intento download) → trial → paywall finto a 3 piani che registra l'intento e regala +20 scan. La produzione (Fase 1) parte SOLO se il gate è verde | Scelta founder 10/07 — valida domanda e CAC prima di investire |
| **Beta gratis, omaggi dopo** | App illimitata di fatto in beta (refill/reward); promo code Play Store in omaggio DOPO il lancio ai tester che completano il questionario | Scelta founder 10/07 |
| **Primo pool beta** | Community "Noi del Toret" (IG Torino, ~10K follower, migliaia agli eventi) + cerchia attuale + gruppi FB | Nota: community generalista, non auto d'epoca → serve anche come proxy del mercato allargato |
| **Posizionamento** | "Il registro digitale del collezionista: identifica, valuta, archivia" — NON "app che riconosce le auto" | Il moat è scheda tecnica+valore+garage, l'ID lo fa anche Google Lens |
| **Deadline lancio** | Produzione live PRIMA di Auto e Moto d'Epoca Bologna (fine ottobre 2026) | Evento con 100K+ appassionati = momento GTM massimo |
| **Budget paid** | €100-200 totali, solo test CAC su Meta. Kill criterion: CAC/abbonato > €40 | LTV annuale ~€60-70 → paid non scala, organico è il motore |
| **Monetizzazione esclusa** | No ads/AdSense/affiliazioni non pertinenti | Policy founder (vale su tutti i progetti) |

## Timeline

```
Lug-Ago 2026       FASE 0 — Beta & validazione domanda (6 settimane, NO Play Store,
                             landing + APK + fake-door, pool Noi del Toret)
                             → GATE GO/NO-GO
Set 2026           FASE 1 — Production hardening (~2 settimane, solo se GO)
Fine Set/Ott 2026  FASE 2 — Lancio Play Store + ASO + billing ON
Ottobre 2026 →     FASE 3 — GTM organica (Bologna, FB groups, club ASI, paid test)
```
Nota timeline: la deadline Bologna (fine ottobre) resta raggiungibile ma è tirata; se la Fase 0 slitta, Bologna diventa evento di *validazione/reclutamento* invece che di lancio — accettabile.
⚠️ Unica azione da anticipare comunque durante la Fase 0: **registrazione account Play Web3 SRL (D-U-N-S)** — costa $25 e 1-2 settimane di attesa; farla partire presto rimuove il long pole dalla Fase 1 (se NO-GO si perdono solo $25).

## Stato fasi

- [ ] **FASE 0** — Beta & validazione → `FASE-0-BETA-VALIDAZIONE.md` → output: `BETA_RESULTS.md` + GO/PIVOT/NO-GO
- [ ] **FASE 1** — Production hardening → `FASE-1-PRODUZIONE.md` (solo se GO)
- [ ] **FASE 2** — Lancio → `FASE-2-LANCIO.md`
- [ ] **FASE 3** — GTM → `FASE-3-GTM.md`

## Contesto tecnico minimo (per sessioni future)

- Repo: `/Users/david/Desktop/AI RnD/carlens/` · Flutter Android · v0.15.0+37
- Meccanica scan limit GIÀ implementata (`lib/services/scan_limit_service.dart`, 5/batch + bottone refill gratuito): al lancio il refill gratuito diventa paywall
- Release attuale: APK diretto + appcast Gist (upgrader) — procedura in memoria `project_carlens_release.md`. Dal lancio Play Store, l'appcast va dismesso per gli utenti store
- Gap produzione noti: debug signing, API key --dart-define in chiaro, Telegram logging PII (GDPR), no billing, no privacy policy, no Crashlytics — tutti nella Fase 0
- Doc strategici di riferimento: `MARKET_RESEARCH_2026.md`, `MONETIZATION_AND_GROWTH_STRATEGY.md`, `ASO_STRATEGY.md`, `CARLENS_BETA_FEEDBACK.pdf` (questionario, mai somministrato)
- Mercato (review 10/07/2026): SOM anno 1 = 100-250 abbonati (€8-20K ARR); tetto nicchia IT Android ~€150-200K ARR. Fonti: Rapporto ACI 2024 (4,3M ultraventennali, 388K Lista Salvaguardia, patrimonio €104mld), ASI (~350K appassionati nei club), FIVA Survey (spesa media €3.737/anno)
