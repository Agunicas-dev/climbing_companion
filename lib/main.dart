import 'package:climbing_companion/screens/home_screen.dart';
import 'package:climbing_companion/style/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  @override
  Widget build(BuildContext context) {
    return MediaQuery(//Media query para conseguir el contexto del dispositivo y evitar que el texto se escale con la configuración del sistema.
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: ScreenUtilInit(//ScreenUtilInit para conseguir el contexto del dispositivo y poder usar los tamaños adaptativos.
        minTextAdapt: true,
        builder: (context, child) {
          return MaterialApp(//MaterialApp con el tema y la pantalla de inicio.
          title: 'Climbing Companion',
          theme: CustomTheme().light,
          themeMode: ThemeMode.light,
          home: Scaffold(//Scaffold con la pantalla de inicio.
            body: HomeScreen(),
          ),
        );
        },
      ),
    );
  }
}
