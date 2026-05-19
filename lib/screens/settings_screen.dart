import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Settings", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        shadowColor: Colors.black,
        elevation: 3,
      ),
      body: Column(
          children: [
            Text("Settings will be here"),
            //TODO: Add settings.
            /*
            -Profile (Username, picture, bio, location)
            -Preferences (Grading system, units, language, notifications)
            -Appearance (Theme, font size, color scheme)
            */
            
          ],      
      ),
    );
  }
}