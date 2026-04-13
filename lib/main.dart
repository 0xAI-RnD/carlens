import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:upgrader/upgrader.dart';
import 'package:version/version.dart';
import 'i18n/strings.g.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'firebase_options.dart';
import 'services/database_service.dart';
import 'services/car_data_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  LocaleSettings.setLocaleRaw('it');

  await initializeDateFormatting('it_IT', null);
  await DatabaseService().init();
  await DatabaseService().seedAchievements();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(TranslationProvider(child: const CarLensApp()));
}

class CarLensApp extends StatelessWidget {
  const CarLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarLens',
      debugShowCheckedModeBanner: false,
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: buildTheme(),
      home: const AppLoader(),
    );
  }
}

class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await CarDataService().loadData();
    } catch (e) {
      debugPrint('Error loading car data: $e');
    }
    try {
      await NotificationService().init();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
    if (mounted) {
      setState(() => _ready = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Scaffold(
        backgroundColor: context.colors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CARLENS',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  color: context.colors.textPrimary,
                  letterSpacing: 12,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: context.colors.textPrimary,
                  strokeWidth: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return UpgradeAlert(
      upgrader: Upgrader(
        storeController: UpgraderStoreController(
          onAndroid: () => UpgraderAppcastStore(
            appcastURL: 'https://gist.githubusercontent.com/0xAI-RnD/7d6904f0d7a2477fa197b03adaa47844/raw/appcast.xml',
            osVersion: Version(0, 0, 0),
          ),
        ),
        languageCode: 'it',
        durationUntilAlertAgain: const Duration(days: 1),
      ),
      child: const HomeScreen(),
    );
  }
}
