import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'constants.dart';
import 'controllers/menu_app_controller.dart';
import 'screens/auth/login_screen.dart';
import 'screens/profil/profil.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/notification/notification_settings_screen.dart';
import 'screens/user/user_screen.dart';
import 'config/firebase_options.dart';
import 'screens/dashboard/pesan_screen.dart';
import 'screens/history/user_history_screen.dart';
import 'screens/dashboard/dashboard_user.dart'; // Import the DashboardUserScreen widget
import 'screens/profil/profil_user.dart'; // Import the ProfileUserPage widget

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Optimize system UI overlay
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // Initialize Firebase with caching enabled
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Enable widget binding optimization
    if (const bool.fromEnvironment('dart.vm.product')) {
      debugPrint = (String? message, {int? wrapWidth}) {};
    }

    runApp(const MyApp());
  } catch (e) {
    debugPrint('Error initializing app: $e');
    // Show user-friendly error message
    runApp(const ErrorApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => MenuAppController(),
          lazy: true, // Enable lazy loading
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sawit Management System',
        theme: _buildTheme(context),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(), // Add const
          '/profil': (context) => const ProfilePage(),
          '/pesan': (context) => const PesanScreen(), // Redirect to dashboard
          '/history': (context) => const HistoryScreen(),
          '/notification': (context) => const NotificationSettingsScreen(),
          '/user': (context) => const UserScreen(),
          '/user_history': (context) => UserHistoryScreen(),
          '/dashboard_user': (context) => DashboardUser(), // ganti dengan nama widget dashboard user Anda
          '/profil_user': (context) => ProfileUserPage(), // ganti dengan nama widget profil user Anda
        },
        builder: (context, child) {
          // Add error boundary
          ErrorWidget.builder = (FlutterErrorDetails details) {
            return Material(
              child: Center(
                child: Text(
                  'An error occurred.\nPlease try again later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red[800]),
                ),
              ),
            );
          };

          // Add performance optimizations
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              physics: const BouncingScrollPhysics(),
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              },
            ),
            child: child!,
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(BuildContext context) {
    // Cache the theme data
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: bgColor,
      textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
          .apply(bodyColor: Colors.white),
      canvasColor: secondaryColor,
      platform: TargetPlatform.android, // Optimize for Android
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      inputDecorationTheme: _buildInputDecorationTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
    );
  }

  InputDecorationTheme _buildInputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: secondaryColor,
      border: _buildDefaultBorder(),
      enabledBorder: _buildDefaultBorder(),
      focusedBorder: _buildFocusedBorder(),
      labelStyle: const TextStyle(color: Colors.white70),
    );
  }

  OutlineInputBorder _buildDefaultBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.white24),
    );
  }

  OutlineInputBorder _buildFocusedBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: primaryColor),
    );
  }

  ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

// Error fallback screen
class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Failed to initialize app.\nPlease restart the application.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red[800]),
          ),
        ),
      ),
    );
  }
}
