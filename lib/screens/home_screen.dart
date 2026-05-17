import 'package:climbing_companion/components/profile_card.dart';
import 'package:climbing_companion/screens/settings_screen.dart';
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
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      SettingsScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        //Difining the constants for the navigation animation.
                        //Doing it with constants to make the code more readable and easier to change if needed.
                        //Don't know if this is the best way to do it, had to rely on ai and online forum posts for this one a bit.
                        const begin = Offset.zero;
                        const end = Offset(-1.0, 0.0);
                        const curve = Curves.easeOutSine;
                        const secondaryBegin = Offset(1.0, 0.0);
                        const secondaryEnd = Offset.zero;

                        var tween = Tween(
                          begin: begin,
                          end: end,
                        ).chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);

                        var secondaryTween = Tween(
                          begin: secondaryBegin,
                          end: secondaryEnd,
                        ).chain(CurveTween(curve: curve));
                        var secondaryOffsetAnimation = secondaryAnimation.drive(
                          secondaryTween,
                        );

                        return SlideTransition(
                          position: offsetAnimation,
                          child: SlideTransition(
                            position: secondaryOffsetAnimation,
                            child: child,
                          ),
                        );
                      },
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ProfileCard(
            username: "Fugu",
            profilePictureUrl:
                "https://img.freepik.com/vector-premium/cute-fugu-puffer-fish-personaje-dibujos-animados-graficos-vectoriales-premium-estilo-pegatinas_324746-1016.jpg",
          ),
        ],
      ),
    );
  }
}
