import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/app_group.dart';

class EditGroupScreen extends StatefulWidget {
  final String token;
  final AppGroup group;

  const EditGroupScreen({
    super.key,
    required this.token,
    required this.group,
  });

  @override
  State<EditGroupScreen> createState() {
    return _EditGroupScreenState();
  }
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  bool isSaving = false;

  String selectedActivityType = 'Spacer';

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

  @override
  void initState() {
    super.initState();

    fillFormWithGroupData();
  }

  void fillFormWithGroupData() {
    nameController.text = widget.group.name;
    descriptionController.text = widget.group.description;
    cityController.text = widget.group.city;

    selectedActivityType = widget.group.activityType;

    if (!activityTypes.contains(selectedActivityType)) {
      activityTypes.add(selectedActivityType);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    cityController.dispose();

    super.dispose();
  }

  bool validateForm() {
    final String name = nameController.text.trim();
    final String city = cityController.text.trim();

    if (name.isEmpty) {
      showValidationError('Wpisz nazwę grupy.');
      return false;
    }

    if (city.isEmpty) {
      showValidationError('Wpisz miasto grupy.');
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

  Future<void> updateGroup() async {
    if (!validateForm()) {
      return;
    }

    setState(() {
      isSaving = true;
      errorMessage = '';
      successMessage = '';
    });

    final Map<String, dynamic> body = {
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim(),
      'city': cityController.text.trim(),
      'activity_type': selectedActivityType,
    };

    try {
      final http.Response response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/groups/${widget.group.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          successMessage = 'Grupa została zaktualizowana.';
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

  void resetForm() {
    setState(() {
      fillFormWithGroupData();

      errorMessage = '';
      successMessage = '';
    });
  }

  String buildShortDate(String value) {
    if (value.length >= 10) {
      return value.substring(0, 10);
    }

    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edytuj grupę'),
        actions: [
          IconButton(
            onPressed: isSaving ? null : resetForm,
            icon: const Icon(Icons.restore),
            tooltip: 'Przywróć dane grupy',
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
          buildCommunitySection(),
          const SizedBox(height: 16),
          buildGroupInfoSection(),
          const SizedBox(height: 16),
          buildSaveSection(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget buildHeaderCard() {
    return Card(
      color: Colors.teal.shade50,
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
      backgroundColor: Colors.teal.shade100,
      child: const Icon(
        Icons.edit,
        size: 44,
      ),
    );
  }

  Widget buildHeaderText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Edycja grupy',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.group.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Zmień dane grupy i zapisz formularz.',
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
      subtitle: 'Nazwa grupy, opis i miasto, w którym działa grupa.',
      children: [
        buildTextField(
          controller: nameController,
          label: 'Nazwa grupy',
          hint: 'np. Spacerowicze Wrocław',
          icon: Icons.groups,
        ),
        const SizedBox(height: 12),
        buildTextField(
          controller: descriptionController,
          label: 'Opis grupy',
          hint: 'Napisz krótko, dla kogo jest ta grupa',
          icon: Icons.description,
          maxLines: 4,
        ),
        const SizedBox(height: 12),
        buildTextField(
          controller: cityController,
          label: 'Miasto',
          hint: 'np. Wrocław',
          icon: Icons.location_city,
        ),
      ],
    );
  }

  Widget buildCommunitySection() {
    return buildSectionCard(
      color: Colors.orange.shade50,
      icon: Icons.directions_walk,
      title: 'Aktywność grupy',
      subtitle: 'Wybierz główny typ aktywności tej grupy.',
      children: [
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
        buildHintBox(),
      ],
    );
  }

  Widget buildHintBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.shade100,
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Po zapisaniu zmian wrócisz do szczegółów grupy, gdzie zobaczysz nowe dane.',
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGroupInfoSection() {
    return buildSectionCard(
      color: Colors.blue.shade50,
      icon: Icons.badge,
      title: 'Informacje techniczne',
      subtitle: 'Dane pomocnicze tej grupy.',
      children: [
        buildInfoRow(
          icon: Icons.badge,
          label: 'ID grupy',
          value: widget.group.id.toString(),
        ),
        const Divider(),
        buildInfoRow(
          icon: Icons.person,
          label: 'Owner ID',
          value: widget.group.ownerId.toString(),
        ),
        const Divider(),
        buildInfoRow(
          icon: Icons.calendar_month,
          label: 'Utworzono',
          value: buildShortDate(widget.group.createdAt),
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
                'Zapisz zmiany',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Po zapisaniu wrócisz do szczegółów grupy, a dane zostaną odświeżone.',
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
        onPressed: isSaving ? null : updateGroup,
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
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
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