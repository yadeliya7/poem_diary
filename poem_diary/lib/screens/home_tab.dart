import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/providers.dart';
import '../core/language_provider.dart';
import 'all_moods_screen.dart';
import '../widgets/premium_poem_card.dart';
import 'settings_screen.dart';
import '../widgets/mood_entry_dialog.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // Removed local _showEntryDialog in favor of shared MoodEntryDialog

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
    final poemProvider = Provider.of<PoemProvider>(context);
    final moodProvider = Provider.of<MoodProvider>(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Check for today's entry to highlight active mood and show attachment
    final today = DateTime.now();
    final todayEntry = moodProvider.getEntryForDate(today);

    // Get daily poem or random for now
    final dailyPoem = poemProvider.featuredPoem;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // LAYER 1: Scrollable Content
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top:
                  MediaQuery.of(context).padding.top +
                  10, // Compact top spacing
              left: 20.0,
              right: 20.0,
              bottom: 100.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. COMPACT CUSTOM APP BAR
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 0,
                  ), // Already handled by ScrollView padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Brand
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
                      // Row 2: Greeting
                      Text(
                        Provider.of<LanguageProvider>(
                          context,
                        ).translate(_getGreetingKey()),
                        style: GoogleFonts.nunito(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      // Row 3: Date
                      Text(
                        DateFormat(
                          'd MMMM yyyy',
                          Provider.of<LanguageProvider>(
                            context,
                          ).currentLanguage,
                        ).format(DateTime.now()),
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20), // Spacing between Header and Moods
                // 2. Mood Check-in Section
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _activeMoodColor.withValues(
                        alpha: 0.3,
                      ), // Subtle colored border
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
                        color: _activeMoodColor.withValues(
                          alpha: 0.15,
                        ), // Colored shadow glow
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
                      const SizedBox(height: 20),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: moodProvider.moods
                              .where((m) => m.code.isNotEmpty)
                              .map((mood) {
                                final isTodayMood =
                                    todayEntry?.moodCode == mood.code;
                                final hasMedia =
                                    isTodayMood &&
                                    (todayEntry?.mediaPaths.isNotEmpty ??
                                        false);

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _activeMoodColor = mood.color;
                                    });
                                    showMoodEntryDialog(
                                      context,
                                      date: today,
                                      provider: moodProvider,
                                      currentMood: mood.code,
                                      currentNote: todayEntry?.note,
                                      currentMedia:
                                          todayEntry?.mediaPaths ?? [],
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: Column(
                                      children: [
                                        Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: isTodayMood
                                                    ? Colors.blueAccent
                                                          .withValues(
                                                            alpha: 0.1,
                                                          )
                                                    : Colors.transparent,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isTodayMood
                                                      ? Colors.blueAccent
                                                      : Colors.grey.withValues(
                                                          alpha: 0.3,
                                                        ),
                                                  width: isTodayMood
                                                      ? 2.0
                                                      : 1.0,
                                                ),
                                              ),
                                              child: Text(
                                                mood.emoji,
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                ),
                                              ),
                                            ),
                                            if (hasMedia)
                                              Positioned(
                                                right: -4,
                                                bottom: -4,
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color:
                                                                Colors.black26,
                                                            blurRadius: 4,
                                                          ),
                                                        ],
                                                      ),
                                                  child: Icon(
                                                    Icons.attach_file,
                                                    size: 12,
                                                    color: Colors.blueAccent,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          Provider.of<LanguageProvider>(
                                            context,
                                          ).translate('mood_${mood.code}'),
                                          style: GoogleFonts.nunito(
                                            fontSize: 12,
                                            fontWeight: isTodayMood
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isTodayMood
                                                ? (isDark
                                                      ? Colors.white
                                                      : Colors.black87)
                                                : (isDark
                                                      ? Colors.white70
                                                      : Colors.black54),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              })
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 3. Daily Content (Today's Poem)
                Text(
                  Provider.of<LanguageProvider>(
                    context,
                  ).translate('poem_of_day'),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (dailyPoem != null)
                  AspectRatio(
                    aspectRatio: 0.7,
                    child: PremiumPoemCard(
                      poem: dailyPoem,
                      onTap: () {
                        // TODO: Open detail view or expand
                      },
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        Provider.of<LanguageProvider>(
                          context,
                        ).translate('msg_no_poem_selected'),
                      ),
                    ),
                  ),

                const SizedBox(height: 30),

                // 4. Discovery Banner
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllMoodsScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6A11CB).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.manage_search,
                          color: Colors.white,
                          size: 40,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Provider.of<LanguageProvider>(
                                  context,
                                ).translate('discover_title'),
                                style: GoogleFonts.nunito(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                Provider.of<LanguageProvider>(
                                  context,
                                ).translate('discover_subtitle'),
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white70,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 80), // Extra space
              ],
            ),
          ),

          // LAYER 2: Fixed Settings Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.white24,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.settings,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
