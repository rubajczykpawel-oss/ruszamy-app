import 'package:flutter/material.dart';

import '../models/app_group.dart';
import '../services/groups_api_service.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/group_card.dart';
import '../widgets/message_card.dart';
import '../widgets/section_header.dart';
import 'create_group_screen.dart';
import 'group_details_screen.dart';

class MyGroupsScreen extends StatefulWidget {
  final String token;

  const MyGroupsScreen({
    super.key,
    required this.token,
  });

  @override
  State<MyGroupsScreen> createState() {
    return _MyGroupsScreenState();
  }
}

class _MyGroupsScreenState extends State<MyGroupsScreen> {
  final GroupsApiService groupsApiService = GroupsApiService();

  bool isLoading = true;
  String errorMessage = '';

  List<AppGroup> myGroups = [];

  @override
  void initState() {
    super.initState();

    loadMyGroups();
  }

  Future<void> loadMyGroups() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final List<AppGroup> loadedGroups = await groupsApiService.getMyGroups(
        token: widget.token,
      );

      setState(() {
        myGroups = loadedGroups;
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

  Future<void> openCreateGroup() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return CreateGroupScreen(
            token: widget.token,
          );
        },
      ),
    );

    loadMyGroups();
  }

  Future<void> openGroupDetails(AppGroup group) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return GroupDetailsScreen(
            groupId: group.id,
            token: widget.token,
          );
        },
      ),
    );

    loadMyGroups();
  }

  int countGroups() {
    return myGroups.length;
  }

  int countDifferentCities() {
    final Set<String> cities = <String>{};

    for (final AppGroup group in myGroups) {
      final String city = group.city.trim();

      if (city.isNotEmpty) {
        cities.add(city.toLowerCase());
      }
    }

    return cities.length;
  }

  int countDifferentActivityTypes() {
    final Set<String> activityTypes = <String>{};

    for (final AppGroup group in myGroups) {
      final String activityType = group.activityType.trim();

      if (activityType.isNotEmpty) {
        activityTypes.add(activityType.toLowerCase());
      }
    }

    return activityTypes.length;
  }

  String getNewestGroupDate() {
    if (myGroups.isEmpty) {
      return '-';
    }

    final List<AppGroup> sortedGroups = [...myGroups];

    sortedGroups.sort((firstGroup, secondGroup) {
      return secondGroup.createdAt.compareTo(firstGroup.createdAt);
    });

    final String createdAt = sortedGroups.first.createdAt;

    if (createdAt.length >= 10) {
      return createdAt.substring(0, 10);
    }

    return createdAt;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje grupy'),
        actions: [
          IconButton(
            onPressed: isLoading ? null : loadMyGroups,
            icon: const Icon(Icons.refresh),
            tooltip: 'Odśwież',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openCreateGroup,
        icon: const Icon(Icons.add),
        label: const Text('Dodaj grupę'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadMyGroups,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  buildHeaderCard(),
                  const SizedBox(height: 16),
                  buildStatsGrid(),
                  const SizedBox(height: 16),
                  if (errorMessage.isNotEmpty)
                    MessageCard(
                      message: errorMessage,
                      isError: true,
                    ),
                  if (errorMessage.isNotEmpty) const SizedBox(height: 16),
                  if (myGroups.isEmpty)
                    EmptyStateCard(
                      icon: Icons.group_off,
                      title: 'Nie należysz jeszcze do żadnej grupy',
                      description:
                          'Utwórz własną grupę albo poproś znajomego o dodanie Cię do istniejącej grupy.',
                      buttonText: 'Dodaj pierwszą grupę',
                      onPressed: openCreateGroup,
                    )
                  else
                    buildGroupsSection(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget buildHeaderCard() {
    return Card(
      color: Colors.orange.shade50,
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
      backgroundColor: Colors.orange.shade100,
      child: const Icon(
        Icons.groups,
        size: 44,
      ),
    );
  }

  Widget buildHeaderText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Moje grupy',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tutaj widzisz grupy, do których należysz albo które utworzyłeś.',
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
        onPressed: openCreateGroup,
        icon: const Icon(Icons.add),
        label: const Text('Dodaj'),
      ),
    );
  }

  Widget buildStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth;

        if (constraints.maxWidth >= 900) {
          cardWidth = (constraints.maxWidth - 36) / 4;
        } else if (constraints.maxWidth >= 650) {
          cardWidth = (constraints.maxWidth - 12) / 2;
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
                icon: Icons.groups,
                value: countGroups().toString(),
                title: 'Wszystkie',
                subtitle: 'Twoje grupy',
                color: Colors.blue.shade50,
                iconColor: Colors.blue,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: buildStatCard(
                icon: Icons.location_city,
                value: countDifferentCities().toString(),
                title: 'Miasta',
                subtitle: 'Różne lokalizacje',
                color: Colors.green.shade50,
                iconColor: Colors.green,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: buildStatCard(
                icon: Icons.directions_walk,
                value: countDifferentActivityTypes().toString(),
                title: 'Aktywności',
                subtitle: 'Typy grup',
                color: Colors.orange.shade50,
                iconColor: Colors.orange,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: buildStatCard(
                icon: Icons.calendar_month,
                value: getNewestGroupDate(),
                title: 'Najnowsza',
                subtitle: 'Ostatnio utworzona',
                color: Colors.purple.shade50,
                iconColor: Colors.purple,
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

  Widget buildGroupsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          icon: Icons.list_alt,
          title: 'Lista grup (${myGroups.length})',
          subtitle: 'Kliknij grupę, żeby zobaczyć szczegóły, członków i akcje.',
        ),
        const SizedBox(height: 12),
        ...myGroups.map((group) {
          return GroupCard(
            group: group,
            onTap: () {
              openGroupDetails(group);
            },
          );
        }),
      ],
    );
  }
}