import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/friends_api_service.dart';
import '../services/users_api_service.dart';
import '../widgets/info_chip.dart';

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

  final TextEditingController usernameController = TextEditingController();

  bool isSearching = false;
  bool hasSearched = false;

  int? sendingRequestUserId;

  String errorMessage = '';
  String successMessage = '';

  List<UserProfile> users = [];

  @override
  void dispose() {
    usernameController.dispose();

    super.dispose();
  }

  Future<void> searchUsers() async {
    final String username = usernameController.text.trim();

    if (username.isEmpty) {
      setState(() {
        errorMessage = 'Wpisz nazwę użytkownika do wyszukania.';
        successMessage = '';
        users = [];
        hasSearched = false;
      });

      return;
    }

    setState(() {
      isSearching = true;
      hasSearched = true;
      errorMessage = '';
      successMessage = '';
      users = [];
    });

    try {
      final List<UserProfile> loadedUsers = await usersApiService.searchUsers(
        token: widget.token,
        username: username,
      );

      setState(() {
        users = loadedUsers;
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

  void clearSearch() {
    setState(() {
      usernameController.clear();
      users = [];
      hasSearched = false;
      errorMessage = '';
      successMessage = '';
    });
  }

  String buildCityText(UserProfile user) {
    return user.city ?? 'Brak miasta';
  }

  String buildAgeText(UserProfile user) {
    if (user.age == null) {
      return 'Brak wieku';
    }

    return '${user.age} lat';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Znajdź znajomych'),
        actions: [
          IconButton(
            onPressed: clearSearch,
            icon: const Icon(Icons.clear),
            tooltip: 'Wyczyść',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildHeaderCard(),
          const SizedBox(height: 16),
          buildSearchCard(),
          const SizedBox(height: 16),
          buildMessages(),
          buildResultsHeader(),
          const SizedBox(height: 12),
          buildResultsContent(),
        ],
      ),
    );
  }

  Widget buildHeaderCard() {
    return Card(
      color: Colors.indigo.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isNarrow = constraints.maxWidth < 560;

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildHeaderIcon(),
                  const SizedBox(height: 16),
                  buildHeaderText(),
                ],
              );
            }

            return Row(
              children: [
                buildHeaderIcon(),
                const SizedBox(width: 18),
                Expanded(
                  child: buildHeaderText(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildHeaderIcon() {
    return CircleAvatar(
      radius: 42,
      backgroundColor: Colors.indigo.shade100,
      child: const Icon(
        Icons.person_search,
        size: 44,
      ),
    );
  }

  Widget buildHeaderText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Znajdź znajomych',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Wyszukaj użytkownika po nazwie i wyślij zaproszenie do znajomych.',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget buildSearchCard() {
    return Card(
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isNarrow = constraints.maxWidth < 560;

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSearchField(),
                  const SizedBox(height: 12),
                  buildSearchButton(),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: buildSearchField(),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 170,
                  child: buildSearchButton(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildSearchField() {
    return TextField(
      controller: usernameController,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        labelText: 'Nazwa użytkownika',
        hintText: 'np. pawel',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.search),
      ),
      onSubmitted: (_) {
        searchUsers();
      },
    );
  }

  Widget buildSearchButton() {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: isSearching ? null : searchUsers,
        icon: isSearching
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.search),
        label: isSearching
            ? const Text('Szukam...')
            : const Text('Szukaj'),
      ),
    );
  }

  Widget buildMessages() {
    if (errorMessage.isEmpty && successMessage.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (errorMessage.isNotEmpty)
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.error,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (successMessage.isNotEmpty)
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      successMessage,
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildResultsHeader() {
    String title = 'Wyniki wyszukiwania';
    String subtitle = 'Wpisz nazwę użytkownika i kliknij Szukaj.';

    if (hasSearched && users.isEmpty && !isSearching) {
      title = 'Brak wyników';
      subtitle = 'Nie znaleziono użytkowników dla podanej nazwy.';
    }

    if (hasSearched && users.isNotEmpty) {
      title = 'Znalezieni użytkownicy (${users.length})';
      subtitle = 'Możesz wysłać zaproszenie do wybranej osoby.';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.people,
          size: 32,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(subtitle),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildResultsContent() {
    if (isSearching) {
      return buildLoadingCard();
    }

    if (!hasSearched) {
      return buildStartState();
    }

    if (users.isEmpty) {
      return buildEmptyState();
    }

    return Column(
      children: users.map((user) {
        return buildUserCard(user);
      }).toList(),
    );
  }

  Widget buildLoadingCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget buildStartState() {
    return Card(
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.search,
              size: 70,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 16),
            const Text(
              'Zacznij od wyszukania użytkownika',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Wpisz nazwę użytkownika w polu powyżej. Możesz wpisać całą nazwę albo fragment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.person_off,
              size: 70,
              color: Colors.grey.shade700,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nikogo nie znaleziono',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Spróbuj wpisać krótszą nazwę albo sprawdź pisownię.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildUserCard(UserProfile user) {
    final bool isSendingThisRequest = sendingRequestUserId == user.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isNarrow = constraints.maxWidth < 560;

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildUserInfo(user),
                  const SizedBox(height: 12),
                  buildSendRequestButton(
                    user: user,
                    isSendingThisRequest: isSendingThisRequest,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: buildUserInfo(user),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 210,
                  child: buildSendRequestButton(
                    user: user,
                    isSendingThisRequest: isSendingThisRequest,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildUserInfo(UserProfile user) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 28,
          child: Icon(Icons.person),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  InfoChip(
                    icon: Icons.location_city,
                    label: buildCityText(user),
                  ),
                  InfoChip(
                    icon: Icons.cake,
                    label: buildAgeText(user),
                  ),
                  InfoChip(
                    icon: Icons.badge,
                    label: 'ID: ${user.id}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildSendRequestButton({
    required UserProfile user,
    required bool isSendingThisRequest,
  }) {
    return SizedBox(
      height: 44,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: sendingRequestUserId == null
            ? () {
                sendFriendRequest(user);
              }
            : null,
        icon: isSendingThisRequest
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.person_add),
        label: isSendingThisRequest
            ? const Text('Wysyłanie...')
            : const Text('Wyślij zaproszenie'),
      ),
    );
  }
}