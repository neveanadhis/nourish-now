class MealModel {
  final String id;
  final String userId;
  final DateTime date;
  final String mealType;
  final String mealName;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final int? rating;
  final DateTime createdAt;

  MealModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.mealType,
    required this.mealName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.rating,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'date': date.toIso8601String(),
      'meal_type': mealType,
      'meal_name': mealName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory MealModel.fromMap(Map<String, dynamic> map) {
    return MealModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      date: DateTime.parse(map['date'] as String),
      mealType: map['meal_type'] as String,
      mealName: map['meal_name'] as String,
      calories: map['calories'] as int,
      protein: (map['protein'] as num).toDouble(),
      carbs: (map['carbs'] as num).toDouble(),
      fat: (map['fat'] as num).toDouble(),
      rating: map['rating'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  MealModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? mealType,
    String? mealName,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    int? rating,
    DateTime? createdAt,
  }) {
    return MealModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      mealName: mealName ?? this.mealName,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}