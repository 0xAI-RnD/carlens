class Achievement {
  final int? id;
  final String achievementId; // e.g. "scans_base", "brands_bronze", "eras_gold"
  final String category; // "scans", "brands", "eras"
  final String tier; // "base", "bronze", "silver", "gold"
  final int threshold; // target value for this tier
  final DateTime? unlockedAt; // null = locked

  Achievement({
    this.id,
    required this.achievementId,
    required this.category,
    required this.tier,
    required this.threshold,
    this.unlockedAt,
  });

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as int?,
      achievementId: map['achievement_id'] as String,
      category: map['category'] as String,
      tier: map['tier'] as String,
      threshold: map['threshold'] as int,
      unlockedAt: map['unlocked_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['unlocked_at'] as int)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'achievement_id': achievementId,
      'category': category,
      'tier': tier,
      'threshold': threshold,
      'unlocked_at': unlockedAt?.millisecondsSinceEpoch,
    };
  }

  Achievement copyWith({
    int? id,
    String? achievementId,
    String? category,
    String? tier,
    int? threshold,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      achievementId: achievementId ?? this.achievementId,
      category: category ?? this.category,
      tier: tier ?? this.tier,
      threshold: threshold ?? this.threshold,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  bool get isUnlocked => unlockedAt != null;

  @override
  String toString() {
    return 'Achievement(id: $id, achievementId: $achievementId, '
        'category: $category, tier: $tier, threshold: $threshold, '
        'unlockedAt: $unlockedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Achievement && other.achievementId == achievementId;
  }

  @override
  int get hashCode => achievementId.hashCode;
}
