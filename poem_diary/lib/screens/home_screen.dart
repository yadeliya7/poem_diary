import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart'; // Titreşim için

import '../core/theme.dart';
import '../core/providers.dart';

import '../widgets/premium_poem_card.dart';
import '../widgets/aurora_button.dart';
import 'favorites_screen.dart';
import 'all_moods_screen.dart';
import 'mood_calendar_screen.dart';
import 'compose_poem_screen.dart';
import '../models/poem_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _addPoemButtonKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final poemProvider = Provider.of<PoemProvider>(context);

    // Tema renklerini al
    final accentColor = isDarkMode ? AppTheme.darkAccent : AppTheme.lightAccent;

    // --- Dynamic Gradients for Dark Mode ---
    final categoriesGradient = isDarkMode
        ? const [
            Color(0xFF0F3838),
            Color(0xFF1D7575),
            Color(0xFF0F3838),
          ] // Deep Sea Green
        : const [
            Color(0xFF4CA1AF),
            Color(0xFF2C3E50),
            Color(0xFF4CA1AF),
          ]; // Aqua/Dark Blue

    final addPoemGradient = isDarkMode
        ? const [
            Color(0xFF003366),
            Color(0xFF0055AA),
            Color(0xFF003366),
          ] // Deep Navy
        : const [
            Color(0xFF89CFF0),
            Color(0xFF00C6FF),
            Color(0xFF89CFF0),
          ]; // Baby Blue

    final favoritesGradient = isDarkMode
        ? const [
            Color(0xFF4A0E2E),
            Color(0xFF961D4E),
            Color(0xFF4A0E2E),
          ] // Burgundy
        : const [
            Color(0xFFFFA7A7),
            Color(0xFFFF7EB3),
            Color(0xFFFFA7A7),
          ]; // Pink

    return Scaffold(
      // Scaffold background rengini tema ile eşleştirelim
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false, // Alt kısmı tamamen kaplasın diye false yapıyoruz
        child: Column(
          children: [
            // 1. HEADER (ÜST KISIM - YENİ NEON BUTONLAR)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // SOL GRUP: KATEGORİLER + EKLE + FAVORİLER
                  Row(
                    children: [
                      AuroraButton(
                        label: null, // ORB MODE
                        icon: Icons.grid_view_rounded,
                        isPrimary: true,
                        gradientColors: categoriesGradient,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AllMoodsScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      AuroraButton(
                        key: _addPoemButtonKey,
                        label: null, // ORB MODE
                        icon: Icons.add,
                        isPrimary: true,
                        gradientColors: addPoemGradient,
                        onPressed: () {
                          HapticFeedback.lightImpact();

                          // 1. Get Button Position & Size
                          final RenderBox? renderBox =
                              _addPoemButtonKey.currentContext
                                      ?.findRenderObject()
                                  as RenderBox?;

                          if (renderBox == null) return;

                          final Size size = renderBox.size;
                          final Offset offset = renderBox.localToGlobal(
                            Offset.zero,
                          );
                          final Offset center =
                              offset + Offset(size.width / 2, size.height / 2);

                          // 2. Navigate with Custom Transition
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(
                                milliseconds: 600,
                              ),
                              reverseTransitionDuration: const Duration(
                                milliseconds: 600,
                              ),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const ComposePoemScreen(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    final screenSize = MediaQuery.of(
                                      context,
                                    ).size;
                                    // Calculate max radius (distance to furthest corner)
                                    // We can just use the screen diagonal for safety
                                    final maxRadius =
                                        screenSize.longestSide * 1.5;

                                    return ClipPath(
                                      clipper: CircularRevealClipper(
                                        center: center,
                                        fraction: animation.value,
                                        maxRadius: maxRadius,
                                      ),
                                      child: child,
                                    );
                                  },
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      AuroraButton(
                        label: null, // ORB MODE
                        icon: Icons.calendar_month,
                        isPrimary: true,
                        gradientColors: const [
                          Color(0xFF8E2DE2),
                          Color(0xFF4A00E0),
                        ], // Purple
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MoodCalendarScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      AuroraButton(
                        label: null, // ORB MODE
                        icon: Icons.favorite,
                        isPrimary: true,
                        gradientColors: favoritesGradient,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FavoritesScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  // SAĞ GRUP: AYARLAR (MENÜ)
                  Row(
                    children: [
                      AuroraButton(
                        label: null, // ORB MODE
                        icon: Icons.more_horiz,
                        isPrimary: false, // Glass Effect
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _showMenuBottomSheet(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // DAILY CHECK-IN (NEW)
            Consumer<MoodProvider>(
              builder: (context, moodProvider, child) {
                if (moodProvider.hasCheckedInToday()) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 0,
                  ),
                  child: GestureDetector(
                    onTap: () => _showMoodCheckIn(context),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppTheme.darkAccent.withOpacity(0.1)
                            : AppTheme.lightAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode
                              ? AppTheme.darkAccent.withOpacity(0.3)
                              : AppTheme.lightAccent.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.sentiment_satisfied_alt,
                            color: isDarkMode
                                ? AppTheme.darkAccent
                                : AppTheme.lightAccent,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Bugün nasıl hissediyorsun?",
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right,
                            color: isDarkMode ? Colors.white54 : Colors.black54,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // 2. ORTA KISIM (ŞİİR KARTLARI - TAM EKRAN)
            Expanded(
              child: poemProvider.weeklyFeed.isNotEmpty
                  ? PageView.builder(
                      itemCount: poemProvider.weeklyFeed.length,
                      physics: const BouncingScrollPhysics(),
                      // Kartlar arası boşluğu ayarlayabiliriz
                      controller: PageController(
                        viewportFraction: 0.9,
                        initialPage: poemProvider.weeklyFeed.length - 1,
                      ),
                      itemBuilder: (context, index) {
                        return PremiumPoemCard(
                          poem: poemProvider.weeklyFeed[index],
                          onTap: () {},
                        );
                      },
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_note,
                            size: 80,
                            color: accentColor.withOpacity(0.3),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Henüz hiç şiir yok...',
                            style: GoogleFonts.nunito(
                              fontSize: 32,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Sağ üstteki (+) ikonuna basarak\nilk şiirini ekle.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            // Alt kısımda biraz boşluk bırakalım ki kart telefona yapışmasın
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // POPUP: Menü
  void _showMenuBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Menü',
                style: GoogleFonts.nunito(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _buildMenuItem(
                icon: Provider.of<ThemeProvider>(context).isDarkMode
                    ? Icons.light_mode
                    : Icons.dark_mode,
                label: 'Temayı Değiştir',
                onTap: () {
                  Navigator.pop(context);
                  Provider.of<ThemeProvider>(
                    context,
                    listen: false,
                  ).toggleTheme();
                },
              ),
              _buildMenuItem(
                icon: Icons.text_fields_rounded,
                label: 'Yazı Tipi',
                onTap: () {
                  Navigator.pop(context);
                  _showFontPicker(context);
                },
              ),
              _buildMenuItem(icon: Icons.settings, label: 'Ayarlar'),
              _buildMenuItem(icon: Icons.info_outline, label: 'Hakkında'),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        label,
        style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      onTap: onTap ?? () => Navigator.pop(context),
    );
  }

  void _showFontPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final backgroundColor = isDarkMode
            ? const Color(0xFF1E1E1E)
            : Colors.white;
        final baseTextColor = isDarkMode ? Colors.white70 : Colors.black87;
        final selectedTextColor = isDarkMode
            ? Colors.cyanAccent
            : Theme.of(context).primaryColor;

        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Yazı Tipi Seç',
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 300,
                  child: Consumer<PoemProvider>(
                    builder: (context, provider, child) {
                      final fonts = [
                        'Nunito',
                        'Lora',
                        'DancingScript',
                        'CourierPrime',
                        'Lato',
                        'Pacifico',
                      ];

                      return ListView.builder(
                        itemCount: fonts.length,
                        itemBuilder: (context, index) {
                          final font = fonts[index];
                          final isSelected = provider.contentFontFamily == font;
                          final itemColor = isSelected
                              ? selectedTextColor
                              : baseTextColor;

                          return ListTile(
                            title: Text(
                              font,
                              style: TextStyle(
                                fontFamily: font,
                                fontSize: 18,
                                color: itemColor,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle,
                                    color: selectedTextColor,
                                  )
                                : null,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              provider.setContentFontFamily(font);
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNoteInput(
    BuildContext context,
    MoodCategory mood,
    MoodProvider provider,
  ) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Text(mood.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Text(
                mood.name,
                style: GoogleFonts.nunito(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: TextField(
            controller: noteController,
            maxLines: 3,
            style: GoogleFonts.nunito(
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Bugün seni böyle hissettiren ne? (Opsiyonel)',
              hintStyle: GoogleFonts.nunito(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              filled: true,
              fillColor: isDark ? Colors.black12 : Colors.grey[100],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'İptal',
                style: GoogleFonts.nunito(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // Save Entry
                provider.saveDailyEntry(
                  DateTime.now(),
                  mood.code,
                  noteController.text,
                );

                // Close Dialog
                Navigator.pop(context);
                // Close BottomSheet (Check-in list)
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${mood.name} modunda hissettiğin günlüğüne işlendi.',
                      style: GoogleFonts.nunito(color: Colors.white),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              child: Text(
                'Kaydet',
                style: GoogleFonts.nunito(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMoodCheckIn(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.darkBackground
                  : AppTheme.lightBackground,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Bugün nasıl hissediyorsun?',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Consumer<MoodProvider>(
                    builder: (context, moodProvider, child) {
                      final moods = moodProvider.moods
                          .where((m) => m.code.isNotEmpty)
                          .toList();

                      return GridView.builder(
                        controller: scrollController,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                              childAspectRatio: 0.8,
                            ),
                        itemCount: moods.length,
                        itemBuilder: (context, index) {
                          final mood = moods[index];
                          // Simple grid item similar to AllMoodsScreen but simplified
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              _showNoteInput(context, mood, moodProvider);
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  mood.emoji,
                                  style: const TextStyle(fontSize: 40),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  mood.name,
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CircularRevealClipper extends CustomClipper<Path> {
  final Offset center;
  final double fraction;
  final double maxRadius;

  CircularRevealClipper({
    required this.center,
    required this.fraction,
    required this.maxRadius,
  });

  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.addOval(Rect.fromCircle(center: center, radius: fraction * maxRadius));
    return path;
  }

  @override
  bool shouldReclip(CircularRevealClipper oldClipper) {
    return fraction != oldClipper.fraction;
  }
}
