import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_retro_app/app/features/tetris-game/presentation/logic/tetromino.dart';

void main() {
  group('Tetromino', () {
    test('every piece has 4 rotation states with 4 cells each', () {
      for (final type in PieceType.values) {
        final states = Tetromino.shapes[type];
        expect(states, isNotNull, reason: 'falta shape de $type');
        expect(states!.length, 4, reason: '$type debe tener 4 estados');
        for (final state in states) {
          expect(state.length, 4, reason: '$type: cada estado tiene 4 celdas');
          for (final cell in state) {
            expect(cell.length, 2);
            expect(cell[0], inInclusiveRange(0, 3));
            expect(cell[1], inInclusiveRange(0, 3));
          }
        }
      }
    });

    test('every piece has a color', () {
      for (final type in PieceType.values) {
        expect(
          Tetromino.colors[type],
          isNotNull,
          reason: 'falta color de $type',
        );
      }
    });

    test('SRS kicks exist for all JLSTZ/I transitions and start at (0,0)', () {
      const transitions = [
        '0>1',
        '1>0',
        '1>2',
        '2>1',
        '2>3',
        '3>2',
        '3>0',
        '0>3',
      ];
      for (final t in [PieceType.t, PieceType.i]) {
        final from = int.parse(transitions.first[0]);
        // Verifica una transición representativa por tipo + que el primer
        // intento sea sin desplazamiento.
        for (final tr in transitions) {
          final f = int.parse(tr[0]);
          final to = int.parse(tr[2]);
          final kicks = Tetromino.kicks(t, f, to);
          expect(kicks, isNotEmpty);
          expect(kicks.first, [0, 0]);
        }
        expect(from, 0);
      }
    });

    test('O piece has no real kicks (only identity)', () {
      expect(Tetromino.kicks(PieceType.o, 0, 1), [
        [0, 0],
      ]);
    });
  });
}
