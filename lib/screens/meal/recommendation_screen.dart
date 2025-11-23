import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/meal_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/meal_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import 'meal_input_sheet.dart';
import 'meal_detail_screen.dart';

class RecommendationScreen extends StatefulWidget {
  final String mealType;

  const RecommendationScreen({
    Key? key,
    required this.mealType,
  }) : super(key: key);

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showMealInputSheet();
    });
  }

  void _showMealInputSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => MealInputSheet(
        mealType: widget.mealType,
        onSubmit: _generateRecommendations,
      ),
    );
  }

  Future<void> _generateRecommendations(
    String budget,
    String mood,
    String timeOfDay,
  ) async {
    final userProvider = context.read<UserProvider>();
    final mealProvider = context.read<MealProvider>();

    if (userProvider.currentUser == null) return;

    await mealProvider.generateRecommendations(
      userProvider.currentUser!,
      widget.mealType,
      budget,
      mood,
      timeOfDay,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.mealType} Recommendations'),
        elevation: 0,
      ),
      body: Consumer<MealProvider>(
        builder: (context, mealProvider, _) {
          if (mealProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Finding the perfect meals for you...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          if (mealProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${mealProvider.error}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _showMealInputSheet,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (mealProvider.currentRecommendation == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 64,
                    color: AppTheme.primaryColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recommendations yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _showMealInputSheet,
                    child: const Text('Get Recommendations'),
                  ),
                ],
              ),
            );
          }

          final recommendation = mealProvider.currentRecommendation!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MealCard(
                  title: 'The Optimized Meal',
                  subtitle: 'Nutritionally perfect',
                  meal: recommendation.optimizedMeal,
                  color: AppTheme.successColor,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MealDetailScreen(
                          meal: recommendation.optimizedMeal,
                          mealType: widget.mealType,
                        ),
                      ),
                    );
                  },
                  onSelect: () {
                    _selectMeal(recommendation.optimizedMeal, widget.mealType);
                  },
                ),
                const SizedBox(height: 16),
                _MealCard(
                  title: 'The Fast & Easy Meal',
                  subtitle: 'Quick & convenient',
                  meal: recommendation.fastEasyMeal,
                  color: AppTheme.accentColor,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MealDetailScreen(
                          meal: recommendation.fastEasyMeal,
                          mealType: widget.mealType,
                        ),
                      ),
                    );
                  },
                  onSelect: () {
                    _selectMeal(recommendation.fastEasyMeal, widget.mealType);
                  },
                ),
                const SizedBox(height: 16),
                _MealCard(
                  title: 'The Indulgent Meal',
                  subtitle: 'A tasty treat',
                  meal: recommendation.indulgentMeal,
                  color: Color(0xFFFFA726),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MealDetailScreen(
                          meal: recommendation.indulgentMeal,
                          mealType: widget.mealType,
                        ),
                      ),
                    );
                  },
                  onSelect: () {
                    _selectMeal(recommendation.indulgentMeal, widget.mealType);
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _selectMeal(dynamic mealOption, String mealType) async {
    final mealProvider = context.read<MealProvider>();
    final authProvider = context.read<AuthProvider>();

    final meal = MealModel(
      id: '',
      userId: authProvider.user!.id,
      date: DateTime.now(),
      mealType: mealType,
      mealName: mealOption.name,
      calories: mealOption.calories,
      protein: mealOption.macros.protein,
      carbs: mealOption.macros.carbs,
      fat: mealOption.macros.fat,
      createdAt: DateTime.now(),
    );

    final success = await mealProvider.saveMeal(meal);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Meal logged successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );

      Navigator.of(context).pop();
    }
  }
}

class _MealCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final dynamic meal;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onSelect;

  const _MealCard({
    required this.title,
    required this.subtitle,
    required this.meal,
    required this.color,
    required this.onTap,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.restaurant,
                        color: color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style:
                                Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: color,
                                    ),
                          ),
                          Text(
                            subtitle,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textLight,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  meal.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MealInfo(
                      label: 'Calories',
                      value: '${meal.calories}',
                      color: color,
                    ),
                    _MealInfo(
                      label: 'Prep',
                      value: '${meal.prepTime}m',
                      color: color,
                    ),
                    _MealInfo(
                      label: 'Protein',
                      value: '${meal.macros.protein.toStringAsFixed(1)}g',
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onSelect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                    ),
                    child: const Text('Log This Meal'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MealInfo extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MealInfo({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}