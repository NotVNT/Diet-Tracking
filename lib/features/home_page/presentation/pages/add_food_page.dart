import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../common/snackbar_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../services/notification_service.dart';
import '../../../record_view_home/domain/entities/food_record_entity.dart';
import '../../../record_view_home/presentation/cubit/record_cubit.dart';
import '../widgets/components/nutrient_color_scheme.dart';

class AddFoodPage extends StatefulWidget {
  const AddFoodPage({super.key});

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _caloriesController = TextEditingController();
    _proteinController = TextEditingController();
    _carbsController = TextEditingController();
    _fatController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _saveFood() async {
    if (_formKey.currentState!.validate()) {
      final l10n = AppLocalizations.of(context)!;
      final foodName = _nameController.text;
      final calories = double.tryParse(_caloriesController.text) ?? 0.0;
      final protein = double.tryParse(_proteinController.text);
      final carbs = double.tryParse(_carbsController.text);
      final fat = double.tryParse(_fatController.text);

      await context.read<RecordCubit>().saveFoodRecord(
        foodName,
        calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        recordType: RecordType.manual,
      );

      if (mounted) {
        final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
        await LocalNotificationService().showSimpleNotification(
          title: l10n.addFoodSuccessNotificationTitle,
          body: l10n.addFoodSuccessNotificationBody(foodName, today),
        );

        if (!mounted) return;

        SnackBarHelper.showSuccess(context, l10n.recordSuccessMessage);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF121212)
          : colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: Text(
          l10n.addFoodPageTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surfaceContainerHighest,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _nameController,
                label: l10n.addFoodNameLabel,
                validatorMessage: l10n.addFoodEmptyValidator,
                icon: '🍽️',
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _caloriesController,
                label: l10n.addFoodCaloriesLabel,
                keyboardType: TextInputType.number,
                validatorMessage: l10n.addFoodEmptyValidator,
                icon: NutrientColorScheme.getEmoji(NutrientType.calorie),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _proteinController,
                      label: l10n.addFoodProteinLabel,
                      keyboardType: TextInputType.number,
                      validatorMessage: l10n.addFoodEmptyValidator,
                      icon: NutrientColorScheme.getEmoji(NutrientType.protein),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildTextField(
                      controller: _carbsController,
                      label: l10n.addFoodCarbsLabel,
                      keyboardType: TextInputType.number,
                      validatorMessage: l10n.addFoodEmptyValidator,
                      icon: NutrientColorScheme.getEmoji(NutrientType.carbs),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _fatController,
                label: l10n.addFoodFatLabel,
                keyboardType: TextInputType.number,
                validatorMessage: l10n.addFoodEmptyValidator,
                icon: NutrientColorScheme.getEmoji(NutrientType.fat),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _saveFood,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text(l10n.addFoodSaveButton),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String validatorMessage,
    TextInputType? keyboardType,
    String? icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        prefixIcon: icon != null
            ? Container(
                width: 0, // Let the padding define the width
                alignment: Alignment.center,
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Text(icon, style: const TextStyle(fontSize: 24)),
              )
            : null,
        labelText: label,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        floatingLabelStyle: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.55),
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[850] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorStyle: TextStyle(color: colorScheme.error),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorMessage;
        }
        return null;
      },
    );
  }
}
