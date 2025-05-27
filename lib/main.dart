import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';
import 'controllers/menu_app_controller.dart';
import 'screens/auth/login_screen.dart';
import 'screens/profil/profil.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/notification/notification_settings_screen.dart';
import 'config/firebase_options.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  } catch (e) {
    print('Error initializing app: $e');
    // Handle initialization error appropriately
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
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sawit Management System',
        theme: _buildTheme(context),
        initialRoute: '/',
        routes: _buildRoutes(),
      ),
    );
  }

  ThemeData _buildTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: bgColor,
      textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
          .apply(bodyColor: Colors.white),
      canvasColor: secondaryColor,
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

  Map<String, Widget Function(BuildContext)> _buildRoutes() {
    return {
      '/': (context) => const LoginScreen(),
      '/dashboard': (context) => DashboardScreen(),
      '/profil': (context) => const ProfilePage(),
      '/history': (context) => const HistoryScreen(),
      '/notification': (context) => const NotificationSettingsScreen(),
    };
  }
}
