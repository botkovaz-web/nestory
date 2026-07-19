import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../app_colors.dart';
import '../models/event_model.dart';
import '../models/project_model.dart';
import '../models/material_model.dart';
import '../l10n/app_localizations.dart';
import '../widgets/add_entry_dialog.dart';
import '../widgets/nestory_card.dart';
import '../widgets/detail_entry_dialog.dart';
import '../widgets/nestory_fab.dart';
import '../widgets/nestory_counter.dart';
import '../widgets/nestory_chip_selection.dart';
import '../widgets/app_bar_actions.dart';
import '../services/database_service.dart';

class PlannerScreen extends StatefulWidget {
  final Function(int, {int subTab}) onNavigate;
  const PlannerScreen({super.key, required this.onNavigate});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final _dbService = DatabaseService();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _showEventDetailDialog(EventModel event) {
    final l10n = AppLocalizations.of(context)!;
    double profit = event.sales - event.expenses;

    showDialog(
      context: context,
      builder: (context) => DetailEntryDialog(
        title: event.title,
        onEdit: () { Navigator.pop(context); _showAddEventDialog(event); },
        onDelete: () => _dbService.deleteEvent(event.id),
        children: [
          DetailEntryDialog.buildDetailRow(Icons.calendar_today_outlined, l10n.deadline, DateFormat('dd.MM.yyyy').format(event.date)),
          if (event.location.isNotEmpty) DetailEntryDialog.buildDetailRow(Icons.location_on_outlined, l10n.location, event.location),
          const Divider(height: 24),
          DetailEntryDialog.buildDetailRow(Icons.euro_outlined, l10n.revenue, '${event.sales.toStringAsFixed(2)} €'),
          DetailEntryDialog.buildDetailRow(Icons.trending_down_outlined, l10n.expenses, '${event.expenses.toStringAsFixed(2)} €'),
          DetailEntryDialog.buildDetailRow(Icons.account_balance_wallet_outlined, 'Čistý zisk', '${profit.toStringAsFixed(2)} €', valueColor: profit >= 0 ? Colors.green : Colors.red),
          const SizedBox(height: 16),
          Text(l10n.inventoryToTake, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
          const SizedBox(height: 8),
          if (event.inventory.isEmpty) Text(l10n.noInventory, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ...event.inventory.entries.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.key, style: const TextStyle(fontSize: 13)),
                Text('${item.value['sold']} / ${item.value['taken']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          )).toList(),
          if (event.description.isNotEmpty) ...[
            const Divider(height: 24),
            Text(l10n.note, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
            Text(event.description, style: const TextStyle(fontSize: 13)),
          ],
        ],
      ),
    );
  }

  Future<void> _showAddEventDialog([EventModel? event]) async {
    final l10n = AppLocalizations.of(context)!;
    final titleController = TextEditingController(text: event?.title ?? '');
    final descController = TextEditingController(text: event?.description ?? '');
    final locController = TextEditingController(text: event?.location ?? '');
    final salesController = TextEditingController(text: event?.sales.toString() ?? '0.0');
    final expensesController = TextEditingController(text: event?.expenses.toString() ?? '0.0');
    
    DateTime selectedDate = event?.date ?? _selectedDay ?? DateTime.now();
    Map<String, Map<String, int>> currentInventory = Map.from(event?.inventory ?? {});

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AddEntryDialog(
          title: event == null ? '${l10n.add} ${l10n.event.toLowerCase()}' : '${l10n.edit} ${l10n.event.toLowerCase()}',
          onSave: () async {
            if (titleController.text.isEmpty) return;
            final data = EventModel(
              id: event?.id ?? '', title: titleController.text.trim(), description: descController.text.trim(),
              location: locController.text.trim(), inventory: currentInventory,
              sales: double.tryParse(salesController.text) ?? 0.0, expenses: double.tryParse(expensesController.text) ?? 0.0,
              date: selectedDate, type: 'event',
            ).toMap();

            event == null ? await _dbService.addEvent(data) : await _dbService.updateEvent(event.id, data);
            if (mounted) Navigator.pop(context);
          },
          content: Column(
            children: [
              TextField(controller: titleController, decoration: InputDecoration(labelText: l10n.name)),
              const SizedBox(height: 8),
              TextField(controller: locController, decoration: InputDecoration(labelText: l10n.location)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: TextField(controller: salesController, decoration: InputDecoration(labelText: '${l10n.revenue} (€)'), keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: expensesController, decoration: InputDecoration(labelText: '${l10n.expenses} (€)'), keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 16),
              const Divider(),
              _buildInventoryManager(l10n, currentInventory, () => setDialogState(() {})),
              const SizedBox(height: 16),
              TextField(controller: descController, decoration: InputDecoration(labelText: l10n.note), maxLines: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryManager(AppLocalizations l10n, Map<String, Map<String, int>> currentInventory, VoidCallback onChanged) {
    return Column(children: [
      Text(l10n.inventoryToTake, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      StreamBuilder<List<ProjectModel>>(
        stream: _dbService.projects,
        builder: (context, snapshot) {
          return NestoryChipSelection(
            title: '',
            allItems: snapshot.hasData ? snapshot.data!.map((p) => p.name).toList() : [],
            selectedItems: currentInventory.keys.toList(),
            onChanged: (list) {
              final newList = Map<String, Map<String, int>>.from(currentInventory);
              for (var name in list) { if (!newList.containsKey(name)) newList[name] = {'taken': 1, 'sold': 0}; }
              newList.removeWhere((key, _) => !list.contains(key));
              currentInventory.clear(); currentInventory.addAll(newList);
              onChanged();
            },
          );
        },
      ),
      const SizedBox(height: 12),
      ...currentInventory.entries.map((entry) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(children: [
          Expanded(child: Text(entry.key, style: const TextStyle(fontSize: 13))),
          NestoryCounter(label: 'Vzaté', value: entry.value['taken']!, onAdd: () { entry.value['taken'] = entry.value['taken']! + 1; onChanged(); }, onSub: () { if (entry.value['taken']! > 0) { entry.value['taken'] = entry.value['taken']! - 1; onChanged(); } }),
          const SizedBox(width: 8),
          NestoryCounter(label: 'Predané', value: entry.value['sold']!, color: Colors.green, onAdd: () { if (entry.value['sold']! < entry.value['taken']!) { entry.value['sold'] = entry.value['sold']! + 1; onChanged(); } }, onSub: () { if (entry.value['sold']! > 0) { entry.value['sold'] = entry.value['sold']! - 1; onChanged(); } }),
        ]),
      )).toList(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.planner),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          NestoryAppBarActions(onNavigate: widget.onNavigate),
        ],
      ),
      floatingActionButton: NestoryFAB(onPressed: () => _showAddEventDialog()),
      body: StreamBuilder<List<EventModel>>(
        stream: _dbService.events,
        builder: (context, eventSnap) {
          return StreamBuilder<List<ProjectModel>>(
            stream: _dbService.projects,
            builder: (context, projectSnap) {
              _events = {};
              if (eventSnap.hasData) { for (var e in eventSnap.data!) { _events[DateTime(e.date.year, e.date.month, e.date.day)] = (_events[DateTime(e.date.year, e.date.month, e.date.day)] ?? [])..add(e); } }
              if (projectSnap.hasData) { for (var p in projectSnap.data!) { if (p.deadline != null) { _events[DateTime(p.deadline!.year, p.deadline!.month, p.deadline!.day)] = (_events[DateTime(p.deadline!.year, p.deadline!.month, p.deadline!.day)] ?? [])..add(p); } } }
              final selectedEvents = _events[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ?? [];
              return Column(children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1), lastDay: DateTime.utc(2030, 12, 31), focusedDay: _focusedDay, calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) => setState(() { _selectedDay = selectedDay; _focusedDay = focusedDay; }),
                  onFormatChanged: (format) => setState(() => _calendarFormat = format),
                  eventLoader: (day) => _events[DateTime(day.year, day.month, day.day)] ?? [],
                  calendarStyle: CalendarStyle(todayDecoration: BoxDecoration(color: AppColors.accent.withAlpha(128), shape: BoxShape.circle), selectedDecoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle), markerDecoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
                ),
                const SizedBox(height: 16),
                Expanded(child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: selectedEvents.length, itemBuilder: (context, index) {
                  final item = selectedEvents[index];
                  String title = ''; String type = ''; IconData icon = Icons.event; Color color = Colors.grey; String? subtitle;
                  if (item is EventModel) {
                    title = item.title; type = l10n.event; icon = Icons.festival; color = AppColors.accent; if (item.location.isNotEmpty) subtitle = item.location;
                  } else if (item is ProjectModel) {
                    title = '${l10n.projects}: ${item.name}'; type = l10n.term; icon = Icons.palette; color = Colors.blue;
                  }
                  return NestoryCard(leading: Icon(icon, color: color), title: title, subtitle: Text(subtitle ?? type), onTap: item is EventModel ? () => _showEventDetailDialog(item) : null);
                })),
              ]);
            },
          );
        },
      ),
    );
  }

  bool isSameDay(DateTime? a, DateTime b) { return a != null && a.year == b.year && a.month == b.month && a.day == b.day; }
}
