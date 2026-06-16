import 'package:flutter/material.dart';

import '../models/user_profile.dart';

class UserDetailsScreen extends StatelessWidget {
  final UserProfile user;

  const UserDetailsScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final String cityText = user.city ?? 'Brak miasta';
    final String ageText = user.age == null ? 'Brak wieku' : '${user.age} lat';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil użytkownika'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 48,
                    child: Icon(
                      Icons.person,
                      size: 56,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.username,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  buildInfoRow(
                    icon: Icons.badge,
                    label: 'ID użytkownika',
                    value: user.id.toString(),
                  ),
                  const Divider(),
                  buildInfoRow(
                    icon: Icons.email,
                    label: 'Email',
                    value: user.email,
                  ),
                  const Divider(),
                  buildInfoRow(
                    icon: Icons.location_city,
                    label: 'Miasto',
                    value: cityText,
                  ),
                  const Divider(),
                  buildInfoRow(
                    icon: Icons.cake,
                    label: 'Wiek',
                    value: ageText,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.green.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'To jest prosty ekran profilu znajomego. Na razie pokazujemy dane, które frontend już ma pobrane z backendu.',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}