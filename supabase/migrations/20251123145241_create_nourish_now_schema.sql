/*
  # NourishNow Database Schema

  1. New Tables
    - `users` - User profile information with dietary preferences
      - `id` (uuid, primary key)
      - `email` (text, unique)
      - `first_name` (text)
      - `age` (integer)
      - `weight_goal` (text) - 'Weight Loss', 'Weight Gain', 'Maintenance'
      - `dietary_restrictions` (text array) - e.g., ['Vegan', 'Lactose Intolerant']
      - `default_budget` (text) - '$', '$$', '$$$'
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

    - `meal_history` - Log of all meals suggested and logged
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key)
      - `date` (timestamp)
      - `meal_type` (text) - 'Breakfast', 'Lunch', 'Dinner'
      - `meal_name` (text)
      - `calories` (integer)
      - `protein` (numeric)
      - `carbs` (numeric)
      - `fat` (numeric)
      - `rating` (integer) - 1-5 stars
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on both tables
    - Users can only access their own data
    - Proper policies for read/write operations

  3. Indexes
    - Index on user_id and date for efficient queries
*/

-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  first_name text NOT NULL,
  age integer NOT NULL,
  weight_goal text NOT NULL CHECK (weight_goal IN ('Weight Loss', 'Weight Gain', 'Maintenance')),
  dietary_restrictions text[] DEFAULT '{}',
  default_budget text NOT NULL CHECK (default_budget IN ('$', '$$', '$$$')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create meal_history table
CREATE TABLE IF NOT EXISTS meal_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  date timestamptz NOT NULL,
  meal_type text NOT NULL CHECK (meal_type IN ('Breakfast', 'Lunch', 'Dinner')),
  meal_name text NOT NULL,
  calories integer NOT NULL,
  protein numeric NOT NULL DEFAULT 0,
  carbs numeric NOT NULL DEFAULT 0,
  fat numeric NOT NULL DEFAULT 0,
  rating integer CHECK (rating >= 1 AND rating <= 5),
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_history ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users table
CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
  ON users FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- RLS Policies for meal_history table
CREATE POLICY "Users can view own meal history"
  ON meal_history FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own meal records"
  ON meal_history FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own meal records"
  ON meal_history FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own meal records"
  ON meal_history FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_meal_history_user_id ON meal_history(user_id);
CREATE INDEX IF NOT EXISTS idx_meal_history_date ON meal_history(date);
CREATE INDEX IF NOT EXISTS idx_meal_history_user_date ON meal_history(user_id, date);