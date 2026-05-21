import 'package:climbing_companion/screens/home_screen.dart';
import 'package:climbing_companion/screens/logs_screen.dart';
import 'package:climbing_companion/screens/session_log_screen.dart';
import 'package:climbing_companion/services/settings_service.dart';
import 'package:climbing_companion/services/theme_service.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

// Global notifier to trigger theme/font changes from anywhere
final themeNotifier = ValueNotifier<String>('system');
final fontSizeNotifier = ValueNotifier<String>('medium');

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late ThemeData _theme;
  bool _themeLoaded = false;
  int currentPageIndex = 0;
  late final PageController _pageController;

  static const List<Widget> screens = [
    HomeScreen(),
    LogsScreen(),
  ];

  static const List<BottomNavigationBarItem> navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.list),
      label: 'Logs',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadTheme();
    themeNotifier.addListener(_onThemeChanged);
    fontSizeNotifier.addListener(_onThemeChanged);
  }

  Future<void> _loadTheme() async {
    final settings = await SettingsService.loadSettings();
    _theme = await ThemeService.buildTheme(settings.theme, settings.fontSize);
    themeNotifier.value = settings.theme;
    fontSizeNotifier.value = settings.fontSize;
    if (mounted) {
      setState(() {
        _themeLoaded = true;
      });
    }
  }

  Future<void> _onThemeChanged() async {
    final theme = await ThemeService.buildTheme(themeNotifier.value, fontSizeNotifier.value);
    if (mounted) {
      setState(() {
        _theme = theme;
      });
    }
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChanged);
    fontSizeNotifier.removeListener(_onThemeChanged);
    _pageController.dispose();
    super.dispose();
  }

  void logNewSession(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SessionLogScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_themeLoaded) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      theme: _theme,
      home: Builder(
        builder: (context) => Scaffold(
          body: SafeArea(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
              children: screens,
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentPageIndex,
            items: navItems,
            onTap: (index) {
              setState(() {
                currentPageIndex = index;
              });
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => logNewSession(context),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
