import 'package:flutter/material.dart';

class AppHorizontalStepper extends StatelessWidget {
  const AppHorizontalStepper({
    super.key,
    required this.currentStep,
    required this.steps,
    required this.canContinue,
    this.onStepTapped,
    this.onStepContinue,
    this.onStepBack,
    this.hideControlsOnLastStep = true,
  });

  final int currentStep;
  final List<Step> steps;
  final bool canContinue;
  final ValueChanged<int>? onStepTapped;
  final VoidCallback? onStepContinue;
  final VoidCallback? onStepBack;
  final bool hideControlsOnLastStep;

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final safeStep = currentStep.clamp(0, steps.length - 1);
    final isLastStep = safeStep == steps.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (var index = 0; index < steps.length; index++) ...[
              if (index > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    color: index <= safeStep
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                  ),
                ),
              _StepIndicator(
                index: index,
                selected: index == safeStep,
                complete:
                    index < safeStep || steps[index].state == StepState.complete,
                onTap: onStepTapped == null
                    ? null
                    : () => onStepTapped!(index),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < steps.length; index++)
              Expanded(
                child: InkWell(
                  onTap: onStepTapped == null
                      ? null
                      : () => onStepTapped!(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: DefaultTextStyle.merge(
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: index <= safeStep
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                      child: steps[index].title,
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (steps[safeStep].subtitle case final subtitle?) ...[
          const SizedBox(height: 10),
          DefaultTextStyle.merge(
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            child: subtitle,
          ),
        ],
        const SizedBox(height: 20),
        KeyedSubtree(
          key: ValueKey(safeStep),
          child: steps[safeStep].content,
        ),
        if (!(hideControlsOnLastStep && isLastStep))
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Row(
              children: [
                if (safeStep > 0) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onStepBack,
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: canContinue ? onStepContinue : null,
                    child: const Text('Next'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.index,
    required this.selected,
    required this.complete,
    this.onTap,
  });

  final int index;
  final bool selected;
  final bool complete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final active = selected || complete;

    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? colorScheme.primary : colorScheme.surfaceContainer,
          border: Border.all(
            color: active ? colorScheme.primary : colorScheme.outlineVariant,
          ),
        ),
        alignment: Alignment.center,
        child: complete
            ? Icon(Icons.check, size: 18, color: colorScheme.onPrimary)
            : Text(
                '${index + 1}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: active
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
