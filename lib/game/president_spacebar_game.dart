import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/parallax.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';

// Audio handled in overlay widgets via FlameAudio

import 'game_state.dart';

class PresidentSpacebarGame extends FlameGame with TapDetector {
  final GameState gameState = GameState();
  bool _isFinalDebate = false;

  String? _currentMinigame;
  String? _currentNPC; // Track which NPC initiated the minigame

  @override
  Color backgroundColor() => Colors.black;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadParallax();
    await _loadAudio();
    overlays.add('MenuOverlay');
    // Start menu music
    FlameAudio.bgm.play('mainmenu.mp3');
  }
  
  // Load all audio assets
  Future<void> _loadAudio() async {
    // Preload sound effects
    await FlameAudio.audioCache.loadAll([
      'boo.mp3',
      'clap.mp3',
      'click.wav',
      'intro.mp3',
      'mainmenu.mp3',
    ]);
  }
  
  // Play button click sound
  void playClickSound() {
    FlameAudio.play('click.wav');
  }
  
  // Play positive feedback sound
  void playPositiveSound() {
    FlameAudio.play('clap.mp3');
  }
  
  // Play negative feedback sound
  void playNegativeSound() {
    FlameAudio.play('boo.mp3');
  }

  Future<void> _loadParallax() async {
    final parallax = await ParallaxComponent.load([
      // ParallaxImageData('parallax/layer_0.png'),
      // ParallaxImageData('parallax/layer_1.png'),
      // ParallaxImageData('parallax/layer_2.png'),
    ], baseVelocity: Vector2(10, 0));
    add(parallax);
  }

  // Flow helpers
  void playIntro() {
    // Stop menu music and play intro music
    FlameAudio.bgm.stop();
    FlameAudio.bgm.play('intro.mp3');
    overlays.add('CutsceneOverlay');
  }

  void startDebate({required bool isFinal}) {
    _isFinalDebate = isFinal;
    overlays.add('DebateOverlay');
  }

  void debateFinished({required bool isFinal}) {
    // Mark debate as completed so it can't be attended again
    gameState.markMinigameCompleted('debate', didWin: true);
    
    if (isFinal) {
      overlays.add('EndingOverlay');
    } else {
      overlays.add('HQOverlay');
    }
  }

  void openCredits() {
    playClickSound();
    overlays.remove('MenuOverlay');
    overlays.add('CreditsOverlay');
  }

  void openControls() {
    playClickSound();
    overlays.remove('MenuOverlay');
    overlays.add('ControlsOverlay');
  }

  void startMinigame(String name, {String? npcId}) {
    print('Starting minigame: $name for NPC: $npcId');
    _currentMinigame = name;
    _currentNPC = npcId; // Store the NPC ID that initiated the minigame
    overlays.add('MinigameOverlay');
  }

  void finishMinigame(bool won) {
    print('Finishing minigame with result: $won');
    print('Current minigame: $_currentMinigame, Current NPC: $_currentNPC');
    
    overlays.remove('MinigameOverlay');
    if (_currentMinigame == null) {
      print('Warning: No current minigame to finish');
      overlays.add('HQOverlay');
      return;
    }
    
    // If there's an NPC associated with this minigame, track it specifically
    if (_currentNPC != null) {
      // Create a unique identifier for this NPC's minigame completion
      String npcMinigameId = '${_currentNPC}_${_currentMinigame}';
      print('Marking NPC-specific minigame as completed: $npcMinigameId');
      // Mark the NPC-specific minigame as completed
      gameState.markMinigameCompleted(npcMinigameId, didWin: won);
      
      // Print the current state of completed minigames for debugging
      print('Completed minigames: ${gameState.completedMinigames}');
    } else {
      print('Warning: No NPC associated with this minigame');
    }
    
    // Also mark the general minigame as completed (for backward compatibility)
    gameState.markMinigameCompleted(_currentMinigame!, didWin: won);
    gameState.addApproval(won ? 10 : -10);
    
    // Reset tracking variables
    _currentMinigame = null;
    _currentNPC = null;
    
    // Return to HQ
    overlays.add('HQOverlay');
  }

  bool get isFinalDebate => _isFinalDebate;

  String? get currentMinigame => _currentMinigame;
}
