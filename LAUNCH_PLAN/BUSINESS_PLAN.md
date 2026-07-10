# CarLens — Mini Business Plan

**Data:** 2026-07-10 · **Orizzonte:** 12 mesi dal lancio (ott 2026 → ott 2027) · **Fonti:** review strategica 10/07/2026, Rapporto ACI 2024, FIVA Survey 2020/21, `LAUNCH_PLAN/`

---

## 1. Sintesi

App Android che identifica auto d'epoca da una foto (AI Gemini) e restituisce scheda tecnica completa, curiosità e valore di mercato, con garage personale. **Problema:** riconoscere e conoscere un'auto storica vista a un raduno/annuncio richiede competenza o ricerche lunghe. **Proposta di valore:** "il registro digitale del collezionista — identifica, valuta, archivia". **Tesi:** prodotto a bassissimo costo di sviluppo/manutenzione (~fatto: v0.15.0, 372 test, no backend) in una nicchia benestante senza competitor verticali.

## 2. Mercato e target (Italia)

| Dato | Valore | Fonte |
|---|---|---|
| Auto ultraventennali circolanti | 4,3M | Rapporto ACI 2024 |
| Possessori "consapevoli" (Lista Salvaguardia ACI) | 388K | idem |
| Appassionati nei club ASI | ~350K | asifed.it |
| Spesa media annua/possessore | €3.737 | FIVA Survey |
| **SAM** (appassionati attivi, Android, digitali) | **~200-300K** | stima bottom-up review |
| **SOM 12 mesi** | 100-250 abbonati | stima (GTM organica solo-dev) |

**Target:** uomo 45-70, appassionato/possessore auto storica, alta capacità di spesa (€84/anno = 2,2% della sua spesa hobby). **Competitor:** nessuna app verticale (generiche <2★); il sostituto reale è Google Lens/ChatGPT (gratis ma senza scheda strutturata, valore, garage) — il moat è il pacchetto, non l'identificazione.

## 3. Modello di business

