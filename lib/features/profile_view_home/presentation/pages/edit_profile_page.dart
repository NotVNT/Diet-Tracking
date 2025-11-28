import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/profile_entity.dart';
import '../providers/profile_provider.dart';
import '../../../../model/user.dart';
import '../../../../common/custom_app_bar.dart';
import '../../../../common/snackbar_helper.dart';

/// Page for editing user profile
class EditProfilePage extends StatefulWidget {
  final ProfileProvider profileProvider;

  const EditProfilePage({
    super.key,
    required this.profileProvider,
  });

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
  late List<String> _goals;

  @override
  void initState() {
    super.initState();
    final profile = widget.profileProvider.profile;
    
    _fullNameController = TextEditingController(text: profile?.displayName ?? '');
    _ageController = TextEditingController(text: profile?.age?.toString() ?? '');
    _heightController = TextEditingController(text: profile?.height?.toString() ?? '');
    _weightController = TextEditingController(text: profile?.weight?.toString() ?? '');
    _goalWeightController = TextEditingController(text: profile?.goalWeight?.toString() ?? '');
    
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
        medicalConditions: profile.medicalConditions,
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
    _goals = [
      AppLocalizations.of(context)!.editProfileGoalLoseWeight,
      AppLocalizations.of(context)!.editProfileGoalGainWeight,
      AppLocalizations.of(context)!.editProfileGoalMaintainWeight,
      AppLocalizations.of(context)!.editProfileGoalBuildMuscle,
    ];
    
    // Validate selectedGoal is in the current goals list
    if (_selectedGoal != null && !_goals.contains(_selectedGoal)) {
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.editProfileSave,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
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
              _buildSectionTitle(AppLocalizations.of(context)!.editProfilePersonalInfo),
              _buildTextField(
                controller: _fullNameController,
                label: AppLocalizations.of(context)!.editProfileFullName,
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!.editProfilePleaseEnterFullName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Tuổi
              _buildTextField(
                controller: _ageController,
                label: AppLocalizations.of(context)!.editProfileAge,
                icon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context)!.editProfilePleaseEnterAge;
                  }
                  final age = int.tryParse(value.trim());
                  if (age == null || age < 1 || age > 120) {
                    return AppLocalizations.of(context)!.editProfileInvalidAge;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Giới tính
              _buildSectionTitle(AppLocalizations.of(context)!.editProfileGender),
              Row(
                children: [
                  Expanded(
                    child: _buildGenderCard(
                      gender: GenderType.male,
                      label: AppLocalizations.of(context)!.editProfileMale,
                      icon: Icons.male,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGenderCard(
                      gender: GenderType.female,
                      label: AppLocalizations.of(context)!.editProfileFemale,
                      icon: Icons.female,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Chiều cao
              _buildSectionTitle(AppLocalizations.of(context)!.editProfileBodyMetrics),
              _buildTextField(
                controller: _heightController,
                label: AppLocalizations.of(context)!.editProfileHeight,
                icon: Icons.height,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final height = double.tryParse(value.trim());
                    if (height == null || height < 50 || height > 300) {
                      return AppLocalizations.of(context)!.editProfileInvalidHeight;
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Cân nặng
              _buildTextField(
                controller: _weightController,
                label: AppLocalizations.of(context)!.editProfileWeight,
                icon: Icons.monitor_weight_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final weight = double.tryParse(value.trim());
                    if (weight == null || weight < 20 || weight > 500) {
                      return AppLocalizations.of(context)!.editProfileInvalidWeight;
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Mục tiêu cân nặng
              _buildTextField(
                controller: _goalWeightController,
                label: AppLocalizations.of(context)!.editProfileGoalWeight,
                icon: Icons.flag_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final goalWeight = double.tryParse(value.trim());
                    if (goalWeight == null || goalWeight < 20 || goalWeight > 500) {
                      return AppLocalizations.of(context)!.editProfileInvalidGoalWeight;
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Mục tiêu
              _buildSectionTitle(AppLocalizations.of(context)!.editProfileYourGoal),
              _buildGoalDropdown(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withAlpha((255 * 0.04).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildGenderCard({
    required GenderType gender,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedGender == gender;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
                    color: isSelected
              ? Theme.of(context).colorScheme.primary.withAlpha((255 * 0.1).toInt())
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
              ? Theme.of(context).colorScheme.primary 
              : Theme.of(context).colorScheme.outline,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withAlpha((255 * 0.04).toInt()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected 
                  ? Theme.of(context).colorScheme.primary 
                  : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withAlpha((255 * 0.04).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedGoal,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.star_outline,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        hint: Text(AppLocalizations.of(context)!.editProfileSelectGoal),
        items: _goals.map((goal) {
          return DropdownMenuItem(
            value: goal,
            child: Text(goal),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedGoal = value;
          });
        },
      ),
    );
  }
}
