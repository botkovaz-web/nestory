import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../app_colors.dart';
import '../models/event_model.dart';
import '../models/order_model.dart';
import '../models/project_model.dart';
import '../l10n/app_localizations.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final user = FirebaseAuth.instance.currentUser;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  Future<void> _showAddEventDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = _selectedDay ?? DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${l10n.add} udalosť'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: InputDecoration(labelText: l10n.name)),
            const SizedBox(height: 8),
            TextField(controller: descController, decoration: InputDecoration(labelText: l10n.note)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty) return;
              final newEvent = EventModel(
                id: '',
                title: titleController.text.trim(),
                description: descController.text.trim(),
                date: selectedDate,
                type: 'event',
              );
              await FirebaseFirestore.instance.collection('users').doc(user?.uid).collection('events').add(newEvent.toMap());
              if (mounted) Navigator.pop(context);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.planner), backgroundColor: Colors.transparent, elevation: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, _) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).collection('events').snapshots(),
            builder: (context, eventSnap) {
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).collection('orders').snapshots(),
                builder: (context, orderSnap) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).collection('projects').snapshots(),
                    builder: (context, projectSnap) {
                      _events = {};
                      
                      if (eventSnap.hasData) {
                        for (var doc in eventSnap.data!.docs) {
                          final event = EventModel.fromFirestore(doc);
                          final date = DateTime(event.date.year, event.date.month, event.date.day);
                          _events[date] = (_events[date] ?? [])..add(event);
                        }
                      }

                      if (orderSnap.hasData) {
                        for (var doc in orderSnap.data!.docs) {
                          final order = OrderModel.fromFirestore(doc);
                          if (order.deadline != null) {
                            final date = DateTime(order.deadline!.year, order.deadline!.month, order.deadline!.day);
                            _events[date] = (_events[date] ?? [])..add(order);
                          }
                        }
                      }

                      if (projectSnap.hasData) {
                        for (var doc in projectSnap.data!.docs) {
                          final project = ProjectModel.fromFirestore(doc);
                          if (project.deadline != null) {
                            final date = DateTime(project.deadline!.year, project.deadline!.month, project.deadline!.day);
                            _events[date] = (_events[date] ?? [])..add(project);
                          }
                        }
                      }

                      final selectedEvents = _events[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ?? [];

                      return Column(
                        children: [
                          TableCalendar(
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: _focusedDay,
                            calendarFormat: _calendarFormat,
                            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                            },
                            onFormatChanged: (format) {
                              setState(() => _calendarFormat = format);
                            },
                            eventLoader: (day) {
                              return _events[DateTime(day.year, day.month, day.day)] ?? [];
                            },
                            calendarStyle: CalendarStyle(
                              todayDecoration: BoxDecoration(color: AppColors.accent.withAlpha(128), shape: BoxShape.circle),
                              selectedDecoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                              markerDecoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: selectedEvents.length,
                              itemBuilder: (context, index) {
                                final item = selectedEvents[index];
                                String title = '';
                                String type = '';
                                IconData icon = Icons.event;
                                Color color = Colors.grey;

                                if (item is EventModel) {
                                  title = item.title;
                                  type = 'Udalosť';
                                  icon = Icons.festival;
                                  color = AppColors.accent;
                                } else if (item is OrderModel) {
                                  title = '${l10n.orders}: ${item.customerName}';
                                  type = l10n.deadline;
                                  icon = Icons.shopping_bag;
                                  color = Colors.orange;
                                } else if (item is ProjectModel) {
                                  title = '${l10n.projects}: ${item.name}';
                                  type = l10n.deadline;
                                  icon = Icons.palette;
                                  color = Colors.blue;
                                }

                                return Card(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: ListTile(
                                    leading: Icon(icon, color: color),
                                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text(type),
                                    trailing: item is EventModel 
                                      ? IconButton(icon: const Icon(Icons.delete, size: 20), onPressed: () => FirebaseFirestore.instance.collection('users').doc(user?.uid).collection('events').doc(item.id).delete())
                                      : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
