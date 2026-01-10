import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/providers.dart';
import '../core/language_provider.dart';
import '../widgets/premium_poem_card.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final lang = Provider.of<LanguageProvider>(context);

    // Scaffold'ın DefaultTabController ile sarmalanması
    return DefaultTabController(
      length: 2, // 2 Sekme: Favorilerim ve Yazdıklarım
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: null,
          automaticallyImplyLeading: false, // Root tab, no back button
          title: Text(
            lang.translate('library'),
            style: GoogleFonts.nunito(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: isDarkMode ? Colors.white : Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: isDarkMode ? Colors.white : Colors.black,
            labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.bold),
            tabs: [
              Tab(
                icon: Icon(Icons.favorite),
                text: lang.translate('favorites'),
              ),
              Tab(
                icon: Icon(Icons.edit_note),
                text: lang.translate('my_poems'),
              ),
            ],
          ),
        ),
        body: const TabBarView(children: [_FavoritesTab(), _UserPoemsTab()]),
      ),
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab();

  @override
  @override
  Widget build(BuildContext context) {
    // Provider'ı burada dinliyoruz
    final poemProvider = Provider.of<PoemProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);
    final favorites = poemProvider.favoritePoems;

    if (favorites.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite_border,
        message: lang.translate('empty_fav_title'),
        subMessage: lang.translate('empty_fav_sub'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final poem = favorites[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: SizedBox(
            height: 500,
            child: PremiumPoemCard(
              poem: poem,
              onTap: () {},
              showUI: true, // Kullanıcı favorilerden kaldırabilsin diye UI açık
            ),
          ),
        );
      },
    );
  }
}

class _UserPoemsTab extends StatelessWidget {
  const _UserPoemsTab();

  @override
  @override
  Widget build(BuildContext context) {
    // Provider'ı burada dinliyoruz
    final poemProvider = Provider.of<PoemProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);
    final userPoems = poemProvider.userPoems;

    if (userPoems.isEmpty) {
      return _buildEmptyState(
        icon: Icons.rate_review_outlined,
        message: lang.translate('empty_poems_title'),
        subMessage: lang.translate('empty_poems_sub'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: userPoems.length,
      itemBuilder: (context, index) {
        final poem = userPoems[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: SizedBox(
            height: 500,
            child: PremiumPoemCard(
              poem: poem,
              onTap: () {},
              showUI: true, // Paylaşma vs. için UI açık kalsın
            ),
          ),
        );
      },
    );
  }
}

// Ortak Empty State Widget'ı
Widget _buildEmptyState({
  required IconData icon,
  required String message,
  required String subMessage,
}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
        const SizedBox(height: 20),
        Text(
          message,
          style: GoogleFonts.nunito(
            fontSize: 18,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subMessage,
          style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
