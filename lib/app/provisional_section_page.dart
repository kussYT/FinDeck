import 'package:findeck/app/theme.dart';
import 'package:flutter/material.dart';

/// Présentation commune des trois écrans du socle.
///
/// Elle disparaîtra lorsque chaque espace aura son contenu réel.
class ProvisionalSectionPage extends StatelessWidget {
  const ProvisionalSectionPage({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>() ?? AppSpacing.standard;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          spacing.lg,
          spacing.xl,
          spacing.lg,
          spacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.headlineMedium),
            SizedBox(height: spacing.md),
            Text(message, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
