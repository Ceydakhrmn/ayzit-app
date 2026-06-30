import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
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
/// import 'gen_l10n/app_localizations.dart';
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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Period Cycle Tracker'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your menstrual cycle'**
  String get appSubtitle;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar (predicted cycles)'**
  String get calendar;

  /// No description provided for @cycleStartDate.
  ///
  /// In en, this message translates to:
  /// **'Cycle Start Date'**
  String get cycleStartDate;

  /// No description provided for @cycleDays.
  ///
  /// In en, this message translates to:
  /// **'Cycle Length (days)'**
  String get cycleDays;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @registeredCycles.
  ///
  /// In en, this message translates to:
  /// **'Registered Cycles'**
  String get registeredCycles;

  /// No description provided for @averageLength.
  ///
  /// In en, this message translates to:
  /// **'Average Length'**
  String get averageLength;

  /// No description provided for @regularity.
  ///
  /// In en, this message translates to:
  /// **'Regularity'**
  String get regularity;

  /// No description provided for @calculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get calculate;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @cycleSeparator.
  ///
  /// In en, this message translates to:
  /// **':'**
  String get cycleSeparator;

  /// No description provided for @nextCycle.
  ///
  /// In en, this message translates to:
  /// **'Next Cycle'**
  String get nextCycle;

  /// No description provided for @tapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap to select date'**
  String get tapToSelect;

  /// No description provided for @mood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get mood;

  /// No description provided for @symptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms & Notes'**
  String get symptoms;

  /// No description provided for @typeSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Type your symptoms or notes...'**
  String get typeSymptoms;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Mood & Notes saved ✅'**
  String get saved;

  /// No description provided for @pleaseSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a date!'**
  String get pleaseSelectDate;

  /// No description provided for @pleaseEnterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number!'**
  String get pleaseEnterValidNumber;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @happy.
  ///
  /// In en, this message translates to:
  /// **'happy 😄'**
  String get happy;

  /// No description provided for @energetic.
  ///
  /// In en, this message translates to:
  /// **'energetic 🤩'**
  String get energetic;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'normal 😐'**
  String get normal;

  /// No description provided for @sad.
  ///
  /// In en, this message translates to:
  /// **'sad 😢'**
  String get sad;

  /// No description provided for @stressed.
  ///
  /// In en, this message translates to:
  /// **'stressed 😰'**
  String get stressed;

  /// No description provided for @tired.
  ///
  /// In en, this message translates to:
  /// **'tired 😴'**
  String get tired;

  /// No description provided for @overviewTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get overviewTab;

  /// No description provided for @notesTab.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get notesTab;

  /// No description provided for @waterReminder.
  ///
  /// In en, this message translates to:
  /// **'Water reminder'**
  String get waterReminder;

  /// No description provided for @waterGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get waterGoal;

  /// No description provided for @glasses.
  ///
  /// In en, this message translates to:
  /// **'glasses'**
  String get glasses;

  /// No description provided for @addGlass.
  ///
  /// In en, this message translates to:
  /// **'Add 1 glass'**
  String get addGlass;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @breathingTitle.
  ///
  /// In en, this message translates to:
  /// **'Breathing exercise'**
  String get breathingTitle;

  /// No description provided for @breathingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'4-4-4 rhythm: inhale 4s, hold 4s, exhale 4s'**
  String get breathingSubtitle;

  /// No description provided for @breathingReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get breathingReady;

  /// No description provided for @breatheIn.
  ///
  /// In en, this message translates to:
  /// **'Inhale'**
  String get breatheIn;

  /// No description provided for @breatheHold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get breatheHold;

  /// No description provided for @breatheOut.
  ///
  /// In en, this message translates to:
  /// **'Exhale'**
  String get breatheOut;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get seconds;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'hörü'**
  String get aiAssistant;

  /// No description provided for @aiAssistantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Chat with hörü for brief, supportive advice'**
  String get aiAssistantSubtitle;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendMessage;

  /// No description provided for @getAdvice.
  ///
  /// In en, this message translates to:
  /// **'Get quick advice'**
  String get getAdvice;

  /// No description provided for @aiRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'AI request failed'**
  String get aiRequestFailed;

  /// No description provided for @adviceNeedsInput.
  ///
  /// In en, this message translates to:
  /// **'Enter a summary or message for quick advice'**
  String get adviceNeedsInput;

  /// No description provided for @horuTab.
  ///
  /// In en, this message translates to:
  /// **'hörü'**
  String get horuTab;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatTitle;

  /// No description provided for @groupChat.
  ///
  /// In en, this message translates to:
  /// **'Group Chat'**
  String get groupChat;

  /// No description provided for @privateChats.
  ///
  /// In en, this message translates to:
  /// **'Private Messages'**
  String get privateChats;

  /// No description provided for @groupChatDesc.
  ///
  /// In en, this message translates to:
  /// **'Chat with the community, share experiences'**
  String get groupChatDesc;

  /// No description provided for @joinGroupChat.
  ///
  /// In en, this message translates to:
  /// **'Join Group Chat'**
  String get joinGroupChat;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No other users yet'**
  String get noUsersFound;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Send the first one!'**
  String get noMessages;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Send the first message to start the conversation'**
  String get startConversation;

  /// No description provided for @typeGroupMessage.
  ///
  /// In en, this message translates to:
  /// **'Message everyone...'**
  String get typeGroupMessage;

  /// No description provided for @chatsTab.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatsTab;
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
      <String>['de', 'en', 'es', 'fr', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
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
