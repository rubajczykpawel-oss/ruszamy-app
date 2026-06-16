import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/auth_api_service.dart';
import '../services/users_api_service.dart';

class ProfileScreen extends StatefulWidget {
  final String token;

  const ProfileScreen({
    super.key,
    required this.token,
  });

  @override
  State<ProfileScreen> createState() {
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthApiService authApiService = AuthApiService();
  final UsersApiService usersApiService = UsersApiService();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  String errorMessage = '';
  String successMessage = '';

  UserProfile? profile;

  @override
  void initState() {
    super.initState();

    loadProfile();
  }

  Future<void> loadProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      successMessage = '';
    });

    try {
      final UserProfile loadedProfile = await authApiService.getCurrentUser(
        token: widget.token,
      );

      usernameController.text = loadedProfile.username;
      cityController.text = loadedProfile.city ?? '';
      ageController.text = loadedProfile.age?.toString() ?? '';

      setState(() {
        profile = loadedProfile;
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

  Future<void> saveProfile() async {
    setState(() {
      isSaving = true;
      errorMessage = '';
      successMessage = '';
    });

    try {
      final UserProfile updatedProfile = await usersApiService.updateMyProfile(
        token: widget.token,
        username: usernameController.text,
        city: cityController.text,
        age: ageController.text,
      );

      setState(() {
        profile = updatedProfile;
        successMessage = 'Profil został zaktualizowany.';
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

  @override
  void dispose() {
    usernameController.dispose();
    cityController.dispose();
    ageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserProfile? currentProfile = profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mój profil'),
        actions: [
          IconButton(
            onPressed: isLoading ? null : loadProfile,
            icon: const Icon(Icons.refresh),
            tooltip: 'Odśwież',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : currentProfile == null
              ? buildErrorView()
              : buildProfileForm(currentProfile),
    );
  }

  Widget buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          errorMessage.isEmpty
              ? 'Nie udało się pobrać profilu.'
              : errorMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget buildProfileForm(UserProfile profile) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 32,
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.username,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(profile.email),
                      const SizedBox(height: 4),
                      Text('ID użytkownika: ${profile.id}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Edytuj dane',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: usernameController,
          decoration: const InputDecoration(
            labelText: 'Nazwa użytkownika',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: cityController,
          decoration: const InputDecoration(
            labelText: 'Miasto',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_city),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: ageController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Wiek',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.cake),
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
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: isSaving ? null : saveProfile,
            icon: const Icon(Icons.save),
            label: isSaving
                ? const Text('Zapisywanie...')
                : const Text('Zapisz zmiany'),
          ),
        ),
      ],
    );
  }
}