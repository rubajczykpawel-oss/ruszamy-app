import 'package:flutter/material.dart';

import '../models/friendship.dart';
import '../models/user_profile.dart';
import '../services/friends_api_service.dart';
import '../widgets/info_chip.dart';
import 'find_friends_screen.dart';
import 'user_details_screen.dart';

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
  int? removingFriendId;

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

  Future<void> loadData({
    bool clearMessages = true,
  }) async {
    setState(() {
      isLoading = true;
      errorMessage = '';

      if (clearMessages) {
        successMessage = '';
      }
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

      await loadData(clearMessages: false);
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

      await loadData(clearMessages: false);
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

  Future<void> openFindFriends() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return FindFriendsScreen(
            token: widget.token,
          );
        },
      ),
    );

    loadData();
  }

  Future<void> openUserDetails(UserProfile user) async {
    final bool? shouldRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return UserDetailsScreen(
            user: user,
            token: widget.token,
          );
        },
      ),
    );

    if (shouldRefresh == true) {
      loadData();
    }
  }

  Future<void> confirmRemoveFriend(UserProfile friend) async {
    final bool? shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Usunąć znajomego?'),
          content: Text(
            'Czy na pewno chcesz usunąć użytkownika "${friend.username}" ze znajomych?',
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
      removeFriend(friend);
    }
  }

  Future<void> removeFriend(UserProfile friend) async {
    setState(() {
      removingFriendId = friend.id;
      errorMessage = '';
      successMessage = '';
    });

    try {
      await friendsApiService.removeFriend(
        token: widget.token,
        friendId: friend.id,
      );

      setState(() {
        successMessage = 'Usunięto użytkownika ${friend.username} ze znajomych.';
      });

      await loadData(clearMessages: false);
    } catch (error) {
      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          removingFriendId = null;
        });
      }
    }
  }

  int countAllSocialItems() {
    return friends.length + receivedRequests.length + sentRequests.length;
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
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.people),
                text: 'Znajomi',
              ),
              Tab(
                icon: Icon(Icons.inbox),
                text: 'Odebrane',
              ),
              Tab(
                icon: Icon(Icons.outbox),
                text: 'Wysłane',
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: openFindFriends,
          icon: const Icon(Icons.person_search),
          label: const Text('Szukaj'),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : TabBarView(
                children: [
                  buildFriendsTab(),
                  buildReceivedRequestsTab(),
                  buildSentRequestsTab(),
                ],
              ),
      ),
    );
  }

  Widget buildFriendsTab() {
    return RefreshIndicator(
      onRefresh: loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildHeaderCard(),
          const SizedBox(height: 16),
          buildMessages(),
          buildStatsGrid(),
          const SizedBox(height: 16),
          buildSectionHeader(
            icon: Icons.people,
            title: 'Moi znajomi',
            subtitle: 'Lista osób, które masz już zaakceptowane jako znajomych.',
          ),
          const SizedBox(height: 12),
          if (friends.isEmpty)
            buildEmptyState(
              icon: Icons.people_outline,
              title: 'Nie masz jeszcze znajomych',
              description:
                  'Wyszukaj użytkownika i wyślij zaproszenie do znajomych.',
              buttonText: 'Znajdź znajomych',
              onPressed: openFindFriends,
            )
          else
            ...friends.map((friend) {
              return buildFriendCard(friend);
            }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget buildReceivedRequestsTab() {
    return RefreshIndicator(
      onRefresh: loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildHeaderCard(),
          const SizedBox(height: 16),
          buildMessages(),
          buildStatsGrid(),
          const SizedBox(height: 16),
          buildSectionHeader(
            icon: Icons.inbox,
            title: 'Odebrane zaproszenia',
            subtitle: 'Tutaj akceptujesz albo odrzucasz zaproszenia od innych osób.',
          ),
          const SizedBox(height: 12),
          if (receivedRequests.isEmpty)
            buildEmptyState(
              icon: Icons.inbox,
              title: 'Brak odebranych zaproszeń',
              description:
                  'Kiedy ktoś wyśle Ci zaproszenie, pojawi się właśnie tutaj.',
              buttonText: 'Odśwież',
              onPressed: loadData,
            )
          else
            ...receivedRequests.map((friendship) {
              return buildReceivedRequestCard(friendship);
            }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget buildSentRequestsTab() {
    return RefreshIndicator(
      onRefresh: loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildHeaderCard(),
          const SizedBox(height: 16),
          buildMessages(),
          buildStatsGrid(),
          const SizedBox(height: 16),
          buildSectionHeader(
            icon: Icons.outbox,
            title: 'Wysłane zaproszenia',
            subtitle: 'Tutaj widzisz zaproszenia, które wysłałeś do innych użytkowników.',
          ),
          const SizedBox(height: 12),
          if (sentRequests.isEmpty)
            buildEmptyState(
              icon: Icons.outbox,
              title: 'Brak wysłanych zaproszeń',
              description:
                  'Wyszukaj użytkownika i wyślij pierwsze zaproszenie.',
              buttonText: 'Znajdź znajomych',
              onPressed: openFindFriends,
            )
          else
            ...sentRequests.map((friendship) {
              return buildSentRequestCard(friendship);
            }),
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
                  const SizedBox(height: 16),
                  buildHeaderButton(),
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
                const SizedBox(width: 16),
                SizedBox(
                  width: 170,
                  child: buildHeaderButton(),
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
        Icons.people,
        size: 44,
      ),
    );
  }

  Widget buildHeaderText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Znajomi i zaproszenia',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Zarządzaj znajomymi, akceptuj zaproszenia i buduj swoją społeczność.',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget buildHeaderButton() {
    return SizedBox(
      height: 44,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: openFindFriends,
        icon: const Icon(Icons.person_search),
        label: const Text('Szukaj'),
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

  Widget buildStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth;

        if (constraints.maxWidth >= 760) {
          cardWidth = (constraints.maxWidth - 24) / 3;
        } else {
          cardWidth = constraints.maxWidth;
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: cardWidth,
              child: buildStatCard(
                icon: Icons.people,
                value: friends.length.toString(),
                title: 'Znajomi',
                subtitle: 'Zaakceptowane osoby',
                color: Colors.blue.shade50,
                iconColor: Colors.blue,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: buildStatCard(
                icon: Icons.inbox,
                value: receivedRequests.length.toString(),
                title: 'Odebrane',
                subtitle: 'Czekają na decyzję',
                color: Colors.green.shade50,
                iconColor: Colors.green,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: buildStatCard(
                icon: Icons.outbox,
                value: sentRequests.length.toString(),
                title: 'Wysłane',
                subtitle: 'Czekają na odpowiedź',
                color: Colors.orange.shade50,
                iconColor: Colors.orange,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildStatCard({
    required IconData icon,
    required String value,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
  }) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                icon,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
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

  Widget buildFriendCard(UserProfile friend) {
    final bool isRemovingThisFriend = removingFriendId == friend.id;

    final String cityText = friend.city ?? 'Brak miasta';
    final String ageText =
        friend.age == null ? 'Brak wieku' : '${friend.age} lat';

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
                  buildUserInfo(
                    username: friend.username,
                    email: friend.email,
                    cityText: cityText,
                    ageText: ageText,
                    idText: 'ID: ${friend.id}',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 12),
                  buildFriendButtons(
                    friend: friend,
                    isRemovingThisFriend: isRemovingThisFriend,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: buildUserInfo(
                    username: friend.username,
                    email: friend.email,
                    cityText: cityText,
                    ageText: ageText,
                    idText: 'ID: ${friend.id}',
                    icon: Icons.person,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 220,
                  child: buildFriendButtons(
                    friend: friend,
                    isRemovingThisFriend: isRemovingThisFriend,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildFriendButtons({
    required UserProfile friend,
    required bool isRemovingThisFriend,
  }) {
    return Column(
      children: [
        SizedBox(
          height: 44,
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              openUserDetails(friend);
            },
            icon: const Icon(Icons.visibility),
            label: const Text('Profil'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: removingFriendId == null
                ? () {
                    confirmRemoveFriend(friend);
                  }
                : null,
            icon: const Icon(Icons.person_remove),
            label: isRemovingThisFriend
                ? const Text('Usuwanie...')
                : const Text('Usuń'),
          ),
        ),
      ],
    );
  }

  Widget buildReceivedRequestCard(Friendship friendship) {
    final bool isActionLoading = actionFriendshipId == friendship.id;

    final UserProfile? requester = friendship.requester;

    final String requesterText = requester == null
        ? 'Użytkownik ID: ${friendship.requesterId}'
        : requester.username;

    final String requesterDetails = requester == null
        ? 'Brak szczegółowych danych użytkownika'
        : requester.email;

    final String cityText = requester?.city ?? 'Brak miasta';
    final String ageText = requester?.age == null
        ? 'Brak wieku'
        : '${requester!.age} lat';

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
                  buildUserInfo(
                    username: requesterText,
                    email: requesterDetails,
                    cityText: cityText,
                    ageText: ageText,
                    idText: 'Zaproszenie ID: ${friendship.id}',
                    icon: Icons.person_add,
                  ),
                  const SizedBox(height: 12),
                  buildRequestActionButtons(
                    friendship: friendship,
                    isActionLoading: isActionLoading,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: buildUserInfo(
                    username: requesterText,
                    email: requesterDetails,
                    cityText: cityText,
                    ageText: ageText,
                    idText: 'Zaproszenie ID: ${friendship.id}',
                    icon: Icons.person_add,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 260,
                  child: buildRequestActionButtons(
                    friendship: friendship,
                    isActionLoading: isActionLoading,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildRequestActionButtons({
    required Friendship friendship,
    required bool isActionLoading,
  }) {
    return Column(
      children: [
        SizedBox(
          height: 44,
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: actionFriendshipId == null
                ? () {
                    acceptRequest(friendship);
                  }
                : null,
            icon: const Icon(Icons.check),
            label: isActionLoading
                ? const Text('Przetwarzanie...')
                : const Text('Akceptuj'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: actionFriendshipId == null
                ? () {
                    rejectRequest(friendship);
                  }
                : null,
            icon: const Icon(Icons.close),
            label: const Text('Odrzuć'),
          ),
        ),
      ],
    );
  }

  Widget buildSentRequestCard(Friendship friendship) {
    final UserProfile? receiver = friendship.receiver;

    final String receiverText = receiver == null
        ? 'Użytkownik ID: ${friendship.receiverId}'
        : receiver.username;

    final String receiverDetails = receiver == null
        ? 'Brak szczegółowych danych użytkownika'
        : receiver.email;

    final String cityText = receiver?.city ?? 'Brak miasta';
    final String ageText =
        receiver?.age == null ? 'Brak wieku' : '${receiver!.age} lat';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: buildUserInfo(
          username: receiverText,
          email: receiverDetails,
          cityText: cityText,
          ageText: ageText,
          idText: 'Zaproszenie ID: ${friendship.id}',
          icon: Icons.outbox,
          statusText: friendship.status,
        ),
      ),
    );
  }

  Widget buildUserInfo({
    required String username,
    required String email,
    required String cityText,
    required String ageText,
    required String idText,
    required IconData icon,
    String? statusText,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 28,
          child: Icon(icon),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                email,
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
                    label: cityText,
                  ),
                  InfoChip(
                    icon: Icons.cake,
                    label: ageText,
                  ),
                  InfoChip(
                    icon: Icons.badge,
                    label: idText,
                  ),
                  if (statusText != null)
                    InfoChip(
                      icon: Icons.info,
                      label: 'Status: $statusText',
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Card(
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              icon,
              size: 70,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 44,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.arrow_forward),
                label: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}