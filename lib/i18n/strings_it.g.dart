///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsIt = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.it,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <it>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsAppIt app = TranslationsAppIt._(_root);
	late final TranslationsNavIt nav = TranslationsNavIt._(_root);
	late final TranslationsHomeIt home = TranslationsHomeIt._(_root);
	late final TranslationsGarageIt garage = TranslationsGarageIt._(_root);
	late final TranslationsResultsIt results = TranslationsResultsIt._(_root);
	late final TranslationsSettingsIt settings = TranslationsSettingsIt._(_root);
	late final TranslationsAchievementsIt achievements = TranslationsAchievementsIt._(_root);
	late final TranslationsVinIt vin = TranslationsVinIt._(_root);
}

// Path: app
class TranslationsAppIt {
	TranslationsAppIt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// it: 'CARLENS'
	String get name => 'CARLENS';

	/// it: 'Identifica la tua classica'
	String get tagline => 'Identifica la tua classica';

	/// it: 'Caricamento...'
	String get loading => 'Caricamento...';
}

// Path: nav
class TranslationsNavIt {
	TranslationsNavIt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// it: 'Home'
	String get home => 'Home';

	/// it: 'Garage'
	String get garage => 'Garage';

	/// it: 'Traguardi'
	String get achievements => 'Traguardi';
}

// Path: home
class TranslationsHomeIt {
	TranslationsHomeIt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// it: 'Scatta una foto'
	String get takePhoto => 'Scatta una foto';

	/// it: 'oppure carica dalla galleria (fino a 3 foto)'
	String get loadFromGallery => 'oppure carica dalla galleria (fino a 3 foto)';

	/// it: 'Incolla Link'
	String get pasteLink => 'Incolla Link';

	/// it: 'Nessun link valido negli appunti'
	String get noValidLink => 'Nessun link valido negli appunti';

	/// it: 'Link copiato dagli appunti'
	String get linkCopied => 'Link copiato dagli appunti';

	/// it: 'Analisi in corso...'
	String get analyzing => 'Analisi in corso...';

	/// it: 'URL non valido o non supportato'
	String get invalidUrl => 'URL non valido o non supportato';

	/// it: 'Siti supportati: Subito.it, AutoScout24'
	String get supportedSites => 'Siti supportati: Subito.it, AutoScout24';

	/// it: 'Analisi annuncio Subito.it...'
	String get analyzingSubito => 'Analisi annuncio Subito.it...';

	/// it: 'Analisi annuncio AutoScout24...'
	String get analyzingAutoScout => 'Analisi annuncio AutoScout24...';

	/// it: 'Analisi link in corso...'
	String get analyzingLink => 'Analisi link in corso...';

	/// it: 'Per risultati migliori'
	String get photoTips => 'Per risultati migliori';

	/// it: 'Inquadra l'auto intera, con buona luce e da più angolazioni'
	String get photoTipsDesc => 'Inquadra l\'auto intera, con buona luce e da più angolazioni';

	/// it: 'Il tuo identificatore di auto d'epoca'
	String get subtitle => 'Il tuo identificatore di auto d\'epoca';

	/// it: 'Scatta e identifica'
	String get snapAndIdentify => 'Scatta e identifica';

	/// it: 'Scegli dalla galleria'
	String get chooseFromGallery => 'Scegli dalla galleria';

	/// it: 'Galleria'
	String get gallery => 'Galleria';

	/// it: 'Subito.it, AutoScout24'
	String get marketplaceSites => 'Subito.it, AutoScout24';
}

// Path: garage
class TranslationsGarageIt {
	TranslationsGarageIt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// it: 'Il tuo Garage'
	String get title => 'Il tuo Garage';

	/// it: 'Il tuo garage è vuoto'
	String get empty => 'Il tuo garage è vuoto';

	/// it: 'Scansiona la tua prima auto storica per iniziare la tua collezione'
	String get emptySubtitle => 'Scansiona la tua prima auto storica\nper iniziare la tua collezione';

	/// it: 'Cerca per marca, modello, anno...'
	String get searchHint => 'Cerca per marca, modello, anno...';

	/// it: 'Elimina scansione'
	String get deleteTitle => 'Elimina scansione';

	/// it: 'Vuoi eliminare ${brand} ${model}?'
	String deleteMessage({required Object brand, required Object model}) => 'Vuoi eliminare ${brand} ${model}?';

	/// it: 'Annulla'
	String get cancel => 'Annulla';

	/// it: 'Elimina'
	String get delete => 'Elimina';

	/// it: 'Scansione eliminata'
	String get deleted => 'Scansione eliminata';

	/// it: 'Annulla'
	String get undo => 'Annulla';

	/// it: '${n} auto scansionate'
	String scannedCount({required Object n}) => '${n} auto scansionate';

	/// it: '1 auto scansionata'
	String get scannedCountOne => '1 auto scansionata';

	/// it: '${n} verificate'
	String verifiedCount({required Object n}) => '${n} verificate';

	/// it: '1 verificata'
	String get verifiedCountOne => '1 verificata';

	/// it: '${n} marchi'
	String brandCount({required Object n}) => '${n} marchi';

	/// it: '1 marchio'
	String get brandCountOne => '1 marchio';

	/// it: 'Tutte'
	String get all => 'Tutte';

	/// it: 'STATISTICHE'
	String get stats => 'STATISTICHE';

	/// it: 'FILTRI'
	String get filters => 'FILTRI';

	/// it: 'Più recenti'
	String get sortRecent => 'Più recenti';

	/// it: 'Più vecchi'
	String get sortOldest => 'Più vecchi';

	/// it: 'Nessun risultato'
	String get noResults => 'Nessun risultato';

	/// it: 'Attendibilità'
	String get confidence => 'Attendibilità';

	/// it: 'Livello'
	String get level => 'Livello';

	/// it: 'Identificato'
	String get identified => 'Identificato';

	/// it: 'Verificato'
	String get verified => 'Verificato';

	/// it: 'top marca'
	String get topBrand => 'top marca';

	/// it: 'Condividi'
	String get share => 'Condividi';

	/// it: 'Condividi scheda'
	String get shareTitle => 'Condividi scheda';

	/// it: 'Scheda auto - CarLens'
	String get shareSubject => 'Scheda auto - CarLens';

	/// it: 'Analizzato con CarLens'
	String get shareVia => 'Analizzato con CarLens';

