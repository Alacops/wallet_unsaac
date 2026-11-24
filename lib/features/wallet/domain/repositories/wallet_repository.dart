import 'package:wallet_unsaac/features/wallet/domain/entities/movement.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';

/// Contrato de la capa de datos.
///
/// La presentación y el dominio dependen de esta abstracción, nunca de una
/// implementación concreta. En la Sesión 2 la implementación sigue siendo en
/// memoria; en la Sesión 5 se sustituirá por Firestore sin tocar la interfaz.
///
/// Cada operación devuelve el resumen actualizado. Esa decisión mantiene el
/// bloc libre de cálculos y permite probar el repositorio por separado.
abstract interface class WalletRepository {
  /// Lee el resumen completo de la billetera.
  Future<WalletSummary> loadSummary();

  /// Registra un movimiento y devuelve el resumen resultante.
  Future<WalletSummary> addMovement(Movement movement);

  /// Reemplaza un movimiento existente por su versión editada, sin cambiar su
  /// posición, y devuelve el resumen resultante (Reto 1). Si el identificador
  /// no existe, la operación no falla: es idempotente.
  Future<WalletSummary> updateMovement(Movement movement);

  /// Elimina el movimiento indicado y devuelve el resumen resultante.
  ///
  /// Si el identificador no existe, la operación no falla: es idempotente.
  Future<WalletSummary> removeMovement(String movementId);

  /// Vacía el historial y devuelve el resumen resultante.
  Future<WalletSummary> clearMovements();
}
