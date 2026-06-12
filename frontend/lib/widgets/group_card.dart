import 'package:flutter/material.dart';

import '../models/app_group.dart';
import 'info_chip.dart';

class GroupCard extends StatelessWidget {
  final AppGroup group;

  const GroupCard({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(group.description),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                InfoChip(
                  icon: Icons.location_city,
                  label: group.city,
                ),
                InfoChip(
                  icon: Icons.directions_walk,
                  label: group.activityType,
                ),
                InfoChip(
                  icon: Icons.person,
                  label: 'Owner ID: ${group.ownerId}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}