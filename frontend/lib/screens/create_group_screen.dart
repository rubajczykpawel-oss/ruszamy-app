import 'package:flutter/material.dart';

import '../models/app_group.dart';
import '../services/groups_api_service.dart';

class CreateGroupScreen extends StatefulWidget {
  final String token;

  const CreateGroupScreen({
    super.key,
    required this.token,
  });

  @override
  State<CreateGroupScreen> createState() {
    return _CreateGroupScreenState();
  }
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final GroupsApiService groupsApiService = GroupsApiService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController activityTypeController = TextEditingController();

  bool isSaving = false;

  String errorMessage = '';
  String successMessage = '';

  AppGroup? createdGroup;

  @override
  void initState() {
    super.initState();

    cityController.text = 'Wrocław';
    activityTypeController.text = 'walking';
  }

  Future<void> createGroup() async {
    setState(() {
      isSaving = true;
      errorMessage = '';
      successMessage = '';
      createdGroup = null;
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
      final AppGroup newGroup = await groupsApiService.createGroup(
        token: widget.token,
        name: nameController.text,
        description: descriptionController.text,
        city: cityController.text,
        activityType: activityTypeController.text,
      );

      setState(() {
        createdGroup = newGroup;
        successMessage = 'Grupa została utworzona.';
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
    nameController.clear();
    descriptionController.clear();

    cityController.text = 'Wrocław';
    activityTypeController.text = 'walking';

    setState(() {
      errorMessage = '';
      successMessage = '';
      createdGroup = null;
    });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj grupę'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Nowa grupa',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Utwórz grupę bez używania Swaggera.',
            style: TextStyle(fontSize: 16),
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
          if (createdGroup != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Utworzono grupę: ${createdGroup!.name}\nID: ${createdGroup!.id}',
                ),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: isSaving ? null : createGroup,
              icon: const Icon(Icons.add),
              label: isSaving
                  ? const Text('Tworzenie...')
                  : const Text('Utwórz grupę'),
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
            'Przykładowe dane:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text('Nazwa: Walking Wroclaw'),
          const Text('Opis: Grupa dla osób, które chcą spacerować po mieście.'),
          const Text('Miasto: Wrocław'),
          const Text('Typ aktywności: walking'),
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