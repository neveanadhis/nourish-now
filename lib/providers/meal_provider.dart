import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Gemini SDK
import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/meal_model.dart';
import '../models/recommendation_model.dart';
import '../models/user_model.dart';

class MealProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  GenerativeModel? _geminiModel; // nullable until loaded properly

  List<MealModel> _mealHistory = [];
  RecommendationModel? _currentRecommendation;
  bool _isLoading = false;
  String? _error;

  List<MealModel> get mealHistory => _mealHistory;
  RecommendationModel? get currentRecommendation => _currentRecommendation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  MealProvider() {
    _initializeGemini();
  }

  // ---------------- GEMINI INITIALIZATION ----------------

  void _initializeGemini() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      debugPrint("FATAL: Gemini API key missing. AI recommendations disabled.");
      _geminiModel = null;
      return;
    }

    _geminiModel = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
  }

  bool get _geminiReady => _geminiModel != null;

  // ---------------- SUPABASE METHODS ----------------

  Future<void> fetchMealHistory(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await supabase
          .from('meal_history')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);

      _mealHistory = (response as List)
          .map((meal) => MealModel.fromMap(meal))
          .toList();
    } catch (e) {
      _error = 'Failed to fetch meal history';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> saveMeal(MealModel meal) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await supabase.from('meal_history').insert(meal.toMap());
      _mealHistory.insert(0, meal);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to save meal';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> rateMeal(String mealId, int rating) async {
    try {
      await supabase
          .from('meal_history')
          .update({'rating': rating})
          .eq('id', mealId);

      final index = _mealHistory.indexWhere((meal) => meal.id == mealId);
      if (index != -1) {
        _mealHistory[index] = _mealHistory[index].copyWith(rating: rating);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to rate meal';
      notifyListeners();
    }
  }

  // ---------------- GEMINI RECOMMENDATION METHOD ----------------

  Future<void> generateRecommendations(
    UserModel userData,
    String mealType,
    String budget,
    String mood,
    String timeOfDay,
  ) async {
    if (!_geminiReady) {
      _error = 'AI Service not configured.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final prompt = _buildRecommendationPrompt(
      userData, mealType, budget, mood, timeOfDay, _mealHistory,
    );

    try {
      final response = await _geminiModel!.generateContent([
        Content.text(prompt),
      ]);

      final rawText = response.text;

      if (rawText == null || rawText.isEmpty) {
        _error = 'AI returned an empty response.';
      } else {
        final jsonMap = jsonDecode(rawText);
        _currentRecommendation = RecommendationModel.fromJson(jsonMap);
      }
    } catch (e) {
      debugPrint('---------------------------------------------------');
      debugPrint('🚨 GEMINI API ERROR');
      debugPrint('Type: ${e.runtimeType}');
      debugPrint('Detail: $e');
      debugPrint('---------------------------------------------------');

      _error = 'Gemini API Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ---------------- PROMPT GENERATOR ----------------

  String _buildRecommendationPrompt(
    UserModel userData,
    String mealType,
    String budget,
    String mood,
    String timeOfDay,
    List<MealModel> history,
  ) {
    final historyString = history.take(5).map((meal) {
      return '• ${meal.mealName} (${meal.date.toIso8601String().substring(5, 10)})';
    }).join('\n');

    return """
    Act as a professional nutritionist for a meal recommendation app. 
    The user is looking for recommendations for the $timeOfDay.

    User Profile:
    - Age: ${userData.age}
    - Goal: ${userData.weightGoal}
    - Dietary Restrictions: ${userData.dietaryRestrictions.isEmpty ? 'None' : userData.dietaryRestrictions.join(', ')}

    Current Preferences:
    - Meal Type: $mealType
    - Budget: $budget
    - Mood: $mood

    Recent Meal History:
    $historyString

    You MUST return a valid JSON object with this structure:

    {
      "optimizedMeal": {
        "name": "Meal Name",
        "calories": 0,
        "macros": {"protein": 0.0, "carbs": 0.0, "fat": 0.0},
        "prepTime": 0,
        "recipe": "Step-by-step recipe.",
        "type": "Breakfast/Lunch/Dinner"
      },
      "fastEasyMeal": {...},
      "indulgentMeal": {...}
    }

    No explanations. No markdown. Only JSON.
    """;
  }
}
