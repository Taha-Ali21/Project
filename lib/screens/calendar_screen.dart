import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  final List<String> userHabits;
  const CalendarScreen({super.key, required this.userHabits});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _viewDate = DateTime(2026, 1);
  DateTime _selectedDay = DateTime.now();

  int get _daysInMonth =>
      DateUtils.getDaysInMonth(_viewDate.year, _viewDate.month);

  // FIXED: Improved offset calculation to prevent negative values or alignment shifts
  int get _firstDayOffset {
    int weekday = DateTime(_viewDate.year, _viewDate.month, 1).weekday;
    return weekday - 1; // Adjusts so Monday is the first column
  }

  void _changeMonth(int increment) {
    setState(() {
      _viewDate = DateTime(_viewDate.year, _viewDate.month + increment);
    });
  }

  @override
  Widget build(BuildContext context) {
    String monthLabel = DateFormat('MMMM yyyy', 'es').format(_viewDate);
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Calendario 📅',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => _changeMonth(-1),
                      ),
                      Text(
                        monthLabel[0].toUpperCase() + monthLabel.substring(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => _changeMonth(1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // FIXED: Added .toList() and proper children list brackets
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
                        .map(
                          (day) => Text(
                            day,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  _buildCalendarGrid(isDark),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Text(
              'Hábitos para el ${DateFormat('d \'de\' MMMM', 'es').format(_selectedDay)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            widget.userHabits.isEmpty
                ? const Text(
                    'No hay hábitos registrados.',
                    style: TextStyle(color: Colors.grey),
                  )
                : Column(
                    children: widget.userHabits
                        .map((habit) => _buildDayHabitTile(habit))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
      ),
      itemCount: _daysInMonth + _firstDayOffset,
      itemBuilder: (context, index) {
        if (index < _firstDayOffset) return const SizedBox.shrink();

        int day = index - _firstDayOffset + 1;
        DateTime currentDay = DateTime(_viewDate.year, _viewDate.month, day);
        bool isSelected =
            _selectedDay.year == currentDay.year &&
            _selectedDay.month == currentDay.month &&
            _selectedDay.day == currentDay.day;

        return GestureDetector(
          onTap: () => setState(() => _selectedDay = currentDay),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF7B2FF7) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : Colors.grey.withOpacity(0.1),
              ),
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black87),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayHabitTile(String title) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.circle, size: 12, color: Color(0xFF7B2FF7)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, size: 18),
      ),
    );
  }
}
