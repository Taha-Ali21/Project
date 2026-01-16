import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. Added Auth import

// Your project name is 'project' according to your pubspec.yaml
import 'package:project/firebase_options.dart';

import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_habit_screen.dart';
import 'screens/habit_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  await initializeDateFormatting('es', null);
  runApp(const ThriveApp());
}

class ThriveApp extends StatefulWidget {
  const ThriveApp({super.key});

  @override
  State<ThriveApp> createState() => _ThriveAppState();
}

class _ThriveAppState extends State<ThriveApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thrive Habit Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7B2FF7)),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF7B2FF7),
        ),
      ),
      themeMode: _themeMode,
      // 2. Removed initialRoute because we use a StreamBuilder for 'home'
      home: StreamBuilder<User?>(
        // This listens to changes in login/logout status in real-time
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // While Firebase is checking the login status, show a loading circle
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // If a user is found in the stream, go directly to HomeScreen
          if (snapshot.hasData) {
            return HomeScreen(
              isDarkMode: _themeMode == ThemeMode.dark,
              onThemeChanged: _toggleTheme,
            );
          }

          // If no user is found, show the Welcome/Login flow
          return const WelcomeScreen();
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => HomeScreen(
          isDarkMode: _themeMode == ThemeMode.dark,
          onThemeChanged: _toggleTheme,
        ),
        '/add-habit': (context) => const AddHabitScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/habit-detail') {
          final String habitName = settings.arguments as String? ?? '';
          return MaterialPageRoute(
            builder: (context) => HabitDetailScreen(habitName: habitName),
          );
        }
        return null;
      },
    );
  }
}
