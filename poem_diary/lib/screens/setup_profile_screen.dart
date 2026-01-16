import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/providers.dart';
import 'main_scaffold.dart';

class SetupProfileScreen extends StatefulWidget {
  final bool isEditMode;

  const SetupProfileScreen({super.key, this.isEditMode = false});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<MoodProvider>(context, listen: false);

    _nameController = TextEditingController(
      text: widget.isEditMode ? provider.userName : '',
    );
    _titleController = TextEditingController(
      text: widget.isEditMode ? provider.userTitle : '',
    );
    if (widget.isEditMode) {
      _selectedImagePath = provider.profileImagePath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
      });
    }
  }

  Future<void> _completeSetup() async {
    final name = _nameController.text.trim();
    final title = _titleController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen adınızı girin.')));
      return;
    }

    final provider = Provider.of<MoodProvider>(context, listen: false);
    await provider.updateUserProfile(
      name,
      title.isNotEmpty ? title : "Şiir Tutkunu",
      _selectedImagePath,
    );

    if (!widget.isEditMode) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_setup_done', true);
    }

    if (mounted) {
      if (widget.isEditMode) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profil güncellendi!')));
      } else {
        // Navigate to Home. Since main.dart logic handles startup,
        // here we just replace this screen with Home.
        // We assume HomeTab is wrapped in MainScaffold usually,
        // but if we are replacing the root widget, we might need a Named route or MainScaffold.
        // Let's verify how main.dart sets up structure.
        // Assuming we can just push MainScaffold or similar?
        // For now, let's pushReplacement to a route named '/' if defined, or assume MainScaffold.
        // Better: Navigator.of(context).pushReplacement(...)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScaffold()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: widget.isEditMode
          ? AppBar(
              title: Text(
                "Profili Düzenle",
                style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  Icons.close,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              if (!widget.isEditMode) ...[
                const SizedBox(height: 60),
                Text(
                  "Hoşgeldin! 👋",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Tanışalım... Seni nasıl hitap etmeliyiz?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 48),
              ] else ...[
                const SizedBox(height: 20),
              ],

              // Photo Picker
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: isDark
                          ? Colors.white10
                          : Colors.grey[200],
                      backgroundImage: _selectedImagePath != null
                          ? FileImage(File(_selectedImagePath!))
                          : null,
                      child: _selectedImagePath == null
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Name Input
              TextField(
                controller: _nameController,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: "Adınız",
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                ),
              ),
              Container(
                height: 2,
                width: 120,
                color: isDark ? Colors.white24 : Colors.black12,
              ),

              const SizedBox(height: 30),

              // Title/Bio Input
              TextField(
                controller: _titleController,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
                decoration: InputDecoration(
                  hintText: "Kendinizi tanıtın (ör. Şiir Tutkunu)",
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white24 : Colors.black12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Container(
                height: 1,
                width: 80,
                color: isDark ? Colors.white24 : Colors.black12,
              ),

              const SizedBox(height: 60),

              // Start Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _completeSetup,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueAccent, // Use theme/brand color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                    shadowColor: Colors.blueAccent.withOpacity(0.4),
                  ),
                  child: Text(
                    widget.isEditMode ? "Kaydet" : "Başla",
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
