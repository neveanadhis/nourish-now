import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/meal_model.dart';
import '../models/recommendation_model.dart';
import '../models/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MealProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<MealModel> _mealHistory = [];
  RecommendationModel? _currentRecommendation;
  bool _isLoading = false;
  String? _error;

  List<MealModel> get mealHistory => _mealHistory;
  RecommendationModel? get currentRecommendation => _currentRecommendation;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

      final index =
          _mealHistory.indexWhere((meal) => meal.id == mealId);
      if (index != -1) {
        _mealHistory[index] = _mealHistory[index].copyWith(rating: rating);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to rate meal';
      notifyListeners();
    }
  }

  Future<void> generateRecommendations(
    UserModel userData,
    String mealType,
    String budget,
    String mood,
    String timeOfDay,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

      final response = await http.post(
        Uri.parse('$supabaseUrl/functions/v1/meal-recommendations'),
        headers: {
          'Authorization': 'Bearer $anonKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userData': {
            'firstName': userData.firstName,
            'age': userData.age,
            'weightGoal': userData.weightGoal,
            'dietaryRestrictions': userData.dietaryRestrictions,
            'defaultBudget': userData.defaultBudget,
          },
          'mealType': mealType,
          'budget': budget,
          'mood': mood,
          'timeOfDay': timeOfDay,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentRecommendation = RecommendationModel.fromJson(data);
      } else {
        _error = 'Failed to generate recommendations';
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }
}