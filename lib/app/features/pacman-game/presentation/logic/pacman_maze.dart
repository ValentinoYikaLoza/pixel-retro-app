import 'dart:math';

/// Dirección de movimiento en la grilla. `none` = quieto (estado inicial).
enum PacDir { none, up, down, left, right }

extension PacDirVec on PacDir {
  /// Vector unitario (dx, dy) de la dirección.
  Point<int> get vec => switch (this) {
    PacDir.up => const Point(0, -1),
    PacDir.down => const Point(0, 1),
    PacDir.left => const Point(-1, 0),
    PacDir.right => const Point(1, 0),
    PacDir.none => const Point(0, 0),
  };

  PacDir get opposite => switch (this) {
    PacDir.up => PacDir.down,
    PacDir.down => PacDir.up,
    PacDir.left => PacDir.right,
    PacDir.right => PacDir.left,
    PacDir.none => PacDir.none,
  };
}

/// Laberinto de Pac-Man parseado desde un mapa ASCII (validado: 28×29, 232
/// comestibles alcanzables, simetría perfecta, túnel funcional).
///
/// Leyenda del ASCII:
///   `#` pared · `.` pellet · `o` power pellet · `=` puerta de la casa
///   (pared para Pac-Man, paso para fantasmas) · `_` pasillo vacío.
///
/// La capa de datos del backend es genérica (sesión por `game_id`, `seed`,
/// `target_score`), así que el layout del laberinto vive en el cliente: es arte
/// fijo y necesita info (pellets/power/casa/spawn) que el esquema `walls` no
/// guarda. El `target_score` del backend debe igualar [pelletCount].
class PacmanMaze {
  PacmanMaze(this.rows)
    : height = rows.length,
      width = rows.isEmpty ? 0 : rows.first.length {
    _parse();
  }

  final List<String> rows;
  final int width;
  final int height;

  final Set<int> _walls = {}; // pared sólida (Pac y fantasmas)
  final Set<int> _doors = {}; // puerta de la casa (solo fantasmas pasan)
  final Set<int> pellets = {}; // pellets restantes (se consume al comer)
  final Set<int> powerPellets = {}; // power pellets restantes
  final List<Point<int>> _power = []; // posiciones originales (para reinicio)
  final Set<int> _tunnelRows = {};

  int pelletCount = 0; // total inicial de comestibles (pellets + power)

  late final Point<int> pacSpawn;

  /// Casa de fantasmas (rect inclusivo) y celda objetivo de salida (sobre la
  /// puerta). Se calculan del ASCII.
  late final Rectangle<int> house;
  late final Point<int> ghostExit;

  int _key(int x, int y) => y * width + x;

  void _parse() {
    Point<int>? pac;
    var minHx = width, minHy = height, maxHx = 0, maxHy = 0;
    final doorCells = <Point<int>>[];

    for (var y = 0; y < height; y++) {
      final row = rows[y];
      for (var x = 0; x < width; x++) {
        final c = row[x];
        final k = _key(x, y);
        switch (c) {
          case '#':
            _walls.add(k);
          case '=':
            _doors.add(k);
            doorCells.add(Point(x, y));
          case '.':
            pellets.add(k);
          case 'o':
            powerPellets.add(k);
            _power.add(Point(x, y));
          case 'P':
            pac = Point(x, y);
        }
      }
      if (row.isNotEmpty && row[0] != '#') _tunnelRows.add(y);
    }

    // Casa de fantasmas: el rect de celdas vacías encerrado por la puerta.
    // Se infiere de la puerta (su fila marca el techo de la casa).
    if (doorCells.isNotEmpty) {
      final dy = doorCells.first.y;
      final dxAvg =
          doorCells.map((d) => d.x).reduce((a, b) => a + b) ~/ doorCells.length;
      // Expande hacia abajo/los lados mientras haya pasillo vacío encerrado.
      for (var y = dy; y < height; y++) {
        for (var x = 0; x < width; x++) {
          if (!_walls.contains(_key(x, y)) &&
              !_doors.contains(_key(x, y)) &&
              !pellets.contains(_key(x, y)) &&
              !powerPellets.contains(_key(x, y)) &&
              (x - dxAvg).abs() <= 3 &&
              y >= dy &&
              y <= dy + 3) {
            minHx = min(minHx, x);
            minHy = min(minHy, y);
            maxHx = max(maxHx, x);
            maxHy = max(maxHy, y);
          }
        }
      }
      house = Rectangle.fromPoints(Point(minHx, minHy), Point(maxHx, maxHy));
      ghostExit = Point(dxAvg, dy - 1);
    } else {
      house = const Rectangle(0, 0, 0, 0);
      ghostExit = const Point(0, 0);
    }

    pacSpawn = pac ?? _defaultSpawn();
    pelletCount = pellets.length + powerPellets.length;
  }

