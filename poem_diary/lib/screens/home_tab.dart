import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/providers.dart';
import '../models/daily_entry_model.dart';
import '../core/language_provider.dart';
import '../models/poem_model.dart';
import 'package:line_icons/line_icons.dart';
import 'settings_screen.dart';
import '../widgets/mood_entry_dialog.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Color _activeMoodColor = Colors.grey;

  String _getGreetingKey() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      return 'good_morning';
    } else if (hour >= 12 && hour < 18) {
      return 'good_afternoon';
    } else if (hour >= 18 && hour < 22) {
      return 'good_evening';
    } else {
      return 'good_night';
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 1. Get All Entries and Sort (Newest First)
    // FILTER: Current Month Only
    final now = DateTime.now();
    final entries = moodProvider.journal.values.where((e) {
      return e.date.year == now.year && e.date.month == now.month;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));

    // 2. Identify Today's Entry
    final todayEntry = moodProvider.getEntryForDate(now);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Wrap in SafeArea to avoid notch issues, but careful with bottom padding
      body: SafeArea(
        bottom: false,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
          itemCount: entries.length + 3, // Header, Goals, Title, Entries
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopHeader(context, isDark),
                  const SizedBox(height: 16),
                  _buildMoodSelector(context, moodProvider, todayEntry, isDark),
                  const SizedBox(height: 16),
                ],
              );
            } else if (index == 1) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: _buildGoalsSection(
                  context,
                  todayEntry,
                  moodProvider,
                  isDark,
                ),
              );
            } else if (index == 2) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "Geçmiş Kayıtlar",
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              );
            } else {
              final entry = entries[index - 3];
              return _buildTimelineCard(context, entry, moodProvider, isDark);
            }
          },
        ),
      ),
      // Settings FAB or Icon
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 10), // Adjust for SafeArea
        child: FloatingActionButton.small(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
          backgroundColor: isDark ? Colors.black45 : Colors.white,
          foregroundColor: isDark ? Colors.white : Colors.black87,
          elevation: 0,
          child: const Icon(Icons.settings, size: 20),
        ),
      ),
    );
  }

  // --- GOALS LOGIC & UI ---

  Widget _buildGoalsSection(
    BuildContext context,
    DailyEntry? entry,
    MoodProvider provider,
    bool isDark,
  ) {
    // Keys to track
    final goals = [
      {'key': 'no_smoking', 'label': 'Sigarasız', 'icon': LineIcons.smokingBan},
      {
        'key': 'social_media_detox',
        'label': 'S. Medya',
        'icon': LineIcons.mobilePhone,
      },
      {'key': 'read_book', 'label': 'Okuma', 'icon': LineIcons.book},
      {'key': 'drink_water', 'label': 'Su', 'icon': LineIcons.tint},
      {'key': 'meditation', 'label': 'Meditasyon', 'icon': LineIcons.spa},
    ];

    return Container(
      height: 110, // Increased height for streak badge
      width: double.infinity,
      color: Colors.transparent,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: goals.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = goals[index];
          final key = item['key'] as String;
          final label = item['label'] as String;
          final icon = item['icon'] as IconData;

          // Check Status
          // We rely on boolean values for these specific keys
          bool isDone = false;
          if (entry != null && entry.activities[key] == true) {
            isDone = true;
          }

          // Calculate Streak
          final pastStreak = provider.getStreakFor(key, DateTime.now());
          final displayStreak = pastStreak + (isDone ? 1 : 0);

          return InkWell(
            onTap: () {
              // Open Dialog
              showMoodEntryDialog(
                context,
                date: DateTime.now(),
                provider: provider,
                currentMood: entry?.moodCode,
                currentNote: entry?.note,
                currentMedia: entry?.mediaPaths ?? [],
                currentActivities: entry?.activities ?? {},
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 90, // Slightly wider
              decoration: BoxDecoration(
                color: isDone
                    ? Colors.green.withValues(alpha: 0.15)
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey.withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDone
                      ? Colors.green
                      : (isDark ? Colors.white10 : Colors.black12),
                  width: 1.5,
                ),
              ),
              child: Stack(
                children: [
                  // Main Content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 14), // Space for top badge
                        Icon(
                          icon,
                          size: 26,
                          color: isDone
                              ? Colors.green
                              : (isDark ? Colors.white54 : Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDone
                                ? Colors.green
                                : (isDark ? Colors.white60 : Colors.grey),
                          ),
                        ),
                        if (isDone)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.green,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Streak Badge (Top Center)
                  if (displayStreak > 0)
                    Positioned(
                      top: 6,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "🔥 $displayStreak",
                            style: GoogleFonts.nunito(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- EXISTING WIDGETS ---

  Widget _buildTopHeader(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "POEM DIARY",
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          Provider.of<LanguageProvider>(context).translate(_getGreetingKey()),
          style: GoogleFonts.nunito(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          DateFormat(
            'd MMMM yyyy',
            Provider.of<LanguageProvider>(context).currentLanguage,
          ).format(DateTime.now()),
          style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildMoodSelector(
    BuildContext context,
    MoodProvider moodProvider,
    DailyEntry? todayEntry,
    bool isDark,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _activeMoodColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _activeMoodColor.withValues(alpha: 0.25),
            Theme.of(context).cardColor.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _activeMoodColor.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              Provider.of<LanguageProvider>(
                context,
              ).translate('check_in_prompt'),
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: moodProvider.moods.where((m) => m.code.isNotEmpty).map((
                mood,
              ) {
                final isTodayMood = todayEntry?.moodCode == mood.code;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeMoodColor = mood.color;
                    });
                    showMoodEntryDialog(
                      context,
                      date: DateTime.now(),
                      provider: moodProvider,
                      currentMood: mood.code,
                      currentNote: todayEntry?.note,
                      currentMedia: todayEntry?.mediaPaths ?? [],
                      currentActivities: todayEntry?.activities ?? {},
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isTodayMood
                                ? Colors.blueAccent.withValues(alpha: 0.1)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isTodayMood
                                  ? Colors.blueAccent
                                  : Colors.grey.withValues(alpha: 0.3),
                              width: isTodayMood ? 2.0 : 1.0,
                            ),
                          ),
                          child: Text(
                            mood.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Provider.of<LanguageProvider>(
                            context,
                          ).translate('mood_${mood.code}'),
                          style: GoogleFonts.nunito(
                            fontSize: 10,
                            fontWeight: isTodayMood
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(
    BuildContext context,
    DailyEntry entry,
    MoodProvider provider,
    bool isDark,
  ) {
    // Resolve Mood
    final mood = provider.moods.firstWhere(
      (m) => m.code == entry.moodCode,
      orElse: () => MoodCategory(
        id: '?',
        code: '?',
        name: '?',
        emoji: '❓',
        description: '',
        backgroundGradient: '',
        color: Colors.grey,
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: mood.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: mood.color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat(
                  'd MMM yyyy, EEEE',
                  Provider.of<LanguageProvider>(context).currentLanguage,
                ).format(entry.date),
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                onPressed: () {
                  showMoodEntryDialog(
                    context,
                    date: entry.date,
                    provider: provider,
                    currentMood: entry.moodCode,
                    currentNote: entry.note,
                    currentMedia: entry.mediaPaths,
                    currentActivities: entry.activities,
                  );
                },
              ),
            ],
          ),
          const Divider(height: 10),

          // Main
          Row(
            children: [
              Text(mood.emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mood.name,
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (entry.note != null && entry.note!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          entry.note!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: isDark ? Colors.white60 : Colors.black45,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Chips
          if (entry.activities.isNotEmpty) _buildWrapIcons(entry),
        ],
      ),
    );
  }

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
