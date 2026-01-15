import 'package:flutter/material.dart';
import 'dart:math';
import 'add_habit_screen.dart';
import 'habit_detail_screen.dart';
import 'stats_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  // FIXED: Added required parameters to fix main.dart errors
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> habits = [];
  int _selectedIndex = 0;
  String userName = "María";

  final List<String> allQuotes = [
    "Pequeños pasos crean grandes cambios",
    "La disciplina es libertad",
    "No te detengas hasta sentirte orgulloso",
    "El éxito es la suma de pequeños esfuerzos",
    "Haz hoy lo que tu futuro yo agradecerá",
    "La constancia es la clave",
    "Tu única competencia eres tú mismo",
    "Un día a la vez",
    "Cree en ti y todo será posible",
    "La motivación te ayuda a empezar, el hábito te mantiene",
    "El mejor momento para plantar un árbol fue hace 20 años; el segundo mejor es ahora",
    "Gana la mañana, gana el día",
    "Cada paso cuenta",
    "Persiste y vencerás",
    "Transforma tus sueños en hábitos",
  ];

  late List<String> currentQuotes;

  @override
  void initState() {
    super.initState();
    _randomizeQuotes();
  }

  void _randomizeQuotes() {
    final random = Random();
    var shuffled = List<String>.from(allQuotes)..shuffle(random);
    currentQuotes = shuffled.take(3).toList();
  }

  // FIXED: Properly passing global theme state to ProfileScreen
  List<Widget> _getPages() {
    return [
      _buildHomeContent(),
      StatsScreen(userHabits: habits),
      CalendarScreen(userHabits: habits),
      ProfileScreen(
        userHabits: habits,
        userName: userName,
        isDarkMode: widget.isDarkMode, // Passed from main.dart
        onThemeChanged: widget.onThemeChanged, // Passed from main.dart
        onNameChanged: (newName) {
          setState(() {
            userName = newName;
          });
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = _getPages();

    return Scaffold(
      // Removed hardcoded background color to support Night Mode automatically
      body: pages[_selectedIndex],

      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF7B2FF7),
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddHabitScreen(),
                  ),
                );
                if (result != null && result is String) {
                  setState(() {
                    habits.add(result);
                    _randomizeQuotes();
                  });
                }
              },
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF7B2FF7),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, $userName 👋',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Viernes, 16 de Enero de 2026',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mis Hábitos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (habits.isNotEmpty)
                  Text(
                    '${habits.length} hábitos activos',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
              ],
            ),
            const SizedBox(height: 15),
            habits.isEmpty
                ? _buildEmptyState()
                : Column(
                    children: habits.map((h) => _buildHabitItem(h)).toList(),
                  ),
            const SizedBox(height: 30),
            const Text(
              'Inspiración para hoy',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: currentQuotes
                  .map(
                    (q) => Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(
                          '"$q"',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(Icons.inbox_outlined, color: Colors.grey, size: 50),
          SizedBox(height: 10),
          Text(
            'No hay hábitos para hoy',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Tus hábitos aparecerán aquí',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitItem(String title) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: const Icon(
          Icons.check_circle_outline,
          color: Color(0xFF7B2FF7),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text(
          '🔥 Racha: 0 días • Diaria',
          style: TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HabitDetailScreen(habitName: title),
            ),
          );
          if (result == 'delete') {
            setState(() {
              habits.remove(title);
            });
          }
        },
      ),
    );
  }
}
