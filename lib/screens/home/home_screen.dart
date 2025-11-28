import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/meal_provider.dart';
import '../../theme/app_theme.dart';
import '../meal/recommendation_screen.dart';
import '../meal/history_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    final mealProvider = context.read<MealProvider>();

    if (authProvider.user != null) {
      userProvider.fetchUserProfile(authProvider.user!.id);
      mealProvider.fetchMealHistory(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    // NOTE: To remove the debug banner visible in the top right corner, 
    // you need to set debugShowCheckedModeBanner: false 
    // in the main MaterialApp widget (usually in main.dart).
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _DashboardTab(),
          HistoryScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: colorScheme.onPrimary,
        unselectedItemColor: colorScheme.onPrimary.withOpacity(0.7),
        backgroundColor: AppTheme.primaryColor,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// --- Dashboard Tab Implementation ---
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (userProvider.isLoading || userProvider.currentUser == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = userProvider.currentUser!;
        
        return CustomScrollView(
          slivers: [
            _buildCustomHeader(context, user.firstName),

            // Dashboard Content
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    const SizedBox(height: 16),
                    Text(
                      'Your Quick Stats',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    // Stats Cards Grid - REVERTED TO PLAIN WHITE
                    _buildStatsCards(context, user),

                    const SizedBox(height: 32),
                    
                    // Meal Type Selector Section
                    Text(
                      'What Meal Do You Need?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildMealTypeSelector(context),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomHeader(BuildContext context, String firstName) {
    final theme = Theme.of(context);
    return SliverAppBar(
      automaticallyImplyLeading: false,
      pinned: true,
      expandedHeight: 200.0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'NourishNow',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome, $firstName!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ready for your personalized meal recommendation?',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onPrimary.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, dynamic user) {
    // Note: backgroundColor is no longer needed since we are reverting to white.
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        // Weight Goal Card
        _StatCard(
          icon: Icons.monitor_weight_outlined,
          title: 'Weight Goal',
          value: user.weightGoal,
          color: AppTheme.successColor,
        ),
        // Budget Card
        _StatCard(
          icon: Icons.attach_money_outlined,
          title: 'Budget',
          value: '\$${user.defaultBudget}',
          color: AppTheme.accentColor,
        ),
      ],
    );
  }

  Widget _buildMealTypeSelector(BuildContext context) {
    final mealTypes = [
      {'name': 'Breakfast', 'icon': Icons.free_breakfast_outlined},
      {'name': 'Lunch', 'icon': Icons.local_dining_outlined},
      {'name': 'Dinner', 'icon': Icons.dinner_dining_outlined},
    ];

    return Column(
      children: mealTypes.map((meal) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _MealTypeButton(
            mealType: meal['name'] as String,
            icon: meal['icon'] as IconData,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RecommendationScreen(
                    mealType: meal['name'] as String,
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}

// --- Reusable Button Component for Meal Types (Unchanged) ---
class _MealTypeButton extends StatelessWidget {
  final String mealType;
  final IconData icon;
  final VoidCallback onPressed;

  const _MealTypeButton({
    required this.mealType,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get $mealType Recommendation',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to find meal ideas for $mealType.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: AppTheme.primaryColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Stat Card Implementation (Reverted) ---
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  // Removed final Color backgroundColor;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    // Removed required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      // Removed color: backgroundColor, reverts to default white theme color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        // Removed side: BorderSide(...)
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
            
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.titleText,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}