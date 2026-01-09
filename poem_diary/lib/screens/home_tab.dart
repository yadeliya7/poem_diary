import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/providers.dart';
import '../models/poem_model.dart';
import 'all_moods_screen.dart';
import '../widgets/premium_poem_card.dart';
import 'settings_screen.dart';
// We should probably move the dialog/sheet logic to a mixin or utility,
// OR just invoke it from here if possible.

// We need to implement the check-in logic here in HomeTab.
// I will copy/adapt the check-in UI logic to here or standardizing it.
// The user said: "Widget: The Horizontal Mood Selector (reused from entry sheet)."

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  // Logic to show the entry dialog
  void _showEntryDialog(
    BuildContext context,
    MoodCategory mood,
    MoodProvider provider,
  ) {
    final noteController = TextEditingController();
    final moodNotifier = ValueNotifier<MoodCategory>(mood);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        "Bugün",
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (moodNotifier.value.code.isNotEmpty) {
                            provider.saveDailyEntry(
                              DateTime.now(),
                              moodNotifier.value.code,
                              noteController.text,
                            );
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          "KAYDET",
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Mood Selector
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: provider.moods
                          .where((m) => m.code.isNotEmpty)
                          .map((m) {
                            return ValueListenableBuilder<MoodCategory>(
                              valueListenable: moodNotifier,
                              builder: (context, selectedMood, child) {
                                final isSelected = selectedMood.code == m.code;
                                return GestureDetector(
                                  onTap: () => moodNotifier.value = m,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.blueAccent.withOpacity(
                                                    0.1,
                                                  )
                                                : Colors.transparent,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.blueAccent
                                                  : Colors.grey.withOpacity(
                                                      0.3,
                                                    ),
                                              width: isSelected ? 2.0 : 1.0,
                                            ),
                                          ),
                                          child: Text(
                                            m.emoji,
                                            style: TextStyle(
                                              fontSize: isSelected ? 28 : 24,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          m.name,
                                          style: GoogleFonts.nunito(
                                            fontSize: 10,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          })
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: TextField(
                      controller: noteController,
                      expands: true,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: "Neler hissediyorsun?",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'İyi Geceler 🌙';
    if (hour < 12) return 'Günaydın ☀️';
    if (hour < 18) return 'İyi Günler 🌤️';
    return 'İyi Akşamlar 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final poemProvider = Provider.of<PoemProvider>(context);
    final moodProvider = Provider.of<MoodProvider>(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  60, // Space for Settings/Header
              left: 24.0,
              right: 24.0,
              bottom: 100.0, // Space for Bottom Nav
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Large App Title
                Text(
                  "Şiir Günlüğü",
                  style: GoogleFonts.nunito(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // Greeting
                Text(
                  _getGreeting(),
                  style: GoogleFonts.nunito(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Bugün şiir gibi bir gün olsun.",
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),

                const SizedBox(height: 30),

                // 2. Mood Check-in Section (Restored)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Bugün nasıl hissediyorsun?",
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
                                return GestureDetector(
                                  onTap: () {
                                    _showEntryDialog(
                                      context,
                                      mood,
                                      moodProvider,
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.grey.withOpacity(
                                                0.3,
                                              ),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Text(
                                            mood.emoji,
                                            style: const TextStyle(
                                              fontSize: 24,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          mood.name,
                                          style: GoogleFonts.nunito(
                                            fontSize: 12,
                                            color: isDark
                                                ? Colors.white70
                                                : Colors.black54,
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
                  "Günün Şiiri",
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
                    child: const Center(
                      child: Text("Henüz bir şiir seçilmedi."),
                    ),
                  ),

                const SizedBox(height: 30),

                // 4. Discovery Banner (Moved Bottom)
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
                          color: const Color(0xFF6A11CB).withOpacity(0.3),
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
                                "Ruh Haline Göre Keşfet",
                                style: GoogleFonts.nunito(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Modunu seç, şiirini bul...",
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
