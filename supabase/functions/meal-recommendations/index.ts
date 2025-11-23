const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

interface UserData {
  firstName: string;
  age: number;
  weightGoal: string;
  dietaryRestrictions: string[];
  defaultBudget: string;
}

interface RequestPayload {
  userData: UserData;
  mealType: string;
  budget: string;
  mood: string;
  timeOfDay: string;
}

interface MealOption {
  name: string;
  calories: number;
  macros: {
    protein: number;
    carbs: number;
    fat: number;
  };
  prepTime: number;
  recipe: string;
  type: string;
}

interface RecommendationResponse {
  optimizedMeal: MealOption;
  fastEasyMeal: MealOption;
  indulgentMeal: MealOption;
}

async function generateMealRecommendation(
  userData: UserData,
  mealType: string,
  budget: string,
  mood: string,
  timeOfDay: string
): Promise<RecommendationResponse> {
  const apiKey = Deno.env.get("GOOGLE_API_KEY");

  if (!apiKey) {
    throw new Error("GOOGLE_API_KEY environment variable is not set");
  }

  const calorieTargets: { [key: string]: number } = {
    Breakfast: 400,
    Lunch: 600,
    Dinner: 700,
  };

  const calorieTarget = calorieTargets[mealType] || 500;
  const minCalories = Math.round(calorieTarget * 0.9);
  const maxCalories = Math.round(calorieTarget * 1.1);

  const dietaryRestrictionText = userData.dietaryRestrictions.length > 0
    ? `Dietary restrictions: ${userData.dietaryRestrictions.join(", ")}`
    : "No dietary restrictions";

  const prompt = `You are a nutritionist and meal planning expert. Generate exactly 3 meal recommendations for ${userData.firstName} (age ${userData.age}).

User Profile:
- Weight Goal: ${userData.weightGoal}
- ${dietaryRestrictionText}
- Budget Level: ${budget}
- Current Mood: ${mood}
- Time of Day: ${timeOfDay}
- Meal Type: ${mealType}

Calorie Target: ${calorieTarget} calories (range: ${minCalories}-${maxCalories})

Generate three distinct meal options:

1. **The Optimized Meal**: A nutritionally perfect meal (${minCalories}-${maxCalories} calories) that prioritizes fresh, home-cookable meals aligned with the weight goal. Must respect dietary restrictions.

2. **The Fast/Easy Meal**: A simple meal that can be prepared in max 15 minutes, respecting budget constraints. If mood is 'Tired' or 'Busy', suggest minimal-ingredient recipes or pre-packaged healthy items. Calorie range: ${minCalories}-${maxCalories}.

3. **The Indulgent Meal**: A slightly higher-calorie (up to 20% above target) but still healthy suggestion. Can be local takeout/delivery or a recipe that meets a 'Treat' mood preference.

Return ONLY valid JSON (no markdown, no extra text) in this exact format:
{
  "optimizedMeal": {
    "name": "Meal Name",
    "calories": 550,
    "macros": {"protein": 25, "carbs": 65, "fat": 15},
    "prepTime": 20,
    "recipe": "Brief cooking instructions or where to order",
    "type": "homemade"
  },
  "fastEasyMeal": {
    "name": "Meal Name",
    "calories": 520,
    "macros": {"protein": 22, "carbs": 60, "fat": 16},
    "prepTime": 10,
    "recipe": "Quick preparation steps",
    "type": "quick"
  },
  "indulgentMeal": {
    "name": "Meal Name",
    "calories": 650,
    "macros": {"protein": 28, "carbs": 75, "fat": 22},
    "prepTime": 15,
    "recipe": "Delivery link or recipe",
    "type": "indulgent"
  }
}`;

  const response = await fetch(
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent",
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-goog-api-key": apiKey,
      },
      body: JSON.stringify({
        contents: [
          {
            parts: [
              {
                text: prompt,
              },
            ],
          },
        ],
        generationConfig: {
          temperature: 0.7,
          maxOutputTokens: 1024,
        },
      }),
    }
  );

  if (!response.ok) {
    const errorData = await response.text();
    throw new Error(
      `Google API error: ${response.status} - ${errorData}`
    );
  }

  const data = await response.json();

  if (
    !data.candidates ||
    !data.candidates[0] ||
    !data.candidates[0].content ||
    !data.candidates[0].content.parts ||
    !data.candidates[0].content.parts[0]
  ) {
    throw new Error("Unexpected API response structure");
  }

  const responseText = data.candidates[0].content.parts[0].text;
  const jsonMatch = responseText.match(/\{[\s\S]*\}/);

  if (!jsonMatch) {
    throw new Error("Could not parse JSON from AI response");
  }

  const recommendations: RecommendationResponse = JSON.parse(jsonMatch[0]);
  return recommendations;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: corsHeaders,
    });
  }

  try {
    const payload: RequestPayload = await req.json();

    const recommendations = await generateMealRecommendation(
      payload.userData,
      payload.mealType,
      payload.budget,
      payload.mood,
      payload.timeOfDay
    );

    return new Response(JSON.stringify(recommendations), {
      status: 200,
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json",
      },
    });
  } catch (error) {
    console.error("Error:", error);

    return new Response(
      JSON.stringify({
        error: error instanceof Error ? error.message : "Unknown error",
      }),
      {
        status: 500,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      }
    );
  }
});