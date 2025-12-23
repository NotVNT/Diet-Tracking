import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  String get bottomNavAddFood;

  String get addFoodPageTitle;

  String get addFoodNameLabel;

  String get addFoodCaloriesLabel;

  String get addFoodProteinLabel;

  String get addFoodCarbsLabel;

  String get addFoodFatLabel;

  String get addFoodSaveButton;

  String get addFoodEmptyValidator;

  String get defineYourGoal;

  String get recordSuccessMessage;

  String get addFoodSuccessNotificationTitle;

  String addFoodSuccessNotificationBody(String foodName, String date);

  String get caloriesToday;

  String get weWillBuild;

  String get getStartedNow;

  String get appTitle;

  String get nutrientFat;

  String get startTrackingToday;

  String get trackDailyDiet;

  String get getStarted;

  String get login;

  String get apply;

  String get tellUsAboutYourself;

  String get weWillCreatePersonalizedPlan;

  String get chatBotYesterday;

  String get chatBotConfirmDeleteTitle;

  String chatBotConfirmDeleteMessage(String sessionTitle);

  String get chatBotSessionDeleted;

  String get chatBotHistoryEmpty;

  String get chatBotStartConversation;

  String get chatBotEmptyTitle;

  String get chatBotEmptySubtitle;

  String get chatBotChatHistory;

  String get chatBotCreateNewChat;

  String get start;

  String get gender;

  String get weWillUseThisInfo;

  String get male;

  String get female;

  String get continueButton;

  String get age;

  String get howOldAreYou;

  String get next;

  String get chooseYourDietStyle;

  String get youCanChangeLater;

  String get keto;

  String get ketoDescription;

  String get normalWeightLoss;

  String get normalWeightLossDescription;

  String get lowCarbs;

  String get lowCarbsDescription;

  String get whatIsYourMainGoal;

  String get skip;

  String get loseWeight;

  String get maintainWeight;

  String get gainWeight;

  String get buildMuscle;

  String get improveFitness;

  String get eatHealthy;

  String get reduceStress;

  String get loseBellyFat;

  String get whyDoYouWantToLoseWeight;

  String get whyDoYouWantToGainWeight;

  String get whyDoYouWantToMaintainWeight;

  String get whyDoYouWantToBuildMuscle;

  String get whyDidYouChooseThisGoal;

  String get improveHealth;

  String get feelMoreConfident;

  String get increaseConfidence;

  String get fitIntoClothes;

  String get moreEnergy;

  String get prepareForEvent;

  String get reduceVisceralFat;

  String get improvePhysicalFitness;

  String get improveAppearance;

  String get doctorRecommendation;

  String get healthyLifestyle;

  String get buildStrength;

  String get improveAthletics;

  String get lookMoreMuscular;

  String get recoverFromIllness;

  String get increaseAppetite;

  String get stayHealthy;

  String get preventWeightGain;

  String get balancedLifestyle;

  String get maintainFitness;

  String get getStronger;

  String get improveBodyComposition;

  String get athleticPerformance;

  String get lookToned;

  String get boostMetabolism;

  String get other;

  String get whatBroughtYouToUs;

  String get findSuitableMealPlan;

  String get wantToBuildGoodHabits;

  String get lackTimeToCook;

  String get improveWorkPerformance;

  String get poorSleep;

  String get careAboutHeartHealth;

  String get poorHealthIndicators;

  String get optimizeMealCosts;

  String get weBringYouBestResults;

  String get personalizedPathwayBasedOnGoals;

  String get height;

  String get whatIsYourHeight;

  String get weight;

  String get whatIsYourWeight;

  String get goalWeight;

  String get whatIsYourGoalWeight;

  String get done;

  String get youCanDoIt;

  String get maintainCurrentWeightIsHealthy;

  String get loseWeightGoalPrefix;

  String get loseWeightGoalSuffix;

  String get gainWeightGoalPrefix;

  String get gainWeightGoalSuffix;

  String get setClearGoalsMessage;

  String get goalWeightPrefix;

  String get userProgressMessage;

  String get continueAsGuest;

  String get signUpAccount;

  String get chooseYourLanguage;

  String get languageChangedSuccessfully;

  String get languageChangedToVietnamese;

  String get languageChangedToEnglish;

  String get bmiCurrentTitle;

  String get bmiEnterHeightToCalculate;

  String get bmiUnderweight;

  String get bmiNormal;

  String get bmiOverweight;

  String get bmiObese;

  String get activityLevelSedentaryTitle;

  String get activityLevelSedentarySubtitle;

  String get activityLevelLightlyActiveTitle;

  String get activityLevelLightlyActiveSubtitle;

  String get activityLevelModeratelyActiveTitle;

  String get activityLevelModeratelyActiveSubtitle;

  String get dateRangeTitle;

  String get today;

  String get yesterday;

  String get last7Days;

  String get customRange;

  String get activityLevelVeryActiveTitle;

  String get activityLevelVeryActiveSubtitle;

  String get activityLevelExtraActiveTitle;

  String get activityLevelExtraActiveSubtitle;

  String get loginTitle;

  String get emailOrPhone;

  String get emailOrPhoneHint;

  String get password;

  String get passwordHint;

  String get forgotPassword;

  String get loginButton;

  String get orLoginWith;

  String get continueWithGoogle;

  String get dontHaveAccount;

  String get pleaseEnterEmail;

  String get pleaseEnterPassword;

  String get loginSuccess;

  String get loginFailed;

  String get invalidCredentials;

  String get googleLoginSuccess;

  String get googleLoginCancelled;

  String get googleLoginFailed;

  String get passwordResetEmailSent;

  String get pleaseEnterEmailFirst;

  String get passwordResetFailed;

  String get signupTitle;

  String get fullName;

  String get fullNameHint;

  String get phoneNumber;

  String get phoneNumberHint;

  String get email;

  String get emailHint;

  String get confirmPassword;

  String get confirmPasswordHint;

  String get agreeWith;

  String get termsOfService;

  String get and;

  String get privacyPolicy;

  String get signupButton;

  String get alreadyHaveAccount;

  String get loginLink;

  String get forgotPasswordTitle;

  String get forgotPasswordInstruction;

  String get sendResetEmail;

  String get backToLogin;

  String get success;

  String get invalidEmail;

  String get pleaseEnterValidEmail;

  String get emailNotExist;

  String accountUsesProviderMessage(Object provider);

  String get unableToSendResetEmail;

  String get userNotFound;

  String get tooManyRequests;

  String get networkError;

  String get pleaseEnterFullName;

  String get pleaseEnterPhoneNumber;

  String get passwordMinLength;

  String get pleaseConfirmPassword;

  String get passwordsDoNotMatch;

  String get pleaseAgreeToTerms;

  String get emailAlreadyInUse;

  String get weakPassword;

  String get registrationFailed;

  String get registrationSuccess;

  String get chatBotDietAssistant;

  String get chatBotNewChatCreated;

  String get chatBotChatHistoryComingSoon;

  String get chatBotSettingsComingSoon;

  String get chatBotPleaseEnterAllInfo;

  String get chatBotStartNewConversation;

  String get chatBotViewPreviousConversations;

  String get chatBotSettings;

  String get chatBotCustomizeApp;

  String get chatBotEnterMessage;

  String get chatBotFoodSuggestion;

  String get chatBotEnterIngredients;

  String get chatBotEnterBudget;

  String get chatBotEnterMealType;

  String get chatBotSubmit;

  String get chatBotJustNow;

  String chatBotMinutesAgo(int minutes);

  String chatBotHoursAgo(int hours);

  String get chatBotSaveAll;

  String get chatBotSave;

  String chatBotAddedAllToList(int count);

  String chatBotAddedToList(String name);

  String get profileTitle;

  String get profileUser;

  String get profileAvatarUpdated;

  String get profileCannotUpdateAvatar;

  String get profileSignedOut;

  String get profileCannotSignOut;

  String get profileEditProfile;

  String get profileViewStatistics;

  String get profileSettings;

  String get profileDataAndSync;

  String get profileSupport;

  String get profileSignOut;

  String get profileSignIn;

  String get profileFeatureInDevelopment;

  String get profileAppName;

  String get profileAppDescription;

  String get editProfileTitle;

  String get editProfileSave;

  String get editProfileUpdated;

  String get editProfileError;

  String get editProfilePersonalInfo;

  String get editProfileFullName;

  String get editProfilePleaseEnterFullName;

  String get editProfileAge;

  String get editProfilePleaseEnterAge;

  String get editProfileInvalidAge;

  String get editProfileGender;

  String get editProfileMale;

  String get editProfileFemale;

  String get editProfileBodyMetrics;

  String get editProfileHeight;

  String get editProfileInvalidHeight;

  String get editProfileWeight;

  String get editProfileInvalidWeight;

  String get editProfileGoalWeight;

  String get editProfileInvalidGoalWeight;

  String get editProfileYourGoal;

  String get editProfileSelectGoal;

  String get editProfileGoalLoseWeight;

  String get editProfileGoalGainWeight;

  String get editProfileGoalMaintainWeight;

  String get editProfileGoalBuildMuscle;

  String get settingsTitle;

  String get settingsNotifications;

  String get settingsNotificationTitle;

  String get settingsNotificationSubtitle;

  String get settingsAppearance;

  String get settingsDarkMode;

  String get settingsDarkModeSubtitle;

  String get settingsDarkModeEnabled;

  String get settingsDarkModeDisabled;

  String get settingsLanguage;

  String get settingsUnits;

  String get settingsUnitSystem;

  String get dataSyncTitle;

  String get dataSyncAutoSync;

  String get dataSyncAutoSyncSubtitle;

  String get dataSyncBackupData;

  String get dataSyncBackupDataSubtitle;

  String get dataSyncBackupDialogTitle;

  String get dataSyncBackupDialogMessage;

  String get dataSyncBackupDialogCancel;

  String get dataSyncBackupDialogConfirm;

  String get dataSyncBackupInProgress;

  String get dataSyncClearCache;

  String get dataSyncClearCacheSubtitle;

  String get dataSyncClearCacheDialogTitle;

  String get dataSyncClearCacheDialogMessage;

  String get dataSyncClearCacheDialogCancel;

  String get dataSyncClearCacheDialogConfirm;

  String get dataSyncClearCacheSuccess;

  String get supportTitle;

  String get supportPrivacyPolicy;

  String get supportOpeningPrivacyPolicy;

  String get supportTermsOfService;

  String get supportOpeningTermsOfService;

  String get supportRecommendationSources;

  String get supportOpeningRecommendationSources;

  String get supportFindVGPOnSocialMedia;

  String get supportTiktok;

  String get supportOpeningTiktok;

  String get supportFacebook;

  String get supportOpeningFacebook;

  String get supportInstagram;

  String get supportOpeningInstagram;

  String get supportHelpCenter;

  String get supportAlwaysHereToHelp;

  String get helpCenterTitle;

  String get helpCenterWeAreReadyToHelp;

  String get helpCenterFindAnswersOrContact;

  String get helpCenterFAQ;

  String get helpCenterContactUs;

  String get helpCenterFAQ1Question;

  String get helpCenterFAQ1Answer;

  String get helpCenterFAQ2Question;

  String get helpCenterFAQ2Answer;

  String get helpCenterFAQ3Question;

  String get helpCenterFAQ3Answer;

  String get helpCenterFAQ4Question;

  String get helpCenterFAQ4Answer;

  String get helpCenterFAQ5Question;

  String get helpCenterFAQ5Answer;

  String get helpCenterContactEmail;

  String get helpCenterContactEmailAddress;

  String get helpCenterContactPhone;

  String get helpCenterContactPhoneNumber;

  String get helpCenterContactAddress;

  String get helpCenterContactAddressValue;

  String get monday;

  String get tuesday;

  String get wednesday;

  String get thursday;

  String get friday;

  String get saturday;

  String get sunday;

  String get bottomNavHome;

  String get bottomNavRecord;

  String get bottomNavChatBot;

  String get bottomNavProfile;

  String get bottomNavScanFood;

  String get bottomNavReport;

  String get searchHint;

  String get calorieCardBurnedToday;

  String get nutrientProtein;

  String get nutrientFiber;

  String get nutrientCarbs;

  String get calorieCardCaloriesTaken;

  String get calorieCardViewReport;

  String get notificationTitle;

  String get waterReminderTitle;

  String get waterReminderMessage;

  String get markAllAsRead;

  String get noNotifications;

  String get recordPageTitle;

  String get recordedMealsTitle;

  String get retryButton;

  String get noMealsRecorded;

  String get addFirstMeal;

  String get calories;

  String get nutritionInfo;

  String get foodScannerTitle;

  String get foodScannerSubtitle;

  String get foodScannerOverlayAutoDetect;

  String get foodScannerOverlayBarcodeHint;

  String get foodScannerActionFood;

  String get foodScannerActionBarcode;

  String get foodScannerActionGallery;

  String get foodScannerHelpTitle;

  String get foodScannerHelpTip1;

  String get foodScannerHelpTip2;

  String get foodScannerHelpTip3;

  String get foodScannerGalleryTitle;

  String get foodScannerGallerySubtitle;

  String get foodScannerGalleryButton;

  String get foodScannerPlaceholderCaptureFood;

  String get foodScannerPlaceholderScanBarcode;

  String get foodScannerPlaceholderOpenGallery;

  String get recentlyLoggedTitle;

  String get recentlyLoggedSubtitle;

  String get recentlyLoggedEmpty;

  String get viewAll;

  String get delete;

  String get cancel;

  String get deletePhoto;

  String get deletePhotoConfirmation;

  String get photoDeletedSuccessfully;

  String get analyzeFood;

  String get shareFunctionality;

  String get aiFoodAnalysis;

  String get permissionCameraRequired;

  String get inboxTitle;

  String get searchHintText;

  String get filterTitle;

  String get category;

  String get all;

  String get breakfast;

  String get lunch;

  String get dinner;

  String get snack;

  String get calorieRangeLabel;

  String get reset;

  String get mealsListTitle;

  String get noMealsYet;

  String get startByScanningOrPhoto;

  String get deleteMealTooltip;

  String get deleteMealTitle;

  String deleteMealMessage(String foodName);

  String get initializing;

  String get selectedFood;

  String get snackbarSuccessTitle;

  String get snackbarErrorTitle;

  String get snackbarWarningTitle;

  String get snackbarInfoTitle;

  String get foodScannerCantCapturePhoto;

  String get foodScannerCantOpenGallery;

  String get foodScannerNoBarcodeFoundSaving;

  String get foodScannerNoCamera;

  String get foodScannerSavePhotoSuccess;

  String get foodScannerUploadError;

  String get foodScannerSavePhotoError;

  String foodScannerSavedBarcodeNoDetail(Object barcodeValue);

  String get foodScannerCameraNotReady;

  String get foodScannerBarcodeError;

  String foodScannerProductDefaultName(Object barcode);

  String foodScannerScanned(Object foodName);

  String get foodScannerSaveProductError;

  String get mealDeletedSuccessfully;

  String get deleteMealFailed;

  String get sourceTagBotSuggestion;

  String get sourceTagScanned;

  String get sourceTagManual;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
