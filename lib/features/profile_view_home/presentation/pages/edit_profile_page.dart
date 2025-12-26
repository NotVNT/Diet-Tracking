import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/profile_entity.dart';
import '../providers/profile_provider.dart';
import '../../../../model/user.dart';
import '../../../../common/custom_app_bar.dart';
import '../../../../common/snackbar_helper.dart';
import '../widgets/edit_profile_widgets.dart';
import '../widgets/profile_constants.dart';

/// Page for editing user profile
class EditProfilePage extends StatefulWidget {
  final ProfileProvider profileProvider;

  const EditProfilePage({super.key, required this.profileProvider});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _goalWeightController;

  GenderType? _selectedGender;
  String? _selectedGoal;

  // Goals will be initialized in build method with localization

  @override
  void initState() {
    super.initState();
    _initForm();
  }

  void _initForm() {
    final profile = widget.profileProvider.profile;

    _fullNameController = TextEditingController(
      text: profile?.displayName ?? '',
    );
    _ageController = TextEditingController(
      text: profile?.age?.toString() ?? '',
    );
    _heightController = TextEditingController(
      text: profile?.height?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: profile?.weight?.toString() ?? '',
    );
    _goalWeightController = TextEditingController(
      text: profile?.goalWeight?.toString() ?? '',
    );

    _selectedGender = profile?.gender;
    _selectedGoal = profile?.goal;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _goalWeightController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final profile = widget.profileProvider.profile;
    if (profile == null) return;

    try {
      final updatedProfile = ProfileEntity(
        uid: profile.uid,
        displayName: _fullNameController.text.trim(),
        email: profile.email,
        gender: _selectedGender,
        age: int.tryParse(_ageController.text.trim()),
        height: double.tryParse(_heightController.text.trim()),
        weight: double.tryParse(_weightController.text.trim()),
        goalWeight: double.tryParse(_goalWeightController.text.trim()),
        goal: _selectedGoal,
        allergies: profile.allergies,
        avatars: profile.avatars,
      );

      await widget.profileProvider.updateProfile(updatedProfile);

      if (!mounted) return;

      SnackBarHelper.showSuccess(
        context,
        AppLocalizations.of(context)!.editProfileUpdated,
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(
        context,
        AppLocalizations.of(context)!.editProfileError,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize goals with localized strings
    final loc = AppLocalizations.of(context)!;
    final goalOptions = _buildGoalOptions(loc);

    // Validate selectedGoal is in the current goals list
    if (_selectedGoal != null &&
        !goalOptions.any((option) => option.storageValue == _selectedGoal)) {
      _selectedGoal = null;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.editProfileTitle,
        showBackButton: true,
        showNotificationBell: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _saveProfile,
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.editProfileSave,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Họ và tên
              EditProfileSectionTitle(
                title: AppLocalizations.of(context)!.editProfilePersonalInfo,
              ),
              EditProfileTextField(
                controller: _fullNameController,
                label: AppLocalizations.of(context)!.editProfileFullName,
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(
                      context,
                    )!.editProfilePleaseEnterFullName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tuổi
              EditProfileTextField(
                controller: _ageController,
                label: AppLocalizations.of(context)!.editProfileAge,
                icon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(
                      context,
                    )!.editProfilePleaseEnterAge;
                  }
                  final age = int.tryParse(value.trim());
                  if (age == null ||
                      age < ProfileValidationConstants.minAge ||
                      age > ProfileValidationConstants.maxAge) {
                    return AppLocalizations.of(context)!.editProfileInvalidAge;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Giới tính
              EditProfileSectionTitle(
                title: AppLocalizations.of(context)!.editProfileGender,
              ),
              Row(
                children: [
                  Expanded(
                    child: EditProfileGenderCard(
                      gender: GenderType.male,
                      label: AppLocalizations.of(context)!.editProfileMale,
                      icon: Icons.male,
                      isSelected: _selectedGender == GenderType.male,
                      onTap: () {
                        setState(() {
                          _selectedGender = GenderType.male;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: EditProfileGenderCard(
                      gender: GenderType.female,
                      label: AppLocalizations.of(context)!.editProfileFemale,
                      icon: Icons.female,
                      isSelected: _selectedGender == GenderType.female,
                      onTap: () {
                        setState(() {
                          _selectedGender = GenderType.female;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Chiều cao
              EditProfileSectionTitle(
                title: AppLocalizations.of(context)!.editProfileBodyMetrics,
              ),
              EditProfileTextField(
                controller: _heightController,
                label: AppLocalizations.of(context)!.editProfileHeight,
                icon: Icons.height,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final height = double.tryParse(value.trim());
                    if (height == null ||
                        height < ProfileValidationConstants.minHeight ||
                        height > ProfileValidationConstants.maxHeight) {
                      return AppLocalizations.of(
                        context,
                      )!.editProfileInvalidHeight;
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Cân nặng
              EditProfileTextField(
                controller: _weightController,
                label: AppLocalizations.of(context)!.editProfileWeight,
                icon: Icons.monitor_weight_outlined,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final weight = double.tryParse(value.trim());
                    if (weight == null ||
                        weight < ProfileValidationConstants.minWeight ||
                        weight > ProfileValidationConstants.maxWeight) {
                      return AppLocalizations.of(
                        context,
                      )!.editProfileInvalidWeight;
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Mục tiêu cân nặng
              EditProfileTextField(
                controller: _goalWeightController,
                label: AppLocalizations.of(context)!.editProfileGoalWeight,
                icon: Icons.flag_outlined,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final goalWeight = double.tryParse(value.trim());
                    if (goalWeight == null ||
                        goalWeight < ProfileValidationConstants.minWeight ||
                        goalWeight > ProfileValidationConstants.maxWeight) {
                      return AppLocalizations.of(
                        context,
                      )!.editProfileInvalidGoalWeight;
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Mục tiêu
              EditProfileSectionTitle(
                title: AppLocalizations.of(context)!.editProfileYourGoal,
              ),
              EditProfileGoalDropdown(
                value: _selectedGoal,
                options: goalOptions,
                hint: AppLocalizations.of(context)!.editProfileSelectGoal,
                onChanged: (value) {
                  setState(() {
                    _selectedGoal = value;
                  });
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  List<ProfileGoalOption> _buildGoalOptions(AppLocalizations loc) {
    return [
      ProfileGoalOption(
        storageValue: GoalConstants.loseWeight,
        label: loc.editProfileGoalLoseWeight,
      ),
      ProfileGoalOption(
        storageValue: GoalConstants.loseWeightKeto,
        label: '${loc.editProfileGoalLoseWeight} (${loc.keto})',
      ),
      ProfileGoalOption(
        storageValue: GoalConstants.loseWeightLowCarb,
        label: '${loc.editProfileGoalLoseWeight} (${loc.lowCarbs})',
      ),
      ProfileGoalOption(
        storageValue: GoalConstants.gainWeight,
        label: loc.editProfileGoalGainWeight,
      ),
      ProfileGoalOption(
        storageValue: GoalConstants.maintainWeight,
        label: loc.editProfileGoalMaintainWeight,
      ),
      ProfileGoalOption(
        storageValue: GoalConstants.buildMuscle,
        label: loc.editProfileGoalBuildMuscle,
      ),
    ];
  }
}
