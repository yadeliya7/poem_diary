import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/poem_model.dart';
import '../core/providers.dart';
import '../widgets/premium_poem_card.dart';

class PoemDetailScreen extends StatelessWidget {
  final Poem poem;

  const PoemDetailScreen({super.key, required this.poem});

  @override
  Widget build(BuildContext context) {
    return Consumer<PoemProvider>(
      builder: (context, poemProvider, child) {
        // Ensure we have the latest version of the poem (for favorite status)
        final currentPoem = poemProvider.getPoemById(poem.id) ?? poem;
        final isFav = currentPoem.isFavorite;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.redAccent : Colors.white,
                  size: 28,
                ),
                onPressed: () {
                  poemProvider.toggleFavorite(currentPoem.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFav
                            ? 'Favorilerden çıkarıldı.'
                            : 'Favorilere eklendi! ❤️',
                      ),
                      duration: const Duration(milliseconds: 1000),
                      backgroundColor: isFav ? Colors.black54 : Colors.red,
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
            ],
          ),
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: PremiumPoemCard(
              poem: currentPoem,
              onTap: () {}, // Already in detail view
              showUI: true,
              showExpandButton:
                  false, // Don't show expand button in detail view
              showFavoriteButton:
                  false, // Don't show favorite button in card (it's in AppBar)
            ),
          ),
        );
      },
    );
  }
}
