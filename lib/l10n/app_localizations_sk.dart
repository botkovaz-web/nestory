// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get appTitle => 'Nestory';

  @override
  String get home => 'Domov';

  @override
  String get welcome => 'Ahoj';

  @override
  String get creator => 'Tvorca';

  @override
  String get whatToCreate => 'Čo dnes ideme tvoriť?';

  @override
  String nestiMessage1(Object name) {
    return 'Dnes je skvelý deň na tvorenie, $name!';
  }

  @override
  String get nestiMessage2 => 'Nezabudla si si zapísať tie nové korálky?';

  @override
  String get nestiMessage3 => 'Nesti na teba dohliada, pôjde ti to od ruky.';

  @override
  String get nestiMessage4 => 'Káva v jednej ruke, ihla v druhej. Ideš!';

  @override
  String get nestiMessage5 => 'Tvoje výrobky robia svet krajším. Fakt.';

  @override
  String get nestiMessage6 => 'Nesti hovorí: Oddych je tiež dôležitý!';

  @override
  String nestiOrdersMessage(Object count) {
    return 'Máš $count objednávky v poradí. Nesti drží palce!';
  }

  @override
  String get nestiNoOrdersMessage =>
      'Všetko hotové? Nesti navrhuje niečo nové vytvoriť!';

  @override
  String get material => 'Materiál';

  @override
  String get tools => 'Pomôcky';

  @override
  String get inventory => 'Sklad';

  @override
  String get orders => 'Objednávky';

  @override
  String get projects => 'Projekty';

  @override
  String get planner => 'Plánovač';

  @override
  String get stats => 'Štatistiky';

  @override
  String get customers => 'Zákazníci';

  @override
  String get logout => 'Odhlásiť sa';

  @override
  String get login => 'Prihlásiť sa';

  @override
  String get register => 'Registrácia';

  @override
  String get add => 'Pridať';

  @override
  String get edit => 'Upraviť';

  @override
  String get delete => 'Vymazať';

  @override
  String get save => 'Uložiť';

  @override
  String get cancel => 'Zrušiť';

  @override
  String get name => 'Názov';

  @override
  String get category => 'Kategória';

  @override
  String get quantity => 'Množstvo';

  @override
  String get unit => 'Jednotka';

  @override
  String get location => 'Umiestnenie';

  @override
  String get note => 'Poznámka';

  @override
  String get noMaterial => 'Zatiaľ tu nemáš žiadny materiál.';

  @override
  String get noTools => 'Zatiaľ tu nemáš žiadne pomôcky.';

  @override
  String get noOrders => 'Žiadne aktívne objednávky.';

  @override
  String get noProjects => 'Zatiaľ žiadne projekty.';

  @override
  String get customerName => 'Meno zákazníka';

  @override
  String get productDescription => 'Produkt / Popis';

  @override
  String get price => 'Cena';

  @override
  String get deadline => 'Termín';

  @override
  String get status => 'Stav';

  @override
  String get paid => 'Zaplatené';

  @override
  String get deleteConfirmation => 'Vymazať túto položku?';

  @override
  String get yes => 'Áno';

  @override
  String get no => 'Nie';

  @override
  String get catYarns => 'Priadze';

  @override
  String get catBeads => 'Korálky';

  @override
  String get catPapers => 'Papiere';

  @override
  String get catFabrics => 'Látky';

  @override
  String get catOther => 'Iné';

  @override
  String get catMachines => 'Stroje';

  @override
  String get catHandTools => 'Ručné náradie';

  @override
  String get catMeasuring => 'Meradlá';

  @override
  String get catOrganizers => 'Organizéry';

  @override
  String get condExcellent => 'Výborný';

  @override
  String get condMaintenance => 'Potrebuje údržbu';

  @override
  String get condBroken => 'Nefunkčný';

  @override
  String get statusInQueue => 'V poradí';

  @override
  String get statusInProgress => 'V procese';

  @override
  String get statusDone => 'Hotovo';

  @override
  String get statusSent => 'Odoslané';

  @override
  String get statusPlanning => 'V pláne';

  @override
  String get statusPreparation => 'Príprava';

  @override
  String get statusProduction => 'Vo výrobe';

  @override
  String get unitPcs => 'ks';

  @override
  String get unitGrams => 'g';

  @override
  String get unitKg => 'kg';

  @override
  String get unitMeters => 'm';

  @override
  String get unitBalls => 'klbka';

  @override
  String get unitSheets => 'hárky';

  @override
  String get unitPacks => 'balenia';

  @override
  String get event => 'Udalosť';

  @override
  String get term => 'Termín';

  @override
  String get inventoryToTake => 'Zásoby na akciu';

  @override
  String get completedOrders => 'Dokončené';

  @override
  String get pendingOrders => 'Čakajúce';

  @override
  String get totalRevenue => 'Celkový obrat';

  @override
  String get statsComingSoon => 'Tu čoskoro pribudnú grafy tvojej tvorby!';
}
