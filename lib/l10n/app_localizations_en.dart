// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Nestory';

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
    return 'You have $count orders in line. Nesti is crossing her paws!';
  }

  @override
  String get nestiNoOrdersMessage =>
      'Everything done? Nesti suggests creating something new!';

  @override
  String get material => 'Material';

  @override
  String get tools => 'Tools';

  @override
  String get inventory => 'Inventory';

  @override
  String get orders => 'Orders';

  @override
  String get projects => 'Projects';

  @override
  String get planner => 'Planner';

  @override
  String get stats => 'Statistics';

  @override
  String get customers => 'Customers';

  @override
  String get logout => 'Logout';

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
  String get name => 'Name';

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
  String get noMaterial => 'You don\'t have any material here yet.';

  @override
  String get noTools => 'You don\'t have any tools here yet.';

  @override
  String get noOrders => 'No active orders.';

  @override
  String get noProjects => 'No projects yet.';

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
  String get totalRevenue => 'Total Revenue';

  @override
  String get statsComingSoon => 'Charts of your creations coming soon!';
}
