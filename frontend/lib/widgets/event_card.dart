import 'package:flutter/material.dart';

import '../models/app_event.dart';

class EventCard extends StatelessWidget {
  final AppEvent event;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double participantsProgress = getParticipantsProgress();

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
              buildParticipantsSection(participantsProgress),
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
          backgroundColor: Colors.green.shade100,
          child: const Icon(
            Icons.directions_walk,
            size: 32,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
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
                      '${event.city} • ${event.locationName}',
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
    if (event.description.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      event.description,
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
          text: event.activityType,
        ),
        buildSmallChip(
          icon: Icons.signal_cellular_alt,
          text: event.level,
        ),
        buildSmallChip(
          icon: Icons.calendar_month,
          text: event.date,
        ),
        buildSmallChip(
          icon: Icons.schedule,
          text: event.time,
        ),
        if (event.ageMin != null || event.ageMax != null)
          buildSmallChip(
            icon: Icons.cake,
            text: buildAgeText(),
          ),
        if (event.groupId != null)
          buildSmallChip(
            icon: Icons.groups,
            text: 'Grupa ID: ${event.groupId}',
          ),
      ],
    );
  }

  Widget buildParticipantsSection(double participantsProgress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.people,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              'Uczestnicy: ${event.participantsCount}/${event.maxParticipants}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: participantsProgress,
          minHeight: 8,
          borderRadius: BorderRadius.circular(20),
        ),
      ],
    );
  }

  Widget buildBottomSection() {
    return Row(
      children: [
        Expanded(
          child: Text(
            event.isPublic ? 'Wydarzenie publiczne' : 'Wydarzenie prywatne',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
        ),
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
    return Container(
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
          Text(
            text,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  String buildAgeText() {
    if (event.ageMin != null && event.ageMax != null) {
      return '${event.ageMin}-${event.ageMax} lat';
    }

    if (event.ageMin != null) {
      return 'od ${event.ageMin} lat';
    }

    if (event.ageMax != null) {
      return 'do ${event.ageMax} lat';
    }

    return 'bez limitu wieku';
  }

  double getParticipantsProgress() {
    if (event.maxParticipants <= 0) {
      return 0;
    }

    return (event.participantsCount / event.maxParticipants)
        .clamp(0.0, 1.0)
        .toDouble();
  }
}