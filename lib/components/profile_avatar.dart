import 'dart:io';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? profilePicturePath;
  final double radius;
  final Brightness? brightnessOverride;

  const ProfileAvatar({
    super.key,
    this.profilePicturePath,
    this.radius = 40,
    this.brightnessOverride,
  });

  String _defaultProfilePath(BuildContext context) {
    final brightness = brightnessOverride ?? Theme.of(context).brightness;
    final suffix = brightness == Brightness.dark ? 'dark' : 'light';
    return 'lib/assets/images/default_profile_$suffix.png';
  }

  @override
  Widget build(BuildContext context) {
    final customPath = profilePicturePath;
    final imagePath = customPath != null && customPath.isNotEmpty
        ? customPath
        : _defaultProfilePath(context);
    final diameter = radius * 2;

    return ClipOval(
      child: SizedBox(
        key: ValueKey(imagePath),
        width: diameter,
        height: diameter,
        child:
            customPath != null &&
                customPath.isNotEmpty &&
                File(customPath).existsSync()
            ? Image.file(File(customPath), fit: BoxFit.cover)
            : Image.asset(imagePath, fit: BoxFit.cover),
      ),
    );
  }
}
