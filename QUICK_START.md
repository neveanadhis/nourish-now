# NourishNow - Quick Start Guide

Get NourishNow running in 5 minutes.

## 1. Install Flutter (First Time Only)

Download and install Flutter from: https://flutter.dev/docs/get-started/install

Verify installation:
```bash
flutter doctor
```

## 2. Clone/Download the Project

```bash
cd nourish-now
```

## 3. Install Dependencies

```bash
flutter pub get
```

## 4. Set Up Credentials

Create a `.env` file with these values:

```
SUPABASE_URL=https://tlmbjmreopjejkovsqbf.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRsbWJqbXJlb3BqZWprb3ZzcWJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM5MDY2NDgsImV4cCI6MjA3OTQ4MjY0OH0.3gfoIzbcQ_7Jh24HyiV1hgZoLLl-2QDqeXFb7ByihF8
GOOGLE_API_KEY=your-api-key-here
```

### Get Your Google API Key

1. Go to: https://console.cloud.google.com
2. Create a new project
3. Enable "Generative Language API"
4. Go to Credentials → Create API Key
5. Copy and paste into `.env` file

## 5. Run the App

### Android
```bash
flutter run
```

### iOS (macOS only)
```bash
flutter run -d ios
```

### Web (for testing)
```bash
flutter run -d chrome
```

## 6. First Login

Create an account with:
- Email: your-email@example.com
- Password: secure-password

Complete the profile setup and start getting meal recommendations!

## Common Issues

**"Doctor summary says there are 2 warnings"**
- This is normal. As long as Flutter is installed, you're good to go.

**"Gradle build failed"**
```bash
flutter clean
flutter pub get
flutter run
```

**"API Key invalid"**
- Check your Google API key is correct
- Make sure it's enabled in Google Cloud Console

## Next Steps

- Explore the app and get meal recommendations
- Check your meal history
- Update your profile preferences
- Rate your meals to improve recommendations

Enjoy NourishNow!