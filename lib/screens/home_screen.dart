import 'package:climbing_companion/components/profile_card.dart';
import 'package:climbing_companion/screens/climbing_log_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Home", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        shadowColor: Colors.black,
        elevation: 3,
        actions: [

          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              /*Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClimbingLogScreen()),
              );*/
            },
          ),
        ]
      ),
      body: Column(
          children: [
            ProfileCard(username: "Fugu", profilePictureUrl: "https://img.freepik.com/vector-premium/cute-fugu-puffer-fish-personaje-dibujos-animados-graficos-vectoriales-premium-estilo-pegatinas_324746-1016.jpg"),
          ],      
      ),
    );
  }

}
