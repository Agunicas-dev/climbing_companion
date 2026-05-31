import 'package:climbing_companion/components/session_type_dialog.dart';
import 'package:climbing_companion/models/session_type.dart';
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
final seedColorNotifier = ValueNotifier<String>('#81D4FA');

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}
//The main app widget that sets up the overall structure of the application, including theme management and navigation
//between the home and logs screens. It listens for changes in theme settings and updates the app's theme accordingly.
//The floating action button is used to start a new climbing session by showing a dialog to select the session type and then navigating to the session log screen.
class _MainAppState extends State<MainApp> {
  late ThemeData _lightTheme;
  late ThemeData _darkTheme;
  ThemeMode _themeMode = ThemeMode.system;
  bool _themeLoaded = false;
  int currentPageIndex = 0;
  late final PageController _pageController;
  late String _seedColor;

  static const List<Widget> screens = [HomeScreen(), LogsScreen()];

  static const List<BottomNavigationBarItem> navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Logs'),
  ];

  // Initialize the theme and page controller, and set up listeners for theme changes.
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadTheme();
    themeNotifier.addListener(_onThemeChanged);
    fontSizeNotifier.addListener(_onThemeChanged);
    seedColorNotifier.addListener(_onThemeChanged);
  }

  //Function to load the theme settings from the SettingsService and build the light and dark themes based on those settings.
  Future<void> _loadTheme() async {
    final settings = await SettingsService.loadSettings();
    _seedColor = settings.seedColor;
    final seedColor = ThemeService.seedColorFromHex(_seedColor);
    _lightTheme = ThemeService.buildTheme(
      Brightness.light,
      settings.fontSize,
      seedColor,
    );
    _darkTheme = ThemeService.buildTheme(
      Brightness.dark,
      settings.fontSize,
      seedColor,
    );
    _themeMode = ThemeService.themeModeFromString(settings.theme);
    themeNotifier.value = settings.theme;
    fontSizeNotifier.value = settings.fontSize;
    seedColorNotifier.value = settings.seedColor;
    if (mounted) {
      setState(() {
        _themeLoaded = true;
      });
    }
  }


  //Handling theme changes by rebuilding the light and dark themes based on the new settings and updating the theme mode.
  void _onThemeChanged() {
    _seedColor = seedColorNotifier.value;
    final seedColor = ThemeService.seedColorFromHex(_seedColor);
    _lightTheme = ThemeService.buildTheme(
      Brightness.light,
      fontSizeNotifier.value,
      seedColor,
    );
    _darkTheme = ThemeService.buildTheme(
      Brightness.dark,
      fontSizeNotifier.value,
      seedColor,
    );
    _themeMode = ThemeService.themeModeFromString(themeNotifier.value);
    if (mounted) {
      setState(() {});
    }
  }

  // Remove listeners and dispose of the page controller when the widget is removed from the widget tree to prevent memory leaks and ensure proper cleanup of resources.
  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChanged);
    fontSizeNotifier.removeListener(_onThemeChanged);
    _pageController.dispose();
    super.dispose();
  }


  //Function to handle starting a new climbing session. It shows a dialog calling SessionTypeDialog component to select the
  //session type and then navigates to the session log screen for that session type.
  Future<void> logNewSession(BuildContext context) async {
    final sessionType = await showDialog<SessionType>(
      context: context,
      builder: (context) => const SessionTypeDialog(),
    );
    if (sessionType == null || !context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionLogScreen(sessionType: sessionType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //If the theme is still loading, show a loading indicator.
    if (!_themeLoaded) {
      return MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    //Once the theme is loaded, return the MaterialApp with the appropriate theme and navigation structure.
    return MaterialApp(
      //Theme data.
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: _themeMode,

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

          //Navigation bar for changing between home and logs screens.
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

          //Floating action button used to start a new climbing session.
          floatingActionButton: FloatingActionButton(
            onPressed: () => logNewSession(context),
            shape: const CircleBorder(),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
