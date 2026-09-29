import 'package:flutter/material.dart';

import '../../data/repositories/farmer_local_repository.dart';
import '../widgets/farmer_scaffold.dart';
import '../widgets/plot_card.dart';
import 'add_plot_screen.dart';
import 'plot_detail_screen.dart';

class PlotsScreen extends StatelessWidget {
  const PlotsScreen({super.key, required this.repository});

  final FarmerLocalRepository repository;

  @override
  Widget build(BuildContext context) {
    return FarmerPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Plots',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          for (final plot in repository.plots) ...[
            PlotCard(
              plot: plot,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      PlotDetailScreen(repository: repository, plotId: plot.id),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddPlotScreen(repository: repository),
              ),
            ),
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Add New Plot'),
          ),
        ],
      ),
    );
  }
}
