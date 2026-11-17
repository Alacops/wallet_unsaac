/// Datos del estudiante y del curso que la interfaz muestra en un solo lugar.
///
/// Centralizar la información aquí evita repartir cadenas por toda la app: para
/// personalizarla basta editar este archivo. La cabecera, el pie y la tarjeta
/// de identidad leen estas constantes.
abstract final class AppProfile {
  // --- Datos del estudiante -------------------------------------------------

  /// Nombre completo que aparece en el saludo de la pantalla principal.
  static const String studentName = 'Alain Armando Condori Contreras';

  /// Código de alumno (derivado del correo institucional 021501@unsaac.edu.pe).
  static const String studentCode = '021501';

  /// Correo institucional.
  static const String studentEmail = '021501@unsaac.edu.pe';

  /// Escuela Profesional.
  static const String school =
      'Escuela Profesional de Ingeniería Informática y de Sistemas';

  // --- Datos del curso ------------------------------------------------------

  static const String courseName = 'Desarrollo de Software II';
  static const String courseCode = 'IF616BIN';
  static const String teacher = 'Mtro. Ing. Yover Collantes Valer';
  static const String semester = '2026-II';
  static const String unit = 'Unidad Didáctica II · Sesión 1';

  // --- Identidad de la app --------------------------------------------------

  static const String appName = 'Wallet UNSAAC';
  static const String appVersion = '1.0.0';

  /// Ruta del escudo oficial de la UNSAAC. Coloca el archivo en esa ruta y la
  /// app lo mostrará automáticamente; mientras no exista se usa un monograma.
  static const String crestAsset = 'assets/images/escudo_unsaac.png';

  // --- Derivados ------------------------------------------------------------

  /// Indica si todavía no se personalizó el nombre del estudiante.
  static bool get hasName =>
      studentName.trim().isNotEmpty && !studentName.startsWith('REEMPLAZAR');

  /// Primer nombre, para un saludo más cercano ("Hola, Juan").
  static String get firstName {
    if (!hasName) return 'estudiante';
    return studentName.trim().split(RegExp(r'\s+')).first;
  }

  /// Saludo mostrado en la cabecera.
  static String get greeting => 'Hola, $firstName';

  /// Iniciales para el monograma de respaldo (p. ej. "JC").
  static String get initials {
    final parts =
        studentName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty || studentName.startsWith('REEMPLAZAR')) return 'UN';
    final letters = parts.take(2).map((p) => p[0].toUpperCase()).join();
    return letters.isEmpty ? 'UN' : letters;
  }

  /// Línea corta de contexto académico para el pie de página.
  static String get courseLine => '$courseName ($courseCode) · $semester';
}
