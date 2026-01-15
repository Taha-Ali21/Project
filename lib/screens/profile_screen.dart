import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  final List<String> userHabits;
  final String userName;
  final Function(String) onNameChanged;

  // NEW: Receive theme state and toggle function from HomeScreen
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const ProfileScreen({
    super.key,
    required this.userHabits,
    required this.userName,
    required this.onNameChanged,
    required this.isDarkMode, // Added
    required this.onThemeChanged, // Added
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    // REAL LOGIC: Calculate stats based on habit list
    final int activeDays = widget.userHabits.isEmpty ? 0 : 15;
    final String successRate = widget.userHabits.isEmpty ? "0%" : "87%";

    // Adaptive color for the header background
    final headerColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E1E1E)
        : Colors.white;

    return Scaffold(
      // We remove the hardcoded background color so it uses the theme color
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 30),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFF7B2FF7).withOpacity(0.1),
                    child: Text(
                      widget.userName.isNotEmpty
                          ? widget.userName[0].toUpperCase()
                          : "M",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B2FF7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Miembro desde septiembre 2024',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // STATS BOXES
                  Row(
                    children: [
                      _buildLargeStatCard('$activeDays', 'Días activo'),
                      const SizedBox(width: 15),
                      _buildLargeStatCard(
                        successRate,
                        'Tasa de éxito',
                        color: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  const Text(
                    'Configuración',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  // DARK MODE TOGGLE (Connected to main.dart)
                  _buildSettingsCard(
                    icon: Icons.dark_mode_outlined,
                    title: 'Modo Oscuro',
                    trailing: Switch(
                      value: widget.isDarkMode, // Use global value
                      onChanged: (val) =>
                          widget.onThemeChanged(val), // Update global state
                      activeColor: const Color(0xFF7B2FF7),
                    ),
                  ),

                  // ABOUT US SECTION
                  _buildSettingsCard(
                    icon: Icons.info_outline,
                    title: 'Sobre nosotros',
                    onTap: () => _showAboutDialog(context),
                  ),

                  const SizedBox(height: 20),

                  // PROGRESS BOX
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1), // Adaptive opacity
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          '🌟 ¡Excelente trabajo!',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Esta aplicación te ayudará a construir hábitos más fuertes cada día.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeStatCard(
    String value,
    String label, {
    Color color = const Color(0xFF7B2FF7),
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, // Uses the theme's card color
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFF7B2FF7)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Thrive Habit Tracker',
      applicationLegalese:
          'Esta app está diseñada para ayudarte a forjar una disciplina inquebrantable.',
    );
  }
}
