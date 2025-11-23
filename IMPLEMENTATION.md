# NourishNow - Implementation Details

## Architecture Overview

NourishNow follows a clean architecture pattern with clear separation of concerns:

```
Presentation Layer (Screens)
        ↓
State Management Layer (Providers)
        ↓
Data Layer (Models & Supabase)
        ↓
Backend (Firebase-compatible Supabase + AI Edge Functions)
```

## Technology Stack

- **Frontend**: Flutter 3.0+
- **State Management**: Provider pattern
- **Backend**: Supabase (PostgreSQL + Authentication)
- **AI Engine**: Google Generative AI (Gemini 1.5 Flash)
- **Real-time Updates**: Supabase Subscriptions (future enhancement)

## Core Components

### 1. Authentication System (`lib/providers/auth_provider.dart`)

**Functionality**:
- Email/Password registration and login
- Session management
- Automatic token refresh
- Sign-out with cleanup

**Key Methods**:
- `signUp()`: Creates new user account
- `signIn()`: Authenticates existing user
- `signOut()`: Clears session
- `resetPassword()`: Password recovery

**Integration**:
- Supabase Auth handles all cryptographic operations
- JWT tokens are automatically managed
- RLS (Row Level Security) enforces data privacy

### 2. User Management (`lib/providers/user_provider.dart`)

**Functionality**:
- Profile creation after signup
- Fetch user preferences
- Update dietary restrictions and goals

**Data Structure**:
```
users {
  id: UUID (matches auth.uid)
  email: String
  firstName: String
  age: Integer
  weightGoal: 'Weight Loss' | 'Weight Gain' | 'Maintenance'
  dietaryRestrictions: String[]
  defaultBudget: '$' | '$$' | '$$$'
  createdAt: Timestamp
  updatedAt: Timestamp
}
```

### 3. Meal Recommendation Engine (`lib/providers/meal_provider.dart`)

**AI Logic Flow**:

1. **User Input Collection**:
   - Meal type (Breakfast/Lunch/Dinner)
   - Budget preference
   - Current mood
   - Time of day

2. **Context Building**:
   - Calorie targets (400 cal for Breakfast, 600 for Lunch, 700 for Dinner)
   - ±10% calorie tolerance
   - Dietary restriction compliance
   - Budget constraints

3. **AI Prompt Generation**:
   - Concatenates all user data and preferences
   - Specifies exact JSON output format
   - Defines three distinct meal options

4. **Response Processing**:
   - Parses JSON from Gemini API
   - Validates macro breakdowns
   - Returns structured recommendations

**Meal Options Logic**:

- **Optimized Meal**:
  - Within calorie target (±10%)
  - Prioritizes home-cooked recipes
  - Respects all dietary restrictions
  - Balanced macronutrients

- **Fast & Easy Meal**:
  - Max 15 minutes prep time
  - Considers mood ('Tired' → minimal ingredients, 'Busy' → pre-packaged)
  - Budget-conscious
  - Simplified recipes

- **Indulgent Meal**:
  - Up to 20% above calorie target
  - Takeout/delivery options
  - Aligned with 'Treat' mood
  - Still nutritionally sound

### 4. Meal History (`lib/providers/meal_provider.dart` + history_screen.dart)

**Data Structure**:
```
meal_history {
  id: UUID
  user_id: UUID (foreign key)
  date: Timestamp
  mealType: 'Breakfast' | 'Lunch' | 'Dinner'
  mealName: String
  calories: Integer
  protein: Numeric (grams)
  carbs: Numeric (grams)
  fat: Numeric (grams)
  rating: Integer (1-5, optional)
  createdAt: Timestamp
}
```

**Functionality**:
- Chronological display grouped by date
- Optional meal ratings (1-5 stars)
- Quick stats (calories, macros)
- Future analytics potential

## UI/UX Implementation

### Theme: "Modern Wellness"

**Color System**:
- Primary: `#4ECDC4` (Teal - freshness & clarity)
- Secondary: `#FF6B6B` (Coral - energy & action)
- Success: `#27AE60` (Green - positive action)
- Warning: `#F39C12` (Orange - caution)
- Error: `#E74C3C` (Red - negative action)
- Background: `#F7F7F7` (Off-white - clean)
- Text: `#2C3E50` (Dark grey - high contrast)

**Design Features**:
- Soft corners (12-16px border radius)
- Card elevation (2-4px shadow)
- Consistent 8px spacing system
- 3-font weight system (Regular, Medium, Bold)
- 150% line height for body text
- Responsive layouts with safe areas

### Screen Architecture

**1. Splash Screen** (`splash_screen.dart`)
- 2-second splash delay
- Checks authentication status
- Routes to Login or Home accordingly

**2. Authentication Screens**
- Login (`login_screen.dart`): Email + Password input
- Signup (`signup_screen.dart`): Registration flow
- Validation and error handling

