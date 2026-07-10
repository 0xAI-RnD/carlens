# FASE 0 — Beta & Validazione della domanda (pre-produzione, NO Play Store)

**Obiettivo:** misurare domanda reale e willingness-to-pay con un fake-door test su bacino ristretto, PRIMA di investire nella produzione (Fase 1). Tre leve: landing page (intento di download) → APK diretto (trial reale) → paywall finto (intento di pagamento, ricompensato con scansioni omaggio). Simula un CAC quasi reale con €50-100 di paid.
**Durata:** 6 settimane (di cui 1 di setup).
**Prerequisiti:** nessuno — si parte dall'app attuale (v0.15.0+, APK diretto + appcast già funzionanti).
**Perché prima della produzione:** se il gate è rosso, si risparmiano i 5-6 giorni di hardening + account Play; se è verde, la Fase 1 parte con dati (incluso QUALE tier di prezzo attira).

## Azioni del founder (David): 4
1. Approvare landing page e copy del paywall finto prima della pubblicazione
2. Partecipare a 1-2 eventi "Noi del Toret" con QR della landing
3. Creare la campagna Meta da €50-100 (Claude prepara tutto; serve il tuo Ads Manager)
4. 15 min/settimana: report di Claude

---

## Etica del fake-door (vincolo non negoziabile)
Il bottone "Abbonati" NON incassa: al click mostra *"CarLens Pro sta arrivando! Grazie per l'interesse — nel frattempo ti regaliamo 20 scansioni"* ed eroga subito le scansioni. Nessun dato di pagamento richiesto, nessun inganno oltre il click. Chi non vuole pagare ha comunque un percorso gratuito visibile.

## Le 3 leve e il funnel completo

```
[Paid Meta / Toret QR / FB groups / cerchia]
   → Landing (visit)                        ev. web: page_view (+utm)
   → Click "Scarica APK" (download intent)  ev. web: download_click
   → Install e primo avvio (trial)          ev. app: first_open (Firebase, automatico)
   → Uso reale (activation)                 ev. app: scan_completed (esiste già)
   → Esaurisce 5 scan → vede paywall        ev. app: paywall_view        [NUOVO]
   → Click su un piano (PAYMENT INTENT)     ev. app: paywall_intent{tier} [NUOVO]
   → Reward +20 scan                        ev. app: fake_door_reward     [NUOVO]
   → (chi rifiuta: "Non ora" → +5 gratis)   ev. app: paywall_dismiss      [NUOVO]
```

### Leva 1 — Landing page
- **Stack:** pagina statica su **Cloudflare Pages** (stesso stack di btpoggi/OW: zero manutenzione, dominio tipo `carlens.pages.dev` o sottodominio di un dominio esistente del founder).
- **Contenuto:** hero con claim ("Che auto è quella? Scoprilo in 3 secondi"), 3 screenshot, 3 bullet valore (identifica/valuta/archivia), CTA unica "Scarica la beta gratuita (Android)".
- **Gate email opzionale ma raccomandato:** prima del download, campo email facoltativo ("ti avvisiamo quando esce la versione completa") — costruisce la lista per il lancio. Il download NON è bloccato dall'email (attrito minimo, l'email è il segnale d'intento forte).
- **Tracking:** GA4 web property (o Cloudflare Web Analytics + beacon custom) con eventi `page_view`, `download_click`, `email_submitted`; UTM su ogni canale (`?utm_source=meta|toret|fb|friends`).
- **Download:** link all'APK della GitHub Release corrente (pattern release esistente).

### Leva 2 — Distribuzione APK e trial
- Build beta dedicata (es. `0.16.0-beta`) con le modifiche in-app (vedi task T2-T3) distribuita col meccanismo esistente (GitHub Release + appcast per gli update).
- **Attribuzione landing→install:** senza Play Store non c'è install referrer. Soluzione pragmatica: si confrontano i conteggi (download_click sulla landing vs first_open in Firebase) per coorte temporale e per canale (i picchi di canale sono leggibili perché i canali si attivano in momenti diversi: prima cerchia, poi Toret, poi paid). Precisione sufficiente per decidere.
- **Trial rate** = first_open / download_click. **Activation** = utenti con ≥1 scan_completed / first_open.

### Leva 3 — Fake-door pagamento (in-app)
- Al 6° scan (batch esaurito) il bottone attuale "+5 scansioni" viene sostituito da un **paywall di prova a 3 piani** (prezzi consolidati: €9,99/mese · €39,99/anno · €99,99 lifetime) — così si misura non solo SE cliccano, ma QUALE tier.
- Sotto i piani, link discreto "Non ora, continua con 5 scansioni gratuite" (il percorso gratuito resta: `paywall_dismiss` + refill 5 come oggi).
- Click su un piano → evento `paywall_intent` con `tier` → schermata ringraziamento + **+20 scansioni omaggio** (una tantum per utente).
- **WTP rate** = utenti con paywall_intent / utenti con paywall_view.

## Modifiche tecniche (task eseguibili — via GSD quando si esegue la fase)

