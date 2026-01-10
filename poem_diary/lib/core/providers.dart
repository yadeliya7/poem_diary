import 'dart:convert';
import 'dart:math';
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
    List<Poem> feed = [];
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      feed.add(getDailyPoem(date));
    }
    // Return closest to oldest order if that was the intent,
    // BUT usually feed is shown chronologically or reverse chronologically.
    // Previous code reversed it: [Oldest ... Today]
    // Let's stick to that convention for compatibility.
    return feed.reversed.toList();
  }

  // Deterministic Daily Poem Algorithm
  Poem getDailyPoem(DateTime date) {
    if (_poems.isEmpty) {
      // Placeholder for empty state
      return Poem(
        id: 'placeholder',
        title: 'Hoş Geldiniz',
        content: 'Şiirler yükleniyor...\nLütfen bekleyiniz.',
        author: 'Sistem',
        mood: 'happy',
        createdAt: date,
        backgroundImage: 'assets/images/bg_1.jpg',
      );
    }

    // 1. Generate Seed from Date (YYYYMMDD)
    final int seed = date.year * 10000 + date.month * 100 + date.day;

    // 2. Random with Seed
    final Random rng = Random(seed);

    // 3. Pick Index
    final int index = rng.nextInt(_poems.length);
    final originalPoem = _poems[index];

    // 4. Return Copy with Date
    // Note: We keep the original ID to allow favorites to work on the underlying poem.
    // But distinct days showing the same poem might share favoriting status, which is expected.
    return originalPoem.copyWith(createdAt: date);
  }

  // Getter for the Featured Daily Poem (Today)
  Poem? get featuredPoem => getDailyPoem(DateTime.now());

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
          clearGradient: true, // Force clear gradient
        );
        notifyListeners();
        return;
      }

      // Check in user poems
      final userIndex = _userPoems.indexWhere((p) => p.id == poemId);
      if (userIndex != -1) {
        _userPoems[userIndex] = _userPoems[userIndex].copyWith(
          backgroundImage: newImagePath,
          clearGradient: true, // Force clear gradient
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
  final Map<String, DailyEntry> _journal = {};

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
    String? note, [
    List<String> mediaPaths = const [],
  ]) async {
    final String dateKey =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final entry = DailyEntry(
      moodCode: moodCode,
      note: note,
      date: date,
      mediaPaths: mediaPaths,
    );

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
      color: Colors.grey,
    ),
    MoodCategory(
      id: '1',
      code: 'sad',
      name: 'Hüzün',
      emoji: '🌧️',
      description: 'Yağmurlu bir gün hissiyatı',
      backgroundGradient: 'sad',
      color: Colors.blueGrey,
    ),
    MoodCategory(
      id: '2',
      code: 'happy',
      name: 'Neşe',
      emoji: '☀️',
      description: 'Güneşli bir sabah gibi',
      backgroundGradient: 'happy',
      color: Colors.amber, // Yellow is too bright for text usually
    ),
    MoodCategory(
      id: '3',
      code: 'nostalgic',
      name: 'Nostaljik',
      emoji: '🍂',
      description: 'Anıların dokunuşu',
      backgroundGradient: 'nostalgic',
      color: Colors.orangeAccent,
    ),
    MoodCategory(
      id: '4',
      code: 'mystic',
      name: 'Gizemli',
      emoji: '🌙',
      description: 'Büyülü ve derin',
      backgroundGradient: 'mystic',
      color: Colors.purple,
    ),
    MoodCategory(
      id: '5',
      code: 'hopeful',
      name: 'Umut',
      emoji: '🌅',
      description: 'Yeni bir başlangıç',
      backgroundGradient: 'hopeful',
      color: Colors.green,
    ),
    MoodCategory(
      id: '6',
      code: 'peaceful',
      name: 'Huzur',
      emoji: '🌊',
      description: 'Akıp giden su gibi',
      backgroundGradient: 'peaceful',
      color: Colors.teal,
    ),
    MoodCategory(
      id: '7',
      code: 'romantic',
      name: 'Romantik',
      emoji: '💖',
      description: 'Aşkın en saf hali',
      backgroundGradient: 'romantic',
      color: Colors.pinkAccent,
    ),
    MoodCategory(
      id: '8',
      code: 'tired',
      name: 'Yorgun',
      emoji: '☕',
      description: 'Biraz dinlenmeye ihtiyaç var',
      backgroundGradient: 'tired',
      color: Colors.brown,
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
