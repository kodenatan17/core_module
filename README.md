# Core Module

Foundation package for the RT-RW Digital Modular Monolith architecture.
Provides shared contracts, base use cases, domain primitives, and DI wiring used by all feature modules.

---

## Package Structure

```
lib/
├── core_module.dart                   # Barrel exports
├── application/
│   └── usecases/
│       └── base_use_case.dart         # UseCase & UseCaseWithParams abstractions
├── contracts/
│   ├── contracts.dart                 # Barrel export
│   ├── feature_module.dart            # FeatureModule abstract contract
│   ├── module_dependency.dart         # ModuleDependency model
│   ├── module_manifest.dart           # ModuleManifest model
│   ├── module_priority.dart           # ModuleInitializationStrategy + StartupBehavior enums
│   ├── module_route.dart              # ModuleRouteDefinition model
│   ├── module_version.dart            # ModuleVersion (semver)
│   └── version_compatibility.dart     # Compatibility checker & result types
├── domain/
│   └── entities/
│       └── base_result_entities.dart  # ResultEntity, ResultSuccess, ResultError
├── infrastructure/
│   └── response/
│       └── base_success_response.dart # BaseSuccessResponse, Status, Meta
└── injection/
    ├── core_injection.dart            # getIt + @InjectableInit setup
    ├── core_injection.config.dart     # Generated
    └── network_module.dart            # Dio lazySingleton (baseUrl + 30s timeouts)
```

---

## Contracts Layer (`lib/contracts/`)

The contracts layer defines every abstraction a feature module needs to plug into the shell. All feature modules depend only on these contracts — no shell internals leak.

### `FeatureModule` (abstract class)

Central contract. Every feature module implements this.

| Member                | Description                                    |
|-----------------------|------------------------------------------------|
| `name`                | Unique ID (e.g. `"resident"`)                  |
| `displayName`         | Human-readable label                           |
| `version`             | Current `ModuleVersion`                        |
| `manifest`            | Full `ModuleManifest`                          |
| `initialize()`        | One-time async init (DB migrations, preload)   |
| `isInitialized`       | Whether `initialize()` has completed           |
| `dispose()`           | Release resources, reset `isInitialized`       |
| `setupDependencies()` | Register DI before `initialize()`              |
| `routes`              | `List<RouteBase>` owned by this module         |
| `strategy`            | Shorthand for `manifest.initializationStrategy`|
| `startupBehavior`     | Shorthand for `manifest.startupBehavior`       |
| `defaultEnabled`      | Shorthand for `manifest.defaultEnabled`        |
| `defaultVisible`      | Shorthand for `manifest.defaultVisible`        |
| `isCompatibleWithShell()` | Checks shell version >= minShellVersion    |

### `ModuleManifest`

Runtime module contract. Controls when and how the module initializes.

| Field                     | Type                    | Description                                   |
|---------------------------|-------------------------|-----------------------------------------------|
| `name`                    | `String`                | Unique module ID                              |
| `displayName`             | `String`                | Human-readable label                          |
| `version`                 | `ModuleVersion`         | Current semver                                |
| `description`             | `String`                | One-line description                          |
| `minShellVersion`         | `ModuleVersion`         | Minimum shell version required                |
| `recommendedShellVersion` | `ModuleVersion?`        | Recommended shell version                     |
| `dependencies`            | `List<ModuleDependency>`| Inter-module dependencies                     |
| `initializationStrategy`  | `ModuleInitializationStrategy` | When to init (eager/warmup/lazy)        |
| `startupBehavior`         | `StartupBehavior`       | Is module required for app function           |
| `defaultEnabled`          | `bool`                  | Default enabled state (no remote flags)       |
| `defaultVisible`          | `bool`                  | Default menu visibility                       |
| `buildNumber`             | `String?`               | Build metadata                                |
| `environment`             | `String?`               | Environment tag                               |

### `ModuleInitializationStrategy`

Controls when a module initializes.

```dart
enum ModuleInitializationStrategy {
  eager,   // Startup (blocking) — e.g. authentication
  warmup,  // Post-first-frame (background) — e.g. notification
  lazy,    // On first access — e.g. resident, reports
}
```

### `StartupBehavior`

Whether the module is required for the app to function.

```dart
enum StartupBehavior {
  required,  // Module is essential
  optional,  // Module is additional, failure non-fatal
}
```

