import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:upgrader/upgrader.dart';
import 'package:version/version.dart';
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

  await initializeDateFormatting('it_IT', null);
  await DatabaseService().init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const CarLensApp());
}

class CarLensApp extends StatelessWidget {
  const CarLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarLens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAFAF8),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1A1A1A),
          secondary: Color(0xFF1A1A1A),
          surface: Color(0xFFFFFFFF),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAFAF8),
          elevation: 0,
          centerTitle: true,
          foregroundColor: Color(0xFF1A1A1A),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFFFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFFAFAF8),
          selectedItemColor: Color(0xFF1A1A1A),
          unselectedItemColor: Color(0xFF8C8C8C),
        ),
      ),
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
      return const Scaffold(
        backgroundColor: Color(0xFFFAFAF8),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CARLENS',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: 12,
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Color(0xFF1A1A1A),
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
