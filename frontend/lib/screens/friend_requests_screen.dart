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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Znajomi'),
        actions: [
          IconButton(
            onPressed: isLoading ? null : loadData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Odśwież',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Znajomi i zaproszenia',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tutaj widzisz odebrane zaproszenia, wysłane zaproszenia oraz listę znajomych.',
                    style: TextStyle(fontSize: 16),
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

                  const SizedBox(height: 16),

                  buildSectionTitle(
                    title: 'Odebrane zaproszenia',
                    icon: Icons.inbox,
                  ),

                  const SizedBox(height: 12),

                  if (receivedRequests.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Nie masz odebranych zaproszeń.'),
                      ),
                    )
                  else
                    ...receivedRequests.map((friendship) {
                      return buildReceivedRequestCard(friendship);
                    }),

                  const SizedBox(height: 24),

                  buildSectionTitle(
                    title: 'Wysłane zaproszenia',
                    icon: Icons.outbox,
                  ),

                  const SizedBox(height: 12),

                  if (sentRequests.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Nie masz wysłanych zaproszeń.'),
                      ),
                    )
                  else
                    ...sentRequests.map((friendship) {
                      return buildSentRequestCard(friendship);
                    }),

                  const SizedBox(height: 24),

                  buildSectionTitle(
                    title: 'Moi znajomi',
                    icon: Icons.people,
                  ),

                  const SizedBox(height: 12),

                  if (friends.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Nie masz jeszcze znajomych.'),
                      ),
                    )
                  else
                    ...friends.map((friend) {
                      return buildFriendCard(friend);
                    }),
                ],
              ),
            ),
    );
  }

  Widget buildSectionTitle({
    required String title,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
            Text(
              requesterText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(requesterDetails),
            const SizedBox(height: 8),
            Text('Status: ${friendship.status}'),
            Text('ID zaproszenia: ${friendship.id}'),
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