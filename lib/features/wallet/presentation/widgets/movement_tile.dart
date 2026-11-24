import 'package:flutter/material.dart';
import 'package:wallet_unsaac/core/utils/money.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/movement.dart';

/// Fila de un movimiento financiero.
///
/// Recibe [hideAmount]; cuando está activo enmascara el importe. Si se entrega
/// [onDelete], muestra un botón para eliminar el movimiento. La fila no habla
/// con el repositorio ni con el bloc: solo invoca el callback que recibe.
class MovementTile extends StatelessWidget {
  const MovementTile({
    super.key,
    required this.movement,
    this.hideAmount = false,
    this.onDelete,
  });

  final Movement movement;
  final bool hideAmount;
  final VoidCallback? onDelete;

  static const Color _incomeLight = Color(0xFF2E7D32);
  static const Color _incomeDark = Color(0xFF81C784);
  static const String _mask = '••••';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = movement.isIncome
        ? (isDark ? _incomeDark : _incomeLight)
        : scheme.error;

    final sign = movement.isIncome ? '+' : '-';
    final trailing =
        hideAmount ? _mask : '$sign ${MoneyFormat.soles(movement.amount)}';

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: accent.withValues(alpha: 0.12),
          child: Icon(
            movement.isIncome
                ? Icons.south_west_rounded
                : Icons.north_east_rounded,
            color: accent,
            size: 20,
          ),
        ),
        title: Text(
          movement.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${movement.category} · ${formatShortDate(movement.date)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              trailing,
              style: TextStyle(color: accent, fontWeight: FontWeight.w600),
            ),
            if (onDelete != null)
              IconButton(
                tooltip: 'Eliminar movimiento',
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
