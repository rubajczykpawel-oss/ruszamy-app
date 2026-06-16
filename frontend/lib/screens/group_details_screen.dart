import 'package:flutter/material.dart';

import '../models/app_group.dart';
import '../models/group_member.dart';
import '../models/user_profile.dart';
import '../services/auth_api_service.dart';
import '../services/friends_api_service.dart';
import '../services/groups_api_service.dart';
import '../widgets/info_chip.dart';
import 'edit_group_screen.dart';

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
  final AuthApiService authApiService = AuthApiService();
  final GroupsApiService groupsApiService = GroupsApiService();
  final FriendsApiService friendsApiService = FriendsApiService();

  bool isLoading = true;
  bool isAddingMember = false;
  bool isDeletingGroup = false;
  bool isRemovingMember = false;
  bool isLeavingGroup = false;

  int? addingUserId;
  int? removingUserId;

  String errorMessage = '';
  String successMessage = '';

  UserProfile? currentUser;
  AppGroup? group;
  List<GroupMember> members = [];
  List<UserProfile> friends = [];

  @override
  void initState() {
    super.initState();
    loadGroupData();
  }

  Future<void> loadGroupData({
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
      final UserProfile loadedCurrentUser =
          await authApiService.getCurrentUser(
        token: widget.token,
      );

      final AppGroup loadedGroup = await groupsApiService.getGroupDetails(
        groupId: widget.groupId,
        token: widget.token,
      );

      final List<GroupMember> loadedMembers =
          await groupsApiService.getGroupMembers(
        groupId: widget.groupId,
        token: widget.token,
      );

      final List<UserProfile> loadedFriends =
          await friendsApiService.getMyFriends(
        token: widget.token,
      );

      setState(() {
        currentUser = loadedCurrentUser;
        group = loadedGroup;
        members = loadedMembers;
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

  Future<void> openEditGroup(AppGroup groupToEdit) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return EditGroupScreen(
            token: widget.token,
            group: groupToEdit,
          );
        },
      ),
    );

    loadGroupData();
  }

  Future<void> confirmDeleteGroup(AppGroup groupToDelete) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Usunąć grupę?'),
          content: Text(
            'Czy na pewno chcesz usunąć grupę "${groupToDelete.name}"? '
            'Tej operacji nie da się cofnąć.',
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

    if (shouldDelete == true) {
      deleteGroup(groupToDelete);
    }
  }

  Future<void> deleteGroup(AppGroup groupToDelete) async {
    setState(() {
      isDeletingGroup = true;
      errorMessage = '';
      successMessage = '';
    });

    try {
      await groupsApiService.deleteGroup(
        token: widget.token,
        groupId: groupToDelete.id,
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
          isDeletingGroup = false;
        });
      }
    }
  }

  Future<void> confirmLeaveGroup(AppGroup groupToLeave) async {
    final bool? shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Opuścić grupę?'),
          content: Text(
            'Czy na pewno chcesz opuścić grupę "${groupToLeave.name}"?',
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
              child: const Text('Opuść'),
            ),
          ],
        );
      },
    );

    if (shouldLeave == true) {
      leaveGroup(groupToLeave);
    }
  }

  Future<void> leaveGroup(AppGroup groupToLeave) async {
    setState(() {
      isLeavingGroup = true;
      errorMessage = '';
      successMessage = '';
    });

    try {
      await groupsApiService.leaveGroup(
        token: widget.token,
        groupId: groupToLeave.id,
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
          isLeavingGroup = false;
        });
      }
    }
  }

  Future<void> addMemberToGroup(UserProfile friend) async {
    setState(() {
      isAddingMember = true;
      addingUserId = friend.id;
      errorMessage = '';
      successMessage = '';
    });

    try {
      await groupsApiService.addMemberToGroup(
        token: widget.token,
        groupId: widget.groupId,
        userId: friend.id,
      );

      setState(() {
        successMessage = 'Dodano użytkownika ${friend.username} do grupy.';
      });

      await loadGroupData(clearMessages: false);
    } catch (error) {
      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          isAddingMember = false;
          addingUserId = null;
        });
      }
    }
  }

  Future<void> confirmRemoveMember(GroupMember member) async {
    final bool? shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Usunąć członka z grupy?'),
          content: Text(
            'Czy na pewno chcesz usunąć użytkownika "${member.user.username}" z tej grupy?',
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
      removeMemberFromGroup(member);
    }
  }

  Future<void> removeMemberFromGroup(GroupMember member) async {
    setState(() {
      isRemovingMember = true;
      removingUserId = member.userId;
      errorMessage = '';
      successMessage = '';
    });

    try {
      await groupsApiService.removeMemberFromGroup(
        token: widget.token,
        groupId: widget.groupId,
        userId: member.userId,
      );

      setState(() {
        successMessage =
            'Usunięto użytkownika ${member.user.username} z grupy.';
      });

      await loadGroupData(clearMessages: false);
    } catch (error) {
      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          isRemovingMember = false;
          removingUserId = null;
        });
      }
    }
  }

  bool isFriendAlreadyInGroup(UserProfile friend) {
    return members.any((member) {
      return member.userId == friend.id;
    });
  }

  bool isCurrentUserOwner(AppGroup group) {
    final UserProfile? user = currentUser;

    if (user == null) {
      return false;
    }

    return group.ownerId == user.id;
  }

  @override
  Widget build(BuildContext context) {
    final AppGroup? currentGroup = group;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Szczegóły grupy'),
        actions: [
          IconButton(
            onPressed: isLoading
                ? null
                : () {
                    loadGroupData();
                  },
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
      onRefresh: () {
        return loadGroupData();
      },
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
          const SizedBox(height: 20),
          buildGroupActionsCard(group),
          const SizedBox(height: 16),
          buildLeaveGroupCard(group),
          const SizedBox(height: 24),
          buildAddFriendsCard(),
          const SizedBox(height: 24),
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
          const SizedBox(height: 12),
          const Text(
            'Członkowie grupy',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
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

  Widget buildGroupActionsCard(AppGroup group) {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.settings,
                  size: 32,
                  color: Colors.orange,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Zarządzanie grupą',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Edytuj dane grupy albo usuń grupę, jeśli jesteś jej właścicielem.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isDeletingGroup || isLeavingGroup
                        ? null
                        : () {
                            openEditGroup(group);
                          },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edytuj'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isDeletingGroup || isLeavingGroup
                        ? null
                        : () {
                            confirmDeleteGroup(group);
                          },
                    icon: const Icon(Icons.delete),
                    label: isDeletingGroup
                        ? const Text('Usuwanie...')
                        : const Text('Usuń'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLeaveGroupCard(AppGroup group) {
    final bool currentUserIsOwner = isCurrentUserOwner(group);

    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.logout,
                  size: 32,
                  color: Colors.red,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Opuść grupę',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              currentUserIsOwner
                  ? 'Jesteś właścicielem grupy. Właściciel powinien usunąć grupę albo przekazać ją komuś innemu w przyszłej funkcji.'
                  : 'Jeśli nie chcesz już należeć do tej grupy, możesz ją opuścić.',
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: currentUserIsOwner || isLeavingGroup
                    ? null
                    : () {
                        confirmLeaveGroup(group);
                      },
                icon: const Icon(Icons.logout),
                label: currentUserIsOwner
                    ? const Text('Właściciel nie może opuścić')
                    : isLeavingGroup
                        ? const Text('Opuszczanie...')
                        : const Text('Opuść grupę'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAddFriendsCard() {
    return Card(
      color: Colors.teal.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dodaj znajomego do grupy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Wybierz znajomego z listy. Nie musisz już wpisywać ID ręcznie.',
            ),
            const SizedBox(height: 16),
            if (friends.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Nie masz jeszcze znajomych do dodania. Najpierw dodaj znajomego i zaakceptuj zaproszenie.',
                  ),
                ),
              )
            else
              ...friends.map((friend) {
                return buildFriendToAddCard(friend);
              }),
          ],
        ),
      ),
    );
  }

  Widget buildFriendToAddCard(UserProfile friend) {
    final bool alreadyInGroup = isFriendAlreadyInGroup(friend);
    final bool isCurrentFriendLoading = addingUserId == friend.id;

    final String cityText = friend.city ?? 'Brak miasta';
    final String ageText =
        friend.age == null ? 'Brak wieku' : '${friend.age} lat';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              child: Icon(Icons.person),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.username,
                    style: const TextStyle(
                      fontSize: 17,
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
            const SizedBox(width: 12),
            FilledButton(
              onPressed: alreadyInGroup || isAddingMember
                  ? null
                  : () {
                      addMemberToGroup(friend);
                    },
              child: alreadyInGroup
                  ? const Text('Już w grupie')
                  : isCurrentFriendLoading
                      ? const Text('Dodaję...')
                      : const Text('Dodaj'),
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

    final bool isOwner = member.role == 'owner';
    final bool isCurrentMemberRemoving = removingUserId == member.userId;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isOwner || isRemovingMember
                    ? null
                    : () {
                        confirmRemoveMember(member);
                      },
                icon: const Icon(Icons.person_remove),
                label: isOwner
                    ? const Text('Właściciel grupy')
                    : isCurrentMemberRemoving
                        ? const Text('Usuwanie...')
                        : const Text('Usuń z grupy'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}