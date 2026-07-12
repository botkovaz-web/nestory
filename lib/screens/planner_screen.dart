import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../app_colors.dart';
import '../models/event_model.dart';
import '../models/project_model.dart';
import '../models/material_model.dart';
import '../l10n/app_localizations.dart';
import '../widgets/add_entry_dialog.dart';
import '../widgets/nestory_card.dart';
import '../services/database_service.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

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

  Future<void> _showAddEventDialog([EventModel? event]) async {
    final l10n = AppLocalizations.of(context)!;
    final titleController = TextEditingController(text: event?.title ?? '');
    final descController = TextEditingController(text: event?.description ?? '');
    final locController = TextEditingController(text: event?.location ?? '');
    DateTime selectedDate = event?.date ?? _selectedDay ?? DateTime.now();
    List<String> selectedInventory = List.from(event?.inventoryItems ?? []);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AddEntryDialog(
          title: event == null ? '${l10n.add} ${l10n.event.toLowerCase()}' : '${l10n.edit} ${l10n.event.toLowerCase()}',
          onSave: () async {
            if (titleController.text.isEmpty) return;
            final eventData = EventModel(
              id: event?.id ?? '',
              title: titleController.text.trim(),
              description: descController.text.trim(),
              location: locController.text.trim(),
              inventoryItems: selectedInventory,
              date: selectedDate,
              type: 'event',
            ).toMap();

            if (event == null) {
              await _dbService.addEvent(eventData);
            } else {
              await _dbService.updateEvent(event.id, eventData);
            }
            if (mounted) Navigator.pop(context);
          },
          content: Column(
            children: [
              TextField(controller: titleController, decoration: InputDecoration(labelText: l10n.name)),
              const SizedBox(height: 8),
              TextField(controller: locController, decoration: InputDecoration(labelText: l10n.location)),
              const SizedBox(height: 8),
              TextField(controller: descController, decoration: InputDecoration(labelText: l10n.note), maxLines: 2),
              const SizedBox(height: 16),
              const Divider(),
              Text(l10n.inventoryToTake, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildInventorySelection(selected: selectedInventory, onChanged: (list) => setDialogState(() => selectedInventory = list)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventorySelection({required List<String> selected, required Function(List<String>) onChanged}) {
    return StreamBuilder<List<MaterialModel>>(
      stream: _dbService.materials,
      builder: (context, materialSnap) {
        return StreamBuilder<List<ProjectModel>>(
          stream: _dbService.projects,
          builder: (context, projectSnap) {
            List<String> allItems = [];
            if (materialSnap.hasData) allItems.addAll(materialSnap.data!.map((m) => m.name));
            if (projectSnap.hasData) allItems.addAll(projectSnap.data!.map((p) => p.name));
            if (allItems.isEmpty) return const SizedBox();
            return Wrap(spacing: 4, children: allItems.map((name) {
              final isSel = selected.contains(name);
              return FilterChip(label: Text(name, style: const TextStyle(fontSize: 11)), selected: isSel, onSelected: (s) {
                final newList = List<String>.from(selected);
                s ? newList.add(name) : newList.remove(name);
                onChanged(newList);
              }, padding: EdgeInsets.zero);
            }).toList());
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.planner), backgroundColor: Colors.transparent, elevation: 0),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddEventDialog(), backgroundColor: AppColors.accent, child: const Icon(Icons.add, color: Colors.white)),
      body: StreamBuilder<List<EventModel>>(
        stream: _dbService.events,
        builder: (context, eventSnap) {
          return StreamBuilder<List<ProjectModel>>(
            stream: _dbService.projects,
            builder: (context, projectSnap) {
              _events = {};
              if (eventSnap.hasData) {
                for (var event in eventSnap.data!) {
                  final date = DateTime(event.date.year, event.date.month, event.date.day);
                  _events[date] = (_events[date] ?? [])..add(event);
                }
              }
              if (projectSnap.hasData) {
                for (var project in projectSnap.data!) {
                  if (project.deadline != null) {
                    final date = DateTime(project.deadline!.year, project.deadline!.month, project.deadline!.day);
                    _events[date] = (_events[date] ?? [])..add(project);
                  }
                }
              }
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
                  return NestoryCard(
                    leading: Icon(icon, color: color), title: title, subtitle: Text(subtitle ?? type),
                    trailing: item is EventModel ? IconButton(icon: const Icon(Icons.delete, size: 20), onPressed: () => _dbService.deleteEvent(item.id)) : null,
                    onTap: item is EventModel ? () => _showAddEventDialog(item) : null,
                  );
                })),
              ]);
            },
          );
        },
      ),
    );
  }
}
