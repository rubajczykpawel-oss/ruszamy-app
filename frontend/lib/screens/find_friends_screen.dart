import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/friends_api_service.dart';
import '../services/users_api_service.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/info_chip.dart';
import '../widgets/message_card.dart';
import '../widgets/section_header.dart';

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

  String getResultsTitle() {
    if (!hasSearched) {
      return 'Wyniki wyszukiwania';
    }

    if (hasSearched && users.isEmpty && !isSearching) {
      return 'Brak wyników';
    }

    return 'Znalezieni użytkownicy (${users.length})';
  }

  String getResultsSubtitle() {
    if (!hasSearched) {
      return 'Wpisz nazwę użytkownika i kliknij Szukaj.';
    }

    if (hasSearched && users.isEmpty && !isSearching) {
      return 'Nie znaleziono użytkowników dla podanej nazwy.';
    }

    return 'Możesz wysłać zaproszenie do wybranej osoby.';
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
          if (errorMessage.isNotEmpty)
            MessageCard(
              message: errorMessage,
              isError: true,
            ),
          if (successMessage.isNotEmpty)
            MessageCard(
              message: successMessage,
              isError: false,
            ),
          if (errorMessage.isNotEmpty || successMessage.isNotEmpty)
            const SizedBox(height: 16),
          SectionHeader(
            icon: Icons.people,
            title: getResultsTitle(),
            subtitle: getResultsSubtitle(),
          ),
          const SizedBox(height: 12),
          buildResultsContent(),
          const SizedBox(height: 80),
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
        label: isSearching ? const Text('Szukam...') : const Text('Szukaj'),
      ),
    );
  }

  Widget buildResultsContent() {
    if (isSearching) {
      return buildLoadingCard();
    }

    if (!hasSearched) {
      return const EmptyStateCard(
        icon: Icons.search,
        title: 'Zacznij od wyszukania użytkownika',
        description:
            'Wpisz nazwę użytkownika w polu powyżej. Możesz wpisać całą nazwę albo fragment.',
      );
    }

    if (users.isEmpty) {
      return const EmptyStateCard(
        icon: Icons.person_off,
        title: 'Nikogo nie znaleziono',
        description: 'Spróbuj wpisać krótszą nazwę albo sprawdź pisownię.',
      );
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