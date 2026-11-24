# Wallet UNSAAC

Aplicativo de finanzas personales para Android del curso *Desarrollo de Software II
(IF616BIN)* — Escuela Profesional de Ingeniería Informática y de Sistemas, UNSAAC.

- **Sesión 1:** arquitectura por capas, tema Material 3 claro/oscuro, conexión
  preparada para Firebase y los cuatro retos de esa guía.
- **Sesión 2 (entregable D1):** primer **flujo BLoC completo** para los movimientos
  (carga, alta, edición, baja y limpieza) con pruebas unitarias, más los **cuatro
  retos** de la guía (edición, guardado visible, error con reintento y filtro).
- **Sesión 3 (avance de D2):** **autenticación con Firebase** (Email/Password),
  registro, inicio y **cierre de sesión**, sesión **persistente** gobernada por un
  `AuthBloc` y un `AuthGate` que decide la pantalla; todo probado sin depender de
  Firebase (repositorio falso + modo local).

- **Autor:** 021501@unsaac.edu.pe
- **Docente:** Mtro. Ing. Yover Collantes Valer
- **Semestre:** 2026-II

## Estado verificado

```
flutter analyze   →  No issues found!
flutter test      →  +64: All tests passed!
```

## Entorno

| Herramienta | Versión usada |
|-------------|---------------|
| Flutter     | 3.47.5 (stable) |
| Dart        | 3.13.4 |
| Git         | 2.54.0 |

Dependencias del flujo: `flutter_bloc`, `equatable`, `firebase_core`, `firebase_auth`
y `bloc_test` (esta última en `dev_dependencies`).

## Puesta en marcha

