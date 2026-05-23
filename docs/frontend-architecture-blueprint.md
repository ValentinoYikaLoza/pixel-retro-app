# Blueprint Frontend (Flutter) — Clean Architecture por feature

> Plan para **replicar la estructura y las buenas prácticas** de este proyecto en
> otra app Flutter. Incluye árbol de carpetas, responsabilidades por capa,
> plantillas de código copiables, convenciones y un checklist para agregar una
> feature nueva.

---

## 1. Principios

1. **Clean Architecture por feature**: cada feature tiene sus capas
   `data / domain / presentation` aisladas.
2. **Flujo de datos unidireccional**: `DTO → Mapper → Entity → State → UI`.
   La UI nunca ve un DTO ni un `Response` de red.
3. **Dependencias hacia adentro** (DIP): `presentation → domain ← data`.
   El dominio define **interfaces**; la capa de datos las implementa.
4. **Inmutabilidad de estado**: siempre `copyWith` sobre copias; nunca mutar
   listas/objetos del estado in place.
5. **Errores tipados**: la capa de datos traduce errores de red a
   `ServiceException`; la presentación los captura y nunca deja el loader colgado.
6. **Solo los datos necesarios**: el `Mapper` recorta el DTO a lo que la UI usa.

---

## 2. Stack

| Rol | Paquete |
|-----|---------|
| Estado | `flutter_riverpod` (StateNotifier) |
| Inyección de dependencias | `get_it` |
| Navegación | `go_router` |
| HTTP | `dio` |
| Config / secrets | `flutter_dotenv` |
| Igualdad de valores | `equatable` |
| Lints | `flutter_lints` |
| Versionado de Flutter | **FVM** (`.fvmrc`) → usar `fvm flutter ...` |

---

## 3. Estructura de carpetas

```
lib/
├── main.dart                 # bootstrap: ensureInitialized → env → DI → runApp
├── di.dart                   # registro GetIt (Api, datasources, repositories)
└── app/
    ├── app.dart              # wrappers globales (Snackbar/Loader)
    ├── config/
    │   ├── api/api.dart       # cliente Dio único (singleton)
    │   ├── constants/         # environment, colores, breakpoints, storage_keys
    │   ├── router/            # go_router + helpers de navegación
    │   └── theme/
    └── shared/
        ├── models/            # ServiceException, ApiResponse, ...
        ├── services/          # ErrorService, StorageService, SnackbarService
        ├── widgets/           # Loader, Snackbar, CustomAppbar, ...
        ├── providers/         # providers globales (snackbar)
        ├── functions/         # utilidades puras reutilizables
        └── enums/
    └── features/
        └── <feature>/
            ├── data/
            │   ├── dto/            # espejo del JSON del backend
            │   ├── mappers/        # DTO → Entity (recorta a lo necesario)
            │   ├── datasources/    # *_datasource_impl.dart (HTTP real)
            │   └── repositories/   # *_repository_impl.dart (delega/orquesta)
            ├── domain/
            │   ├── entities/       # modelos limpios para la UI
            │   ├── datasources/    # interfaces (abstract class)
            │   └── repositories/   # interfaces (abstract class)
            └── presentation/
                ├── providers/      # StateNotifier + State
                ├── screens/
                ├── widgets/
                └── routes/         # GoRoute de la feature
```

---

## 4. Responsabilidades por capa

| Capa | Hace | NO hace |
|------|------|---------|
| **DTO** (`data/dto`) | Parsear JSON 1:1 (`fromJson`/`toJson`) | Lógica de negocio |
| **Mapper** (`data/mappers`) | Convertir DTO → Entity, recortando campos no usados | Llamadas de red |
| **Datasource impl** (`data/datasources`) | Llamar al `Api`, parsear DTO, lanzar `ServiceException` | Estado de UI |
| **Repository impl** (`data/repositories`) | Orquestar datasources (caché/red), exponer entidades | Detalles de transporte |
| **Entity** (`domain/entities`) | Modelo inmutable para la app | Serialización JSON |
| **Interfaces** (`domain/...`) | Definir el contrato | Implementación |
| **Provider/State** (`presentation/providers`) | Estado inmutable, llamar repos, manejar loader/errores | HTTP directo |
| **Screens/Widgets** | Render + input | Lógica de datos |

---

## 5. Plantillas de código

### 5.1 `Api` — cliente Dio único (singleton)
```dart
class Api {
  Api() : _dio = _build();
  final Dio _dio;

  static Dio _build() {
    final dio = Dio(BaseOptions(
      baseUrl: Environment.urlBase,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      contentType: Headers.jsonContentType,
    ));
    if (kDebugMode) dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    return dio;
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) =>
      _dio.get(path, queryParameters: queryParameters);
  Future<Response> post(String path, {required Object data}) => _dio.post(path, data: data);
}
```

### 5.2 Error tipado
```dart
class ServiceException implements Exception {
  final String message;
  final int? statusCode;
  ServiceException(this.message, {this.statusCode});
}

class ErrorService {
  const ErrorService._();
  static const _keys = ['message', 'mensaje', 'msg'];

  static ServiceException toServiceException(Object e, {String fallback = 'Error inesperado'}) {
    if (e is ServiceException) return e;
    if (e is DioException) {
      final data = e.response?.data;
      String? msg;
      if (data is Map) for (final k in _keys) {
        if (data[k] is String && (data[k] as String).trim().isNotEmpty) { msg = data[k]; break; }
      }
      return ServiceException(msg ?? fallback, statusCode: e.response?.statusCode);
    }
    return ServiceException(fallback);
  }
}
```

