import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubits/privacy_state.dart';

/// Oculta o muestra los importes sin recargar la pantalla ni tocar los datos
/// (Reto 2).
class PrivacyCubit extends Cubit<PrivacyState> {
  PrivacyCubit() : super(const PrivacyState());

  void toggle() => emit(state.copyWith(hidden: !state.hidden));
}
