import 'package:flutter/material.dart';
import 'package:poem_diary/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';

import '../core/theme.dart';
import '../core/providers.dart';
import '../models/daily_entry_model.dart';
import '../models/poem_model.dart'; // Needed for MoodCategory
import '../widgets/mood_entry_dialog.dart';
import '../core/language_provider.dart';
import '../helpers/localization_helper.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final loc = AppLocalizations.of(context)!;
    if (hour < 6) return loc.greetingNight;
    if (hour < 12) return loc.greetingMorning;
    if (hour < 18) return loc.greetingDay;
    return loc.greetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodProvider>(
      builder: (context, provider, child) {
        // 1. Strict Date Checking (Ignore Time)
        final now = DateTime.now();
        DailyEntry? todayEntry;
        try {
          // provider.entries doesn't exist. Use provider.journal.values
          todayEntry = provider.journal.values.firstWhere(
            (e) =>
                e.date.year == now.year &&
                e.date.month == now.month &&
                e.date.day == now.day,
          );
        } catch (_) {
          todayEntry = null;
        }

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // A. Header
                  _buildHeader(context),
                  const SizedBox(height: 20),

                  // B. Main Content Switch
                  // If we have data -> Show Dashboard.
                  // If we don't -> Show Selector.
                  todayEntry != null
                      ? _buildDailyDashboard(context, todayEntry, provider)
                      : _buildMoodSelector(context, provider, now),

                  // NO POEM CARD HERE. IT IS DELETED.
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    final lang = Provider.of<LanguageProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(context),
              style: GoogleFonts.nunito(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              DateFormat('d MMMM yyyy', lang.currentLanguage).format(now),
              style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  // Widget: The New Dashboard Card
  Widget _buildDailyDashboard(
    BuildContext context,
    DailyEntry entry,
    MoodProvider provider,
  ) {
    // Resolve full Mood object from code
    final mood = provider.moods.firstWhere(
      (m) => m.code == entry.moodCode,
      orElse: () => MoodCategory(
        id: 'unknown',
        code: 'unknown',
        name: 'Bilinmiyor',
        emoji: '❓',
        description: '',
        backgroundGradient: '',
        color: Colors.grey,
      ),
    );

    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        // Allow editing
        await showMoodEntryDialog(
          context,
          date: DateTime.now(),
          provider: provider,
          currentMood: entry.moodCode,
          currentNote: entry.note,
          currentMedia: entry.mediaPaths,
          currentActivities: entry.activities,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              mood.color.withValues(alpha: 0.9),
              mood.color.withValues(alpha: 0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: mood.color.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top: Mood
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Text(mood.emoji, style: const TextStyle(fontSize: 50)),
            ),
            const SizedBox(height: 12),
            Text(
              LocalizationHelper.getMoodName(context, mood.code),
              style: GoogleFonts.nunito(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              AppLocalizations.of(context)!.todaySummary,
              style: GoogleFonts.nunito(fontSize: 16, color: Colors.white70),
            ),

            const SizedBox(height: 20),
            Divider(color: Colors.white.withValues(alpha: 0.3), height: 30),
            const SizedBox(height: 10),

            // Bottom: Icons Strip
            _buildIconStrip(context, entry),
          ],
        ),
      ),
    );
  }

  // Widget: Icon Strip (The missing piece)
  Widget _buildIconStrip(BuildContext context, DailyEntry entry) {
    List<Widget> icons = [];

    // Helper
    Widget makeIcon(IconData icon, String label) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            // Optional label if design permits, or keep clean icons
          ],
        ),
      );
    }

    final act = entry.activities;

    // Logic to add icons based on map...
    // Sleep
    if (act['sleep'] != null) {
      icons.add(
        makeIcon(
          LineIcons.moon,
          LocalizationHelper.getActivityName(context, 'sleep', act['sleep']),
        ),
      );
    }

    // Weather
    if (act['weather'] != null) {
      icons.add(
        makeIcon(
          LineIcons.cloudWithSun,
          LocalizationHelper.getActivityName(
            context,
            'weather',
            act['weather'],
          ),
        ),
      );
    }

    // Habits
    if (act['no_smoking'] == true) {
      icons.add(
        makeIcon(
          LineIcons.smokingBan,
          LocalizationHelper.getActivityName(context, 'no_smoking'),
        ),
      );
    }
    if (act['sport'] == true) {
      icons.add(
        makeIcon(
          LineIcons.running,
          LocalizationHelper.getActivityName(context, 'sport'),
        ),
      );
    }
    if (act['drink_water'] == true || act['water'] == true) {
      icons.add(
        makeIcon(
          LineIcons.tint,
          LocalizationHelper.getActivityName(context, 'water'),
        ),
      );
    }
    if (act['read_book'] == true || act['reading'] == true) {
      icons.add(
        makeIcon(
          LineIcons.book,
          LocalizationHelper.getActivityName(context, 'reading'),
        ),
      );
    }
    if (act['meditation'] == true) {
      icons.add(
        makeIcon(
          LineIcons.spa,
          LocalizationHelper.getActivityName(context, 'meditation'),
        ),
      );
    }
    if (act['social_media_detox'] == true) {
      icons.add(
        makeIcon(
          LineIcons.mobilePhone,
          LocalizationHelper.getActivityName(context, 'detox'),
        ),
      );
    }

    if (icons.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          AppLocalizations.of(context)!.noActivityDetails,
          style: GoogleFonts.nunito(
            color: Colors.white70,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Wrap(alignment: WrapAlignment.center, children: icons);
  }

  Widget _buildMoodSelector(
    BuildContext context,
    MoodProvider moodProvider,
    DateTime now,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        await showMoodEntryDialog(context, date: now, provider: moodProvider);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: BoxDecoration(
          color: isDarkMode
              ? AppTheme.darkAccent.withValues(alpha: 0.1)
              : AppTheme.lightAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDarkMode ? Colors.white24 : Colors.black12,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.moodTitle,
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            // Emulate the horizontal list idea
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFakeEmoji('🤩'),
                _buildFakeEmoji('😊'),
                _buildFakeEmoji('😐'),
                _buildFakeEmoji('😔'),
                _buildFakeEmoji('😡'),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.tapToAddEntry,
              style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFakeEmoji(String e) {
    return Text(e, style: const TextStyle(fontSize: 32));
  }
}
