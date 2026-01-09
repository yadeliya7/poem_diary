import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/providers.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final poemProvider = Provider.of<PoemProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ayarlar",
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text("Karanlık Mod", style: GoogleFonts.nunito()),
            value: themeProvider.isDarkMode,
            activeColor: Colors.cyanAccent,
            onChanged: (value) {
              themeProvider.setDarkMode(value);
            },
          ),
          ListTile(
            title: Text("Yazı Tipi", style: GoogleFonts.nunito()),
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: poemProvider.contentFontFamily,
                dropdownColor: isDark ? Colors.grey[850] : Colors.white,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontFamily: 'Nunito',
                  fontSize: 16,
                ),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                items: ['Nunito', 'Dancing Script', 'Merriweather', 'Lora'].map(
                  (String font) {
                    return DropdownMenuItem<String>(
                      value: font,
                      child: Text(font, style: GoogleFonts.getFont(font)),
                    );
                  },
                ).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    poemProvider.setContentFontFamily(newValue);
                  }
                },
              ),
            ),
          ),
          // Add more settings here
        ],
      ),
    );
  }
}
