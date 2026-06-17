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

  bool isCurrentUserOwner(AppGroup group) {
    final UserProfile? user = currentUser;

    if (user == null) {
      return false;
    }

    return group.ownerId == user.id;
  }

  bool isCurrentUserMember() {
    final UserProfile? user = currentUser;

    if (user == null) {
      return false;
    }

    return members.any((member) {
      return member.userId == user.id;
    });
  }

  bool isFriendAlreadyInGroup(UserProfile friend) {
    return members.any((member) {
      return member.userId == friend.id;
    });
  }

  List<UserProfile> getFriendsNotInGroup() {
    return friends.where((friend) {
      return !isFriendAlreadyInGroup(friend);
    }).toList();
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
    final bool currentUserIsOwner = isCurrentUserOwner(group);
    final bool currentUserIsMember = isCurrentUserMember();

    return RefreshIndicator(
      onRefresh: () {
        return loadGroupData();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildHeroCard(group),
          const SizedBox(height: 16),
          buildMessages(),
          buildStatsCard(group),
          const SizedBox(height: 16),
          buildDescriptionCard(group),
          const SizedBox(height: 16),
          buildMembersCard(
            group: group,
            currentUserIsOwner: currentUserIsOwner,
          ),
          const SizedBox(height: 16),
          buildAddFriendsCard(
            currentUserIsOwner: currentUserIsOwner,
          ),
          const SizedBox(height: 16),
          buildLeaveGroupCard(
            group: group,
            currentUserIsOwner: currentUserIsOwner,
            currentUserIsMember: currentUserIsMember,
          ),
          if (currentUserIsOwner) const SizedBox(height: 16),
          if (currentUserIsOwner)
            buildOwnerActionsCard(
              group: group,
            ),
        ],
      ),
    );
  }

  Widget buildHeroCard(AppGroup group) {
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
                  buildHeroIcon(),
                  const SizedBox(height: 16),
                  buildHeroText(group),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildHeroIcon(),
                const SizedBox(width: 18),
                Expanded(
                  child: buildHeroText(group),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildHeroIcon() {
    return CircleAvatar(
      radius: 42,
      backgroundColor: Colors.orange.shade100,
      child: const Icon(
        Icons.groups,
        size: 44,
      ),
    );
  }

  Widget buildHeroText(AppGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          group.name,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
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
              label: 'Owner: ${group.ownerId}',
            ),
            InfoChip(
              icon: Icons.calendar_month,
              label: buildShortDate(group.createdAt),
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

  Widget buildStatsCard(AppGroup group) {
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
                value: members.length.toString(),
                title: 'Członkowie',
                subtitle: 'Osoby w grupie',
                color: Colors.blue.shade50,
                iconColor: Colors.blue,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: buildStatCard(
                icon: Icons.person_add,
                value: getFriendsNotInGroup().length.toString(),
                title: 'Do dodania',
                subtitle: 'Znajomi poza grupą',
                color: Colors.green.shade50,
                iconColor: Colors.green,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: buildStatCard(
                icon: Icons.directions_walk,
                value: group.activityType,
                title: 'Aktywność',
                subtitle: group.city,
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
                      fontSize: 24,
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

  Widget buildDescriptionCard(AppGroup group) {
    return Card(
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.description),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Opis grupy',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              group.description.trim().isEmpty
                  ? 'Brak opisu grupy.'
                  : group.description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMembersCard({
    required AppGroup group,
    required bool currentUserIsOwner,
  }) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSectionHeader(
              icon: Icons.people,
              title: 'Członkowie grupy',
              subtitle: 'Lista osób należących do tej grupy.',
            ),
            const SizedBox(height: 12),
            if (members.isEmpty)
              buildEmptyBox('Ta grupa nie ma jeszcze członków.')
            else
              ...members.map((member) {
                return buildMemberCard(
                  member: member,
                  currentUserIsOwner: currentUserIsOwner,
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget buildMemberCard({
    required GroupMember member,
    required bool currentUserIsOwner,
  }) {
    final String cityText = member.user.city ?? 'Brak miasta';
    final String ageText = member.user.age == null
        ? 'Brak wieku'
        : '${member.user.age} lat';

    final bool memberIsOwner = member.role == 'owner';
    final bool isCurrentMemberRemoving = removingUserId == member.userId;

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
                  buildMemberInfo(
                    member: member,
                    cityText: cityText,
                    ageText: ageText,
                  ),
                  const SizedBox(height: 12),
                  buildRemoveMemberButton(
                    member: member,
                    memberIsOwner: memberIsOwner,
                    currentUserIsOwner: currentUserIsOwner,
                    isCurrentMemberRemoving: isCurrentMemberRemoving,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: buildMemberInfo(
                    member: member,
                    cityText: cityText,
                    ageText: ageText,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 170,
                  child: buildRemoveMemberButton(
                    member: member,
                    memberIsOwner: memberIsOwner,
                    currentUserIsOwner: currentUserIsOwner,
                    isCurrentMemberRemoving: isCurrentMemberRemoving,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildMemberInfo({
    required GroupMember member,
    required String cityText,
    required String ageText,
  }) {
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
                member.user.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                member.user.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
    );
  }

  Widget buildRemoveMemberButton({
    required GroupMember member,
    required bool memberIsOwner,
    required bool currentUserIsOwner,
    required bool isCurrentMemberRemoving,
  }) {
    final bool buttonDisabled =
        memberIsOwner || !currentUserIsOwner || isRemovingMember;

    String label = 'Usuń';

    if (memberIsOwner) {
      label = 'Właściciel';
    } else if (!currentUserIsOwner) {
      label = 'Tylko owner';
    } else if (isCurrentMemberRemoving) {
      label = 'Usuwanie...';
    }

    return SizedBox(
      height: 44,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: buttonDisabled
            ? null
            : () {
                confirmRemoveMember(member);
              },
        icon: const Icon(Icons.person_remove),
        label: Text(label),
      ),
    );
  }

  Widget buildAddFriendsCard({
    required bool currentUserIsOwner,
  }) {
    final List<UserProfile> friendsNotInGroup = getFriendsNotInGroup();

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSectionHeader(
              icon: Icons.person_add,
              title: 'Dodaj znajomego',
              subtitle:
                  'Wybierz znajomego z listy i dodaj go do tej grupy.',
            ),
            const SizedBox(height: 12),
            if (!currentUserIsOwner)
              buildEmptyBox(
                'Tylko właściciel grupy może dodawać nowych członków.',
              )
            else if (friendsNotInGroup.isEmpty)
              buildEmptyBox(
                'Nie masz znajomych do dodania albo wszyscy są już w tej grupie.',
              )
            else
              ...friendsNotInGroup.map((friend) {
                return buildFriendToAddCard(friend);
              }),
          ],
        ),
      ),
    );
  }

  Widget buildFriendToAddCard(UserProfile friend) {
    final bool isCurrentFriendLoading = addingUserId == friend.id;

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
                  buildFriendToAddInfo(
                    friend: friend,
                    cityText: cityText,
                    ageText: ageText,
                  ),
                  const SizedBox(height: 12),
                  buildAddFriendButton(
                    friend: friend,
                    isCurrentFriendLoading: isCurrentFriendLoading,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: buildFriendToAddInfo(
                    friend: friend,
                    cityText: cityText,
                    ageText: ageText,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 140,
                  child: buildAddFriendButton(
                    friend: friend,
                    isCurrentFriendLoading: isCurrentFriendLoading,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildFriendToAddInfo({
    required UserProfile friend,
    required String cityText,
    required String ageText,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 26,
          child: Icon(Icons.person),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                friend.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                friend.email,
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
                    icon: Icons.person,
                    label: 'ID: ${friend.id}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildAddFriendButton({
    required UserProfile friend,
    required bool isCurrentFriendLoading,
  }) {
    return SizedBox(
      height: 44,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: isAddingMember
            ? null
            : () {
                addMemberToGroup(friend);
              },
        icon: const Icon(Icons.person_add),
        label: isCurrentFriendLoading
            ? const Text('Dodaję...')
            : const Text('Dodaj'),
      ),
    );
  }

  Widget buildLeaveGroupCard({
    required AppGroup group,
    required bool currentUserIsOwner,
    required bool currentUserIsMember,
  }) {
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
                  buildLeaveGroupText(
                    currentUserIsOwner: currentUserIsOwner,
                    currentUserIsMember: currentUserIsMember,
                  ),
                  const SizedBox(height: 16),
                  buildLeaveGroupButton(
                    group: group,
                    currentUserIsOwner: currentUserIsOwner,
                    currentUserIsMember: currentUserIsMember,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: buildLeaveGroupText(
                    currentUserIsOwner: currentUserIsOwner,
                    currentUserIsMember: currentUserIsMember,
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 220,
                  child: buildLeaveGroupButton(
                    group: group,
                    currentUserIsOwner: currentUserIsOwner,
                    currentUserIsMember: currentUserIsMember,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildLeaveGroupText({
    required bool currentUserIsOwner,
    required bool currentUserIsMember,
  }) {
    String title;
    String description;

    if (currentUserIsOwner) {
      title = 'Jesteś właścicielem grupy';
      description =
          'Właściciel nie powinien opuszczać grupy. Możesz ją edytować albo usunąć.';
    } else if (!currentUserIsMember) {
      title = 'Nie jesteś członkiem tej grupy';
      description = 'Nie możesz opuścić grupy, do której nie należysz.';
    } else {
      title = 'Opuść grupę';
      description = 'Możesz opuścić grupę, jeśli nie chcesz już do niej należeć.';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.logout,
          size: 34,
          color: Colors.red,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(description),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildLeaveGroupButton({
    required AppGroup group,
    required bool currentUserIsOwner,
    required bool currentUserIsMember,
  }) {
    final bool buttonDisabled =
        currentUserIsOwner || !currentUserIsMember || isLeavingGroup;

    String label = 'Opuść grupę';

    if (currentUserIsOwner) {
      label = 'Owner nie opuszcza';
    } else if (!currentUserIsMember) {
      label = 'Nie jesteś członkiem';
    } else if (isLeavingGroup) {
      label = 'Opuszczanie...';
    }

    return SizedBox(
      height: 44,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: buttonDisabled
            ? null
            : () {
                confirmLeaveGroup(group);
              },
        icon: const Icon(Icons.logout),
        label: Text(label),
      ),
    );
  }

  Widget buildOwnerActionsCard({
    required AppGroup group,
  }) {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isNarrow = constraints.maxWidth < 560;

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildOwnerActionsText(),
                  const SizedBox(height: 16),
                  buildOwnerActionsButtons(group),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: buildOwnerActionsText(),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 260,
                  child: buildOwnerActionsButtons(group),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildOwnerActionsText() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.settings,
          size: 34,
          color: Colors.orange,
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Zarządzanie grupą',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Jako właściciel możesz edytować albo usunąć tę grupę.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildOwnerActionsButtons(AppGroup group) {
    return Column(
      children: [
        SizedBox(
          height: 44,
          width: double.infinity,
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
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          width: double.infinity,
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

  Widget buildEmptyBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text),
    );
  }

  String buildShortDate(String value) {
    if (value.length >= 10) {
      return value.substring(0, 10);
    }

    return value;
  }
}