```bash
flutter pub get      # instalar dependencias
flutter analyze      # análisis estático (debe salir "No issues found!")
flutter test         # 64 pruebas (dominio, blocs, Cubits y widgets)
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
├── features/auth/              # Sesión 3 — autenticación
│   ├── domain/
│   │   ├── entities/           # AuthUser (Equatable)
│   │   ├── failures/           # AuthFailureReason, AuthException, AuthMessages
│   │   └── repositories/       # AuthRepository (contrato de 5 operaciones)
│   ├── data/
│   │   ├── mappers/            # firebase_auth_error_mapper
│   │   └── repositories/       # FirebaseAuthRepository, InMemoryAuthRepository
│   └── presentation/
│       ├── blocs/auth/         # AuthBloc, AuthEvent, AuthState
│       ├── pages/              # AuthGate, LoginPage, RegisterPage
│       ├── utils/              # AuthValidators
│       └── widgets/            # AuthScaffold, AuthFormField
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

## Autenticación con Firebase (Sesión 3 · avance de D2)

### Habilitar el proveedor

1. [Firebase Console](https://console.firebase.google.com/) → proyecto
   `wallet-unsaac-alain` (project_number `664747208936`).
2. **Authentication → Sign-in method → Email/Password → Habilitar**. Este flujo no
   requiere SHA-1 ni verificación por correo.
3. Verifica que la app Android está registrada con el `applicationId`
   `pe.edu.unsaac.wallet_unsaac` (el mismo de `google-services.json`).

Si el proveedor no está habilitado, el registro falla con `operation-not-allowed` y
la app muestra «El acceso con correo y contraseña no está habilitado en Firebase.».

### Modo local (sin Firebase)

Cuando Firebase no está listo, la app usa `InMemoryAuthRepository`: una cuenta de
demostración `estudiante@unsaac.edu.pe` / `wallet123`. **No es autenticación real**;
las contraseñas viven en memoria solo para la demo del taller.

### Flujo del `AuthBloc`

**Eventos** (`auth_event.dart`): `AuthStarted` (observar la sesión),
`AuthLoginRequested`, `AuthRegisterRequested`, `AuthLogoutRequested`.

**Estados** (`auth_state.dart`): `AuthInitial`, `AuthLoading`,
`AuthAuthenticated(user, {message})`, `AuthUnauthenticated({message})`.

El `AuthGate` escucha el stream `authStateChanges()` con `emit.forEach`, de modo que
la **sesión persiste** entre reinicios: Firebase la restaura y el gate decide entre
la pantalla de acceso y la billetera. `AuthLoading` no desmonta el formulario
(`buildWhen: current is! AuthLoading`).

### Errores de Firebase → mensajes estables

`firebase_auth_error_mapper.dart` traduce el `code` del SDK (sin prefijo `auth/`) a un
`AuthFailureReason` y a un texto de `AuthMessages`:

| Código de Firebase | Mensaje para el usuario |
|--------------------|-------------------------|
| `invalid-email` | El correo no tiene un formato válido. |
| `user-not-found`, `wrong-password`, `invalid-credential` | Correo o contraseña incorrectos. |
| `email-already-in-use` | Ya existe una cuenta con este correo. |
| `weak-password` | La contraseña es demasiado débil. Usa al menos 6 caracteres. |
| `operation-not-allowed` | El acceso con correo y contraseña no está habilitado en Firebase. |
| `too-many-requests` | Demasiados intentos. Espera unos minutos y vuelve a intentarlo. |
| `network-request-failed` | No se pudo conectar. Revisa tu conexión a Internet. |
| (desconocido) | Ocurrió un error inesperado. Inténtalo de nuevo. |

`user-not-found` y `wrong-password` comparten el mismo mensaje a propósito: no se
enumeran cuentas (recomendación de OWASP).

### Verificación de D2 parcial

- [x] Registro, acceso y cierre funcionan con Firebase real o modo local.
- [x] La sesión persiste al reiniciar la app.
- [x] `AuthGate` muestra login o billetera según el estado.
- [x] Los errores tienen mensajes comprensibles.
- [x] Existen pruebas del bloc y de widget.
- [x] `flutter analyze` y `flutter test` en verde.
- [x] Sin contraseñas, tokens ni credenciales en el repositorio.

### Retos de ampliación (Sesión 3)

| Reto | Nivel | Qué agrega |
|------|-------|-----------|
| 1 · Recuperación de contraseña | Básico | `sendPasswordResetEmail` en el contrato y las dos implementaciones; evento `AuthPasswordResetRequested`; enlace «¿Olvidaste tu contraseña?». El mensaje es **genérico** (no revela si el correo existe) |
| 2 · Perfil con nombre | Intermedio | `updateDisplayName` (el `uid` no cambia); evento `AuthDisplayNameUpdated`; botón de perfil con la inicial y un formulario para editar el nombre. Un nombre vacío se ignora |
| 3 · Sesión expirada | Avanzado | `AuthMessages.sessionExpired`; `_stateForUser` distingue un **cierre voluntario** (pasa por `AuthLoading`) de una **expiración** (el stream emite `null` sobre una sesión activa); `SnackBar` con «Volver a iniciar sesión» |

**¿Por qué no se guarda el token en la app?** Firebase Authentication conserva y
restaura la sesión de forma segura en el dispositivo; duplicar el token en la app
sería una segunda fuente de verdad que puede quedar desincronizada y amplía la
superficie de ataque. La app solo observa `authStateChanges()`.

## Pruebas

64 pruebas en `test/`:

| Archivo | Qué verifica |
|---------|--------------|
| `movements_bloc_test.dart` | pruebas del bloc: estado inicial, alta, edición, baja, no-emisión, limpieza, guardado visible, filtro por tipo y caminos de error (lectura, alta, baja) |
| `movements_state_test.dart` | 5 pruebas de igualdad por valor de entidades y estados |
| `wallet_home_page_test.dart` | vistas de éxito, privacidad, error de carga y SnackBar de fallo de alta |
| `auth/auth_bloc_test.dart` | pruebas del `AuthBloc`: inicial, sesión persistida, acceso, error, registro, cierre (limpio y fallido) y los retos 1-3 (recuperación, perfil y expiración) |
| `auth/auth_widget_test.dart` | validación del formulario, acceso correcto abre la billetera, fallo muestra el mensaje, el registro exige confirmación y la sesión expirada vuelve al login |
| `auth/auth_validators_test.dart`, `auth/auth_error_mapper_test.dart` | validaciones de correo/contraseña y traducción de códigos de Firebase |
| `privacy_test.dart`, `seed_color_test.dart`, `theme_persistence_test.dart` | retos de la Sesión 1 (privacidad, color semilla, persistencia del tema) |

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
