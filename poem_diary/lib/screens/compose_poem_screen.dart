import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../core/providers.dart';
import '../models/poem_model.dart';

class ComposePoemScreen extends StatefulWidget {
  const ComposePoemScreen({Key? key}) : super(key: key);

  @override
  State<ComposePoemScreen> createState() => _ComposePoemScreenState();
}

class _ComposePoemScreenState extends State<ComposePoemScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _savePoem() {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lütfen başlık ve şiir içeriğini girin.',
            style: GoogleFonts.nunito(),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final newPoem = Poem(
      id: DateTime.now().toString(),
      title: _titleController.text,
      content: _contentController.text,
      author: _authorController.text.trim().isEmpty
          ? 'Ben'
          : _authorController.text.trim(),
      mood: 'happy', // Default mood
      createdAt: DateTime.now(),
      // Default background will be empty, or we can assign a random one?
      // Use clean style by default or allow user to pick later.
    );

    Provider.of<PoemProvider>(context, listen: false).addUserPoem(newPoem);
    HapticFeedback.mediumImpact();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Şiirin günlüğüne eklendi! ✨',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final fontName = Provider.of<PoemProvider>(context).contentFontFamily;

    // Light Mode Gradient: Cyan/Turquoise -> Soft Purple
    final lightModeColors = [const Color(0xFF5EE7DF), const Color(0xFFB490CA)];

    // Dark Mode Gradient: Deep Indigo -> Dark Midnight Blue
    final darkModeColors = [
      const Color(0xFF0F2027), // Deep Indigo
      const Color(0xFF203A43), // Dark Violet
      const Color(0xFF2C5364), // Midnight Blue
    ];

    return Scaffold(
      extendBodyBehindAppBar: true, // Allow gradient to go behind AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: _savePoem,
              style: TextButton.styleFrom(
                foregroundColor: isDarkMode ? Colors.white70 : Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'KAYDET',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode ? darkModeColors : lightModeColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Column(
              children: [
                // Title Input
                TextField(
                  controller: _titleController,
                  style: TextStyle(
                    fontFamily: fontName,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: 'Başlık...',
                    hintStyle: TextStyle(
                      fontFamily: fontName,
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _authorController,
                  style: TextStyle(
                    fontFamily: fontName,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.white70,
                  ),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: 'Şair / Mahlas',
                    hintStyle: TextStyle(
                      fontFamily: fontName,
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 10),
                // Content Input
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    maxLines: null, // Unlimited lines
                    expands: true, // Fill available space
                    textAlignVertical: TextAlignVertical.top,
                    style: TextStyle(
                      fontFamily: fontName,
                      fontSize: 18,
                      height: 1.6, // Better line height for reading
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: 'İçindekileri dök...',
                      hintStyle: TextStyle(
                        fontFamily: fontName,
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
