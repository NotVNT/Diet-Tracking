import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @bottomNavAddFood.
  ///
  /// In en, this message translates to:
  /// **'Add Food'**
  String get bottomNavAddFood;

  /// No description provided for @addFoodPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Food'**
  String get addFoodPageTitle;

  /// No description provided for @addFoodNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Food name'**
  String get addFoodNameLabel;

  /// No description provided for @addFoodCaloriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Calories (kcal)'**
  String get addFoodCaloriesLabel;

  /// No description provided for @addFoodProteinLabel.
  ///
  /// In en, this message translates to:
  /// **'Protein (g)'**
  String get addFoodProteinLabel;

  /// No description provided for @addFoodCarbsLabel.
  ///
  /// In en, this message translates to:
  /// **'Carbs (g)'**
  String get addFoodCarbsLabel;

  /// No description provided for @addFoodFatLabel.
  ///
  /// In en, this message translates to:
  /// **'Fat (g)'**
  String get addFoodFatLabel;

  /// No description provided for @addFoodSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Food'**
  String get addFoodSaveButton;

  /// No description provided for @addFoodEmptyValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter this information'**
  String get addFoodEmptyValidator;

  /// No description provided for @defineYourGoal.
  ///
  /// In en, this message translates to:
  /// **'Define your goal'**
  String get defineYourGoal;

  /// No description provided for @recordSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Food record saved successfully!'**
  String get recordSuccessMessage;

  /// No description provided for @addFoodSuccessNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Food Added Successfully'**
  String get addFoodSuccessNotificationTitle;

  /// No description provided for @addFoodSuccessNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'You have added \'{foodName}\' on {date}.'**
  String addFoodSuccessNotificationBody(String foodName, String date);

  /// No description provided for @weWillBuild.
  ///
  /// In en, this message translates to:
  /// **'We\'ll build a tailored plan to keep you motivated and help you reach your goals.'**
  String get weWillBuild;

  /// No description provided for @getStartedNow.
  ///
  /// In en, this message translates to:
  /// **'Get started!'**
  String get getStartedNow;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Diet Tracking'**
  String get appTitle;

  /// No description provided for @nutrientFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get nutrientFat;

  /// No description provided for @startTrackingToday.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your\ndiet plan today!'**
  String get startTrackingToday;

  /// No description provided for @trackDailyDiet.
  ///
  /// In en, this message translates to:
  /// **'Track your daily diet with\npersonalized meal plans and\nsmart recommendations.'**
  String get trackDailyDiet;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @tellUsAboutYourself.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get tellUsAboutYourself;

  /// No description provided for @weWillCreatePersonalizedPlan.
  ///
  /// In en, this message translates to:
  /// **'We\'ll create a personalized plan for you based on details like your age and current weight.'**
  String get weWillCreatePersonalizedPlan;

  /// No description provided for @chatBotYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get chatBotYesterday;

  /// No description provided for @chatBotConfirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete session?'**
  String get chatBotConfirmDeleteTitle;

  /// Confirmation message for deleting a chat session
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the session \"{sessionTitle}\"?'**
  String chatBotConfirmDeleteMessage(String sessionTitle);

  /// No description provided for @chatBotSessionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Session deleted'**
  String get chatBotSessionDeleted;

  /// No description provided for @chatBotUploadVideo.
  ///
  /// In en, this message translates to:
  /// **'Upload Video'**
  String get chatBotUploadVideo;

  /// No description provided for @chatBotUploadVideoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Analyze food from video'**
  String get chatBotUploadVideoSubtitle;

  /// No description provided for @chatBotAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get chatBotAnalyze;

  /// No description provided for @chatBotCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get chatBotCancel;

  /// No description provided for @chatBotHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No chat history yet'**
  String get chatBotHistoryEmpty;

  /// No description provided for @chatBotStartConversation.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation...'**
  String get chatBotStartConversation;

  /// No description provided for @chatBotEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new conversation'**
  String get chatBotEmptyTitle;

  /// No description provided for @chatBotEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your chat history will be saved here. Ask me anything about your diet plan!'**
  String get chatBotEmptySubtitle;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @weWillUseThisInfo.
  ///
  /// In en, this message translates to:
  /// **'We\'ll use this information to calculate your daily energy needs.'**
  String get weWillUseThisInfo;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @howOldAreYou.
  ///
  /// In en, this message translates to:
  /// **'How old are you?'**
  String get howOldAreYou;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @chooseYourDietStyle.
  ///
  /// In en, this message translates to:
  /// **'Which plan do you prefer?'**
  String get chooseYourDietStyle;

  /// No description provided for @youCanChangeLater.
  ///
  /// In en, this message translates to:
  /// **'You can change this later in Settings.'**
  String get youCanChangeLater;

  /// No description provided for @keto.
  ///
  /// In en, this message translates to:
  /// **'Keto'**
  String get keto;

  /// No description provided for @ketoDescription.
  ///
  /// In en, this message translates to:
  /// **'Very low carb, higher fat.'**
  String get ketoDescription;

  /// No description provided for @normalWeightLoss.
  ///
  /// In en, this message translates to:
  /// **'Normal weight loss'**
  String get normalWeightLoss;

  /// No description provided for @normalWeightLossDescription.
  ///
  /// In en, this message translates to:
  /// **'Balanced carbs, protein, and fat. Easy to maintain.'**
  String get normalWeightLossDescription;

  /// No description provided for @lowCarbs.
  ///
  /// In en, this message translates to:
  /// **'Low Carbs'**
  String get lowCarbs;

  /// No description provided for @lowCarbsDescription.
  ///
  /// In en, this message translates to:
  /// **'Moderately reduced carbs, easier to sustain.'**
  String get lowCarbsDescription;

  /// No description provided for @whatIsYourMainGoal.
  ///
  /// In en, this message translates to:
  /// **'What is your main goal?'**
  String get whatIsYourMainGoal;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @loseWeight.
  ///
  /// In en, this message translates to:
  /// **'Lose weight'**
  String get loseWeight;

  /// No description provided for @maintainWeight.
  ///
  /// In en, this message translates to:
  /// **'Maintain weight'**
  String get maintainWeight;

  /// No description provided for @gainWeight.
  ///
  /// In en, this message translates to:
  /// **'Gain weight'**
  String get gainWeight;

  /// No description provided for @buildMuscle.
  ///
  /// In en, this message translates to:
  /// **'Build muscle'**
  String get buildMuscle;

  /// No description provided for @improveFitness.
  ///
  /// In en, this message translates to:
  /// **'Improve fitness'**
  String get improveFitness;

  /// No description provided for @eatHealthy.
  ///
  /// In en, this message translates to:
  /// **'Eat healthy'**
  String get eatHealthy;

  /// No description provided for @reduceStress.
  ///
  /// In en, this message translates to:
  /// **'Reduce stress'**
  String get reduceStress;

  /// No description provided for @loseBellyFat.
  ///
  /// In en, this message translates to:
  /// **'Lose belly fat'**
  String get loseBellyFat;

  /// No description provided for @whyDoYouWantToLoseWeight.
  ///
  /// In en, this message translates to:
  /// **'Why do you want to lose weight?'**
  String get whyDoYouWantToLoseWeight;

  /// No description provided for @whyDoYouWantToGainWeight.
  ///
  /// In en, this message translates to:
  /// **'Why do you want to gain weight?'**
  String get whyDoYouWantToGainWeight;

  /// No description provided for @whyDoYouWantToMaintainWeight.
  ///
  /// In en, this message translates to:
  /// **'Why do you want to maintain weight?'**
  String get whyDoYouWantToMaintainWeight;

  /// No description provided for @whyDoYouWantToBuildMuscle.
  ///
  /// In en, this message translates to:
  /// **'Why do you want to build muscle?'**
  String get whyDoYouWantToBuildMuscle;

  /// No description provided for @whyDidYouChooseThisGoal.
  ///
  /// In en, this message translates to:
  /// **'Why did you choose this goal?'**
  String get whyDidYouChooseThisGoal;

  /// No description provided for @improveHealth.
  ///
  /// In en, this message translates to:
  /// **'Improve health'**
  String get improveHealth;

  /// No description provided for @feelMoreConfident.
  ///
  /// In en, this message translates to:
  /// **'Feel more confident'**
  String get feelMoreConfident;

  /// No description provided for @increaseConfidence.
  ///
  /// In en, this message translates to:
  /// **'Increase confidence'**
  String get increaseConfidence;

  /// No description provided for @fitIntoClothes.
  ///
  /// In en, this message translates to:
  /// **'Fit into clothes'**
  String get fitIntoClothes;

  /// No description provided for @moreEnergy.
  ///
  /// In en, this message translates to:
  /// **'More energy'**
  String get moreEnergy;

  /// No description provided for @prepareForEvent.
  ///
  /// In en, this message translates to:
  /// **'Prepare for an event'**
  String get prepareForEvent;

  /// No description provided for @reduceVisceralFat.
  ///
  /// In en, this message translates to:
  /// **'Reduce visceral fat'**
  String get reduceVisceralFat;

  /// No description provided for @improvePhysicalFitness.
  ///
  /// In en, this message translates to:
  /// **'Improve physical fitness'**
  String get improvePhysicalFitness;

  /// No description provided for @improveAppearance.
  ///
  /// In en, this message translates to:
  /// **'Improve appearance'**
  String get improveAppearance;

  /// No description provided for @doctorRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Doctor\'s recommendation'**
  String get doctorRecommendation;

  /// No description provided for @healthyLifestyle.
  ///
  /// In en, this message translates to:
  /// **'Healthy lifestyle'**
  String get healthyLifestyle;

  /// No description provided for @buildStrength.
  ///
  /// In en, this message translates to:
  /// **'Build strength'**
  String get buildStrength;

  /// No description provided for @improveAthletics.
  ///
  /// In en, this message translates to:
  /// **'Improve athletics'**
  String get improveAthletics;

  /// No description provided for @lookMoreMuscular.
  ///
  /// In en, this message translates to:
  /// **'Look more muscular'**
  String get lookMoreMuscular;

  /// No description provided for @recoverFromIllness.
  ///
  /// In en, this message translates to:
  /// **'Recover from illness'**
  String get recoverFromIllness;

  /// No description provided for @increaseAppetite.
  ///
  /// In en, this message translates to:
  /// **'Increase appetite'**
  String get increaseAppetite;

  /// No description provided for @stayHealthy.
  ///
  /// In en, this message translates to:
  /// **'Stay healthy'**
  String get stayHealthy;

  /// No description provided for @preventWeightGain.
  ///
  /// In en, this message translates to:
  /// **'Prevent weight gain'**
  String get preventWeightGain;

  /// No description provided for @balancedLifestyle.
  ///
  /// In en, this message translates to:
  /// **'Balanced lifestyle'**
  String get balancedLifestyle;

  /// No description provided for @maintainFitness.
  ///
  /// In en, this message translates to:
  /// **'Maintain fitness'**
  String get maintainFitness;

  /// No description provided for @getStronger.
  ///
  /// In en, this message translates to:
  /// **'Get stronger'**
  String get getStronger;

  /// No description provided for @improveBodyComposition.
  ///
  /// In en, this message translates to:
  /// **'Improve body composition'**
  String get improveBodyComposition;

  /// No description provided for @athleticPerformance.
  ///
  /// In en, this message translates to:
  /// **'Athletic performance'**
  String get athleticPerformance;

  /// No description provided for @lookToned.
  ///
  /// In en, this message translates to:
  /// **'Look toned'**
  String get lookToned;

  /// No description provided for @boostMetabolism.
  ///
  /// In en, this message translates to:
  /// **'Boost metabolism'**
  String get boostMetabolism;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @whatBroughtYouToUs.
  ///
  /// In en, this message translates to:
  /// **'What brought you to us?'**
  String get whatBroughtYouToUs;

  /// No description provided for @findSuitableMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Find a suitable meal plan'**
  String get findSuitableMealPlan;

  /// No description provided for @wantToBuildGoodHabits.
  ///
  /// In en, this message translates to:
  /// **'Want to build good habits'**
  String get wantToBuildGoodHabits;

  /// No description provided for @lackTimeToCook.
  ///
  /// In en, this message translates to:
  /// **'Lack time to cook'**
  String get lackTimeToCook;

  /// No description provided for @improveWorkPerformance.
  ///
  /// In en, this message translates to:
  /// **'Improve work performance'**
  String get improveWorkPerformance;

  /// No description provided for @poorSleep.
  ///
  /// In en, this message translates to:
  /// **'Poor sleep'**
  String get poorSleep;

  /// No description provided for @careAboutHeartHealth.
  ///
  /// In en, this message translates to:
  /// **'Care about heart health'**
  String get careAboutHeartHealth;

  /// No description provided for @poorHealthIndicators.
  ///
  /// In en, this message translates to:
  /// **'Poor health indicators'**
  String get poorHealthIndicators;

  /// No description provided for @optimizeMealCosts.
  ///
  /// In en, this message translates to:
  /// **'Optimize meal costs'**
  String get optimizeMealCosts;

  /// No description provided for @weBringYouBestResults.
  ///
  /// In en, this message translates to:
  /// **'We bring you the best results'**
  String get weBringYouBestResults;

  /// No description provided for @personalizedPathwayBasedOnGoals.
  ///
  /// In en, this message translates to:
  /// **'Personalized pathway based on your goals and habits. Start now to see sustainable change.'**
  String get personalizedPathwayBasedOnGoals;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @whatIsYourHeight.
  ///
  /// In en, this message translates to:
  /// **'What is your height?'**
  String get whatIsYourHeight;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @whatIsYourWeight.
  ///
  /// In en, this message translates to:
  /// **'What is your weight?'**
  String get whatIsYourWeight;

  /// No description provided for @goalWeight.
  ///
  /// In en, this message translates to:
  /// **'Goal Weight'**
  String get goalWeight;

  /// No description provided for @whatIsYourGoalWeight.
  ///
  /// In en, this message translates to:
  /// **'What weight do you want to achieve?'**
  String get whatIsYourGoalWeight;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @youCanDoIt.
  ///
  /// In en, this message translates to:
  /// **'You can do it!'**
  String get youCanDoIt;

  /// No description provided for @maintainCurrentWeightIsHealthy.
  ///
  /// In en, this message translates to:
  /// **'Maintaining your current weight is a healthy choice'**
  String get maintainCurrentWeightIsHealthy;

  /// No description provided for @loseWeightGoalPrefix.
  ///
  /// In en, this message translates to:
  /// **'Losing'**
  String get loseWeightGoalPrefix;

  /// No description provided for @loseWeightGoalSuffix.
  ///
  /// In en, this message translates to:
  /// **'kg is a challenging but completely achievable goal'**
  String get loseWeightGoalSuffix;

  /// No description provided for @gainWeightGoalPrefix.
  ///
  /// In en, this message translates to:
  /// **'Gaining'**
  String get gainWeightGoalPrefix;

  /// No description provided for @gainWeightGoalSuffix.
  ///
  /// In en, this message translates to:
  /// **'kg will help you achieve better balance'**
  String get gainWeightGoalSuffix;

  /// No description provided for @setClearGoalsMessage.
  ///
  /// In en, this message translates to:
  /// **'Setting clear goals helps you get closer every day'**
  String get setClearGoalsMessage;

  /// No description provided for @goalWeightPrefix.
  ///
  /// In en, this message translates to:
  /// **'Goal weight'**
  String get goalWeightPrefix;

  /// No description provided for @userProgressMessage.
  ///
  /// In en, this message translates to:
  /// **'users report clear progress after 4 weeks on the plan'**
  String get userProgressMessage;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @signUpAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign Up Account'**
  String get signUpAccount;

  /// No description provided for @chooseYourLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseYourLanguage;

  /// No description provided for @languageChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully!'**
  String get languageChangedSuccessfully;

  /// No description provided for @languageChangedToVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Language changed to Vietnamese'**
  String get languageChangedToVietnamese;

  /// No description provided for @languageChangedToEnglish.
  ///
  /// In en, this message translates to:
  /// **'Language changed to English'**
  String get languageChangedToEnglish;

  /// No description provided for @bmiCurrentTitle.
  ///
  /// In en, this message translates to:
  /// **'Current BMI'**
  String get bmiCurrentTitle;

  /// No description provided for @bmiEnterHeightToCalculate.
  ///
  /// In en, this message translates to:
  /// **'Please enter height to calculate BMI.'**
  String get bmiEnterHeightToCalculate;

  /// No description provided for @bmiUnderweight.
  ///
  /// In en, this message translates to:
  /// **'You are underweight.'**
  String get bmiUnderweight;

  /// No description provided for @bmiNormal.
  ///
  /// In en, this message translates to:
  /// **'You have a normal weight.'**
  String get bmiNormal;

  /// No description provided for @bmiOverweight.
  ///
  /// In en, this message translates to:
  /// **'You are overweight.'**
  String get bmiOverweight;

  /// No description provided for @bmiObese.
  ///
  /// In en, this message translates to:
  /// **'You need to lose weight seriously to protect your health.'**
  String get bmiObese;

  /// No description provided for @activityLevelSedentaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get activityLevelSedentaryTitle;

  /// No description provided for @activityLevelSedentarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'(Mostly sitting, little or no exercise)'**
  String get activityLevelSedentarySubtitle;

  /// No description provided for @activityLevelLightlyActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Lightly active'**
  String get activityLevelLightlyActiveTitle;

  /// No description provided for @activityLevelLightlyActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'(Exercise/sports 1-3 days/week)'**
  String get activityLevelLightlyActiveSubtitle;

  /// No description provided for @activityLevelModeratelyActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Moderately active'**
  String get activityLevelModeratelyActiveTitle;

  /// No description provided for @activityLevelModeratelyActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'(Exercise/sports 3-5 days/week)'**
  String get activityLevelModeratelyActiveSubtitle;

  /// No description provided for @dateRangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get dateRangeTitle;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'Custom range'**
  String get customRange;

  /// No description provided for @activityLevelVeryActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Very active'**
  String get activityLevelVeryActiveTitle;

  /// No description provided for @activityLevelVeryActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'(Exercise/sports 6-7 days/week)'**
  String get activityLevelVeryActiveSubtitle;

  /// No description provided for @activityLevelExtraActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Extra active'**
  String get activityLevelExtraActiveTitle;

  /// No description provided for @activityLevelExtraActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'(Exercise twice a day, manual labor)'**
  String get activityLevelExtraActiveSubtitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @emailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email or Phone Number'**
  String get emailOrPhone;

  /// No description provided for @emailOrPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Email or Phone Number'**
  String get emailOrPhoneHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @orLoginWith.
  ///
  /// In en, this message translates to:
  /// **'OR login with'**
  String get orLoginWith;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I don\'t have an account'**
  String get dontHaveAccount;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get pleaseEnterPassword;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your information.'**
  String get loginFailed;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect. Please try again.'**
  String get invalidCredentials;

  /// No description provided for @googleLoginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Google login successful!'**
  String get googleLoginSuccess;

  /// No description provided for @googleLoginCancelled.
  ///
  /// In en, this message translates to:
  /// **'Google login cancelled.'**
  String get googleLoginCancelled;

  /// No description provided for @googleLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Google login failed. Please try again.'**
  String get googleLoginFailed;

  /// No description provided for @passwordResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent. Please check your inbox.'**
  String get passwordResetEmailSent;

  /// No description provided for @pleaseEnterEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter email first.'**
  String get pleaseEnterEmailFirst;

  /// No description provided for @passwordResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to send password reset email. Please check your email and try again.'**
  String get passwordResetFailed;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signupTitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullNameHint;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get phoneNumberHint;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'example@gmail.com'**
  String get emailHint;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get confirmPasswordHint;

  /// No description provided for @agreeWith.
  ///
  /// In en, this message translates to:
  /// **'I agree with '**
  String get agreeWith;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @signupButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signupButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @loginLink.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginLink;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordInstruction.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you instructions to reset your password.'**
  String get forgotPasswordInstruction;

  /// No description provided for @sendResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Email'**
  String get sendResetEmail;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email.'**
  String get invalidEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter email.'**
  String get pleaseEnterValidEmail;

  /// No description provided for @emailNotExist.
  ///
  /// In en, this message translates to:
  /// **'Email does not exist in the system.'**
  String get emailNotExist;

  /// No description provided for @accountUsesProviderMessage.
  ///
  /// In en, this message translates to:
  /// **'This account uses: {provider}. Cannot reset password via email.'**
  String accountUsesProviderMessage(Object provider);

  /// No description provided for @unableToSendResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Unable to send password reset email. Please try again later.'**
  String get unableToSendResetEmail;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email.'**
  String get userNotFound;

  /// No description provided for @tooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please try again later.'**
  String get tooManyRequests;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection and try again.'**
  String get networkError;

  /// No description provided for @pleaseEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name.'**
  String get pleaseEnterFullName;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number.'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get passwordMinLength;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm password.'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @pleaseAgreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'Please agree to the terms of service.'**
  String get pleaseAgreeToTerms;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'Email is already in use. Please use a different email.'**
  String get emailAlreadyInUse;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak. Please use a stronger password.'**
  String get weakPassword;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get registrationFailed;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get registrationSuccess;

  /// No description provided for @chatBotDietAssistant.
  ///
  /// In en, this message translates to:
  /// **'Diet Assistant'**
  String get chatBotDietAssistant;

  /// No description provided for @chatBotNewChatCreated.
  ///
  /// In en, this message translates to:
  /// **'New conversation created'**
  String get chatBotNewChatCreated;

  /// No description provided for @chatBotChatHistoryComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Chat history feature will be added later'**
  String get chatBotChatHistoryComingSoon;

  /// No description provided for @chatBotSettingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Settings feature will be added later'**
  String get chatBotSettingsComingSoon;

  /// No description provided for @chatBotPleaseEnterAllInfo.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all information'**
  String get chatBotPleaseEnterAllInfo;

  /// No description provided for @chatBotCreateNewChat.
  ///
  /// In en, this message translates to:
  /// **'Create new chat'**
  String get chatBotCreateNewChat;

  /// No description provided for @chatBotStartNewConversation.
  ///
  /// In en, this message translates to:
  /// **'Start a new conversation'**
  String get chatBotStartNewConversation;

  /// No description provided for @chatBotChatHistory.
  ///
  /// In en, this message translates to:
  /// **'Chat history'**
  String get chatBotChatHistory;

  /// No description provided for @chatBotViewPreviousConversations.
  ///
  /// In en, this message translates to:
  /// **'View previous conversations'**
  String get chatBotViewPreviousConversations;

  /// No description provided for @chatBotSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get chatBotSettings;

  /// No description provided for @chatBotCustomizeApp.
  ///
  /// In en, this message translates to:
  /// **'Customize app'**
  String get chatBotCustomizeApp;

  /// No description provided for @chatBotEnterMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter message...'**
  String get chatBotEnterMessage;

  /// No description provided for @chatBotFoodSuggestion.
  ///
  /// In en, this message translates to:
  /// **'food suggestion'**
  String get chatBotFoodSuggestion;

  /// No description provided for @chatBotEnterIngredients.
  ///
  /// In en, this message translates to:
  /// **'Enter available ingredients'**
  String get chatBotEnterIngredients;

  /// No description provided for @chatBotEnterBudget.
  ///
  /// In en, this message translates to:
  /// **'Enter desired meal budget'**
  String get chatBotEnterBudget;

  /// No description provided for @chatBotEnterMealType.
  ///
  /// In en, this message translates to:
  /// **'Breakfast, Lunch, Dinner, Snack, Full day menu'**
  String get chatBotEnterMealType;

  /// No description provided for @chatBotSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get chatBotSubmit;

  /// No description provided for @chatBotJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get chatBotJustNow;

  /// No description provided for @chatBotMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes ago'**
  String chatBotMinutesAgo(int minutes);

  /// No description provided for @chatBotHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String chatBotHoursAgo(int hours);

  /// No description provided for @chatBotSaveAll.
  ///
  /// In en, this message translates to:
  /// **'Save all'**
  String get chatBotSaveAll;

  /// No description provided for @chatBotSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get chatBotSave;

  /// No description provided for @chatBotAddedAllToList.
  ///
  /// In en, this message translates to:
  /// **'Added {count} dishes to list'**
  String chatBotAddedAllToList(int count);

  /// No description provided for @chatBotAddedToList.
  ///
  /// In en, this message translates to:
  /// **'Added \"{name}\" to list'**
  String chatBotAddedToList(String name);

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get profileUser;

  /// No description provided for @profileAvatarUpdated.
  ///
  /// In en, this message translates to:
  /// **'Avatar updated'**
  String get profileAvatarUpdated;

  /// No description provided for @profileCannotUpdateAvatar.
  ///
  /// In en, this message translates to:
  /// **'Cannot update avatar'**
  String get profileCannotUpdateAvatar;

  /// No description provided for @profileSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get profileSignedOut;

  /// No description provided for @profileCannotSignOut.
  ///
  /// In en, this message translates to:
  /// **'Cannot sign out'**
  String get profileCannotSignOut;

  /// No description provided for @profileEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditProfile;

  /// No description provided for @profileViewStatistics.
  ///
  /// In en, this message translates to:
  /// **'View statistics'**
  String get profileViewStatistics;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profileDataAndSync.
  ///
  /// In en, this message translates to:
  /// **'Data and sync'**
  String get profileDataAndSync;

  /// No description provided for @profileSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get profileSupport;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOut;

  /// No description provided for @profileSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get profileSignIn;

  /// No description provided for @profileFeatureInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Feature in development'**
  String get profileFeatureInDevelopment;

  /// No description provided for @profileAppName.
  ///
  /// In en, this message translates to:
  /// **'VGP'**
  String get profileAppName;

  /// No description provided for @profileAppDescription.
  ///
  /// In en, this message translates to:
  /// **'Smart diet management app'**
  String get profileAppDescription;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTitle;

  /// No description provided for @editProfileSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get editProfileSave;

  /// No description provided for @editProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get editProfileUpdated;

  /// No description provided for @editProfileError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get editProfileError;

  /// No description provided for @editProfilePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get editProfilePersonalInfo;

  /// No description provided for @editProfileFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get editProfileFullName;

  /// No description provided for @editProfilePleaseEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter full name'**
  String get editProfilePleaseEnterFullName;

  /// No description provided for @editProfileAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get editProfileAge;

  /// No description provided for @editProfilePleaseEnterAge.
  ///
  /// In en, this message translates to:
  /// **'Please enter age'**
  String get editProfilePleaseEnterAge;

  /// No description provided for @editProfileInvalidAge.
  ///
  /// In en, this message translates to:
  /// **'Invalid age'**
  String get editProfileInvalidAge;

  /// No description provided for @editProfileGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get editProfileGender;

  /// No description provided for @editProfileMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get editProfileMale;

  /// No description provided for @editProfileFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get editProfileFemale;

  /// No description provided for @editProfileBodyMetrics.
  ///
  /// In en, this message translates to:
  /// **'Body metrics'**
  String get editProfileBodyMetrics;

  /// No description provided for @editProfileHeight.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get editProfileHeight;

  /// No description provided for @editProfileInvalidHeight.
  ///
  /// In en, this message translates to:
  /// **'Invalid height'**
  String get editProfileInvalidHeight;

  /// No description provided for @editProfileWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get editProfileWeight;

  /// No description provided for @editProfileInvalidWeight.
  ///
  /// In en, this message translates to:
  /// **'Invalid weight'**
  String get editProfileInvalidWeight;

  /// No description provided for @editProfileGoalWeight.
  ///
  /// In en, this message translates to:
  /// **'Goal weight (kg)'**
  String get editProfileGoalWeight;

  /// No description provided for @editProfileInvalidGoalWeight.
  ///
  /// In en, this message translates to:
  /// **'Invalid goal weight'**
  String get editProfileInvalidGoalWeight;

  /// No description provided for @editProfileYourGoal.
  ///
  /// In en, this message translates to:
  /// **'Your goal'**
  String get editProfileYourGoal;

  /// No description provided for @editProfileSelectGoal.
  ///
  /// In en, this message translates to:
  /// **'Select goal'**
  String get editProfileSelectGoal;

  /// No description provided for @editProfileGoalLoseWeight.
  ///
  /// In en, this message translates to:
  /// **'Lose weight'**
  String get editProfileGoalLoseWeight;

  /// No description provided for @editProfileGoalGainWeight.
  ///
  /// In en, this message translates to:
  /// **'Gain weight'**
  String get editProfileGoalGainWeight;

  /// No description provided for @editProfileGoalMaintainWeight.
  ///
  /// In en, this message translates to:
  /// **'Maintain weight'**
  String get editProfileGoalMaintainWeight;

  /// No description provided for @editProfileGoalBuildMuscle.
  ///
  /// In en, this message translates to:
  /// **'Build muscle'**
  String get editProfileGoalBuildMuscle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotificationTitle;

  /// No description provided for @settingsNotificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications about meals and goals'**
  String get settingsNotificationSubtitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsDarkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use dark theme'**
  String get settingsDarkModeSubtitle;

  /// No description provided for @settingsDarkModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Switched to dark mode'**
  String get settingsDarkModeEnabled;

  /// No description provided for @settingsDarkModeDisabled.
  ///
  /// In en, this message translates to:
  /// **'Switched to light mode'**
  String get settingsDarkModeDisabled;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsUnits.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get settingsUnits;

  /// No description provided for @settingsUnitSystem.
  ///
  /// In en, this message translates to:
  /// **'Unit system'**
  String get settingsUnitSystem;

  /// No description provided for @dataSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Data & Sync'**
  String get dataSyncTitle;

  /// No description provided for @dataSyncAutoSync.
  ///
  /// In en, this message translates to:
  /// **'Auto sync'**
  String get dataSyncAutoSync;

  /// No description provided for @dataSyncAutoSyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sync data automatically with cloud'**
  String get dataSyncAutoSyncSubtitle;

  /// No description provided for @dataSyncBackupData.
  ///
  /// In en, this message translates to:
  /// **'Backup data'**
  String get dataSyncBackupData;

  /// No description provided for @dataSyncBackupDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Backup your data'**
  String get dataSyncBackupDataSubtitle;

  /// No description provided for @dataSyncBackupDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup data'**
  String get dataSyncBackupDialogTitle;

  /// No description provided for @dataSyncBackupDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to backup your data to the cloud?'**
  String get dataSyncBackupDialogMessage;

  /// No description provided for @dataSyncBackupDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dataSyncBackupDialogCancel;

  /// No description provided for @dataSyncBackupDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get dataSyncBackupDialogConfirm;

  /// No description provided for @dataSyncBackupInProgress.
  ///
  /// In en, this message translates to:
  /// **'Backing up data...'**
  String get dataSyncBackupInProgress;

  /// No description provided for @dataSyncClearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get dataSyncClearCache;

  /// No description provided for @dataSyncClearCacheSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clear temporary data'**
  String get dataSyncClearCacheSubtitle;

  /// No description provided for @dataSyncClearCacheDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get dataSyncClearCacheDialogTitle;

  /// No description provided for @dataSyncClearCacheDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Clearing cache will free up storage but may slow down the app on next launch. Are you sure you want to clear?'**
  String get dataSyncClearCacheDialogMessage;

  /// No description provided for @dataSyncClearCacheDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dataSyncClearCacheDialogCancel;

  /// No description provided for @dataSyncClearCacheDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get dataSyncClearCacheDialogConfirm;

  /// No description provided for @dataSyncClearCacheSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get dataSyncClearCacheSuccess;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportTitle;

  /// No description provided for @supportPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get supportPrivacyPolicy;

  /// No description provided for @supportOpeningPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Opening privacy policy...'**
  String get supportOpeningPrivacyPolicy;

  /// No description provided for @supportTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get supportTermsOfService;

  /// No description provided for @supportOpeningTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Opening terms of service...'**
  String get supportOpeningTermsOfService;

  /// No description provided for @supportRecommendationSources.
  ///
  /// In en, this message translates to:
  /// **'Recommendation sources'**
  String get supportRecommendationSources;

  /// No description provided for @supportOpeningRecommendationSources.
  ///
  /// In en, this message translates to:
  /// **'Opening recommendation sources...'**
  String get supportOpeningRecommendationSources;

  /// No description provided for @supportFindVGPOnSocialMedia.
  ///
  /// In en, this message translates to:
  /// **'Find VGP on social media'**
  String get supportFindVGPOnSocialMedia;

  /// No description provided for @supportTiktok.
  ///
  /// In en, this message translates to:
  /// **'Tiktok'**
  String get supportTiktok;

  /// No description provided for @supportOpeningTiktok.
  ///
  /// In en, this message translates to:
  /// **'Opening TikTok...'**
  String get supportOpeningTiktok;

  /// No description provided for @supportFacebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get supportFacebook;

  /// No description provided for @supportOpeningFacebook.
  ///
  /// In en, this message translates to:
  /// **'Opening Facebook...'**
  String get supportOpeningFacebook;

  /// No description provided for @supportInstagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get supportInstagram;

  /// No description provided for @supportOpeningInstagram.
  ///
  /// In en, this message translates to:
  /// **'Opening Instagram...'**
  String get supportOpeningInstagram;

  /// No description provided for @supportHelpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help center'**
  String get supportHelpCenter;

  /// No description provided for @supportAlwaysHereToHelp.
  ///
  /// In en, this message translates to:
  /// **'We are always here to help'**
  String get supportAlwaysHereToHelp;

  /// No description provided for @helpCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Help center'**
  String get helpCenterTitle;

  /// No description provided for @helpCenterWeAreReadyToHelp.
  ///
  /// In en, this message translates to:
  /// **'We are ready to help'**
  String get helpCenterWeAreReadyToHelp;

  /// No description provided for @helpCenterFindAnswersOrContact.
  ///
  /// In en, this message translates to:
  /// **'Find answers or contact the team'**
  String get helpCenterFindAnswersOrContact;

  /// No description provided for @helpCenterFAQ.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get helpCenterFAQ;

  /// No description provided for @helpCenterContactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get helpCenterContactUs;

  /// No description provided for @helpCenterFAQ1Question.
  ///
  /// In en, this message translates to:
  /// **'How to track nutrition?'**
  String get helpCenterFAQ1Question;

  /// No description provided for @helpCenterFAQ1Answer.
  ///
  /// In en, this message translates to:
  /// **'You can add food to your daily meal diary. The app will automatically calculate nutrition for you.'**
  String get helpCenterFAQ1Answer;

  /// No description provided for @helpCenterFAQ2Question.
  ///
  /// In en, this message translates to:
  /// **'Can I set calorie goals?'**
  String get helpCenterFAQ2Question;

  /// No description provided for @helpCenterFAQ2Answer.
  ///
  /// In en, this message translates to:
  /// **'Yes, you can set calorie goals and other nutrition metrics in the Goal Settings section.'**
  String get helpCenterFAQ2Answer;

  /// No description provided for @helpCenterFAQ3Question.
  ///
  /// In en, this message translates to:
  /// **'How to create a menu?'**
  String get helpCenterFAQ3Question;

  /// No description provided for @helpCenterFAQ3Answer.
  ///
  /// In en, this message translates to:
  /// **'Go to the Menu section, select \"Create new\" and add the dishes you want. The app will automatically calculate nutrition.'**
  String get helpCenterFAQ3Answer;

  /// No description provided for @helpCenterFAQ4Question.
  ///
  /// In en, this message translates to:
  /// **'Is my data synchronized?'**
  String get helpCenterFAQ4Question;

  /// No description provided for @helpCenterFAQ4Answer.
  ///
  /// In en, this message translates to:
  /// **'Yes, data is automatically synchronized with cloud if you are logged in to an account.'**
  String get helpCenterFAQ4Answer;

  /// No description provided for @helpCenterFAQ5Question.
  ///
  /// In en, this message translates to:
  /// **'How to export reports?'**
  String get helpCenterFAQ5Question;

  /// No description provided for @helpCenterFAQ5Answer.
  ///
  /// In en, this message translates to:
  /// **'Go to the Report section, select a time period and press the \"Export PDF\" button to download the report to your device.'**
  String get helpCenterFAQ5Answer;

  /// No description provided for @helpCenterContactEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get helpCenterContactEmail;

  /// No description provided for @helpCenterContactEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'support@vgp.com'**
  String get helpCenterContactEmailAddress;

  /// No description provided for @helpCenterContactPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get helpCenterContactPhone;

  /// No description provided for @helpCenterContactPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'+84 123 456 789'**
  String get helpCenterContactPhoneNumber;

  /// No description provided for @helpCenterContactAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get helpCenterContactAddress;

  /// No description provided for @helpCenterContactAddressValue.
  ///
  /// In en, this message translates to:
  /// **'123 Main Street, District 1, Ho Chi Minh City'**
  String get helpCenterContactAddressValue;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @bottomNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get bottomNavHome;

  /// No description provided for @bottomNavRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get bottomNavRecord;

  /// No description provided for @bottomNavChatBot.
  ///
  /// In en, this message translates to:
  /// **'Chat bot'**
  String get bottomNavChatBot;

  /// No description provided for @bottomNavProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get bottomNavProfile;

  /// No description provided for @bottomNavScanFood.
  ///
  /// In en, this message translates to:
  /// **'Scan food'**
  String get bottomNavScanFood;

  /// No description provided for @bottomNavReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get bottomNavReport;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchHint;

  /// No description provided for @calorieCardBurnedToday.
  ///
  /// In en, this message translates to:
  /// **'Your calories burned today'**
  String get calorieCardBurnedToday;

  /// No description provided for @nutrientProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get nutrientProtein;

  /// No description provided for @nutrientFiber.
  ///
  /// In en, this message translates to:
  /// **'Fiber'**
  String get nutrientFiber;

  /// No description provided for @nutrientCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get nutrientCarbs;

  /// No description provided for @calorieCardCaloriesTaken.
  ///
  /// In en, this message translates to:
  /// **'Calories taken'**
  String get calorieCardCaloriesTaken;

  /// No description provided for @calorieCardViewReport.
  ///
  /// In en, this message translates to:
  /// **'View report'**
  String get calorieCardViewReport;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationTitle;

  /// No description provided for @waterReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Water Reminder'**
  String get waterReminderTitle;

  /// No description provided for @waterReminderMessage.
  ///
  /// In en, this message translates to:
  /// **'Drink enough water every day to keep your body healthy and energized!'**
  String get waterReminderMessage;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @recordPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Record Meals'**
  String get recordPageTitle;

  /// No description provided for @recordedMealsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recorded Meals'**
  String get recordedMealsTitle;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @noMealsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No meals recorded yet'**
  String get noMealsRecorded;

  /// No description provided for @addFirstMeal.
  ///
  /// In en, this message translates to:
  /// **'Add your first meal!'**
  String get addFirstMeal;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'calories'**
  String get calories;

  /// No description provided for @nutritionInfo.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Information'**
  String get nutritionInfo;

  /// No description provided for @foodScannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Food scanner'**
  String get foodScannerTitle;

  /// No description provided for @foodScannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Align the product inside the frame'**
  String get foodScannerSubtitle;

  /// No description provided for @foodScannerOverlayAutoDetect.
  ///
  /// In en, this message translates to:
  /// **'Auto detecting...'**
  String get foodScannerOverlayAutoDetect;

  /// No description provided for @foodScannerOverlayBarcodeHint.
  ///
  /// In en, this message translates to:
  /// **'Align barcode inside the frame'**
  String get foodScannerOverlayBarcodeHint;

  /// No description provided for @foodScannerActionFood.
  ///
  /// In en, this message translates to:
  /// **'Scan food'**
  String get foodScannerActionFood;

  /// No description provided for @foodScannerActionBarcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get foodScannerActionBarcode;

  /// No description provided for @foodScannerActionGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get foodScannerActionGallery;

  /// No description provided for @foodScannerHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'How to scan'**
  String get foodScannerHelpTitle;

  /// No description provided for @foodScannerHelpTip1.
  ///
  /// In en, this message translates to:
  /// **'Place the meal fully inside the frame.'**
  String get foodScannerHelpTip1;

  /// No description provided for @foodScannerHelpTip2.
  ///
  /// In en, this message translates to:
  /// **'Use the Barcode mode for packaged products.'**
  String get foodScannerHelpTip2;

  /// No description provided for @foodScannerHelpTip3.
  ///
  /// In en, this message translates to:
  /// **'Pick from Gallery to reuse saved photos.'**
  String get foodScannerHelpTip3;

  /// No description provided for @foodScannerGalleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick from gallery'**
  String get foodScannerGalleryTitle;

  /// No description provided for @foodScannerGallerySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a previously captured meal photo.'**
  String get foodScannerGallerySubtitle;

  /// No description provided for @foodScannerGalleryButton.
  ///
  /// In en, this message translates to:
  /// **'Open gallery'**
  String get foodScannerGalleryButton;

  /// No description provided for @foodScannerPlaceholderCaptureFood.
  ///
  /// In en, this message translates to:
  /// **'Capturing food photo (coming soon)'**
  String get foodScannerPlaceholderCaptureFood;

  /// No description provided for @foodScannerPlaceholderScanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scanning barcode (coming soon)'**
  String get foodScannerPlaceholderScanBarcode;

  /// No description provided for @foodScannerPlaceholderOpenGallery.
  ///
  /// In en, this message translates to:
  /// **'Opening gallery (coming soon)'**
  String get foodScannerPlaceholderOpenGallery;

  /// No description provided for @recentlyLoggedTitle.
  ///
  /// In en, this message translates to:
  /// **'Recently logged'**
  String get recentlyLoggedTitle;

  /// No description provided for @recentlyLoggedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your meals by taking a quick picture'**
  String get recentlyLoggedSubtitle;

  /// No description provided for @recentlyLoggedEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t uploaded any food'**
  String get recentlyLoggedEmpty;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deletePhoto.
  ///
  /// In en, this message translates to:
  /// **'Delete Photo'**
  String get deletePhoto;

  /// No description provided for @deletePhotoConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this photo?'**
  String get deletePhotoConfirmation;

  /// No description provided for @photoDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get photoDeletedSuccessfully;

  /// No description provided for @analyzeFood.
  ///
  /// In en, this message translates to:
  /// **'Analyze Food'**
  String get analyzeFood;

  /// No description provided for @shareFunctionality.
  ///
  /// In en, this message translates to:
  /// **'Share functionality coming soon'**
  String get shareFunctionality;

  /// No description provided for @aiFoodAnalysis.
  ///
  /// In en, this message translates to:
  /// **'AI food analysis coming soon'**
  String get aiFoodAnalysis;

  /// No description provided for @permissionCameraRequired.
  ///
  /// In en, this message translates to:
  /// **'Please grant camera access to use this feature.'**
  String get permissionCameraRequired;

  /// No description provided for @inboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get inboxTitle;

  /// No description provided for @searchHintText.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchHintText;

  /// No description provided for @filterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterTitle;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// No description provided for @calorieRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Calorie range'**
  String get calorieRangeLabel;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @mealsListTitle.
  ///
  /// In en, this message translates to:
  /// **'Meals list'**
  String get mealsListTitle;

  /// No description provided for @noMealsYet.
  ///
  /// In en, this message translates to:
  /// **'No meals yet'**
  String get noMealsYet;

  /// No description provided for @startByScanningOrPhoto.
  ///
  /// In en, this message translates to:
  /// **'Scan a barcode or take a photo to get started'**
  String get startByScanningOrPhoto;

  /// No description provided for @deleteMealTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete meal'**
  String get deleteMealTooltip;

  /// No description provided for @deleteMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete meal?'**
  String get deleteMealTitle;

  /// No description provided for @deleteMealMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{foodName}\" from records?'**
  String deleteMealMessage(String foodName);

  /// No description provided for @initializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get initializing;

  /// No description provided for @selectedFood.
  ///
  /// In en, this message translates to:
  /// **'Selected Food'**
  String get selectedFood;

  /// No description provided for @snackbarSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get snackbarSuccessTitle;

  /// No description provided for @snackbarErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get snackbarErrorTitle;

  /// No description provided for @snackbarWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get snackbarWarningTitle;

  /// No description provided for @snackbarInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get snackbarInfoTitle;

  /// No description provided for @foodScannerCantCapturePhoto.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t capture photo, please try again.'**
  String get foodScannerCantCapturePhoto;

  /// No description provided for @foodScannerCantOpenGallery.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open gallery, please try again.'**
  String get foodScannerCantOpenGallery;

  /// No description provided for @foodScannerNoBarcodeFoundSaving.
  ///
  /// In en, this message translates to:
  /// **'No barcode found in image. Saving photo...'**
  String get foodScannerNoBarcodeFoundSaving;

  /// No description provided for @foodScannerNoCamera.
  ///
  /// In en, this message translates to:
  /// **'No camera found on device.'**
  String get foodScannerNoCamera;

  /// No description provided for @foodScannerSavePhotoSuccess.
  ///
  /// In en, this message translates to:
  /// **'Photo saved successfully'**
  String get foodScannerSavePhotoSuccess;

  /// No description provided for @foodScannerUploadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t upload photo to Cloudinary. Please try again.'**
  String get foodScannerUploadError;

  /// No description provided for @foodScannerSavePhotoError.
  ///
  /// In en, this message translates to:
  /// **'Saved photo (error looking up info)'**
  String get foodScannerSavePhotoError;

  /// No description provided for @foodScannerSavedBarcodeNoDetail.
  ///
  /// In en, this message translates to:
  /// **'Saved code: {barcodeValue} (Details not found)'**
  String foodScannerSavedBarcodeNoDetail(Object barcodeValue);

  /// No description provided for @foodScannerCameraNotReady.
  ///
  /// In en, this message translates to:
  /// **'Camera not ready'**
  String get foodScannerCameraNotReady;

  /// No description provided for @foodScannerBarcodeError.
  ///
  /// In en, this message translates to:
  /// **'Error scanning barcode'**
  String get foodScannerBarcodeError;

  /// No description provided for @foodScannerProductDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Product {barcode}'**
  String foodScannerProductDefaultName(Object barcode);

  /// No description provided for @foodScannerScanned.
  ///
  /// In en, this message translates to:
  /// **'Scanned: {foodName}'**
  String foodScannerScanned(Object foodName);

  /// No description provided for @foodScannerSaveProductError.
  ///
  /// In en, this message translates to:
  /// **'Error saving product'**
  String get foodScannerSaveProductError;

  /// No description provided for @mealDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Meal deleted successfully'**
  String get mealDeletedSuccessfully;

  /// No description provided for @deleteMealFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete meal'**
  String get deleteMealFailed;

  /// No description provided for @sourceTagBotSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Chatbot suggestion'**
  String get sourceTagBotSuggestion;

  /// No description provided for @sourceTagScanned.
  ///
  /// In en, this message translates to:
  /// **'From scan/photo'**
  String get sourceTagScanned;

  /// No description provided for @sourceTagManual.
  ///
  /// In en, this message translates to:
  /// **'Manual input'**
  String get sourceTagManual;

  /// No description provided for @foodAllergiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Food Allergies'**
  String get foodAllergiesTitle;

  /// No description provided for @foodAllergiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please provide information about your food allergies so we can best assist you'**
  String get foodAllergiesSubtitle;

  /// No description provided for @foodAllergiesHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: Seafood...'**
  String get foodAllergiesHint;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @noAllergiesAdded.
  ///
  /// In en, this message translates to:
  /// **'No allergies added yet'**
  String get noAllergiesAdded;

  /// No description provided for @allergySeafood.
  ///
  /// In en, this message translates to:
  /// **'Seafood'**
  String get allergySeafood;

  /// No description provided for @allergyMilk.
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get allergyMilk;

  /// No description provided for @allergyPeanuts.
  ///
  /// In en, this message translates to:
  /// **'Peanuts'**
  String get allergyPeanuts;

  /// No description provided for @allergyEggs.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get allergyEggs;

  /// No description provided for @allergyWheat.
  ///
  /// In en, this message translates to:
  /// **'Wheat'**
  String get allergyWheat;

  /// No description provided for @allergySoy.
  ///
  /// In en, this message translates to:
  /// **'Soy'**
  String get allergySoy;

  /// No description provided for @allergyFish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get allergyFish;

  /// No description provided for @allergyNuts.
  ///
  /// In en, this message translates to:
  /// **'Nuts'**
  String get allergyNuts;

  /// No description provided for @allergyShrimp.
  ///
  /// In en, this message translates to:
  /// **'Shrimp'**
  String get allergyShrimp;

  /// No description provided for @allergyCrab.
  ///
  /// In en, this message translates to:
  /// **'Crab'**
  String get allergyCrab;

  /// No description provided for @allergyBeef.
  ///
  /// In en, this message translates to:
  /// **'Beef'**
  String get allergyBeef;

  /// No description provided for @allergyChicken.
  ///
  /// In en, this message translates to:
  /// **'Chicken'**
  String get allergyChicken;

  /// No description provided for @allergySesame.
  ///
  /// In en, this message translates to:
  /// **'Sesame'**
  String get allergySesame;

  /// No description provided for @allergyScallops.
  ///
  /// In en, this message translates to:
  /// **'Scallops'**
  String get allergyScallops;

  /// No description provided for @allergySnails.
  ///
  /// In en, this message translates to:
  /// **'Snails'**
  String get allergySnails;

  /// No description provided for @allergyGluten.
  ///
  /// In en, this message translates to:
  /// **'Gluten'**
  String get allergyGluten;

  /// No description provided for @allergyLactose.
  ///
  /// In en, this message translates to:
  /// **'Lactose'**
  String get allergyLactose;

  /// No description provided for @allergyHoney.
  ///
  /// In en, this message translates to:
  /// **'Honey'**
  String get allergyHoney;

  /// No description provided for @allergyStrawberry.
  ///
  /// In en, this message translates to:
  /// **'Strawberry'**
  String get allergyStrawberry;

  /// No description provided for @allergyKiwi.
  ///
  /// In en, this message translates to:
  /// **'Kiwi'**
  String get allergyKiwi;

  /// No description provided for @allergyTomato.
  ///
  /// In en, this message translates to:
  /// **'Tomato'**
  String get allergyTomato;

  /// No description provided for @allergyMushroom.
  ///
  /// In en, this message translates to:
  /// **'Mushroom'**
  String get allergyMushroom;

  /// No description provided for @allergyAlcohol.
  ///
  /// In en, this message translates to:
  /// **'Alcohol/Beer'**
  String get allergyAlcohol;

  /// No description provided for @allergyPreservatives.
  ///
  /// In en, this message translates to:
  /// **'Preservatives'**
  String get allergyPreservatives;

  /// No description provided for @allergyFoodColoring.
  ///
  /// In en, this message translates to:
  /// **'Food Coloring'**
  String get allergyFoodColoring;

  /// No description provided for @allergyMustard.
  ///
  /// In en, this message translates to:
  /// **'Mustard'**
  String get allergyMustard;

  /// No description provided for @allergyCelery.
  ///
  /// In en, this message translates to:
  /// **'Celery'**
  String get allergyCelery;

  /// No description provided for @allergyAlmond.
  ///
  /// In en, this message translates to:
  /// **'Almond'**
  String get allergyAlmond;

  /// No description provided for @allergyCashew.
  ///
  /// In en, this message translates to:
  /// **'Cashew'**
  String get allergyCashew;

  /// No description provided for @allergyWalnut.
  ///
  /// In en, this message translates to:
  /// **'Walnut'**
  String get allergyWalnut;

  /// No description provided for @allergyChestnut.
  ///
  /// In en, this message translates to:
  /// **'Chestnut'**
  String get allergyChestnut;

  /// No description provided for @allergyOats.
  ///
  /// In en, this message translates to:
  /// **'Oats'**
  String get allergyOats;

  /// No description provided for @allergyCorn.
  ///
  /// In en, this message translates to:
  /// **'Corn'**
  String get allergyCorn;

  /// No description provided for @allergyBanana.
  ///
  /// In en, this message translates to:
  /// **'Banana'**
  String get allergyBanana;

  /// No description provided for @allergyPineapple.
  ///
  /// In en, this message translates to:
  /// **'Pineapple'**
  String get allergyPineapple;

  /// No description provided for @allergyGarlic.
  ///
  /// In en, this message translates to:
  /// **'Garlic'**
  String get allergyGarlic;

  /// No description provided for @allergyOnion.
  ///
  /// In en, this message translates to:
  /// **'Onion'**
  String get allergyOnion;

  /// No description provided for @allergyChocolate.
  ///
  /// In en, this message translates to:
  /// **'Chocolate'**
  String get allergyChocolate;

  /// No description provided for @allergyCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get allergyCoffee;

  /// No description provided for @howActiveAreYou.
  ///
  /// In en, this message translates to:
  /// **'How active are you each day?'**
  String get howActiveAreYou;

  /// No description provided for @howLongToReachGoal.
  ///
  /// In en, this message translates to:
  /// **'How long do you want to reach your goal?'**
  String get howLongToReachGoal;

  /// No description provided for @loseWeightAmount.
  ///
  /// In en, this message translates to:
  /// **'Lose {amount} kg'**
  String loseWeightAmount(String amount);

  /// No description provided for @gainWeightAmount.
  ///
  /// In en, this message translates to:
  /// **'Gain {amount} kg'**
  String gainWeightAmount(String amount);

  /// No description provided for @daysSuffix.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysSuffix(int count);

  /// No description provided for @unhealthyPlanWarning.
  ///
  /// In en, this message translates to:
  /// **'This plan may not be suitable for your health.'**
  String get unhealthyPlanWarning;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @weeksApprox.
  ///
  /// In en, this message translates to:
  /// **'≈ {weeks} weeks'**
  String weeksApprox(String weeks);

  /// No description provided for @bmr.
  ///
  /// In en, this message translates to:
  /// **'BMR'**
  String get bmr;

  /// No description provided for @tdee.
  ///
  /// In en, this message translates to:
  /// **'TDEE'**
  String get tdee;

  /// No description provided for @calPerDay.
  ///
  /// In en, this message translates to:
  /// **'{cal} cal/day'**
  String calPerDay(String cal);

  /// No description provided for @targetCalories.
  ///
  /// In en, this message translates to:
  /// **'Target Calories'**
  String get targetCalories;

  /// No description provided for @dailyAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Daily Adjustment'**
  String get dailyAdjustment;

  /// No description provided for @calSuffix.
  ///
  /// In en, this message translates to:
  /// **'{cal} cal'**
  String calSuffix(String cal);

  /// No description provided for @safeRange.
  ///
  /// In en, this message translates to:
  /// **'Safe Range'**
  String get safeRange;

  /// No description provided for @warningTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warningTitle;

  /// No description provided for @recommendationDays.
  ///
  /// In en, this message translates to:
  /// **'Recommendation: {days} days'**
  String recommendationDays(int days);

  /// No description provided for @yourGoal.
  ///
  /// In en, this message translates to:
  /// **'Your Goal'**
  String get yourGoal;

  /// No description provided for @currentWeight.
  ///
  /// In en, this message translates to:
  /// **'Current Weight'**
  String get currentWeight;

  /// No description provided for @targetWeight.
  ///
  /// In en, this message translates to:
  /// **'Target Weight'**
  String get targetWeight;

  /// No description provided for @difference.
  ///
  /// In en, this message translates to:
  /// **'Difference'**
  String get difference;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @daysWeeks.
  ///
  /// In en, this message translates to:
  /// **'{days} days (≈ {weeks} weeks)'**
  String daysWeeks(int days, String weeks);

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @recommendation.
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get recommendation;

  /// No description provided for @recommendationDaysWeeks.
  ///
  /// In en, this message translates to:
  /// **'Recommendation: {days} days (≈ {weeks} weeks)'**
  String recommendationDaysWeeks(int days, String weeks);

  /// No description provided for @planSummary.
  ///
  /// In en, this message translates to:
  /// **'Plan Summary'**
  String get planSummary;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @understandRisk.
  ///
  /// In en, this message translates to:
  /// **'I understand the risk'**
  String get understandRisk;

  /// No description provided for @planSavedWarning.
  ///
  /// In en, this message translates to:
  /// **'Plan saved. Please consult a specialist.'**
  String get planSavedWarning;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data: {error}'**
  String errorLoadingData(String error);

  /// No description provided for @noCalculationData.
  ///
  /// In en, this message translates to:
  /// **'No calculation data found.'**
  String get noCalculationData;

  /// No description provided for @interfaceConfirmationReadyToStartTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re ready to start!'**
  String get interfaceConfirmationReadyToStartTitle;

  /// No description provided for @interfaceConfirmationKeepHabitsMessage.
  ///
  /// In en, this message translates to:
  /// **'Keep small habits each day — track meals and weight to see clear progress.'**
  String get interfaceConfirmationKeepHabitsMessage;

  /// No description provided for @interfaceConfirmationUpdateGoalsAnytimeMessage.
  ///
  /// In en, this message translates to:
  /// **'You can update your goal anytime in your profile.'**
  String get interfaceConfirmationUpdateGoalsAnytimeMessage;

  /// No description provided for @interfaceConfirmationGoalMaintain.
  ///
  /// In en, this message translates to:
  /// **'Goal: maintain current weight'**
  String get interfaceConfirmationGoalMaintain;

  /// No description provided for @interfaceConfirmationGoalLoseKg.
  ///
  /// In en, this message translates to:
  /// **'Goal: lose {kg} kg (step by step)'**
  String interfaceConfirmationGoalLoseKg(int kg);

  /// No description provided for @interfaceConfirmationGoalGainKg.
  ///
  /// In en, this message translates to:
  /// **'Goal: gain {kg} kg (step by step)'**
  String interfaceConfirmationGoalGainKg(int kg);

  /// No description provided for @videoProcessingTitle.
  ///
  /// In en, this message translates to:
  /// **'Video Processing'**
  String get videoProcessingTitle;

  /// No description provided for @videoPermissionWarning.
  ///
  /// In en, this message translates to:
  /// **'Camera and Microphone permissions are required to record video.'**
  String get videoPermissionWarning;

  /// No description provided for @videoPickError.
  ///
  /// In en, this message translates to:
  /// **'Error picking video: {error}'**
  String videoPickError(String error);

  /// No description provided for @videoUploadButton.
  ///
  /// In en, this message translates to:
  /// **'Upload Video'**
  String get videoUploadButton;

  /// No description provided for @analysisVideo.
  ///
  /// In en, this message translates to:
  /// **'Analyze Video'**
  String get analysisVideo;

  /// No description provided for @videoAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Analysis from bot'**
  String get videoAnalysisTitle;

  /// No description provided for @videoAnalysisError.
  ///
  /// In en, this message translates to:
  /// **'Error analyzing video: {error}'**
  String videoAnalysisError(String error);

  /// No description provided for @videoNoData.
  ///
  /// In en, this message translates to:
  /// **'No analysis data available.'**
  String get videoNoData;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'vi': return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
