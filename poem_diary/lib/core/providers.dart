import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../models/daily_entry_model.dart';
import '../models/poem_model.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }
}

class PoemProvider extends ChangeNotifier {
  List<Poem> _poems = [];

  PoemProvider() {
    _loadPoems();
    _loadFontPreference();
  }

  Future<void> _loadPoems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> savedFavs =
          prefs.getStringList('favorite_poems') ?? [];

      final String response = await rootBundle.loadString('assets/poems.json');
      final List<dynamic> data = json.decode(response);

      _poems = [];
      for (int i = 0; i < data.length; i++) {
        final item = data[i];
        // Calculate background image sequentially (1-6) using index
        // Using "bg_X.jpg" format
        final bgIndex = (i % 6) + 1;
        final String assignedBg = 'assets/images/bg_$bgIndex.jpg';

        _poems.add(
          Poem(
            id: item['id'],
            title: item['title'],
            content: item['content'],
            author: item['author'],
            mood: item['mood'],
            createdAt: DateTime.now(), // Date is dynamic
            backgroundImage: assignedBg,
            isFavorite: savedFavs.contains(item['id']),
          ),
        );
      }

      notifyListeners();
      debugPrint('Loaded ${_poems.length} poems with assigned backgrounds.');
    } catch (e) {
      debugPrint('Error loading poems: $e');
    }
  }

  String _contentFontFamily = 'Nunito';
  String get contentFontFamily => _contentFontFamily;

  Future<void> _loadFontPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _contentFontFamily = prefs.getString('selected_font') ?? 'Nunito';
    notifyListeners();
  }

  Future<void> setContentFontFamily(String fontName) async {
    _contentFontFamily = fontName;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_font', fontName);
  }

  // Getter for the full archive (for internal use or specific screens)
  List<Poem> get poems => _poems;

  // Getter for the Weekly Feed (Home Screen)
  // Returns 7 poems: Today's poem + past 6 days
  List<Poem> get weeklyFeed {
    if (_poems.isEmpty) return [];

    final now = DateTime.now();
    // Start date: 2026-01-01
    final startDate = DateTime(2026, 1, 1);

    // How many days have passed since 2026-01-01?
    // +1 because ID 1 is Day 0 (start date)
    final daysSinceStart = now.difference(startDate).inDays;

    // Today's ID: If today is 2026-01-01 (0 days diff), ID should be 1.
    // So ID = daysSinceStart + 1.
    final todayId = daysSinceStart + 1;

    List<Poem> feed = [];
    for (int i = 0; i < 7; i++) {
      // We want to show poems for [Today, Yesterday, ... Today-6]
      // The ID for "Today - i" is simply (todayId - i).

      int targetId = todayId - i;

      // Handle IDs < 1 (Before Start Date) or IDs that don't exist
      // For now, let's wrap around if < 1 to show *something* or just clamp to 1?
      // User said "it start from 01 01 2026 id:1". Logic implies before that there are no poems?
      // If targetId < 1, let's just show Poem #1 or loop from the end.
      // Let's safe-guard: modulo if ID > length, clamp if < 1.

      // Actually, if we want strict ID mapping, we should try to find that specific ID.
      // But we only have 20 poems generated so far.
      // If today is 2026-01-08, ID=8. All good.
      // If user sets date to 2027, ID=370? We don't have it.
      // Fallback: Modulo logic for safety if ID > _poems.length

      int effectiveIndex;
      if (targetId <= 0) {
        // Before 2026 -> Show cyclic
        effectiveIndex =
            (_poems.length + (targetId % _poems.length)) % _poems.length;
      } else {
        // Real ID mapping
        // Index = ID - 1
        effectiveIndex = (targetId - 1) % _poems.length;
      }

      final originalPoem = _poems[effectiveIndex];

      // The display date is physically "Today - i"
      feed.add(
        originalPoem.copyWith(createdAt: now.subtract(Duration(days: i))),
      );
    }
    return feed.reversed.toList();
  }

  // Getter for the Featured Daily Poem
  Poem? get featuredPoem => weeklyFeed.isNotEmpty ? weeklyFeed.first : null;

  // User created poems
  final List<Poem> _userPoems = [];
  List<Poem> get userPoems => _userPoems;

  void addUserPoem(Poem poem) {
    _userPoems.insert(0, poem);
    notifyListeners();
  }

  // Getter for favorite poems
  List<Poem> get favoritePoems => _poems.where((p) => p.isFavorite).toList();

  bool isFavorite(String poemId) {
    return _poems.any((p) => p.id == poemId && p.isFavorite);
  }

  // Method to get poems by mood (Archive)
  List<Poem> getPoemsByMood(String moodCode) {
    if (moodCode.isEmpty) return _poems;
    // Simple filter by mood string
    return _poems.where((p) => p.mood == moodCode).toList();
  }

  // Helper to find a poem by ID (checks both stock and user poems)
  Poem? getPoemById(String id) {
    try {
      return _poems.firstWhere(
        (p) => p.id == id,
        orElse: () => _userPoems.firstWhere((p) => p.id == id),
      );
    } catch (e) {
      return null;
    }
  }

  // Background Selection Logic
  // _selectedBackgroundImage removed in favor of per-poem background

  String get selectedFont => _contentFontFamily;

  Poem? getCurrentPoem() {
    if (_poems.isNotEmpty) {
      return _poems.first;
    }
    return null;
  }

  // Method to update a specific poem's background image
  void updatePoemBackground(String poemId, String newImagePath) {
    try {
      // Check in stock poems
      final index = _poems.indexWhere((p) => p.id == poemId);
      if (index != -1) {
        _poems[index] = _poems[index].copyWith(
          backgroundImage: newImagePath,
          gradientId: null, // Clear gradient
        );
        notifyListeners();
        return;
      }

      // Check in user poems
      final userIndex = _userPoems.indexWhere((p) => p.id == poemId);
      if (userIndex != -1) {
        _userPoems[userIndex] = _userPoems[userIndex].copyWith(
          backgroundImage: newImagePath,
          gradientId: null, // Clear gradient
        );
        notifyListeners();
        return;
      }
    } catch (e) {
      debugPrint('Error updating poem background: $e');
    }
  }

  // Method to update a specific poem's gradient
  void updatePoemGradient(String poemId, String gradientId) {
    try {
      // Check in stock poems
      final index = _poems.indexWhere((p) => p.id == poemId);
      if (index != -1) {
        _poems[index] = _poems[index].copyWith(
          gradientId: gradientId,
          backgroundImage: '', // Clear image
        );
        notifyListeners();
        return;
      }

      // Check in user poems
      final userIndex = _userPoems.indexWhere((p) => p.id == poemId);
      if (userIndex != -1) {
        _userPoems[userIndex] = _userPoems[userIndex].copyWith(
          gradientId: gradientId,
          backgroundImage: '', // Clear image
        );
        notifyListeners();
        return;
      }
    } catch (e) {
      debugPrint('Error updating poem gradient: $e');
    }
  }

  void setFont(String fontName) {
    setContentFontFamily(fontName);
  }

  void toggleFavorite(String poemId) {
    final index = _poems.indexWhere((p) => p.id == poemId);
    if (index != -1) {
      _poems[index] = _poems[index].copyWith(
        isFavorite: !_poems[index].isFavorite,
      );
      notifyListeners();
      _saveFavorites();
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favIds = _poems.where((p) => p.isFavorite).map((p) => p.id).toList();
    await prefs.setStringList('favorite_poems', favIds);
  }

  void addPoem(Poem poem) {
    _poems.insert(0, poem);
    notifyListeners();
  }

  void deletePoem(String poemId) {
    _poems.removeWhere((p) => p.id == poemId);
    notifyListeners();
  }
}

