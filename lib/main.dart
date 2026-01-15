import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_habit_screen.dart';
import 'screens/habit_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  runApp(const ThriveApp());
}

// Convert to StatefulWidget to manage global Dark Mode state
class ThriveApp extends StatefulWidget {
  const ThriveApp({super.key});

  @override
  State<ThriveApp> createState() => _ThriveAppState();
}

class _ThriveAppState extends State<ThriveApp> {
  // Theme state: default to Light
  ThemeMode _themeMode = ThemeMode.light;

  // Function to toggle the theme across the whole app
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

      // LIGHT THEME
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7B2FF7),
          surface: const Color(0xFFF6F7FB),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: Colors.white,
        ),
      ),

      // DARK THEME
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF7B2FF7),
          surface: const Color(0xFF121212),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: const Color(0xFF1E1E1E), // Slightly lighter than background
        ),
      ),

      // Current active mode
      themeMode: _themeMode,

      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        // Pass theme data to HomeScreen so Profile can use it
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