  /// Spawn por defecto: la celda caminable más cercana al centro horizontal de
  /// la casa, en la primera fila libre justo DEBAJO de la casa de fantasmas
  /// (no al fondo del mapa).
  Point<int> _defaultSpawn() {
    final cxHouse = ghostExit.x;
    for (var y = house.bottom + 2; y < height; y++) {
      for (var off = 0; off <= width; off++) {
        for (final x in [cxHouse - off, cxHouse + off]) {
          if (x < 0 || x >= width) continue;
          if (!isWall(x, y)) return Point(x, y);
        }
      }
    }
    return const Point(1, 1);
  }

  /// Pared para Pac-Man (incluye la puerta de la casa).
  bool isWall(int x, int y) {
    final k = _key(x, y);
    return _walls.contains(k) || _doors.contains(k);
  }

  /// Pared para fantasmas (la puerta es transitable).
  bool isWallForGhost(int x, int y) => _walls.contains(_key(x, y));

  bool isDoor(int x, int y) => _doors.contains(_key(x, y));
  bool isTunnelRow(int y) => _tunnelRows.contains(y);

  bool hasPellet(int x, int y) => pellets.contains(_key(x, y));
  bool hasPower(int x, int y) => powerPellets.contains(_key(x, y));

  /// Come el comestible en (x,y); devuelve 'pellet', 'power' o null.
  String? eat(int x, int y) {
    final k = _key(x, y);
    if (pellets.remove(k)) return 'pellet';
    if (powerPellets.remove(k)) return 'power';
    return null;
  }

  int get remaining => pellets.length + powerPellets.length;
  bool get cleared => remaining == 0;

  /// Reinicia los comestibles al estado inicial (reintento del mismo nivel).
  void resetPellets() {
    pellets.clear();
    powerPellets.clear();
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final c = rows[y][x];
        if (c == '.') pellets.add(_key(x, y));
        if (c == 'o') powerPellets.add(_key(x, y));
      }
    }
  }

  /// Normaliza una coordenada X con wrap en filas de túnel.
  int wrapX(int x, int y) {
    if (!isTunnelRow(y)) return x;
    if (x < 0) return width - 1;
    if (x >= width) return 0;
    return x;
  }
}

/// Mapa para un nivel. Los mapas rotan y se van cerrando para subir la
/// complejidad (ver [kPacmanMazeA]..[kPacmanMazeD]). Todos están validados
/// (simétricos, comestibles alcanzables, con casa+puerta+túnel).
List<String> mazeForLevel(int level) => switch (level) {
  1 || 2 => kPacmanMazeA,
  3 || 4 => kPacmanMazeC,
  5 || 6 || 9 => kPacmanMazeB,
  _ => kPacmanMazeD, // 7, 8, 10
};

/// Mapa A (validado): clásico y abierto. 232 comestibles.
const List<String> kPacmanMazeL1 = [
  '############################',
  '#............##............#',
  '#.####.#####.##.#####.####.#',
  '#o####.#####.##.#####.####o#',
  '#.####.#####.##.#####.####.#',
  '#..........................#',
  '#.####.##.########.##.####.#',
  '#.####.##.########.##.####.#',
  '#......##....##....##......#',
  '######.#####_##_#####.######',
  '######.#####_##_#####.######',
  '######.##__________##.######',
  '######.##_###==###_##.######',
  '######.##_#______#_##.######',
  '______.___#______#___.______',
  '######.##_#______#_##.######',
  '######.##_########_##.######',
  '######.##__________##.######',
  '######.#####_##_#####.######',
  '######.#####_##_#####.######',
  '#............##............#',
  '#.####.#####.##.#####.####.#',
  '#o..##.......##.......##..o#',
  '###.##.##.########.##.##.###',
  '#......##....##....##......#',
  '#.##########.##.##########.#',
  '#.##########.##.##########.#',
  '#..........................#',
  '############################',
];

