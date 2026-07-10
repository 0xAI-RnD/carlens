# FASE 1 — Production Hardening

**Obiettivo:** portare CarLens da beta-ready a production-ready per Google Play. Nessuna feature nuova (eccetto billing e redeem infra), solo chiusura dei gap bloccanti.
**Durata stimata:** ~2 settimane calendario (4-5 giorni effettivi di lavoro).
**Prerequisiti:** **Fase 0 chiusa con verdetto GO** (`BETA_RESULTS.md` esistente). Il paywall reale eredita schermata ed eventi dal fake-door della Fase 0 e usa il tier-mix emerso dai dati. **T2 (envied) è GIÀ FATTO in Fase 0** — verificare soltanto. Se l'account Play (T6) è stato avviato durante la Fase 0 come raccomandato nel master, qui è già verificato.

## Azioni del founder (David): 3
1. **T1** — Salvare il keystore in 3 posti separati (password manager + cloud + supporto fisico)
2. **T6** — Registrare l'account Google Play Console per Web3 SRL ($25, serve D-U-N-S — Claude prepara la guida; la verifica richiede 1-2 settimane → **farlo SUBITO, è il long pole**)
3. **T5** — Approvare la privacy policy prima della pubblicazione

Tutto il resto lo esegue Claude (via GSD workflow: `/gsd:quick` per task piccole, fase pianificata per il billing).

---

## Task

### T1 — Keystore di produzione ⚠️ IRREVERSIBILE SE PERSO
- Claude: genera keystore (`keytool -genkeypair`, RSA 4096, validità 30 anni), configura `android/key.properties` (gitignored!) e `build.gradle` per release signing. Verifica: `apksigner verify` sull'APK prodotto.
- David: backup triplo del file `.jks` + password. **Senza backup non si procede oltre.**
- Nota: con Play App Signing, Google custodisce la chiave app e il keystore locale diventa upload key (reimpostabile) — attivarlo alla creazione dell'app in Console (riduce il rischio catastrofico).
- Done: APK release firmato con chiave di produzione, keystore backuppato, `key.properties` in `.gitignore`.

### T2 — API key sicure (envied) — GIÀ FATTO IN FASE 0
- Eseguito come T0 della Fase 0 (prerequisito distribuzione landing). Qui solo verifica: `strings` sull'AAB non rivela chiavi, budget alert attivi su Gemini/Groq.
- Done: verifica ok.

### T3 — Telegram logging: rimozione PII (GDPR) ⚠️ BLOCCANTE LEGALE
- `lib/services/telegram_service.dart` invia attività utente a un canale Telegram del founder. In produzione = trattamento dati non dichiarato.
- Azione: rimuovere le chiamate con contenuti utente (foto/scansioni/dettagli d'uso). Se serve telemetria, usare solo Firebase Analytics (eventi anonimi, dichiarati nella Data Safety form). Telegram può restare SOLO per notifiche di sistema senza dati utente (es. "nuova installazione" senza identificatori) — in dubbio, rimuovere.
- Done: nessun dato riconducibile all'utente lascia il device verso canali non dichiarati; test verdi.

### T4 — Crashlytics
- Aggiungere `firebase_crashlytics` (firebase_core già presente), inizializzazione in `main.dart` con `FlutterError.onError` + `PlatformDispatcher.onError`.
- Done: crash di prova visibile nella console Firebase.

### T5 — Privacy policy + Data Safety
- Claude genera la privacy policy (IT+EN): dati trattati = foto inviate a Google Gemini e Groq per l'identificazione (non conservate da CarLens), analytics Firebase, dati locali sul device (garage). Titolare: Web3 SRL.
- Hosting: GitHub Pages sul repo (`docs/privacy.html`) o pagina su dominio esistente del founder — URL stabile richiesto da Play Console.
- Compilare la bozza della Data Safety form (le risposte esatte dipendono dalla policy finale).
- David: revisione/approvazione (eventualmente girarla al commercialista/legale se vuole).
- Done: URL privacy policy pubblico e stabile.

### T6 — Account Google Play Console (Web3 SRL) — LONG POLE, AVVIARE SUBITO
- David si registra come organizzazione: serve numero D-U-N-S di Web3 SRL (gratuito, richiesta su dnb.com se non già presente — può richiedere giorni), email aziendale, sito web, $25.
- Claude: prepara la checklist passo-passo e assiste nella compilazione; configura poi l'app in Console (package name definitivo — verificare quello attuale in `android/app/build.gradle` e deciderlo ORA perché è immutabile).
- Merchant account per vendere abbonamenti: dati bancari e fiscali SRL.
- Done: account attivo e verificato, app creata in Console (anche solo draft), merchant configurato.

### T7 — Billing (il task più grosso: 2-3 giorni)
- Implementare Google Play Billing via plugin ufficiale `in_app_purchase` (preferito a RevenueCat: no dipendenza SaaS esterna, coerente con vincolo low-effort e single-store).
- Prodotti da creare in Console: `pro_monthly` €9,99 · `pro_yearly` €39,99 · `pro_lifetime` €99,99 (one-time) — **salvo revisione da `BETA_RESULTS.md`** (se il fake-door mostra un tier-mix diverso, adeguare qui).
- Nuovo `SubscriptionService` (singleton, pattern repo) che espone `isPro` (stream/notifier); persistenza stato + restore purchases.
- Integrazione con `ScanLimitService`: se `isPro` → scan illimitati; se free → 5 scan/mese con **reset automatico mensile** (sostituire la logica batch attuale: il bottone "+5 scansioni" diventa CTA paywall "Passa a Pro").
- **Flag `BETA_MODE`** (dart-define): in beta l'app è illimitata e il paywall è invisibile. Il flag si spegne al lancio (Fase 2).
- Schermata paywall: **riusare la schermata fake-door della Fase 0** (già costruita, già i18n, con eventi GA4) collegandola al billing reale al posto del reward; copy posizionamento ("scansioni illimitate, schede complete, il tuo garage"), link privacy/termini.
- Unit test per la logica (mock del billing), test manuali con license tester in Console.
- Done: acquisto sandbox funzionante end-to-end, restore ok, flag BETA_MODE operativo, `flutter test` verde.

### T8 — Compliance Play Store
- Verificare `targetSdk`/`compileSdk` = 35 in `android/app/build.gradle`; aggiornare se serve. Build `appbundle` (`flutter build appbundle`) — Play richiede AAB, non APK.
- Rimuovere/adattare l'update check `upgrader`+appcast per la build store (su Play gli update li gestisce lo store; l'appcast resta solo per il canale APK diretto legacy, o si dismette).
- Done: `flutter build appbundle --release` pulito, targetSdk 35.

## Ordine di esecuzione
`T6 subito (attese esterne)` → `T1 → T2 → T3 → T4` (parallele, piccole) → `T5` → `T7` (dopo T6 per i prodotti in Console; il codice si può scrivere prima con license testing) → `T8`.

## Criteri di completamento della fase
- [ ] AAB firmato produzione, chiavi obfuscate, targetSdk 35
- [ ] Zero PII verso Telegram; Crashlytics attivo
- [ ] Privacy policy pubblica; Data Safety pronta
- [ ] Account Play Web3 SRL verificato + merchant + 3 prodotti billing creati
- [ ] Acquisto sandbox testato; BETA_MODE funzionante
- [ ] `flutter test` verde (release gate, come sempre)
