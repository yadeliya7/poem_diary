import 'dart:io';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/providers.dart';
import '../core/language_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/poem_model.dart';
import '../models/daily_entry_model.dart';
import '../widgets/mood_entry_dialog.dart';
import '../widgets/monthly_mood_share_card.dart';
import 'package:line_icons/line_icons.dart';

class MoodCalendarScreen extends StatefulWidget {
  const MoodCalendarScreen({super.key});

  @override
  State<MoodCalendarScreen> createState() => _MoodCalendarScreenState();
}

class _MoodCalendarScreenState extends State<MoodCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;

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
          Provider.of<LanguageProvider>(context).translate('calendar_title'),
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
        actions: [
          IconButton(
            icon: Icon(_isSharing ? Icons.hourglass_empty : Icons.ios_share),
            onPressed: () => _isSharing ? null : _shareMonth(context),
            tooltip: 'Ayı Paylaş',
          ),
        ],
      ),
      body: Consumer<MoodProvider>(
        builder: (context, moodProvider, child) {
          return Column(
            children: [
              // Calendar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TableCalendar(
                  locale:
                      Provider.of<LanguageProvider>(context).currentLanguage ==
                          'tr'
                      ? 'tr_TR'
                      : 'en_US',
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    // Future Check
                    if (selectedDay.isAfter(DateTime.now())) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            Provider.of<LanguageProvider>(
                              context,
                              listen: false,
                            ).translate('future_warning'),
                            style: GoogleFonts.nunito(color: Colors.white),
                          ),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });

                    // Open Entry Dialog directly if no entry exists, or Details if exists
                    final hasEntry =
                        moodProvider.getEntryForDate(selectedDay) != null;

                    if (hasEntry) {
                      _showDayDetails(context, selectedDay, moodProvider);
                    } else {
                      showMoodEntryDialog(
                        context,
                        date: selectedDay,
                        provider: moodProvider,
                      );
                    }
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
                    todayTextStyle: GoogleFonts.nunito(
                      color: isDarkMode ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    todayDecoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.white
                          : Colors.black, // White Moon
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
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
                              Provider.of<LanguageProvider>(
                                context,
                              ).translate('mood_${mood.code}'),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: textColor.withValues(alpha: 0.8),
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

  String _getMonthName(int month) {
    try {
      final langCode = Provider.of<LanguageProvider>(
        context,
        listen: false,
      ).currentLanguage;
      final locale = langCode == 'tr' ? 'tr_TR' : 'en_US';
      // Create a dummy date for the month
      final date = DateTime(2024, month, 1);
      return DateFormat('MMMM', locale).format(date);
    } catch (e) {
      return '';
    }
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

  Future<void> _shareMonth(BuildContext context) async {
    setState(() => _isSharing = true);
    final provider = Provider.of<MoodProvider>(context, listen: false);
    final lang = Provider.of<LanguageProvider>(context, listen: false);

    try {
      // 1. Gather Data for the Card
      final Map<int, MoodCategory> dailyMoods = {};
      final daysInMonth = DateUtils.getDaysInMonth(
        _focusedDay.year,
        _focusedDay.month,
      );

      for (int i = 1; i <= daysInMonth; i++) {
        final date = DateTime(_focusedDay.year, _focusedDay.month, i);
        final entry = provider.getEntryForDate(date);

        if (entry != null) {
          final mood = provider.moods.firstWhere(
            (m) => m.code == entry.moodCode,
            orElse: () => MoodCategory(
              id: '',
              code: '',
              name: '',
              emoji: '',
              description: '',
              backgroundGradient: '',
              color: Colors.grey,
            ),
          );
          if (mood.code.isNotEmpty) {
            dailyMoods[i] = mood;
          }
        }
      }

      // 2. Build Legend Definition
      final Map<String, MoodCategory> definitions = {
        for (var m in provider.moods.where((x) => x.code.isNotEmpty)) m.code: m,
      };

      // 3. Build Localized Labels
      final Map<String, String> localizedLabels = {
        for (var m in provider.moods.where((x) => x.code.isNotEmpty))
          m.code: lang.translate('mood_${m.code}'),
      };

      // 4. Generate Image
      final imageBytes = await _screenshotController.captureFromWidget(
        MonthlyMoodShareCard(
          month: _focusedDay,
          dailyMoods: dailyMoods,
          moodDefinitions: definitions,
          localizedLabels: localizedLabels,
          locale: lang.currentLanguage == 'tr' ? 'tr_TR' : 'en_US',
          footerText: "${lang.translate('created_with')} Poem Diary",
        ),
        delay: const Duration(milliseconds: 100),
        context: context,
      );

      // 4. Save to Temp
      final directory = await getTemporaryDirectory();
      final imagePath =
          '${directory.path}/mood_calendar_${_focusedDay.year}_${_focusedDay.month}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);

      // 5. Share
      if (!mounted) return;
      await Share.shareXFiles([
        XFile(imagePath),
      ], text: 'Bu ayki duygu takvimim! 📅✨ #PoemDiary');
    } catch (e) {
      debugPrint('Share Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Paylaşım hatası: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
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
        name: Provider.of<LanguageProvider>(
          context,
          listen: false,
        ).translate('mood_unknown'),
        emoji: '❓',
        description: '',
        backgroundGradient: '',
        color: Colors.grey,
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
                        Provider.of<LanguageProvider>(
                          context,
                        ).translate('mood_${mood.code}'),
                        style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        "${date.day} ${_getMonthName(date.month)} ${date.year}",
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
                      showMoodEntryDialog(
                        context,
                        date: date,
                        provider: provider,
                        currentMood: moodCode,
                        currentNote: note,
                        currentMedia: entry?.mediaPaths ?? [],
                        currentActivities: entry?.activities ?? {},
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Activity Chips
              if (entry != null && entry.activities.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: _buildWrapIcons(entry),
                ),

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
                      : Provider.of<LanguageProvider>(
                          context,
                        ).translate('no_note'),
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

              // Media Display
              if (entry?.mediaPaths != null && entry!.mediaPaths.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: entry.mediaPaths.length,
                      itemBuilder: (context, index) {
                        final path = entry.mediaPaths[index];
                        final ext = path.split('.').last.toLowerCase();
                        final isImage = [
                          'jpg',
                          'jpeg',
                          'png',
                          'heic',
                          'webp',
                        ].contains(ext);

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              if (!isImage) return;
                              showDialog(
                                context: context,
                                builder: (ctx) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: InteractiveViewer(
                                    child: Image.file(File(path)),
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: buildMediaThumbnail(path),
                            ),
                          ),
                        );
                      },
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

  Widget? _buildMoodCell(
    BuildContext context,
    DateTime day,
    MoodProvider provider, {
    bool isSelected = false,
    bool isToday = false,
  }) {
    final String? moodCode = provider.getMoodForDate(day);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // "White Moon" Logic
    final todayColor = isDarkMode ? Colors.white : Colors.black;
    final todayTextColor = isDarkMode ? Colors.black : Colors.white;

    if (moodCode != null) {
      final color = _getMoodColor(moodCode);
      final isLightBg =
          ThemeData.estimateBrightnessForColor(color) == Brightness.light;
      final cellTextColor = isLightBg ? Colors.black87 : Colors.white;

      return Container(
        margin: const EdgeInsets.all(4.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          // Today with Mood -> White/Black Border
          border: isToday
              ? Border.all(color: todayColor, width: 3)
              : (isSelected ? Border.all(color: Colors.white, width: 2) : null),
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

    // No Mood
    if (isToday) {
      return Container(
        margin: const EdgeInsets.all(4.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: todayColor, // Solid White/Black
          shape: BoxShape.circle,
        ),
        child: Text(
          '${day.day}',
          style: GoogleFonts.nunito(
            color: todayTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (isSelected) {
      return Container(
        margin: const EdgeInsets.all(4.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.pinkAccent,
          shape: BoxShape.circle,
        ),
        child: Text(
          '${day.day}',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return null; // Use default
  }

  // Copied from HomeTab for consistency. Consider moving to a shared widget.
  Widget _buildWrapIcons(DailyEntry entry) {
    List<Widget> chips = [];

    Widget makeChip(IconData icon, Color color, String label) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.nunito(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    final act = entry.activities;

    if (act['sleep'] == 'good') {
      chips.add(makeChip(LineIcons.sun, Colors.orange, 'İyi Uyku'));
    }
    if (act['sleep'] == 'medium') {
      chips.add(
        makeChip(LineIcons.cloudWithMoon, Colors.blueGrey, 'Orta Uyku'),
      );
    }
    if (act['sleep'] == 'bad') {
      chips.add(makeChip(LineIcons.moon, Colors.indigo, 'Kötü Uyku'));
    }

    if (act['weather'] == 'sunny') {
      chips.add(makeChip(LineIcons.sun, Colors.amber, 'Güneşli'));
    }
    if (act['weather'] == 'rainy') {
      chips.add(makeChip(LineIcons.cloudWithRain, Colors.blue, 'Yağmurlu'));
    }
    if (act['weather'] == 'cloudy') {
      chips.add(makeChip(LineIcons.cloud, Colors.grey, 'Bulutlu'));
    }
    if (act['weather'] == 'snowy') {
      chips.add(makeChip(LineIcons.snowflake, Colors.lightBlueAccent, 'Karlı'));
    }

    // LIST HELPERS
    List<String> listFrom(dynamic v) =>
        (v as List?)?.map((e) => e.toString()).toList() ?? [];

    final health = listFrom(act['health']);
    if (health.contains('sport')) {
      chips.add(makeChip(LineIcons.running, Colors.green, 'Spor'));
    }
    if (health.contains('healthy_food')) {
      chips.add(makeChip(LineIcons.carrot, Colors.greenAccent, 'Sağlıklı'));
    }
    if (health.contains('fast_food')) {
      chips.add(
        makeChip(LineIcons.hamburger, Colors.orangeAccent, 'Fast Food'),
      );
    }
    if (health.contains('water')) {
      chips.add(makeChip(LineIcons.tint, Colors.blueAccent, 'Su'));
    }

    final social = listFrom(act['social']);
    if (social.contains('friends')) {
      chips.add(makeChip(LineIcons.userFriends, Colors.purple, 'Arkadaşlar'));
    }
    if (social.contains('family')) {
      chips.add(makeChip(LineIcons.home, Colors.brown, 'Aile'));
    }
    if (social.contains('party')) {
      chips.add(makeChip(LineIcons.cocktail, Colors.deepPurple, 'Parti'));
    }
    if (social.contains('partner')) {
      chips.add(makeChip(LineIcons.heartAlt, Colors.red, 'Partner'));
    }

    final hobbies = listFrom(act['hobbies']);
    if (hobbies.contains('gaming')) {
      chips.add(makeChip(LineIcons.gamepad, Colors.indigoAccent, 'Oyun'));
    }
    if (hobbies.contains('reading')) {
      chips.add(makeChip(LineIcons.book, Colors.brown, 'Okuma'));
    }
    if (hobbies.contains('movie')) {
      chips.add(makeChip(LineIcons.video, Colors.redAccent, 'Film'));
    }
    if (hobbies.contains('art')) {
      chips.add(makeChip(LineIcons.palette, Colors.pinkAccent, 'Sanat'));
    }

    final chores = listFrom(act['chores']);
    if (chores.contains('cleaning')) {
      chips.add(makeChip(LineIcons.broom, Colors.teal, 'Temizlik'));
    }
    if (chores.contains('shopping')) {
      chips.add(makeChip(LineIcons.shoppingCart, Colors.orange, 'Alışveriş'));
    }
    if (chores.contains('laundry')) {
      chips.add(makeChip(LineIcons.tShirt, Colors.blueGrey, 'Çamaşır'));
    }
    if (chores.contains('cooking')) {
      chips.add(makeChip(LineIcons.utensils, Colors.deepOrange, 'Yemek'));
    }

    final selfcare = listFrom(act['selfcare']);
    if (selfcare.contains('manicure')) {
      chips.add(makeChip(LineIcons.handHoldingHeart, Colors.pink, 'Manikür'));
    }
    if (selfcare.contains('skincare')) {
      chips.add(makeChip(LineIcons.spa, Colors.lightGreen, 'Cilt Bakımı'));
    }
    if (selfcare.contains('hair')) {
      chips.add(makeChip(LineIcons.cut, Colors.brown, 'Saç'));
    }

    if (act['no_smoking'] == true) {
      chips.add(makeChip(LineIcons.smokingBan, Colors.redAccent, 'Sigara Yok'));
    }
    if (act['social_media_detox'] == true) {
      chips.add(makeChip(LineIcons.mobilePhone, Colors.blueGrey, 'Detoks'));
    }
    if (act['meditation'] == true) {
      chips.add(makeChip(LineIcons.spa, Colors.purpleAccent, 'Meditasyon'));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.start,
      children: chips,
    );
  }
}
