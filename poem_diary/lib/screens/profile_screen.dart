import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';

import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

import '../core/providers.dart';
import 'setup_profile_screen.dart';
import 'about_screen.dart';

import '../core/language_provider.dart';
import 'package:poem_diary/l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final moodProvider = Provider.of<MoodProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final poemProvider = Provider.of<PoemProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const SetupProfileScreen(isEditMode: true),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.withOpacity(0.1),
                            backgroundImage:
                                moodProvider.profileImagePath != null
                                ? FileImage(
                                    File(moodProvider.profileImagePath!),
                                  )
                                : const AssetImage('assets/images/bg_1.jpg')
                                      as ImageProvider,
                            child: moodProvider.profileImagePath == null
                                ? const Icon(
                                    LineIcons.user,
                                    size: 50,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.blueAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            moodProvider.userName == "Misafir Kullanıcı"
                                ? AppLocalizations.of(context)!.guestUser
                                : moodProvider.userName,
                            style: GoogleFonts.nunito(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                        ],
                      ),
                      Text(
                        moodProvider.userTitle == "Şiir Tutkunu"
                            ? AppLocalizations.of(context)!.defaultUserTitle
                            : moodProvider.userTitle,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Premium Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFDAA520), Color(0xFF8E44AD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFDAA520).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LineIcons.crown,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.goPremium,
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)!.premiumDesc,
                            style: GoogleFonts.nunito(
                              fontSize: 12,
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

              const SizedBox(height: 30),
              // --- GÖRÜNÜM (APPEARANCE) ---
              Text(
                AppLocalizations.of(context)!.sectionAppearance,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),

              // Theme Switch
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SwitchListTile(
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black26 : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDark ? LineIcons.moon : LineIcons.sun,
                      color: isDark ? Colors.purpleAccent : Colors.orange,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.darkMode,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  value: themeProvider.isDarkMode,
                  activeColor: Colors.purpleAccent,
                  onChanged: (val) => themeProvider.setDarkMode(val),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Language Switch
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SwitchListTile(
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black26 : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.language,
                      color: Colors.blueAccent,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    '${AppLocalizations.of(context)!.settingsLanguage}: ${languageProvider.currentLanguage == 'tr' ? 'Türkçe' : 'English'}',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  value: languageProvider.currentLanguage == 'en',
                  activeColor: Colors.blueAccent,
                  onChanged: (val) => languageProvider.toggleLanguage(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Font Selector
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black26 : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.font_download,
                      color: Colors.pinkAccent,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.settingFontTitle,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value:
                          [
                            'Nunito',
                            'Dancing Script',
                            'Merriweather',
                            'Lora',
                          ].contains(poemProvider.contentFontFamily)
                          ? poemProvider.contentFontFamily
                          : 'Nunito',
                      dropdownColor: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 14,
                      ),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey,
                      ),
                      items:
                          [
                            'Nunito',
                            'Dancing Script',
                            'Merriweather',
                            'Lora',
                          ].map((String font) {
                            return DropdownMenuItem<String>(
                              value: font,
                              child: Text(
                                font,
                                style: GoogleFonts.getFont(font),
                              ),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          poemProvider.setContentFontFamily(newValue);
                        }
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // --- AYARLAR (SETTINGS) ---
              Text(
                AppLocalizations.of(context)!.sectionOther,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),

              // Goal Duration Setting
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LineIcons.bullseye,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AppLocalizations.of(context)!.goalDuration,
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final options = [7, 14, 21, 30];
                        // Calculate width for 4 items with spacing
                        final itemWidth = (constraints.maxWidth - (3 * 8)) / 4;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: options.map((days) {
                            final isSelected =
                                moodProvider.goalDuration == days;
                            return InkWell(
                              onTap: () => moodProvider.setGoalDuration(days),
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: itemWidth,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : (isDark
                                            ? Colors.white10
                                            : Colors.grey[200]),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.transparent,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: Theme.of(
                                              context,
                                            ).primaryColor.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Center(
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.daysSuffix(days),
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark
                                                ? Colors.white70
                                                : Colors.black87),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Share
              _buildSettingTile(
                context,
                icon: LineIcons.share,
                title: AppLocalizations.of(context)!.shareApp,
                onTap: () => _shareApp(context),
                isDark: isDark,
              ),

              const SizedBox(height: 10),

              // About
              _buildSettingTile(
                context,
                icon: LineIcons.infoCircle,
                title: AppLocalizations.of(context)!.about,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  );
                },
                isDark: isDark,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.black26 : Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDark ? Colors.white70 : Colors.black54,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _shareApp(BuildContext context) {
    // Turkish marketing message
    final String message = AppLocalizations.of(context)!.shareMessage;
    //     + "https://example.com"; // Placeholder link

    // Share using share_plus
    try {
      Share.share(message);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.shareError(e.toString())),
        ),
      );
    }
  }
}
