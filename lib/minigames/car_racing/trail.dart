import 'dart:ui';

import 'package:flame/components.dart';

import 'package:president_spacebar/minigames/car_racing/car.dart';
import 'package:president_spacebar/minigames/car_racing/tire.dart';

class Trail extends Component with HasPaint {
  Trail({required this.car, required this.tire}) : super(priority: 1);

  final Car car;
  final Tire tire;

  final trail = <Offset>[];
  final _trailLength = 30;

  @override
  Future<void> onLoad() async {
    paint
      ..color = (tire.paint.color.withValues(alpha: 0.9))
      ..strokeWidth = 1.0;
  }

  @override
  void update(double dt) {
    if (tire.body.linearVelocity.length2 > 100) {
      if (trail.length > _trailLength) {
        trail.removeAt(0);
      }
      final trailPoint = tire.body.position.toOffset();
      trail.add(trailPoint);
    } else if (trail.isNotEmpty) {
      trail.removeAt(0);
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawPoints(PointMode.polygon, trail, paint);
  }
}
