import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'app_colors.dart';
import 'screens/main_navigation.dart';
import 'screens/login_screen.dart';
import 'secrets.dart';
import 'services/database_service.dart';

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
    return MaterialApp(
      title: 'NestyCraft',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withAlpha(128),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            minimumSize: const Size(300, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('sk'),
        Locale('en'),
      ],
      home: const AuthWrapper(),
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

  // Sledujeme zmeny v predplatnom a synchronizujeme s Firebase
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
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        if (snapshot.hasData) {
          final uid = snapshot.data!.uid;
          debugPrint('Prihlasujem používateľa do RevenueCat: $uid');
          Purchases.logIn(uid);
          return const MainNavigation();
        } else {
          Purchases.logOut();
          return const LoginScreen();
        }
      },
    );
  }
}
