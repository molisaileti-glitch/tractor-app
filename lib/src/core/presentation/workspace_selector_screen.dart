import 'package:flutter/material.dart';

class WorkspaceSelectorScreen extends StatelessWidget {
  const WorkspaceSelectorScreen({
    super.key,
    required this.onOpenFarmer,
    required this.onOpenOperations,
    required this.onOpenOperator,
    required this.onOpenTechnician,
  });

  final VoidCallback onOpenFarmer;
  final VoidCallback onOpenOperations;
  final VoidCallback onOpenOperator;
  final VoidCallback onOpenTechnician;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shamba Bora',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('Choose a workspace for this offline prototype.'),
                  const SizedBox(height: 22),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cards = [
                        _WorkspaceCard(
                          icon: Icons.person_outline,
                          title: 'Farmer App',
                          subtitle:
                              'Register plots, request service and confirm work.',
                          onTap: onOpenFarmer,
                        ),
                        _WorkspaceCard(
                          icon: Icons.dashboard_outlined,
                          title: 'Union Operations',
                          subtitle:
                              'Review requests, schedule tractors and monitor jobs.',
                          onTap: onOpenOperations,
                        ),
                        _WorkspaceCard(
                          icon: Icons.agriculture_outlined,
                          title: 'Operator App',
                          subtitle:
                              'Receive jobs, navigate, verify location and complete work.',
                          onTap: onOpenOperator,
                        ),
                        _WorkspaceCard(
                          icon: Icons.home_repair_service_outlined,
                          title: 'Technician',
                          subtitle:
                              'Manage tractor maintenance, repairs, history and parts.',
                          onTap: onOpenTechnician,
                        ),
                      ];
                      final columns = constraints.maxWidth >= 760 ? 2 : 1;
                      final width =
                          (constraints.maxWidth - (columns - 1) * 12) / columns;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final card in cards)
                            SizedBox(width: width, child: card),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkspaceCard extends StatelessWidget {
  const _WorkspaceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.12),
                child: Icon(icon),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(subtitle),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    'Open',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
