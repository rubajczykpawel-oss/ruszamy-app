import 'package:flutter/material.dart';

import '../models/app_event.dart';
import '../services/events_api_service.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/event_card.dart';
import '../widgets/message_card.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';
import 'create_event_screen.dart';
import 'event_details_screen.dart';

class MyEventsScreen extends StatefulWidget {
  final String token;

  const MyEventsScreen({
    super.key,
    required this.token,
  });

  @override
  State<MyEventsScreen> createState() {
    return _MyEventsScreenState();
  }
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  final EventsApiService eventsApiService = EventsApiService();

  bool isLoading = true;
  String errorMessage = '';

  List<AppEvent> myEvents = [];

  @override
  void initState() {
    super.initState();

    loadMyEvents();
  }

  Future<void> loadMyEvents() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final List<AppEvent> loadedEvents = await eventsApiService.getMyEvents(
        token: widget.token,
      );

      setState(() {
        myEvents = loadedEvents;
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

    loadMyEvents();
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

    loadMyEvents();
  }

  int countJoinedEvents() {
    return myEvents.length;
  }

  int countCreatedEvents() {
    return myEvents.where((event) {
      return event.creatorId > 0;
    }).length;
  }

  int countFullEvents() {
    return myEvents.where((event) {
      return event.participantsCount >= event.maxParticipants;
    }).length;
  }

  int countAvailableEvents() {
    return myEvents.where((event) {
      return event.participantsCount < event.maxParticipants;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje wydarzenia'),
        actions: [
          IconButton(
            onPressed: isLoading ? null : loadMyEvents,
            icon: const Icon(Icons.refresh),
            tooltip: 'Odśwież',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openCreateEvent,
        icon: const Icon(Icons.add),
        label: const Text('Dodaj event'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadMyEvents,
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
                  if (myEvents.isEmpty)
                    EmptyStateCard(
                      icon: Icons.event_busy,
                      title: 'Nie masz jeszcze żadnych wydarzeń',
                      description:
                          'Utwórz własne wydarzenie albo dołącz do istniejącego wydarzenia publicznego.',
                      buttonText: 'Dodaj pierwsze wydarzenie',
                      onPressed: openCreateEvent,
                    )
                  else
                    buildEventsSection(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget buildHeaderCard() {
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
      backgroundColor: Colors.green.shade100,
      child: const Icon(
        Icons.event_available,
        size: 44,
      ),
    );
  }

  Widget buildHeaderText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Moje wydarzenia',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tutaj widzisz wydarzenia, do których jesteś zapisany albo które utworzyłeś.',
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
        onPressed: openCreateEvent,
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
              child: StatCard(
                icon: Icons.event,
                value: countJoinedEvents().toString(),
                title: 'Wszystkie',
                subtitle: 'Twoje wydarzenia',
                color: Colors.blue.shade50,
                iconColor: Colors.blue,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: StatCard(
                icon: Icons.person,
                value: countCreatedEvents().toString(),
                title: 'Powiązane z Tobą',
                subtitle: 'Eventy na Twojej liście',
                color: Colors.green.shade50,
                iconColor: Colors.green,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: StatCard(
                icon: Icons.check_circle,
                value: countAvailableEvents().toString(),
                title: 'Z miejscami',
                subtitle: 'Można jeszcze dołączyć',
                color: Colors.orange.shade50,
                iconColor: Colors.orange,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: StatCard(
                icon: Icons.block,
                value: countFullEvents().toString(),
                title: 'Pełne',
                subtitle: 'Brak wolnych miejsc',
                color: Colors.red.shade50,
                iconColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          icon: Icons.list_alt,
          title: 'Lista wydarzeń (${myEvents.length})',
          subtitle:
              'Kliknij wydarzenie, żeby zobaczyć szczegóły, uczestników i akcje.',
        ),
        const SizedBox(height: 12),
        ...myEvents.map((event) {
          return EventCard(
            event: event,
            onTap: () {
              openEventDetails(event);
            },
          );
        }),
      ],
    );
  }
}