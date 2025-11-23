class MealOption {
  final String name;
  final int calories;
  final MacroBreakdown macros;
  final int prepTime;
  final String recipe;
  final String type;

  MealOption({
    required this.name,
    required this.calories,
    required this.macros,
    required this.prepTime,
    required this.recipe,
    required this.type,
  });

  factory MealOption.fromJson(Map<String, dynamic> json) {
    return MealOption(
      name: json['name'] as String,
      calories: json['calories'] as int,
      macros: MacroBreakdown.fromJson(json['macros'] as Map<String, dynamic>),
      prepTime: json['prepTime'] as int,
      recipe: json['recipe'] as String,
      type: json['type'] as String,
    );
  }
}

class MacroBreakdown {
  final double protein;
  final double carbs;
  final double fat;

  MacroBreakdown({
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory MacroBreakdown.fromJson(Map<String, dynamic> json) {
    return MacroBreakdown(
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
    );
  }
}

class RecommendationModel {
  final MealOption optimizedMeal;
  final MealOption fastEasyMeal;
  final MealOption indulgentMeal;

  RecommendationModel({
    required this.optimizedMeal,
    required this.fastEasyMeal,
    required this.indulgentMeal,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      optimizedMeal: MealOption.fromJson(json['optimizedMeal'] as Map<String, dynamic>),
      fastEasyMeal: MealOption.fromJson(json['fastEasyMeal'] as Map<String, dynamic>),
      indulgentMeal: MealOption.fromJson(json['indulgentMeal'] as Map<String, dynamic>),
    );
  }
}