import 'package:flutter/material.dart';

import '../models/app_event.dart';
import '../services/events_api_service.dart';
import '../widgets/event_card.dart';
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

  List<AppEvent> events = [];

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
        events = loadedEvents;
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadMyEvents,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Eventy, do których jesteś zapisany',
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
                          'Nie jesteś jeszcze zapisany na żadne wydarzenie.',
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