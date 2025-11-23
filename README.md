# NourishNow - AI-Powered Meal Recommendation App

A personalized meal recommendation application built with Flutter and powered by Google Generative AI. Get customized meal suggestions based on your dietary preferences, budget, mood, and weight goals.

## Overview

NourishNow delivers three personalized meal options for each request:

1. **The Optimized Meal** - Nutritionally perfect, home-cooked recipes within your calorie target
2. **The Fast & Easy Meal** - Quick preparation (max 15 minutes), convenient options
3. **The Indulgent Meal** - Healthy treat options slightly above calorie target

All recommendations respect your dietary restrictions and budget preferences.

## Features

- **AI-Powered Recommendations**: Google Generative AI provides personalized meal suggestions
- **User Authentication**: Secure email/password authentication with Supabase
- **Profile Management**: Customize weight goals, dietary restrictions, and budget preferences
- **Meal History**: Track all logged meals with nutritional breakdown
- **Meal Ratings**: Rate meals and track your preferences over time
- **Modern UI**: Clean, intuitive design with smooth animations
- **Real-time Data**: Synchronized across devices with Supabase

## Getting Started

### Prerequisites

- Flutter 3.0 or higher
- Android Studio or Xcode
- Google API Key (for Generative AI)
- Supabase credentials (provided in `.env`)

### Quick Start (5 minutes)

1. **Install Flutter** (if not already installed)
   ```bash
   https://flutter.dev/docs/get-started/install
   ```

2. **Get Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Key**
   - Create `.env` file from `.env.example`
   - Get Google API key from Google Cloud Console
   - Add credentials to `.env`

4. **Run the App**
   ```bash
   flutter run
   ```

See **QUICK_START.md** for detailed setup steps.

## Documentation

- **QUICK_START.md** - 5-minute setup guide
- **SETUP.md** - Complete installation and configuration guide
- **API_SETUP.md** - Google API and Supabase configuration
- **IMPLEMENTATION.md** - Technical architecture and design details

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── theme/app_theme.dart              # "Modern Wellness" theme
├── models/                           # Data models
│   ├── user_model.dart
│   ├── meal_model.dart
│   └── recommendation_model.dart
├── providers/                        # State management
│   ├── auth_provider.dart
│   ├── user_provider.dart
│   └── meal_provider.dart
└── screens/                          # UI Screens
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

## Technology Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter 3.0+ |
| State Management | Provider pattern |
| Backend Database | Supabase (PostgreSQL) |
| Authentication | Supabase Auth |
| AI Engine | Google Generative AI (Gemini 1.5 Flash) |
| Serverless | Supabase Edge Functions (Deno) |

## Key Features Explained

### AI Recommendation Logic

**Calorie Targets**:
- Breakfast: 400 calories (±10%)
- Lunch: 600 calories (±10%)
- Dinner: 700 calories (±10%)

**Customization Factors**:
- Weight Goal (Weight Loss / Maintenance / Weight Gain)
- Dietary Restrictions (Vegan, Vegetarian, Gluten-Free, etc.)
- Budget Level ($ / $$ / $$$)
- Current Mood (Normal / Tired / Busy / Treat)
- Time of Day (Morning / Afternoon / Evening)

### Database Schema

**Users Table**
- Profile information and preferences
- Dietary restrictions array
- Weight goal and budget
- RLS-secured (users can only access own data)

**Meal History Table**
- Logged meals with timestamp
- Nutritional breakdown (protein, carbs, fat)
- Calorie count
- Optional 1-5 star rating
- RLS-secured (users can only access own meals)

### Security

- **Row Level Security (RLS)**: Enforced at database level
- **Secure Authentication**: JWT tokens, automatic refresh
- **API Key Restrictions**: Google API keys restricted to app
- **Environment Variables**: Secrets never committed to code

## Theme: Modern Wellness

**Color Palette**:
- Primary Teal: `#4ECDC4` - Freshness & clarity
- Secondary Coral: `#FF6B6B` - Energy & action
- Success Green: `#27AE60` - Positive feedback
- Background White: `#F7F7F7` - Clean space

**Design Philosophy**:
- Soft corners (12-16px radius)
- Elevated cards for visual hierarchy
- Consistent 8px spacing system
- Clear, readable typography
- Smooth transitions and animations

## Building for Production

### Android Release Build
```bash
flutter build apk --release
```

### iOS Release Build
```bash
flutter build ios --release
```

### Web Build
```bash
flutter build web
```

### Considerations
- API keys must be restricted to your app domain/SHA
- Update privacy policy and terms of service
- Set up error tracking (e.g., Sentry)
- Configure analytics (e.g., Firebase Analytics)
- Test thoroughly on multiple devices

## API Integration

### Meal Recommendations Edge Function
- **Endpoint**: `{SUPABASE_URL}/functions/v1/meal-recommendations`
- **Authentication**: Requires valid Supabase JWT token
- **Input**: User data, meal type, preferences
- **Output**: 3 meal recommendations with nutritional info

### Google Generative AI
- **Model**: Gemini 1.5 Flash
- **Rate Limit**: 60 requests/minute (free tier)
- **Cost**: Check Google's pricing for production use

## Performance Optimization

- Lazy loading of meal history
- Efficient database queries with indexes
- Cached user preferences
- Optimized UI rebuilds with Provider
- Minimal dependencies for fast builds

## Testing

```bash
# Run tests
flutter test

# Generate coverage
flutter test --coverage
```

## Troubleshooting

### App won't start
```bash
flutter clean
flutter pub get
flutter run
```

### API Key errors
- Verify API key in `.env` file
- Check Google API is enabled
- Ensure no typos or extra spaces

### Database connection issues
- Check internet connection
- Verify Supabase credentials
- Check RLS policies in dashboard

### Meal recommendations not loading
- Check Google API key validity
- Verify internet connection
- Check app logs for errors
- Ensure profile is complete

See **SETUP.md** for more troubleshooting tips.

## Future Enhancements

- Nutrition tracking dashboard
- Weekly meal planning
- Social sharing features
- Restaurant/delivery integration
- Seasonal meal adjustments
- Advanced allergy management
- Meal plan customization

## Contributing

This is a production-ready template. Feel free to:
- Add more dietary restriction options
- Customize the AI prompt for your region
- Add additional meal types
- Implement new features

## License

This project is provided as-is for educational and commercial use.

## Support

- **Flutter Documentation**: https://flutter.dev/docs
- **Supabase Documentation**: https://supabase.com/docs
- **Google AI Documentation**: https://ai.google.dev/docs

## Credits

Built with Flutter, Supabase, and Google Generative AI.

---

**Ready to Get Started?** See **QUICK_START.md** for a 5-minute setup guide!