import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _enabledKey = 'notifications_enabled';
  static const String _indexKey = 'curiosity_index';
  static const String _channelId = 'carlens_daily';
  static const String _channelName = 'Curiosità del giorno';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  List<Map<String, dynamic>> _curiosities = [];
  bool _initialized = false;

  FlutterLocalNotificationsPlugin get plugin => _plugin;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings: initSettings);

    await _loadCuriosities();

    final enabled = await isEnabled();
    if (enabled) {
      await scheduleDailyNotification();
    }

    _initialized = true;
  }

  Future<void> _loadCuriosities() async {
    final jsonString =
        await rootBundle.loadString('assets/data/curiosities.json');
    final List<dynamic> decoded = json.decode(jsonString);
    _curiosities = decoded.cast<Map<String, dynamic>>();
  }

  /// Load curiosities from a raw JSON string (for testing).
  void loadCuriositiesFromJson(String jsonString) {
    final List<dynamic> decoded = json.decode(jsonString);
    _curiosities = decoded.cast<Map<String, dynamic>>();
  }

  List<Map<String, dynamic>> get curiosities => _curiosities;

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? true; // Default: enabled
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
    if (value) {
      await scheduleDailyNotification();
    } else {
      await cancelAll();
    }
  }

  Future<int> _getAndIncrementIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final currentIndex = prefs.getInt(_indexKey) ?? 0;
    final nextIndex =
        _curiosities.isEmpty ? 0 : (currentIndex + 1) % _curiosities.length;
    await prefs.setInt(_indexKey, nextIndex);
    return currentIndex;
  }

  Future<int> getCurrentIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_indexKey) ?? 0;
  }

  Future<void> scheduleDailyNotification() async {
    if (_curiosities.isEmpty) return;

    await cancelAll();

    final index = await _getAndIncrementIndex();
    final curiosity = _curiosities[index % _curiosities.length];

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Curiosità giornaliere sulle auto storiche',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      styleInformation: BigTextStyleInformation(
        curiosity['body'] as String,
        contentTitle: curiosity['title'] as String,
      ),
    );

    final details = NotificationDetails(android: androidDetails);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      10, // 10:00
    );

    // If 10:00 has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: 0,
      title: curiosity['title'] as String,
      body: curiosity['body'] as String,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
