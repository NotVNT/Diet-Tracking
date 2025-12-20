class NutritionTotals {
  double calories;
  double protein;
  double carbs;
  double fat;

  NutritionTotals({this.calories = 0, this.protein = 0, this.carbs = 0, this.fat = 0});

  NutritionTotals operator +(NutritionTotals other) => NutritionTotals(
    calories: calories + other.calories,
    protein: protein + other.protein,
    carbs: carbs + other.carbs,
    fat: fat + other.fat,
  );
}

