import 'package:flutter/material.dart';

import '../models/app_group.dart';
import '../models/group_member.dart';
import '../services/groups_api_service.dart';
import '../widgets/info_chip.dart';

class GroupDetailsScreen extends StatefulWidget {
  final int groupId;
  final String token;

  const GroupDetailsScreen({
    super.key,
    required this.groupId,
    required this.token,
  });

  @override
  State<GroupDetailsScreen> createState() {
    return _GroupDetailsScreenState();
  }
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final GroupsApiService groupsApiService = GroupsApiService();

  final TextEditingController memberUserIdController = TextEditingController();

  bool isLoading = true;
  bool isAddingMember = false;

  String errorMessage = '';
  String successMessage = '';

  AppGroup? group;
  List<GroupMember> members = [];

  @override
  void initState() {
    super.initState();

    loadGroupData();
  }

  Future<void> loadGroupData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      successMessage = '';
    });

    try {
      final AppGroup loadedGroup = await groupsApiService.getGroupDetails(
        groupId: widget.groupId,
        token: widget.token,
      );

      final List<GroupMember> loadedMembers =
          await groupsApiService.getGroupMembers(
        groupId: widget.groupId,
        token: widget.token,
      );

      setState(() {
        group = loadedGroup;
        members = loadedMembers;
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

  Future<void> addMemberToGroup() async {
    final int? userId = int.tryParse(memberUserIdController.text.trim());

    if (userId == null) {
      setState(() {
        errorMessage = 'ID użytkownika musi być liczbą.';
        successMessage = '';
      });

      return;
    }

    setState(() {
      isAddingMember = true;
      errorMessage = '';
      successMessage = '';
    });

    try {
      await groupsApiService.addMemberToGroup(
        token: widget.token,
        groupId: widget.groupId,
        userId: userId,
      );

      memberUserIdController.clear();

      setState(() {
        successMessage = 'Użytkownik został dodany do grupy.';
      });

      await loadGroupData();
    } catch (error) {
      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          isAddingMember = false;
        });
      }
    }
  }

  @override
  void dispose() {
    memberUserIdController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppGroup? currentGroup = group;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Szczegóły grupy'),
        actions: [
          IconButton(
            onPressed: isLoading ? null : loadGroupData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Odśwież',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : currentGroup == null
              ? buildErrorView()
              : buildGroupDetails(currentGroup),
    );
  }

  Widget buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          errorMessage.isEmpty
              ? 'Nie udało się pobrać szczegółów grupy.'
              : errorMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget buildGroupDetails(AppGroup group) {
    return RefreshIndicator(
      onRefresh: loadGroupData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            group.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            group.description,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoChip(
                icon: Icons.location_city,
                label: group.city,
              ),
              InfoChip(
                icon: Icons.directions_walk,
                label: group.activityType,
              ),
              InfoChip(
                icon: Icons.person,
                label: 'Owner ID: ${group.ownerId}',
              ),
              InfoChip(
                icon: Icons.calendar_month,
                label: group.createdAt,
              ),
            ],
          ),
          const SizedBox(height: 24),
          buildAddMemberCard(),
          const SizedBox(height: 24),
          const Text(
            'Członkowie grupy',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
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
          if (members.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Ta grupa nie ma jeszcze członków.'),
              ),
            )
          else
            ...members.map((member) {
              return buildMemberCard(member);
            }),
        ],
      ),
    );
  }

  Widget buildAddMemberCard() {
    return Card(
      color: Colors.teal.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dodaj członka do grupy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Wpisz ID użytkownika, którego chcesz dodać. Backend sprawdzi, czy możesz dodać tę osobę.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: memberUserIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'ID użytkownika',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_add),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isAddingMember ? null : addMemberToGroup,
                icon: const Icon(Icons.group_add),
                label: isAddingMember
                    ? const Text('Dodawanie...')
                    : const Text('Dodaj członka'),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Podpowiedź: ID użytkownika zobaczysz np. na ekranie Znajdź znajomych albo Znajomi.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMemberCard(GroupMember member) {
    final String cityText = member.user.city ?? 'Brak miasta';
    final String ageText = member.user.age == null
        ? 'Brak wieku'
        : '${member.user.age} lat';

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
                    member.user.username,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(member.user.email),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      InfoChip(
                        icon: Icons.badge,
                        label: member.role,
                      ),
                      InfoChip(
                        icon: Icons.location_city,
                        label: cityText,
                      ),
                      InfoChip(
                        icon: Icons.cake,
                        label: ageText,
                      ),
                      InfoChip(
                        icon: Icons.person,
                        label: 'ID: ${member.userId}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}