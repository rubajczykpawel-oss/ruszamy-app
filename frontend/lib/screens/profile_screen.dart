import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/user_profile.dart';
import '../services/auth_api_service.dart';
import '../widgets/info_chip.dart';

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

  @override
  void dispose() {
    usernameController.dispose();
    cityController.dispose();
    ageController.dispose();

    super.dispose();
  }

  Future<void> loadProfile({
    bool clearMessages = true,
  }) async {
    setState(() {
      isLoading = true;
      errorMessage = '';

      if (clearMessages) {
        successMessage = '';
      }
    });

    try {
      final UserProfile loadedProfile = await authApiService.getCurrentUser(
        token: widget.token,
      );

      setState(() {
        profile = loadedProfile;

        usernameController.text = loadedProfile.username;
        cityController.text = loadedProfile.city ?? '';
        ageController.text = loadedProfile.age?.toString() ?? '';
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

  int? parseAge() {
    final String ageText = ageController.text.trim();

    if (ageText.isEmpty) {
      return null;
    }

    return int.tryParse(ageText);
  }

  bool validateForm() {
    final String username = usernameController.text.trim();
    final String ageText = ageController.text.trim();

    if (username.isEmpty) {
      setState(() {
        errorMessage = 'Nazwa użytkownika nie może być pusta.';
        successMessage = '';
      });

      return false;
    }

    if (ageText.isNotEmpty) {
      final int? age = int.tryParse(ageText);

      if (age == null) {
        setState(() {
          errorMessage = 'Wiek musi być liczbą.';
          successMessage = '';
        });

        return false;
      }

      if (age < 1 || age > 120) {
        setState(() {
          errorMessage = 'Wiek musi być w zakresie od 1 do 120.';
          successMessage = '';
        });

        return false;
      }
    }

    return true;
  }

  Future<void> saveProfile() async {
    final UserProfile? currentProfile = profile;

    if (currentProfile == null) {
      return;
    }

    if (!validateForm()) {
      return;
    }

    setState(() {
      isSaving = true;
      errorMessage = '';
      successMessage = '';
    });

    try {
      final Map<String, dynamic> body = {
        'username': usernameController.text.trim(),
        'city': cityController.text.trim().isEmpty
            ? null
            : cityController.text.trim(),
        'age': parseAge(),
      };

      final http.Response response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          successMessage = 'Profil został zapisany.';
        });

        await loadProfile(clearMessages: false);
      } else {
        final dynamic decodedBody = jsonDecode(response.body);

        final String detail = decodedBody is Map<String, dynamic>
            ? decodedBody['detail'].toString()
            : response.body;

        setState(() {
          errorMessage = detail;
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

  String buildCityText(UserProfile profile) {
    return profile.city ?? 'Nie ustawiono miasta';
  }

  String buildAgeText(UserProfile profile) {
    if (profile.age == null) {
      return 'Nie ustawiono wieku';
    }

    return '${profile.age} lat';
  }

  String buildInitial(UserProfile profile) {
    if (profile.username.trim().isEmpty) {
      return '?';
    }

    return profile.username.trim().characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final UserProfile? currentProfile = profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mój profil'),
        actions: [
          IconButton(
            onPressed: isLoading
                ? null
                : () {
                    loadProfile();
                  },
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
              : buildProfileContent(currentProfile),
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

  Widget buildProfileContent(UserProfile profile) {
    return RefreshIndicator(
      onRefresh: () {
        return loadProfile();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildHeaderCard(profile),
          const SizedBox(height: 16),
          buildMessages(),
          buildStatsGrid(profile),
          const SizedBox(height: 16),
          buildProfileInfoCard(profile),
          const SizedBox(height: 16),
          buildEditProfileCard(profile),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget buildHeaderCard(UserProfile profile) {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isNarrow = constraints.maxWidth < 560;

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildAvatar(profile),
                  const SizedBox(height: 16),
                  buildHeaderText(profile),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildAvatar(profile),
                const SizedBox(width: 18),
                Expanded(
                  child: buildHeaderText(profile),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildAvatar(UserProfile profile) {
    return CircleAvatar(
      radius: 46,
      backgroundColor: Colors.orange.shade100,
      child: Text(
        buildInitial(profile),
        style: const TextStyle(
          fontSize: 38,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildHeaderText(UserProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          profile.username,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          profile.email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            InfoChip(
              icon: Icons.badge,
              label: 'ID: ${profile.id}',
            ),
            InfoChip(
              icon: Icons.location_city,
              label: buildCityText(profile),
            ),
            InfoChip(
              icon: Icons.cake,
              label: buildAgeText(profile),
            ),
          ],
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

  Widget buildStatsGrid(UserProfile profile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth;

        if (constraints.maxWidth >= 760) {
          cardWidth = (constraints.maxWidth - 24) / 3;
        } else {
          cardWidth = constraints.maxWidth;
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: cardWidth,
              child: buildStatCard(
                icon: Icons.person,
                value: profile.username,
                title: 'Nazwa',
                subtitle: 'Twoja nazwa w aplikacji',
                color: Colors.blue.shade50,
                iconColor: Colors.blue,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: buildStatCard(
                icon: Icons.location_city,
                value: profile.city ?? '-',
                title: 'Miasto',
                subtitle: 'Lokalizacja profilu',
                color: Colors.green.shade50,
                iconColor: Colors.green,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: buildStatCard(
                icon: Icons.cake,
                value: profile.age?.toString() ?? '-',
                title: 'Wiek',
                subtitle: 'Dane opcjonalne',
                color: Colors.orange.shade50,
                iconColor: Colors.orange,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildStatCard({
    required IconData icon,
    required String value,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
  }) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                icon,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfileInfoCard(UserProfile profile) {
    return Card(
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildSectionHeader(
              icon: Icons.info,
              title: 'Dane profilu',
              subtitle: 'Podstawowe dane widoczne w aplikacji.',
            ),
            const SizedBox(height: 12),
            buildInfoRow(
              icon: Icons.badge,
              label: 'ID użytkownika',
              value: profile.id.toString(),
            ),
            const Divider(),
            buildInfoRow(
              icon: Icons.email,
              label: 'Email',
              value: profile.email,
            ),
            const Divider(),
            buildInfoRow(
              icon: Icons.person,
              label: 'Nazwa',
              value: profile.username,
            ),
            const Divider(),
            buildInfoRow(
              icon: Icons.location_city,
              label: 'Miasto',
              value: buildCityText(profile),
            ),
            const Divider(),
            buildInfoRow(
              icon: Icons.cake,
              label: 'Wiek',
              value: buildAgeText(profile),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEditProfileCard(UserProfile profile) {
    return Card(
      color: Colors.indigo.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildSectionHeader(
              icon: Icons.edit,
              title: 'Edytuj profil',
              subtitle:
                  'Zmień nazwę użytkownika, miasto albo wiek. Email zostaje tylko do odczytu.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Nazwa użytkownika',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              enabled: false,
              controller: TextEditingController(text: profile.email),
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: 'Miasto',
                hintText: 'np. Wrocław',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Wiek',
                hintText: 'np. 30',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cake),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 46,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isSaving ? null : saveProfile,
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: isSaving
                    ? const Text('Zapisywanie...')
                    : const Text('Zapisz profil'),
              ),
            ),
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