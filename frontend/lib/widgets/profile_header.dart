import 'package:flutter/material.dart';

import '../models/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile? profile;

  const ProfileHeader({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    if (profile == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Brak danych profilu'),
        ),
      );
    }

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              child: Icon(Icons.person),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile!.username,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(profile!.email),
                  if (profile!.city != null)
                    Text('Miasto: ${profile!.city}'),
                  if (profile!.age != null)
                    Text('Wiek: ${profile!.age}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}