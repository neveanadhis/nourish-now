import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class MealInputSheet extends StatefulWidget {
  final String mealType;
  final Function(String budget, String mood, String timeOfDay) onSubmit;

  const MealInputSheet({
    Key? key,
    required this.mealType,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<MealInputSheet> createState() => _MealInputSheetState();
}

class _MealInputSheetState extends State<MealInputSheet> {
  String _selectedBudget = '\$';
  String _selectedMood = 'Normal';
  String _selectedTime = 'Anytime';

  final budgets = ['\$', '\$\$', '\$\$\$'];
  final moods = ['Normal', 'Tired', 'Busy', 'Treat'];
  final moodEmojis = {
    'Normal': '😊',
    'Tired': '😴',
    'Busy': '⚡',
    'Treat': '🎉',
  };
  final times = ['Anytime', 'Morning', 'Afternoon', 'Evening'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'What are your preferences?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Budget Level',
              budgets.map((budget) {
                return _buildOption(
                  context,
                  budget,
                  _selectedBudget == budget,
                  () => setState(() => _selectedBudget = budget),
                  AppTheme.primaryColor,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'How are you feeling?',
              moods.map((mood) {
                final emoji = moodEmojis[mood] ?? '';
                return _buildOption(
                  context,
                  '$emoji $mood',
                  _selectedMood == mood,
                  () => setState(() => _selectedMood = mood),
                  AppTheme.accentColor,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Time of Day',
              times.map((time) {
                return _buildOption(
                  context,
                  time,
                  _selectedTime == time,
                  () => setState(() => _selectedTime = time),
                  AppTheme.successColor,
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSubmit(_selectedBudget, _selectedMood, _selectedTime);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: const Text(
                  'Get Recommendations',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> options,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options,
        ),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
    Color color,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Color(0xFFE0E0E0),
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}