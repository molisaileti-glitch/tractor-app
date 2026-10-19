import 'package:flutter/material.dart';

import '../../../components/components.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../application/app_preferences_controller.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({
    super.key,
    required this.preferences,
    required this.name,
    required this.role,
    this.email,
    this.showTitle = true,
    this.onThemeChanged,
  });

  final AppPreferencesController preferences;
  final String name;
  final String role;
  final String? email;
  final bool showTitle;
  final Future<void> Function(BuildContext origin, bool enabled)?
  onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return AnimatedBuilder(
      animation: preferences,
      builder: (context, _) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showTitle) ...[
              Text(
                strings.settings,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 18),
            ],
            _Section(
              title: strings.account,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: const Icon(Icons.person_outline),
                ),
                title: Text(name),
                subtitle: Text(
                  [role, email]
                      .where(
                        (value) => value != null && value.trim().isNotEmpty,
                      )
                      .join('\n'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: strings.appearance,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.dark_mode_outlined),
                    title: Text(strings.darkMode),
                    subtitle: Text(strings.darkModeDescription),
                    trailing: Builder(
                      builder: (switchContext) => Switch(
                        value: Theme.of(context).brightness == Brightness.dark,
                        onChanged: (enabled) async {
                          final callback = onThemeChanged;
                          if (callback != null) {
                            await callback(switchContext, enabled);
                            return;
                          }
                          await showAppThemeReveal(
                            switchContext,
                            color: enabled
                                ? AppColors.darkBackground
                                : AppColors.pageBackground,
                            onCovered: () => preferences.setDarkMode(enabled),
                          );
                        },
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.language_outlined),
                    title: Text(strings.language),
                    subtitle: Text(
                      preferences.usesSwahili
                          ? strings.swahili
                          : strings.english,
                    ),
                    value: preferences.usesSwahili,
                    onChanged: preferences.setSwahili,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