| # | Task | Effort | Note |
|---|---|---|---|
| T0 | **Migrazione `envied`** (API key obfuscate) — PREREQUISITO di distribuzione | 0,5 g | Anticipata dalla Fase 1: con landing semi-pubblica l'APK esce dalla cerchia fidata e le chiavi in chiaro (--dart-define) sono estraibili. Impostare anche budget cap/alert su Gemini e Groq. Il trust model documentato in memoria (apk_distribution) decade da qui in poi. |
| T1 | Landing page su Cloudflare Pages + GA4 web + UTM | 0,5-1 g | Copy da approvare (David). Include email gate facoltativo (storage: Cloudflare Worker KV o semplice form → Google Sheet). |
| T2 | Paywall fake-door: schermata 3 piani, eventi `paywall_view` / `paywall_intent{tier}` / `paywall_dismiss` / `fake_door_reward`, reward +20 scan one-time (SharedPreferences), i18n slang | 1 g | Si aggancia a `ScanLimitService` esistente: il flusso batch-esaurito → paywall sostituisce il bottone refill diretto. Unit test. |
| T3 | Evento `scan_limit_reached` + verifica pipeline eventi GA4 esistente | 0,5 g | AnalyticsService ha già scan_completed/car_shared; first_open è automatico. |
| T4 | Nota Telegram logging: in bacino ristretto resta tollerato, ma NON pubblicizzare la landing oltre i canali previsti; la rimozione PII completa resta in Fase 1 | — | Rischio accettato dal founder per la beta ristretta. |

Totale sviluppo: **~3 giorni** (vs 5-6 della produzione: è il senso della validazione anticipata).

## Bacino e reclutamento (target: 80-150 install, bastano per leggere il funnel)
1. **Cerchia attuale** (~10): migrano alla build beta via appcast — settimana 1
2. **Noi del Toret**: eventi con QR della landing (`utm_source=toret`) — community generalista: misurarne trial/activation separatamente come proxy del mercato allargato — settimane 2-4
3. **Gruppi FB auto d'epoca** (2-3 post "cerco beta tester", `utm_source=fb`) — settimane 2-4
4. **Paid Meta €50-100** (`utm_source=meta`): campagna traffico alla landing, target IT 45-65 interessi auto d'epoca, solo Android, €5-7/giorno × 2 settimane — settimane 3-5 (dopo che l'app è rodata con i primi organici)

In parallelo: **questionario PMF** (Google Form dal `CARLENS_BETA_FEEDBACK.pdf`, mai somministrato) inviato a chi ha ≥2 settimane d'uso — include Sean Ellis e domanda WTP esplicita di confronto coi 3 tier. Incentivo: chi lo completa è in lista omaggio al lancio (annuale gratis; lifetime ai top 3-5).

## Derivazione CAC quasi reale (dal solo canale paid)

```
CAC_intent   = spesa Meta / n. paywall_intent della coorte meta
CAC_stimato  = CAC_intent / fattore_conversione_fake_door
```
dove `fattore_conversione_fake_door` = 0,25-0,50 (benchmark: il 25-50% degli intent su fake-door diventa pagante reale). Usare 0,33 come stima centrale → **CAC_stimato ≈ 3 × CAC_intent**.
Esempio: €80 spesi, 400 visite, 120 download_click, 60 install, 15 paywall_intent → CAC_intent = €5,3 → CAC_stimato ≈ €16 (verde, ben sotto il kill criterion €40 della GTM).

## KPI e soglie

| Metrica | Verde | Giallo | Rosso |
|---|---|---|---|
| Landing: download_click / visit | >25% | 10-25% | <10% |
| Trial: first_open / download_click | >50% | 30-50% | <30% |
| Activation: ≥1 scan / first_open | >70% | 50-70% | <50% |
| **WTP: paywall_intent / paywall_view** | **>8%** | **3-8%** | **<3%** |
| CAC_stimato (coorte meta) | <€25 | €25-40 | >€40 |
| Sean Ellis (form) | >40% | 20-40% | <20% |
| D7 retention | >25% | 10-25% | <10% |

## Criteri GO/NO-GO verso la Fase 1 (produzione)
- **GO:** WTP ≥ giallo E activation ≥ giallo E Sean Ellis ≥ giallo E almeno 80 install totali → si parte con la produzione; il tier più cliccato guida il paywall reale.
- **PIVOT:** WTP rosso ma activation/retention verdi → il prodotto piace ma non si paga: rivedere prezzo (dati form) o modello (lifetime-only? one-time?) e ri-testare il solo paywall (2 settimane).
- **NO-GO:** activation E retention rossi → il prodotto non trattiene nemmeno gratis: STOP investimento, review strategica.

**Output della fase:** `LAUNCH_PLAN/BETA_RESULTS.md` — funnel completo per canale, CAC_stimato, tier vincente, verdetto PMF, lista omaggi congelata, decisione GO/PIVOT/NO-GO motivata. È l'input della Fase 1.
