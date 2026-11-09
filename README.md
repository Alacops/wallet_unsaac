# Wallet UNSAAC

Aplicativo de finanzas personales para Android, construido en la **Sesión 1 de la
Unidad Didáctica II** del curso *Desarrollo de Software II (IF616BIN)* — Escuela
Profesional de Ingeniería Informática y de Sistemas, UNSAAC.

El proyecto demuestra **arquitectura por capas**, el **patrón BLoC (Cubit)**,
**tema Material 3 claro/oscuro** y una **conexión preparada para Firebase**. Sobre
esta base se resuelven los **cuatro retos** de la guía.

- **Autor:** 021501@unsaac.edu.pe
- **Docente:** Mtro. Ing. Yover Collantes Valer
- **Semestre:** 2026-II

## Entorno

| Herramienta | Versión usada |
|-------------|---------------|
| Flutter     | 3.47.5 (stable) |
| Dart        | 3.13.4 |
| Git         | 2.54.0 |

## Comandos

```bash
flutter pub get      # instalar dependencias
flutter analyze      # análisis estático (debe salir "No issues found!")
flutter test         # 22 pruebas (Cubits y widgets)
flutter run          # ejecutar en emulador o dispositivo Android
```

> En Windows, `flutter run` requiere habilitar el **Modo de desarrollador**
> (`start ms-settings:developers`) porque los plugins de Firebase usan symlinks.
> `flutter analyze` y `flutter test` funcionan sin él.

## Configurar Firebase (opcional)

La app arranca en **modo local** con datos de demostración mientras
`lib/firebase_options.dart` conserve los marcadores `REEMPLAZAR`. Para conectar un
proyecto real:

```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure   # selecciona el proyecto y la plataforma android
flutter run
```

La tarjeta inferior de la app mostrará entonces **Firebase: conectado**.

## Estructura de carpetas

```
lib/
├── app.dart                     # Providers + MaterialApp (tema conectado al Cubit)
├── main.dart                    # binding → preferencias → Firebase → runApp
├── firebase_options.dart        # plantilla (la reemplaza flutterfire configure)
├── core/
│   ├── config/                  # FirebaseStatus, FirebaseBootstrap
│   ├── theme/                   # ThemeState, ThemeCubit, ThemePreferences, AppTheme
│   └── utils/                   # MoneyFormat, formatShortDate
└── features/wallet/
    ├── domain/
    │   ├── entities/            # Movement, WalletSummary (cálculo del saldo)
    │   └── repositories/        # WalletRepository (contrato)
    ├── data/
    │   └── repositories/        # InMemoryWalletRepository
    └── presentation/
        ├── cubits/              # PrivacyCubit, BalanceCubit (estados sellados)
        ├── pages/               # WalletHomePage
        └── widgets/             # BalanceCard, MovementTile, FirebaseStatusCard,
                                 #   SeedColorSelector
```

## Los cuatro retos (integrados)

| Reto | Tema | Dónde |
|------|------|-------|
| 1 | Tema persistente entre sesiones | `core/theme/theme_preferences.dart`, `theme_cubit.dart`, `main.dart` |
| 2 | Saldo privado | `presentation/cubits/privacy_*.dart`, `balance_card.dart`, `movement_tile.dart` |
| 3 | Saldo con estados de carga/éxito/error | `presentation/cubits/balance_*.dart`, `wallet_home_page.dart`, `app.dart` |
| 4 | Color semilla configurable | `core/theme/theme_state.dart`, `app_theme.dart`, `seed_color_selector.dart` |

- **Reto 1:** `ThemePreferences` persiste el modo y el color con `shared_preferences`;
  se leen antes de `runApp`. El botón recorre claro → oscuro → sistema → claro y un
  valor corrupto cae en `system` sin romper el arranque.
- **Reto 2:** `PrivacyCubit` (estado inmutable con `Equatable`) oculta los importes.
  Los widgets no deciden: reciben `hideBalance` / `hideAmount` y un callback.
- **Reto 3:** jerarquía sellada `BalanceInitial | BalanceLoading | BalanceSuccess |
  BalanceFailure`. La pantalla solo habla con `BalanceCubit`; `isClosed` se verifica
  después de cada `await`.
- **Reto 4:** `seedColor` vive en `ThemeState` (participa en `props`); `AppTheme`
  recalcula toda la paleta con `ColorScheme.fromSeed`. El indicador de selección
  usa `BlocSelector`.

## Diagrama evento → estado (ThemeCubit)

```
[Usuario pulsa el icono]
          │
context.read<ThemeCubit>().toggle()
          │
ThemeCubit.emit(ThemeState(mode: ...))
          │
BlocBuilder<ThemeCubit, ThemeState>
          │
MaterialApp(themeMode: state.mode)
          │
Interfaz reconstruida con el nuevo tema
```

## Pruebas

22 pruebas en `test/`: persistencia del tema, ciclo de modos y color semilla
(Reto 1 y 4), `PrivacyCubit` y enmascarado (Reto 2), estados del saldo con
`bloc_test` y vistas de éxito/error (Reto 3), e igualdad del `primary` con
`ColorScheme.fromSeed` (Reto 4).