### 5.3 Domain (interfaces + entity)
```dart
// domain/entities/foo_entity.dart
class FooEntity {
  final int id;
  final String name;
  FooEntity({required this.id, required this.name});
}

// domain/datasources/foo_datasource.dart
abstract class FooDatasource { Future<List<FooEntity>> getFoos(); }

// domain/repositories/foo_repository.dart
abstract class FooRepository { Future<List<FooEntity>> getFoos(); }
```

### 5.4 Data (DTO → Mapper → Datasource → Repository)
```dart
// data/dto/foo_dto.dart
class FooDto {
  final int id; final String name;
  FooDto({required this.id, required this.name});
  factory FooDto.fromJson(Map<String, dynamic> j) => FooDto(id: j['id'], name: j['name']);
}

// data/mappers/foo_mapper.dart  (recorta sólo lo que la UI usa)
class FooMapper {
  static FooEntity fromDto(FooDto d) => FooEntity(id: d.id, name: d.name);
}

// data/datasources/foo_datasource_impl.dart
class FooDatasourceImpl implements FooDatasource {
  FooDatasourceImpl(this._api);
  final Api _api;
  @override
  Future<List<FooEntity>> getFoos() async {
    try {
      final res = await _api.get('/foo/getFoos');
      final list = (res.data['data'] as List).map((e) => FooDto.fromJson(e));
      return list.map(FooMapper.fromDto).toList();
    } catch (e) {
      throw ErrorService.toServiceException(e, fallback: 'Error al cargar foos');
    }
  }
}

// data/repositories/foo_repository_impl.dart
class FooRepositoryImpl implements FooRepository {
  FooRepositoryImpl(this.datasource);
  final FooDatasource datasource;
  @override
  Future<List<FooEntity>> getFoos() => datasource.getFoos();
}
```

### 5.5 Presentation (StateNotifier + State inmutable + manejo de errores)
```dart
final fooProvider = StateNotifierProvider<FooNotifier, FooState>((ref) => FooNotifier());

class FooNotifier extends StateNotifier<FooState> {
  FooNotifier() : super(FooState());
  final FooRepository _repo = getIt<FooRepository>();

  Future<void> load() async {
    Loader.show();
    try {
      state = state.copyWith(foos: await _repo.getFoos());
    } on ServiceException catch (e) {
      SnackbarService.show(e.message, type: SnackbarType.error);
    } catch (_) {
      SnackbarService.show('Error al cargar foos', type: SnackbarType.error);
    } finally {
      Loader.dismiss();              // ← SIEMPRE en finally
    }
  }
}

class FooState {
  final List<FooEntity> foos;
  FooState({this.foos = const []});
  FooState copyWith({List<FooEntity>? foos}) => FooState(foos: foos ?? this.foos);
}
```

### 5.6 Inyección (`di.dart`)
```dart
final getIt = GetIt.instance;
void setup() {
  getIt.registerLazySingleton<Api>(() => Api());
  getIt.registerLazySingleton<FooDatasource>(() => FooDatasourceImpl(getIt<Api>()));
  getIt.registerLazySingleton<FooRepository>(() => FooRepositoryImpl(getIt<FooDatasource>()));
}
```

### 5.7 `main.dart` (orden correcto)
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();   // 1º bindings
  await Environment.initEnvironment();          // 2º .env (lee assets)
  setup();                                      // 3º DI
  runApp(const ProviderScope(child: MainApp()));
}
```

---

## 6. Convenciones y calidad (no negociables)

- **Inmutabilidad**: `final newList = [...state.list];` antes de modificar; nunca `state.list..shuffle()`.
- **Loader**: `Loader.dismiss()` siempre en `finally`.
- **Timers / game loops**: provider `.autoDispose` **y** cancelar el `Timer` en `dispose()`.
- **Sin duplicación**: lógica pura repetida → `shared/functions/`.
- **Un idioma** en el código (recomendado: inglés). Sin typos en nombres de archivos/métodos.
- **`Environment`** con getter validado (lanza si falta la variable); `.env` en `.gitignore`.
- **Lints** activos (`flutter_lints`). Meta: `fvm flutter analyze` → *No issues found!*
- **Tests** unitarios para lógica pura y providers sin UI (`test/`).
- **Sin deprecaciones**: p. ej. `withValues(alpha:)` en vez de `withOpacity`, `onPopInvokedWithResult` en vez de `onPopInvoked`.

---

## 7. Checklist: agregar una feature nueva

1. `lib/app/features/<feature>/` con `data/ domain/ presentation/`.
2. **domain**: `entities/`, interfaces `datasources/` y `repositories/`.
3. **data**: `dto/` (+`fromJson`), `mappers/` (recorta), `*_datasource_impl` (usa `Api`, lanza `ServiceException`), `*_repository_impl`.
4. Registrar datasource + repository en `di.dart`.
5. **presentation**: `providers/` (StateNotifier + State `copyWith`), `screens/`, `widgets/`, `routes/`.
6. Sumar la `GoRoute` al router central.
7. Tests del provider / utilidades.
8. `fvm flutter analyze` y `fvm flutter test` en verde.

---

## 8. Tooling

- **Flutter** vía FVM: `fvm flutter run|analyze|test|build`.
- **Web**: `fvm flutter run -d chrome` (o `-d web-server --web-port=5555`).
- **Celular Android por USB**: `adb reverse tcp:<port> tcp:<port>` + `URL_BASE=http://127.0.0.1:<port>/api`; habilitar cleartext **solo en debug** en `android/app/src/debug/AndroidManifest.xml`:
  ```xml
  <application android:usesCleartextTraffic="true" />
  ```
- **Android Gradle**: usar **un solo** DSL (Groovy `.gradle` *o* Kotlin `.gradle.kts`), nunca ambos; un único `MainActivity.kt` por paquete.
```