Set in manifest:
```dart
ModuleManifest(
  name: 'authentication',
  initializationStrategy: ModuleInitializationStrategy.eager,
  startupBehavior: StartupBehavior.required,
  defaultEnabled: true,
  defaultVisible: false,
)
```

### `ModuleVersion`

Semantic version following `MAJOR.MINOR.PATCH`.

```dart
const v1 = ModuleVersion(1, 0, 0);
const v2 = ModuleVersion(1, 5, 2);

v1 < v2;              // true
v1.satisfies(min: v2) // false
```

Methods: `compareTo`, `>=`, `<=`, `>`, `<`, `satisfies`, `asString`.

### `ModuleDependency`

Declares a dependency on another module.

```dart
ModuleDependency(
  moduleName: 'core_module',
  minVersion: ModuleVersion(1, 0, 0),
  optional: false,
)
```

### `FeatureFlagRepository` (abstract)

Single source of truth for feature flag resolution.

```dart
abstract class FeatureFlagRepository {
  Map<String, bool> resolveFlags();
  bool isEnabled(String flagName);
  Future<void> loadCached();
  Future<bool> refreshRemote();
  Future<void> saveFlags(Map<String, bool> flags);
}
```

Resolution order:
1. Remote override (GrowthBook) — highest priority
2. Local cached flags — medium priority
3. Manifest defaults (`defaultEnabled`, `defaultVisible`) — fallback

GrowthBook unavailability NEVER blocks app startup.

### `ModuleRouteDefinition`

Describes a route a module owns (for documentation / manifest purposes).

```dart
ModuleRouteDefinition(
  path: '/resident/:id',
  name: 'resident.detail',
  description: 'View resident detail',
  requiresAuth: true,
)
```

### `VersionCompatibility`

Checks version compatibility between shell and modules.

| Method                     | Returns                    |
|----------------------------|----------------------------|
| `checkModule(manifest)`    | `CompatibilityResult`      |
| `checkAll(manifests)`      | `List<CompatibilityResult>`|
| `areAllCompatible(manifests)` | `bool`                 |

`CompatibilityResult` has severity: `ok`, `warning`, or `blocking`.

---

## Bootstrap Flow (Offline-First)

The contracts in this library enable the shell to run an offline-first bootstrap.
GrowthBook NEVER blocks startup.

```
App Start
  ↓
Register All Modules            ← lightweight, metadata/routes ready instantly
  ↓
Version Compatibility Check     ← ModuleVersion + VersionCompatibility
  ↓
Load Cached Feature Flags       ← FeatureFlagRepository.loadCached() (non-blocking)
  ↓
DI Setup                        ← FeatureModule.setupDependencies()
  ↓
Init Eager Modules              ← ModuleInitializationStrategy.eager
  ↓
App Ready ✅
  ↓  (background)
Init GrowthBook SDK
  ↓
Refresh Remote Flags            ← FeatureFlagRepository.refreshRemote()
  ↓
Persist to Cache                ← FeatureFlagRepository.saveFlags()
  ↓
Schedule Warmup Modules         ← ModuleInitializationStrategy.warmup
```

### Key Contracts Used Per Phase

| Phase                        | Contracts Used                                    |
|------------------------------|---------------------------------------------------|
| Register                     | `FeatureModule`, `ModuleManifest`                 |
| Compatibility                | `ModuleVersion`, `VersionCompatibility`           |
| Feature Flags                | `FeatureFlagRepository`                           |
| DI Setup                     | `FeatureModule.setupDependencies()`               |
| Init Eager                   | `FeatureModule.initialize()`, `ModuleInitializationStrategy.eager` |
| Background Refresh           | `FeatureFlagRepository.refreshRemote()`           |
| Warmup                       | `ModuleInitializationStrategy.warmup`             |

---

## Other Layers

### Application — `base_use_case.dart`

Two base abstractions for use cases:

```dart
abstract class UseCase<ReturnType> {
  Future<ResultEntity<ReturnType>> call();
}

abstract class UseCaseWithParams<Params, ReturnType> {
  Future<ResultEntity<ReturnType>> call(Params params);
}
```

### Domain — `base_result_entities.dart`

Unified result type across all modules:

- `ResultEntity<T>` — sealed-like mixin with `when(success:, error:)`
- `ResultSuccess<T>` — wraps `data` + optional `Meta`
- `ResultError<T>` — wraps `code` + `message`
- Extension `successOrNull` — safe unwrap

