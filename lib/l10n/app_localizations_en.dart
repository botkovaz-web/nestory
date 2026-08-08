// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NestyCraft';

  @override
  String get home => 'Home';

  @override
  String get welcome => 'Hello';

  @override
  String get creator => 'Creator';

  @override
  String get whatToCreate => 'What are we making today?';

  @override
  String nestiMessage1(Object name) {
    return 'Today is a great day for creating, $name!';
  }

  @override
  String get nestiMessage2 => 'Did you remember to record those new beads?';

  @override
  String get nestiMessage3 =>
      'Nesti is watching over you, it will go smoothly.';

  @override
  String get nestiMessage4 => 'Coffee in one hand, needle in the other. Go!';

  @override
  String get nestiMessage5 =>
      'Your products make the world more beautiful. Really.';

  @override
  String get nestiMessage6 => 'Nesti says: Rest is also important!';

  @override
  String nestiOrdersMessage(Object count) {
    return 'You have $count active tasks. Nesti is crossing her paws!';
  }

  @override
  String get nestiNoOrdersMessage =>
      'Everything done? Nesti suggests creating something new!';

  @override
  String get material => 'Material';

  @override
  String get addMaterial => 'Add Material';

  @override
  String get editMaterial => 'Edit Material';

  @override
  String get tools => 'Tools';

  @override
  String get tool => 'Tool';

  @override
  String get addTool => 'Add Tool';

  @override
  String get editTool => 'Edit Tool';

  @override
  String get inventory => 'Inventory';

  @override
  String get orders => 'Orders';

  @override
  String get myCreation => 'My Creation';

  @override
  String get projects => 'Projects';

  @override
  String get project => 'Project';

  @override
  String get addProject => 'Add Project';

  @override
  String get editProject => 'Edit Project';

  @override
  String get guides => 'Guides';

  @override
  String get guide => 'Guide';

  @override
  String get addGuide => 'Add Guide';

  @override
  String get editGuide => 'Edit Guide';

  @override
  String get openPdfGuide => 'Open PDF Guide';

  @override
  String get viewPhotoGuide => 'View Photo Guide';

  @override
  String get changeFile => 'Change file';

  @override
  String get selectFile => 'Select file (Photo/PDF)';

  @override
  String get planner => 'Planner';

  @override
  String get addEvent => 'Add Event';

  @override
  String get editEvent => 'Edit Event';

  @override
  String get stats => 'Statistics';

  @override
  String get customers => 'Customers';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get premium => 'Premium';

  @override
  String get premiumStatus => 'Premium Status';

  @override
  String get premiumActive => 'All features unlocked';

  @override
  String get premiumActiveDesc => 'Your subscription is active.';

  @override
  String get getPremium => 'Get Premium';

  @override
  String get premiumBenefit => 'Unlock unlimited guides and stats.';

  @override
  String get activateMonthly => 'ACTIVATE MONTHLY SUBSCRIPTION';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get account => 'Account';

  @override
  String get legal => 'Legal';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountWarning =>
      'This will permanently delete your account and all your data. This action cannot be undone.';

  @override
  String get confirmPassword => 'Password for confirmation';

  @override
  String get deleteAccountError => 'Error deleting account. Check password.';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmation =>
      'Are you sure you want to sign out from your account?';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get name => 'Name';

  @override
  String get email => 'Email';

  @override
  String get category => 'Category';

  @override
  String get quantity => 'Quantity';

  @override
  String get unit => 'Unit';

  @override
  String get location => 'Location';

  @override
  String get note => 'Note';

  @override
  String get lastUpdated => 'Last updated';

  @override
  String get noMaterial => 'You don\'t have any material here yet.';

  @override
  String get noTools => 'You don\'t have any tools here yet.';

  @override
  String get noOrders => 'No active orders.';

  @override
  String get noProjects => 'No projects yet.';

  @override
  String get noGuides => 'No guides yet.';

  @override
  String get customerName => 'Customer Name';

  @override
  String get productDescription => 'Product / Description';

  @override
  String get price => 'Price';

  @override
  String get deadline => 'Deadline';

  @override
  String get status => 'Status';

  @override
  String get paid => 'Paid';

  @override
  String get deleteConfirmation => 'Delete this item?';

  @override
  String get deleteProfile => 'Delete Profile';

  @override
  String get deleteProfileWarning =>
      'This will permanently delete your account and all your data. This action cannot be undone.';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get catYarns => 'Yarns';

  @override
  String get catBeads => 'Beads';

  @override
  String get catPapers => 'Papers';

  @override
  String get catFabrics => 'Fabrics';

  @override
  String get catOther => 'Other';

  @override
  String get catMachines => 'Machines';

  @override
  String get catHandTools => 'Hand Tools';

  @override
  String get catMeasuring => 'Measuring Tools';

  @override
  String get catOrganizers => 'Organizers';

  @override
  String get catCrochet => 'Crochet';

  @override
  String get catSewing => 'Sewing';

  @override
  String get catKnitting => 'Knitting';

  @override
  String get catJewelry => 'Jewelry';

  @override
  String get condExcellent => 'Excellent';

  @override
  String get condMaintenance => 'Needs maintenance';

  @override
  String get condBroken => 'Broken';

  @override
  String get statusInQueue => 'In queue';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusDone => 'Done';

  @override
  String get statusSent => 'Sent';

  @override
  String get statusPlanning => 'Planning';

  @override
  String get statusPreparation => 'Preparation';

  @override
  String get statusProduction => 'Production';

  @override
  String get unitPcs => 'pcs';

  @override
  String get unitGrams => 'g';

  @override
  String get unitKg => 'kg';

  @override
  String get unitMeters => 'm';

  @override
  String get unitBalls => 'balls';

  @override
  String get unitSheets => 'sheets';

  @override
  String get unitPacks => 'packs';

  @override
  String get event => 'Event';

  @override
  String get term => 'Deadline';

  @override
  String get inventoryToTake => 'Inventory to take';

  @override
  String get completedOrders => 'Completed';

  @override
  String get pendingOrders => 'Pending';

  @override
  String get totalIncome => 'Total Income';

  @override
  String get totalExpenses => 'Total Expenses';

  @override
  String get netProfit => 'Net Profit';

  @override
  String get revenueOrders => 'From Projects';

  @override
  String get revenueEvents => 'From Events';

  @override
  String get eventHistory => 'Event History';

  @override
  String get noEvents => 'No finished events yet.';

  @override
  String get revenue => 'Revenue';

  @override
  String get expenses => 'Expenses';

  @override
  String get itemsSold => 'Items sold';

  @override
  String get noInventory => 'No items in inventory';

  @override
  String get statsComingSoon => 'Charts coming soon!';

  @override
  String get forCustomer => 'For Customer';

  @override
  String get forStock => 'For Stock';

  @override
  String get appVersion => 'Version';

  @override
  String get revenueSources => 'Revenue Sources';

  @override
  String get noData => 'No data available.';

  @override
  String get taken => 'Taken';

  @override
  String get sold => 'Sold';

  @override
  String get enterPasswordToConfirm => 'Enter password to confirm';

  @override
  String get freeVersion => 'Free Version';

  @override
  String get purchaseSuccess =>
      'Congratulations! You are now a Premium creator.';

  @override
  String get restoreSuccess => 'Subscription successfully restored!';

  @override
  String get noActiveSubscription => 'No active subscription found.';

  @override
  String get becomePremiumTitle => 'Become a Premium creator!';

  @override
  String get becomePremiumDesc =>
      'Unlock unlimited projects, guide library, market planner, and detailed stats of your growth.';

  @override
  String get activatePremiumButton => 'Activate Premium for €3.99 / month';

  @override
  String get maybeLater => 'Maybe later';

  @override
  String get theme => 'Appearance';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get inProgress => 'In progress';

  @override
  String get itemsInStock => 'Items in stock';

  @override
  String get upcomingDeadline => 'Upcoming deadline';

  @override
  String get noDeadlines => 'No upcoming deadlines';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get addEntry => 'Add Entry';

  @override
  String get onboarding1Title => 'Welcome, Creator!';

  @override
  String get onboarding1Desc =>
      'NestyCraft is your personal assistant for handmade creation.';

  @override
  String get onboarding2Title => 'Studio in your pocket';

  @override
  String get onboarding2Desc =>
      'Keep a perfect overview of your materials and tools. Never buy what you already have at home again.';

  @override
  String get onboarding3Title => 'From idea to finished piece';

  @override
  String get onboarding3Desc =>
      'Track your projects, save PDF guides and photos to them. Your creation will finally be organized.';

  @override
  String get onboarding4Title => 'Plan and grow';

  @override
  String get onboarding4Desc =>
      'Prepare for markets, track sales and see your handmade business grow thanks to detailed statistics.';

  @override
  String get onboardingDone => 'Start creating';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get addNewCategory => 'Add new...';

  @override
  String get newCategoryTitle => 'New Category';

  @override
  String get categoryNameHint => 'Category name (e.g. Zippers)';

  @override
  String get overdue => 'Overdue';

  @override
  String daysLeft(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
    );
    return '$_temp0';
  }
}
