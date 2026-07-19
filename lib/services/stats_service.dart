import 'package:rxdart/streams.dart';
import '../models/project_model.dart';
import '../models/event_model.dart';
import 'database_service.dart';

class StatsData {
  final double projectRevenue;
  final double eventSales;
  final double totalExpenses;
  final double totalIncome;
  final double netProfit;
  final List<EventModel> pastEvents;

  StatsData({
    required this.projectRevenue,
    required this.eventSales,
    required this.totalExpenses,
    required this.totalIncome,
    required this.netProfit,
    required this.pastEvents,
  });
}

class StatsService {
  final DatabaseService _dbService = DatabaseService();

  Stream<StatsData> get statsStream {
    // Kombinujeme streamy projektov a udalostí pomocou rxdart (musíme ho pridať do pubspec)
    // Alebo to urobíme natívne cez StreamZip alebo CombineLatestStream
    return CombineLatestStream.combine2<List<ProjectModel>, List<EventModel>, StatsData>(
      _dbService.projects,
      _dbService.events,
      (projects, events) {
        double projectRevenue = 0;
        double eventSales = 0;
        double totalExpenses = 0;

        for (var project in projects) {
          if (project.isForCustomer && project.status == 'Hotovo') {
            projectRevenue += project.price;
          }
        }

        List<EventModel> pastEvents = [];
        for (var event in events) {
          eventSales += event.sales;
          totalExpenses += event.expenses;
          if (event.sales > 0 || event.expenses > 0) {
            pastEvents.add(event);
          }
        }
        pastEvents.sort((a, b) => b.date.compareTo(a.date));

        double totalIncome = projectRevenue + eventSales;
        double netProfit = totalIncome - totalExpenses;

        return StatsData(
          projectRevenue: projectRevenue,
          eventSales: eventSales,
          totalExpenses: totalExpenses,
          totalIncome: totalIncome,
          netProfit: netProfit,
          pastEvents: pastEvents,
        );
      },
    );
  }
}
