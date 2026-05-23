import 'package:climbing_companion/components/discipline_badge.dart';
import 'package:climbing_companion/components/profile_avatar.dart';
import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String username;
  final String? profilePicturePath;
  final bool doesBouldering;
  final bool doesLead;

  const ProfileCard({
    super.key,
    required this.username,
    this.profilePicturePath,
    this.doesBouldering = false,
    this.doesLead = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ProfileAvatar(profilePicturePath: profilePicturePath),
            ),
            VerticalDivider(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      username,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    if (doesBouldering || doesLead) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (doesBouldering)
                            const DisciplineBadge(
                              type: DisciplineBadgeType.bouldering,
                            ),
                          if (doesLead)
                            const DisciplineBadge(
                              type: DisciplineBadgeType.lead,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
