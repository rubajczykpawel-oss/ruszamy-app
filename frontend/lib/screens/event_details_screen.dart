import 'package:flutter/material.dart';

import '../models/app_event.dart';
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

  bool isLoading = true;
  bool isActionLoading = false;
  bool isDeletingEvent = false;

  String errorMessage = '';
  String successMessage = '';

  AppEvent? event;

  @override
  void initState() {
    super.initState();

    loadEventDetails();
  }

  Future<void> loadEventDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      successMessage = '';
    });

    try {
      final AppEvent loadedEvent = await eventsApiService.getEventDetails(
        eventId: widget.eventId,
        token: widget.token,
      );

      setState(() {
        event = loadedEvent;
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

    loadEventDetails();
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
      isDeletingEvent = true;
      errorMessage = '';
      successMessage = '';
    });

    try {
      await eventsApiService.deleteEvent(
        eventId: eventToDelete.id,
        token: widget.token,
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
          isDeletingEvent = false;
        });
      }
    }
  }

  Future<void> joinEvent() async {
    setState(() {
      isActionLoading = true;
      errorMessage = '';
      successMessage = '';
    });

    try {
      await eventsApiService.joinEvent(
        eventId: widget.eventId,
        token: widget.token,
      );

      setState(() {
        successMessage = 'Dołączono do wydarzenia.';
      });

      await loadEventDetails();
    } catch (error) {
      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          isActionLoading = false;
        });
      }
    }
  }

  Future<void> leaveEvent() async {
    setState(() {
      isActionLoading = true;
      errorMessage = '';
      successMessage = '';
    });

    try {
      await eventsApiService.leaveEvent(
        eventId: widget.eventId,
        token: widget.token,
      );

      setState(() {
        successMessage = 'Opuszczono wydarzenie.';
      });

      await loadEventDetails();
    } catch (error) {
      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          isActionLoading = false;
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
            onPressed: isLoading ? null : loadEventDetails,
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
              ? 'Nie udało się pobrać wydarzenia.'
              : errorMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget buildEventDetails(AppEvent event) {
    final String ageText = buildAgeText(event);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          event.title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          event.description,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
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
              icon: Icons.access_time,
              label: event.time,
            ),
            InfoChip(
              icon: Icons.directions_walk,
              label: event.activityType,
            ),
            InfoChip(
              icon: Icons.signal_cellular_alt,
              label: event.level,
            ),
            InfoChip(
              icon: Icons.people,
              label: '${event.participantsCount}/${event.maxParticipants}',
            ),
            if (ageText.isNotEmpty)
              InfoChip(
                icon: Icons.cake,
                label: ageText,
              ),
            InfoChip(
              icon: Icons.person,
              label: 'Creator ID: ${event.creatorId}',
            ),
          ],
        ),
        const SizedBox(height: 20),
        buildEventActionsCard(event),
        const SizedBox(height: 20),
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
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: isActionLoading || isDeletingEvent ? null : joinEvent,
            icon: const Icon(Icons.group_add),
            label: const Text('Dołącz do wydarzenia'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: isActionLoading || isDeletingEvent ? null : leaveEvent,
            icon: const Icon(Icons.logout),
            label: const Text('Opuść wydarzenie'),
          ),
        ),
      ],
    );
  }

  Widget buildEventActionsCard(AppEvent event) {
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
                    'Zarządzanie wydarzeniem',
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
              'Edytuj dane wydarzenia albo usuń wydarzenie, jeśli jesteś jego twórcą.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isDeletingEvent
                        ? null
                        : () {
                            openEditEvent(event);
                          },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edytuj'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isDeletingEvent
                        ? null
                        : () {
                            confirmDeleteEvent(event);
                          },
                    icon: const Icon(Icons.delete),
                    label: isDeletingEvent
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

  String buildAgeText(AppEvent event) {
    if (event.ageMin == null && event.ageMax == null) {
      return '';
    }

    if (event.ageMin != null && event.ageMax != null) {
      return '${event.ageMin}-${event.ageMax} lat';
    }

    if (event.ageMin != null) {
      return 'od ${event.ageMin} lat';
    }

    return 'do ${event.ageMax} lat';
  }
}