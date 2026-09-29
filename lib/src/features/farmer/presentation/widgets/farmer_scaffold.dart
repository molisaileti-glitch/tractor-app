import 'package:flutter/material.dart';

class FarmerPage extends StatelessWidget {
  const FarmerPage({
    super.key,
    this.title,
    this.actions,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 24),
  });

  final String? title;
  final List<Widget>? actions;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      padding: padding,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: child,
      ),
    );

    if (title == null) {
      return Align(alignment: Alignment.topCenter, child: content);
    }

    return Scaffold(
      appBar: AppBar(title: Text(title!), actions: actions),
      body: Align(alignment: Alignment.topCenter, child: content),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );

    if (onTap == null) return card;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: card,
    );
  }
}
