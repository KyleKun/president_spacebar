import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game/president_spacebar_game.dart';
import 'overlays/overlays.dart';
import 'overlays/npc_dialogue_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final game = PresidentSpacebarGame();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'President Spacebar',
    theme: ThemeData.dark(),
    home: GameWidget(
      game: game,
      overlayBuilderMap: {
        'MenuOverlay': (ctx, g) => MenuOverlay(game: g as PresidentSpacebarGame),
        'ControlsOverlay': (ctx, g) => ControlsOverlay(game: g as PresidentSpacebarGame),
        'CreditsOverlay': (ctx, g) => CreditsOverlay(game: g as PresidentSpacebarGame),
        'DebateOverlay': (ctx, g) => DebateOverlay(game: g as PresidentSpacebarGame),
        'HQOverlay': (ctx, g) => HQOverlay(game: g as PresidentSpacebarGame),
        'MinigameOverlay': (ctx, g) => MinigameOverlay(game: g as PresidentSpacebarGame),
        'EndingOverlay': (ctx, g) => EndingOverlay(game: g as PresidentSpacebarGame),
        'CutsceneOverlay': (ctx, g) => CutsceneOverlay(game: g as PresidentSpacebarGame),
        'NPCDialogueOverlay_keyA': (ctx, g) => NPCDialogueOverlay(game: g as PresidentSpacebarGame, npcId: 'keyA'),
        'NPCDialogueOverlay_keyE': (ctx, g) => NPCDialogueOverlay(game: g as PresidentSpacebarGame, npcId: 'keyE'),
      },
      initialActiveOverlays: const ['MenuOverlay'],
    ),
  ));
}
