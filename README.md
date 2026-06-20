# Core Module

Foundation package for the Smart RT/RW Modular Monolith architecture.
Provides shared contracts, base use cases, domain primitives, and DI wiring used by all feature modules.

---

## Package Structure

```
lib/
├── core_module.dart               # Barrel exports
├── application/
│   └── usecases/
│       └── base_use_case.dart     # UseCase & UseCaseWithParams abstractions
├── contracts/
│   ├── contracts.dart             # Barrel export
│   ├── feature_module.dart        # FeatureModule abstract contract
│   ├── module_dependency.dart     # ModuleDependency model
│   ├── module_manifest.dart       # ModuleManifest model
│   ├── module_permission.dart     # ModulePermission model
│   ├── module_route.dart          # ModuleRouteDefinition model
│   ├── module_version.dart        # ModuleVersion (semver)
│   └── version_compatibility.dart # Compatibility checker & result types
├── domain/
│   └── entities/
│       └── base_result_entities.dart  # ResultEntity, ResultSuccess, ResultError
├── infrastructure/
│   └── response/
│       └── base_success_response.dart # BaseSuccessResponse, Status, Meta
└── injection/
    ├── core_injection.dart        # getIt + @InjectableInit setup
    ├── core_injection.config.dart # Generated
    └── network_module.dart        # Dio lazySingleton module
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
| `permissions`         | Required `ModulePermission` list               |
| `initialize()`        | One-time async init (DB migrations, preload)   |
| `setupDependencies()` | Register DI before `initialize()`              |
| `routes`              | `List<RouteBase>` owned by this module         |
| `isCompatibleWithShell()` | Checks shell version >= minShellVersion    |
| `defaultValueFor()`   | Default for a feature flag                     |

### `ModuleManifest`

Self-describing metadata every module exposes. Allows shell, AI agents, and developers to understand a module without reading implementation.

| Field                     | Type                    | Description                          |
|---------------------------|-------------------------|--------------------------------------|
| `name`                    | `String`                | Unique module ID                     |
| `displayName`             | `String`                | Human-readable label                 |
| `version`                 | `ModuleVersion`         | Current semver                       |
| `description`             | `String`                | One-line description                 |
| `minShellVersion`         | `ModuleVersion`         | Minimum shell version required       |
| `recommendedShellVersion` | `ModuleVersion?`        | Recommended shell version            |
| `dependencies`            | `List<ModuleDependency>`| Inter-module dependencies            |
| `permissions`             | `List<ModulePermission>`| Required permissions                 |
| `featureFlags`            | `Map<String, bool>`     | Default flag values                  |
| `provides`                | `List<String>`          | Capabilities (e.g. `"resident.crud"`)|
| `buildNumber`             | `String?`               | Build metadata                       |
| `environment`             | `String?`               | Environment tag                      |

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

### `ModulePermission`

A permission a module requires or exposes.

```dart
ModulePermission(
  name: 'resident.read',
  description: 'View resident profiles',
)
```

### `ModuleRouteDefinition`

Describes a route a module owns (for documentation / manifest purposes). Modules return these from their manifest.

```dart
ModuleRouteDefinition(
  path: '/resident/:id',
  name: 'resident.detail',
  description: 'View resident detail',
  requiresAuth: true,
  requiredPermissions: ['resident.read'],
)
```

### `VersionCompatibility`

Checks version compatibility between shell and modules.

| Method                     | Returns                   |
|----------------------------|---------------------------|
| `checkModule(manifest)`    | `CompatibilityResult`     |
| `checkAll(manifests)`      | `List<CompatibilityResult>`|
| `areAllCompatible(manifests)` | `bool`                |

`CompatibilityResult` has severity: `ok`, `warning`, or `blocking`.

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
- `NetworkModule` — provides `Dio` as lazy singleton (30s timeouts)

---

## How to Add a New Module

Step-by-step to create a new feature module (e.g. `FinanceModule`).

### 1. Create Module Package

```
finance_module/
├── lib/
│   ├── finance_module.dart       # Barrel
│   ├── public_api.dart           # Domain abstractions only
│   ├── manifest/
│   │   └── manifest.dart         # ModuleManifest instance
│   ├── module/
│   │   └── finance_module_definition.dart  # FeatureModule impl
│   ├── domain/                   # Entities + Repositories
│   ├── application/              # Use cases, DTOs, services
│   ├── infrastructure/           # Data sources, mappers, repo impl
│   ├── injection/
│   │   └── finance_injection.dart
│   ├── routes/
│   │   └── finance_routes.dart
│   └── presentation/            # BLoC, pages, widgets
├── pubspec.yaml                 # Depends on core_module
└── test/
```

### 2. Define Manifest

```dart
// lib/manifest/manifest.dart
final financeManifest = ModuleManifest(
  name: 'finance',
  displayName: 'Finance Management',
  version: ModuleVersion(1, 0, 0),
  description: 'Manage iuran and financial records',
  minShellVersion: ModuleVersion(1, 0, 0),
  permissions: [
    ModulePermission(name: 'finance.read', description: 'View financial data'),
    ModulePermission(name: 'finance.write', description: 'Create/update records'),
  ],
  dependencies: [
    ModuleDependency(moduleName: 'core_module', minVersion: ModuleVersion(1, 0, 0)),
  ],
  featureFlags: {
    'finance.enabled': true,
    'finance.visible': true,
  },
  provides: ['finance.crud', 'finance.report'],
);
```

### 3. Implement FeatureModule

```dart
// lib/module/finance_module_definition.dart
class FinanceModule extends FeatureModule {
  @override String get name => 'finance';
  @override String get displayName => 'Finance Management';
  @override ModuleVersion get version => ModuleVersion(1, 0, 0);
  @override ModuleManifest get manifest => financeManifest;
  @override List<ModulePermission> get permissions => financeManifest.permissions;

  @override Future<void> initialize() async { /* DB migrations, etc */ }
  @override void setupDependencies() { setupFinanceInjection(); }
  @override List<RouteBase> get routes => FinanceRoutes.all;
}
```

### 4. Define Routes

```dart
// lib/routes/finance_routes.dart
class FinanceRoutes {
  static const String list = '/finance';
  static const String detail = '/finance/:id';

  static List<RouteBase> get all => [
    GoRoute(path: list, name: 'finance.list', builder: ...),
  ];
}
```

### 5. Register in App Shell

```dart
// rt-rw-digital/lib/main.dart
final result = await AppBootstrap.run(
  modules: [
    ResidentModule(),
    FinanceModule(),  // ← add here
  ],
  shellVersion: shellVersion,
);
```

### 6. Add to pubspec.yaml

```yaml
# rt-rw-digital/pubspec.yaml
dependencies:
  finance_module:
    path: ../finance_module
```

The shell discovers everything automatically: routes, manifests, permissions, feature flags. No manual wiring beyond registration.

---

## Dependencies

| Package           | Purpose                     |
|-------------------|-----------------------------|
| `flutter`         | SDK                         |
| `equatable`       | Value equality              |
| `json_annotation` | JSON serialization          |
| `get_it`          | Service locator             |
| `injectable`      | DI code generation          |
| `dio`             | HTTP client                 |
| `go_router`       | Routing                     |

---

## Dev Dependencies

- `flutter_test`, `flutter_lints`, `build_runner`, `injectable_generator`, `json_serializable`