/// Alias del mapa A (clásico y abierto).
const List<String> kPacmanMazeA = kPacmanMazeL1;

/// Mapa B (validado): pilares pequeños, muy laberíntico. 266 comestibles.
const List<String> kPacmanMazeB = [
  '############################',
  '#............##............#',
  '#.#.#.##.#.#.##.#.#.##.#.#.#',
  '#o#.#.##.#.#.##.#.#.##.#.#o#',
  '#...#.##.#...##...#.##.#...#',
  '#.#.#....#.#.##.#.#....#.#.#',
  '#.#.####.#.#.##.#.#.####.#.#',
  '#......##....##....##......#',
  '######.#####_##_#####.######',
  '######.#####_##_#####.######',
  '######.##__________##.######',
  '######.##_###==###_##.######',
  '######.##_#______#_##.######',
  '______.___#______#___.______',
  '######.##_#______#_##.######',
  '######.##_########_##.######',
  '######.##__________##.######',
  '######.#####_##_#####.######',
  '######.#####_##_#####.######',
  '#............##............#',
  '#.#.####.#.#.##.#.#.####.#.#',
  '#o#......#.#.##.#.#......#o#',
  '#.#.####.#.#.##.#.#.####.#.#',
  '#...#..#..#..##..#..#..#...#',
  '#.#.##.#.#.#.##.#.#.#.##.#.#',
  '#.#....#...#.##.#...#....#.#',
  '#............##............#',
  '############################',
];

/// Mapa C (validado): variante del clásico con otros bloques. 248 comestibles.
const List<String> kPacmanMazeC = [
  '############################',
  '#............##............#',
  '#.####.#####.##.#####.####.#',
  '#o####.#####.##.#####.####o#',
  '#.####.#####.##.#####.####.#',
  '#..........................#',
  '#.##.#.#.##.####.##.#.#.##.#',
  '#.##.#.#.##.####.##.#.#.##.#',
  '#......##....##....##......#',
  '######.#####_##_#####.######',
  '######.#####_##_#####.######',
  '######.##__________##.######',
  '######.##_###==###_##.######',
  '######.##_#______#_##.######',
  '______.___#______#___.______',
  '######.##_#______#_##.######',
  '######.##_########_##.######',
  '######.##__________##.######',
  '######.#####_##_#####.######',
  '######.#####_##_#####.######',
  '#............##............#',
  '#.####.#####.##.#####.####.#',
  '#o..##.......##.......##..o#',
  '###.##.##.########.##.##.###',
  '#......##....##....##......#',
  '#.##.####.##.##.##.####.##.#',
  '#.##.####.##.##.##.####.##.#',
  '#..........................#',
  '############################',
];

/// Mapa D (validado): pilares densos, el más cerrado. 258 comestibles.
const List<String> kPacmanMazeD = [
  '############################',
  '#............##............#',
  '#.#.##.#.##.####.##.#.##.#.#',
  '#o#.....#...####...#.....#o#',
  '#.#.###.###.####.###.###.#.#',
  '#...#.#.#...####...#.#.#...#',
  '#.#.#.#.#.#.####.#.#.#.#.#.#',
  '#......##....##....##......#',
  '######.#####_##_#####.######',
  '######.#####_##_#####.######',
  '######.##__________##.######',
  '######.##_###==###_##.######',
  '######.##_#______#_##.######',
  '______.___#______#___.______',
  '######.##_#______#_##.######',
  '######.##_########_##.######',
  '######.##__________##.######',
  '######.#####_##_#####.######',
  '######.#####_##_#####.######',
  '#............##............#',
  '#.##.#.#.##.####.##.#.#.##.#',
  '#o.#.#.#.#..####..#.#.#.#.o#',
  '#.##.#.#.##.####.##.#.#.##.#',
  '#....#.#....####....#.#....#',
  '#.##.#.#.##.####.##.#.#.##.#',
  '#.#.......#.####.#.......#.#',
  '#............##............#',
  '############################',
];