Freemium: 5 scan/mese gratis → **Pro €9,99/mese · €39,99/anno · Lifetime €99,99** (mensile volutamente caro: neutralizza l'arbitraggio sulla stagione eventi mag-set). Vendita via Google Play (fee 15%), ricavi in Web3 SRL. No ads/affiliazioni (policy). Costi variabili ~zero (Gemini Flash Lite: <€0,001/scan).

## 4. Roadmap e tempistiche (realistiche, solo-dev + Claude)

| Periodo | Milestone | Effort founder | Effort sviluppo |
|---|---|---|---|
| **0-3 mesi** (lug-ott 2026) | Fase 0 validazione fake-door (lug-ago, gate GO/NO-GO a inizio set) → Fase 1 produzione (set) → Fase 2 lancio Play Store ~metà ottobre, **Bologna fine ottobre** | 4-5 azioni + 2 eventi + 15min/sett | ~3 gg (Fase 0) + ~5 gg (Fase 1-2) |
| **3-6 mesi** (nov 2026-gen 2027) | GTM: gruppi FB, 10-20 club ASI contattati, test paid €100-200 (kill CAC>€40), prime 15-20 recensioni | 30-45 min/sett | manutenzione <5h/mese |
| **6-12 mesi** (feb-ott 2027) | Stagione raduni 2027 (picco acquisizione mag-set), espansione "Noi del…", review trimestrali canali; a 12 mesi: decisione iOS / DACH sui dati | 1 evento/mese in stagione | idem |

Caveat temporali dichiarati: agosto rallenta reclutamento (gruppi/club fermi; gli eventi Toret estivi compensano); review Google 1-7 gg; D-U-N-S SRL 1-2 settimane (avviato in Fase 0). Se la Fase 0 slitta, Bologna diventa evento di validazione anziché lancio.

## 5. Profittabilità

**Costi (cash, 12 mesi):**

| Voce | € |
|---|---|
| Google Play (una tantum) | ~23 |
| API Gemini/Groq (crescente col volume) | 60-250/anno |
| Paid test Meta | 100-200 |
| Bologna + stampa QR + varie | 150-200 |
| Dominio/landing (Cloudflare free) | 0-10 |
| **Totale anno 1** | **~€350-700** |

Il vero costo è il tempo founder (~10-12 gg lancio + 2-4 h/sett regime): dichiarato come costo opportunità, non cash.

**Ricavi (assunzioni: ARPU lordo blended €45/anno — mix 65% annuali, 20% lifetime ammortizzato, 15% mensili ~3 mesi; -15% fee Google → netto ~€38):**

| Scenario | Install 12m | Paganti 12m | Ricavi netti anno 1* | Utile cash anno 1 |
|---|---|---|---|---|
| **Conservativo** | 2.000-2.500 | 80-100 | ~€2.300-3.000 | **~€1.800-2.500** |
| **Ottimistico** | 5.000-6.000 | 250-350 | ~€7.500-10.500 | **~€7.000-10.000** |

\* Cumulato con ramp (i paganti arrivano progressivamente, non tutti a gennaio).

**Break-even cash: mese 4-6 post-lancio** in entrambi gli scenari (costi minimi). Break-even sul tempo (valorizzando ~€300/g): mai nell'anno 1 nello scenario conservativo, ~anno 2 nell'ottimistico — **è un side-business ad alto margine percentuale e piccolo valore assoluto**, coerente col vincolo low-effort. Anno 2 (rinnovi ~60% + crescita + eventuale DACH): conservativo €6-9K, ottimistico €20-35K netti.

## 6. Traction potenziale

**Ipotesi di crescita** (motore: ASO su keyword vergini + share card virale + canali organici FASE-3; CAC paid stimato in Fase 0 con fake-door, kill >€40):

| Trimestre post-lancio | Install cum. (cons. / ott.) | Paganti cum. | MRR-equivalente |
|---|---|---|---|
| Q1 (Bologna incluso) | 500 / 1.200 | 15 / 45 | €50 / €160 |
| Q2 (inverno, piatto) | 900 / 2.200 | 30 / 90 | €100 / €330 |
| Q3 (stagione raduni) | 1.700 / 4.200 | 60 / 200 | €210 / €730 |
| Q4 | 2.400 / 6.000 | 90 / 320 | €330 / €1.150 |

**KPI guida** (soglie complete in FASE-0/3): WTP fake-door >8% verde · activation >70% · D7 >25% · conversione free→paid >2% · LTV/CAC >2 (LTV annuale ~€60-70 vs CAC target <€25). **La traction è stagionale by design**: aspettarsi curva piatta nov-mar e picchi mag-set/eventi.

## 7. Rischi e mitigazioni

| Rischio | Prob. | Mitigazione |
|---|---|---|
| WTP reale bassa (nessuno paga per ciò che Lens fa quasi-gratis) | **Alta** | Fase 0 fake-door PRIMA di ogni investimento; PIVOT su prezzo/lifetime-only; moat = scheda+valore+garage nel copy |
| PMF non validato (0 dati oggi) | Alta | Gate GO/NO-GO con soglie numeriche; NO-GO = stop a costo ~€100 |
| Stagionalità ricavi/churn | Media | Annuale-first + mensile caro (già nel pricing) |
| Aumento prezzi/deprecazione Gemini | Media | Fallback chain 4-tier già in prod; budget alert; costo/scan ha margine 100× |
| Tempo founder (burnout multi-progetto) | Media | Ritmo Fase 3 capped (30-45 min/sett); Claude esegue il resto |
| Accuratezza AI su auto rare → recensioni negative | Media | Confidence multipla già in UI; beta misura accuratezza percepita (soglia 70%) |
| Piccolo tetto di mercato IT (~€150-200K ARR max) | Certa | Accettato: è un side-business; opzione DACH/UK a 12 mesi se conv >4% |

---
**Decisione incorporata:** il piano spende ~€100 e ~3 giorni di sviluppo (Fase 0) prima di impegnare qualsiasi altra risorsa. Il business plan si aggiorna con i dati reali in `BETA_RESULTS.md`.
