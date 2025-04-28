import 'package:flutter/foundation.dart';

/// Global mutable game data (approval %, completed minigames, etc.).
class GameState extends ChangeNotifier {
  double approval = 50; // starts at 50 %
  final Set<String> completedMinigames = {};
  // Map to track win/loss status for each minigame
  final Map<String, bool> minigameResults = {};

  void addApproval(double delta) {
    approval += delta;
    if (approval < 0) approval = 0;
    if (approval > 100) approval = 100;
    notifyListeners();
  }

  bool get isGameWon => approval >= 51;

  bool isMinigameCompleted(String name) => completedMinigames.contains(name);

  void markMinigameCompleted(String name, {bool didWin = false}) {
    completedMinigames.add(name);
    minigameResults[name] = didWin;
    notifyListeners();
  }
  
  // Get the win/loss status for a minigame
  bool? getMinigameResult(String name) {
    return minigameResults[name];
  }
}
