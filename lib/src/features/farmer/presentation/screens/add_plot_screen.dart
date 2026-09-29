import 'package:flutter/material.dart';
import '../../data/repositories/farmer_local_repository.dart';
import '../../domain/entities/farm_plot.dart';
import '../widgets/farm_map_card.dart';
import '../widgets/farmer_scaffold.dart';
import 'plot_detail_screen.dart';

class AddPlotScreen extends StatefulWidget {
  const AddPlotScreen({super.key, required this.repository});

  final FarmerLocalRepository repository;

  @override
  State<AddPlotScreen> createState() => _AddPlotScreenState();
}

class _AddPlotScreenState extends State<AddPlotScreen> {
  final _nameController = TextEditingController(text: 'New Farm Plot');
  final _locationController = TextEditingController(text: 'Kibaha, Pwani');
  int _step = 0;
  int _points = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FarmerPage(
      title: 'Add Farm Plot',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepStrip(currentStep: _step),
          const SizedBox(height: 20),
          if (_step == 0) _locateStep(),
          if (_step == 1) _boundaryStep(),
          if (_step == 2) _confirmStep(),
        ],
      ),
    );
  }

  Widget _locateStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How would you like to locate your farm?',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 16),
        _ChoiceCard(
          icon: Icons.my_location,
          title: "I'm currently at my farm",
          subtitle: "Use my phone's GPS",
          onTap: () => setState(() => _step = 1),
        ),
        const SizedBox(height: 12),
        _ChoiceCard(
          icon: Icons.map_outlined,
          title: 'Select location on map',
          subtitle: 'Find the farm manually',
          onTap: () => setState(() => _step = 1),
        ),
      ],
    );
  }

  Widget _boundaryStep() {
    final ready = _points >= 4;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mark Farm Boundary',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        FarmMapCard(pointCount: _points),
        const SizedBox(height: 16),
        const Text('Walk to each corner of your farm and mark the boundary.'),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: ready ? null : () => setState(() => _points++),
          icon: const Icon(Icons.add_location),
          label: const Text('Mark Current Point'),
        ),
        const SizedBox(height: 14),
        Text('$_points boundary points recorded'),
        const SizedBox(height: 6),
        Text('Estimated area: ${_estimatedArea.toStringAsFixed(1)} hectares'),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: ready ? () => setState(() => _step = 2) : null,
          icon: const Icon(Icons.check),
          label: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _confirmStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm Plot Details',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Farm name'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _locationController,
          decoration: const InputDecoration(labelText: 'Location'),
        ),
        const SizedBox(height: 12),
        InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Area'),
              const SizedBox(height: 4),
              Text(
                '${_estimatedArea.toStringAsFixed(1)} hectares',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text('Coordinates registered'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: _savePlot,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save Plot'),
        ),
      ],
    );
  }

  double get _estimatedArea => _points < 4 ? _points * 0.9 : 4.2;

  void _savePlot() {
    final points = List.generate(
      4,
      (index) => BoundaryPoint(
        label: 'Point ${index + 1}',
        latitude: -6.80 - (index * 0.002),
        longitude: 38.91 + (index * 0.003),
      ),
    );
    final plotId = widget.repository.addPlot(
      name: _nameController.text.trim().isEmpty
          ? 'New Farm Plot'
          : _nameController.text.trim(),
      location: _locationController.text.trim().isEmpty
          ? 'Kibaha, Pwani'
          : _locationController.text.trim(),
      areaHectares: _estimatedArea,
      boundaryPoints: points,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            PlotDetailScreen(repository: widget.repository, plotId: plotId),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
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
    return InfoCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepStrip extends StatelessWidget {
  const _StepStrip({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        final active = index <= currentStep;
        return Expanded(
          child: Container(
            height: 5,
            margin: EdgeInsets.only(right: index == 2 ? 0 : 6),
            decoration: BoxDecoration(
              color: active
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        );
      }),
    );
  }
}
