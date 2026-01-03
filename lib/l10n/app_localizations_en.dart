// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get bottomNavAddFood => 'Add Food';

  @override
  String get addFoodPageTitle => 'Add Food';

  @override
  String get addFoodNameLabel => 'Food name';

  @override
  String get addFoodCaloriesLabel => 'Calories (kcal)';

  @override
  String get addFoodProteinLabel => 'Protein (g)';

  @override
  String get addFoodCarbsLabel => 'Carbs (g)';

  @override
  String get addFoodFatLabel => 'Fat (g)';

  @override
  String get addFoodSaveButton => 'Save Food';

  @override
  String get addFoodEmptyValidator => 'Please enter this information';

  @override
  String get defineYourGoal => 'Define your goal';

  @override
  String get recordSuccessMessage => 'Food record saved successfully!';

  @override
  String get addFoodSuccessNotificationTitle => 'Food Added Successfully';

  @override
  String addFoodSuccessNotificationBody(String foodName, String date) {
    return 'You have added \'$foodName\' on $date.';
  }

  @override
  String get weWillBuild => 'We\'ll build a tailored plan to keep you motivated and help you reach your goals.';

  @override
  String get getStartedNow => 'Get started!';

  @override
  String get appTitle => 'Diet Tracking';

  @override
  String get nutrientFat => 'Fat';

  @override
  String get startTrackingToday => 'Start tracking your\ndiet plan today!';

  @override
  String get trackDailyDiet => 'Track your daily diet with\npersonalized meal plans and\nsmart recommendations.';

  @override
  String get getStarted => 'Get started';

  @override
  String get login => 'Login';

  @override
  String get apply => 'Apply';

  @override
  String get tellUsAboutYourself => 'Tell us about yourself';

  @override
  String get weWillCreatePersonalizedPlan => 'We\'ll create a personalized plan for you based on details like your age and current weight.';

  @override
  String get chatBotYesterday => 'Yesterday';

  @override
  String get chatBotConfirmDeleteTitle => 'Delete session?';

  @override
  String chatBotConfirmDeleteMessage(String sessionTitle) {
    return 'Are you sure you want to delete the session \"$sessionTitle\"?';
  }

  @override
  String get chatBotSessionDeleted => 'Session deleted';

  @override
  String get chatBotUploadVideo => 'Upload Video';

  @override
  String get chatBotUploadVideoSubtitle => 'Analyze food from video';

  @override
  String get chatBotAnalyze => 'Analyze';

  @override
  String get chatBotCancel => 'Cancel';

  @override
  String get chatBotHistoryEmpty => 'No chat history yet';

  @override
  String get chatBotStartConversation => 'Start a conversation...';

  @override
  String get chatBotEmptyTitle => 'Start a new conversation';

  @override
  String get chatBotEmptySubtitle => 'Your chat history will be saved here. Ask me anything about your diet plan!';

  @override
  String get start => 'Start';

  @override
  String get gender => 'Gender';

  @override
  String get weWillUseThisInfo => 'We\'ll use this information to calculate your daily energy needs.';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get continueButton => 'Continue';

  @override
  String get age => 'Age';

  @override
  String get howOldAreYou => 'How old are you?';

  @override
  String get next => 'Next';

  @override
  String get chooseYourDietStyle => 'Which plan do you prefer?';

  @override
  String get youCanChangeLater => 'You can change this later in Settings.';

  @override
  String get keto => 'Keto';

  @override
  String get ketoDescription => 'Very low carb, higher fat.';

  @override
  String get normalWeightLoss => 'Normal weight loss';

  @override
  String get normalWeightLossDescription => 'Balanced carbs, protein, and fat. Easy to maintain.';

  @override
  String get lowCarbs => 'Low Carbs';

  @override
  String get lowCarbsDescription => 'Moderately reduced carbs, easier to sustain.';

  @override
  String get whatIsYourMainGoal => 'What is your main goal?';

  @override
  String get skip => 'Skip';

  @override
  String get loseWeight => 'Lose weight';

  @override
  String get maintainWeight => 'Maintain weight';

  @override
  String get gainWeight => 'Gain weight';

  @override
  String get buildMuscle => 'Build muscle';

  @override
  String get improveFitness => 'Improve fitness';

  @override
  String get eatHealthy => 'Eat healthy';

  @override
  String get reduceStress => 'Reduce stress';

  @override
  String get loseBellyFat => 'Lose belly fat';

  @override
  String get whyDoYouWantToLoseWeight => 'Why do you want to lose weight?';

  @override
  String get whyDoYouWantToGainWeight => 'Why do you want to gain weight?';

  @override
  String get whyDoYouWantToMaintainWeight => 'Why do you want to maintain weight?';

  @override
  String get whyDoYouWantToBuildMuscle => 'Why do you want to build muscle?';

  @override
  String get whyDidYouChooseThisGoal => 'Why did you choose this goal?';

  @override
  String get improveHealth => 'Improve health';

  @override
  String get feelMoreConfident => 'Feel more confident';

  @override
  String get increaseConfidence => 'Increase confidence';

  @override
  String get fitIntoClothes => 'Fit into clothes';

  @override
  String get moreEnergy => 'More energy';

  @override
  String get prepareForEvent => 'Prepare for an event';

  @override
  String get reduceVisceralFat => 'Reduce visceral fat';

  @override
  String get improvePhysicalFitness => 'Improve physical fitness';

  @override
  String get improveAppearance => 'Improve appearance';

  @override
  String get doctorRecommendation => 'Doctor\'s recommendation';

  @override
  String get healthyLifestyle => 'Healthy lifestyle';

  @override
  String get buildStrength => 'Build strength';

  @override
  String get improveAthletics => 'Improve athletics';

  @override
  String get lookMoreMuscular => 'Look more muscular';

  @override
  String get recoverFromIllness => 'Recover from illness';

  @override
  String get increaseAppetite => 'Increase appetite';

  @override
  String get stayHealthy => 'Stay healthy';

  @override
  String get preventWeightGain => 'Prevent weight gain';

  @override
  String get balancedLifestyle => 'Balanced lifestyle';

  @override
  String get maintainFitness => 'Maintain fitness';

  @override
  String get getStronger => 'Get stronger';

  @override
  String get improveBodyComposition => 'Improve body composition';

  @override
  String get athleticPerformance => 'Athletic performance';

  @override
  String get lookToned => 'Look toned';

  @override
  String get boostMetabolism => 'Boost metabolism';

  @override
  String get other => 'Other';

  @override
  String get whatBroughtYouToUs => 'What brought you to us?';

  @override
  String get findSuitableMealPlan => 'Find a suitable meal plan';

  @override
  String get wantToBuildGoodHabits => 'Want to build good habits';

  @override
  String get lackTimeToCook => 'Lack time to cook';

  @override
  String get improveWorkPerformance => 'Improve work performance';

  @override
  String get poorSleep => 'Poor sleep';

  @override
  String get careAboutHeartHealth => 'Care about heart health';

  @override
  String get poorHealthIndicators => 'Poor health indicators';

  @override
  String get optimizeMealCosts => 'Optimize meal costs';

  @override
  String get weBringYouBestResults => 'We bring you the best results';

  @override
  String get personalizedPathwayBasedOnGoals => 'Personalized pathway based on your goals and habits. Start now to see sustainable change.';

  @override
  String get height => 'Height';

  @override
  String get whatIsYourHeight => 'What is your height?';

  @override
  String get weight => 'Weight';

  @override
  String get whatIsYourWeight => 'What is your weight?';

  @override
  String get goalWeight => 'Goal Weight';

  @override
  String get whatIsYourGoalWeight => 'What weight do you want to achieve?';

  @override
  String get done => 'Done';

  @override
  String get youCanDoIt => 'You can do it!';

  @override
  String get maintainCurrentWeightIsHealthy => 'Maintaining your current weight is a healthy choice';

  @override
  String get loseWeightGoalPrefix => 'Losing';

  @override
  String get loseWeightGoalSuffix => 'kg is a challenging but completely achievable goal';

  @override
  String get gainWeightGoalPrefix => 'Gaining';

  @override
  String get gainWeightGoalSuffix => 'kg will help you achieve better balance';

  @override
  String get setClearGoalsMessage => 'Setting clear goals helps you get closer every day';

  @override
  String get goalWeightPrefix => 'Goal weight';

  @override
  String get userProgressMessage => 'users report clear progress after 4 weeks on the plan';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get signUpAccount => 'Sign Up Account';

  @override
  String get chooseYourLanguage => 'Choose your language';

  @override
  String get languageChangedSuccessfully => 'Language changed successfully!';

  @override
  String get languageChangedToVietnamese => 'Language changed to Vietnamese';

  @override
  String get languageChangedToEnglish => 'Language changed to English';

  @override
  String get bmiCurrentTitle => 'Current BMI';

  @override
  String get bmiEnterHeightToCalculate => 'Please enter height to calculate BMI.';

  @override
  String get bmiUnderweight => 'You are underweight.';

  @override
  String get bmiNormal => 'You have a normal weight.';

  @override
  String get bmiOverweight => 'You are overweight.';

  @override
  String get bmiObese => 'You need to lose weight seriously to protect your health.';

  @override
  String get activityLevelSedentaryTitle => 'Sedentary';

  @override
  String get activityLevelSedentarySubtitle => '(Mostly sitting, little or no exercise)';

  @override
  String get activityLevelLightlyActiveTitle => 'Lightly active';

  @override
  String get activityLevelLightlyActiveSubtitle => '(Exercise/sports 1-3 days/week)';

  @override
  String get activityLevelModeratelyActiveTitle => 'Moderately active';

  @override
  String get activityLevelModeratelyActiveSubtitle => '(Exercise/sports 3-5 days/week)';

  @override
  String get dateRangeTitle => 'Date range';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get last7Days => 'Last 7 days';

  @override
  String get customRange => 'Custom range';

  @override
  String get activityLevelVeryActiveTitle => 'Very active';

  @override
  String get activityLevelVeryActiveSubtitle => '(Exercise/sports 6-7 days/week)';

  @override
  String get activityLevelExtraActiveTitle => 'Extra active';

  @override
  String get activityLevelExtraActiveSubtitle => '(Exercise twice a day, manual labor)';

  @override
  String get loginTitle => 'Login';

  @override
  String get emailOrPhone => 'Email or Phone Number';

  @override
  String get emailOrPhoneHint => 'Enter Email or Phone Number';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => '••••••••';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get loginButton => 'Login';

  @override
  String get orLoginWith => 'OR login with';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get dontHaveAccount => 'I don\'t have an account';

  @override
  String get pleaseEnterEmail => 'Please enter email';

  @override
  String get pleaseEnterPassword => 'Please enter password';

  @override
  String get loginSuccess => 'Login successful!';

  @override
  String get loginFailed => 'Login failed. Please check your information.';

  @override
  String get invalidCredentials => 'Email or password is incorrect. Please try again.';

  @override
  String get googleLoginSuccess => 'Google login successful!';

  @override
  String get googleLoginCancelled => 'Google login cancelled.';

  @override
  String get googleLoginFailed => 'Google login failed. Please try again.';

  @override
  String get passwordResetEmailSent => 'Password reset email sent. Please check your inbox.';

  @override
  String get pleaseEnterEmailFirst => 'Please enter email first.';

  @override
  String get passwordResetFailed => 'Unable to send password reset email. Please check your email and try again.';

  @override
  String get signupTitle => 'Create Account';

  @override
  String get fullName => 'Full Name';

  @override
  String get fullNameHint => 'Enter your full name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get phoneNumberHint => 'Enter phone number';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'example@gmail.com';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmPasswordHint => '••••••••';

  @override
  String get agreeWith => 'I agree with ';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get and => ' and ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get signupButton => 'Sign Up';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get loginLink => 'Login';

  @override
  String get forgotPasswordTitle => 'Forgot Password?';

  @override
  String get forgotPasswordInstruction => 'Enter your email and we\'ll send you instructions to reset your password.';

  @override
  String get sendResetEmail => 'Send Reset Email';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get success => 'Success';

  @override
  String get invalidEmail => 'Invalid email.';

  @override
  String get pleaseEnterValidEmail => 'Please enter email.';

  @override
  String get emailNotExist => 'Email does not exist in the system.';

  @override
  String accountUsesProviderMessage(Object provider) {
    return 'This account uses: $provider. Cannot reset password via email.';
  }

  @override
  String get unableToSendResetEmail => 'Unable to send password reset email. Please try again later.';

  @override
  String get userNotFound => 'No account found with this email.';

  @override
  String get tooManyRequests => 'Too many requests. Please try again later.';

  @override
  String get networkError => 'Network error. Please check your connection and try again.';

  @override
  String get pleaseEnterFullName => 'Please enter your full name.';

  @override
  String get pleaseEnterPhoneNumber => 'Please enter phone number.';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters.';

  @override
  String get pleaseConfirmPassword => 'Please confirm password.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get pleaseAgreeToTerms => 'Please agree to the terms of service.';

  @override
  String get emailAlreadyInUse => 'Email is already in use. Please use a different email.';

  @override
  String get weakPassword => 'Password is too weak. Please use a stronger password.';

  @override
  String get registrationFailed => 'Registration failed. Please try again.';

  @override
  String get registrationSuccess => 'Registration successful!';

  @override
  String get chatBotDietAssistant => 'Diet Assistant';

  @override
  String get chatBotNewChatCreated => 'New conversation created';

  @override
  String get chatBotChatHistoryComingSoon => 'Chat history feature will be added later';

  @override
  String get chatBotSettingsComingSoon => 'Settings feature will be added later';

  @override
  String get chatBotPleaseEnterAllInfo => 'Please fill in all information';

  @override
  String get chatBotCreateNewChat => 'Create new chat';

  @override
  String get chatBotStartNewConversation => 'Start a new conversation';

  @override
  String get chatBotChatHistory => 'Chat history';

  @override
  String get chatBotViewPreviousConversations => 'View previous conversations';

  @override
  String get chatBotSettings => 'Settings';

  @override
  String get chatBotCustomizeApp => 'Customize app';

  @override
  String get chatBotEnterMessage => 'Enter message...';

  @override
  String get chatBotFoodSuggestion => 'food suggestion';

  @override
  String get chatBotEnterIngredients => 'Enter available ingredients';

  @override
  String get chatBotEnterBudget => 'Enter desired meal budget';

  @override
  String get chatBotEnterMealType => 'Breakfast, Lunch, Dinner, Snack, Full day menu';

  @override
  String get chatBotSubmit => 'Submit';

  @override
  String get chatBotJustNow => 'Just now';

  @override
  String chatBotMinutesAgo(int minutes) {
    return '$minutes minutes ago';
  }

  @override
  String chatBotHoursAgo(int hours) {
    return '$hours hours ago';
  }

  @override
  String get chatBotSaveAll => 'Save all';

  @override
  String get chatBotSave => 'Save';

  @override
  String chatBotAddedAllToList(int count) {
    return 'Added $count dishes to list';
  }

  @override
  String chatBotAddedToList(String name) {
    return 'Added \"$name\" to list';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileUser => 'User';

  @override
  String get profileAvatarUpdated => 'Avatar updated';

  @override
  String get profileCannotUpdateAvatar => 'Cannot update avatar';

  @override
  String get profileSignedOut => 'Signed out';

  @override
  String get profileCannotSignOut => 'Cannot sign out';

  @override
  String get profileEditProfile => 'Edit profile';

  @override
  String get profileViewStatistics => 'View statistics';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileDataAndSync => 'Data and sync';

  @override
  String get profileSupport => 'Support';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get profileSignIn => 'Sign in';

  @override
  String get profileFeatureInDevelopment => 'Feature in development';

  @override
  String get profileAppName => 'VGP';

  @override
  String get profileAppDescription => 'Smart diet management app';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get editProfileSave => 'Save';

  @override
  String get editProfileUpdated => 'Profile updated';

  @override
  String get editProfileError => 'Error';

  @override
  String get editProfilePersonalInfo => 'Personal information';

  @override
  String get editProfileFullName => 'Full name';

  @override
  String get editProfilePleaseEnterFullName => 'Please enter full name';

  @override
  String get editProfileAge => 'Age';

  @override
  String get editProfilePleaseEnterAge => 'Please enter age';

  @override
  String get editProfileInvalidAge => 'Invalid age';

  @override
  String get editProfileGender => 'Gender';

  @override
  String get editProfileMale => 'Male';

  @override
  String get editProfileFemale => 'Female';

  @override
  String get editProfileBodyMetrics => 'Body metrics';

  @override
  String get editProfileHeight => 'Height (cm)';

  @override
  String get editProfileInvalidHeight => 'Invalid height';

  @override
  String get editProfileWeight => 'Weight (kg)';

  @override
  String get editProfileInvalidWeight => 'Invalid weight';

  @override
  String get editProfileGoalWeight => 'Goal weight (kg)';

  @override
  String get editProfileInvalidGoalWeight => 'Invalid goal weight';

  @override
  String get editProfileYourGoal => 'Your goal';

  @override
  String get editProfileSelectGoal => 'Select goal';

  @override
  String get editProfileGoalLoseWeight => 'Lose weight';

  @override
  String get editProfileGoalGainWeight => 'Gain weight';

  @override
  String get editProfileGoalMaintainWeight => 'Maintain weight';

  @override
  String get editProfileGoalBuildMuscle => 'Build muscle';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationTitle => 'Notifications';

  @override
  String get settingsNotificationSubtitle => 'Receive notifications about meals and goals';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsDarkMode => 'Dark mode';

  @override
  String get settingsDarkModeSubtitle => 'Use dark theme';

  @override
  String get settingsDarkModeEnabled => 'Switched to dark mode';

  @override
  String get settingsDarkModeDisabled => 'Switched to light mode';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsUnits => 'Units';

  @override
  String get settingsUnitSystem => 'Unit system';

  @override
  String get dataSyncTitle => 'Data & Sync';

  @override
  String get dataSyncAutoSync => 'Auto sync';

  @override
  String get dataSyncAutoSyncSubtitle => 'Sync data automatically with cloud';

  @override
  String get dataSyncBackupData => 'Backup data';

  @override
  String get dataSyncBackupDataSubtitle => 'Backup your data';

  @override
  String get dataSyncBackupDialogTitle => 'Backup data';

  @override
  String get dataSyncBackupDialogMessage => 'Do you want to backup your data to the cloud?';

  @override
  String get dataSyncBackupDialogCancel => 'Cancel';

  @override
  String get dataSyncBackupDialogConfirm => 'Backup';

  @override
  String get dataSyncBackupInProgress => 'Backing up data...';

  @override
  String get dataSyncClearCache => 'Clear cache';

  @override
  String get dataSyncClearCacheSubtitle => 'Clear temporary data';

  @override
  String get dataSyncClearCacheDialogTitle => 'Clear cache';

  @override
  String get dataSyncClearCacheDialogMessage => 'Clearing cache will free up storage but may slow down the app on next launch. Are you sure you want to clear?';

  @override
  String get dataSyncClearCacheDialogCancel => 'Cancel';

  @override
  String get dataSyncClearCacheDialogConfirm => 'Clear';

  @override
  String get dataSyncClearCacheSuccess => 'Cache cleared successfully';

  @override
  String get supportTitle => 'Support';

  @override
  String get supportPrivacyPolicy => 'Privacy policy';

  @override
  String get supportOpeningPrivacyPolicy => 'Opening privacy policy...';

  @override
  String get supportTermsOfService => 'Terms of service';

  @override
  String get supportOpeningTermsOfService => 'Opening terms of service...';

  @override
  String get supportRecommendationSources => 'Recommendation sources';

  @override
  String get supportOpeningRecommendationSources => 'Opening recommendation sources...';

  @override
  String get supportFindVGPOnSocialMedia => 'Find VGP on social media';

  @override
  String get supportTiktok => 'Tiktok';

  @override
  String get supportOpeningTiktok => 'Opening TikTok...';

  @override
  String get supportFacebook => 'Facebook';

  @override
  String get supportOpeningFacebook => 'Opening Facebook...';

  @override
  String get supportInstagram => 'Instagram';

  @override
  String get supportOpeningInstagram => 'Opening Instagram...';

  @override
  String get supportHelpCenter => 'Help center';

  @override
  String get supportAlwaysHereToHelp => 'We are always here to help';

  @override
  String get helpCenterTitle => 'Help center';

  @override
  String get helpCenterWeAreReadyToHelp => 'We are ready to help';

  @override
  String get helpCenterFindAnswersOrContact => 'Find answers or contact the team';

  @override
  String get helpCenterFAQ => 'Frequently asked questions';

  @override
  String get helpCenterContactUs => 'Contact us';

  @override
  String get helpCenterFAQ1Question => 'How to track nutrition?';

  @override
  String get helpCenterFAQ1Answer => 'You can add food to your daily meal diary. The app will automatically calculate nutrition for you.';

  @override
  String get helpCenterFAQ2Question => 'Can I set calorie goals?';

  @override
  String get helpCenterFAQ2Answer => 'Yes, you can set calorie goals and other nutrition metrics in the Goal Settings section.';

  @override
  String get helpCenterFAQ3Question => 'How to create a menu?';

  @override
  String get helpCenterFAQ3Answer => 'Go to the Menu section, select \"Create new\" and add the dishes you want. The app will automatically calculate nutrition.';

  @override
  String get helpCenterFAQ4Question => 'Is my data synchronized?';

  @override
  String get helpCenterFAQ4Answer => 'Yes, data is automatically synchronized with cloud if you are logged in to an account.';

  @override
  String get helpCenterFAQ5Question => 'How to export reports?';

  @override
  String get helpCenterFAQ5Answer => 'Go to the Report section, select a time period and press the \"Export PDF\" button to download the report to your device.';

  @override
  String get helpCenterContactEmail => 'Email';

  @override
  String get helpCenterContactEmailAddress => 'support@vgp.com';

  @override
  String get helpCenterContactPhone => 'Phone';

  @override
  String get helpCenterContactPhoneNumber => '+84 123 456 789';

  @override
  String get helpCenterContactAddress => 'Address';

  @override
  String get helpCenterContactAddressValue => '123 Main Street, District 1, Ho Chi Minh City';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get bottomNavHome => 'Home';

  @override
  String get bottomNavRecord => 'Record';

  @override
  String get bottomNavChatBot => 'Chat bot';

  @override
  String get bottomNavProfile => 'Profile';

  @override
  String get bottomNavScanFood => 'Scan food';

  @override
  String get bottomNavReport => 'Report';

  @override
  String get searchHint => 'Search';

  @override
  String get calorieCardBurnedToday => 'Your calories burned today';

  @override
  String get nutrientProtein => 'Protein';

  @override
  String get nutrientFiber => 'Fiber';

  @override
  String get nutrientCarbs => 'Carbs';

  @override
  String get calorieCardCaloriesTaken => 'Calories taken';

  @override
  String get calorieCardViewReport => 'View report';

  @override
  String get notificationTitle => 'Notifications';

  @override
  String get waterReminderTitle => 'Water Reminder';

  @override
  String get waterReminderMessage => 'Drink enough water every day to keep your body healthy and energized!';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get recordPageTitle => 'Record Meals';

  @override
  String get recordedMealsTitle => 'Recorded Meals';

  @override
  String get retryButton => 'Retry';

  @override
  String get noMealsRecorded => 'No meals recorded yet';

  @override
  String get addFirstMeal => 'Add your first meal!';

  @override
  String get calories => 'calories';

  @override
  String get nutritionInfo => 'Nutrition Information';

  @override
  String get foodScannerTitle => 'Food scanner';

  @override
  String get foodScannerSubtitle => 'Align the product inside the frame';

  @override
  String get foodScannerOverlayAutoDetect => 'Auto detecting...';

  @override
  String get foodScannerOverlayBarcodeHint => 'Align barcode inside the frame';

  @override
  String get foodScannerActionFood => 'Scan food';

  @override
  String get foodScannerActionBarcode => 'Barcode';

  @override
  String get foodScannerActionGallery => 'Gallery';

  @override
  String get foodScannerHelpTitle => 'How to scan';

  @override
  String get foodScannerHelpTip1 => 'Place the meal fully inside the frame.';

  @override
  String get foodScannerHelpTip2 => 'Use the Barcode mode for packaged products.';

  @override
  String get foodScannerHelpTip3 => 'Pick from Gallery to reuse saved photos.';

  @override
  String get foodScannerGalleryTitle => 'Pick from gallery';

  @override
  String get foodScannerGallerySubtitle => 'Select a previously captured meal photo.';

  @override
  String get foodScannerGalleryButton => 'Open gallery';

  @override
  String get foodScannerPlaceholderCaptureFood => 'Capturing food photo (coming soon)';

  @override
  String get foodScannerPlaceholderScanBarcode => 'Scanning barcode (coming soon)';

  @override
  String get foodScannerPlaceholderOpenGallery => 'Opening gallery (coming soon)';

  @override
  String get recentlyLoggedTitle => 'Recently logged';

  @override
  String get recentlyLoggedSubtitle => 'Start tracking your meals by taking a quick picture';

  @override
  String get recentlyLoggedEmpty => 'You haven\'t uploaded any food';

  @override
  String get viewAll => 'View all';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get deletePhoto => 'Delete Photo';

  @override
  String get deletePhotoConfirmation => 'Are you sure you want to delete this photo?';

  @override
  String get photoDeletedSuccessfully => 'Deleted successfully';

  @override
  String get analyzeFood => 'Analyze Food';

  @override
  String get shareFunctionality => 'Share functionality coming soon';

  @override
  String get aiFoodAnalysis => 'AI food analysis coming soon';

  @override
  String get permissionCameraRequired => 'Please grant camera access to use this feature.';

  @override
  String get inboxTitle => 'Inbox';

  @override
  String get searchHintText => 'Search';

  @override
  String get filterTitle => 'Filter';

  @override
  String get category => 'Category';

  @override
  String get all => 'All';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get snack => 'Snack';

  @override
  String get calorieRangeLabel => 'Calorie range';

  @override
  String get reset => 'Reset';

  @override
  String get mealsListTitle => 'Meals list';

  @override
  String get noMealsYet => 'No meals yet';

  @override
  String get startByScanningOrPhoto => 'Scan a barcode or take a photo to get started';

  @override
  String get deleteMealTooltip => 'Delete meal';

  @override
  String get deleteMealTitle => 'Delete meal?';

  @override
  String deleteMealMessage(String foodName) {
    return 'Are you sure you want to delete \"$foodName\" from records?';
  }

  @override
  String get initializing => 'Initializing...';

  @override
  String get selectedFood => 'Selected Food';

  @override
  String get snackbarSuccessTitle => 'Success';

  @override
  String get snackbarErrorTitle => 'Error';

  @override
  String get snackbarWarningTitle => 'Warning';

  @override
  String get snackbarInfoTitle => 'Info';

  @override
  String get foodScannerCantCapturePhoto => 'Couldn\'t capture photo, please try again.';

  @override
  String get foodScannerCantOpenGallery => 'Couldn\'t open gallery, please try again.';

  @override
  String get foodScannerNoBarcodeFoundSaving => 'No barcode found in image. Saving photo...';

  @override
  String get foodScannerNoCamera => 'No camera found on device.';

  @override
  String get foodScannerSavePhotoSuccess => 'Photo saved successfully';

  @override
  String get foodScannerUploadError => 'Couldn\'t upload photo to Cloudinary. Please try again.';

  @override
  String get foodScannerSavePhotoError => 'Saved photo (error looking up info)';

  @override
  String foodScannerSavedBarcodeNoDetail(Object barcodeValue) {
    return 'Saved code: $barcodeValue (Details not found)';
  }

  @override
  String get foodScannerCameraNotReady => 'Camera not ready';

  @override
  String get foodScannerBarcodeError => 'Error scanning barcode';

  @override
  String foodScannerProductDefaultName(Object barcode) {
    return 'Product $barcode';
  }

  @override
  String foodScannerScanned(Object foodName) {
    return 'Scanned: $foodName';
  }

  @override
  String get foodScannerSaveProductError => 'Error saving product';

  @override
  String get mealDeletedSuccessfully => 'Meal deleted successfully';

  @override
  String get deleteMealFailed => 'Failed to delete meal';

  @override
  String get sourceTagBotSuggestion => 'Chatbot suggestion';

  @override
  String get sourceTagScanned => 'From scan/photo';

  @override
  String get sourceTagManual => 'Manual input';

  @override
  String get foodAllergiesTitle => 'Food Allergies';

  @override
  String get foodAllergiesSubtitle => 'Please provide information about your food allergies so we can best assist you';

  @override
  String get foodAllergiesHint => 'Ex: Seafood...';

  @override
  String get add => 'Add';

  @override
  String get noAllergiesAdded => 'No allergies added yet';

  @override
  String get allergySeafood => 'Seafood';

  @override
  String get allergyMilk => 'Milk';

  @override
  String get allergyPeanuts => 'Peanuts';

  @override
  String get allergyEggs => 'Eggs';

  @override
  String get allergyWheat => 'Wheat';

  @override
  String get allergySoy => 'Soy';

  @override
  String get allergyFish => 'Fish';

  @override
  String get allergyNuts => 'Nuts';

  @override
  String get allergyShrimp => 'Shrimp';

  @override
  String get allergyCrab => 'Crab';

  @override
  String get allergyBeef => 'Beef';

  @override
  String get allergyChicken => 'Chicken';

  @override
  String get allergySesame => 'Sesame';

  @override
  String get allergyScallops => 'Scallops';

  @override
  String get allergySnails => 'Snails';

  @override
  String get allergyGluten => 'Gluten';

  @override
  String get allergyLactose => 'Lactose';

  @override
  String get allergyHoney => 'Honey';

  @override
  String get allergyStrawberry => 'Strawberry';

  @override
  String get allergyKiwi => 'Kiwi';

  @override
  String get allergyTomato => 'Tomato';

  @override
  String get allergyMushroom => 'Mushroom';

  @override
  String get allergyAlcohol => 'Alcohol/Beer';

  @override
  String get allergyPreservatives => 'Preservatives';

  @override
  String get allergyFoodColoring => 'Food Coloring';

  @override
  String get allergyMustard => 'Mustard';

  @override
  String get allergyCelery => 'Celery';

  @override
  String get allergyAlmond => 'Almond';

  @override
  String get allergyCashew => 'Cashew';

  @override
  String get allergyWalnut => 'Walnut';

  @override
  String get allergyChestnut => 'Chestnut';

  @override
  String get allergyOats => 'Oats';

  @override
  String get allergyCorn => 'Corn';

  @override
  String get allergyBanana => 'Banana';

  @override
  String get allergyPineapple => 'Pineapple';

  @override
  String get allergyGarlic => 'Garlic';

  @override
  String get allergyOnion => 'Onion';

  @override
  String get allergyChocolate => 'Chocolate';

  @override
  String get allergyCoffee => 'Coffee';

  @override
  String get howActiveAreYou => 'How active are you each day?';

  @override
  String get howLongToReachGoal => 'How long do you want to reach your goal?';

  @override
  String loseWeightAmount(String amount) {
    return 'Lose $amount kg';
  }

  @override
  String gainWeightAmount(String amount) {
    return 'Gain $amount kg';
  }

  @override
  String daysSuffix(int count) {
    return '$count days';
  }

  @override
  String get unhealthyPlanWarning => 'This plan may not be suitable for your health.';

  @override
  String get back => 'Back';

  @override
  String weeksApprox(String weeks) {
    return '≈ $weeks weeks';
  }

  @override
  String get bmr => 'BMR';

  @override
  String get tdee => 'TDEE';

  @override
  String calPerDay(String cal) {
    return '$cal cal/day';
  }

  @override
  String get targetCalories => 'Target Calories';

  @override
  String get dailyAdjustment => 'Daily Adjustment';

  @override
  String calSuffix(String cal) {
    return '$cal cal';
  }

  @override
  String get safeRange => 'Safe Range';

  @override
  String get warningTitle => 'Warning';

  @override
  String recommendationDays(int days) {
    return 'Recommendation: $days days';
  }

  @override
  String get yourGoal => 'Your Goal';

  @override
  String get currentWeight => 'Current Weight';

  @override
  String get targetWeight => 'Target Weight';

  @override
  String get difference => 'Difference';

  @override
  String get time => 'Time';

  @override
  String daysWeeks(int days, String weeks) {
    return '$days days (≈ $weeks weeks)';
  }

  @override
  String get warning => 'Warning';

  @override
  String get recommendation => 'Recommendation';

  @override
  String recommendationDaysWeeks(int days, String weeks) {
    return 'Recommendation: $days days (≈ $weeks weeks)';
  }

  @override
  String get planSummary => 'Plan Summary';

  @override
  String get confirm => 'Confirm';

  @override
  String get understandRisk => 'I understand the risk';

  @override
  String get planSavedWarning => 'Plan saved. Please consult a specialist.';

  @override
  String errorLoadingData(String error) {
    return 'Error loading data: $error';
  }

  @override
  String get noCalculationData => 'No calculation data found.';

  @override
  String get interfaceConfirmationReadyToStartTitle => 'You\'re ready to start!';

  @override
  String get interfaceConfirmationKeepHabitsMessage => 'Keep small habits each day — track meals and weight to see clear progress.';

  @override
  String get interfaceConfirmationUpdateGoalsAnytimeMessage => 'You can update your goal anytime in your profile.';

  @override
  String get interfaceConfirmationGoalMaintain => 'Goal: maintain current weight';

  @override
  String interfaceConfirmationGoalLoseKg(int kg) {
    return 'Goal: lose $kg kg (step by step)';
  }

  @override
  String interfaceConfirmationGoalGainKg(int kg) {
    return 'Goal: gain $kg kg (step by step)';
  }

  @override
  String get videoProcessingTitle => 'Video Processing';

  @override
  String get videoPermissionWarning => 'Camera and Microphone permissions are required to record video.';

  @override
  String videoPickError(String error) {
    return 'Error picking video: $error';
  }

  @override
  String get videoUploadButton => 'Upload Video';

  @override
  String get analysisVideo => 'Analyze Video';

  @override
  String get videoAnalysisTitle => 'Analysis from bot';

  @override
  String videoAnalysisError(String error) {
    return 'Error analyzing video: $error';
  }

  @override
  String get videoNoData => 'No analysis data available.';
}
