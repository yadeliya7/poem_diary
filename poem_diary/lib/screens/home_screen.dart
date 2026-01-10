import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart'; // Titreşim için

import '../core/theme.dart';
import '../core/providers.dart';
import '../core/language_provider.dart';

import '../widgets/premium_poem_card.dart';
import '../widgets/aurora_button.dart';
import 'favorites_screen.dart';
import 'all_moods_screen.dart';
import 'mood_calendar_screen.dart';
import 'compose_poem_screen.dart';
import '../models/poem_model.dart';
import '../widgets/mood_entry_dialog.dart'; // Unified Dialog

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _addPoemButtonKey = GlobalKey();

  // Local methods _showNoteInput and _showMoodCheckIn removed in favor of MoodEntryDialog

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final poemProvider = Provider.of<PoemProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);

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

            // DAILY CHECK-IN (Unified Dialog Integration)
            Consumer<MoodProvider>(
              builder: (context, moodProvider, child) {
                final today = DateTime.now();
                final entry = moodProvider.getEntryForDate(today);

                // Common decoration
                final decoration = BoxDecoration(
                  color: isDarkMode
                      ? AppTheme.darkAccent.withOpacity(0.1)
                      : AppTheme.lightAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDarkMode
                        ? AppTheme.darkAccent.withOpacity(0.3)
                        : AppTheme.lightAccent.withValues(alpha: 0.3),
                  ),
                );

                if (entry != null) {
                  // HAS ENTRY -> Show Summary Card (Edit Mode)
                  final mood = moodProvider.moods.firstWhere(
                    (m) => m.code == entry.moodCode,
                    orElse: () => MoodCategory(
                      id: '',
                      code: '',
                      name: '',
                      emoji: '❓',
                      description: '',
                      backgroundGradient: '',
                      color: Colors.grey,
                    ),
                  );
                  final hasMedia = entry.mediaPaths.isNotEmpty;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 0,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        showMoodEntryDialog(
                          context,
                          date: today,
                          provider: moodProvider,
                          currentMood: entry.moodCode,
                          currentNote: entry.note,
                          currentMedia: entry.mediaPaths,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: decoration, // Reusing decoration
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDarkMode
                                    ? Colors.white10
                                    : Colors.white54,
                              ),
                              child: Text(
                                mood.emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Bugün: ${mood.name}",
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  if (entry.note != null &&
                                      entry.note!.isNotEmpty)
                                    Text(
                                      entry.note!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.nunito(
                                        fontSize: 12,
                                        color: isDarkMode
                                            ? Colors.white54
                                            : Colors.black54,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (hasMedia)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? Colors.black26
                                      : Colors.white54,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.attach_file,
                                      size: 14,
                                      color: accentColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${entry.mediaPaths.length}',
                                      style: GoogleFonts.nunito(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: accentColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(width: 8),
                            Icon(Icons.edit, size: 18, color: accentColor),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  // NO ENTRY -> Show Check-in Button (Create Mode)
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 0,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        showMoodEntryDialog(
                          context,
                          date: today,
                          provider: moodProvider,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: decoration,
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
                              lang.translate('mood_title'),
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
                              color: isDarkMode
                                  ? Colors.white54
                                  : Colors.black54,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
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
                            color: accentColor.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            lang.translate('empty_feed'),
                            style: GoogleFonts.nunito(
                              fontSize: 32,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            lang.translate('empty_feed_subtitle'),
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
      builder: (context) {
        final lang = Provider.of<LanguageProvider>(context);
        return Container(
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
                  lang.translate('menu'),
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
                  label: lang.translate('change_theme'),
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
                  label: lang.translate('font_style'),
                  onTap: () {
                    Navigator.pop(context);
                    _showFontPicker(context);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.settings,
                  label: lang.translate('settings'),
                ),
                _buildMenuItem(
                  icon: Icons.info_outline,
                  label: lang.translate('about'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
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
        final lang = Provider.of<LanguageProvider>(context);
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
                  lang.translate('font_style'),
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
