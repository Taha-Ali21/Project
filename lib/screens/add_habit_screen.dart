import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. Import Auth to identify the user

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final TextEditingController _controller = TextEditingController();
  String _frecuencia = 'Diaria';
  bool _recordatorio = false;

  // 2. Updated Save Function for Unlimited Multi-user support
  Future<void> _saveHabit() async {
    if (_controller.text.isEmpty) return;

    // Get the unique ID of the person currently logged in
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Path matches your console: User -> {UID} -> habits -> {Auto-Generated ID}
        await FirebaseFirestore.instance
            .collection('User') // Matches your capitalized collection name
            .doc(user.uid) // Directs data to the private folder of this user
            .collection('habits')
            .add({
              'title': _controller.text,
              'frequency': _frecuencia,
              'reminder': _recordatorio,
              'isCompleted': false,
              'createdAt':
                  FieldValue.serverTimestamp(), // Used to sort unlimited lists
            });

        if (mounted) {
          Navigator.pop(context); // Go back to Home Screen after success
        }
      } catch (e) {
        debugPrint("Error saving to Firebase: $e");
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error al guardar: $e")));
        }
      }
    } else {
      // If no user is found, the data cannot be saved
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: No se encontró un usuario activo"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode
        ? const Color(0xFF121212)
        : const Color(0xFFF6F7FB);
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color inputFillColor = isDarkMode
        ? const Color(0xFF2C2C2C)
        : Colors.grey[100]!;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color tipBgColor = isDarkMode
        ? Colors.blueGrey.withOpacity(0.2)
        : Colors.blue[50]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Crear nuevo hábito', style: TextStyle(color: textColor)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nombre del hábito',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _controller,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Ej. Beber 2L de agua',
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.grey : Colors.black38,
                      ),
                      filled: true,
                      fillColor: inputFillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Frecuencia',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  DropdownButton<String>(
                    value: _frecuencia,
                    isExpanded: true,
                    dropdownColor: cardColor,
                    iconEnabledColor: textColor,
                    underline: Container(
                      height: 1,
                      color: isDarkMode ? Colors.grey : Colors.grey[300],
                    ),
                    items: ['Diaria', 'Semanal', 'Mensual'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(color: textColor)),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _frecuencia = val!),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recordatorio',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Switch(
                        activeColor: const Color(0xFF7B2FF7),
                        value: _recordatorio,
                        onChanged: (val) => setState(() => _recordatorio = val),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _saveHabit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B2FF7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Guardar hábito',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildTipsCard(tipBgColor, textColor, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard(Color bgColor, Color textColor, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                ' Consejos',
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '• Sé específico: "Caminar 30 min" es mejor que "Hacer ejercicio"',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          Text(
            '• Empieza pequeño: 5 min diarios es mejor que 1 hora semanal',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
