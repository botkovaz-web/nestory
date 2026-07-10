import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../app_colors.dart';
import '../models/order_model.dart';
import '../l10n/app_localizations.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final user = FirebaseAuth.instance.currentUser;

  String _getLocalizedStatus(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case 'V poradí': return l10n.statusInQueue;
      case 'V procese': return l10n.statusInProgress;
      case 'Hotovo': return l10n.statusDone;
      case 'Odoslané': return l10n.statusSent;
      default: return status;
    }
  }

  void _showAddOrderDialog([OrderModel? order]) async {
    final l10n = AppLocalizations.of(context)!;
    final customerController = TextEditingController(text: order != null ? order.customerName : '');
    final productController = TextEditingController(text: order != null ? order.productName : '');
    final priceController = TextEditingController(text: order != null ? order.price.toString() : '');
    DateTime? selectedDate = order?.deadline;
    String status = order != null ? order.status : 'V poradí';
    bool isPaid = order != null ? order.isPaid : false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(order == null ? '${l10n.add} ${l10n.orders.toLowerCase()}' : '${l10n.edit} ${l10n.orders.toLowerCase()}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: customerController,
                  decoration: InputDecoration(labelText: l10n.customerName),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: productController,
                  decoration: InputDecoration(labelText: l10n.productDescription),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: '${l10n.price} (€)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(selectedDate == null 
                    ? l10n.deadline 
                    : '${l10n.deadline}: ${DateFormat('dd.MM.yyyy').format(selectedDate!)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                ),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: InputDecoration(labelText: l10n.status),
                  items: [
                    DropdownMenuItem(value: 'V poradí', child: Text(l10n.statusInQueue)),
                    DropdownMenuItem(value: 'V procese', child: Text(l10n.statusInProgress)),
                    DropdownMenuItem(value: 'Hotovo', child: Text(l10n.statusDone)),
                    DropdownMenuItem(value: 'Odoslané', child: Text(l10n.statusSent)),
                  ],
                  onChanged: (val) => status = val!,
                ),
                SwitchListTile(
                  title: Text(l10n.paid),
                  value: isPaid,
                  onChanged: (val) => setDialogState(() => isPaid = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () async {
                if (customerController.text.isEmpty) return;
                
                final newOrder = OrderModel(
                  id: order?.id ?? '',
                  customerName: customerController.text.trim(),
                  productName: productController.text.trim(),
                  price: double.tryParse(priceController.text) ?? 0,
                  deadline: selectedDate,
                  status: status,
                  isPaid: isPaid,
                );

                if (order == null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user?.uid)
                      .collection('orders')
                      .add(newOrder.toMap());
                } else {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user?.uid)
                      .collection('orders')
                      .doc(order.id)
                      .update(newOrder.toMap());
                }
                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(100, 40)),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.orders),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'order_fab_unique',
        onPressed: () => _showAddOrderDialog(),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('orders')
            .orderBy('updatedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/nesti_packing.png', height: 150),
                  const SizedBox(height: 16),
                  Text(l10n.noOrders, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final order = OrderModel.fromFirestore(snapshot.data!.docs[index]);

              Color statusColor;
              switch (order.status) {
                case 'V procese': statusColor = Colors.orange; break;
                case 'Hotovo': statusColor = Colors.blue; break;
                case 'Odoslané': statusColor = Colors.green; break;
                default: statusColor = Colors.grey;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  title: Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.productName),
                      if (order.deadline != null)
                        Text('${l10n.deadline}: ${DateFormat('dd.MM.yyyy').format(order.deadline!)}', 
                             style: const TextStyle(fontSize: 12, color: Colors.redAccent)),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${order.price.toStringAsFixed(2)} €', 
                           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (order.isPaid) const Icon(Icons.check_circle, size: 14, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(_getLocalizedStatus(context, order.status), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  onTap: () => _showAddOrderDialog(order),
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.deleteConfirmation),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.no)),
                          TextButton(
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user?.uid)
                                  .collection('orders')
                                  .doc(order.id)
                                  .delete();
                              Navigator.pop(context);
                            },
                            child: Text(l10n.yes, style: const TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
