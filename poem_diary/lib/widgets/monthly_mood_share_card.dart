import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/poem_model.dart';

class MonthlyMoodShareCard extends StatelessWidget {
  final DateTime month;
  final Map<int, MoodCategory> dailyMoods;
  final String userName; // Optional: "Yadeliya's Mood Diary"
  final Map<String, MoodCategory> moodDefinitions; // For colors/icons
  final Map<String, String> localizedLabels; // For translated names
  final String locale; // e.g. 'tr' or 'en'
  final String footerText; // "Created with Poem Diary"

  const MonthlyMoodShareCard({
    super.key,
    required this.month,
    required this.dailyMoods,
    this.userName = 'Poem Diary',
    required this.moodDefinitions,
    required this.localizedLabels,
    required this.locale,
    required this.footerText,
  });

  @override
  Widget build(BuildContext context) {
    // Fixed dimensions for better social media sharing (e.g., Instagram Story/Post)
    // Using a 4:5 ratio or square is usually good, but we'll let it size by content
    // and wrap it in a container with a nice background.

    return Container(
      width: 400, // Fixed width to ensure consistency in screenshots
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA), // Clean off-white background
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMMM', locale).format(month).toUpperCase(),
                    style: GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    DateFormat('yyyy', locale).format(month),
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Icon(Icons.auto_awesome, color: Colors.amber, size: 32),
            ],
          ),

          const SizedBox(height: 24),

          // 2. The Calendar Grid
          // We need to calculate offset for the first day of the month
          _buildCalendarGrid(),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // 3. Legend (Top used moods)
          _buildLegend(),

          const SizedBox(height: 24),

          // 4. Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.edit_note, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                footerText,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    // Calendar logic
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);

    // 1 = Monday, 7 = Sunday (DateTime standard)
    // We want Monday start? Usually calendars are Monday or Sunday.
    // Let's assume Monday start for Turkey context usually.
    final firstWeekday = firstDayOfMonth.weekday; // 1 (Mon) to 7 (Sun)

    // Calculation:
    // Empty cells before 1st day: (firstWeekday - 1)

    final int offset = firstWeekday - 1;
    final int totalCells = offset + daysInMonth;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, // 7 Days a week
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        if (index < offset) {
          return const SizedBox(); // Empty cell
        }

        final dayNum = index - offset + 1;
        final mood = dailyMoods[dayNum];

        return Container(
          decoration: BoxDecoration(
            color: mood?.color ?? Colors.grey.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: mood == null
                ? Border.all(color: Colors.grey.withValues(alpha: 0.2))
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '$dayNum',
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: mood != null ? Colors.white : Colors.grey,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend() {
    // 1. Calculate Stats
    final totalEntries = dailyMoods.length;
    if (totalEntries == 0) return const SizedBox();

    final Map<String, int> counts = {};
    for (var mood in dailyMoods.values) {
      counts[mood.code] = (counts[mood.code] ?? 0) + 1;
    }

    // 2. Sort by Percentage (Highest first)
    final sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // 3. Take Top 4
    final topEntries = sortedEntries.take(4).toList();

    return Wrap(
      spacing: 16,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: topEntries.map((entry) {
        final code = entry.key;
        final count = entry.value;
        final mood = moodDefinitions[code];
        final name = localizedLabels[code] ?? mood?.name ?? code;
        final percentage = ((count / totalEntries) * 100).toInt();

        if (mood == null) return const SizedBox();

        return IntrinsicWidth(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: mood.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: mood.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "$name: %$percentage",
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
