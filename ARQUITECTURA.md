# Esquema del código — Wallet UNSAAC (Unidad II · Sesión 1)

Documento de apoyo para **entender y explicar** el proyecto: cómo arranca, cómo
están separadas las capas y cómo viaja un evento desde que el usuario toca la
pantalla hasta que la interfaz se vuelve a dibujar. Pensado para sustentar la
guía ante el docente.

- **Curso:** Desarrollo de Software II (IF616BIN) · 2026-II
- **Patrón:** BLoC (Cubit) sobre arquitectura por capas
- **Estado:** `flutter analyze` sin observaciones · **22 pruebas** en verde

---

## 1. El punto de entrada: `main.dart`

Todo empieza aquí. El `main` es **asíncrono a propósito**: prepara dos cosas
*antes* de dibujar el primer frame y recién entonces llama a `runApp`.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();   // 1. enlaza Flutter con el SO
  final themePreferences = await ThemePreferences.create();  // 2. lee tema guardado (Reto 1)
  final firebaseStatus   = await FirebaseBootstrap.initialize(); // 3. prepara Firebase
  runApp(WalletApp(                              // 4. arranca la app ya configurada
    firebaseStatus: firebaseStatus,
    themePreferences: themePreferences,
  ));
}
```

**Por qué este orden importa:**

1. `ensureInitialized()` es obligatorio cuando se hace trabajo `async` antes de
   `runApp` (acceder a `shared_preferences`, a Firebase, etc.).
2. Las **preferencias de tema se leen primero** (Reto 1): así el primer frame ya
   usa el modo correcto y no hay parpadeo claro → oscuro.
3. **Firebase se inicializa** y devuelve un estado (`ready` / `notConfigured` /
   `failed`). Si no está configurado, la app sigue en **modo local** sin romperse.
4. `runApp(WalletApp(...))` recibe ambos resultados por constructor: la raíz de la
   app no hace trabajo pesado, solo recibe lo ya resuelto.

> Idea clave: `main.dart` **orquesta el arranque**; no contiene lógica de negocio
> ni de interfaz. Cada pieza que necesita vive en su propia capa.

---

## 2. La raíz: `app.dart` (inyección de dependencias)

`WalletApp` arma el árbol de *providers* por encima de `MaterialApp`. Es el único
lugar donde se "enchufan" el repositorio y los Cubits:

```
RepositoryProvider<WalletRepository>  → InMemoryWalletRepository   (capa de datos)
   └── MultiBlocProvider
         ├── ThemeCubit(themePreferences)          (Retos 1 y 4)
         ├── PrivacyCubit()                         (Reto 2)
         └── BalanceCubit(repository)..load()       (Reto 3)
               └── BlocBuilder<ThemeCubit>          (reconstruye el tema)
                     └── MaterialApp(theme, darkTheme, themeMode, home: WalletHomePage)
```

- El **repositorio se inyecta como contrato** (`WalletRepository`), no como clase
  concreta: mañana se cambia `InMemoryWalletRepository` por uno de Firebase sin
  tocar la interfaz ni los Cubits.
- `BalanceCubit(...)..load()` **dispara la carga** apenas se crea.
- El `BlocBuilder<ThemeCubit>` envuelve a `MaterialApp`: cuando el tema cambia, se
  reconstruye toda la app con la nueva paleta.

---

## 3. Las capas (carpeta `lib/`)

El proyecto separa responsabilidades en cuatro bloques. **La regla de oro es que
las dependencias apuntan hacia adentro**: la presentación conoce al dominio, pero
el dominio no sabe nada de Flutter ni de los Cubits.

```
lib/
├── main.dart                      ← arranque (binding → prefs → Firebase → runApp)
├── app.dart                       ← providers + MaterialApp (tema conectado al Cubit)
├── firebase_options.dart          ← plantilla (la reemplaza `flutterfire configure`)
│
├── core/                          ← lo transversal, sin lógica de billetera
│   ├── config/
│   │   ├── app_profile.dart       ← TUS DATOS: nombre, código, curso, docente, logo
│   │   ├── firebase_status.dart   ← enum + estado legible de Firebase
│   │   └── firebase_bootstrap.dart← inicializa Firebase con tolerancia a fallos
│   ├── theme/
│   │   ├── theme_state.dart       ← estado inmutable (modo + color semilla)
│   │   ├── theme_cubit.dart       ← lógica del tema (toggle, setSeedColor)
│   │   ├── theme_preferences.dart ← persistencia con shared_preferences (Reto 1)
│   │   └── app_theme.dart         ← ColorScheme.fromSeed (Material 3) (Reto 4)
│   └── utils/
│       └── money.dart             ← formato de soles y fechas
│
└── features/wallet/               ← la funcionalidad "billetera", en 3 subcapas
    │
    ├── domain/                    ← REGLAS DE NEGOCIO (Dart puro, sin Flutter)
    │   ├── entities/
    │   │   ├── movement.dart       ← un movimiento (ingreso/egreso)
    │   │   └── wallet_summary.dart ← AQUÍ se calcula el saldo, ingresos y egresos
    │   └── repositories/
    │       └── wallet_repository.dart ← CONTRATO: qué datos se piden (interfaz)
    │
    ├── data/                      ← CÓMO se obtienen los datos
    │   └── repositories/
    │       └── in_memory_wallet_repository.dart ← implementación de demostración
    │
    └── presentation/             ← LO QUE SE VE y reacciona
        ├── cubits/
        │   ├── privacy_state.dart / privacy_cubit.dart   ← ocultar saldo (Reto 2)
        │   └── balance_state.dart / balance_cubit.dart   ← carga/éxito/error (Reto 3)
        ├── pages/
        │   └── wallet_home_page.dart ← la pantalla principal (arma todo)
        └── widgets/
            ├── identity_header.dart    ← cabecera con escudo + tus datos
            ├── unsaac_logo.dart        ← escudo UNSAAC (con respaldo a monograma)
            ├── balance_card.dart       ← tarjeta del saldo + botón de ojo (Reto 2)
            ├── movement_tile.dart      ← fila de un movimiento
            ├── seed_color_selector.dart← selector de color semilla (Reto 4)
            └── firebase_status_card.dart← estado de Firebase
