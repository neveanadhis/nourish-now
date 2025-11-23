import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/meal_provider.dart';
import '../../theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MealProvider>(
      builder: (context, mealProvider, _) {
        if (mealProvider.mealHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: AppTheme.primaryColor.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No meals logged yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Start logging meals to see your history',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          );
        }

        final groupedMeals = _groupMealsByDate(mealProvider.mealHistory);

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groupedMeals.length,
          itemBuilder: (context, index) {
            final entry = groupedMeals.entries.toList()[index];
            final date = entry.key;
            final meals = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    DateFormat('MMMM d, yyyy').format(date),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                ...meals.map((meal) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      meal.mealName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor
                                            .withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        meal.mealType,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppTheme.primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (meal.rating != null)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Color(0xFFFFA726),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${meal.rating}/5',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _HistoryMealInfo(
                                label: 'Calories',
                                value: '${meal.calories}',
                              ),
                              _HistoryMealInfo(
                                label: 'Protein',
                                value: '${meal.protein.toStringAsFixed(1)}g',
                              ),
                              _HistoryMealInfo(
                                label: 'Carbs',
                                value: '${meal.carbs.toStringAsFixed(1)}g',
                              ),
                              _HistoryMealInfo(
                                label: 'Fat',
                                value: '${meal.fat.toStringAsFixed(1)}g',
                              ),
                            ],
                          ),
                          if (meal.rating == null)
                            Column(
                              children: [
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _showRatingDialog(context, meal.id,
                                          mealProvider);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                    ),
                                    child: const Text('Rate Meal'),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          },
        );
      },
    );
  }

  Map<DateTime, dynamic> _groupMealsByDate(dynamic meals) {
    final grouped = <DateTime, List<dynamic>>{};

    for (final meal in meals) {
      final date = DateTime(
        meal.date.year,
        meal.date.month,
        meal.date.day,
      );

      if (grouped[date] == null) {
        grouped[date] = [];
      }
      grouped[date]!.add(meal);
    }

    return grouped;
  }

  void _showRatingDialog(
    BuildContext context,
    String mealId,
    dynamic mealProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => _RatingDialog(
        mealId: mealId,
        mealProvider: mealProvider,
      ),
    );
  }
}

class _HistoryMealInfo extends StatelessWidget {
  final String label;
  final String value;

  const _HistoryMealInfo({
    required this.label,
    required this.value,
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
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _RatingDialog extends StatefulWidget {
  final String mealId;
  final dynamic mealProvider;

  const _RatingDialog({
    required this.mealId,
    required this.mealProvider,
  });

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate This Meal'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          5,
          (index) => GestureDetector(
            onTap: () => setState(() => _rating = index + 1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.star,
                size: 40,
                color: index < _rating
                    ? const Color(0xFFFFA726)
                    : const Color(0xFFE0E0E0),
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _rating > 0
              ? () {
                  widget.mealProvider.rateMeal(widget.mealId, _rating);
                  Navigator.pop(context);
                }
              : null,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}