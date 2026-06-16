import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/friends_api_service.dart';
import '../services/users_api_service.dart';

class FindFriendsScreen extends StatefulWidget {
  final String token;

  const FindFriendsScreen({
    super.key,
    required this.token,
  });

  @override
  State<FindFriendsScreen> createState() {
    return _FindFriendsScreenState();
  }
}

class _FindFriendsScreenState extends State<FindFriendsScreen> {
  final UsersApiService usersApiService = UsersApiService();
  final FriendsApiService friendsApiService = FriendsApiService();

  final TextEditingController searchController = TextEditingController();

  bool isSearching = false;
  int? sendingRequestUserId;

  String errorMessage = '';
  String successMessage = '';

  List<UserProfile> users = [];

  Future<void> searchUsers() async {
    final String username = searchController.text.trim();

    if (username.isEmpty) {
      setState(() {
        errorMessage = 'Wpisz nazwę użytkownika do wyszukania.';
        successMessage = '';
        users = [];
      });

      return;
    }

    setState(() {
      isSearching = true;
      errorMessage = '';
      successMessage = '';
      users = [];
    });

    try {
      final List<UserProfile> foundUsers = await usersApiService.searchUsers(
        token: widget.token,
        username: username,
      );

      setState(() {
        users = foundUsers;
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          isSearching = false;
        });
      }
    }
  }

  Future<void> sendFriendRequest(UserProfile user) async {
    setState(() {
      sendingRequestUserId = user.id;
      errorMessage = '';
      successMessage = '';
    });

    try {
      await friendsApiService.sendFriendRequest(
        token: widget.token,
        userId: user.id,
      );

      setState(() {
        successMessage = 'Wysłano zaproszenie do użytkownika ${user.username}.';
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          sendingRequestUserId = null;
        });
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Znajdź znajomych'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Wyszukaj użytkownika',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Wpisz fragment nazwy użytkownika i wyślij zaproszenie do znajomych.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: searchController,
            onSubmitted: (_) {
              searchUsers();
            },
            decoration: InputDecoration(
              labelText: 'Nazwa użytkownika',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: isSearching ? null : searchUsers,
                icon: const Icon(Icons.arrow_forward),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: isSearching ? null : searchUsers,
              icon: const Icon(Icons.search),
              label: isSearching
                  ? const Text('Szukam...')
                  : const Text('Szukaj użytkowników'),
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
          if (successMessage.isNotEmpty)
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  successMessage,
                  style: const TextStyle(color: Colors.green),
                ),
              ),
            ),
          const SizedBox(height: 8),
          const Text(
            'Wyniki wyszukiwania',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (!isSearching && users.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Brak wyników. Wpisz nazwę użytkownika i kliknij Szukaj.',
                ),
              ),
            )
          else
            ...users.map((user) {
              return buildUserCard(user);
            }),
        ],
      ),
    );
  }

  Widget buildUserCard(UserProfile user) {
    final bool isSending = sendingRequestUserId == user.id;

    final String cityText = user.city ?? 'Brak miasta';
    final String ageText = user.age == null ? 'Brak wieku' : '${user.age} lat';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                    user.username,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(user.email),
                  const SizedBox(height: 4),
                  Text('Miasto: $cityText'),
                  Text('Wiek: $ageText'),
                  Text('ID: ${user.id}'),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: isSending
                  ? null
                  : () {
                      sendFriendRequest(user);
                    },
              child: isSending
                  ? const Text('Wysyłanie...')
                  : const Text('Dodaj'),
            ),
          ],
        ),
      ),
    );
  }
}