import 'package:flutter/material.dart';

import '../models/app_event.dart';
import '../services/events_api_service.dart';

class CreateEventScreen extends StatefulWidget {
  final String token;

  const CreateEventScreen({
    super.key,
    required this.token,
  });

  @override
  State<CreateEventScreen> createState() {
    return _CreateEventScreenState();
  }
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final EventsApiService eventsApiService = EventsApiService();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController activityTypeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController locationNameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController maxParticipantsController =
      TextEditingController();
  final TextEditingController levelController = TextEditingController();
  final TextEditingController ageMinController = TextEditingController();
  final TextEditingController ageMaxController = TextEditingController();
  final TextEditingController groupIdController = TextEditingController();

  bool isPublic = true;
  bool isSaving = false;

  String errorMessage = '';
  String successMessage = '';

  AppEvent? createdEvent;

  @override
  void initState() {
    super.initState();

    activityTypeController.text = 'walking';
    cityController.text = 'Wrocław';
    dateController.text = '2026-06-25';
    timeController.text = '18:30:00';
    maxParticipantsController.text = '10';
    levelController.text = 'easy';
  }

  Future<void> createEvent() async {
    setState(() {
      isSaving = true;
      errorMessage = '';
      successMessage = '';
      createdEvent = null;
    });

    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        activityTypeController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        locationNameController.text.trim().isEmpty ||
        dateController.text.trim().isEmpty ||
        timeController.text.trim().isEmpty ||
        maxParticipantsController.text.trim().isEmpty ||
        levelController.text.trim().isEmpty) {
      setState(() {
        isSaving = false;
        errorMessage =
            'Uzupełnij wymagane pola: tytuł, opis, typ aktywności, miasto, miejsce, data, godzina, limit uczestników i poziom.';
      });

      return;
    }

    try {
      final AppEvent newEvent = await eventsApiService.createEvent(
        token: widget.token,
        title: titleController.text,
        description: descriptionController.text,
        activityType: activityTypeController.text,
        city: cityController.text,
        locationName: locationNameController.text,
        date: dateController.text,
        time: timeController.text,
        maxParticipants: maxParticipantsController.text,
        level: levelController.text,
        ageMin: ageMinController.text,
        ageMax: ageMaxController.text,
        isPublic: isPublic,
        groupId: groupIdController.text,
      );

      setState(() {
        createdEvent = newEvent;
        successMessage = 'Wydarzenie zostało utworzone.';
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    locationNameController.clear();
    ageMinController.clear();
    ageMaxController.clear();
    groupIdController.clear();

    activityTypeController.text = 'walking';
    cityController.text = 'Wrocław';
    dateController.text = '2026-06-25';
    timeController.text = '18:30:00';
    maxParticipantsController.text = '10';
    levelController.text = 'easy';

    setState(() {
      isPublic = true;
      errorMessage = '';
      successMessage = '';
      createdEvent = null;
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    activityTypeController.dispose();
    cityController.dispose();
    locationNameController.dispose();
    dateController.dispose();
    timeController.dispose();
    maxParticipantsController.dispose();
    levelController.dispose();
    ageMinController.dispose();
    ageMaxController.dispose();
    groupIdController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj wydarzenie'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Nowe wydarzenie',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Utwórz wydarzenie bez używania Swaggera.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          buildTextField(
            controller: titleController,
            label: 'Tytuł wydarzenia',
            icon: Icons.title,
          ),
          const SizedBox(height: 16),
          buildTextField(
            controller: descriptionController,
            label: 'Opis',
            icon: Icons.description,
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          buildTextField(
            controller: activityTypeController,
            label: 'Typ aktywności, np. walking, football, cycling',
            icon: Icons.directions_walk,
          ),
          const SizedBox(height: 16),
          buildTextField(
            controller: cityController,
            label: 'Miasto',
            icon: Icons.location_city,
          ),
          const SizedBox(height: 16),
          buildTextField(
            controller: locationNameController,
            label: 'Miejsce spotkania',
            icon: Icons.place,
          ),
          const SizedBox(height: 16),
          buildTextField(
            controller: dateController,
            label: 'Data, np. 2026-06-25',
            icon: Icons.calendar_month,
          ),
          const SizedBox(height: 16),
          buildTextField(
            controller: timeController,
            label: 'Godzina, np. 18:30:00',
            icon: Icons.access_time,
          ),
          const SizedBox(height: 16),
          buildTextField(
            controller: maxParticipantsController,
            label: 'Limit uczestników',
            icon: Icons.people,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          buildTextField(
            controller: levelController,
            label: 'Poziom, np. easy, medium, hard',
            icon: Icons.signal_cellular_alt,
          ),
          const SizedBox(height: 16),
          buildTextField(
            controller: ageMinController,
            label: 'Minimalny wiek — opcjonalnie',
            icon: Icons.cake,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          buildTextField(
            controller: ageMaxController,
            label: 'Maksymalny wiek — opcjonalnie',
            icon: Icons.cake,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          buildTextField(
            controller: groupIdController,
            label: 'ID grupy — opcjonalnie',
            icon: Icons.groups,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: isPublic,
            onChanged: (bool value) {
              setState(() {
                isPublic = value;
              });
            },
            title: const Text('Wydarzenie publiczne'),
            subtitle: Text(
              isPublic
                  ? 'Event będzie widoczny na publicznej liście wydarzeń.'
                  : 'Event będzie prywatny albo grupowy.',
            ),
          ),
          const SizedBox(height: 16),
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
          if (createdEvent != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Utworzono event: ${createdEvent!.title}\nID: ${createdEvent!.id}',
                ),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: isSaving ? null : createEvent,
              icon: const Icon(Icons.add),
              label: isSaving
                  ? const Text('Tworzenie...')
                  : const Text('Utwórz wydarzenie'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: isSaving ? null : clearForm,
              icon: const Icon(Icons.cleaning_services),
              label: const Text('Wyczyść formularz'),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Formaty wymagane przez backend:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text('Data: YYYY-MM-DD, np. 2026-06-25'),
          const Text('Godzina: HH:MM:SS, np. 18:30:00'),
          const Text('Jeśli event nie jest grupowy, zostaw ID grupy puste.'),
        ],
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }
}