	/// it: 'SCHEDA RAPIDA'
	String get quickSpecs => 'SCHEDA RAPIDA';

	/// it: 'STORIA DEL MODELLO'
	String get modelHistory => 'STORIA DEL MODELLO';

	/// it: 'STIMA DI MERCATO'
	String get marketEstimate => 'STIMA DI MERCATO';

	/// it: 'Esemplare in buone condizioni. Stima indicativa.'
	String get marketDisclaimer => 'Esemplare in buone condizioni. Stima indicativa.';

	/// it: 'LO SAPEVI?'
	String get funFact => 'LO SAPEVI?';

	/// it: 'Originalità'
	String get originalityLabel => 'Originalità';

	/// it: 'REPORT ORIGINALITÀ'
	String get originalityReport => 'REPORT ORIGINALITÀ';

	/// it: 'Eccellente'
	String get originalityExcellent => 'Eccellente';

	/// it: 'Buona'
	String get originalityGood => 'Buona';

	/// it: 'Discreta'
	String get originalityFair => 'Discreta';

	/// it: 'Bassa'
	String get originalityLow => 'Bassa';

	/// it: 'Elimina scansione'
	String get deleteAction => 'Elimina scansione';

	/// it: 'Aggiungi telaio per saperne di più'
	String get addVin => 'Aggiungi telaio per saperne di più';

	/// it: 'Verifica originalità'
	String get verifyOriginality => 'Verifica originalità';

	/// it: 'Foto originale non disponibile. Scansiona di nuovo.'
	String get photoUnavailable => 'Foto originale non disponibile. Scansiona di nuovo.';

	/// it: 'Solo identificazione'
	String get identificationOnly => 'Solo identificazione';

	/// it: 'DA ${source}'
	String from({required Object source}) => 'DA ${source}';

	/// it: 'Prezzo richiesto'
	String get askingPrice => 'Prezzo richiesto';

	/// it: 'Km dichiarati'
	String get mileage => 'Km dichiarati';

	/// it: 'Originalità ${score}/100'
	String originalityScore({required Object score}) => 'Originalità ${score}/100';

	late final TranslationsGarageSpecsIt specs = TranslationsGarageSpecsIt._(_root);
	late final TranslationsGarageShareTextIt shareText = TranslationsGarageShareTextIt._(_root);
}

// Path: results
class TranslationsResultsIt {
	TranslationsResultsIt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// it: 'Risultato'
	String get title => 'Risultato';

	/// it: 'Analisi in corso...'
	String get analyzing => 'Analisi in corso...';

	/// it: 'Analisi annuncio in corso...'
	String get analyzingListing => 'Analisi annuncio in corso...';

	/// it: 'L'AI sta identificando l'auto'
	String get analyzingSubtitle => 'L\'AI sta identificando l\'auto';

	/// it: 'Scaricamento foto e identificazione'
	String get analyzingListingSubtitle => 'Scaricamento foto e identificazione';

	/// it: 'SCHEDA RAPIDA'
	String get quickSpecs => 'SCHEDA RAPIDA';

	/// it: 'Identificato'
	String get identified => 'Identificato';

	/// it: 'Identificato · ${percent}%'
	String identifiedWithPercent({required Object percent}) => 'Identificato · ${percent}%';

	/// it: 'Vuoi saperne di più?'
	String get wantToKnowMore => 'Vuoi saperne di più?';

	/// it: 'Inserisci il numero di telaio per scoprire le specifiche esatte del tuo esemplare.'
	String get vinInviteDesc => 'Inserisci il numero di telaio per scoprire le specifiche esatte del tuo esemplare.';

	/// it: 'Dove trovo il telaio? ⓘ'
	String get whereIsVin => 'Dove trovo il telaio? ⓘ';

	/// it: 'Inserisci telaio'
	String get enterVin => 'Inserisci telaio';

	/// it: 'Decodifica'
	String get decode => 'Decodifica';

	/// it: 'Condividi scheda'
	String get share => 'Condividi scheda';

	/// it: 'Riprova'
	String get retry => 'Riprova';

	/// it: 'Si è verificato un errore. Riprova.'
	String get error => 'Si è verificato un errore. Riprova.';

	/// it: 'Errore durante l'analisi'
	String get errorRetry => 'Errore durante l\'analisi';

	/// it: 'Salvata nel garage'
	String get saved => 'Salvata nel garage';

	/// it: 'Auto salvata nel Garage!'
	String get savedExcl => 'Auto salvata nel Garage!';

	/// it: 'Già nel garage'
	String get alreadySaved => 'Già nel garage';

	/// it: 'Salva nel garage'
	String get save => 'Salva nel garage';

	/// it: 'Salvata nel Garage'
	String get savedInGarage => 'Salvata nel Garage';

	/// it: 'Salva nel Garage'
	String get saveToGarage => 'Salva nel Garage';

	/// it: 'Telaio trovato: ${vin}'
	String vinFound({required Object vin}) => 'Telaio trovato: ${vin}';

	/// it: 'Nessun VIN trovato nelle immagini'
	String get vinNotFound => 'Nessun VIN trovato nelle immagini';

	/// it: 'Nessun numero di telaio riconosciuto. Prova ad avvicinare la fotocamera.'
	String get vinNotRecognized => 'Nessun numero di telaio riconosciuto. Prova ad avvicinare la fotocamera.';

	/// it: 'Errore nella lettura. Inserisci il telaio manualmente.'
	String get vinReadError => 'Errore nella lettura. Inserisci il telaio manualmente.';

	/// it: 'Formato telaio non riconosciuto. Controlla e riprova.'
	String get vinFormatError => 'Formato telaio non riconosciuto. Controlla e riprova.';

	/// it: 'Attenzione: il check digit non corrisponde. I VIN europei spesso non lo utilizzano.'
	String get vinCheckDigitWarning => 'Attenzione: il check digit non corrisponde. I VIN europei spesso non lo utilizzano.';

	/// it: 'Errore nella decodifica del telaio. Controlla e riprova.'
	String get vinDecodeError => 'Errore nella decodifica del telaio. Controlla e riprova.';

	/// it: 'Scansiona telaio'
	String get scanVin => 'Scansiona telaio';

	/// it: 'VIN decodificato'
	String get vinDecoded => 'VIN decodificato';

