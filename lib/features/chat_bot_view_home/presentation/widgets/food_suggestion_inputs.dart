import 'package:flutter/material.dart';

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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: ingredientsController,
            decoration: const InputDecoration(
              hintText: 'Nhập nguyên liệu món ăn đang có sẵn',
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: budgetController,
            decoration: const InputDecoration(
              hintText: 'Nhâp chi phí mong muốn cho bữa ăn',
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: mealTypeController,
            decoration: const InputDecoration(
              hintText: 'Bữa sáng, Bữa trưa, Bữa tối, Bữa ăn nhẹ, Thực đơn cả ngày',
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onSubmit,
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}
