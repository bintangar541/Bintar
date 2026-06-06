class Goal {
  final int id;
  final int userId;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String category;
  final String icon;
  final DateTime? targetDate;
  final DateTime createdAt;

  const Goal({
    required this.id,
    required this.userId,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.category,
    required this.icon,
    this.targetDate,
    required this.createdAt,
  });

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0;
  bool get isCompleted => currentAmount >= targetAmount;
  double get remaining => (targetAmount - currentAmount).clamp(0, double.infinity);

  int calculateMonthsRemaining(double avgMonthlySavings) {
    if (isCompleted) return 0;
    if (avgMonthlySavings <= 0) return 99; // Very long
    return (remaining / avgMonthlySavings).ceil();
  }

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
    id: json['id'],
    userId: json['user_id'],
    title: json['title'],
    targetAmount: (json['target_amount'] as num).toDouble(),
    currentAmount: (json['current_amount'] as num).toDouble(),
    category: json['category'],
    icon: json['icon'],
    targetDate: json['target_date'] != null ? DateTime.parse(json['target_date']) : null,
    createdAt: DateTime.parse(json['created_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'target_amount': targetAmount,
    'current_amount': currentAmount,
    'category': category,
    'icon': icon,
    'target_date': targetDate?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
  };

  Goal copyWith({
    int? id,
    int? userId,
    String? title,
    double? targetAmount,
    double? currentAmount,
    String? category,
    String? icon,
    DateTime? targetDate,
    DateTime? createdAt,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
