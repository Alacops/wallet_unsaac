# Wallet UNSAAC

Aplicativo de finanzas personales para Android del curso *Desarrollo de Software II
(IF616BIN)* — Escuela Profesional de Ingeniería Informática y de Sistemas, UNSAAC.

- **Sesión 1:** arquitectura por capas, tema Material 3 claro/oscuro, conexión
  preparada para Firebase y los cuatro retos de esa guía.
- **Sesión 2 (entregable D1):** primer **flujo BLoC completo** para los movimientos
  (carga, alta, edición, baja y limpieza) con pruebas unitarias, más los **cuatro
  retos** de la guía (edición, guardado visible, error con reintento y filtro).

- **Autor:** 021501@unsaac.edu.pe
- **Docente:** Mtro. Ing. Yover Collantes Valer
- **Semestre:** 2026-II

## Estado verificado

```
flutter analyze   →  No issues found!
flutter test      →  +39: All tests passed!
```

## Entorno

| Herramienta | Versión usada |
|-------------|---------------|
| Flutter     | 3.47.5 (stable) |
| Dart        | 3.13.4 |
| Git         | 2.54.0 |

Dependencias del flujo: `flutter_bloc`, `equatable` y `bloc_test` (esta última en
`dev_dependencies`).

## Puesta en marcha

```bash
flutter pub get      # instalar dependencias
flutter analyze      # análisis estático (debe salir "No issues found!")
flutter test         # 39 pruebas (dominio, bloc, Cubits y widgets)
flutter run          # ejecutar en emulador o dispositivo Android
```

> En Windows, `flutter run` requiere habilitar el **Modo de desarrollador**
> (`start ms-settings:developers`) porque los plugins de Firebase usan symlinks.
> `flutter analyze` y `flutter test` funcionan sin él.

## Configurar Firebase

La app arranca en **modo local** con datos de demostración mientras
`lib/firebase_options.dart` conserve los marcadores `REEMPLAZAR`. La conexión no
bloquea el arranque: si falla o no está configurada, la tarjeta inferior muestra el
estado y la app sigue funcionando. Para conectar un proyecto real:

```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure   # selecciona el proyecto y la plataforma android
flutter run
```

La tarjeta inferior de la app mostrará entonces **Firebase: conectado**.
`firebase_options.dart` se conserva como plantilla pública, **sin credenciales
reales**; `google-services.json` y los archivos de firma no se versionan
(ver `.gitignore`).

## Estructura y regla de dependencia

La dependencia apunta siempre **hacia el dominio**: la presentación conoce el
contrato `WalletRepository`, nunca la implementación concreta. El dominio no importa
Flutter ni Firebase.

```
lib/
├── app.dart                     # RepositoryProvider + BlocProvider + MaterialApp
├── main.dart                    # binding → preferencias → Firebase → runApp
├── firebase_options.dart        # plantilla (la reemplaza flutterfire configure)
├── core/
│   ├── config/                  # FirebaseStatus, FirebaseBootstrap
│   ├── theme/                   # ThemeState, ThemeCubit, ThemePreferences, AppTheme
│   └── utils/                   # MoneyFormat, formatShortDate
└── features/wallet/
    ├── domain/
    │   ├── entities/            # Movement, WalletSummary (Equatable; cálculo del saldo)
    │   └── repositories/        # WalletRepository (contrato de 4 operaciones)
    ├── data/
    │   └── repositories/        # InMemoryWalletRepository (vistas inmutables)
    └── presentation/
        ├── blocs/movements/     # MovementsBloc, MovementsEvent, MovementsState
        ├── cubits/              # PrivacyCubit (saldo privado)
        ├── pages/               # WalletHomePage (BlocBuilder + switch exhaustivo)
        └── widgets/             # BalanceCard, MovementTile, FirebaseStatusCard,
                                 #   SeedColorSelector
```

## Flujo BLoC de movimientos

**Eventos** (`movements_event.dart`, jerarquía sellada):

| Evento | Intención |
|--------|-----------|
| `MovementsStarted` | pedir la carga inicial del resumen |
| `MovementAdded(movement)` | registrar un movimiento nuevo |
| `MovementRemoved(movementId)` | eliminar un movimiento por id (idempotente) |
| `MovementsCleared` | vaciar el historial |

**Estados** (`movements_state.dart`, jerarquía sellada y exclusiva):

| Estado | Significado |
|--------|-------------|
| `MovementsInitial` | antes de la primera carga |
| `MovementsLoading` | hay una lectura en curso |
| `MovementsReady(summary)` | el resumen está listo para pintarse |
| `MovementsFailure(message)` | la última operación falló; mensaje apto para el usuario |

