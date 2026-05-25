import 'pacman_maze.dart';

/// Los 4 fantasmas clásicos, cada uno con su personalidad de persecución.
enum GhostType { blinky, pinky, inky, clyde }

/// Estado de un fantasma.
/// - [house]: esperando dentro de la casa (rebota) hasta su turno de salir.
/// - [leaving]: saliendo de la casa hacia la puerta.
/// - [scatter]: va a su esquina (fase de dispersión).
/// - [chase]: persigue según su personalidad.
/// - [frightened]: huye (tras un power pellet); Pac-Man puede comerlo.
/// - [eaten]: solo ojos, vuelve a la casa a regenerarse.
enum GhostMode { house, leaving, scatter, chase, frightened, eaten }

/// Fantasma con posición sub-tile (tile + progreso 0..1 hacia el siguiente en
/// [dir]), igual que Pac-Man.
class Ghost {
  Ghost(
    this.type,
    this.tx,
    this.ty, {
    this.mode = GhostMode.house,
    this.dir = PacDir.up,
    this.releaseAtMs = 0,
  });

  final GhostType type;
  int tx, ty;
  double prog = 0;
  PacDir dir;
  GhostMode mode;

  /// Momento (ms del cronómetro de partida) en que sale de la casa.
  int releaseAtMs;

  double get px => tx + dir.vec.x * prog;
  double get py => ty + dir.vec.y * prog;

  bool get inMaze => mode == GhostMode.scatter || mode == GhostMode.chase;
}