	/// it: 'Lettura targhetta in corso...'
	String get vinReading => 'Lettura targhetta in corso...';

	/// it: 'Attendibilità ricerca: ${percent}%'
	String searchReliability({required Object percent}) => 'Attendibilità ricerca: ${percent}%';

	/// it: 'Non è quest'auto?'
	String get notThisCar => 'Non è quest\'auto?';

	/// it: 'Mostra alternative di identificazione'
	String get showAlternatives => 'Mostra alternative di identificazione';

	/// it: 'Grazie per il feedback! Riprova con un'altra foto.'
	String get correctionFeedback => 'Grazie per il feedback! Riprova con un\'altra foto.';

	/// it: 'Errore nel salvataggio. Riprova.'
	String get saveError => 'Errore nel salvataggio. Riprova.';

	/// it: 'Errore nella generazione del report. Riprova.'
	String get reportError => 'Errore nella generazione del report. Riprova.';

	/// it: 'Generazione report in corso...'
	String get reportGenerating => 'Generazione report in corso...';

	/// it: 'L'AI sta confrontando le specifiche'
	String get reportGeneratingSubtitle => 'L\'AI sta confrontando le specifiche';

	/// it: 'Scheda tecnica'
	String get techSheet => 'Scheda tecnica';

	late final TranslationsResultsSpecsIt specs = TranslationsResultsSpecsIt._(_root);
	late final TranslationsResultsShareTextIt shareText = TranslationsResultsShareTextIt._(_root);
	late final TranslationsResultsLevel2It level2 = TranslationsResultsLevel2It._(_root);
	late final TranslationsResultsMarketIt market = TranslationsResultsMarketIt._(_root);

	/// it: 'STORIA DEL MODELLO'
	String get modelHistory => 'STORIA DEL MODELLO';

	/// it: 'LO SAPEVI?'
	String get funFact => 'LO SAPEVI?';

	/// it: 'POTREBBE ANCHE ESSERE'
	String get alternatives => 'POTREBBE ANCHE ESSERE';

	/// it: 'Verificato'
	String get verified => 'Verificato';

	late final TranslationsResultsOriginalityIt originality = TranslationsResultsOriginalityIt._(_root);
	late final TranslationsResultsListingIt listing = TranslationsResultsListingIt._(_root);
	late final TranslationsResultsVinSpecsIt vinSpecs = TranslationsResultsVinSpecsIt._(_root);
}

// Path: settings
class TranslationsSettingsIt {
	TranslationsSettingsIt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// it: 'Impostazioni'
	String get title => 'Impostazioni';

	/// it: 'NOTIFICHE'
	String get notifications => 'NOTIFICHE';

	/// it: 'Curiosità del giorno'
	String get dailyCuriosity => 'Curiosità del giorno';

	/// it: 'Ricevi ogni giorno una curiosità sulle auto storiche'
	String get dailyCuriosityDesc => 'Ricevi ogni giorno una curiosità sulle auto storiche';

	/// it: 'INFORMAZIONI'
	String get info => 'INFORMAZIONI';

	/// it: 'Versione'
	String get version => 'Versione';

	/// it: 'Elimina tutti i dati'
	String get deleteAllData => 'Elimina tutti i dati';

	/// it: 'Eliminare tutto?'
	String get deleteAllTitle => 'Eliminare tutto?';

	/// it: 'Questa azione eliminerà tutte le scansioni salvate. Non può essere annullata.'
	String get deleteAllMessage => 'Questa azione eliminerà tutte le scansioni salvate. Non può essere annullata.';

	/// it: 'Elimina tutto'
	String get deleteAllConfirm => 'Elimina tutto';

	/// it: 'Tutti i dati sono stati eliminati'
	String get deleteAllDone => 'Tutti i dati sono stati eliminati';

	/// it: 'Annulla'
	String get cancel => 'Annulla';
}

// Path: achievements
class TranslationsAchievementsIt {
	TranslationsAchievementsIt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// it: 'Presto disponibile'
	String get comingSoon => 'Presto disponibile';

	/// it: 'I tuoi traguardi appariranno qui'
	String get comingSoonDesc => 'I tuoi traguardi appariranno qui';
}

// Path: vin
class TranslationsVinIt {
	TranslationsVinIt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// it: 'Dove trovo il telaio?'
	String get title => 'Dove trovo il telaio?';

	/// it: 'Il VIN (Vehicle Identification Number) può trovarsi in diverse posizioni a seconda del modello e dell'anno.'
	String get subtitle => 'Il VIN (Vehicle Identification Number) può trovarsi in diverse posizioni a seconda del modello e dell\'anno.';

	/// it: 'Dove trovo il numero di telaio?'
	String get pageTitle => 'Dove trovo il numero di telaio?';

	/// it: 'Targhetta sul cruscotto'
	String get dashboard => 'Targhetta sul cruscotto';

	/// it: 'Visibile dall'esterno attraverso il parabrezza, lato passeggero. È il metodo più semplice per auto dal 1981 in poi.'
	String get dashboardDesc => 'Visibile dall\'esterno attraverso il parabrezza, lato passeggero. È il metodo più semplice per auto dal 1981 in poi.';

	/// it: 'Montante portiera'
	String get doorPillar => 'Montante portiera';

	/// it: 'Aprendo la portiera lato guida, sul montante verticale trovi un'etichetta con il VIN e altre informazioni.'
	String get doorPillarDesc => 'Aprendo la portiera lato guida, sul montante verticale trovi un\'etichetta con il VIN e altre informazioni.';

	/// it: 'Vano motore'
	String get engineBay => 'Vano motore';

	/// it: 'Targhetta rivettata nel vano motore, spesso sulla parete parafiamma o sul passaruota. Comune in auto italiane pre-1981.'
	String get engineBayDesc => 'Targhetta rivettata nel vano motore, spesso sulla parete parafiamma o sul passaruota. Comune in auto italiane pre-1981.';

	/// it: 'Libretto di circolazione'
	String get registration => 'Libretto di circolazione';

	/// it: 'Il numero di telaio è riportato alla voce (E) del libretto di circolazione. Puoi fotografare il libretto e l'app leggerà il VIN automaticamente.'
	String get registrationDesc => 'Il numero di telaio è riportato alla voce (E) del libretto di circolazione. Puoi fotografare il libretto e l\'app leggerà il VIN automaticamente.';