```

### Responsabilidad de cada capa

| Capa | Pregunta que responde | No puede… |
|------|-----------------------|-----------|
| **domain** | *¿Qué es un movimiento? ¿Cómo se calcula el saldo?* | importar Flutter ni flutter_bloc |
| **data** | *¿De dónde salen los datos?* | contener reglas de negocio |
| **presentation** | *¿Qué ve el usuario y cómo reacciona?* | calcular el saldo ni hablar con la BD directa |
| **core** | *Tema, formato, configuración, perfil* | depender de la billetera |

---

## 4. El patrón BLoC: evento → estado

Un **Cubit** guarda un **estado inmutable** y lo reemplaza con `emit(...)`. La
interfaz **solo escucha** con `BlocBuilder` y se redibuja cuando el estado cambia.
Nunca al revés: el widget no modifica datos a mano.

### Ejemplo: cargar el saldo (Reto 3)

```
[ app arranca ]
      │  BalanceCubit..load()
      ▼
BalanceCubit.emit(BalanceLoading())  ───────────────► BlocBuilder → spinner
      │  await repository.loadSummary()
      ▼
  ┌── éxito ──► emit(BalanceSuccess(summary)) ───────► BlocBuilder → saldo + lista
  └── error ──► emit(BalanceFailure(mensaje)) ───────► BlocBuilder → error + "Reintentar"
```

`BalanceState` es una **jerarquía sellada** (`sealed class`): el compilador obliga
a cubrir los cuatro casos en el `switch` de la pantalla, así no se olvida ninguno.

```dart
sealed class BalanceState {}
final class BalanceInitial  extends BalanceState {}
final class BalanceLoading  extends BalanceState {}
final class BalanceSuccess  extends BalanceState { final WalletSummary summary; }
final class BalanceFailure  extends BalanceState { final String message; }
```

### Ejemplo: ocultar el saldo (Reto 2)

```
[ usuario toca el ojo ]
      │  context.read<PrivacyCubit>().toggle()
      ▼
PrivacyCubit.emit(PrivacyState(hidden: !hidden))
      ▼
BlocBuilder<PrivacyCubit> → BalanceCard recibe hideBalance → muestra "••••••"
```

El widget **no decide** si ocultar: recibe `hideBalance` y un callback. La decisión
vive en el Cubit. Esa es la frontera limpia que pide la rúbrica.

---

## 5. Mapa de los cuatro retos

| Reto | Qué hace | Archivos clave |
|------|----------|----------------|
| **1 · Tema persistente** | Guarda modo y color entre sesiones; se lee antes de `runApp` | `theme_preferences.dart`, `theme_cubit.dart`, `main.dart` |
| **2 · Saldo privado** | Oculta importes con un Cubit de presentación | `privacy_cubit.dart`, `balance_card.dart`, `movement_tile.dart` |
| **3 · Carga/éxito/error** | Estados sellados + Reintentar + RefreshIndicator | `balance_cubit.dart`, `balance_state.dart`, `wallet_home_page.dart` |
| **4 · Color semilla** | Cambia toda la paleta Material 3 en caliente | `theme_state.dart`, `app_theme.dart`, `seed_color_selector.dart` |

---

## 6. Personalización (tus datos y el logo)

Toda la identidad está **centralizada en un solo archivo**:
[`lib/core/config/app_profile.dart`](lib/core/config/app_profile.dart).

- Cambiar el **nombre** → editar `studentName` (una línea).
- El **escudo** vive en `assets/images/escudo_unsaac.png` y lo muestra
  `UnsaacLogo`, que degrada a un monograma si el archivo faltara.
- La cabecera (`IdentityHeader`), el AppBar y el pie (`_AcademicFooter`) leen de
  `AppProfile`: no hay datos "quemados" repartidos por el código.

---

## 7. Pruebas (`test/`)

| Archivo | Qué verifica | Reto |
|---------|--------------|------|
| `core/theme_persistence_test.dart` | guardar/recuperar tema, ciclo de modos, valor corrupto → sistema | 1 |
| `features/wallet/privacy_test.dart` | `PrivacyCubit.toggle` y enmascarado del importe | 2 |
| `features/wallet/balance_test.dart` | `bloc_test`: Loading→Success, Loading→Failure, reintento | 3 |
| `features/wallet/seed_color_test.dart` | el `primary` coincide con `ColorScheme.fromSeed`; tocar un color | 4 |
| `features/wallet/wallet_home_page_test.dart` | vistas de éxito, error y botón de ojo (integración) | 2·3 |

Ejecutar: `flutter test` (22 pruebas). Análisis: `flutter analyze`.

---

## 8. Resumen en una frase

> `main.dart` prepara el entorno y entrega el control a `WalletApp`, que inyecta un
> **repositorio** (datos) y tres **Cubits** (estado) por encima de una
> `MaterialApp`; la pantalla **solo escucha estados** y los cuatro retos son, cada
> uno, un estado nuevo bien modelado.
