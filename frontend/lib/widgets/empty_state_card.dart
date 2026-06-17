import 'package:flutter/material.dart';

class EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onPressed;

  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              icon,
              size: 70,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade800,
              ),
            ),
            if (buttonText != null && onPressed != null)
              const SizedBox(height: 18),
            if (buttonText != null && onPressed != null)
              SizedBox(
                height: 44,
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onPressed,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(buttonText!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}