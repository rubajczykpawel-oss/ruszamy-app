import 'package:flutter/material.dart';

import '../models/app_group.dart';
import '../services/groups_api_service.dart';
import '../widgets/group_card.dart';
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

  List<AppGroup> groups = [];

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
        groups = loadedGroups;
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadMyGroups,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Grupy, do których należysz',
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
                  if (groups.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Nie należysz jeszcze do żadnej grupy.',
                        ),
                      ),
                    )
                  else
                    ...groups.map((group) {
                      return GroupCard(
                        group: group,
                        onTap: () {
                          openGroupDetails(group);
                        },
                      );
                    }),
                ],
              ),
            ),
    );
  }
}