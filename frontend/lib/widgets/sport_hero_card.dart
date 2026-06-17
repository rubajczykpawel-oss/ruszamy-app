import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SportHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final IconData icon;
  final VoidCallback onPressed;

  const SportHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.sportBlue,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -28,
              top: -28,
              child: Icon(
                Icons.sports_soccer,
                size: 150,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
            Positioned(
              right: 34,
              bottom: -24,
              child: Icon(
                Icons.directions_run,
                size: 130,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isNarrow = constraints.maxWidth < 560;

                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildIcon(),
                        const SizedBox(height: 16),
                        buildText(),
                        const SizedBox(height: 18),
                        buildButton(),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      buildIcon(),
                      const SizedBox(width: 18),
                      Expanded(
                        child: buildText(),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 190,
                        child: buildButton(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildIcon() {
    return CircleAvatar(
      radius: 42,
      backgroundColor: Colors.white.withValues(alpha: 0.18),
      child: Icon(
        icon,
        size: 44,
        color: Colors.white,
      ),
    );
  }

  Widget buildText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 31,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.88),
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget buildButton() {
    return SizedBox(
      height: 46,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
        ),
        icon: const Icon(Icons.add),
        label: Text(buttonText),
      ),
    );
  }
}