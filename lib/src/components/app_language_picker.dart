import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import 'app_dialogs.dart';

Future<Locale?> showAppLanguagePicker(
  BuildContext context, {
  required Locale selectedLocale,
}) {
  return showModalBottomSheet<Locale>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _AppLanguagePickerSheet(selectedLocale: selectedLocale),
  );
}

class _AppLanguagePickerSheet extends StatefulWidget {
  const _AppLanguagePickerSheet({required this.selectedLocale});

  final Locale selectedLocale;

  @override
  State<_AppLanguagePickerSheet> createState() =>
      _AppLanguagePickerSheetState();
}

class _AppLanguagePickerSheetState extends State<_AppLanguagePickerSheet> {
  late Locale _selection;

  @override
  void initState() {
    super.initState();
    _selection = widget.selectedLocale;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.language,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              strings.selectAppLanguage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            _LanguageOption(
              flag: '🇬🇧',
              title: strings.english,
              selected: _selection.languageCode == 'en',
              onTap: () => setState(() => _selection = const Locale('en')),
            ),
            const SizedBox(height: 10),
            _LanguageOption(
              flag: '🇹🇿',
              title: strings.swahili,
              selected: _selection.languageCode == 'sw',
              onTap: () => setState(() => _selection = const Locale('sw')),
            ),
            const SizedBox(height: 20),
            AppDialogActions(
              onCancel: () => Navigator.of(context).pop(),
              onConfirm: () => Navigator.of(context).pop(_selection),
              cancelLabel: strings.cancel,
              confirmLabel: strings.ok,
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.flag,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String flag;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colors.primaryContainer : colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? colors.primary : colors.outlineVariant,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 30)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
