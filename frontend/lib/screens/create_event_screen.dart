import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

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
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController locationNameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController maxParticipantsController =
      TextEditingController();
  final TextEditingController ageMinController = TextEditingController();
  final TextEditingController ageMaxController = TextEditingController();
  final TextEditingController groupIdController = TextEditingController();

  bool isSaving = false;
  bool isPublic = true;

  String selectedActivityType = 'Spacer';
  String selectedLevel = 'Początkujący';

  String errorMessage = '';
  String successMessage = '';

  final List<String> activityTypes = [
    'Spacer',
    'Bieganie',
    'Rower',
    'Piłka nożna',
    'Koszykówka',
    'Siłownia plenerowa',
    'Góry',
    'Rolki',
    'Tenis',
    'Inne',
  ];

  final List<String> levels = [
    'Początkujący',
    'Średni',
    'Zaawansowany',
  ];

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    cityController.dispose();
    locationNameController.dispose();
    dateController.dispose();
    timeController.dispose();
    maxParticipantsController.dispose();
    ageMinController.dispose();
    ageMaxController.dispose();
    groupIdController.dispose();

    super.dispose();
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

    return '$hour:$minute';
  }

  int? parseOptionalInt(String value) {
    final String trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      return null;
    }

    return int.tryParse(trimmedValue);
  }

  Future<void> pickDate() async {
    final DateTime now = DateTime.now();

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      dateController.text = formatDate(selectedDate);
    });
  }

  Future<void> pickTime() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime == null) {
      return;
    }

    setState(() {
      timeController.text = formatTime(selectedTime);
    });
  }

  bool validateForm() {
    final String title = titleController.text.trim();
    final String city = cityController.text.trim();
    final String locationName = locationNameController.text.trim();
    final String date = dateController.text.trim();
    final String time = timeController.text.trim();
    final String maxParticipantsText = maxParticipantsController.text.trim();
    final String ageMinText = ageMinController.text.trim();
    final String ageMaxText = ageMaxController.text.trim();
    final String groupIdText = groupIdController.text.trim();

    if (title.isEmpty) {
      showValidationError('Wpisz nazwę wydarzenia.');
      return false;
    }

    if (city.isEmpty) {
      showValidationError('Wpisz miasto wydarzenia.');
      return false;
    }

    if (locationName.isEmpty) {
      showValidationError('Wpisz dokładne miejsce wydarzenia.');
      return false;
    }

    if (date.isEmpty) {
      showValidationError('Wybierz datę wydarzenia.');
      return false;
    }

    if (time.isEmpty) {
      showValidationError('Wybierz godzinę wydarzenia.');
      return false;
    }

    final int? maxParticipants = int.tryParse(maxParticipantsText);

    if (maxParticipants == null) {
      showValidationError('Limit uczestników musi być liczbą.');
      return false;
    }

    if (maxParticipants < 1) {
      showValidationError('Limit uczestników musi być większy od 0.');
      return false;
    }

    if (ageMinText.isNotEmpty && int.tryParse(ageMinText) == null) {
      showValidationError('Minimalny wiek musi być liczbą.');
      return false;
    }

    if (ageMaxText.isNotEmpty && int.tryParse(ageMaxText) == null) {
      showValidationError('Maksymalny wiek musi być liczbą.');
      return false;
    }

    final int? ageMin = parseOptionalInt(ageMinText);
    final int? ageMax = parseOptionalInt(ageMaxText);

    if (ageMin != null && ageMin < 1) {
      showValidationError('Minimalny wiek musi być większy od 0.');
      return false;
    }

    if (ageMax != null && ageMax < 1) {
      showValidationError('Maksymalny wiek musi być większy od 0.');
      return false;
    }

    if (ageMin != null && ageMax != null && ageMin > ageMax) {
      showValidationError(
        'Minimalny wiek nie może być większy niż maksymalny wiek.',
      );
      return false;
    }

    if (groupIdText.isNotEmpty && int.tryParse(groupIdText) == null) {
      showValidationError('ID grupy musi być liczbą.');
      return false;
    }

    return true;
  }

  void showValidationError(String message) {
    setState(() {
      errorMessage = message;
      successMessage = '';
    });
  }

  String getErrorDetail(http.Response response) {
    try {
      final dynamic decodedBody = jsonDecode(response.body);

      if (decodedBody is Map<String, dynamic>) {
        return decodedBody['detail'].toString();
      }

      return response.body;
    } catch (_) {
      return response.body;
    }
  }

  Future<void> createEvent() async {
    if (!validateForm()) {
      return;
    }

    setState(() {
      isSaving = true;
      errorMessage = '';
      successMessage = '';
    });

    final Map<String, dynamic> body = {
      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'activity_type': selectedActivityType,
      'city': cityController.text.trim(),
      'location_name': locationNameController.text.trim(),
      'date': dateController.text.trim(),
      'time': timeController.text.trim(),
      'max_participants': int.parse(maxParticipantsController.text.trim()),
      'level': selectedLevel,
      'age_min': parseOptionalInt(ageMinController.text),
      'age_max': parseOptionalInt(ageMaxController.text),
      'is_public': isPublic,
      'group_id': parseOptionalInt(groupIdController.text),
    };

    try {
      final http.Response response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/events'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          successMessage = 'Wydarzenie zostało utworzone.';
        });

        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) {
          return;
        }

        Navigator.pop(context, true);
      } else {
        setState(() {
          errorMessage = getErrorDetail(response);
        });
      }
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
    setState(() {
      titleController.clear();
      descriptionController.clear();
      cityController.clear();
      locationNameController.clear();
      dateController.clear();
      timeController.clear();
      maxParticipantsController.clear();
      ageMinController.clear();
      ageMaxController.clear();
      groupIdController.clear();

      selectedActivityType = 'Spacer';
      selectedLevel = 'Początkujący';
      isPublic = true;

      errorMessage = '';
      successMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj wydarzenie'),
        actions: [
          IconButton(
            onPressed: isSaving ? null : clearForm,
            icon: const Icon(Icons.clear),
            tooltip: 'Wyczyść formularz',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildHeaderCard(),
          const SizedBox(height: 16),
          buildMessages(),
          buildBasicInfoSection(),
          const SizedBox(height: 16),
          buildDateAndPlaceSection(),
          const SizedBox(height: 16),
          buildParticipantsSection(),
          const SizedBox(height: 16),
          buildVisibilitySection(),
          const SizedBox(height: 16),
          buildSaveSection(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget buildHeaderCard() {
    return Card(
      color: Colors.purple.shade50,
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
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildHeaderIcon(),
                const SizedBox(width: 18),
                Expanded(
                  child: buildHeaderText(),
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
      backgroundColor: Colors.purple.shade100,
      child: const Icon(
        Icons.add_circle,
        size: 44,
      ),
    );
  }

  Widget buildHeaderText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nowe wydarzenie',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Uzupełnij dane wydarzenia. Pola z nazwą, miastem, miejscem, datą, godziną i limitem uczestników są najważniejsze.',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade800,
          ),
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

  Widget buildBasicInfoSection() {
    return buildSectionCard(
      color: Colors.grey.shade50,
      icon: Icons.info,
      title: 'Podstawowe informacje',
      subtitle: 'Nazwa, opis, typ aktywności i poziom wydarzenia.',
      children: [
        buildTextField(
          controller: titleController,
          label: 'Nazwa wydarzenia',
          hint: 'np. Spacer po parku',
          icon: Icons.title,
        ),
        const SizedBox(height: 12),
        buildTextField(
          controller: descriptionController,
          label: 'Opis',
          hint: 'Napisz krótko, o co chodzi w wydarzeniu',
          icon: Icons.description,
          maxLines: 4,
        ),
        const SizedBox(height: 12),
        buildDropdownField(
          label: 'Typ aktywności',
          icon: Icons.directions_walk,
          value: selectedActivityType,
          values: activityTypes,
          onChanged: (String value) {
            setState(() {
              selectedActivityType = value;
            });
          },
        ),
        const SizedBox(height: 12),
        buildDropdownField(
          label: 'Poziom',
          icon: Icons.signal_cellular_alt,
          value: selectedLevel,
          values: levels,
          onChanged: (String value) {
            setState(() {
              selectedLevel = value;
            });
          },
        ),
      ],
    );
  }

  Widget buildDateAndPlaceSection() {
    return buildSectionCard(
      color: Colors.blue.shade50,
      icon: Icons.place,
      title: 'Miejsce i termin',
      subtitle: 'Podaj miasto, dokładne miejsce, datę i godzinę.',
      children: [
        buildTextField(
          controller: cityController,
          label: 'Miasto',
          hint: 'np. Wrocław',
          icon: Icons.location_city,
        ),
        const SizedBox(height: 12),
        buildTextField(
          controller: locationNameController,
          label: 'Dokładne miejsce',
          hint: 'np. Park Szczytnicki, wejście główne',
          icon: Icons.place,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final bool isNarrow = constraints.maxWidth < 560;

            if (isNarrow) {
              return Column(
                children: [
                  buildDateField(),
                  const SizedBox(height: 12),
                  buildTimeField(),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: buildDateField(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: buildTimeField(),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget buildParticipantsSection() {
    return buildSectionCard(
      color: Colors.green.shade50,
      icon: Icons.people,
      title: 'Uczestnicy',
      subtitle: 'Ustaw limit miejsc i opcjonalne ograniczenia wieku.',
      children: [
        buildTextField(
          controller: maxParticipantsController,
          label: 'Maksymalna liczba uczestników',
          hint: 'np. 10',
          icon: Icons.people,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final bool isNarrow = constraints.maxWidth < 560;

            if (isNarrow) {
              return Column(
                children: [
                  buildTextField(
                    controller: ageMinController,
                    label: 'Minimalny wiek',
                    hint: 'opcjonalnie',
                    icon: Icons.cake,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  buildTextField(
                    controller: ageMaxController,
                    label: 'Maksymalny wiek',
                    hint: 'opcjonalnie',
                    icon: Icons.cake,
                    keyboardType: TextInputType.number,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: buildTextField(
                    controller: ageMinController,
                    label: 'Minimalny wiek',
                    hint: 'opcjonalnie',
                    icon: Icons.cake,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: buildTextField(
                    controller: ageMaxController,
                    label: 'Maksymalny wiek',
                    hint: 'opcjonalnie',
                    icon: Icons.cake,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget buildVisibilitySection() {
    return buildSectionCard(
      color: Colors.orange.shade50,
      icon: Icons.public,
      title: 'Widoczność i grupa',
      subtitle: 'Zdecyduj, czy wydarzenie ma być publiczne i opcjonalnie przypisz je do grupy.',
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Wydarzenie publiczne',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            isPublic
                ? 'Każdy użytkownik może zobaczyć to wydarzenie.'
                : 'Wydarzenie nie będzie publiczne.',
          ),
          value: isPublic,
          onChanged: (bool value) {
            setState(() {
              isPublic = value;
            });
          },
        ),
        const SizedBox(height: 12),
        buildTextField(
          controller: groupIdController,
          label: 'ID grupy',
          hint: 'opcjonalnie, np. 1',
          icon: Icons.groups,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget buildSaveSection() {
    return Card(
      color: Colors.indigo.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isNarrow = constraints.maxWidth < 560;

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSaveText(),
                  const SizedBox(height: 16),
                  buildSaveButton(),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: buildSaveText(),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 220,
                  child: buildSaveButton(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildSaveText() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.save,
          size: 34,
          color: Colors.indigo,
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Zapisz wydarzenie',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Po zapisaniu wrócisz do poprzedniego ekranu, a lista wydarzeń się odświeży.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildSaveButton() {
    return SizedBox(
      height: 46,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: isSaving ? null : createEvent,
        icon: isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save),
        label: isSaving
            ? const Text('Zapisywanie...')
            : const Text('Zapisz'),
      ),
    );
  }

  Widget buildSectionCard({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildSectionHeader(
              icon: icon,
              title: title,
              subtitle: subtitle,
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
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

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
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
        hintText: hint,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> values,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      items: values.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue == null) {
          return;
        }

        onChanged(newValue);
      },
    );
  }

  Widget buildDateField() {
    return TextField(
      controller: dateController,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Data',
        hintText: 'YYYY-MM-DD',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_month),
      ),
      onTap: pickDate,
    );
  }

  Widget buildTimeField() {
    return TextField(
      controller: timeController,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Godzina',
        hintText: 'HH:MM',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.schedule),
      ),
      onTap: pickTime,
    );
  }
}