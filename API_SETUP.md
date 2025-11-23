# API Setup Guide

This document provides step-by-step instructions for configuring all required APIs for NourishNow.

## Supabase Configuration

### Status: Already Configured
Your Supabase instance is already provisioned and available.

**Connection Details**:
- URL: `https://tlmbjmreopjejkovsqbf.supabase.co`
- Anon Key: Located in your `.env` file
- Database: PostgreSQL with RLS enabled

**What's Already Set Up**:
- ✓ Database schema (users, meal_history tables)
- ✓ RLS policies (Row Level Security)
- ✓ Indexes for performance
- ✓ Edge Functions runtime

### Verify Supabase Connection

1. In the app, go to Profile screen
2. If you can create an account and see your profile, Supabase is connected

## Google Generative AI Setup (Required)

### Step 1: Create Google Cloud Project

1. Go to: https://console.cloud.google.com
2. Click the project selector at the top
3. Click "New Project"
4. Enter project name: "NourishNow"
5. Click "Create"
6. Wait for project to be created (1-2 minutes)

### Step 2: Enable Generative Language API

1. In Google Cloud Console, click the search bar at the top
2. Type: "Generative Language API"
3. Click the result
4. Click "Enable"
5. Wait for API to be enabled

### Step 3: Create API Key

1. Click the search bar again
2. Type: "Credentials"
3. Click "Credentials" from the APIs & Services
4. Click "Create Credentials" → "API Key"
5. A dialog will show your new API key
6. Click "Copy" to copy the key

### Step 4: Add API Key to Project

1. Open `.env` file in your NourishNow project
2. Add or update this line:
   ```
   GOOGLE_API_KEY=<paste-your-api-key-here>
   ```
3. Save the file

### Step 5: Restrict API Key (Recommended for Production)

1. Back in Google Cloud Console, go to Credentials
2. Find your API key in the list
3. Click on it to edit
4. Under "API restrictions":
   - Select "Restrict key"
   - Search for "Generative Language API"
   - Select it
5. Under "Application restrictions":
   - Select "Android apps" (if targeting Android)
   - Add your app's SHA-1 fingerprint (see below)
6. Click "Save"

#### Get Android App SHA-1 Fingerprint

```bash
# For development/debug build
cd android
./gradlew signingReport
```

Look for "Variant: debugAndroidTest" and copy the SHA1 value.

### Step 6: Verify API Access

Run the app and:
1. Create an account and complete profile setup
2. Go to Home screen
3. Click "Get Breakfast Recommendation"
4. Select budget, mood, and time of day
5. Click "Get Recommendations"

If recommendations load successfully, the API is working!

## Supabase Edge Function Configuration

### Status: Already Deployed
The meal-recommendations edge function is already deployed.

### Verify Edge Function

1. Log in to Supabase dashboard: https://app.supabase.com
2. Go to your project: tlmbjmreopjejkovsqbf
3. Click "Edge Functions" in the left menu
4. Verify "meal-recommendations" appears in the list
5. Click on it to see deployment logs

### Set Edge Function Secrets

The edge function needs the GOOGLE_API_KEY secret:

1. In Supabase dashboard, go to Edge Functions
2. Click the "meal-recommendations" function
3. Go to "Settings" tab
4. Under "Secrets", click "Add secret"
5. Add:
   - Name: `GOOGLE_API_KEY`
   - Value: (your Google API key from above)
6. Click "Save"

## Testing APIs

### 1. Test Supabase Connection

```bash
# In your app, try signing up and logging in
# If successful, Supabase is working
```

### 2. Test Google API

```bash
# In your app, try getting a meal recommendation
# If you see results, Google API is working
```

### 3. Test Edge Function

```bash
# The edge function is tested automatically when you get recommendations
# Check edge function logs in Supabase dashboard if there's an error
```

## Troubleshooting

### "Invalid API Key"
- Verify API key is copied correctly (no extra spaces)
- Check key hasn't been regenerated or revoked
- Ensure Generative Language API is enabled

### "API quota exceeded"
- Check your Google Cloud Console for quota limits
- You get free quota for testing (60 API calls per minute)
- Upgrade billing if you need more

### "Edge Function not found"
- Verify edge function deployment in Supabase dashboard
- Check function logs for deployment errors
- Try redeploying: contact support or redeploy via CLI

### "Authentication error"
- Verify Supabase URL and Anon Key are correct
- Ensure RLS policies are allowing your user
- Check user is properly authenticated

### "No recommendations generated"
- Check internet connection
- Verify Google API key has Generative Language API enabled
- Check app logs for detailed error messages
- Ensure profile is complete (all dietary info set)

## API Rate Limits

### Google Generative AI
- Free tier: 60 requests per minute
- Production tier: Contact Google for limits

### Supabase
- Authentication: Generous free tier
- Database: Depends on your plan
- Edge Functions: Generous free tier

## Security Best Practices

1. **Never Commit Secrets**:
   - Don't commit `.env` file to git
   - Add `.env` to `.gitignore`

2. **Rotate API Keys Regularly**:
   - Generate new keys every 3-6 months
   - Revoke old keys

3. **Monitor Usage**:
   - Check Google Cloud Console for unusual activity
   - Monitor Supabase usage in dashboard
   - Set up billing alerts

4. **Restrict Key Access**:
   - Use API key restrictions (Android/iOS apps only)
   - Don't expose keys in client code unnecessarily

5. **Use Environment Variables**:
   - Store all secrets in `.env` file
   - Load from environment at runtime
   - Never hardcode API keys

## Production Deployment

### Before Going Live

1. ✓ Test all features thoroughly
2. ✓ Set API key restrictions to your app domain/SHA
3. ✓ Enable billing on Google Cloud Console
4. ✓ Set up budget alerts
5. ✓ Test error scenarios
6. ✓ Document API keys and secrets securely
7. ✓ Set up monitoring and alerts

### Monitoring

Set up alerts for:
- API quota usage
- Edge function errors
- Database performance
- Authentication failures

### Updating APIs

To update API keys later:
1. Generate new API key in Google Cloud Console
2. Update `.env` file
3. Update Edge Function secrets in Supabase
4. Rebuild and redeploy app

## Support

- Google Cloud Support: https://cloud.google.com/support
- Supabase Support: https://supabase.com/support
- Community Help: Discord, GitHub Issues, Stack Overflow

## References

- Google Generative AI Docs: https://ai.google.dev/docs
- Supabase Docs: https://supabase.com/docs
- Flutter Dotenv: https://pub.dev/packages/flutter_dotenv