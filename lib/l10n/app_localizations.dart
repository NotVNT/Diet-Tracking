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

  /// No description provided for @defineYourGoal.
  ///
  /// In en, this message translates to:
  /// **'Define your goal'**
  String get defineYourGoal;

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
<<<<<<< HEAD
=======

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

  /// No description provided for @dietAssistant.
  ///
  /// In en, this message translates to:
  /// **'Diet Assistant'**
  String get dietAssistant;

  /// No description provided for @recordMeal.
  ///
  /// In en, this message translates to:
  /// **'Record Meal'**
  String get recordMeal;
>>>>>>> 34fe3db9ee2fbe41befcb7c6d761953ebaa95435
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
