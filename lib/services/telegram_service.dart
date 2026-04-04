import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Service that sends notifications to a Telegram group
/// when users scan cars or add VIN data.
class TelegramService {
  static final TelegramService _instance = TelegramService._internal();
  factory TelegramService() => _instance;
  TelegramService._internal();

  // Bot token and chat ID — configured for CarLens monitor group
  // To set up: create a bot via @BotFather, add it to a group,
  // then call getUpdates to find the chat_id.
  static const String _botToken = String.fromEnvironment('TELEGRAM_BOT_TOKEN');
  static const String _chatId = String.fromEnvironment('TELEGRAM_CHAT_ID');

  bool get isConfigured => _botToken.isNotEmpty && _chatId.isNotEmpty;

  String? _deviceId;

  /// Returns a stable anonymous device ID (hash of device info).
  Future<String> _getDeviceId() async {
    if (_deviceId != null) return _deviceId!;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/.carlens_device_id');

      if (await file.exists()) {
        _deviceId = await file.readAsString();
      } else {
        // Generate a short random ID
        final now = DateTime.now().microsecondsSinceEpoch;
        _deviceId = 'user_${now.toRadixString(36).substring(0, 6)}';
        await file.writeAsString(_deviceId!);
      }
    } catch (_) {
      _deviceId = 'user_unknown';
    }

    return _deviceId!;
  }

  /// Notify when a car is scanned and saved (L1).
  Future<void> notifyNewScan({
    required String brand,
    required String model,
    required String yearEstimate,
    required String bodyType,
    required double confidence,
    required int level,
    String? imagePath,
  }) async {
    if (!isConfigured) return;

    final deviceId = await _getDeviceId();
    final now = DateTime.now();
    final timestamp =
        '${now.day}/${now.month}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final text = StringBuffer()
      ..writeln('\u{1F697} Nuova scansione CarLens')
      ..writeln()
      ..writeln('$brand $model')
      ..writeln('$yearEstimate \u00b7 $bodyType')
      ..writeln('Attendibilit\u00e0: ${(confidence * 100).round()}%')
      ..writeln('Livello: L$level')
      ..writeln()
      ..writeln('\u{1F4F1} Utente: #$deviceId')
      ..writeln('\u{1F552} $timestamp');

    if (imagePath != null && File(imagePath).existsSync()) {
      await _sendPhoto(imagePath, text.toString());
    } else {
      await _sendMessage(text.toString());
    }
  }

  /// Notify when a car is scanned from a marketplace listing.
  Future<void> notifyMarketplaceScan({
    required String brand,
    required String model,
    required String yearEstimate,
    required String bodyType,
    required double confidence,
    required String sourceUrl,
    required String sourceName,
    String? askingPrice,
    String? mileage,
    String? imagePath,
  }) async {
    if (!isConfigured) return;

    final deviceId = await _getDeviceId();
    final now = DateTime.now();
    final months = [
      '', 'gen', 'feb', 'mar', 'apr', 'mag', 'giu',
      'lug', 'ago', 'set', 'ott', 'nov', 'dic',
    ];
    final timestamp =
        '${now.day} ${months[now.month]} ${now.year}, '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final text = StringBuffer()
      ..writeln('\u{1F517} Scansione da marketplace - CarLens')
      ..writeln()
      ..writeln('$brand $model')
      ..writeln('$yearEstimate \u00b7 $bodyType')
      ..writeln('Attendibilit\u00e0: ${(confidence * 100).round()}%')
      ..writeln()
      ..writeln('\u{1F4CD} Fonte: $sourceName');

    if (askingPrice != null && askingPrice.isNotEmpty) {
      text.writeln('\u{1F4B0} Prezzo: $askingPrice');
    }
    if (mileage != null && mileage.isNotEmpty) {
      text.writeln('\u{1F6E3} Km: $mileage');
    }

    text
      ..writeln()
      ..writeln('\u{1F4F1} Utente: #$deviceId')
      ..writeln('\u{1F552} $timestamp');

    if (imagePath != null && File(imagePath).existsSync()) {
      await _sendPhoto(imagePath, text.toString());
    } else {
      await _sendMessage(text.toString());
    }
  }

  /// Notify when a car is saved to garage.
  Future<void> notifyGarageSave({
    required String brand,
    required String model,
    required String yearEstimate,
    required String bodyType,
    required int level,
  }) async {
    if (!isConfigured) return;

    final deviceId = await _getDeviceId();
    final now = DateTime.now();
    final timestamp =
        '${now.day}/${now.month}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final text = StringBuffer()
      ..writeln('\u{1F4BE} Auto salvata nel Garage - CarLens')
      ..writeln()
      ..writeln('$brand $model')
      ..writeln('$yearEstimate \u00b7 $bodyType')
      ..writeln('Livello: L$level')
      ..writeln()
      ..writeln('\u{1F4F1} Utente: #$deviceId')
      ..writeln('\u{1F552} $timestamp');

    await _sendMessage(text.toString());
  }

  /// Notify when a car is deleted from garage.
  Future<void> notifyGarageDelete({
    required String brand,
    required String model,
  }) async {
    if (!isConfigured) return;

    final deviceId = await _getDeviceId();
    final now = DateTime.now();
    final timestamp =
        '${now.day}/${now.month}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final text = StringBuffer()
      ..writeln('\u{1F5D1} Auto rimossa dal Garage - CarLens')
      ..writeln()
      ..writeln('$brand $model')
      ..writeln()
      ..writeln('\u{1F4F1} Utente: #$deviceId')
      ..writeln('\u{1F552} $timestamp');

    await _sendMessage(text.toString());
  }

  /// Notify when a VIN is added (upgrade to L2).
  Future<void> notifyVinAdded({
    required String brand,
    required String model,
    required String vin,
    required String decodedManufacturer,
    int? decodedYear,
  }) async {
    if (!isConfigured) return;

    final deviceId = await _getDeviceId();
    final now = DateTime.now();
    final timestamp =
        '${now.day}/${now.month}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final text = StringBuffer()
      ..writeln('\u{1F50D} VIN aggiunto - CarLens')
      ..writeln()
      ..writeln('$brand $model')
      ..writeln('VIN: $vin');

    if (decodedManufacturer.isNotEmpty && decodedManufacturer != 'Unknown') {
      text.writeln('Decodificato: $decodedManufacturer');
    }
    if (decodedYear != null) {
      text.writeln('Anno (VIN): $decodedYear');
    }

    text
      ..writeln()
      ..writeln('\u{1F4F1} Utente: #$deviceId')
      ..writeln('\u{1F552} $timestamp');

    await _sendMessage(text.toString());
  }

  Future<void> _sendMessage(String text) async {
    try {
      final url = Uri.parse(
          'https://api.telegram.org/bot$_botToken/sendMessage');
      await http.post(url, body: {
        'chat_id': _chatId,
        'text': text,
      }).timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Telegram notification failed: $e');
    }
  }

  Future<void> _sendPhoto(String imagePath, String caption) async {
    try {
      final url = Uri.parse(
          'https://api.telegram.org/bot$_botToken/sendPhoto');
      final request = http.MultipartRequest('POST', url)
        ..fields['chat_id'] = _chatId
        ..fields['caption'] = caption
        ..files.add(await http.MultipartFile.fromPath('photo', imagePath));

      await request.send().timeout(const Duration(seconds: 30));
    } catch (e) {
      debugPrint('Telegram photo notification failed: $e');
      // Fallback to text-only
      await _sendMessage(caption);
    }
  }
}
