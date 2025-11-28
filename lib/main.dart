
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'screens/home/home_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/meal_provider.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- DOTENV LOADING AND VERIFICATION ---
  try {
    await dotenv.load(fileName: ".env");

    // Retrieve the Gemini API key and check if it's available
    final geminiApiKey = dotenv.env['GEMINI_API_KEY'];
    
    if (geminiApiKey == null || geminiApiKey.isEmpty) {
      // Print a warning if the key is missing or empty
      debugPrint("🚨 WARNING: GEMINI_API_KEY not found in .env file or is empty. AI features may fail.");
    } else {
      // Confirmation that the key was loaded
      debugPrint("✅ Gemini API Key loaded successfully for use.");
    }
  } catch (e) {
    debugPrint("❌ CRITICAL ERROR: Failed to load .env file. $e");
    // Continue running the app, but note the API failure.
  }
  // --- END DOTENV LOADING AND VERIFICATION ---

  // --- SUPABASE INITIALIZATION ---
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => MealProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NourishNow',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const SplashScreen(),
        routes: {
          '/home': (_) => const HomeScreen(),
        },
      ),
    );
  }
}