**3. Profile Setup** (`profile_setup_screen.dart`)
- 4-step PageView stepper:
  - Step 1: Name & Age
  - Step 2: Weight Goal selection
  - Step 3: Dietary Restrictions (multi-select)
  - Step 4: Budget level
- Progress indicator
- Back/Next navigation

**4. Home Dashboard** (`home_screen.dart`)
- Bottom nav (Home, History, Profile)
- Welcome message with user first name
- Weight goal and budget stat cards
- Meal type selector (3 buttons for Breakfast/Lunch/Dinner)

**5. Recommendation Flow**
- `recommendation_screen.dart`: Displays 3 meal cards
- `meal_input_sheet.dart`: Bottom sheet for preferences
- `meal_detail_screen.dart`: Full meal breakdown
- Color-coded cards (Teal, Coral, Orange)

**6. Meal History** (`history_screen.dart`)
- Timeline grouped by date
- Meal cards with quick stats
- Rating dialog for unrated meals
- Empty state design

**7. Profile Screen** (`profile_screen.dart`)
- User avatar and name
- Editable profile sections
- Dietary preferences display
- Sign out button with confirmation

## Database Security (RLS Policies)

### Users Table
```sql
-- SELECT: Users can only view their own profile
-- UPDATE: Users can only update their own profile
-- INSERT: New users can create their own profile
-- DELETE: Not allowed (data retention)
```

### Meal History Table
```sql
-- SELECT: Users can only view their own meal records
-- INSERT: Users can log their own meals
-- UPDATE: Users can update their own records (rating)
-- DELETE: Users can delete their own records
```

## Edge Function: meal-recommendations

**Deployment Location**: Supabase Edge Functions (Deno runtime)

**Processing Flow**:
1. Receives POST request with user data and preferences
2. Constructs detailed prompt for Gemini API
3. Calls Google Generative AI API
4. Parses JSON response
5. Returns structured recommendation object

**Error Handling**:
- API key validation
- Network error recovery
- Response format validation
- Detailed error messages

## State Management Flow

```
User Action (e.g., click "Get Recommendation")
        ↓
Screen calls Provider method
        ↓
Provider sends API request / Supabase query
        ↓
Provider updates internal state
        ↓
Provider calls notifyListeners()
        ↓
Consumer widgets rebuild with new data
        ↓
UI reflects changes
```

## Performance Optimizations

1. **Lazy Loading**:
   - Meal history loaded on-demand
   - User profile cached in memory

2. **Single Responsibility**:
   - Each provider handles one domain
   - Screens use only needed providers

3. **Efficient Queries**:
   - Use `.maybeSingle()` for single-row results
   - Index on user_id and date
   - Limit query results

4. **UI Optimization**:
   - IndexedStack in home screen (no rebuild on tab change)
   - Card elevation for visual hierarchy
   - Smooth transitions with Curves

## Future Enhancements

1. **Real-time Sync**: Supabase subscriptions for multi-device sync
2. **Nutrition Tracking**: Daily macro breakdown and goals
3. **Social Features**: Share meals with friends
4. **Advanced Analytics**: Meal trends and insights
5. **Seasonal Preferences**: Adjust recommendations by season
6. **Local Restaurants**: Integration with food delivery APIs
7. **Allergen Tracking**: Enhanced allergy management
8. **Meal Plans**: Weekly meal planning with AI

## Testing Considerations

1. **Unit Tests**: Provider logic and models
2. **Widget Tests**: Individual screen components
3. **Integration Tests**: Full user flows (auth → recommendation → history)
4. **API Testing**: Mock Supabase and Google AI responses
5. **Performance Testing**: Large meal history lists

## Deployment Checklist

- [ ] API keys configured in environment
- [ ] Supabase project verified and accessible
- [ ] Google Generative AI API enabled and quota checked
- [ ] RLS policies enabled on all tables
- [ ] Edge function deployed and tested
- [ ] Release build created for app store
- [ ] Privacy policy documented
- [ ] Terms of service documented
- [ ] Error tracking (e.g., Sentry) configured
- [ ] Analytics (e.g., Firebase Analytics) configured

## Troubleshooting Guide

**Recommendation generation fails**:
- Check Google API key validity
- Verify API quota not exceeded
- Check user profile is complete
- Verify internet connection

**Meal history not loading**:
- Confirm user is authenticated
- Check RLS policies
- Verify Supabase connection
- Check database has data

**Profile setup not saving**:
- Verify Supabase permissions
- Check network connection
- Ensure auth user ID matches
- Verify required fields filled

**App crashes on launch**:
- Run `flutter clean && flutter pub get`
- Check `.env` file exists and has values
- Verify Flutter version is v3.0+
- Check Android SDK and iOS Xcode versions