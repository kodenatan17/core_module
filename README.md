# Core Module

Foundation package for the RT-RW Digital Modular Monolith architecture.
Provides shared contracts, base use cases, domain primitives, and DI wiring used by all feature modules.

## Latest Changes
- Refactored `SessionEventBus` to **Generic Infrastructure** (`EventBus`).
- `CoreModule` no longer holds business logic (`SessionExpired`, `TokenRefreshed`).
- Added `CoreAuthEvent` as generic technical events triggered by infrastructure.

## Introduce Repository
- `GenericEventBus` for cross-module decoupled communication.
- `CoreAuthEvent` for generic technical auth notifications.

## Core Module
Foundation package untuk shared infrastructure. Tidak diperbolehkan mengandung business logic (Auth, Login, Logout, Session).

## MFE-Ready Connectivity
`CoreModule` menyediakan transport generik. Gunakan `EventBus` untuk komunikasi antar-modul tanpa membuat dependensi fisik antar modul fitur.
```dart
// Publish event
GetIt.I<EventBus>().publish(MyDomainEvent());
```

---

## Package Structure

```
lib/
├── core_module.dart                   # Barrel exports
├── application/
│   └── usecases/
│       └── base_use_case.dart         # UseCase & UseCaseWithParams abstractions
├── contracts/
│   └── ...                            # Module manifests, contracts
├── domain/
│   ├── entities/
│   │   └── base_result_entities.dart  # ResultEntity
│   └── events/
│       └── core_auth_events.dart      # Generic Auth Events (transport-level)
├── infrastructure/
│   ├── response/
│   │   └── base_success_response.dart # BaseSuccessResponse
│   └── services/
│       ├── generic_event_bus.dart     # Generic EventBus
│       └── pae_indexer.dart           # PAE Indexer
└── injection/
    └── core_injection.dart            # getIt + @InjectableInit setup
```
