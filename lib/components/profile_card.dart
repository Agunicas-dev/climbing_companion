import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String username;
  final String profilePictureUrl;

  const ProfileCard({super.key, required this.username, required this.profilePictureUrl});
  //TODO: Add a gesture detector to the card to allow the user to tap on it and go to the profile screen.
  //Will need to create a profile screen, wich will be generated on the fly from the info shown in the card.
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Expanded(
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(profilePictureUrl),
              ),
            ),
          ),
          VerticalDivider(width: 16),
          Column( mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(username, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,),
            ],
          ),
        ],
      ),
    );
  }
}