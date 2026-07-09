import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_colors.dart';
import 'material_screen.dart';
import 'tools_screen.dart';
import 'order_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getRandomNestiMessage(String name, int orderCount) {
    final List<String> messages = [
      'Dnes je skvelý deň na tvorenie, $name!',
      'Nezabudla si si zapísať tie nové korálky?',
      'Nesti na teba dohliada, pôjde ti to od ruky.',
      'Káva v jednej ruke, ihla v druhej. Ideš!',
      'Tvoje výrobky robia svet krajším. Fakt.',
      'Nesti hovorí: Oddych je tiež dôležitý!',
    ];

    if (orderCount > 0) {
      messages.add('Máš $orderCount objednávky v poradí. Nesti drží palce!');
    } else {
      messages.add('Všetko hotové? Nesti navrhuje niečo nové vytvoriť!');
    }

    return messages[Random().nextInt(messages.length)];
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nestory'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, userSnapshot) {
          String name = "Tvorca";
          if (userSnapshot.hasData && userSnapshot.data!.exists) {
            name = (userSnapshot.data!.data() as Map<String, dynamic>)['name'] ?? "Tvorca";
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user?.uid)
                .collection('orders')
                .where('status', whereIn: ['V poradí', 'V procese'])
                .snapshots(),
            builder: (context, ordersSnapshot) {
              int activeOrders = ordersSnapshot.hasData ? ordersSnapshot.data!.docs.length : 0;
              String nestiMessage = _getRandomNestiMessage(name, activeOrders);

              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ahoj, $name!',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withOpacity(0.15),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(15),
                                    bottomLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15),
                                  ),
                                ),
                                child: Text(
                                  nestiMessage,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.green.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Image.asset('assets/nesti_happy.png', height: 80),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Dashboard grid filling the rest of the screen
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(child: _buildDashboardCard(
                                  context,
                                  'Materiál',
                                  'assets/nesti_organizing.png',
                                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MaterialScreen())),
                                )),
                                const SizedBox(width: 16),
                                Expanded(child: _buildDashboardCard(
                                  context,
                                  'Pomôcky',
                                  'assets/nesti_watching.png',
                                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ToolsScreen())),
                                )),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(child: _buildDashboardCard(
                                  context,
                                  'Objednávky',
                                  'assets/nesti_packing.png',
                                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderScreen())),
                                )),
                                const SizedBox(width: 16),
                                Expanded(child: _buildDashboardCard(
                                  context,
                                  'Produkty',
                                  'assets/nesti_in_basket.png',
                                  () {},
                                )),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(child: _buildDashboardCard(
                                  context,
                                  'Plánovač',
                                  'assets/nesti_planning.png',
                                  () {},
                                )),
                                const SizedBox(width: 16),
                                Expanded(child: _buildDashboardCard(
                                  context,
                                  'Štatistiky',
                                  'assets/icon_grow.png',
                                  () {},
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(child: Image.asset(assetPath, height: 60)),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
