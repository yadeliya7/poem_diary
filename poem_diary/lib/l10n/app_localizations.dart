import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'My Library'**
  String get library;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @myPoems.
  ///
  /// In en, this message translates to:
  /// **'My Poems'**
  String get myPoems;

  /// No description provided for @poemOfDay.
  ///
  /// In en, this message translates to:
  /// **'Poem of the Day'**
  String get poemOfDay;

  /// No description provided for @moodTitle.
  ///
  /// In en, this message translates to:
  /// **'How do you feel today?'**
  String get moodTitle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get save;

  /// No description provided for @poetPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Poet / Pseudonym'**
  String get poetPlaceholder;

  /// No description provided for @titlePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Poem Title...'**
  String get titlePlaceholder;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @addVideo.
  ///
  /// In en, this message translates to:
  /// **'Add Video'**
  String get addVideo;

  /// No description provided for @futureWarning.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t lived the future yet!'**
  String get futureWarning;

  /// No description provided for @writePoem.
  ///
  /// In en, this message translates to:
  /// **'Write Poem'**
  String get writePoem;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'English / Turkish'**
  String get language;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @checkInPrompt.
  ///
  /// In en, this message translates to:
  /// **'How are you today?'**
  String get checkInPrompt;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning ☀️'**
  String get greetingMorning;

  /// No description provided for @greetingDay.
  ///
  /// In en, this message translates to:
  /// **'Good Day 🌤️'**
  String get greetingDay;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening 🌙'**
  String get greetingEvening;

  /// No description provided for @greetingNight.
  ///
  /// In en, this message translates to:
  /// **'Good Night 🌙'**
  String get greetingNight;

  /// No description provided for @dailyQuote.
  ///
  /// In en, this message translates to:
  /// **'May today be poetic.'**
  String get dailyQuote;

  /// No description provided for @discoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover by Mood'**
  String get discoverTitle;

  /// No description provided for @discoverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your mood, find your poem...'**
  String get discoverSubtitle;

  /// No description provided for @emptyFeed.
  ///
  /// In en, this message translates to:
  /// **'No poems yet...'**
  String get emptyFeed;

  /// No description provided for @emptyFeedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap (+) above to add your first poem.'**
  String get emptyFeedSubtitle;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @changeTheme.
  ///
  /// In en, this message translates to:
  /// **'Change Theme'**
  String get changeTheme;

  /// No description provided for @fontStyle.
  ///
  /// In en, this message translates to:
  /// **'Font Style'**
  String get fontStyle;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Mood Calendar'**
  String get calendarTitle;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get tabLibrary;

  /// No description provided for @tabCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get tabCalendar;

  /// No description provided for @emptyPoemsTitle.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t written a poem yet'**
  String get emptyPoemsTitle;

  /// No description provided for @emptyPoemsSub.
  ///
  /// In en, this message translates to:
  /// **'Pour your heart out...'**
  String get emptyPoemsSub;

  /// No description provided for @emptyFavTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorite poems yet'**
  String get emptyFavTitle;

  /// No description provided for @emptyFavSub.
  ///
  /// In en, this message translates to:
  /// **'You can add poems you like here'**
  String get emptyFavSub;

  /// No description provided for @dialogDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete?'**
  String get dialogDeleteTitle;

  /// No description provided for @dialogDeleteMsg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this?'**
  String get dialogDeleteMsg;

  /// No description provided for @btnYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get btnYes;

  /// No description provided for @btnNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get btnNo;

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @msgSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get msgSaved;

  /// No description provided for @msgError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get msgError;

  /// No description provided for @msgFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get msgFieldRequired;

  /// No description provided for @msgFutureDate.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t lived the future yet!'**
  String get msgFutureDate;

  /// No description provided for @moodHappy.
  ///
  /// In en, this message translates to:
  /// **'Joy'**
  String get moodHappy;

  /// No description provided for @moodSad.
  ///
  /// In en, this message translates to:
  /// **'Sadness'**
  String get moodSad;

  /// No description provided for @moodRomantic.
  ///
  /// In en, this message translates to:
  /// **'Romantic'**
  String get moodRomantic;

  /// No description provided for @moodAngry.
  ///
  /// In en, this message translates to:
  /// **'Angry'**
  String get moodAngry;

  /// No description provided for @moodTired.
  ///
  /// In en, this message translates to:
  /// **'Tired'**
  String get moodTired;

  /// No description provided for @moodHopeful.
  ///
  /// In en, this message translates to:
  /// **'Hopeful'**
  String get moodHopeful;

  /// No description provided for @moodPeaceful.
  ///
  /// In en, this message translates to:
  /// **'Peaceful'**
  String get moodPeaceful;

  /// No description provided for @moodNostalgic.
  ///
  /// In en, this message translates to:
  /// **'Nostalgic'**
  String get moodNostalgic;

  /// No description provided for @moodMystic.
  ///
  /// In en, this message translates to:
  /// **'Mystic'**
  String get moodMystic;

  /// No description provided for @hintSearch.
  ///
  /// In en, this message translates to:
  /// **'Search poems or poets...'**
  String get hintSearch;

  /// No description provided for @hintNote.
  ///
  /// In en, this message translates to:
  /// **'Add a note for today...'**
  String get hintNote;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @goodNight.
  ///
  /// In en, this message translates to:
  /// **'Good Night'**
  String get goodNight;

  /// No description provided for @dialogEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Entry'**
  String get dialogEntryTitle;

  /// No description provided for @labelMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get labelMood;

  /// No description provided for @hintWriteNote.
  ///
  /// In en, this message translates to:
  /// **'Write a note for today...'**
  String get hintWriteNote;

  /// No description provided for @labelAttachedFiles.
  ///
  /// In en, this message translates to:
  /// **'Attached Files'**
  String get labelAttachedFiles;

  /// No description provided for @btnSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btnSave;

  /// No description provided for @msgEntrySaved.
  ///
  /// In en, this message translates to:
  /// **'Diary entry saved'**
  String get msgEntrySaved;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'Share Text'**
  String get shareText;

  /// No description provided for @shareImage.
  ///
  /// In en, this message translates to:
  /// **'Share as Image'**
  String get shareImage;

  /// No description provided for @shareImageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-expanding design for long poems'**
  String get shareImageSubtitle;

  /// No description provided for @designBgTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Background'**
  String get designBgTitle;

  /// No description provided for @tabGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get tabGallery;

  /// No description provided for @tabColors.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get tabColors;

  /// No description provided for @settingFontTitle.
  ///
  /// In en, this message translates to:
  /// **'Font Style'**
  String get settingFontTitle;

  /// No description provided for @hintPoemBody.
  ///
  /// In en, this message translates to:
  /// **'Pour your heart out...'**
  String get hintPoemBody;

  /// No description provided for @moodUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get moodUnknown;

  /// No description provided for @noNote.
  ///
  /// In en, this message translates to:
  /// **'No note added for today.'**
  String get noNote;

  /// No description provided for @titleSelectMood.
  ///
  /// In en, this message translates to:
  /// **'Select Mood'**
  String get titleSelectMood;

  /// No description provided for @btnSeePoems.
  ///
  /// In en, this message translates to:
  /// **'See Poems'**
  String get btnSeePoems;

  /// No description provided for @msgNoMoodPoems.
  ///
  /// In en, this message translates to:
  /// **'No poems for this mood yet.'**
  String get msgNoMoodPoems;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Habitual'**
  String get appTitle;

  /// No description provided for @msgNoPoemSelected.
  ///
  /// In en, this message translates to:
  /// **'No poem selected yet.'**
  String get msgNoPoemSelected;

  /// No description provided for @createdWith.
  ///
  /// In en, this message translates to:
  /// **'Created with'**
  String get createdWith;

  /// No description provided for @dailyGoals.
  ///
  /// In en, this message translates to:
  /// **'Daily Goals'**
  String get dailyGoals;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Habitual'**
  String get homeTitle;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @pastRecords.
  ///
  /// In en, this message translates to:
  /// **'Past Records'**
  String get pastRecords;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak: {days} days'**
  String streak(int days);

  /// No description provided for @todaySummary.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Summary'**
  String get todaySummary;

  /// No description provided for @noActivityDetails.
  ///
  /// In en, this message translates to:
  /// **'No activity details yet'**
  String get noActivityDetails;

  /// No description provided for @tapToAddEntry.
  ///
  /// In en, this message translates to:
  /// **'Tap to add daily summary'**
  String get tapToAddEntry;

  /// No description provided for @activityGoodSleep.
  ///
  /// In en, this message translates to:
  /// **'Good Sleep'**
  String get activityGoodSleep;

  /// No description provided for @activityMediumSleep.
  ///
  /// In en, this message translates to:
  /// **'Medium Sleep'**
  String get activityMediumSleep;

  /// No description provided for @activityBadSleep.
  ///
  /// In en, this message translates to:
  /// **'Bad Sleep'**
  String get activityBadSleep;

  /// No description provided for @activitySunny.
  ///
  /// In en, this message translates to:
  /// **'Sunny'**
  String get activitySunny;

  /// No description provided for @activityRainy.
  ///
  /// In en, this message translates to:
  /// **'Rainy'**
  String get activityRainy;

  /// No description provided for @activityCloudy.
  ///
  /// In en, this message translates to:
  /// **'Cloudy'**
  String get activityCloudy;

  /// No description provided for @activitySnowy.
  ///
  /// In en, this message translates to:
  /// **'Snowy'**
  String get activitySnowy;

  /// No description provided for @activityNoSmoking.
  ///
  /// In en, this message translates to:
  /// **'No Smoking'**
  String get activityNoSmoking;

  /// No description provided for @activitySport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get activitySport;

  /// No description provided for @activityWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get activityWater;

  /// No description provided for @activityBook.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get activityBook;

  /// No description provided for @activityMeditation.
  ///
  /// In en, this message translates to:
  /// **'Meditation'**
  String get activityMeditation;

  /// No description provided for @activityDetox.
  ///
  /// In en, this message translates to:
  /// **'Detox'**
  String get activityDetox;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share with Friends'**
  String get shareApp;

  /// No description provided for @shareMessage.
  ///
  /// In en, this message translates to:
  /// **'Hi! I discovered this great app to track my mood and habits. You should try it too! 🚀 Habitual\n\n'**
  String get shareMessage;

  /// No description provided for @shareError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}. Please restart the app.'**
  String shareError(String error);

  /// No description provided for @goPremium.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get goPremium;

  /// No description provided for @premiumDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlimited access and ad-free experience.'**
  String get premiumDesc;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get sectionAppearance;

  /// No description provided for @sectionOther.
  ///
  /// In en, this message translates to:
  /// **'OTHER'**
  String get sectionOther;

  /// No description provided for @dayDetail.
  ///
  /// In en, this message translates to:
  /// **'Day Detail'**
  String get dayDetail;

  /// No description provided for @btnAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get btnAddPhoto;

  /// No description provided for @goalDuration.
  ///
  /// In en, this message translates to:
  /// **'Goal Duration'**
  String get goalDuration;

  /// No description provided for @daysSuffix.
  ///
  /// In en, this message translates to:
  /// **'{days} Days'**
  String daysSuffix(int days);

  /// No description provided for @guestUser.
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guestUser;

  /// No description provided for @defaultUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Poetry Enthusiast'**
  String get defaultUserTitle;

  /// No description provided for @descSad.
  ///
  /// In en, this message translates to:
  /// **'Feels like a rainy day'**
  String get descSad;

  /// No description provided for @descHappy.
  ///
  /// In en, this message translates to:
  /// **'Like a sunny morning'**
  String get descHappy;

  /// No description provided for @descNostalgic.
  ///
  /// In en, this message translates to:
  /// **'Touch of memories'**
  String get descNostalgic;

  /// No description provided for @descAngry.
  ///
  /// In en, this message translates to:
  /// **'Angry and tense'**
  String get descAngry;

  /// No description provided for @descHopeful.
  ///
  /// In en, this message translates to:
  /// **'A fresh start'**
  String get descHopeful;

  /// No description provided for @descPeaceful.
  ///
  /// In en, this message translates to:
  /// **'Like flowing water'**
  String get descPeaceful;

  /// No description provided for @descRomantic.
  ///
  /// In en, this message translates to:
  /// **'Purest form of love'**
  String get descRomantic;

  /// No description provided for @descTired.
  ///
  /// In en, this message translates to:
  /// **'Need some rest'**
  String get descTired;

  /// No description provided for @descAll.
  ///
  /// In en, this message translates to:
  /// **'Whole archive'**
  String get descAll;

  /// No description provided for @moodAll.
  ///
  /// In en, this message translates to:
  /// **'All Poems'**
  String get moodAll;

  /// No description provided for @sectionSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sectionSleep;

  /// No description provided for @sleepGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get sleepGood;

  /// No description provided for @sleepMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get sleepMedium;

  /// No description provided for @sleepBad.
  ///
  /// In en, this message translates to:
  /// **'Bad'**
  String get sleepBad;

  /// No description provided for @sectionHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get sectionHealth;

  /// No description provided for @healthSport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get healthSport;

  /// No description provided for @healthHealthyFood.
  ///
  /// In en, this message translates to:
  /// **'Healthy Food'**
  String get healthHealthyFood;

  /// No description provided for @healthFastFood.
  ///
  /// In en, this message translates to:
  /// **'Fast Food'**
  String get healthFastFood;

  /// No description provided for @healthWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get healthWater;

  /// No description provided for @healthWalking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get healthWalking;

  /// No description provided for @healthVitamins.
  ///
  /// In en, this message translates to:
  /// **'Vitamins'**
  String get healthVitamins;

  /// No description provided for @healthSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get healthSleep;

  /// No description provided for @healthDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get healthDoctor;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// No description provided for @tabInspiration.
  ///
  /// In en, this message translates to:
  /// **'Inspiration'**
  String get tabInspiration;

  /// No description provided for @tabNotebook.
  ///
  /// In en, this message translates to:
  /// **'Notebook'**
  String get tabNotebook;

  /// No description provided for @msgNoPoemYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t written a poem yet...'**
  String get msgNoPoemYet;

  /// No description provided for @msgStartWriting.
  ///
  /// In en, this message translates to:
  /// **'Come on, pick up the pen!'**
  String get msgStartWriting;

  /// No description provided for @btnNewPoem.
  ///
  /// In en, this message translates to:
  /// **'Get New Poem'**
  String get btnNewPoem;

  /// No description provided for @titleDeletePoem.
  ///
  /// In en, this message translates to:
  /// **'Delete Poem'**
  String get titleDeletePoem;

  /// No description provided for @msgDeleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this poem? This action cannot be undone.'**
  String get msgDeleteConfirmation;

  /// No description provided for @btnDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get btnDelete;

  /// No description provided for @analysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysisTitle;

  /// No description provided for @analysisMoodTrend.
  ///
  /// In en, this message translates to:
  /// **'Mood Trend (Last 7 Days)'**
  String get analysisMoodTrend;

  /// No description provided for @analysisSleepQuality.
  ///
  /// In en, this message translates to:
  /// **'Sleep Quality'**
  String get analysisSleepQuality;

  /// No description provided for @analysisTopActivities.
  ///
  /// In en, this message translates to:
  /// **'Top Activities'**
  String get analysisTopActivities;

  /// No description provided for @analysisAllActivities.
  ///
  /// In en, this message translates to:
  /// **'All Activities'**
  String get analysisAllActivities;

  /// No description provided for @analysisNoData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data'**
  String get analysisNoData;

  /// No description provided for @analysisNoSleepData.
  ///
  /// In en, this message translates to:
  /// **'No sleep data'**
  String get analysisNoSleepData;

  /// No description provided for @analysisNoActivityData.
  ///
  /// In en, this message translates to:
  /// **'No activity data'**
  String get analysisNoActivityData;

  /// No description provided for @analysisNoActivities.
  ///
  /// In en, this message translates to:
  /// **'No activities yet'**
  String get analysisNoActivities;

  /// No description provided for @btnSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get btnSeeAll;

  /// No description provided for @timesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} times'**
  String timesCount(int count);

  /// No description provided for @legendSleepGood.
  ///
  /// In en, this message translates to:
  /// **'Good Sleep'**
  String get legendSleepGood;

  /// No description provided for @legendSleepMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get legendSleepMedium;

  /// No description provided for @legendSleepBad.
  ///
  /// In en, this message translates to:
  /// **'Bad'**
  String get legendSleepBad;

  /// No description provided for @dailyStreak.
  ///
  /// In en, this message translates to:
  /// **'{count} Day Streak'**
  String dailyStreak(int count);

  /// No description provided for @startStreak.
  ///
  /// In en, this message translates to:
  /// **'Start Streak'**
  String get startStreak;

  /// No description provided for @streakCompleted.
  ///
  /// In en, this message translates to:
  /// **'\nYou completed {days} days streak in {goal}!'**
  String streakCompleted(int days, String goal);

  /// No description provided for @streakGoalCompleted.
  ///
  /// In en, this message translates to:
  /// **'\nYou completed {days} days streak!'**
  String streakGoalCompleted(int days);

  /// No description provided for @sectionSocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get sectionSocial;

  /// No description provided for @socialFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get socialFriends;

  /// No description provided for @socialFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get socialFamily;

  /// No description provided for @socialParty.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get socialParty;

  /// No description provided for @socialPartner.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get socialPartner;

  /// No description provided for @socialGuests.
  ///
  /// In en, this message translates to:
  /// **'Guests'**
  String get socialGuests;

  /// No description provided for @socialColleagues.
  ///
  /// In en, this message translates to:
  /// **'Colleagues'**
  String get socialColleagues;

  /// No description provided for @socialTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get socialTravel;

  /// No description provided for @socialVolunteer.
  ///
  /// In en, this message translates to:
  /// **'Volunteer'**
  String get socialVolunteer;

  /// No description provided for @sectionHobbies.
  ///
  /// In en, this message translates to:
  /// **'Hobbies'**
  String get sectionHobbies;

  /// No description provided for @hobbyGaming.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get hobbyGaming;

  /// No description provided for @hobbyReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get hobbyReading;

  /// No description provided for @hobbyMovie.
  ///
  /// In en, this message translates to:
  /// **'Movie/Series'**
  String get hobbyMovie;

  /// No description provided for @hobbyArt.
  ///
  /// In en, this message translates to:
  /// **'Art'**
  String get hobbyArt;

  /// No description provided for @hobbyMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get hobbyMusic;

  /// No description provided for @hobbyCoding.
  ///
  /// In en, this message translates to:
  /// **'Coding'**
  String get hobbyCoding;

  /// No description provided for @hobbyPhotography.
  ///
  /// In en, this message translates to:
  /// **'Photography'**
  String get hobbyPhotography;

  /// No description provided for @hobbyCrafts.
  ///
  /// In en, this message translates to:
  /// **'Handcrafts'**
  String get hobbyCrafts;

  /// No description provided for @sectionChores.
  ///
  /// In en, this message translates to:
  /// **'Chores'**
  String get sectionChores;

  /// No description provided for @choreCleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get choreCleaning;

  /// No description provided for @choreShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get choreShopping;

  /// No description provided for @choreLaundry.
  ///
  /// In en, this message translates to:
  /// **'Laundry'**
  String get choreLaundry;

  /// No description provided for @choreCooking.
  ///
  /// In en, this message translates to:
  /// **'Cooking'**
  String get choreCooking;

  /// No description provided for @choreIroning.
  ///
  /// In en, this message translates to:
  /// **'Ironing'**
  String get choreIroning;

  /// No description provided for @choreDishes.
  ///
  /// In en, this message translates to:
  /// **'Dishes'**
  String get choreDishes;

  /// No description provided for @choreRepair.
  ///
  /// In en, this message translates to:
  /// **'Repair'**
  String get choreRepair;

  /// No description provided for @chorePlants.
  ///
  /// In en, this message translates to:
  /// **'Plants'**
  String get chorePlants;

  /// No description provided for @sectionSelfCare.
  ///
  /// In en, this message translates to:
  /// **'Self Care'**
  String get sectionSelfCare;

  /// No description provided for @careManicure.
  ///
  /// In en, this message translates to:
  /// **'Manicure'**
  String get careManicure;

  /// No description provided for @careSkincare.
  ///
  /// In en, this message translates to:
  /// **'Skincare'**
  String get careSkincare;

  /// No description provided for @careHair.
  ///
  /// In en, this message translates to:
  /// **'Hair Care'**
  String get careHair;

  /// No description provided for @careMassage.
  ///
  /// In en, this message translates to:
  /// **'Massage'**
  String get careMassage;

  /// No description provided for @careFaceMask.
  ///
  /// In en, this message translates to:
  /// **'Face Mask'**
  String get careFaceMask;

  /// No description provided for @careBath.
  ///
  /// In en, this message translates to:
  /// **'Bath'**
  String get careBath;

  /// No description provided for @careDetox.
  ///
  /// In en, this message translates to:
  /// **'Digital Detox'**
  String get careDetox;

  /// No description provided for @sectionWeather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get sectionWeather;

  /// No description provided for @weatherSunny.
  ///
  /// In en, this message translates to:
  /// **'Sunny'**
  String get weatherSunny;

  /// No description provided for @weatherRainy.
  ///
  /// In en, this message translates to:
  /// **'Rainy'**
  String get weatherRainy;

  /// No description provided for @weatherCloudy.
  ///
  /// In en, this message translates to:
  /// **'Cloudy'**
  String get weatherCloudy;

  /// No description provided for @weatherSnowy.
  ///
  /// In en, this message translates to:
  /// **'Snowy'**
  String get weatherSnowy;

  /// No description provided for @sectionNotesMedia.
  ///
  /// In en, this message translates to:
  /// **'Notes & Media'**
  String get sectionNotesMedia;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Notes for today...'**
  String get notesHint;

  /// No description provided for @saveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Daily entry saved!'**
  String get saveSuccess;

  /// No description provided for @selectMoodWarning.
  ///
  /// In en, this message translates to:
  /// **'Please select a mood'**
  String get selectMoodWarning;

  /// No description provided for @maxMediaWarning.
  ///
  /// In en, this message translates to:
  /// **'You can add up to 5 photos.'**
  String get maxMediaWarning;

  /// No description provided for @goalNoSmoking.
  ///
  /// In en, this message translates to:
  /// **'No Smoking'**
  String get goalNoSmoking;

  /// No description provided for @goalSocialDetox.
  ///
  /// In en, this message translates to:
  /// **'Social Media Detox'**
  String get goalSocialDetox;

  /// No description provided for @goalReadBook.
  ///
  /// In en, this message translates to:
  /// **'Read Book'**
  String get goalReadBook;

  /// No description provided for @goalDrinkWater.
  ///
  /// In en, this message translates to:
  /// **'Drink Water'**
  String get goalDrinkWater;

  /// No description provided for @goalMeditation.
  ///
  /// In en, this message translates to:
  /// **'Meditation'**
  String get goalMeditation;

  /// No description provided for @goalEarlyRise.
  ///
  /// In en, this message translates to:
  /// **'Wake up Early'**
  String get goalEarlyRise;

  /// No description provided for @goalNoSugar.
  ///
  /// In en, this message translates to:
  /// **'No Sugar'**
  String get goalNoSugar;

  /// No description provided for @goalJournaling.
  ///
  /// In en, this message translates to:
  /// **'Journaling'**
  String get goalJournaling;

  /// No description provided for @goalSteps.
  ///
  /// In en, this message translates to:
  /// **'10k Steps'**
  String get goalSteps;
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
