import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  final List<String> userHabits;

  const StatsScreen({super.key, required this.userHabits});

  @override
  Widget build(BuildContext context) {
    int total = userHabits.length;
    double progressValue = total == 0 ? 0 : 0.5;
    int completedCount = (total * progressValue).round();
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Tu Progreso 📊',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _card(
              context,
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 70,
                        width: 70,
                        child: CircularProgressIndicator(
                          value: progressValue,
                          strokeWidth: 8,
                          color: const Color(0xFF7B2FF7),
                          backgroundColor: isDark
                              ? Colors.white10
                              : Colors.grey[200],
                        ),
                      ),
                      Text(
                        '${(progressValue * 100).toInt()}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cumplimiento',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$completedCount de $total hábitos',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _card(
              context,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Progreso semanal',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _bar('L', total > 0 ? 0.4 : 0.1),
                      _bar('M', total > 0 ? 0.6 : 0.1),
                      _bar('M', total > 0 ? 0.8 : 0.1),
                      _bar('J', 1.0),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
              children: [
                _smallStat(
                  context,
                  'Hábitos',
                  '$total activos',
                  Icons.list,
                  Colors.blue,
                ),
                _smallStat(
                  context,
                  'Racha',
                  '3 días',
                  Icons.fireplace,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, Widget child) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: child,
  );

  Widget _bar(String label, double height) => Column(
    children: [
      Container(
        width: 25,
        height: 80 * height,
        decoration: BoxDecoration(
          color: const Color(0xFF7B2FF7),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      const SizedBox(height: 5),
      Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
    ],
  );

  Widget _smallStat(
    BuildContext context,
    String title,
    String val,
    IconData icon,
    Color col,
  ) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Center(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: col, size: 20),
        title: Text(
          title,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        subtitle: Text(
          val,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );
}
