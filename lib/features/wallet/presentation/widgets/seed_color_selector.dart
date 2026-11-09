import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/core/theme/app_theme.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';

/// Selector de color semilla (Reto 4). Cada punto usa `BlocSelector` para
/// reconstruir solo su indicador de selección cuando cambia el color activo.
class SeedColorSelector extends StatelessWidget {
  const SeedColorSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color del tema',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'El cambio recalcula toda la paleta con ColorScheme.fromSeed.',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final color in AppTheme.seeds) _SeedDot(color: color),
          ],
        ),
      ],
    );
  }
}

class _SeedDot extends StatelessWidget {
  const _SeedDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ThemeCubit, ThemeState, bool>(
      selector: (state) => state.seedColor == color,
      builder: (context, selected) {
        final borderColor = selected
            ? Theme.of(context).colorScheme.onSurface
            : Colors.transparent;
        return Semantics(
          button: true,
          selected: selected,
          label: 'Color semilla',
          child: GestureDetector(
            onTap: () => context.read<ThemeCubit>().setSeedColor(color),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 3),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 22)
                  : null,
            ),
          ),
        );
      },
    );
  }
}
