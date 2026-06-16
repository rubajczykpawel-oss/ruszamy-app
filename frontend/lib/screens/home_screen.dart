import 'package:flutter/material.dart';

import '../models/app_event.dart';
import '../models/user_profile.dart';
import '../services/auth_api_service.dart';
import '../services/events_api_service.dart';
import '../widgets/event_card.dart';
import '../widgets/profile_header.dart';
import 'create_event_screen.dart';
import 'create_group_screen.dart';
import 'event_details_screen.dart';
import 'find_friends_screen.dart';
import 'login_screen.dart';
import 'my_events_screen.dart';
import 'my_groups_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String token;

  const HomeScreen({
    super.key,
    required this.token,
  });

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthApiService authApiService = AuthApiService();
  final EventsApiService eventsApiService = EventsApiService();

  bool isLoadingProfile = true;
  bool isLoadingEvents = true;

  String errorMessage = '';

  UserProfile? profile;
  List<AppEvent> events = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await Future.wait([
      loadProfile(),
      loadEvents(),
    ]);
  }

  Future<void> loadProfile() async {
    setState(() {
      isLoadingProfile = true;
      errorMessage = '';
    });

    try {
      final UserProfile loadedProfile = await authApiService.getCurrentUser(
        token: widget.token,
      );

      setState(() {
        profile = loadedProfile;
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoadingProfile = false;
        });
      }
    }
  }

  Future<void> loadEvents() async {
    setState(() {
      isLoadingEvents = true;
      errorMessage = '';
    });

    try {
      final List<AppEvent> loadedEvents =
          await eventsApiService.getPublicEvents();

      setState(() {
        events = loadedEvents;
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoadingEvents = false;
        });
      }
    }
  }

  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const LoginScreen();
        },
      ),
    );
  }

  Future<void> openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ProfileScreen(
            token: widget.token,
          );
        },
      ),
    );

    loadProfile();
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

  Future<void> openCreateEvent() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return CreateEventScreen(
            token: widget.token,
          );
        },
      ),
    );

    loadEvents();
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

    loadData();
  }

  Future<void> openEventDetails(AppEvent event) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return EventDetailsScreen(
            eventId: event.id,
            token: widget.token,
          );
        },
      ),
    );

    loadEvents();
  }

  Future<void> openMyEvents() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return MyEventsScreen(
            token: widget.token,
          );
        },
      ),
    );

    loadEvents();
  }

  Future<void> openMyGroups() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return MyGroupsScreen(
            token: widget.token,
          );
        },
      ),
    );

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = isLoadingProfile || isLoadingEvents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruszamy App'),
        actions: [
          IconButton(
            onPressed: loadData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Odśwież',
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Wyloguj',
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
                  ProfileHeader(profile: profile),

                  const SizedBox(height: 12),

                  Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 32,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mój profil',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text('Zobacz i edytuj swoje dane.'),
                              ],
                            ),
                          ),
                          FilledButton(
                            onPressed: openProfile,
                            child: const Text('Otwórz'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Card(
                    color: Colors.indigo.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person_search,
                            size: 32,
                            color: Colors.indigo,
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Znajdź znajomych',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Wyszukaj użytkownika i wyślij zaproszenie.',
                                ),
                              ],
                            ),
                          ),
                          FilledButton(
                            onPressed: openFindFriends,
                            child: const Text('Otwórz'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Card(
                    color: Colors.purple.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.add_circle,
                            size: 32,
                            color: Colors.purple,
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dodaj wydarzenie',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text('Utwórz nowy event bez używania Swaggera.'),
                              ],
                            ),
                          ),
                          FilledButton(
                            onPressed: openCreateEvent,
                            child: const Text('Otwórz'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Card(
                    color: Colors.teal.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.group_add,
                            size: 32,
                            color: Colors.teal,
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dodaj grupę',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text('Utwórz nową grupę bez używania Swaggera.'),
                              ],
                            ),
                          ),
                          FilledButton(
                            onPressed: openCreateGroup,
                            child: const Text('Otwórz'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.event_available,
                            size: 32,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Moje wydarzenia',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text('Zobacz eventy, do których jesteś zapisany.'),
                              ],
                            ),
                          ),
                          FilledButton(
                            onPressed: openMyEvents,
                            child: const Text('Otwórz'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.groups,
                            size: 32,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Moje grupy',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text('Zobacz grupy, do których należysz.'),
                              ],
                            ),
                          ),
                          FilledButton(
                            onPressed: openMyGroups,
                            child: const Text('Otwórz'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Publiczne wydarzenia',
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

                  if (events.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Brak publicznych wydarzeń. Utwórz event przez kafelek Dodaj wydarzenie.',
                        ),
                      ),
                    )
                  else
                    ...events.map((event) {
                      return EventCard(
                        event: event,
                        onTap: () {
                          openEventDetails(event);
                        },
                      );
                    }),
                ],
              ),
            ),
    );
  }
}