	/// it: 'Bagagliaio'
	String get trunk => 'Bagagliaio';

	/// it: 'Sotto il tappetino del bagagliaio o sul passaruota posteriore. Tipico di Fiat 500, 600, 850.'
	String get trunkDesc => 'Sotto il tappetino del bagagliaio o sul passaruota posteriore. Tipico di Fiat 500, 600, 850.';

	/// it: 'Certificato ASI'
	String get asiCert => 'Certificato ASI';

	/// it: 'Se l'auto è iscritta all'ASI, il numero di telaio è riportato sul certificato di rilevanza storica.'
	String get asiCertDesc => 'Se l\'auto è iscritta all\'ASI, il numero di telaio è riportato sul certificato di rilevanza storica.';

	/// it: 'Telaio/scocca'
	String get chassis => 'Telaio/scocca';

	/// it: 'Stampigliato direttamente sulla scocca o sul telaio. Posizione variabile: spesso sotto il cofano anteriore o nel bagagliaio.'
	String get chassisDesc => 'Stampigliato direttamente sulla scocca o sul telaio. Posizione variabile: spesso sotto il cofano anteriore o nel bagagliaio.';

	/// it: 'Per auto dal 1981 in poi, il VIN ha sempre 17 caratteri. Per auto precedenti, il formato varia per marca.'
	String get infoNote => 'Per auto dal 1981 in poi, il VIN ha sempre 17 caratteri. Per auto precedenti, il formato varia per marca.';

	/// it: 'Auto pre-1981 possono avere numeri più corti (8-13 cifre) con formati specifici del costruttore.'
	String get infoNote2 => 'Auto pre-1981 possono avere numeri più corti (8-13 cifre) con formati specifici del costruttore.';

	/// it: 'Ho capito'
	String get understood => 'Ho capito';

	/// it: 'Inserisci il VIN manualmente'
	String get enterVin => 'Inserisci il VIN manualmente';

	/// it: 'Es: ZARFAEAV4N7600001'
	String get vinHint => 'Es: ZARFAEAV4N7600001';

	/// it: 'Decodifica VIN'
	String get decode => 'Decodifica VIN';
}

// Path: garage.specs
class TranslationsGarageSpecsIt {
	TranslationsGarageSpecsIt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// it: 'Motore'
	String get engine => 'Motore';

	/// it: 'Potenza'
	String get power => 'Potenza';

	/// it: 'Cambio'
	String get gearbox => 'Cambio';

	/// it: 'Peso'
	String get weight => 'Peso';

	/// it: 'Velocità max'
	String get topSpeed => 'Velocità max';

	/// it: 'Produzione'
	String get production => 'Produzione';

	/// it: '${n} esemplari'
	String productionValue({required Object n}) => '${n} esemplari';

	/// it: 'Design'
	String get design => 'Design';
}

// Path: garage.shareText
class TranslationsGarageShareTextIt {
	TranslationsGarageShareTextIt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// it: 'Attendibilità ricerca: ${percent}%'
	String searchReliability({required Object percent}) => 'Attendibilità ricerca: ${percent}%';

	/// it: 'Motore: ${value}'
	String engine({required Object value}) => 'Motore: ${value}';

	/// it: 'Potenza: ${value}'
	String power({required Object value}) => 'Potenza: ${value}';

	/// it: 'Cambio: ${value}'
	String gearbox({required Object value}) => 'Cambio: ${value}';

	/// it: 'Peso: ${value}'
	String weight({required Object value}) => 'Peso: ${value}';

	/// it: 'Velocità max: ${value}'
	String topSpeed({required Object value}) => 'Velocità max: ${value}';

	/// it: 'Produzione: ${value} esemplari'
	String production({required Object value}) => 'Produzione: ${value} esemplari';

	/// it: 'Design: ${value}'
	String design({required Object value}) => 'Design: ${value}';

	/// it: 'Stima di mercato: ${value}'
	String marketEstimate({required Object value}) => 'Stima di mercato: ${value}';

	/// it: 'Telaio: ${value}'
	String vin({required Object value}) => 'Telaio: ${value}';

	/// it: 'Originalità: ${value}%'
	String originality({required Object value}) => 'Originalità: ${value}%';

	/// it: 'Analizzato con CarLens'
	String get footer => 'Analizzato con CarLens';
}

// Path: results.specs
class TranslationsResultsSpecsIt {
	TranslationsResultsSpecsIt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// it: 'Motore'
	String get engine => 'Motore';

	/// it: 'Potenza'
	String get power => 'Potenza';

	/// it: 'Trasmissione'
	String get transmission => 'Trasmissione';

	/// it: 'Cambio'
	String get gearbox => 'Cambio';

	/// it: 'Peso'
	String get weight => 'Peso';

	/// it: 'Velocità max'
	String get topSpeed => 'Velocità max';

	/// it: 'Dimensioni'
	String get dimensions => 'Dimensioni';

	/// it: 'Passo'
	String get wheelbase => 'Passo';

	/// it: 'Anni di produzione'
	String get years => 'Anni di produzione';

	/// it: 'Esemplari prodotti'
	String get produced => 'Esemplari prodotti';

	/// it: 'Produzione'
	String get production => 'Produzione';

	/// it: '${n} esemplari'
	String productionValue({required Object n}) => '${n} esemplari';

	/// it: 'Designer'
	String get designer => 'Designer';

	/// it: 'Design'
	String get design => 'Design';

	/// it: 'Valore di mercato'
	String get marketValue => 'Valore di mercato';

	/// it: 'Lo sapevi che...'
	String get curiosity => 'Lo sapevi che...';
}

// Path: results.shareText
class TranslationsResultsShareTextIt {
	TranslationsResultsShareTextIt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// it: 'Auto identificata con CarLens'
	String get header => 'Auto identificata con CarLens';

	/// it: 'Attendibilità ricerca: ${percent}%'
	String searchReliability({required Object percent}) => 'Attendibilità ricerca: ${percent}%';

	/// it: 'Motore: ${value}'
	String engine({required Object value}) => 'Motore: ${value}';

	/// it: 'Potenza: ${value}'
	String power({required Object value}) => 'Potenza: ${value}';

	/// it: 'Cambio: ${value}'
	String gearbox({required Object value}) => 'Cambio: ${value}';

	/// it: 'Peso: ${value}'
	String weight({required Object value}) => 'Peso: ${value}';

