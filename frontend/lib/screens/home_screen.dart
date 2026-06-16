import 'package:flutter/material.dart';

import '../models/app_event.dart';
import '../models/app_group.dart';
import '../models/user_profile.dart';
import '../services/auth_api_service.dart';
import '../services/events_api_service.dart';
import '../services/friends_api_service.dart';
import '../services/groups_api_service.dart';
import '../widgets/event_card.dart';
import '../widgets/profile_header.dart';
import 'create_event_screen.dart';
import 'create_group_screen.dart';
import 'event_details_screen.dart';
import 'find_friends_screen.dart';
import 'friend_requests_screen.dart';
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
  final FriendsApiService friendsApiService = FriendsApiService();
  final GroupsApiService groupsApiService = GroupsApiService();

  final GlobalKey publicEventsKey = GlobalKey();

  bool isLoadingProfile = true;
  bool isLoadingEvents = true;
  bool isLoadingFriends = true;
  bool isLoadingGroups = true;

  bool isFriendsExpanded = true;
  bool isEventsExpanded = true;
  bool isGroupsExpanded = true;

  String errorMessage = '';

  String selectedCity = '';
  String selectedActivityType = '';
  String selectedLevel = '';

  UserProfile? profile;
  List<AppEvent> events = [];
  List<UserProfile> friends = [];
  List<AppGroup> groups = [];

  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future<void> loadData() async {
    await Future.wait([
      loadProfile(),
      loadEvents(),
      loadFriends(),
      loadGroups(),
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

  Future<void> loadFriends() async {
    setState(() {
      isLoadingFriends = true;
      errorMessage = '';
    });

    try {
      final List<UserProfile> loadedFriends =
          await friendsApiService.getMyFriends(
        token: widget.token,
      );

      setState(() {
        friends = loadedFriends;
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoadingFriends = false;
        });
      }
    }
  }

  Future<void> loadGroups() async {
    setState(() {
      isLoadingGroups = true;
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
          isLoadingGroups = false;
        });
      }
    }
  }

  List<AppEvent> getFilteredEvents() {
    return events.where((event) {
      final bool matchesCity = selectedCity.isEmpty ||
          event.city.toLowerCase() == selectedCity.toLowerCase();

      final bool matchesActivityType = selectedActivityType.isEmpty ||
          event.activityType.toLowerCase() ==
              selectedActivityType.toLowerCase();

      final bool matchesLevel = selectedLevel.isEmpty ||
          event.level.toLowerCase() == selectedLevel.toLowerCase();

      return matchesCity && matchesActivityType && matchesLevel;
    }).toList();
  }

  List<String> getUniqueValues(List<String> values) {
    final Set<String> uniqueValues = <String>{};

    for (final String value in values) {
      final String trimmedValue = value.trim();

      if (trimmedValue.isNotEmpty) {
        uniqueValues.add(trimmedValue);
      }
    }

    final List<String> sortedValues = uniqueValues.toList();
    sortedValues.sort();

    return sortedValues;
  }

  void clearFilters() {
    setState(() {
      selectedCity = '';
      selectedActivityType = '';
      selectedLevel = '';
    });
  }

  void scrollToPublicEvents() {
    final BuildContext? publicEventsContext = publicEventsKey.currentContext;

    if (publicEventsContext == null) {
      return;
    }

    Scrollable.ensureVisible(
      publicEventsContext,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
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

  Future<void> openFriendRequests() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return FriendRequestsScreen(
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
    final bool isLoading = isLoadingProfile ||
        isLoadingEvents ||
        isLoadingFriends ||
        isLoadingGroups;

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
          : LayoutBuilder(
              builder: (context, constraints) {
                final bool useDesktopLayout = constraints.maxWidth >= 500;

                if (useDesktopLayout) {
                  return buildDesktopLayout();
                }

                return buildMobileLayout();
              },
            ),
    );
  }

  Widget buildDesktopLayout() {
    return Row(
      children: [
        SizedBox(
          width: 300,
          child: buildLeftMenu(),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: buildMainContent(
            showMobileNavigationCards: false,
          ),
        ),
      ],
    );
  }

  Widget buildMobileLayout() {
    return buildMainContent(
      showMobileNavigationCards: true,
    );
  }

  Widget buildLeftMenu() {
    return Material(
      color: Colors.grey.shade100,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ProfileHeader(profile: profile),
          const SizedBox(height: 12),
          buildLeftMenuButton(
            icon: Icons.person,
            title: 'Mój profil',
            subtitle: 'Zobacz i edytuj dane',
            onTap: openProfile,
          ),
          const SizedBox(height: 8),
          buildLeftExpansionSection(
            icon: Icons.people,
            title: 'Znajomi',
            isExpanded: isFriendsExpanded,
            onExpansionChanged: (bool value) {
              setState(() {
                isFriendsExpanded = value;
              });
            },
            children: [
              buildSmallMenuButton(
                icon: Icons.person_search,
                title: 'Znajdź znajomych',
                onTap: openFindFriends,
              ),
              buildSmallMenuButton(
                icon: Icons.people,
                title: 'Moi znajomi i zaproszenia',
                onTap: openFriendRequests,
              ),
              const SizedBox(height: 8),
              buildFriendsPreview(),
            ],
          ),
          const SizedBox(height: 8),
          buildLeftExpansionSection(
            icon: Icons.event,
            title: 'Wydarzenia',
            isExpanded: isEventsExpanded,
            onExpansionChanged: (bool value) {
              setState(() {
                isEventsExpanded = value;
              });
            },
            children: [
              buildSmallMenuButton(
                icon: Icons.add_circle,
                title: 'Dodaj wydarzenie',
                onTap: openCreateEvent,
              ),
              buildSmallMenuButton(
                icon: Icons.event_available,
                title: 'Moje wydarzenia',
                onTap: openMyEvents,
              ),
              buildSmallMenuButton(
                icon: Icons.public,
                title: 'Publiczne wydarzenia',
                onTap: scrollToPublicEvents,
              ),
            ],
          ),
          const SizedBox(height: 8),
          buildLeftExpansionSection(
            icon: Icons.groups,
            title: 'Grupy',
            isExpanded: isGroupsExpanded,
            onExpansionChanged: (bool value) {
              setState(() {
                isGroupsExpanded = value;
              });
            },
            children: [
              buildSmallMenuButton(
                icon: Icons.group_add,
                title: 'Dodaj grupę',
                onTap: openCreateGroup,
              ),
              buildSmallMenuButton(
                icon: Icons.groups,
                title: 'Moje grupy',
                onTap: openMyGroups,
              ),
              const SizedBox(height: 8),
              buildGroupsPreview(),
            ],
          ),
          const SizedBox(height: 12),
          buildLeftMenuButton(
            icon: Icons.logout,
            title: 'Wyloguj',
            subtitle: 'Zakończ sesję',
            onTap: logout,
          ),
        ],
      ),
    );
  }

  Widget buildMainContent({
    required bool showMobileNavigationCards,
  }) {
    final List<AppEvent> filteredEvents = getFilteredEvents();

    return RefreshIndicator(
      onRefresh: loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (showMobileNavigationCards) ProfileHeader(profile: profile),
          if (showMobileNavigationCards) const SizedBox(height: 12),
          if (showMobileNavigationCards) buildNavigationCardsForMobile(),
          if (showMobileNavigationCards) const SizedBox(height: 16),
          Container(
            key: publicEventsKey,
            child: const Text(
              'Publiczne wydarzenia',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (events.isNotEmpty)
            buildFiltersCard(
              filteredEventsCount: filteredEvents.length,
            ),
          if (events.isNotEmpty) const SizedBox(height: 12),
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
                  'Brak publicznych wydarzeń. Utwórz event przez menu Dodaj wydarzenie.',
                ),
              ),
            )
          else if (filteredEvents.isEmpty)
            Card(
              color: Colors.amber.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Brak wydarzeń pasujących do wybranych filtrów. Wyczyść filtry albo wybierz inne wartości.',
                ),
              ),
            )
          else
            ...filteredEvents.map((event) {
              return EventCard(
                event: event,
                onTap: () {
                  openEventDetails(event);
                },
              );
            }),
        ],
      ),
    );
  }

  Widget buildNavigationCardsForMobile() {
    return Column(
      children: [
        buildNavigationCard(
          color: Colors.orange.shade50,
          iconColor: Colors.orange,
          icon: Icons.person,
          title: 'Mój profil',
          subtitle: 'Zobacz i edytuj swoje dane.',
          onPressed: openProfile,
        ),
        const SizedBox(height: 12),
        buildNavigationCard(
          color: Colors.indigo.shade50,
          iconColor: Colors.indigo,
          icon: Icons.person_search,
          title: 'Znajdź znajomych',
          subtitle: 'Wyszukaj użytkownika i wyślij zaproszenie.',
          onPressed: openFindFriends,
        ),
        const SizedBox(height: 12),
        buildNavigationCard(
          color: Colors.cyan.shade50,
          iconColor: Colors.cyan,
          icon: Icons.people,
          title: 'Znajomi',
          subtitle: 'Sprawdź zaproszenia i listę znajomych.',
          onPressed: openFriendRequests,
        ),
        const SizedBox(height: 12),
        buildNavigationCard(
          color: Colors.purple.shade50,
          iconColor: Colors.purple,
          icon: Icons.add_circle,
          title: 'Dodaj wydarzenie',
          subtitle: 'Utwórz nowy event bez używania Swaggera.',
          onPressed: openCreateEvent,
        ),
        const SizedBox(height: 12),
        buildNavigationCard(
          color: Colors.teal.shade50,
          iconColor: Colors.teal,
          icon: Icons.group_add,
          title: 'Dodaj grupę',
          subtitle: 'Utwórz nową grupę bez używania Swaggera.',
          onPressed: openCreateGroup,
        ),
        const SizedBox(height: 12),
        buildNavigationCard(
          color: Colors.green.shade50,
          iconColor: Colors.green,
          icon: Icons.event_available,
          title: 'Moje wydarzenia',
          subtitle: 'Zobacz eventy, do których jesteś zapisany.',
          onPressed: openMyEvents,
        ),
        const SizedBox(height: 12),
        buildNavigationCard(
          color: Colors.blue.shade50,
          iconColor: Colors.blue,
          icon: Icons.groups,
          title: 'Moje grupy',
          subtitle: 'Zobacz grupy, do których należysz.',
          onPressed: openMyGroups,
        ),
      ],
    );
  }

  Widget buildFriendsPreview() {
    if (friends.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Brak znajomych do pokazania.',
          style: TextStyle(fontSize: 13),
        ),
      );
    }

    final List<UserProfile> previewFriends = friends.take(5).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Twoi znajomi (${friends.length})',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          ...previewFriends.map((friend) {
            return buildFriendPreviewRow(friend);
          }),
          if (friends.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '+ ${friends.length - 5} więcej',
                style: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildGroupsPreview() {
    if (groups.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Brak grup do pokazania.',
          style: TextStyle(fontSize: 13),
        ),
      );
    }

    final List<AppGroup> previewGroups = groups.take(5).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Twoje grupy (${groups.length})',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          ...previewGroups.map((group) {
            return buildGroupPreviewRow(group);
          }),
          if (groups.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '+ ${groups.length - 5} więcej',
                style: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildFriendPreviewRow(UserProfile friend) {
    final String cityText = friend.city ?? 'Brak miasta';

    return InkWell(
      onTap: openFriendRequests,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 14,
              child: Icon(
                Icons.person,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    cityText,
                    maxLines: 1,
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

  Widget buildGroupPreviewRow(AppGroup group) {
    return InkWell(
      onTap: openMyGroups,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 14,
              child: Icon(
                Icons.groups,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${group.city} • ${group.activityType}',
                    maxLines: 1,
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

  Widget buildLeftMenuButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        dense: true,
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }

  Widget buildLeftExpansionSection({
    required IconData icon,
    required String title,
    required bool isExpanded,
    required ValueChanged<bool> onExpansionChanged,
    required List<Widget> children,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        onExpansionChanged: onExpansionChanged,
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: children,
      ),
    );
  }

  Widget buildSmallMenuButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNavigationCard({
    required Color color,
    required Color iconColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: iconColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle),
                ],
              ),
            ),
            FilledButton(
              onPressed: onPressed,
              child: const Text('Otwórz'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFiltersCard({
    required int filteredEventsCount,
  }) {
    final List<String> cities = getUniqueValues(
      events.map((event) {
        return event.city;
      }).toList(),
    );

    final List<String> activityTypes = getUniqueValues(
      events.map((event) {
        return event.activityType;
      }).toList(),
    );

    final List<String> levels = getUniqueValues(
      events.map((event) {
        return event.level;
      }).toList(),
    );

    return Card(
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.filter_list),
                SizedBox(width: 8),
                Text(
                  'Filtry wydarzeń',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Pokazuję $filteredEventsCount z ${events.length} wydarzeń.',
            ),
            const SizedBox(height: 16),
            buildFilterDropdown(
              label: 'Miasto',
              icon: Icons.location_city,
              currentValue: selectedCity,
              allLabel: 'Wszystkie miasta',
              options: cities,
              onChanged: (String value) {
                setState(() {
                  selectedCity = value;
                });
              },
            ),
            const SizedBox(height: 12),
            buildFilterDropdown(
              label: 'Typ aktywności',
              icon: Icons.directions_walk,
              currentValue: selectedActivityType,
              allLabel: 'Wszystkie aktywności',
              options: activityTypes,
              onChanged: (String value) {
                setState(() {
                  selectedActivityType = value;
                });
              },
            ),
            const SizedBox(height: 12),
            buildFilterDropdown(
              label: 'Poziom',
              icon: Icons.signal_cellular_alt,
              currentValue: selectedLevel,
              allLabel: 'Wszystkie poziomy',
              options: levels,
              onChanged: (String value) {
                setState(() {
                  selectedLevel = value;
                });
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: clearFilters,
                icon: const Icon(Icons.clear),
                label: const Text('Wyczyść filtry'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFilterDropdown({
    required String label,
    required IconData icon,
    required String currentValue,
    required String allLabel,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    final String safeValue = options.contains(currentValue) ? currentValue : '';

    return DropdownButtonFormField<String>(
      key: ValueKey('$label-$safeValue'),
      initialValue: safeValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      items: [
        DropdownMenuItem<String>(
          value: '',
          child: Text(allLabel),
        ),
        ...options.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }),
      ],
      onChanged: (String? value) {
        onChanged(value ?? '');
      },
    );
  }
}