import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/providers.dart';
import '../models/poem_model.dart';
import '../models/daily_entry_model.dart';

class MoodCalendarScreen extends StatefulWidget {
  const MoodCalendarScreen({Key? key}) : super(key: key);

  @override
  State<MoodCalendarScreen> createState() => _MoodCalendarScreenState();
}

class _MoodCalendarScreenState extends State<MoodCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    // Determine theme brightness for text colors
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final offColor = isDarkMode ? Colors.white54 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor, // Explicit background color
      appBar: AppBar(
        title: Text(
          'Ruh Takvimi',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: textColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Consumer<MoodProvider>(
        builder: (context, moodProvider, child) {
          return Column(
            children: [
              // Calendar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TableCalendar(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });

                    // Show Journal Entry
                    _showDayDetails(context, selectedDay, moodProvider);
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },

                  // STYLING UPDATES
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: GoogleFonts.nunito(color: offColor),
                    weekendStyle: GoogleFonts.nunito(color: Colors.redAccent),
                  ),

                  calendarStyle: CalendarStyle(
                    defaultTextStyle: GoogleFonts.nunito(color: textColor),
                    weekendTextStyle: GoogleFonts.nunito(
                      color: Colors.redAccent,
                    ),
                    outsideTextStyle: GoogleFonts.nunito(color: offColor),
                    todayDecoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      shape: BoxShape.circle,
                    ),
                  ),

                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    leftChevronIcon: Icon(Icons.chevron_left, color: textColor),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: textColor,
                    ),
                  ),

                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return _buildMoodCell(context, day, moodProvider);
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      return _buildMoodCell(
                        context,
                        day,
                        moodProvider,
                        isSelected: true,
                      );
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return _buildMoodCell(
                        context,
                        day,
                        moodProvider,
                        isToday: true,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),
              // Legend (Key) - Moved to Bottom
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50.0,
                  vertical: 10.0,
                ),
                child: GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.3,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  children: moodProvider.moods
                      .where((m) => m.code.isNotEmpty)
                      .map((mood) {
                        final color = _getMoodColor(mood.code);
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              mood.name,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: textColor.withOpacity(0.8),
                              ),
                            ),
                          ],
                        );
                      })
                      .toList(),
                ),
              ),
              const Spacer(),

              // Daily Check-in Button (if not focused on past)
              // Actually, HomeScreen handles the check-in mostly, but nice to have here too maybe?
              // Leaving it clean for now as requested.
            ],
          );
        },
      ),
    );
  }

  Color _getMoodColor(String moodCode) {
    switch (moodCode) {
      case 'sad':
        return Colors.blue[300]!;
      case 'happy':
        return Colors.yellow[300]!; // Darker yellow for visibility
      case 'romantic':
        return Colors.pink[300]!;
      case 'mystic':
        return Colors.purple[300]!;
      case 'tired':
        return Colors.grey[400]!;
      case 'hopeful':
        return Colors.green[300]!;
      case 'peaceful':
        return Colors.cyan[300]!;
      case 'nostalgic':
        return Colors.orange[300]!;
      default:
        return Colors.blueGrey[200]!;
    }
  }

  void _showDayDetails(
    BuildContext context,
    DateTime date,
    MoodProvider provider,
  ) {
    final entry = provider.getEntryForDate(date);
    if (entry == null && provider.getMoodForDate(date) == null) {
      // No Data
      return;
    }

    // Prepare Data
    final moodCode = entry?.moodCode ?? provider.getMoodForDate(date);
    final note = entry?.note;

    // Find Mood Object
    final mood = provider.moods.firstWhere(
      (m) => m.code == moodCode,
      orElse: () => MoodCategory(
        id: '',
        code: '',
        name: 'Bilinmiyor',
        emoji: '❓',
        description: '',
        backgroundGradient: '',
      ),
    );

    if (mood.code.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: Icon + Date
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getMoodColor(mood.code),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      mood.emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mood.name,
                        style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        "${date.day}.${date.month}.${date.year}",
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Close details
                      _showEntryDialog(
                        context,
                        date,
                        provider,
                        currentMood: moodCode,
                        currentNote: note,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Note Content
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black12 : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  note != null && note.isNotEmpty
                      ? note
                      : 'Bugün için eklenen bir not yok.',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    height: 1.5,
                    fontStyle: note != null && note.isNotEmpty
                        ? FontStyle.normal
                        : FontStyle.italic,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showEntryDialog(
    BuildContext context,
    DateTime date,
    MoodProvider provider, {
    String? currentMood,
    String? currentNote,
  }) {
    // Determine initial mood if editing
    MoodCategory? selectedMood;
    if (currentMood != null) {
      try {
        selectedMood = provider.moods.firstWhere((m) => m.code == currentMood);
      } catch (e) {
        selectedMood = null;
      }
    }

    // Use a ValueNotifier for local state (mood selection)
    final moodNotifier = ValueNotifier<MoodCategory?>(selectedMood);
    final noteController = TextEditingController(text: currentNote);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
              ),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      // 1. Header: Close + Date + Save
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Text(
                              "${date.day}.${date.month}.${date.year}",
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                if (moodNotifier.value == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Lütfen bir mod seçin',
                                        style: GoogleFonts.nunito(),
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                provider.saveDailyEntry(
                                  date,
                                  moodNotifier.value!.code,
                                  noteController.text,
                                );
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Günlük kaydedildi.',
                                      style: GoogleFonts.nunito(
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Text(
                                'KAYDET',
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 2. Mood Selector (Just below header)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: provider.moods
                                .where((m) => m.code.isNotEmpty)
                                .map((mood) {
                                  final isSelected =
                                      moodNotifier.value?.code == mood.code;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        moodNotifier.value = mood;
                                      });
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? _getMoodColor(mood.code)
                                                : Colors.transparent,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.transparent
                                                  : Colors.grey.withOpacity(
                                                      0.3,
                                                    ),
                                            ),
                                          ),
                                          child: Text(
                                            mood.emoji,
                                            style: TextStyle(
                                              fontSize: isSelected ? 28 : 24,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          mood.name,
                                          style: GoogleFonts.nunito(
                                            fontSize: 10,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? (isDark
                                                      ? Colors.white
                                                      : Colors.black87)
                                                : (isDark
                                                      ? Colors.white54
                                                      : Colors.black54),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ),
                      ),

                      // 3. Expanded Text Field (The "Clean Paper")
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 16.0,
                          ),
                          child: TextField(
                            controller: noteController,
                            expands: true, // Fills the space
                            maxLines: null,
                            minLines: null,
                            keyboardType: TextInputType.multiline,
                            textAlignVertical: TextAlignVertical.top,
                            style: GoogleFonts.lora(
                              // Reader font (Serif) looks nice for journals
                              fontSize: 18,
                              height: 1.6,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Bugün seni böyle hissettiren ne? İçini dök...',
                              hintStyle: GoogleFonts.lora(
                                color: isDark ? Colors.white24 : Colors.black26,
                                fontStyle: FontStyle.italic,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom +
                                    20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget? _buildMoodCell(
    BuildContext context,
    DateTime day,
    MoodProvider provider, {
    bool isSelected = false,
    bool isToday = false,
  }) {
    final String? moodCode = provider.getMoodForDate(day);

    // Normal text style
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    if (moodCode != null) {
      final color = _getMoodColor(moodCode);

      // Determine text color based on background luminance for readability
      final isLightBg =
          ThemeData.estimateBrightnessForColor(color) == Brightness.light;
      final cellTextColor = isLightBg ? Colors.black87 : Colors.white;

      return Container(
        margin: const EdgeInsets.all(4.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected || isToday
              ? Border.all(color: textColor, width: 2)
              : null,
        ),
        child: Text(
          '${day.day}',
          style: GoogleFonts.nunito(
            color: cellTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // Default styling for non-mood days
    if (isSelected || isToday) {
      return Container(
        margin: const EdgeInsets.all(4.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColor.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Text(
          '${day.day}',
          style: GoogleFonts.nunito(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return null; // Use default
  }
}
