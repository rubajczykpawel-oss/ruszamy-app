import 'package:flutter/material.dart';

import '../services/auth_api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/message_card.dart';
import '../widgets/primary_action_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
  });

  @override
  State<RegisterScreen> createState() {
    return _RegisterScreenState();
  }
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthApiService authApiService = AuthApiService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  String errorMessage = '';
  String successMessage = '';

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    cityController.dispose();
    ageController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  int? parseAge() {
    final String ageText = ageController.text.trim();

    if (ageText.isEmpty) {
      return null;
    }

    return int.tryParse(ageText);
  }

  bool validateForm() {
    final String email = emailController.text.trim();
    final String username = usernameController.text.trim();
    final String ageText = ageController.text.trim();
    final String password = passwordController.text.trim();
    final String confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty) {
      showError('Wpisz adres e-mail.');
      return false;
    }

    if (!email.contains('@')) {
      showError('Adres e-mail wygląda niepoprawnie.');
      return false;
    }

    if (username.isEmpty) {
      showError('Wpisz nazwę użytkownika.');
      return false;
    }

    if (username.length < 3) {
      showError('Nazwa użytkownika powinna mieć minimum 3 znaki.');
      return false;
    }

    if (ageText.isNotEmpty) {
      final int? age = int.tryParse(ageText);

      if (age == null) {
        showError('Wiek musi być liczbą.');
        return false;
      }

      if (age < 1 || age > 120) {
        showError('Wiek musi być w zakresie od 1 do 120.');
        return false;
      }
    }

    if (password.isEmpty) {
      showError('Wpisz hasło.');
      return false;
    }

    if (password.length < 4) {
      showError('Hasło powinno mieć minimum 4 znaki.');
      return false;
    }

    if (confirmPassword.isEmpty) {
      showError('Powtórz hasło.');
      return false;
    }

    if (password != confirmPassword) {
      showError('Hasła nie są takie same.');
      return false;
    }

    return true;
  }

  void showError(String message) {
    setState(() {
      errorMessage = message;
      successMessage = '';
    });
  }

  Future<void> register() async {
    if (!validateForm()) {
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
      successMessage = '';
    });

    try {
      await authApiService.register(
        email: emailController.text.trim(),
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
        city: cityController.text.trim().isEmpty
            ? null
            : cityController.text.trim(),
        age: parseAge(),
      );

      setState(() {
        successMessage =
            'Konto zostało utworzone. Za chwilę wrócisz do logowania.';
      });

      await Future.delayed(const Duration(milliseconds: 900));

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
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

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  void toggleConfirmPasswordVisibility() {
    setState(() {
      isConfirmPasswordVisible = !isConfirmPasswordVisible;
    });
  }

  void backToLogin() {
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          buildBackgroundDecoration(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: buildRegisterCard(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBackgroundDecoration() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.sportBlue,
              AppColors.primary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -50,
              top: 40,
              child: Icon(
                Icons.sports_basketball,
                size: 220,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            Positioned(
              left: -40,
              bottom: 50,
              child: Icon(
                Icons.directions_bike,
                size: 210,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            Positioned(
              right: 40,
              bottom: 80,
              child: Icon(
                Icons.sports_soccer,
                size: 150,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRegisterCard() {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildLogo(),
            const SizedBox(height: 18),
            buildTitle(),
            const SizedBox(height: 24),
            buildRegisterForm(),
            const SizedBox(height: 16),
            buildBackToLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget buildLogo() {
    return const CircleAvatar(
      radius: 46,
      backgroundColor: AppColors.sportBlueLight,
      child: Icon(
        Icons.person_add,
        size: 52,
        color: AppColors.sportBlue,
      ),
    );
  }

  Widget buildTitle() {
    return Column(
      children: [
        const Text(
          'Utwórz konto',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Dołącz do Ruszamy App i zacznij tworzyć sportowe wydarzenia.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget buildRegisterForm() {
    return Column(
      children: [
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [
            AutofillHints.email,
          ],
          decoration: const InputDecoration(
            labelText: 'E-mail',
            hintText: 'np. test@example.com',
            prefixIcon: Icon(Icons.email),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: usernameController,
          textInputAction: TextInputAction.next,
          autofillHints: const [
            AutofillHints.username,
          ],
          decoration: const InputDecoration(
            labelText: 'Nazwa użytkownika',
            hintText: 'np. pawel',
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: cityController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Miasto',
            hintText: 'np. Wrocław',
            prefixIcon: Icon(Icons.location_city),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: ageController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Wiek',
            hintText: 'np. 25',
            prefixIcon: Icon(Icons.cake),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: passwordController,
          obscureText: !isPasswordVisible,
          textInputAction: TextInputAction.next,
          autofillHints: const [
            AutofillHints.newPassword,
          ],
          decoration: InputDecoration(
            labelText: 'Hasło',
            hintText: 'Wpisz hasło',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              tooltip: isPasswordVisible ? 'Ukryj hasło' : 'Pokaż hasło',
              onPressed: togglePasswordVisibility,
              icon: Icon(
                isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: confirmPasswordController,
          obscureText: !isConfirmPasswordVisible,
          textInputAction: TextInputAction.done,
          autofillHints: const [
            AutofillHints.newPassword,
          ],
          decoration: InputDecoration(
            labelText: 'Powtórz hasło',
            hintText: 'Wpisz hasło ponownie',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              tooltip:
                  isConfirmPasswordVisible ? 'Ukryj hasło' : 'Pokaż hasło',
              onPressed: toggleConfirmPasswordVisibility,
              icon: Icon(
                isConfirmPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.primary,
              ),
            ),
          ),
          onSubmitted: (_) {
            register();
          },
        ),
        const SizedBox(height: 16),
        if (errorMessage.isNotEmpty)
          MessageCard(
            message: errorMessage,
            isError: true,
          ),
        if (successMessage.isNotEmpty)
          MessageCard(
            message: successMessage,
            isError: false,
          ),
        if (errorMessage.isNotEmpty || successMessage.isNotEmpty)
          const SizedBox(height: 12),
        PrimaryActionButton(
          icon: Icons.person_add,
          label: 'Utwórz konto',
          loadingLabel: 'Tworzenie konta...',
          isLoading: isLoading,
          onPressed: register,
        ),
      ],
    );
  }

  Widget buildBackToLoginButton() {
    return SizedBox(
      height: 46,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : backToLogin,
        icon: const Icon(Icons.arrow_back),
        label: const Text('Mam już konto'),
      ),
    );
  }
}