class MoodProvider extends ChangeNotifier {
  // Changed from Map<String, String> to Map<String, DailyEntry>
  Map<String, DailyEntry> _journal = {};

  MoodProvider() {
    _loadJournal();
  }

  Map<String, DailyEntry> get journal => _journal;

  void _loadJournal() async {
    final prefs = await SharedPreferences.getInstance();

    // Legacy migration: Check for old 'mood_history'
    if (prefs.containsKey('mood_history')) {
      final String? legacyJson = prefs.getString('mood_history');
      if (legacyJson != null) {
        final Map<String, dynamic> legacyMap = jsonDecode(legacyJson);
        legacyMap.forEach((key, value) {
          // Convert old "YYYY-MM-DD": "moodCode" to new format
          // Key is date string
          final date = DateTime.tryParse(key);
          if (date != null) {
            final entry = DailyEntry(
              moodCode: value as String,
              date: date,
              note: null, // No note for legacy data
            );
            // Save to new format immediately
            _saveEntryToPrefs(prefs, key, entry);
            _journal[key] = entry;
          }
        });
        // Remove old key after migration
        await prefs.remove('mood_history');
      }
    }

    // Load new journal entries
    final keys = prefs.getKeys().where((k) => k.startsWith('journal_'));
    for (final key in keys) {
      final String? jsonStr = prefs.getString(key);
      if (jsonStr != null) {
        try {
          final entry = DailyEntry.fromJson(jsonDecode(jsonStr));
          // Extract date key from the prefs key "journal_YYYY-MM-DD"
          final dateKey = key.replaceFirst('journal_', '');
          _journal[dateKey] = entry;
        } catch (e) {
          print('Error loading journal entry $key: $e');
        }
      }
    }
    notifyListeners();
  }

