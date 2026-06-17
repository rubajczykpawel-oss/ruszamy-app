import 'package:flutter/material.dart';

import '../models/app_group.dart';

class GroupCard extends StatelessWidget {
  final AppGroup group;
  final VoidCallback onTap;

  const GroupCard({
    super.key,
    required this.group,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTopSection(),
              const SizedBox(height: 14),
              buildDescription(),
              const SizedBox(height: 14),
              buildChipsSection(),
              const SizedBox(height: 14),
              buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTopSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.orange.shade100,
          child: const Icon(
            Icons.groups,
            size: 32,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.location_city,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      group.city,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildDescription() {
    if (group.description.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      group.description,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget buildChipsSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        buildSmallChip(
          icon: Icons.directions_walk,
          text: group.activityType,
        ),
        buildSmallChip(
          icon: Icons.person,
          text: 'Owner: ${group.ownerId}',
        ),
        buildSmallChip(
          icon: Icons.calendar_month,
          text: buildShortDate(),
        ),
      ],
    );
  }

  Widget buildBottomSection() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Grupa społecznościowa',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Szczegóły'),
        ),
      ],
    );
  }

  Widget buildSmallChip({
    required IconData icon,
    required String text,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 230,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String buildShortDate() {
    if (group.createdAt.length >= 10) {
      return group.createdAt.substring(0, 10);
    }

    return group.createdAt;
  }
}