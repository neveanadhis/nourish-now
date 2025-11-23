# NourishNow - Setup Guide

A personalized meal recommendation app powered by AI, built with Flutter and Supabase.

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Flutter SDK** (v3.0+)
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter doctor`

2. **Android Studio** or **Xcode** (depending on your target platform)
   - For Android: Android Studio with Android SDK
   - For iOS: Xcode on macOS

3. **Git** (for version control)

## Installation Steps

### 1. Clone or Download the Project

```bash
cd /path/to/nourish-now
```

### 2. Get Flutter Dependencies

```bash
flutter pub get
```

### 3. Configure Environment Variables

Create a `.env` file in the project root (if not already present):

```bash
cp .env.example .env
```

Edit `.env` and add your credentials:

```
SUPABASE_URL=https://tlmbjmreopjejkovsqbf.supabase.co
SUPABASE_ANON_KEY=<your-anon-key>
GOOGLE_API_KEY=<your-google-generative-ai-key>
```

### 4. Get Your Credentials

#### Supabase Credentials
- The Supabase project is already set up and available
- Your `SUPABASE_URL` and `SUPABASE_ANON_KEY` are already in your `.env` file

#### Google Generative AI API Key

1. Visit: https://console.cloud.google.com
2. Create a new project or select existing one
3. Enable "Generative Language API"
4. Create an API key (select "Restrict key to Android apps" for security)
5. Add the key to your `.env` file as `GOOGLE_API_KEY`

**Note**: For development testing, you can use an unrestricted API key temporarily. Remember to restrict it in production.

### 5. Run the App

#### Android
```bash
flutter run -d android
```

#### iOS
```bash
flutter run -d ios
```

#### Web (for testing in browser)
```bash
flutter run -d chrome
```

## Database Setup

The Supabase database is automatically configured with the following tables:

- **users**: User profiles with dietary preferences
- **meal_history**: Logs of all meals logged by users

No additional database setup is required.

## Features Overview

### 1. Authentication
- Email/Password sign-up and sign-in
- Secure session management with Supabase Auth

### 2. Profile Setup
- Multi-step onboarding form
- Configure weight goals, dietary restrictions, and budget
- Easy to update settings

### 3. Meal Recommendations
- Select meal type (Breakfast, Lunch, Dinner)
- Provide preferences (budget, mood, time of day)
- AI generates 3 personalized options:
  - **Optimized Meal**: Nutritionally perfect, fresh recipes
  - **Fast & Easy**: Quick prep time, convenient options
  - **Indulgent**: Treat meals, higher calorie but still healthy

### 4. Meal History
- Timeline view of all logged meals
- Rate meals after consuming
- Track nutrition over time

### 5. Profile Management
- View and update personal information
- Manage dietary preferences
- Sign out securely

## Troubleshooting

### "flutter: command not found"
- Ensure Flutter SDK is in your PATH
- Run: `export PATH="$PATH:/path/to/flutter/bin"`

### Build errors on iOS
```bash
cd ios
rm -rf Pods Podfile.lock .symlinks/
cd ..
flutter clean
flutter pub get
flutter run
```

### Build errors on Android
```bash
flutter clean
flutter pub get
flutter run
```

### API Key errors
- Verify your Google API key is valid and enabled
- Check that the API key is not restricted to specific domains
- Ensure `.env` file is in the project root

### Database connection issues
- Verify Supabase URL and anon key are correct
- Check internet connection
- Ensure RLS policies allow your user to access tables

## Project Structure

```
lib/
├── main.dart                 # Entry point
├── theme/
│   └── app_theme.dart       # App styling and colors
├── models/
│   ├── user_model.dart      # User data model
│   ├── meal_model.dart      # Meal data model
│   └── recommendation_model.dart  # AI recommendation model
├── providers/
│   ├── auth_provider.dart   # Authentication logic
│   ├── user_provider.dart   # User data management
│   └── meal_provider.dart   # Meal and recommendation logic
└── screens/
    ├── splash_screen.dart
    ├── auth/
    │   ├── login_screen.dart
    │   └── signup_screen.dart
    ├── profile/
    │   ├── profile_setup_screen.dart
    │   └── profile_screen.dart
    ├── home/
    │   └── home_screen.dart
    └── meal/
        ├── recommendation_screen.dart
        ├── meal_input_sheet.dart
        ├── meal_detail_screen.dart
        └── history_screen.dart
```

## API Endpoints

### Edge Function: meal-recommendations

**Endpoint**: `https://tlmbjmreopjejkovsqbf.supabase.co/functions/v1/meal-recommendations`

**Method**: POST

**Headers**:
```
Authorization: Bearer <SUPABASE_ANON_KEY>
Content-Type: application/json
```

**Request Body**:
```json
{
  "userData": {
    "firstName": "John",
    "age": 30,
    "weightGoal": "Weight Loss",
    "dietaryRestrictions": ["Vegan"],
    "defaultBudget": "$"
  },
  "mealType": "Dinner",
  "budget": "$",
  "mood": "Tired",
  "timeOfDay": "Evening"
}
```

**Response**:
```json
{
  "optimizedMeal": {
    "name": "Grilled Chicken with Quinoa",
    "calories": 550,
    "macros": {
      "protein": 35,
      "carbs": 60,
      "fat": 12
    },
    "prepTime": 25,
    "recipe": "...",
    "type": "homemade"
  },
  "fastEasyMeal": {...},
  "indulgentMeal": {...}
}
```

## Performance Tips

1. **Optimize Images**: Use compressed images for app icons
2. **Build Release App**: For production deployment, use `flutter build apk --release` or `flutter build ios --release`
3. **Monitor API Calls**: Limit API calls to Google Generative AI to avoid quota issues
4. **Cache Data**: Use `shared_preferences` for frequently accessed user data

## Security Notes

- Never commit `.env` file to version control
- Store API keys in environment variables, not hardcoded
- Use HTTPS for all API calls
- Enable Row Level Security (RLS) on Supabase tables (already configured)
- Validate user input on both client and server
- Keep dependencies updated: `flutter pub upgrade`

## Next Steps

1. Customize the "Modern Wellness" theme colors if desired
2. Add more meal types or dietary categories
3. Implement nutrition tracking features
4. Add user preferences for meal frequency
5. Create social sharing features
6. Build a web dashboard for meal analytics

## Support

For issues or questions:
- Check Flutter documentation: https://flutter.dev/docs
- Visit Supabase docs: https://supabase.com/docs
- Check Google AI API docs: https://ai.google.dev/docs

## License

This project is provided as-is for educational and commercial use.