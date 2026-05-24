import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_retro_app/app/features/invaders-game/presentation/logic/invaders_defs.dart';

void main() {
  group('LevelPlan.forLevel', () {
    test('escala columnas/filas con cota y dispara jefe cada 5 niveles', () {
      final l1 = LevelPlan.forLevel(1);
      expect(l1.cols, 5);
      expect(l1.rows, 3);
      expect(l1.hasBoss, isFalse);

      final l5 = LevelPlan.forLevel(5);
      expect(l5.hasBoss, isTrue);

      final l10 = LevelPlan.forLevel(10);
      expect(l10.cols, lessThanOrEqualTo(8));
      expect(l10.rows, lessThanOrEqualTo(5));
      expect(l10.hasBoss, isTrue);
      // A mayor nivel, los enemigos disparan más seguido (fireRate menor).
      expect(l10.fireRateMs, lessThan(l1.fireRateMs));
    });

    test('los enemigos de filas superiores son más duros en niveles altos', () {
      final plan = LevelPlan.forLevel(6);
      // Fila 0 (arriba) = tanque desde nivel 4.
      expect(plan.typeForRow(0, 6), EnemyType.tank);
      // Filas inferiores siguen siendo normales.
      expect(plan.typeForRow(plan.rows - 1, 6), EnemyType.normal);
    });
  });

  group('atributos de enemigo', () {
    test('vida y puntos por tipo son coherentes', () {
      expect(enemyHp(EnemyType.tank), greaterThan(enemyHp(EnemyType.normal)));
      expect(
        enemyPoints(EnemyType.tank),
        greaterThan(enemyPoints(EnemyType.normal)),
      );
    });
  });
}
