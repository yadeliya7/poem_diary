import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/poem_model.dart';
import '../core/providers.dart';
import '../core/language_provider.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

void showMoodEntryDialog(
  BuildContext context, {
  required DateTime date,
  required MoodProvider provider,
  String? currentMood,
  String? currentNote,
  List<String> currentMedia = const [],
}) {
  // Determine initial mood if editing
  MoodCategory? selectedMood;
  if (currentMood != null) {
    try {
      selectedMood = provider.moods.firstWhere((m) => m.code == currentMood);
    } catch (e) {
      selectedMood = null;
    }
  }

  final moodNotifier = ValueNotifier<MoodCategory?>(selectedMood);
  final noteController = TextEditingController(text: currentNote);
  // Local state for media
  List<String> selectedMedia = List.from(currentMedia);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25),
              ),
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    // 1. Header: Close + Date + Save
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Text(
                            DateFormat(
                              'd MMMM yyyy',
                              Provider.of<LanguageProvider>(
                                context,
                              ).currentLanguage,
                            ).format(date),
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              if (moodNotifier.value == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      Provider.of<LanguageProvider>(
                                        context,
                                        listen: false,
                                      ).translate('msg_field_required'),
                                      style: GoogleFonts.nunito(),
                                    ),
                                  ),
                                );
                                return;
                              }
                              provider.saveDailyEntry(
                                date,
                                moodNotifier.value!.code,
                                noteController.text,
                                selectedMedia,
                              );
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    Provider.of<LanguageProvider>(
                                      context,
                                      listen: false,
                                    ).translate('msg_entry_saved'),
                                    style: GoogleFonts.nunito(
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: Text(
                              Provider.of<LanguageProvider>(
                                context,
                              ).translate('btn_save'),
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. Mood Selector
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: provider.moods
                              .where((m) => m.code.isNotEmpty)
                              .map((mood) {
                                final isSelected =
                                    moodNotifier.value?.code == mood.code;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      moodNotifier.value = mood;
                                    });
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? _getMoodColor(mood.code)
                                              : Colors.transparent,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.transparent
                                                : Colors.grey.withValues(
                                                    alpha: 0.3,
                                                  ),
                                          ),
                                        ),
                                        child: Text(
                                          mood.emoji,
                                          style: TextStyle(
                                            fontSize: isSelected ? 28 : 24,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        Provider.of<LanguageProvider>(
                                          context,
                                        ).translate('mood_${mood.code}'),
                                        style: GoogleFonts.nunito(
                                          fontSize: 10,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? (isDark
                                                    ? Colors.white
                                                    : Colors.black87)
                                              : (isDark
                                                    ? Colors.white54
                                                    : Colors.black54),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              })
                              .toList(),
                        ),
                      ),
                    ),

                    // 3. Expanded Text Field + Media Preview
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 16.0,
                              ),
                              child: TextField(
                                controller: noteController,
                                expands: true,
                                maxLines: null,
                                minLines: null,
                                keyboardType: TextInputType.multiline,
                                textAlignVertical: TextAlignVertical.top,
                                style: GoogleFonts.lora(
                                  fontSize: 18,
                                  height: 1.6,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  hintText: Provider.of<LanguageProvider>(
                                    context,
                                  ).translate('hint_write_note'),
                                  hintStyle: GoogleFonts.lora(
                                    color: isDark
                                        ? Colors.white24
                                        : Colors.black26,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ),

                          // Media Preview List
                          if (selectedMedia.isNotEmpty)
                            Container(
                              height: 80,
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: selectedMedia.length,
                                itemBuilder: (context, index) {
                                  final path = selectedMedia[index];

                                  return Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: buildMediaThumbnail(
                                            path,
                                            width: 80,
                                            height: 80,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedMedia.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.all(2),
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black54,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),

                          // Bottom Toolbar
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black26 : Colors.grey[200],
                              border: Border(
                                top: BorderSide(
                                  color: isDark
                                      ? Colors.white10
                                      : Colors.black12,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.add_photo_alternate_rounded,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                  onPressed: () async {
                                    try {
                                      final picker = ImagePicker();
                                      final List<XFile> medias = await picker
                                          .pickMultipleMedia();
                                      if (medias.isNotEmpty) {
                                        setState(() {
                                          selectedMedia.addAll(
                                            medias.map((m) => m.path),
                                          );
                                        });
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Medya seçilemedi: Sistem hatası.',
                                            style: GoogleFonts.nunito(),
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  tooltip: 'Fotoğraf/Video Ekle',
                                ),
                                const Spacer(),
                                Text(
                                  '${selectedMedia.length} dosya',
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black38,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      );
    },
  );
}

Widget buildMediaThumbnail(
  String path, {
  double width = 100,
  double height = 100,
}) {
  final ext = path.split('.').last.toLowerCase();

  // Video
  if (['mp4', 'mov', 'avi'].contains(ext)) {
    return Container(
      width: width,
      height: height,
      color: Colors.black87,
      child: Icon(
        Icons.play_circle_fill,
        color: Colors.white,
        size: width * 0.4,
      ),
    );
  }

  // PDF
  if (['pdf'].contains(ext)) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf, color: Colors.red, size: width * 0.4),
          const SizedBox(height: 4),
          Text(
            'PDF',
            style: const TextStyle(fontSize: 10, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // Audio
  if (['mp3', 'm4a', 'wav'].contains(ext)) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Icon(Icons.mic, color: Colors.blue, size: width * 0.4),
    );
  }

  // Image
  if (['jpg', 'jpeg', 'png', 'heic', 'webp'].contains(ext)) {
    return Image.file(
      File(path),
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Icon(
            Icons.broken_image,
            color: Colors.grey,
            size: width * 0.4,
          ),
        );
      },
    );
  }

  // Default
  return Container(
    width: width,
    height: height,
    color: Colors.grey[300],
    child: Icon(Icons.insert_drive_file, color: Colors.grey, size: width * 0.4),
  );
}

Color _getMoodColor(String moodCode) {
  switch (moodCode) {
    case 'sad':
      return Colors.blue[300]!;
    case 'happy':
      return Colors.yellow[300]!;
    case 'romantic':
      return Colors.pink[300]!;
    case 'mystic':
      return Colors.purple[300]!;
    case 'tired':
      return Colors.grey[400]!;
    case 'hopeful':
      return Colors.green[300]!;
    case 'peaceful':
      return Colors.cyan[300]!;
    case 'nostalgic':
      return Colors.orange[300]!;
    default:
      return Colors.blueGrey[200]!;
  }
}