```
[Usuario pulsa "Ingreso"]
          │
context.read<MovementsBloc>().add(MovementAdded(movement))
          │
MovementsBloc._onAdded  →  repository.addMovement(...)
          │
emit(MovementsReady(summary))   // o MovementsFailure(mensaje) si falla
          │
BlocBuilder<MovementsBloc, MovementsState> + switch exhaustivo
          │
Lista y saldo reconstruidos
```

### Decisiones de diseño

1. **El estado inicial es `MovementsInitial`, no `MovementsLoading`.** La carga aún no
   comenzó; el evento `MovementsStarted` la inicia (`lazy: false` en `app.dart`).
2. **Solo la carga inicial emite `MovementsLoading`.** En alta y baja la lista ya está
   visible y no conviene reemplazarla por un indicador de pantalla completa.
3. **Cada operación del repositorio devuelve el resumen actualizado**, no `void`. Así
   el bloc no vuelve a leer tras cada cambio y queda libre de cálculos.
4. **`Movement` y `WalletSummary` implementan `Equatable`.** Sin igualdad por valor el
   bloc emitiría estados redundantes; con ella, eliminar un id inexistente no emite.
5. **Las acciones de la interfaz envían eventos, no llaman al repositorio.** La pantalla
   no contiene lógica de negocio.
6. **`emit.isDone` se comprueba tras cada `await`:** si el bloc se cerró durante la
   operación, emitir lanzaría `StateError`.

## Los cuatro retos (Sesión 2)

Integrados en el mismo flujo (alimentan los criterios «Flujo BLoC» y «Pruebas»):

| Reto | Nivel | Qué agrega |
|------|-------|-----------|
| 1 · Edición | Básico | `Movement.copyWith` (id inmutable), evento `MovementUpdated`, `updateMovement` en el repositorio (conserva la posición) y formulario mínimo |
| 2 · Guardado visible | Intermedio | `isSaving` en `MovementsReady`; el alta marca el guardado sin ocultar la lista |
| 3 · Error y reintento | Intermedio | `errorMessage` transitorio + `BlocListener`/`SnackBar`; el fallo de alta/baja conserva la lista |
| 4 · Filtro por tipo | Avanzado | `MovementFilter` + `visibleMovements`, `SegmentedButton` y `BlocSelector` (no reconstruye la tarjeta de saldo) |

> Los retos se trabajaron de forma acumulativa sobre `sesion-02` (comparten el
> mismo `MovementsReady`), con un commit descriptivo por reto.

## Pruebas

39 pruebas en `test/`:

| Archivo | Qué verifica |
|---------|--------------|
| `movements_bloc_test.dart` | pruebas del bloc: estado inicial, alta, edición, baja, no-emisión, limpieza, guardado visible, filtro por tipo y caminos de error (lectura, alta, baja) |
| `movements_state_test.dart` | 5 pruebas de igualdad por valor de entidades y estados |
| `wallet_home_page_test.dart` | vistas de éxito, privacidad, error de carga y SnackBar de fallo de alta |
| `balance_test.dart`*, `privacy_test.dart`, `seed_color_test.dart`, `theme_persistence_test.dart` | retos de la Sesión 1 (privacidad, color semilla, persistencia del tema) |

\* La prueba del saldo de la Sesión 1 se reemplazó por `movements_bloc_test.dart`,
que cubre el mismo flujo de carga y además alta, baja y limpieza.

Las tres pruebas obligatorias del D1 (estado inicial, alta y baja) están en
`movements_bloc_test.dart`.

## Errores frecuentes

- **`flutter test` falla con `ProviderNotFoundException`:** la prueba de widget debe
  construir el árbol con `BlocProvider<MovementsBloc>` por encima de la pantalla.
- **El bloc emite dos veces el mismo estado:** falta un campo en `props` de alguna
  entidad o estado; completa `Equatable`.
- **La prueba se cuelga:** usa `InMemoryWalletRepository(latency: Duration.zero)` en
  las pruebas para no esperar la latencia simulada.
- **La app abre con "Firebase: no configurado":** es el modo local previsto; no es un
  error.

## Referencias

- Angelov, F. (2025). *flutter_bloc*, *bloc_test*, *equatable* — https://pub.dev
- Bloc Library. *Bloc concepts*, *Modeling state*, *Testing* — https://bloclibrary.dev
- Dart Team. *Class modifiers* — https://dart.dev/language/class-modifiers
- Google. *Add Firebase to your Flutter app* — https://firebase.google.com/docs/flutter/setup
- Flutter Team. *Testing Flutter apps* — https://docs.flutter.dev/testing/overview
