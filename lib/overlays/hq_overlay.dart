import 'package:flutter/material.dart';
import '../game/president_spacebar_game.dart';
import 'package:google_fonts/google_fonts.dart';

class HQOverlay extends StatelessWidget {
  final PresidentSpacebarGame game;
  const HQOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // Check if all activities are completed
    final allCompleted =
        game.gameState.completedMinigames.contains('car_racing') &&
        game.gameState.completedMinigames.contains('hurdles') &&
        game.gameState.completedMinigames.contains('debate');

    // If all completed, proceed to ending based on approval rating
    if (allCompleted) {
      // Use a microtask to avoid build errors
      Future.microtask(() {
        game.overlays.remove('HQOverlay');
        game.startDebate(isFinal: true);
      });
    }

    return Material(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.indigo.shade900],
            stops: const [0.3, 0.9],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Campaign HQ header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue.shade800,
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(70), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Column(
                  children: [
                    Text(
                      'CAMPAIGN HEADQUARTERS',
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Approval Rating: ${game.gameState.approval.toStringAsFixed(0)}%',
                      style: GoogleFonts.raleway(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    // Progress bar for approval rating
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: game.gameState.approval / 100,
                        backgroundColor: Colors.grey.shade800,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          game.gameState.approval > 50 ? Colors.green.shade400 : Colors.orange,
                        ),
                        minHeight: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Day schedule heading
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      'Today\'s Campaign Schedule',
                      style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Campaign activities - NPC visits and debate
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      // Presidential Debate (now first)
                      _buildEventButton(
                        context,
                        'Attend Presidential Debate',
                        'debate',
                        const Icon(Icons.campaign, color: Colors.amber, size: 32),
                        Colors.red.shade700,
                        'Debate against your opponent to improve your approval rating',
                        // If debate not completed, allow attending
                        game.gameState.completedMinigames.contains('debate')
                            ? null
                            : () {
                              game.overlays.remove('HQOverlay');
                              game.startDebate(isFinal: false);
                            },
                      ),

                      const SizedBox(height: 16),

                      // Visit Key A - Athletic key (Hurdles minigame)
                      _buildEventButton(
                        context,
                        'Visit Key A',
                        'keyA',
                        Image.asset(
                          'assets/images/a.png',
                          width: 96,
                          height: 96,
                          errorBuilder:
                              (_, __, ___) => Icon(Icons.directions_run, color: Colors.green.shade300, size: 32),
                        ),
                        Colors.green.shade700,
                        'Athletic champion who could boost your sports credentials',
                        // Check if Key A's specific hurdles minigame is completed
                        game.gameState.completedMinigames.contains('keyA_hurdles')
                            ? null
                            : () {
                              // Check again if the minigame is completed to prevent black screen
                              if (game.gameState.completedMinigames.contains('keyA_hurdles')) {
                                // Already completed, do nothing
                                print('Key A hurdles already completed, not showing dialogue');
                              } else {
                                game.overlays.remove('HQOverlay');
                                game.overlays.add('NPCDialogueOverlay_keyA');
                              }
                            },
                      ),

                      const SizedBox(height: 16),

                      // Visit Key E - Entrepreneur key (Car Racing minigame)
                      _buildEventButton(
                        context,
                        'Visit Key E',
                        'keyE',
                        Image.asset(
                          'assets/images/e.png',
                          width: 96,
                          height: 96,
                          errorBuilder: (_, __, ___) => Icon(Icons.electric_car, color: Colors.blue.shade200, size: 32),
                        ),
                        Colors.blue.shade700,
                        'Tech entrepreneur & fitness enthusiast who values both innovation and athletics',
                        // Check if Key E's specific hurdles minigame is completed
                        game.gameState.completedMinigames.contains('keyE_hurdles')
                            ? null
                            : () {
                              // Check again if the minigame is completed to prevent black screen
                              if (game.gameState.completedMinigames.contains('keyE_hurdles')) {
                                // Already completed, do nothing
                                print('Key E hurdles already completed, not showing dialogue');
                              } else {
                                game.overlays.remove('HQOverlay');
                                game.overlays.add('NPCDialogueOverlay_keyE');
                              }
                            },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventButton(
    BuildContext context,
    String label,
    String id, [
    Widget? leadingIcon,
    Color? cardColor,
    String? description,
    VoidCallback? onPressed,
  ]) {
    // Map NPC IDs to minigame IDs
    String checkId = id;
    if (id == 'keyA') checkId = 'hurdles';
    if (id == 'keyE') checkId = 'car_racing';

    // Use the game instance passed to the constructor
    final completed = game.gameState.completedMinigames.contains(checkId);
    final result = game.gameState.minigameResults[checkId];

    // Default handling for debate, otherwise use custom NPC handlers
    final isDebate = id == 'debate';
    defaultAction() {
      game.overlays.remove('HQOverlay');
      if (isDebate) {
        game.startMinigame(id);
      } else {
        // This is handled by the custom onPressed for NPCs
      }
    }

    return Container(
      decoration: BoxDecoration(
        color:
            completed
                ? (result == true ? Colors.green.shade700.withAlpha(200) : Colors.red.shade700.withAlpha(180))
                : cardColor?.withAlpha(180) ?? Colors.white.withAlpha(40),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(60), blurRadius: 8, offset: const Offset(0, 3))],
        border: Border.all(
          color:
              completed ? (result == true ? Colors.green.shade300 : Colors.red.shade300) : Colors.white.withAlpha(100),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: completed ? null : (onPressed ?? defaultAction),
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withAlpha(50),
          highlightColor: Colors.white.withAlpha(30),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row with icon and label
                Row(
                  children: [
                    // Leading icon
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(color: Colors.white.withAlpha(30), shape: BoxShape.circle),
                      child:
                          leadingIcon ?? Icon(isDebate ? Icons.campaign : Icons.event, size: 24, color: Colors.white),
                    ),
                    const SizedBox(width: 12),

                    // Label
                    Expanded(
                      child: Text(
                        label,
                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),

                    // Status indicator
                    if (completed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              result == true
                                  ? Colors.green.shade300.withAlpha(150)
                                  : Colors.red.shade300.withAlpha(150),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              result == true ? Icons.check_circle_outline : Icons.cancel_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              result == true ? 'SUCCESS' : 'FAILED',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                if (description != null) ...[
                  const SizedBox(height: 12),
                  Text(description, style: GoogleFonts.raleway(fontSize: 14, color: Colors.white.withAlpha(220))),
                ],

                // Action button
                if (!completed) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isDebate ? 'Attend' : 'Visit',
                              style: GoogleFonts.raleway(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
