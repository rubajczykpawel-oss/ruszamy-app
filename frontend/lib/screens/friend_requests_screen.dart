import 'package:flutter/material.dart';

import '../models/friendship.dart';
import '../models/user_profile.dart';
import '../services/friends_api_service.dart';

class FriendRequestsScreen extends StatefulWidget {
  final String token;

  const FriendRequestsScreen({
    super.key,
    required this.token,
  });

  @override
  State<FriendRequestsScreen> createState() {
    return _FriendRequestsScreenState();
  }
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  final FriendsApiService friendsApiService = FriendsApiService();

  bool isLoading = true;
  int? actionFriendshipId;

  String errorMessage = '';
  String successMessage = '';

  List<Friendship> receivedRequests = [];
  List<Friendship> sentRequests = [];
  List<UserProfile> friends = [];

  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      successMessage = '';
    });

    try {
      final List<Friendship> loadedReceivedRequests =
          await friendsApiService.getReceivedFriendRequests(
        token: widget.token,
      );

      final List<Friendship> loadedSentRequests =
          await friendsApiService.getSentFriendRequests(
        token: widget.token,
      );

      final List<UserProfile> loadedFriends =
          await friendsApiService.getMyFriends(
        token: widget.token,
      );

      setState(() {
        receivedRequests = loadedReceivedRequests;
        sentRequests = loadedSentRequests;
        friends = loadedFriends;
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> acceptRequest(Friendship friendship) async {
    setState(() {
      actionFriendshipId = friendship.id;
      errorMessage = '';
      successMessage = '';
    });

    try {
      await friendsApiService.acceptFriendRequest(
        token: widget.token,
        friendshipId: friendship.id,
      );

      setState(() {
        successMessage = 'Zaproszenie zostało zaakceptowane.';
      });

      await loadData();
    } catch (error) {
      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          actionFriendshipId = null;
        });
      }
    }
  }

  Future<void> rejectRequest(Friendship friendship) async {
    setState(() {
      actionFriendshipId = friendship.id;
      errorMessage = '';
      successMessage = '';
    });

    try {
      await friendsApiService.rejectFriendRequest(
        token: widget.token,
        friendshipId: friendship.id,
      );

      setState(() {
        successMessage = 'Zaproszenie zostało odrzucone.';
      });

      await loadData();
    } catch (error) {
      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          actionFriendshipId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Znajomi'),
          actions: [
            IconButton(
              onPressed: isLoading ? null : loadData,
              icon: const Icon(Icons.refresh),
              tooltip: 'Odśwież',
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(
                icon: const Icon(Icons.people),
                text: 'Moi znajomi (${friends.length})',
              ),
              Tab(
                icon: const Icon(Icons.inbox),
                text: 'Odebrane (${receivedRequests.length})',
              ),
              Tab(
                icon: const Icon(Icons.outbox),
                text: 'Wysłane (${sentRequests.length})',
              ),
            ],
          ),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  buildTopInfo(),
                  buildMessages(),
                  Expanded(
                    child: TabBarView(
                      children: [
                        buildFriendsTab(),
                        buildReceivedRequestsTab(),
                        buildSentRequestsTab(),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget buildTopInfo() {
    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.blue,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tutaj masz znajomych oraz zaproszenia podzielone na zakładki.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMessages() {
    if (errorMessage.isEmpty && successMessage.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
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
        ],
      ),
    );
  }

  Widget buildFriendsTab() {
    return RefreshIndicator(
      onRefresh: loadData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          buildSectionHeader(
            title: 'Moi znajomi',
            subtitle: 'Lista zaakceptowanych znajomych.',
            icon: Icons.people,
          ),
          const SizedBox(height: 12),
          if (friends.isEmpty)
            buildEmptyCard(
              text:
                  'Nie masz jeszcze znajomych. Wejdź w kafelek Znajdź znajomych i wyślij zaproszenie.',
            )
          else
            ...friends.map((friend) {
              return buildFriendCard(friend);
            }),
        ],
      ),
    );
  }

  Widget buildReceivedRequestsTab() {
    return RefreshIndicator(
      onRefresh: loadData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          buildSectionHeader(
            title: 'Odebrane zaproszenia',
            subtitle: 'Tutaj akceptujesz albo odrzucasz zaproszenia.',
            icon: Icons.inbox,
          ),
          const SizedBox(height: 12),
          if (receivedRequests.isEmpty)
            buildEmptyCard(
              text: 'Nie masz odebranych zaproszeń.',
            )
          else
            ...receivedRequests.map((friendship) {
              return buildReceivedRequestCard(friendship);
            }),
        ],
      ),
    );
  }

  Widget buildSentRequestsTab() {
    return RefreshIndicator(
      onRefresh: loadData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          buildSectionHeader(
            title: 'Wysłane zaproszenia',
            subtitle: 'Tutaj widzisz zaproszenia, które wysłałeś.',
            icon: Icons.outbox,
          ),
          const SizedBox(height: 12),
          if (sentRequests.isEmpty)
            buildEmptyCard(
              text: 'Nie masz wysłanych zaproszeń.',
            )
          else
            ...sentRequests.map((friendship) {
              return buildSentRequestCard(friendship);
            }),
        ],
      ),
    );
  }

  Widget buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        CircleAvatar(
          child: Icon(icon),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(subtitle),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildEmptyCard({
    required String text,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(text),
      ),
    );
  }

  Widget buildReceivedRequestCard(Friendship friendship) {
    final bool isActionLoading = actionFriendshipId == friendship.id;

    final String requesterText = friendship.requester == null
        ? 'Użytkownik ID: ${friendship.requesterId}'
        : friendship.requester!.username;

    final String requesterDetails = friendship.requester == null
        ? 'Brak szczegółowych danych użytkownika'
        : friendship.requester!.email;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                        requesterText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(requesterDetails),
                      const SizedBox(height: 4),
                      Text('Status: ${friendship.status}'),
                      Text('ID zaproszenia: ${friendship.id}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isActionLoading
                        ? null
                        : () {
                            acceptRequest(friendship);
                          },
                    icon: const Icon(Icons.check),
                    label: isActionLoading
                        ? const Text('Przetwarzanie...')
                        : const Text('Akceptuj'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isActionLoading
                        ? null
                        : () {
                            rejectRequest(friendship);
                          },
                    icon: const Icon(Icons.close),
                    label: const Text('Odrzuć'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSentRequestCard(Friendship friendship) {
    final String receiverText = friendship.receiver == null
        ? 'Użytkownik ID: ${friendship.receiverId}'
        : friendship.receiver!.username;

    final String receiverDetails = friendship.receiver == null
        ? 'Brak szczegółowych danych użytkownika'
        : friendship.receiver!.email;

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
                    receiverText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(receiverDetails),
                  const SizedBox(height: 4),
                  Text('Status: ${friendship.status}'),
                  Text('ID zaproszenia: ${friendship.id}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFriendCard(UserProfile friend) {
    final String cityText = friend.city ?? 'Brak miasta';
    final String ageText = friend.age == null ? 'Brak wieku' : '${friend.age} lat';

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
                    friend.username,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(friend.email),
                  const SizedBox(height: 4),
                  Text('Miasto: $cityText'),
                  Text('Wiek: $ageText'),
                  Text('ID: ${friend.id}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}