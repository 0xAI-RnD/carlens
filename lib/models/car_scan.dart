class CarScan {
  final int? id;
  final String brand;
  final String model;
  final String yearEstimate;
  final String bodyType;
  final String color;
  final double confidence;
  final String details;
  final String? vin;
  final double? originalityScore;
  final String? originalityReport;
  final String imagePath;
  final DateTime createdAt;
  final int level;
  final String? extraData; // JSON with specs, timeline, funFact, marketValue
  final String? sourceUrl; // marketplace listing URL (null for manual scans)
  final String? sourceName; // "Subito.it", "AutoScout24", etc.
  final String? askingPrice; // price from the listing
  final String? mileage; // km from the listing

  CarScan({
    this.id,
    required this.brand,
    required this.model,
    required this.yearEstimate,
    required this.bodyType,
    required this.color,
    required this.confidence,
    required this.details,
    this.vin,
    this.originalityScore,
    this.originalityReport,
    required this.imagePath,
    required this.createdAt,
    required this.level,
    this.extraData,
    this.sourceUrl,
    this.sourceName,
    this.askingPrice,
    this.mileage,
  });

  factory CarScan.fromMap(Map<String, dynamic> map) {
    return CarScan(
      id: map['id'] as int?,
      brand: map['brand'] as String,
      model: map['model'] as String,
      yearEstimate: map['year_estimate'] as String,
      bodyType: map['body_type'] as String,
      color: map['color'] as String,
      confidence: (map['confidence'] as num).toDouble(),
      details: map['details'] as String,
      vin: map['vin'] as String?,
      originalityScore: map['originality_score'] != null
          ? (map['originality_score'] as num).toDouble()
          : null,
      originalityReport: map['originality_report'] as String?,
      imagePath: map['image_path'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      level: map['level'] as int,
      extraData: map['extra_data'] as String?,
      sourceUrl: map['source_url'] as String?,
      sourceName: map['source_name'] as String?,
      askingPrice: map['asking_price'] as String?,
      mileage: map['mileage'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'brand': brand,
      'model': model,
      'year_estimate': yearEstimate,
      'body_type': bodyType,
      'color': color,
      'confidence': confidence,
      'details': details,
      'vin': vin,
      'originality_score': originalityScore,
      'originality_report': originalityReport,
      'image_path': imagePath,
      'created_at': createdAt.millisecondsSinceEpoch,
      'level': level,
      'extra_data': extraData,
      'source_url': sourceUrl,
      'source_name': sourceName,
      'asking_price': askingPrice,
      'mileage': mileage,
    };
  }

  CarScan copyWith({
    int? id,
    String? brand,
    String? model,
    String? yearEstimate,
    String? bodyType,
    String? color,
    double? confidence,
    String? details,
    String? vin,
    double? originalityScore,
    String? originalityReport,
    String? imagePath,
    DateTime? createdAt,
    int? level,
    String? extraData,
    String? sourceUrl,
    String? sourceName,
    String? askingPrice,
    String? mileage,
  }) {
    return CarScan(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      yearEstimate: yearEstimate ?? this.yearEstimate,
      bodyType: bodyType ?? this.bodyType,
      color: color ?? this.color,
      confidence: confidence ?? this.confidence,
      details: details ?? this.details,
      vin: vin ?? this.vin,
      originalityScore: originalityScore ?? this.originalityScore,
      originalityReport: originalityReport ?? this.originalityReport,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      level: level ?? this.level,
      extraData: extraData ?? this.extraData,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      sourceName: sourceName ?? this.sourceName,
      askingPrice: askingPrice ?? this.askingPrice,
      mileage: mileage ?? this.mileage,
    );
  }

  @override
  String toString() {
    return 'CarScan(id: $id, brand: $brand, model: $model, '
        'yearEstimate: $yearEstimate, level: $level, '
        'confidence: $confidence)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CarScan && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
