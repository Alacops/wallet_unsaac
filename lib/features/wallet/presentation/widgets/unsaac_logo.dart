import 'package:flutter/material.dart';
import 'package:wallet_unsaac/core/config/app_profile.dart';

/// Muestra el escudo oficial de la UNSAAC desde `assets/`.
///
/// Si el archivo no estuviera disponible, degrada con elegancia a un monograma
/// con las iniciales, de modo que la interfaz nunca se rompe por un asset que
/// falte.
class UnsaacLogo extends StatelessWidget {
  const UnsaacLogo({super.key, this.size = 40});

  final double size;

  /// Alto real del PNG del escudo (`assets/images/escudo_unsaac.png`).
  static const int _sourceHeight = 675;

  @override
  Widget build(BuildContext context) {
    // Decodifica la imagen a una resolución acorde a la densidad de la pantalla
    // (con holgura ×2) en lugar de reescalar el bitmap completo al dibujar: así
    // el escudo se ve nítido y no borroso, sobre todo en Flutter web.
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;
    final decodeHeight = (size * dpr * 2).round().clamp(1, _sourceHeight);

    return Image.asset(
      AppProfile.crestAsset,
      height: size,
      width: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      cacheHeight: decodeHeight,
      errorBuilder: (context, error, stackTrace) => _MonogramFallback(size: size),
    );
  }
}

/// Respaldo visual cuando el escudo no está disponible.
class _MonogramFallback extends StatelessWidget {
  const _MonogramFallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Text(
        AppProfile.initials,
        style: TextStyle(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.38,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
