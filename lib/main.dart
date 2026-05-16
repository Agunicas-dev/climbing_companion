import 'package:climbing_companion/screens/home_screen.dart';
import 'package:climbing_companion/screens/logs_screen.dart';
import 'package:climbing_companion/screens/session_log_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int currentPageIndex = 0;

  //Defining a PageController in order to be able to 
  final PageController _pageController = PageController(initialPage: 0);

//List of screens to be used in the PageView and BottomNavigationBar.
  static const List<Widget> screens = [
    HomeScreen(),
    LogsScreen(),
  ];

//Items for the NavBar, allowing the user to switch between the different screens.
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
  

//Disposal of the page controller to make the app more efficient.
  @override
  void dispose() {
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
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          //add pageview to the scaffold body.
          body: SafeArea(
            child: PageView(
              //adding the controller to manage the page view.
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

          //Adding the bottom NavBar
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentPageIndex,
            items: navItems,

            //actions on tap of a nav item.
            onTap: (index) {
              setState(() {
                currentPageIndex = index;
              });

              //Animate the page change to make it slide smoothly between screens.
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
