import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sk.dart';

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
    Locale('sk')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Nestory'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get welcome;

  /// No description provided for @creator.
  ///
  /// In en, this message translates to:
  /// **'Creator'**
  String get creator;

  /// No description provided for @whatToCreate.
  ///
  /// In en, this message translates to:
  /// **'What are we making today?'**
  String get whatToCreate;

  /// No description provided for @nestiMessage1.
  ///
  /// In en, this message translates to:
  /// **'Today is a great day for creating, {name}!'**
  String nestiMessage1(Object name);

  /// No description provided for @nestiMessage2.
  ///
  /// In en, this message translates to:
  /// **'Did you remember to record those new beads?'**
  String get nestiMessage2;

  /// No description provided for @nestiMessage3.
  ///
  /// In en, this message translates to:
  /// **'Nesti is watching over you, it will go smoothly.'**
  String get nestiMessage3;

  /// No description provided for @nestiMessage4.
  ///
  /// In en, this message translates to:
  /// **'Coffee in one hand, needle in the other. Go!'**
  String get nestiMessage4;

  /// No description provided for @nestiMessage5.
  ///
  /// In en, this message translates to:
  /// **'Your products make the world more beautiful. Really.'**
  String get nestiMessage5;

  /// No description provided for @nestiMessage6.
  ///
  /// In en, this message translates to:
  /// **'Nesti says: Rest is also important!'**
  String get nestiMessage6;

  /// No description provided for @nestiOrdersMessage.
  ///
  /// In en, this message translates to:
  /// **'You have {count} orders in line. Nesti is crossing her paws!'**
  String nestiOrdersMessage(Object count);

  /// No description provided for @nestiNoOrdersMessage.
  ///
  /// In en, this message translates to:
  /// **'Everything done? Nesti suggests creating something new!'**
  String get nestiNoOrdersMessage;

  /// No description provided for @material.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get material;

  /// No description provided for @tools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tools;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @projects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projects;

  /// No description provided for @planner.
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get planner;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get stats;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @noMaterial.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any material here yet.'**
  String get noMaterial;

  /// No description provided for @noTools.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any tools here yet.'**
  String get noTools;

  /// No description provided for @noOrders.
  ///
  /// In en, this message translates to:
  /// **'No active orders.'**
  String get noOrders;

  /// No description provided for @noProjects.
  ///
  /// In en, this message translates to:
  /// **'No projects yet.'**
  String get noProjects;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerName;

  /// No description provided for @productDescription.
  ///
  /// In en, this message translates to:
  /// **'Product / Description'**
  String get productDescription;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @deadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadline;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete this item?'**
  String get deleteConfirmation;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @catYarns.
  ///
  /// In en, this message translates to:
  /// **'Yarns'**
  String get catYarns;

  /// No description provided for @catBeads.
  ///
  /// In en, this message translates to:
  /// **'Beads'**
  String get catBeads;

  /// No description provided for @catPapers.
  ///
  /// In en, this message translates to:
  /// **'Papers'**
  String get catPapers;

  /// No description provided for @catFabrics.
  ///
  /// In en, this message translates to:
  /// **'Fabrics'**
  String get catFabrics;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// No description provided for @catMachines.
  ///
  /// In en, this message translates to:
  /// **'Machines'**
  String get catMachines;

  /// No description provided for @catHandTools.
  ///
  /// In en, this message translates to:
  /// **'Hand Tools'**
  String get catHandTools;

  /// No description provided for @catMeasuring.
  ///
  /// In en, this message translates to:
  /// **'Measuring Tools'**
  String get catMeasuring;

  /// No description provided for @catOrganizers.
  ///
  /// In en, this message translates to:
  /// **'Organizers'**
  String get catOrganizers;

  /// No description provided for @condExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get condExcellent;

  /// No description provided for @condMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Needs maintenance'**
  String get condMaintenance;

  /// No description provided for @condBroken.
  ///
  /// In en, this message translates to:
  /// **'Broken'**
  String get condBroken;

  /// No description provided for @statusInQueue.
  ///
  /// In en, this message translates to:
  /// **'In queue'**
  String get statusInQueue;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get statusInProgress;

  /// No description provided for @statusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusDone;

  /// No description provided for @statusSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get statusSent;

  /// No description provided for @statusPlanning.
  ///
  /// In en, this message translates to:
  /// **'Planning'**
  String get statusPlanning;

  /// No description provided for @statusPreparation.
  ///
  /// In en, this message translates to:
  /// **'Preparation'**
  String get statusPreparation;

  /// No description provided for @statusProduction.
  ///
  /// In en, this message translates to:
  /// **'Production'**
  String get statusProduction;

  /// No description provided for @unitPcs.
  ///
  /// In en, this message translates to:
  /// **'pcs'**
  String get unitPcs;

  /// No description provided for @unitGrams.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get unitGrams;

  /// No description provided for @unitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// No description provided for @unitMeters.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get unitMeters;

  /// No description provided for @unitBalls.
  ///
  /// In en, this message translates to:
  /// **'balls'**
  String get unitBalls;

  /// No description provided for @unitSheets.
  ///
  /// In en, this message translates to:
  /// **'sheets'**
  String get unitSheets;

  /// No description provided for @unitPacks.
  ///
  /// In en, this message translates to:
  /// **'packs'**
  String get unitPacks;
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
      <String>['en', 'sk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sk':
      return AppLocalizationsSk();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