	/// it: 'Velocità max: ${value}'
	String topSpeed({required Object value}) => 'Velocità max: ${value}';

	/// it: 'Trasmissione: ${value}'
	String transmission({required Object value}) => 'Trasmissione: ${value}';

	/// it: 'Produzione: ${value}'
	String production({required Object value}) => 'Produzione: ${value}';

	/// it: 'Produzione: ${value} esemplari'
	String productionWithUnits({required Object value}) => 'Produzione: ${value} esemplari';

	/// it: 'Design: ${value}'
	String design({required Object value}) => 'Design: ${value}';

	/// it: 'Valore di mercato: ${value}'
	String marketValue({required Object value}) => 'Valore di mercato: ${value}';

	/// it: 'Stima di mercato: ${value}'
	String marketEstimate({required Object value}) => 'Stima di mercato: ${value}';

	/// it: 'Telaio: ${value}'
	String vin({required Object value}) => 'Telaio: ${value}';

	/// it: 'Costruttore: ${value}'
	String manufacturer({required Object value}) => 'Costruttore: ${value}';

	/// it: 'Anno (da VIN): ${value}'
	String yearFromVin({required Object value}) => 'Anno (da VIN): ${value}';

	/// it: 'Originalità: ${value}%'
	String originality({required Object value}) => 'Originalità: ${value}%';

	/// it: 'Motore: ${value}'
	String engineConform({required Object value}) => 'Motore: ${value}';

	/// it: 'Cambio: ${value}'
	String gearboxConform({required Object value}) => 'Cambio: ${value}';

	/// it: 'Carrozzeria: ${value}'
	String bodyConform({required Object value}) => 'Carrozzeria: ${value}';

	/// it: 'Analizzato con CarLens'
	String get footer => 'Analizzato con CarLens';
}

// Path: results.level2
class TranslationsResultsLevel2It {
	TranslationsResultsLevel2It._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// it: 'Analisi approfondita'
	String get deepAnalysis => 'Analisi approfondita';

	/// it: 'Approfondimento in corso...'
	String get loading => 'Approfondimento in corso...';

	/// it: 'TIMELINE'
	String get timeline => 'TIMELINE';

	/// it: 'PRODUZIONE'
	String get production => 'PRODUZIONE';

	/// it: 'DETTAGLI TECNICI'
	String get techDetails => 'DETTAGLI TECNICI';

	/// it: 'VALORE DI MERCATO'
	String get marketValue => 'VALORE DI MERCATO';

	/// it: 'CURIOSITÀ'
	String get curiosities => 'CURIOSITÀ';

	/// it: 'Costruttore'
	String get manufacturer => 'Costruttore';

	/// it: 'Paese'
	String get country => 'Paese';

	/// it: 'Anno'
	String get year => 'Anno';

	/// it: 'Numero di serie'
	String get serialNumber => 'Numero di serie';

	/// it: 'DATI DA TELAIO'
	String get vinData => 'DATI DA TELAIO';
}

// Path: results.market
class TranslationsResultsMarketIt {
	TranslationsResultsMarketIt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// it: 'STIMA DI MERCATO'
	String get title => 'STIMA DI MERCATO';

	/// it: 'Esemplare in buone condizioni. Stima indicativa.'
	String get disclaimer => 'Esemplare in buone condizioni. Stima indicativa.';

	/// it: 'Stima di mercato: ${value}'
	String estimate({required Object value}) => 'Stima di mercato: ${value}';
}

// Path: results.originality
class TranslationsResultsOriginalityIt {
	TranslationsResultsOriginalityIt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// it: 'ORIGINALITÀ'
	String get title => 'ORIGINALITÀ';

	/// it: 'su 100'
	String get outOf100 => 'su 100';

	/// it: 'Eccellente corrispondenza'
	String get excellent => 'Eccellente corrispondenza';

	/// it: 'Buona corrispondenza'
	String get good => 'Buona corrispondenza';

	/// it: 'Discreta corrispondenza'
	String get fair => 'Discreta corrispondenza';

	/// it: 'Bassa corrispondenza'
	String get low => 'Bassa corrispondenza';

	/// it: 'Motore'
	String get engine => 'Motore';

	/// it: 'Cambio'
	String get gearbox => 'Cambio';

	/// it: 'Carrozzeria'
	String get body => 'Carrozzeria';

	/// it: 'Conforme'
	String get conform => 'Conforme';

	/// it: 'Non conforme'
	String get nonConform => 'Non conforme';

	/// it: 'conforme'
	String get conformLower => 'conforme';

	/// it: 'non conforme'
	String get nonConformLower => 'non conforme';

	/// it: 'DIFFERENZE RILEVATE'
	String get differencesFound => 'DIFFERENZE RILEVATE';

	/// it: 'Diverso'
	String get badgeDiverso => 'Diverso';

	/// it: 'Conforme'
	String get badgeConforme => 'Conforme';

	/// it: 'Info'
	String get badgeInfo => 'Info';

	/// it: 'IN CONCLUSIONE'
	String get conclusion => 'IN CONCLUSIONE';

	/// it: 'Questo report non sostituisce una perizia tecnica. Per certificazioni ufficiali, rivolgersi al Registro Storico o all'ASI.'
	String get disclaimer => 'Questo report non sostituisce una perizia tecnica. Per certificazioni ufficiali, rivolgersi al Registro Storico o all\'ASI.';
}

// Path: results.listing
class TranslationsResultsListingIt {
	TranslationsResultsListingIt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// it: 'DATI ANNUNCIO'
	String get title => 'DATI ANNUNCIO';

	/// it: 'Prezzo richiesto'
	String get askingPrice => 'Prezzo richiesto';

	/// it: 'Km dichiarati'
	String get mileage => 'Km dichiarati';

	/// it: 'Provenienza'
	String get source => 'Provenienza';

	/// it: 'Stima di mercato: ${value}'
	String marketEstimate({required Object value}) => 'Stima di mercato: ${value}';
}

// Path: results.vinSpecs
class TranslationsResultsVinSpecsIt {
	TranslationsResultsVinSpecsIt._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// it: 'Motore'
	String get engineType => 'Motore';

	/// it: 'Cilindrata'
	String get displacement => 'Cilindrata';

	/// it: 'Alimentazione'
	String get fuelSystem => 'Alimentazione';

