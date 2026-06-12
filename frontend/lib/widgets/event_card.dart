import 'package:flutter/material.dart';

import '../models/app_event.dart';
import 'info_chip.dart';

class EventCard extends StatelessWidget {
  final AppEvent event;

  const EventCard({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final String ageText = buildAgeText();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(event.description),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                InfoChip(
                  icon: Icons.location_city,
                  label: event.city,
                ),
                InfoChip(
                  icon: Icons.place,
                  label: event.locationName,
                ),
                InfoChip(
                  icon: Icons.calendar_month,
                  label: event.date,
                ),
                InfoChip(
                  icon: Icons.access_time,
                  label: event.time,
                ),
                InfoChip(
                  icon: Icons.directions_walk,
                  label: event.activityType,
                ),
                InfoChip(
                  icon: Icons.signal_cellular_alt,
                  label: event.level,
                ),
                InfoChip(
                  icon: Icons.people,
                  label: '${event.participantsCount}/${event.maxParticipants}',
                ),
                if (ageText.isNotEmpty)
                  InfoChip(
                    icon: Icons.cake,
                    label: ageText,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String buildAgeText() {
    if (event.ageMin == null && event.ageMax == null) {
      return '';
    }

    if (event.ageMin != null && event.ageMax != null) {
      return '${event.ageMin}-${event.ageMax} lat';
    }

    if (event.ageMin != null) {
      return 'od ${event.ageMin} lat';
    }

    return 'do ${event.ageMax} lat';
  }
}