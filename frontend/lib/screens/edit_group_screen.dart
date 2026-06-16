import 'package:flutter/material.dart';

import '../models/app_group.dart';
import '../services/groups_api_service.dart';

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
  final GroupsApiService groupsApiService = GroupsApiService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController activityTypeController = TextEditingController();

  bool isSaving = false;

  String errorMessage = '';
  String successMessage = '';

  AppGroup? updatedGroup;

  @override
  void initState() {
    super.initState();

    nameController.text = widget.group.name;
    descriptionController.text = widget.group.description;
    cityController.text = widget.group.city;
    activityTypeController.text = widget.group.activityType;
  }

  Future<void> updateGroup() async {
    setState(() {
      isSaving = true;
      errorMessage = '';
      successMessage = '';
      updatedGroup = null;
    });

    if (nameController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        activityTypeController.text.trim().isEmpty) {
      setState(() {
        isSaving = false;
        errorMessage =
            'Uzupełnij wymagane pola: nazwa, opis, miasto i typ aktywności.';
      });

      return;
    }

    try {
      final AppGroup savedGroup = await groupsApiService.updateGroup(
        token: widget.token,
        groupId: widget.group.id,
        name: nameController.text,
        description: descriptionController.text,
        city: cityController.text,
        activityType: activityTypeController.text,
      );

      setState(() {
        updatedGroup = savedGroup;
        successMessage = 'Grupa została zaktualizowana.';
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
    nameController.dispose();
    descriptionController.dispose();
    cityController.dispose();
    activityTypeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppGroup groupToShow = updatedGroup ?? widget.group;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edytuj grupę'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Edycja grupy',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Edytujesz grupę ID: ${groupToShow.id}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          buildTextField(
            controller: nameController,
            label: 'Nazwa grupy',
            icon: Icons.groups,
          ),
          const SizedBox(height: 16),
          buildTextField(
            controller: descriptionController,
            label: 'Opis grupy',
            icon: Icons.description,
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          buildTextField(
            controller: cityController,
            label: 'Miasto',
            icon: Icons.location_city,
          ),
          const SizedBox(height: 16),
          buildTextField(
            controller: activityTypeController,
            label: 'Typ aktywności, np. walking, football, cycling',
            icon: Icons.directions_walk,
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
          if (updatedGroup != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Zaktualizowano grupę: ${updatedGroup!.name}\nMiasto: ${updatedGroup!.city}\nTyp: ${updatedGroup!.activityType}',
                ),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: isSaving ? null : updateGroup,
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
              label: const Text('Wróć do szczegółów grupy'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }
}