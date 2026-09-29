import 'package:flutter/material.dart';

import '../../data/repositories/technician_local_repository.dart';
import '../widgets/technician_widgets.dart';

class TechnicianPartsScreen extends StatelessWidget {
  const TechnicianPartsScreen({
    super.key,
    required this.technicianRepository,
    required this.onSwitchWorkspace,
  });

  final TechnicianLocalRepository technicianRepository;
  final VoidCallback onSwitchWorkspace;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Parts',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              for (final part in technicianRepository.parts) ...[
                TechnicianCard(
                  child: Row(
                    children: [
                      Icon(
                        part.needsReorder
                            ? Icons.warning_amber_outlined
                            : Icons.inventory_2_outlined,
                        color: part.needsReorder
                            ? Theme.of(context).colorScheme.secondary
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              part.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            Text('${part.stock} ${part.unit} in stock'),
                          ],
                        ),
                      ),
                      if (part.needsReorder)
                        const Text(
                          'Reorder',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onSwitchWorkspace,
                icon: const Icon(Icons.switch_account_outlined),
                label: const Text('Switch Workspace'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
