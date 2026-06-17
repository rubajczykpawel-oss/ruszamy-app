import 'package:flutter/material.dart';

import '../models/app_event.dart';
import '../models/user_profile.dart';
import '../services/auth_api_service.dart';
import '../services/events_api_service.dart';
import '../widgets/info_chip.dart';
import 'edit_event_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final int eventId;
  final String token;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
    required this.token,
  });

  @override
  State<EventDetailsScreen> createState() {
    return _EventDetailsScreenState();
  }
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final EventsApiService eventsApiService = EventsApiService();
  final AuthApiService authApiService = AuthApiService();

  bool isLoading = true;
  bool isJoining = false;
  bool isLeaving = false;
  bool isDeleting = false;

  String errorMessage = '';
  String successMessage = '';

  AppEvent? event;
  UserProfile? currentUser;
  bool isJoined = false;

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
      final UserProfile loadedUser = await authApiService.getCurrentUser(
        token: widget.token,
      );

      final AppEvent loadedEvent = await eventsApiService.getEventDetails(
        eventId: widget.eventId,
        token: widget.token,
      );

      final List<AppEvent> loadedMyEvents = await eventsApiService.getMyEvents(
        token: widget.token,
      );

      final bool userIsJoined = loadedMyEvents.any((myEvent) {
        return myEvent.id == loadedEvent.id;
      });

      setState(() {
        currentUser = loadedUser;
        event = loadedEvent;
        isJoined = userIsJoined;
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

  bool isCurrentUserCreator() {
    final AppEvent? currentEvent = event;
    final UserProfile? user = currentUser;

    if (currentEvent == null || user == null) {
      return false;
    }

    return currentEvent.creatorId == user.id;
  }

  double getParticipantsProgress(AppEvent event) {
    if (event.maxParticipants <= 0) {
      return 0;
    }

    return (event.participantsCount / event.maxParticipants)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  String buildAgeText(AppEvent event) {
    if (event.ageMin != null && event.ageMax != null) {
      return '${event.ageMin}-${event.ageMax} lat';
    }

    if (event.ageMin != null) {
      return 'od ${event.ageMin} lat';
    }

    if (event.ageMax != null) {
      return 'do ${event.ageMax} lat';
    }

    return 'bez limitu wieku';
  }

  Future<void> joinEvent() async {
    final AppEvent? currentEvent = event;

    if (currentEvent == null) {
      return;
    }

    setState(() {
      isJoining = true;
      errorMessage = '';
      successMessage = '';
    });

    try {
      await eventsApiService.joinEvent(
        token: widget.token,
        eventId: currentEvent.id,
      );

      setState(() {
        successMessage = 'Dołączono do wydarzenia.';
      });

      await loadData(clearMessages: false);
    } catch (error) {
      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          isJoining = false;
        });
      }
    }
  }

  Future<void> leaveEvent() async {
    final AppEvent? currentEvent = event;

    if (currentEvent == null) {
      return;
    }

    setState(() {
      isLeaving = true;
      errorMessage = '';
      successMessage = '';
    });

    try {
      await eventsApiService.leaveEvent(
        token: widget.token,
        eventId: currentEvent.id,
      );

      setState(() {
        successMessage = 'Opuszczono wydarzenie.';
      });

      await loadData(clearMessages: false);
    } catch (error) {
      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          isLeaving = false;
        });
      }
    }
  }

  Future<void> openEditEvent(AppEvent eventToEdit) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return EditEventScreen(
            token: widget.token,
            event: eventToEdit,
          );
        },
      ),
    );

    loadData();
  }

  Future<void> confirmDeleteEvent(AppEvent eventToDelete) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Usunąć wydarzenie?'),
          content: Text(
            'Czy na pewno chcesz usunąć wydarzenie "${eventToDelete.title}"? '
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
      deleteEvent(eventToDelete);
    }
  }

  Future<void> deleteEvent(AppEvent eventToDelete) async {
    setState(() {
      isDeleting = true;
      errorMessage = '';
      successMessage = '';
    });

    try {
      await eventsApiService.deleteEvent(
        token: widget.token,
        eventId: eventToDelete.id,
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
          isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppEvent? currentEvent = event;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Szczegóły wydarzenia'),
        actions: [
          IconButton(
            onPressed: isLoading
                ? null
                : () {
                    loadData();
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
          : currentEvent == null
              ? buildErrorView()
              : buildEventDetails(currentEvent),
    );
  }

  Widget buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          errorMessage.isEmpty
              ? 'Nie udało się pobrać szczegółów wydarzenia.'
              : errorMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget buildEventDetails(AppEvent event) {
    final bool currentUserIsCreator = isCurrentUserCreator();

    return RefreshIndicator(
      onRefresh: () {
        return loadData();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildHeroCard(event),
          const SizedBox(height: 16),
          buildMessages(),
          buildParticipantsCard(event),
          const SizedBox(height: 16),
          buildMainInfoCard(event),
          const SizedBox(height: 16),
          buildDescriptionCard(event),
          const SizedBox(height: 16),
          buildActionCard(
            event: event,
            currentUserIsCreator: currentUserIsCreator,
          ),
          if (currentUserIsCreator) const SizedBox(height: 16),
          if (currentUserIsCreator)
            buildOwnerActionsCard(
              event: event,
            ),
        ],
      ),
    );
  }

  Widget buildHeroCard(AppEvent event) {
    return Card(
      color: Colors.green.shade50,
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
                  buildHeroText(event),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildHeroIcon(),
                const SizedBox(width: 18),
                Expanded(
                  child: buildHeroText(event),
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
      backgroundColor: Colors.green.shade100,
      child: const Icon(
        Icons.event,
        size: 44,
      ),
    );
  }

  Widget buildHeroText(AppEvent event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.title,
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
              label: event.city,
            ),
            InfoChip(
              icon: Icons.place,
              label: event.locationName,
            ),
            InfoChip(
              icon: Icons.calendar_month,
              label: event.date,
            ),
            InfoChip(
              icon: Icons.schedule,
              label: event.time,
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

  Widget buildParticipantsCard(AppEvent event) {
    final double progress = getParticipantsProgress(event);
    final int freePlaces = event.maxParticipants - event.participantsCount;

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.people,
                  color: Colors.blue,
                ),
                SizedBox(width: 12),
                Text(
                  'Uczestnicy',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${event.participantsCount}/${event.maxParticipants} miejsc zajętych',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              borderRadius: BorderRadius.circular(20),
            ),
            const SizedBox(height: 10),
            Text(
              freePlaces <= 0
                  ? 'Brak wolnych miejsc.'
                  : 'Wolne miejsca: $freePlaces',
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMainInfoCard(AppEvent event) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildInfoRow(
              icon: Icons.directions_walk,
              label: 'Typ aktywności',
              value: event.activityType,
            ),
            const Divider(),
            buildInfoRow(
              icon: Icons.signal_cellular_alt,
              label: 'Poziom',
              value: event.level,
            ),
            const Divider(),
            buildInfoRow(
              icon: Icons.cake,
              label: 'Wiek',
              value: buildAgeText(event),
            ),
            const Divider(),
            buildInfoRow(
              icon: Icons.public,
              label: 'Widoczność',
              value: event.isPublic ? 'Publiczne' : 'Prywatne',
            ),
            const Divider(),
            buildInfoRow(
              icon: Icons.person,
              label: 'Twórca',
              value: 'ID: ${event.creatorId}',
            ),
            if (event.groupId != null) const Divider(),
            if (event.groupId != null)
              buildInfoRow(
                icon: Icons.groups,
                label: 'Grupa',
                value: 'ID: ${event.groupId}',
              ),
          ],
        ),
      ),
    );
  }

  Widget buildDescriptionCard(AppEvent event) {
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
                Text(
                  'Opis wydarzenia',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              event.description.trim().isEmpty
                  ? 'Brak opisu wydarzenia.'
                  : event.description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildActionCard({
    required AppEvent event,
    required bool currentUserIsCreator,
  }) {
    final bool eventIsFull = event.participantsCount >= event.maxParticipants;

    return Card(
      color: isJoined ? Colors.orange.shade50 : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isNarrow = constraints.maxWidth < 560;

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildActionText(
                    currentUserIsCreator: currentUserIsCreator,
                    eventIsFull: eventIsFull,
                  ),
                  const SizedBox(height: 16),
                  buildJoinLeaveButton(
                    currentUserIsCreator: currentUserIsCreator,
                    eventIsFull: eventIsFull,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: buildActionText(
                    currentUserIsCreator: currentUserIsCreator,
                    eventIsFull: eventIsFull,
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 220,
                  child: buildJoinLeaveButton(
                    currentUserIsCreator: currentUserIsCreator,
                    eventIsFull: eventIsFull,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildActionText({
    required bool currentUserIsCreator,
    required bool eventIsFull,
  }) {
    String title;
    String description;
    IconData icon;

    if (currentUserIsCreator) {
      title = 'Jesteś twórcą wydarzenia';
      description =
          'Twórca wydarzenia jest automatycznie zapisany. Możesz edytować albo usunąć wydarzenie.';
      icon = Icons.admin_panel_settings;
    } else if (isJoined) {
      title = 'Jesteś zapisany';
      description = 'Możesz opuścić wydarzenie, jeśli jednak nie bierzesz udziału.';
      icon = Icons.check_circle;
    } else if (eventIsFull) {
      title = 'Brak wolnych miejsc';
      description = 'Limit uczestników został osiągnięty.';
      icon = Icons.block;
    } else {
      title = 'Dołącz do wydarzenia';
      description = 'Kliknij przycisk, żeby zapisać się na to wydarzenie.';
      icon = Icons.add_circle;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 34,
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

  Widget buildJoinLeaveButton({
    required bool currentUserIsCreator,
    required bool eventIsFull,
  }) {
    if (currentUserIsCreator) {
      return SizedBox(
        height: 44,
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.verified_user),
          label: const Text('Twórca wydarzenia'),
        ),
      );
    }

    if (isJoined) {
      return SizedBox(
        height: 44,
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: isLeaving || isJoining ? null : leaveEvent,
          icon: const Icon(Icons.logout),
          label: isLeaving
              ? const Text('Opuszczanie...')
              : const Text('Opuść wydarzenie'),
        ),
      );
    }

    return SizedBox(
      height: 44,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: eventIsFull || isJoining || isLeaving ? null : joinEvent,
        icon: const Icon(Icons.add),
        label: isJoining
            ? const Text('Dołączanie...')
            : const Text('Dołącz do wydarzenia'),
      ),
    );
  }

  Widget buildOwnerActionsCard({
    required AppEvent event,
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
                  buildOwnerActionsButtons(event),
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
                  child: buildOwnerActionsButtons(event),
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
                'Zarządzanie wydarzeniem',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Jako twórca możesz edytować albo usunąć to wydarzenie.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildOwnerActionsButtons(AppEvent event) {
    return Column(
      children: [
        SizedBox(
          height: 44,
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: isDeleting
                ? null
                : () {
                    openEditEvent(event);
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
            onPressed: isDeleting
                ? null
                : () {
                    confirmDeleteEvent(event);
                  },
            icon: const Icon(Icons.delete),
            label: isDeleting
                ? const Text('Usuwanie...')
                : const Text('Usuń'),
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