import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:google_nav_bar/google_nav_bar.dart';

import 'home_tab.dart';
import 'mood_calendar_screen.dart';
import 'library_screen.dart';
import 'compose_poem_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 1; // Default to Home

  final List<Widget> _widgetOptions = <Widget>[
    const LibraryScreen(), // Index 0: Kitaplık
    const HomeTab(), // Index 1: Akış (Home)
    const MoodCalendarScreen(), // Index 2: Takvim
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true, // For transparent nav bar effect if needed
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: isDark
                  ? Colors.black.withOpacity(0.6)
                  : Colors.white.withOpacity(0.7),
              child: Padding(
                padding: const EdgeInsets.all(
                  10,
                ), // Internal padding for the glass container
                child: GNav(
                  gap: 0,
                  activeColor: isDark ? Colors.white : Colors.black,
                  color: Colors.grey,
                  tabBackgroundColor: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutExpo,
                  selectedIndex: _selectedIndex,
                  onTabChange: _onItemTapped,
                  tabs: const [
                    GButton(icon: Icons.bookmarks, text: ''),
                    GButton(icon: Icons.home_filled, text: ''),
                    GButton(icon: Icons.calendar_month, text: ''),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open ComposePoemScreen with a nice transition
          // Open ComposePoemScreen with a nice transition
          Navigator.of(context).push(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const ComposePoemScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            ),
          );
        },
        backgroundColor: Colors.orangeAccent, // distinct accent
        child: const Icon(Icons.edit, color: Colors.white),
        elevation: 4,
      ),
      // Depending on layout, we might want centerDocked, but simpler is safer first.
      // If we used a notched shape, we'd need BottomAppBar.
      // Standard FAB is fine.
    );
  }
}

// Reusing the Clipper (copied from HomeScreen or moved to utils)
// I'll duplicate it here to be safe and avoid tight coupling unless I move it to utils.
// Moving to utils is better but for speed I'll include it here or verify if it's public in HomeScreen.
// It was at the bottom of HomeScreen. ideally I should move it to a shared file.
// I will move it to lib/utils/ui_utils.dart in a future step or just duplicate for now.
// I'll duplicate for now to minimize file touches, will comment to refactor.
