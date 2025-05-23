import 'dart:math';
import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle, World;
import 'package:flutter/material.dart' hide Image, Gradient;
import 'package:president_spacebar/game/game_colors.dart';
import 'package:president_spacebar/minigames/car_racing/car.dart';

class LapLine extends BodyComponent with ContactCallbacks {
  LapLine(this.id, this.initialPosition, this.size, {required this.isFinish}) : super(priority: 1);

  final int id;
  final bool isFinish;
  final Vector2 initialPosition;
  final Vector2 size;
  late final Rect rect = size.toRect();
  Image? _finishOverlay;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    if (isFinish) {
      _finishOverlay = await createFinishOverlay();
    }
  }

  @override
  Body createBody() {
    paint.color = (isFinish ? GameColors.green.color : GameColors.green.color)..withValues(alpha: 0.5);
    paint
      ..style = PaintingStyle.fill
      ..shader = Gradient.radial((size / 2).toOffset(), max(size.x, size.y), [paint.color, Colors.black]);

    final groundBody = world.createBody(BodyDef(position: initialPosition, userData: this));
    final shape = PolygonShape()..setAsBoxXY(size.x / 2, size.y / 2);
    final fixtureDef = FixtureDef(shape, isSensor: true);
    return groundBody..createFixture(fixtureDef);
  }

  late final Rect _scaledRect = (size * 10).toRect();
  late final Rect _drawRect = size.toRect();

  Future<Image> createFinishOverlay() {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, _scaledRect);
    final step = _scaledRect.width / 2;
    final black = BasicPalette.black.paint();

    for (var i = 0; i * step < _scaledRect.height; i++) {
      canvas.drawRect(Rect.fromLTWH(i.isEven ? 0 : step, i * step, step, step), black);
    }
    final picture = recorder.endRecording();
    return picture.toImage(_scaledRect.width.toInt(), _scaledRect.height.toInt());
  }

  @override
  void render(Canvas canvas) {
    canvas.translate(-size.x / 2, -size.y / 2);
    canvas.drawRect(rect, paint);
    if (_finishOverlay != null) {
      canvas.drawImageRect(_finishOverlay!, _scaledRect, _drawRect, paint);
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is! Car) {
      return;
    }
    
    if (isFinish) {
      // The finish line is the checkpoint for completing a lap
      // Check if a car has passed at least 3 checkpoints (all non-finish checkpoints)
      if (other.passedStartControl.length >= 3) {
        // If all checkpoints were passed, increment lap counter
        other.lapNotifier.value++;
        // Clear the checkpoints to start fresh for the next lap
        other.passedStartControl.clear();
      }
    } else {
      // For non-finish checkpoints, add them to the car's passed checkpoints
      // Avoid duplicating checkpoints
      if (!other.passedStartControl.any((checkpoint) => checkpoint.id == id)) {
        other.passedStartControl.add(this);
      }
    }
  }
}
