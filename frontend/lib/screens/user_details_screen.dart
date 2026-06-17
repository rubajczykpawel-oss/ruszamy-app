import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/friends_api_service.dart';
import '../widgets/info_chip.dart';

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
  String successMessage = '';

  String buildCityText() {
    return widget.user.city ?? 'Nie ustawiono miasta';
  }

  String buildAgeText() {
    if (widget.user.age == null) {
      return 'Nie ustawiono wieku';
    }

    return '${widget.user.age} lat';
  }

  String buildInitial() {
    final String username = widget.user.username.trim();

    if (username.isEmpty) {
      return '?';
    }

    return username[0].toUpperCase();
  }

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
      successMessage = '';
    });

    try {
      await friendsApiService.removeFriend(
        token: widget.token,
        friendId: widget.user.id,
      );

      setState(() {
        successMessage = 'Usunięto użytkownika ze znajomych.';
      });

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
    return Scaffold(
      appBar: buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            buildHeaderCard(),
            const SizedBox(height: 16),
            buildMessages(),
            buildStatsGrid(),
            const SizedBox(height: 16),
            buildProfileInfoCard(),
            const SizedBox(height: 16),
            buildActionsCard(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      title: const Text('Profil użytkownika'),
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
                  buildAvatar(),
                  const SizedBox(height: 16),
                  buildHeaderText(),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildAvatar(),
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

  Widget buildAvatar() {
    return CircleAvatar(
      radius: 46,
      backgroundColor: Colors.indigo.shade100,
      child: Text(
        buildInitial(),
        style: const TextStyle(
          fontSize: 38,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildHeaderText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.user.username,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.user.email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            InfoChip(
              icon: Icons.badge,
              label: 'ID: ${widget.user.id}',
            ),
            InfoChip(
              icon: Icons.location_city,
              label: buildCityText(),
            ),
            InfoChip(
              icon: Icons.cake,
              label: buildAgeText(),
            ),
          ],
        ),
      ],
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
                icon: Icons.person,
                value: widget.user.username,
                title: 'Użytkownik',
                subtitle: 'Nazwa profilu',
                color: Colors.blue.shade50,
                iconColor: Colors.blue,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: buildStatCard(
                icon: Icons.location_city,
                value: widget.user.city ?? '-',
                title: 'Miasto',
                subtitle: 'Lokalizacja użytkownika',
                color: Colors.green.shade50,
                iconColor: Colors.green,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: buildStatCard(
                icon: Icons.cake,
                value: widget.user.age?.toString() ?? '-',
                title: 'Wiek',
                subtitle: 'Informacja opcjonalna',
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
                      fontSize: 22,
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

  Widget buildProfileInfoCard() {
    return Card(
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildSectionHeader(
              icon: Icons.info,
              title: 'Dane użytkownika',
              subtitle: 'Podstawowe informacje o tym profilu.',
            ),
            const SizedBox(height: 12),
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
              icon: Icons.person,
              label: 'Nazwa',
              value: widget.user.username,
            ),
            const Divider(),
            buildInfoRow(
              icon: Icons.location_city,
              label: 'Miasto',
              value: buildCityText(),
            ),
            const Divider(),
            buildInfoRow(
              icon: Icons.cake,
              label: 'Wiek',
              value: buildAgeText(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildActionsCard() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isNarrow = constraints.maxWidth < 560;

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildActionsText(),
                  const SizedBox(height: 16),
                  buildRemoveFriendButton(),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: buildActionsText(),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 230,
                  child: buildRemoveFriendButton(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildActionsText() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.person_remove,
          size: 34,
          color: Colors.red,
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Zarządzanie znajomym',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Możesz usunąć tę osobę ze swoich znajomych.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildRemoveFriendButton() {
    return SizedBox(
      height: 44,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isRemovingFriend ? null : confirmRemoveFriend,
        icon: const Icon(Icons.person_remove),
        label: isRemovingFriend
            ? const Text('Usuwanie...')
            : const Text('Usuń znajomego'),
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
            width: 130,
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}