### Infrastructure — `base_success_response.dart`

Generic JSON response model for API layer:

- `BaseSuccessResponse<T>` — `status` + `data` + `meta`
- `Status` — `code` + `message`
- `Meta` — pagination (`page`, `limit`, `totalPage`, `totalData`)
- Annotated with `@JsonSerializable(genericArgumentFactories: true)`

### Injection

- `setupCoreInjection()` — initializes GetIt via `@InjectableInit`
- `NetworkModule` — provides `Dio` as lazy singleton (30s timeouts, `baseUrl` set)

```dart
const String kBaseUrl = 'https://api.rt-rw-digital.example.com/v1';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio get dio => Dio(
    BaseOptions(
      baseUrl: kBaseUrl,
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
    ),
  );
}
```

---

## How to Add a New Module

Step-by-step to create a new feature module (e.g. `FinanceModule`).

### 1. Create Module Package

```
finance_module/
├── lib/
│   ├── finance_module.dart         # Barrel
│   ├── public_api.dart             # Domain abstractions only
│   ├── manifest/
│   │   └── manifest.dart           # ModuleManifest instance
│   ├── module/
│   │   └── finance_module_definition.dart  # FeatureModule impl
│   ├── domain/
│   │   ├── entities/               # Domain models
│   │   └── repositories/           # Abstract repositories
│   ├── application/
│   │   ├── dto/                    # Data transfer objects
│   │   ├── models/                 # App models
│   │   ├── repositories/           # Repository implementations
│   │   ├── services/               # Business logic
│   │   └── usecases/               # Use cases
│   ├── infrastructure/
│   │   ├── datasource/             # Remote/local data sources
│   │   ├── models/                 # JSON models
│   │   └── repositories/           # Infra repository impls
│   ├── injection/
│   │   ├── finance_injection.dart  # DI setup
│   │   └── finance_injection.config.dart  # Generated
│   ├── routes/
│   │   └── finance_routes.dart     # GoRouter routes
│   └── presentation/
│       ├── bloc/                   # BLoCs
│       ├── pages/                  # Screens
│       └── widgets/                # Reusable widgets
├── test/
├── pubspec.yaml                    # Depends on core_module
├── CHANGELOG.md
└── README.md
```

### 2. Define Manifest

```dart
// lib/manifest/manifest.dart
import 'package:core_module/core_module.dart';

final financeManifest = ModuleManifest(
  name: 'finance',
  displayName: 'Finance Management',
  version: ModuleVersion(1, 0, 0),
  description: 'Manage iuran and kas transactions',
  initializationStrategy: ModuleInitializationStrategy.lazy,
  startupBehavior: StartupBehavior.optional,
  defaultEnabled: true,
  defaultVisible: true,
  dependencies: [
    ModuleDependency(
      moduleName: 'core_module',
      minVersion: ModuleVersion(1, 0, 0),
    ),
  ],
);
```

### 3. Implement FeatureModule

```dart
// lib/module/finance_module_definition.dart
import 'package:core_module/core_module.dart';

class FinanceModule extends FeatureModule {
  bool _initialized = false;

  @override
  String get name => 'finance';

  @override
  String get displayName => 'Finance Management';

  @override
  ModuleVersion get version => ModuleVersion(1, 0, 0);

  @override
  ModuleManifest get manifest => financeManifest;

  @override
  List<ModulePermission> get permissions => financeManifest.permissions;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    // Init DB, preload data, etc.
    _initialized = true;
  }

  @override
  void dispose() {
    _initialized = false;
  }

  @override
  void setupDependencies() {
    setupFinanceInjection();
  }

  @override
  List<RouteBase> get routes => FinanceRoutes.all;
}
```

### 4. Register in Shell

```dart
// In rt-rw-digital/lib/main.dart
final modules = <FeatureModule>[
  ResidentModule(),
  FinanceModule(),   // <-- add here
];
```

### 5. Strategy Selection Guide

| If your module...                                    | Use strategy     | StartupBehavior |
|------------------------------------------------------|------------------|-----------------|
| Renders on first screen after login                  | `eager`          | `required`      |
| Shown in navigation but not needed instantly         | `warmup`         | `optional`      |
| Only accessed via deep nav or specific action        | `lazy`           | `optional`      |
| Required for auth or app scaffolding                 | `eager`          | `required`      |
| Reports, analytics, admin panels                     | `lazy`           | `optional`      |
