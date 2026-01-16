import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../core/providers.dart';
import '../models/daily_entry_model.dart';
import '../helpers/story_generator.dart';
import 'package:poem_diary/l10n/app_localizations.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);
    // Sort entries descending by date
    final entries = moodProvider.journal.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          // "Journal" or "Timeline" - localized name?
          // Using "Mood Calendar" name or similar; let's reuse a generic or add "Journal" key.
          // For now, let's use the old library title or just "My Journey" (Gunlugum - My Diary).
          // Retaining "Library" key context momentarily or hardcoding title until localized.
          // Let's use "Günlüğüm" (My Journal) hardcoded for now or reuse 'myPoems' if appropriate,
          // but better to add a key. The user didn't ask for a title change explicitly but "Journal Screen" implies it.
          // Let's us "Günlüğüm" (TR) / "My Journal" (EN) fallback
          "Journal",
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: entries.isEmpty
          ? Center(
              child: Text(
                AppLocalizations.of(context)!.emptyFeed,
                style: GoogleFonts.nunito(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return _buildTimelineCard(context, entry, isDark, textColor);
              },
            ),
    );
  }

  Widget _buildTimelineCard(
    BuildContext context,
    DailyEntry entry,
    bool isDark,
    Color textColor,
  ) {
    // Mood Icon/Color lookup
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);

    final story = StoryGenerator.generateDailyStory(context, entry);
    final dateFormat = DateFormat(
      'd MMMM yyyy, EEEE',
      Localizations.localeOf(context).toString(),
    );

    final mood = moodProvider.moods.firstWhere(
      (m) => m.code == entry.moodCode,
      orElse: () => moodProvider.moods.first,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: mood.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: mood.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(mood.emoji, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormat.format(entry.date),
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: textColor.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    mood.name, // Should be localized if MoodCategory provides it via helper
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: textColor.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Photo (if any)
          if (entry.mediaPaths.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(entry.mediaPaths.first),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox(),
                ),
              ),
            ),

          // Story Text
          Text(
            story,
            style: GoogleFonts.nunito(
              fontSize: 16,
              height: 1.5,
              color: textColor,
            ),
          ),

          // Debug/Raw Chips (Optional, maybe for verification)
          /* 
          const SizedBox(height: 12),
          Wrap(
            spacing: 4,
            children: entry.activities.keys.map((k) => Chip(label: Text(k))).toList(),
          ) 
          */
        ],
      ),
    );
  }
}
