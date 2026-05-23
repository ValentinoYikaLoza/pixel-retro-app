import 'package:flutter/material.dart';
import 'package:pixel_retro_app/app/config/constants/app_colors.dart';
import 'package:pixel_retro_app/app/features/tetris-game/presentation/logic/tetromino.dart';
import 'package:pixel_retro_app/app/features/tetris-game/presentation/providers/tetris_game_provider.dart';

/// Tablero de Tetris: dibuja la grilla, los bloques fijos, la pieza fantasma
/// (sombra de caída) y la pieza activa. Mantiene la proporción 1:2.
class TetrisBoard extends StatelessWidget {
  final TetrisGameState state;

  /// Overlay opcional (game over / pausa) dibujado dentro del tablero.
  final Widget? overlay;

  const TetrisBoard({super.key, required this.state, this.overlay});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: state.gridWidth / state.gridHeight,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.backgroundDark,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.neonPurple, width: 3),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _BoardPainter(state))),
            if (overlay != null) Positioned.fill(child: overlay!),
          ],
        ),
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  final TetrisGameState state;

  _BoardPainter(this.state);

  @override
  void paint(Canvas canvas, Size size) {
    final gw = state.gridWidth;
    final gh = state.gridHeight;
    if (gw <= 0 || gh <= 0) return;
    final cell = size.width / gw;

    // Líneas de la grilla (tenues).
    final grid = Paint()
      ..color = AppColors.neonPurple.withValues(alpha: 0.08)
      ..strokeWidth = 0.5;
    for (var x = 1; x < gw; x++) {
      canvas.drawLine(Offset(x * cell, 0), Offset(x * cell, size.height), grid);
    }
    for (var y = 1; y < gh; y++) {
      canvas.drawLine(Offset(0, y * cell), Offset(size.width, y * cell), grid);
    }

    // Bloques fijos.
    for (var y = 0; y < state.board.length; y++) {
      for (var x = 0; x < state.board[y].length; x++) {
        final c = state.board[y][x];
        if (c != null) _block(canvas, x, y, cell, c);
      }
    }

    final type = state.currentType;
    if (type == null) return;
    final shape = Tetromino.shapes[type]![state.currentRotation];

    // Fantasma (sombra de caída).
    if (state.ghostY != state.currentY) {
      for (final c in shape) {
        final ax = state.currentX + c[0];
        final ay = state.ghostY + c[1];
        if (ay >= 0) _ghost(canvas, ax, ay, cell, Tetromino.colors[type]!);
      }
    }

    // Pieza activa.
    final color = Tetromino.colors[type]!;
    for (final c in shape) {
      final ax = state.currentX + c[0];
      final ay = state.currentY + c[1];
      if (ay >= 0) _block(canvas, ax, ay, cell, color);
    }
  }

  void _block(Canvas canvas, int x, int y, double cell, Color color) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x * cell + 0.5, y * cell + 0.5, cell - 1, cell - 1),
      Radius.circular(cell * 0.18),
    );
    canvas.drawRRect(rect, Paint()..color = color);
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.25),
    );
  }

  void _ghost(Canvas canvas, int x, int y, double cell, Color color) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x * cell + 0.5, y * cell + 0.5, cell - 1, cell - 1),
      Radius.circular(cell * 0.18),
    );
    canvas.drawRRect(rect, Paint()..color = color.withValues(alpha: 0.18));
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color.withValues(alpha: 0.6),
    );
  }

  @override
  bool shouldRepaint(_BoardPainter oldDelegate) => oldDelegate.state != state;
}

/// Miniatura de una pieza (para "siguiente" y "hold"). Si [type] es null,
/// muestra la caja vacía.
class PiecePreview extends StatelessWidget {
  final PieceType? type;
  final double size;

  const PiecePreview({super.key, required this.type, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.neonPurple.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: type == null ? null : CustomPaint(painter: _PiecePainter(type!)),
    );
  }
}

class _PiecePainter extends CustomPainter {
  final PieceType type;

  _PiecePainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    final shape = Tetromino.shapes[type]![0];
    // Bounding box de la pieza en estado 0.
    var minX = 4, maxX = 0, minY = 4, maxY = 0;
    for (final c in shape) {
      minX = c[0] < minX ? c[0] : minX;
      maxX = c[0] > maxX ? c[0] : maxX;
      minY = c[1] < minY ? c[1] : minY;
      maxY = c[1] > maxY ? c[1] : maxY;
    }
    final wCells = (maxX - minX + 1);
    final hCells = (maxY - minY + 1);
    final cell = (size.width / 4).clamp(0.0, size.height / 4);
    final offX = (size.width - wCells * cell) / 2 - minX * cell;
    final offY = (size.height - hCells * cell) / 2 - minY * cell;
    final color = Tetromino.colors[type]!;

    for (final c in shape) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          offX + c[0] * cell + 0.5,
          offY + c[1] * cell + 0.5,
          cell - 1,
          cell - 1,
        ),
        Radius.circular(cell * 0.18),
      );
      canvas.drawRRect(rect, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_PiecePainter oldDelegate) => oldDelegate.type != type;
}
