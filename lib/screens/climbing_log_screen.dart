/*This screen will be used to review a climbing log session entry.
It will offer decently detailed info about the */

import 'package:flutter/material.dart';

class ClimbingLog extends StatelessWidget {
  const ClimbingLog({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black),
        ),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Text('Climbing log screen'),
        ),
      ),
    );
  }
}
