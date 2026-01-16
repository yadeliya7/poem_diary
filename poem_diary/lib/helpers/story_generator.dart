import 'package:flutter/material.dart';
import 'localization_helper.dart';
import '../models/daily_entry_model.dart';
import 'package:poem_diary/l10n/app_localizations.dart';

class StoryGenerator {
  // Category Mappings
  static const _weather = [
    'sunny',
    'rainy',
    'cloudy',
    'snowy',
    'windy',
    'foggy',
    'hail',
  ];

  static String generateDailyStory(BuildContext context, DailyEntry entry) {
    final loc = AppLocalizations.of(context)!;
    final sb = StringBuffer();

    // 1. INTRO (Mood + Sleep + Weather)
    final mood = entry.moodCode;
    final sleep = entry.activities['sleep'] as String? ?? '';

    // Safely extract weather, which might be stored as a List (new format) or String (legacy)
    String? weather;
    final rawWeather = entry.activities['weather'];
    if (rawWeather is List && rawWeather.isNotEmpty) {
      weather = rawWeather.first.toString();
    } else if (rawWeather is String) {
      weather = rawWeather;
    }

    // Choose and write Intro
    // 1. INTRO (Narrative Style)
    // Start with Mood Sentence
    sb.write(LocalizationHelper.getMoodSentence(context, mood));

    // Append Sleep Info
    final sleepSentence = LocalizationHelper.getSleepSentence(context, sleep);
    if (sleepSentence.isNotEmpty) {
      sb.write(' $sleepSentence');
    }

    // Append Weather Info
    if (weather != null) {
      final weatherText = LocalizationHelper.getWeatherSentence(
        context,
        weather,
      );
      if (weatherText.isNotEmpty) {
        sb.write(' $weatherText');
      }
    }
    sb.write(' ');

    // 2. BODY (Activities - Narrative Style)
    // Flatten activities first
    final activities = _flattenActivities(entry.activities);

    // We can use a set to avoid duplicate sentences if multiple keys map to same concept (though unlikely with current ID setup)
    final sentences = <String>{};

    for (final actId in activities) {
      final sentence = LocalizationHelper.getJournalSentence(context, actId);
      if (sentence.isNotEmpty) {
        sentences.add(sentence);
      }
    }

    // Join sentences.
    // Optimization: We could add connectors like "Also,", "Then," etc. randomly if desired suitable for Turkish.
    // For now, simple space joining is clean and works well with full sentences.
    if (sentences.isNotEmpty) {
      sb.write(sentences.join(' '));
      sb.write(' ');
    }

    // 3. OUTRO
    if (entry.note != null && entry.note!.isNotEmpty) {
      sb.write(loc.dayNote(entry.note!));
    }

    return sb.toString().trim();
  }

  static List<String> _flattenActivities(Map<String, dynamic> actMap) {
    final list = <String>[];

    // Handle nested lists commonly used in this app (e.g. Health: ['sport', 'water'])
    actMap.forEach((key, value) {
      if (value is List) {
        list.addAll(value.map((e) => e.toString()));
      } else if (value is bool && value == true) {
        list.add(key);
      } else if (value is String &&
          !_weather.contains(value) &&
          value != 'good' &&
          value != 'medium' &&
          value != 'bad') {
        // Exclude sleep/weather values if they are just strings, unless they are specific activities
        list.add(value);
      }
    });
    return list;
  }
}
