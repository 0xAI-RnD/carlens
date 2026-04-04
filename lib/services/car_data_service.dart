import 'dart:convert';
import 'package:flutter/services.dart';

class CarDataService {
  static final CarDataService _instance = CarDataService._internal();
  factory CarDataService() => _instance;
  CarDataService._internal();

  List<Map<String, dynamic>> _cars = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  Future<void> loadData() async {
    if (_isLoaded) return;

    final jsonString = await rootBundle.loadString('assets/data/car_models.json');
    final decoded = json.decode(jsonString);
    if (decoded is List) {
      _cars = decoded.cast<Map<String, dynamic>>();
    } else if (decoded is Map<String, dynamic> && decoded.containsKey('models')) {
      _cars = (decoded['models'] as List).cast<Map<String, dynamic>>();
    } else {
      _cars = [];
    }
    _isLoaded = true;
  }

  void _ensureLoaded() {
    if (!_isLoaded) {
      throw StateError(
        'CarDataService not initialized. Call loadData() first.',
      );
    }
  }

  Map<String, dynamic>? findByBrandModel(String brand, String model) {
    _ensureLoaded();

    final brandLower = brand.toLowerCase().trim();
    final modelLower = model.toLowerCase().trim();

    for (final car in _cars) {
      final carBrand = (car['brand'] as String?)?.toLowerCase() ?? '';
      final carModel = (car['model'] as String?)?.toLowerCase() ?? '';

      if (carBrand == brandLower && carModel == modelLower) {
        return car;
      }
    }
    return null;
  }

  List<Map<String, dynamic>> searchCars(String query) {
    _ensureLoaded();

    if (query.trim().isEmpty) return [];

    final queryLower = query.toLowerCase().trim();
    final results = <Map<String, dynamic>>[];

    for (final car in _cars) {
      final brand = (car['brand'] as String?)?.toLowerCase() ?? '';
      final model = (car['model'] as String?)?.toLowerCase() ?? '';
      final chassisPrefix =
          (car['chassis_prefix'] as String?)?.toLowerCase() ?? '';

      if (brand.contains(queryLower) ||
          model.contains(queryLower) ||
          chassisPrefix.contains(queryLower) ||
          '$brand $model'.contains(queryLower)) {
        results.add(car);
      }
    }

    return results;
  }

  Map<String, dynamic>? getByChassisPrefix(String prefix) {
    _ensureLoaded();

    if (prefix.trim().isEmpty) return null;

    final prefixUpper = prefix.toUpperCase().trim();

    for (final car in _cars) {
      final chassisPrefix =
          (car['chassis_prefix'] as String?)?.toUpperCase() ?? '';

      if (chassisPrefix.isNotEmpty && prefixUpper.startsWith(chassisPrefix)) {
        return car;
      }
    }
    return null;
  }

  List<String> getAllBrands() {
    _ensureLoaded();

    final brands = <String>{};
    for (final car in _cars) {
      final brand = car['brand'] as String?;
      if (brand != null && brand.isNotEmpty) {
        brands.add(brand);
      }
    }

    final sorted = brands.toList()..sort();
    return sorted;
  }

  List<Map<String, dynamic>> getModelsByBrand(String brand) {
    _ensureLoaded();

    final brandLower = brand.toLowerCase().trim();
    final models = <Map<String, dynamic>>[];

    for (final car in _cars) {
      final carBrand = (car['brand'] as String?)?.toLowerCase() ?? '';
      if (carBrand == brandLower) {
        models.add(car);
      }
    }

    models.sort((a, b) {
      final modelA = (a['model'] as String?)?.toLowerCase() ?? '';
      final modelB = (b['model'] as String?)?.toLowerCase() ?? '';
      return modelA.compareTo(modelB);
    });

    return models;
  }
}
