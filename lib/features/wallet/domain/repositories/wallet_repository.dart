import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';

/// Contrato del repositorio. El dominio no sabe si los datos vienen de
/// memoria, Firestore o una API.
abstract interface class WalletRepository {
  Future<WalletSummary> loadSummary();
}
