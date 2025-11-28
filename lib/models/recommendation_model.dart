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
      name: json['name']?.toString() ?? "Unknown Meal",
      
      calories: _parseInt(json['calories']),
      prepTime: _parseInt(json['prepTime']),
      
      macros: MacroBreakdown.fromJson(
        json['macros'] as Map<String, dynamic>? ?? {},
      ),
      
      recipe: _parseRecipe(json['recipe']),
      type: json['type']?.toString() ?? "Unknown",
    );
  }

  // ---------------- SAFE PARSERS ----------------

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;

    if (value is String) {
      return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }

    return 0;
  }

  static String _parseRecipe(dynamic value) {
    if (value == null) return "No recipe available.";

    // Handle recipe as list of steps
    if (value is List) {
      return value.map((e) => e.toString()).join("\n");
    }

    return value.toString();
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
      protein: _parseDouble(json['protein']),
      carbs: _parseDouble(json['carbs']),
      fat: _parseDouble(json['fat']),
    );
  }

  // Safe number parser
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();

    if (value is String) {
      return double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    }

    return 0.0;
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
      optimizedMeal: MealOption.fromJson(
        json['optimizedMeal'] as Map<String, dynamic>? ?? {},
      ),
      fastEasyMeal: MealOption.fromJson(
        json['fastEasyMeal'] as Map<String, dynamic>? ?? {},
      ),
      indulgentMeal: MealOption.fromJson(
        json['indulgentMeal'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
