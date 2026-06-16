import 'package:flutter/material.dart';

import '../models/app_event.dart';
import '../services/events_api_service.dart';

class EditEventScreen extends StatefulWidget {
  final String token;
  final AppEvent event;

  const EditEventScreen({
    super.key,
    required this.token,
    required this.event,
  });

  @override
  State<EditEventScreen> createState() {
    return _EditEventScreenState();
  }
}

class _EditEventScreenState extends State<EditEventScreen> {
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

  AppEvent? updatedEvent;

  @override
  void initState() {
    super.initState();

    titleController.text = widget.event.title;
    descriptionController.text = widget.event.description;
    activityTypeController.text = widget.event.activityType;
    cityController.text = widget.event.city;
    locationNameController.text = widget.event.locationName;
    dateController.text = widget.event.date;
    timeController.text = widget.event.time;
    maxParticipantsController.text = widget.event.maxParticipants.toString();
    levelController.text = widget.event.level;
    ageMinController.text = widget.event.ageMin?.toString() ?? '';
    ageMaxController.text = widget.event.ageMax?.toString() ?? '';
    groupIdController.text = widget.event.groupId?.toString() ?? '';
    isPublic = widget.event.isPublic;
  }

  Future<void> pickDate() async {
    final DateTime initialDate = parseInitialDate();

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (selectedDate == null) {
      return;
    }

    final String formattedDate = formatDate(selectedDate);

    setState(() {
      dateController.text = formattedDate;
    });
  }

  Future<void> pickTime() async {
    final TimeOfDay initialTime = parseInitialTime();

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selectedTime == null) {
      return;
    }

    final String formattedTime = formatTime(selectedTime);

    setState(() {
      timeController.text = formattedTime;
    });
  }

  DateTime parseInitialDate() {
    try {
      return DateTime.parse(dateController.text);
    } catch (_) {
      return DateTime.now();
    }
  }

  TimeOfDay parseInitialTime() {
    final List<String> parts = timeController.text.split(':');

    if (parts.length < 2) {
      return TimeOfDay.now();
    }

    final int? hour = int.tryParse(parts[0]);
    final int? minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      return TimeOfDay.now();
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  String formatDate(DateTime date) {
    final String year = date.year.toString();
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String formatTime(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute:00';
  }

  Future<void> updateEvent() async {
    setState(() {
      isSaving = true;
      errorMessage = '';
      successMessage = '';
      updatedEvent = null;
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
      final AppEvent savedEvent = await eventsApiService.updateEvent(
        token: widget.token,
        eventId: widget.event.id,
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
        updatedEvent = savedEvent;
        successMessage = 'Wydarzenie zostało zaktualizowane.';
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

  void goBackToDetails() {
    Navigator.pop(context, true);
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
    final AppEvent eventToShow = updatedEvent ?? widget.event;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edytuj wydarzenie'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Edycja wydarzenia',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Edytujesz wydarzenie ID: ${eventToShow.id}',
            style: const TextStyle(fontSize: 16),
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
          buildDatePickerField(),
          const SizedBox(height: 16),
          buildTimePickerField(),
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
          if (updatedEvent != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Zaktualizowano event: ${updatedEvent!.title}\nMiasto: ${updatedEvent!.city}\nData: ${updatedEvent!.date}\nGodzina: ${updatedEvent!.time}',
                ),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: isSaving ? null : updateEvent,
              icon: const Icon(Icons.save),
              label: isSaving
                  ? const Text('Zapisywanie...')
                  : const Text('Zapisz zmiany'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: goBackToDetails,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Wróć do szczegółów wydarzenia'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDatePickerField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: dateController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Data',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_month),
            ),
            onTap: pickDate,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: pickDate,
            child: const Text('Wybierz'),
          ),
        ),
      ],
    );
  }

  Widget buildTimePickerField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: timeController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Godzina',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.access_time),
            ),
            onTap: pickTime,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: pickTime,
            child: const Text('Wybierz'),
          ),
        ),
      ],
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