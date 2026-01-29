import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'add_habit_screen.dart';
import 'habit_detail_screen.dart';
import 'stats_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
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
  int _selectedIndex = 0;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  late String userName;

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
    userName = currentUser?.displayName ?? "Usuario";
  }

  void _randomizeQuotes() {
    final random = Random();
    var shuffled = List<String>.from(allQuotes)..shuffle(random);
    currentQuotes = shuffled.take(3).toList();
  }

  String getTodayDate() {
    final now = DateTime.now();
    final formatted = DateFormat(
      "EEEE, d 'de' MMMM 'de' y",
      'es_ES',
    ).format(now);

    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  List<Widget> _getPages() {
    return [
      _buildHomeContent(),
      const StatsScreen(userHabits: []),
      const CalendarScreen(userHabits: []),
      ProfileScreen(
        userHabits: const [],
        userName: userName,
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
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
    return Scaffold(
      body: _getPages()[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF7B2FF7),
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddHabitScreen(),
                  ),
                );
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
            Text(
              getTodayDate(),
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 30),
            const Text(
              'Mis Hábitos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('User')
                  .doc(currentUser?.uid)
                  .collection('habits')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final habitDocs = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: habitDocs.length,
                  itemBuilder: (context, index) {
                    final data =
                        habitDocs[index].data() as Map<String, dynamic>;
                    return _buildHabitItem(
                      habitDocs[index].id,
                      data['title'] ?? 'Sin nombre',
                      data['isCompleted'] ?? false,
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 30),
            const Text(
              'Inspiración para hoy',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...currentQuotes.map(
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
        ],
      ),
    );
  }

  Widget _buildHabitItem(String docId, String title, bool isCompleted) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: IconButton(
          icon: Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: const Color(0xFF7B2FF7),
          ),
          onPressed: () {
            FirebaseFirestore.instance
                .collection('User')
                .doc(currentUser?.uid)
                .collection('habits')
                .doc(docId)
                .update({'isCompleted': !isCompleted});
          },
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text(
          '🔥 Racha: 0 días • Diaria',
          style: TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HabitDetailScreen(habitName: title),
            ),
          );
        },
      ),
    );
  }
}