  Future<void> saveDailyEntry(
    DateTime date,
    String moodCode,
    String? note,
  ) async {
    final String dateKey =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final entry = DailyEntry(moodCode: moodCode, note: note, date: date);

    _journal[dateKey] = entry;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await _saveEntryToPrefs(prefs, dateKey, entry);
  }

  Future<void> _saveEntryToPrefs(
    SharedPreferences prefs,
    String dateKey,
    DailyEntry entry,
  ) async {
    await prefs.setString('journal_$dateKey', jsonEncode(entry.toJson()));
  }

  String? getMoodForDate(DateTime date) {
    final String key =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return _journal[key]?.moodCode;
  }

  DailyEntry? getEntryForDate(DateTime date) {
    final String key =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return _journal[key];
  }

  bool hasCheckedInToday() {
    final now = DateTime.now();
    final String key =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    return _journal.containsKey(key);
  }

  final List<MoodCategory> _moods = [
    MoodCategory(
      id: '0',
      code: '', // Empty code signifies "All Poems"
      name: 'Tüm Şiirler',
      emoji: '📚',
      description: 'Bütün arşiv',
      backgroundGradient: 'mystic',
    ),
    MoodCategory(
      id: '1',
      code: 'sad',
      name: 'Hüzün',
      emoji: '🌧️',
      description: 'Yağmurlu bir gün hissiyatı',
      backgroundGradient: 'sad',
    ),
    MoodCategory(
      id: '2',
      code: 'happy',
      name: 'Neşe',
      emoji: '☀️',
      description: 'Güneşli bir sabah gibi',
      backgroundGradient: 'happy',
    ),
    MoodCategory(
      id: '3',
      code: 'nostalgic',
      name: 'Nostaljik',
      emoji: '🍂',
      description: 'Anıların dokunuşu',
      backgroundGradient: 'nostalgic',
    ),
    MoodCategory(
      id: '4',
      code: 'mystic',
      name: 'Gizemli',
      emoji: '🌙',
      description: 'Büyülü ve derin',
      backgroundGradient: 'mystic',
    ),
    MoodCategory(
      id: '5',
      code: 'hopeful',
      name: 'Umut',
      emoji: '🌅',
      description: 'Yeni bir başlangıç',
      backgroundGradient: 'hopeful',
    ),
    MoodCategory(
      id: '6',
      code: 'peaceful',
      name: 'Huzur',
      emoji: '🌊',
      description: 'Akıp giden su gibi',
      backgroundGradient: 'peaceful',
    ),
    MoodCategory(
      id: '7',
      code: 'romantic',
      name: 'Romantik',
      emoji: '💖',
      description: 'Aşkın en saf hali',
      backgroundGradient: 'romantic',
    ),
    MoodCategory(
      id: '8',
      code: 'tired',
      name: 'Yorgun',
      emoji: '☕',
      description: 'Biraz dinlenmeye ihtiyaç var',
      backgroundGradient: 'tired',
    ),
  ];

  List<MoodCategory> get moods => _moods;

  MoodCategory? getMoodById(String id) {
    try {
      return _moods.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }
}
