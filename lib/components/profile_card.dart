import 'dart:io';
import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String username;
  final String profilePictureUrl;
  final String? profilePicturePath;

  const ProfileCard({
    super.key,
    required this.username,
    required this.profilePictureUrl,
    this.profilePicturePath,
  });

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
                backgroundImage: profilePicturePath != null && profilePicturePath!.isNotEmpty
                    ? FileImage(File(profilePicturePath!)) as ImageProvider
                    : NetworkImage(profilePictureUrl),
              ),
            ),
          ),
          VerticalDivider(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                username,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ],
      ),
    );
  }
}