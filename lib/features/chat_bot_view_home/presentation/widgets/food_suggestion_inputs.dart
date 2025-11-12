import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

/// Widget for food suggestion input fields
class FoodSuggestionInputs extends StatelessWidget {
  final TextEditingController ingredientsController;
  final TextEditingController budgetController;
  final TextEditingController mealTypeController;
  final VoidCallback onSubmit;

  const FoodSuggestionInputs({
    super.key,
    required this.ingredientsController,
    required this.budgetController,
    required this.mealTypeController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: ingredientsController,
            decoration: InputDecoration(
              hintText: l10n.chatBotEnterIngredients,
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: budgetController,
            decoration: InputDecoration(
              hintText: l10n.chatBotEnterBudget,
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: mealTypeController,
            decoration: InputDecoration(
              hintText: l10n.chatBotEnterMealType,
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onSubmit,
            child: Text(l10n.chatBotSubmit),
          ),
        ],
      ),
    );
  }
}