	/// it: 'Cambio'
	String get transmission => 'Cambio';

	/// it: 'Carrozzeria'
	String get bodyStyle => 'Carrozzeria';

	/// it: 'Trazione'
	String get driveType => 'Trazione';

	/// it: 'Codice VDS'
	String get vdsCode => 'Codice VDS';
}

/// The flat map containing all translations for locale <it>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.name' => 'CARLENS',
			'app.tagline' => 'Identifica la tua classica',
			'app.loading' => 'Caricamento...',
			'nav.home' => 'Home',
			'nav.garage' => 'Garage',
			'nav.achievements' => 'Traguardi',
			'home.takePhoto' => 'Scatta una foto',
			'home.loadFromGallery' => 'oppure carica dalla galleria (fino a 3 foto)',
			'home.pasteLink' => 'Incolla Link',
			'home.noValidLink' => 'Nessun link valido negli appunti',
			'home.linkCopied' => 'Link copiato dagli appunti',
			'home.analyzing' => 'Analisi in corso...',
			'home.invalidUrl' => 'URL non valido o non supportato',
			'home.supportedSites' => 'Siti supportati: Subito.it, AutoScout24',
			'home.analyzingSubito' => 'Analisi annuncio Subito.it...',
			'home.analyzingAutoScout' => 'Analisi annuncio AutoScout24...',
			'home.analyzingLink' => 'Analisi link in corso...',
			'home.photoTips' => 'Per risultati migliori',
			'home.photoTipsDesc' => 'Inquadra l\'auto intera, con buona luce e da più angolazioni',
			'home.subtitle' => 'Il tuo identificatore di auto d\'epoca',
			'home.snapAndIdentify' => 'Scatta e identifica',
			'home.chooseFromGallery' => 'Scegli dalla galleria',
			'home.gallery' => 'Galleria',
			'home.marketplaceSites' => 'Subito.it, AutoScout24',
			'garage.title' => 'Il tuo Garage',
			'garage.empty' => 'Il tuo garage è vuoto',
			'garage.emptySubtitle' => 'Scansiona la tua prima auto storica\nper iniziare la tua collezione',
			'garage.searchHint' => 'Cerca per marca, modello, anno...',
			'garage.deleteTitle' => 'Elimina scansione',
			'garage.deleteMessage' => ({required Object brand, required Object model}) => 'Vuoi eliminare ${brand} ${model}?',
			'garage.cancel' => 'Annulla',
			'garage.delete' => 'Elimina',
			'garage.deleted' => 'Scansione eliminata',
			'garage.undo' => 'Annulla',
			'garage.scannedCount' => ({required Object n}) => '${n} auto scansionate',
			'garage.scannedCountOne' => '1 auto scansionata',
			'garage.verifiedCount' => ({required Object n}) => '${n} verificate',
			'garage.verifiedCountOne' => '1 verificata',
			'garage.brandCount' => ({required Object n}) => '${n} marchi',
			'garage.brandCountOne' => '1 marchio',
			'garage.all' => 'Tutte',
			'garage.stats' => 'STATISTICHE',
			'garage.filters' => 'FILTRI',
			'garage.sortRecent' => 'Più recenti',
			'garage.sortOldest' => 'Più vecchi',
			'garage.noResults' => 'Nessun risultato',
			'garage.confidence' => 'Attendibilità',
			'garage.level' => 'Livello',
			'garage.identified' => 'Identificato',
			'garage.verified' => 'Verificato',
			'garage.topBrand' => 'top marca',
			'garage.share' => 'Condividi',
			'garage.shareTitle' => 'Condividi scheda',
			'garage.shareSubject' => 'Scheda auto - CarLens',
			'garage.shareVia' => 'Analizzato con CarLens',
			'garage.quickSpecs' => 'SCHEDA RAPIDA',
			'garage.modelHistory' => 'STORIA DEL MODELLO',
			'garage.marketEstimate' => 'STIMA DI MERCATO',
			'garage.marketDisclaimer' => 'Esemplare in buone condizioni. Stima indicativa.',
			'garage.funFact' => 'LO SAPEVI?',
			'garage.originalityLabel' => 'Originalità',
			'garage.originalityReport' => 'REPORT ORIGINALITÀ',
			'garage.originalityExcellent' => 'Eccellente',
			'garage.originalityGood' => 'Buona',
			'garage.originalityFair' => 'Discreta',
			'garage.originalityLow' => 'Bassa',
			'garage.deleteAction' => 'Elimina scansione',
			'garage.addVin' => 'Aggiungi telaio per saperne di più',
			'garage.verifyOriginality' => 'Verifica originalità',
			'garage.photoUnavailable' => 'Foto originale non disponibile. Scansiona di nuovo.',
			'garage.identificationOnly' => 'Solo identificazione',
			'garage.from' => ({required Object source}) => 'DA ${source}',
			'garage.askingPrice' => 'Prezzo richiesto',
			'garage.mileage' => 'Km dichiarati',
			'garage.originalityScore' => ({required Object score}) => 'Originalità ${score}/100',
			'garage.specs.engine' => 'Motore',
			'garage.specs.power' => 'Potenza',
			'garage.specs.gearbox' => 'Cambio',
			'garage.specs.weight' => 'Peso',
			'garage.specs.topSpeed' => 'Velocità max',
			'garage.specs.production' => 'Produzione',
			'garage.specs.productionValue' => ({required Object n}) => '${n} esemplari',
			'garage.specs.design' => 'Design',
			'garage.shareText.searchReliability' => ({required Object percent}) => 'Attendibilità ricerca: ${percent}%',
			'garage.shareText.engine' => ({required Object value}) => 'Motore: ${value}',
			'garage.shareText.power' => ({required Object value}) => 'Potenza: ${value}',
			'garage.shareText.gearbox' => ({required Object value}) => 'Cambio: ${value}',
			'garage.shareText.weight' => ({required Object value}) => 'Peso: ${value}',
			'garage.shareText.topSpeed' => ({required Object value}) => 'Velocità max: ${value}',
			'garage.shareText.production' => ({required Object value}) => 'Produzione: ${value} esemplari',
			'garage.shareText.design' => ({required Object value}) => 'Design: ${value}',
			'garage.shareText.marketEstimate' => ({required Object value}) => 'Stima di mercato: ${value}',
			'garage.shareText.vin' => ({required Object value}) => 'Telaio: ${value}',
			'garage.shareText.originality' => ({required Object value}) => 'Originalità: ${value}%',
			'garage.shareText.footer' => 'Analizzato con CarLens',
			'results.title' => 'Risultato',
			'results.analyzing' => 'Analisi in corso...',
			'results.analyzingListing' => 'Analisi annuncio in corso...',
			'results.analyzingSubtitle' => 'L\'AI sta identificando l\'auto',
			'results.analyzingListingSubtitle' => 'Scaricamento foto e identificazione',
			'results.quickSpecs' => 'SCHEDA RAPIDA',
			'results.identified' => 'Identificato',
			'results.identifiedWithPercent' => ({required Object percent}) => 'Identificato · ${percent}%',
			'results.wantToKnowMore' => 'Vuoi saperne di più?',
			'results.vinInviteDesc' => 'Inserisci il numero di telaio per scoprire le specifiche esatte del tuo esemplare.',
			'results.whereIsVin' => 'Dove trovo il telaio? ⓘ',
			'results.enterVin' => 'Inserisci telaio',
			'results.decode' => 'Decodifica',
			'results.share' => 'Condividi scheda',
			'results.retry' => 'Riprova',
			'results.error' => 'Si è verificato un errore. Riprova.',
			'results.errorRetry' => 'Errore durante l\'analisi',
			'results.saved' => 'Salvata nel garage',
			'results.savedExcl' => 'Auto salvata nel Garage!',
			'results.alreadySaved' => 'Già nel garage',
			'results.save' => 'Salva nel garage',
			'results.savedInGarage' => 'Salvata nel Garage',
			'results.saveToGarage' => 'Salva nel Garage',
			'results.vinFound' => ({required Object vin}) => 'Telaio trovato: ${vin}',
			'results.vinNotFound' => 'Nessun VIN trovato nelle immagini',
			'results.vinNotRecognized' => 'Nessun numero di telaio riconosciuto. Prova ad avvicinare la fotocamera.',
			'results.vinReadError' => 'Errore nella lettura. Inserisci il telaio manualmente.',
			'results.vinFormatError' => 'Formato telaio non riconosciuto. Controlla e riprova.',
			'results.vinCheckDigitWarning' => 'Attenzione: il check digit non corrisponde. I VIN europei spesso non lo utilizzano.',
			'results.vinDecodeError' => 'Errore nella decodifica del telaio. Controlla e riprova.',
			'results.scanVin' => 'Scansiona telaio',
			'results.vinDecoded' => 'VIN decodificato',
			'results.vinReading' => 'Lettura targhetta in corso...',
			'results.searchReliability' => ({required Object percent}) => 'Attendibilità ricerca: ${percent}%',
			'results.notThisCar' => 'Non è quest\'auto?',
			'results.showAlternatives' => 'Mostra alternative di identificazione',
			'results.correctionFeedback' => 'Grazie per il feedback! Riprova con un\'altra foto.',
			'results.saveError' => 'Errore nel salvataggio. Riprova.',
			'results.reportError' => 'Errore nella generazione del report. Riprova.',
			'results.reportGenerating' => 'Generazione report in corso...',
			'results.reportGeneratingSubtitle' => 'L\'AI sta confrontando le specifiche',
			'results.techSheet' => 'Scheda tecnica',
			'results.specs.engine' => 'Motore',
			'results.specs.power' => 'Potenza',
			'results.specs.transmission' => 'Trasmissione',
			'results.specs.gearbox' => 'Cambio',
			'results.specs.weight' => 'Peso',
			'results.specs.topSpeed' => 'Velocità max',
			'results.specs.dimensions' => 'Dimensioni',
			'results.specs.wheelbase' => 'Passo',
			'results.specs.years' => 'Anni di produzione',
			'results.specs.produced' => 'Esemplari prodotti',
			'results.specs.production' => 'Produzione',
			'results.specs.productionValue' => ({required Object n}) => '${n} esemplari',
			'results.specs.designer' => 'Designer',
			'results.specs.design' => 'Design',
			'results.specs.marketValue' => 'Valore di mercato',
			'results.specs.curiosity' => 'Lo sapevi che...',
			'results.shareText.header' => 'Auto identificata con CarLens',
			'results.shareText.searchReliability' => ({required Object percent}) => 'Attendibilità ricerca: ${percent}%',
			'results.shareText.engine' => ({required Object value}) => 'Motore: ${value}',
			'results.shareText.power' => ({required Object value}) => 'Potenza: ${value}',
			'results.shareText.gearbox' => ({required Object value}) => 'Cambio: ${value}',
			'results.shareText.weight' => ({required Object value}) => 'Peso: ${value}',
			'results.shareText.topSpeed' => ({required Object value}) => 'Velocità max: ${value}',
			'results.shareText.transmission' => ({required Object value}) => 'Trasmissione: ${value}',
			'results.shareText.production' => ({required Object value}) => 'Produzione: ${value}',
			'results.shareText.productionWithUnits' => ({required Object value}) => 'Produzione: ${value} esemplari',
			'results.shareText.design' => ({required Object value}) => 'Design: ${value}',
			'results.shareText.marketValue' => ({required Object value}) => 'Valore di mercato: ${value}',
			'results.shareText.marketEstimate' => ({required Object value}) => 'Stima di mercato: ${value}',
			'results.shareText.vin' => ({required Object value}) => 'Telaio: ${value}',
			'results.shareText.manufacturer' => ({required Object value}) => 'Costruttore: ${value}',
			'results.shareText.yearFromVin' => ({required Object value}) => 'Anno (da VIN): ${value}',
			'results.shareText.originality' => ({required Object value}) => 'Originalità: ${value}%',
			'results.shareText.engineConform' => ({required Object value}) => 'Motore: ${value}',
			'results.shareText.gearboxConform' => ({required Object value}) => 'Cambio: ${value}',
			'results.shareText.bodyConform' => ({required Object value}) => 'Carrozzeria: ${value}',
			'results.shareText.footer' => 'Analizzato con CarLens',
			'results.level2.deepAnalysis' => 'Analisi approfondita',
			'results.level2.loading' => 'Approfondimento in corso...',
			'results.level2.timeline' => 'TIMELINE',
			'results.level2.production' => 'PRODUZIONE',
			'results.level2.techDetails' => 'DETTAGLI TECNICI',
			'results.level2.marketValue' => 'VALORE DI MERCATO',
			'results.level2.curiosities' => 'CURIOSITÀ',
			'results.level2.manufacturer' => 'Costruttore',
			'results.level2.country' => 'Paese',
			'results.level2.year' => 'Anno',
			'results.level2.serialNumber' => 'Numero di serie',
			'results.level2.vinData' => 'DATI DA TELAIO',
			'results.market.title' => 'STIMA DI MERCATO',
			'results.market.disclaimer' => 'Esemplare in buone condizioni. Stima indicativa.',
			'results.market.estimate' => ({required Object value}) => 'Stima di mercato: ${value}',
			'results.modelHistory' => 'STORIA DEL MODELLO',
			'results.funFact' => 'LO SAPEVI?',
			'results.alternatives' => 'POTREBBE ANCHE ESSERE',
			'results.verified' => 'Verificato',
			'results.originality.title' => 'ORIGINALITÀ',
			'results.originality.outOf100' => 'su 100',
			'results.originality.excellent' => 'Eccellente corrispondenza',
			'results.originality.good' => 'Buona corrispondenza',
			'results.originality.fair' => 'Discreta corrispondenza',
			'results.originality.low' => 'Bassa corrispondenza',
			'results.originality.engine' => 'Motore',
			'results.originality.gearbox' => 'Cambio',
			'results.originality.body' => 'Carrozzeria',
			'results.originality.conform' => 'Conforme',
			'results.originality.nonConform' => 'Non conforme',
			'results.originality.conformLower' => 'conforme',
			'results.originality.nonConformLower' => 'non conforme',
			'results.originality.differencesFound' => 'DIFFERENZE RILEVATE',
			'results.originality.badgeDiverso' => 'Diverso',
			'results.originality.badgeConforme' => 'Conforme',
			'results.originality.badgeInfo' => 'Info',
			'results.originality.conclusion' => 'IN CONCLUSIONE',
			'results.originality.disclaimer' => 'Questo report non sostituisce una perizia tecnica. Per certificazioni ufficiali, rivolgersi al Registro Storico o all\'ASI.',
			'results.listing.title' => 'DATI ANNUNCIO',
			'results.listing.askingPrice' => 'Prezzo richiesto',
			'results.listing.mileage' => 'Km dichiarati',
			'results.listing.source' => 'Provenienza',
			'results.listing.marketEstimate' => ({required Object value}) => 'Stima di mercato: ${value}',
			'results.vinSpecs.engineType' => 'Motore',
			'results.vinSpecs.displacement' => 'Cilindrata',
			'results.vinSpecs.fuelSystem' => 'Alimentazione',
			'results.vinSpecs.transmission' => 'Cambio',
			'results.vinSpecs.bodyStyle' => 'Carrozzeria',
			'results.vinSpecs.driveType' => 'Trazione',
			'results.vinSpecs.vdsCode' => 'Codice VDS',
			'settings.title' => 'Impostazioni',
			'settings.notifications' => 'NOTIFICHE',
			'settings.dailyCuriosity' => 'Curiosità del giorno',
			'settings.dailyCuriosityDesc' => 'Ricevi ogni giorno una curiosità sulle auto storiche',
			'settings.info' => 'INFORMAZIONI',
			'settings.version' => 'Versione',
			'settings.deleteAllData' => 'Elimina tutti i dati',
			'settings.deleteAllTitle' => 'Eliminare tutto?',
			'settings.deleteAllMessage' => 'Questa azione eliminerà tutte le scansioni salvate. Non può essere annullata.',
			'settings.deleteAllConfirm' => 'Elimina tutto',
			'settings.deleteAllDone' => 'Tutti i dati sono stati eliminati',
			'settings.cancel' => 'Annulla',
			'achievements.comingSoon' => 'Presto disponibile',
			'achievements.comingSoonDesc' => 'I tuoi traguardi appariranno qui',
			'vin.title' => 'Dove trovo il telaio?',
			'vin.subtitle' => 'Il VIN (Vehicle Identification Number) può trovarsi in diverse posizioni a seconda del modello e dell\'anno.',
			'vin.pageTitle' => 'Dove trovo il numero di telaio?',
			'vin.dashboard' => 'Targhetta sul cruscotto',
			'vin.dashboardDesc' => 'Visibile dall\'esterno attraverso il parabrezza, lato passeggero. È il metodo più semplice per auto dal 1981 in poi.',
			'vin.doorPillar' => 'Montante portiera',
			'vin.doorPillarDesc' => 'Aprendo la portiera lato guida, sul montante verticale trovi un\'etichetta con il VIN e altre informazioni.',
			'vin.engineBay' => 'Vano motore',
			'vin.engineBayDesc' => 'Targhetta rivettata nel vano motore, spesso sulla parete parafiamma o sul passaruota. Comune in auto italiane pre-1981.',
			'vin.registration' => 'Libretto di circolazione',
			'vin.registrationDesc' => 'Il numero di telaio è riportato alla voce (E) del libretto di circolazione. Puoi fotografare il libretto e l\'app leggerà il VIN automaticamente.',
			'vin.trunk' => 'Bagagliaio',
			'vin.trunkDesc' => 'Sotto il tappetino del bagagliaio o sul passaruota posteriore. Tipico di Fiat 500, 600, 850.',
			'vin.asiCert' => 'Certificato ASI',
			'vin.asiCertDesc' => 'Se l\'auto è iscritta all\'ASI, il numero di telaio è riportato sul certificato di rilevanza storica.',
			'vin.chassis' => 'Telaio/scocca',
			'vin.chassisDesc' => 'Stampigliato direttamente sulla scocca o sul telaio. Posizione variabile: spesso sotto il cofano anteriore o nel bagagliaio.',
			'vin.infoNote' => 'Per auto dal 1981 in poi, il VIN ha sempre 17 caratteri. Per auto precedenti, il formato varia per marca.',
			'vin.infoNote2' => 'Auto pre-1981 possono avere numeri più corti (8-13 cifre) con formati specifici del costruttore.',
			'vin.understood' => 'Ho capito',
			'vin.enterVin' => 'Inserisci il VIN manualmente',
			'vin.vinHint' => 'Es: ZARFAEAV4N7600001',
			'vin.decode' => 'Decodifica VIN',
			_ => null,
		};
	}
}
