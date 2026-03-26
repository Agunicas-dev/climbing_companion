import 'package:climbing_companion/core/app_colors.dart';
import 'package:climbing_companion/core/app_size.dart';
import 'package:climbing_companion/extensions/ext_build_context.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("This is a placeholder for the home screen", style: context.textTheme.headlineMedium, textAlign: TextAlign.center,),
        ElevatedButton(
          onPressed: (){},
          child: Text(
            "Go to climbing log",
            style: context.textTheme.titleLarge?.copyWith(color: AppColors.white),
          ),
        ),
      ],
    );
  }
}