import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'l10n/app_localizations.dart';
import 'app_theme.dart';
import 'screens/main_navigation.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'secrets.dart';
import 'services/database_service.dart';

// Globálny ovládač témy
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    
    // INICIALIZÁCIA REVENUECAT
    await Purchases.setLogLevel(LogLevel.debug);
    
    String apiKey;
    if (Platform.isIOS) {
      apiKey = Secrets.revenueCatIosApiKey;
    } else {
      apiKey = Secrets.revenueCatAndroidApiKey;
    }

    await Purchases.configure(PurchasesConfiguration(apiKey));
    
  } catch (e) {
    debugPrint('Initialization error: $e');
  }

  runApp(const NestoryApp());
}

class NestoryApp extends StatelessWidget {
  const NestoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'NestyCraft',
          debugShowCheckedModeBanner: false,
          
          // Dynamické témy
          themeMode: currentMode, 
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('sk'),
          ],
          home: const AuthWrapper(),
        );
      }
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _setupPurchaseListener();
  }

  void _setupPurchaseListener() {
    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final isPremium = customerInfo.entitlements.all['NestyCraftPro']?.isActive ?? false;
        debugPrint('RevenueCat Update: isPremium = $isPremium pre UID: ${user.uid}');
        await DatabaseService().updatePremiumStatus(isPremium);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        if (authSnapshot.hasData) {
          final uid = authSnapshot.data!.uid;
          debugPrint('Prihlasujem používateľa do RevenueCat: $uid');
          Purchases.logIn(uid);

          // Kontrola onboardingu cez Firestore
          return StreamBuilder<DocumentSnapshot>(
            stream: DatabaseService().userData,
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              final data = userSnapshot.data?.data() as Map<String, dynamic>?;
              final hasSeenOnboarding = data?['hasSeenOnboarding'] ?? false;

              if (!hasSeenOnboarding) {
                return OnboardingScreen(onDone: () {
                  setState(() {}); // Prekreslenie po dokončení
                });
              }

              return const MainNavigation();
            },
          );
        } else {
          Purchases.logOut();
          return const LoginScreen();
        }
      },
    );
  }
}
