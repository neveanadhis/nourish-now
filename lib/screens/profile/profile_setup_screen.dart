import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  late TextEditingController _firstNameController;
  late TextEditingController _ageController;

  String _selectedWeightGoal = 'Maintenance';
  String _selectedBudget = '\$';
  final List<String> _selectedRestrictions = [];

  final weightGoals = ['Weight Loss', 'Weight Gain', 'Maintenance'];
  final budgets = ['\$', '\$\$', '\$\$\$'];
  final restrictions = [
    'Vegan',
    'Vegetarian',
    'Gluten-Free',
    'Lactose Intolerant',
    'Peanut Allergy',
    'Shellfish Allergy',
    'Nut Allergy',
    'Keto',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _firstNameController = TextEditingController();
    _ageController = TextEditingController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeSetup() async {
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();

    if (authProvider.user == null) return;

    final user = UserModel(
      id: authProvider.user!.id,
      email: authProvider.user!.email ?? '',
      firstName: _firstNameController.text,
      age: int.parse(_ageController.text),
      weightGoal: _selectedWeightGoal,
      dietaryRestrictions: _selectedRestrictions,
      defaultBudget: _selectedBudget,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await userProvider.createUser(user);

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Step ${_currentPage + 1} of 4',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${((_currentPage + 1) / 4 * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                children: [
                  _buildNameAgeStep(),
                  _buildWeightGoalStep(),
                  _buildRestrictionsStep(),
                  _buildBudgetStep(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentPage < 3 ? _nextPage : _completeSetup,
                      child: Text(
                        _currentPage < 3 ? 'Next' : 'Complete Setup',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameAgeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Let\'s get to know you',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll use this information to personalize your recommendations',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'First Name',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              hintText: 'Enter your first name',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Age',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _ageController,
            decoration: const InputDecoration(
              hintText: 'Enter your age',
              prefixIcon: Icon(Icons.cake),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildWeightGoalStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s your weight goal?',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          ...weightGoals.map((goal) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => setState(() => _selectedWeightGoal = goal),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _selectedWeightGoal == goal
                        ? AppTheme.primaryColor
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedWeightGoal == goal
                          ? AppTheme.primaryColor
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedWeightGoal == goal
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: _selectedWeightGoal == goal
                            ? Colors.white
                            : AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        goal,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: _selectedWeightGoal == goal
                              ? Colors.white
                              : AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRestrictionsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dietary Restrictions',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select any that apply',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: restrictions.map((restriction) {
              final isSelected = _selectedRestrictions.contains(restriction);
              return FilterChip(
                label: Text(restriction),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedRestrictions.add(restriction);
                    } else {
                      _selectedRestrictions.remove(restriction);
                    }
                  });
                },
                backgroundColor: Colors.white,
                selectedColor: AppTheme.primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textDark,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s your budget level?',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us suggest meals in your price range',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 32),
          ...budgets.map((budget) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => setState(() => _selectedBudget = budget),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _selectedBudget == budget
                        ? AppTheme.primaryColor
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedBudget == budget
                          ? AppTheme.primaryColor
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedBudget == budget
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: _selectedBudget == budget
                            ? Colors.white
                            : AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        budget,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: _selectedBudget == budget
                              ? Colors.white
                              : AppTheme.textDark,
                          fontSize: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}