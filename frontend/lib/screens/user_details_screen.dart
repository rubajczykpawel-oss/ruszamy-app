import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/friends_api_service.dart';

class UserDetailsScreen extends StatefulWidget {
  final UserProfile user;
  final String token;

  const UserDetailsScreen({
    super.key,
    required this.user,
    required this.token,
  });

  @override
  State<UserDetailsScreen> createState() {
    return _UserDetailsScreenState();
  }
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final FriendsApiService friendsApiService = FriendsApiService();

  bool isRemovingFriend = false;
  String errorMessage = '';

  Future<void> confirmRemoveFriend() async {
    final bool? shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Usunąć znajomego?'),
          content: Text(
            'Czy na pewno chcesz usunąć użytkownika "${widget.user.username}" ze znajomych?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Anuluj'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Usuń'),
            ),
          ],
        );
      },
    );

    if (shouldRemove == true) {
      removeFriend();
    }
  }

  Future<void> removeFriend() async {
    setState(() {
      isRemovingFriend = true;
      errorMessage = '';
    });

    try {
      await friendsApiService.removeFriend(
        token: widget.token,
        friendId: widget.user.id,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (error) {
      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          isRemovingFriend = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String cityText = widget.user.city ?? 'Brak miasta';

    final String ageText = widget.user.age == null
        ? 'Brak wieku'
        : '${widget.user.age} lat';

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
                    widget.user.username,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.user.email,
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
                    value: widget.user.id.toString(),
                  ),
                  const Divider(),
                  buildInfoRow(
                    icon: Icons.email,
                    label: 'Email',
                    value: widget.user.email,
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
          if (errorMessage.isNotEmpty)
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          if (errorMessage.isNotEmpty) const SizedBox(height: 16),
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.person_remove,
                        color: Colors.red,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Usuń znajomego',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Po usunięciu ta osoba zniknie z Twojej listy znajomych.',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 44,
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: isRemovingFriend ? null : confirmRemoveFriend,
                      icon: const Icon(Icons.person_remove),
                      label: isRemovingFriend
                          ? const Text('Usuwanie...')
                          : const Text('Usuń znajomego'),
                    ),
                  ),
                ],
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