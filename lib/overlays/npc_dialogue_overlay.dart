import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/president_spacebar_game.dart';

// Question class to replace tuple
class NPCQuestion {
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String incorrectFeedback;
  final String correctFeedback;

  NPCQuestion({
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.incorrectFeedback,
    required this.correctFeedback,
  });
}

class NPCDialogueOverlay extends StatefulWidget {
  final PresidentSpacebarGame game;
  final String npcId; // 'keyE' or 'keyA'

  const NPCDialogueOverlay({super.key, required this.game, required this.npcId});

  @override
  State<NPCDialogueOverlay> createState() => _NPCDialogueOverlayState();
}

class _NPCDialogueOverlayState extends State<NPCDialogueOverlay> {
  int dialogueIndex = 0;
  String? feedbackText;
  bool? lastAnswerCorrect;
  int supportLikelihood = 50; // Starting at 50%
  bool showQuestion = false;
  bool showChallenge = false;

  // NPC data
  late final String npcName;
  late final String npcTitle;
  late final String npcAvatar;
  late final String minigameId;
  late final Color npcColor;
  late final List<String> introDialogues;
  late final NPCQuestion question;
  late final String challengeText;

  @override
  void initState() {
    super.initState();

    // Set NPC-specific data
    if (widget.npcId == 'keyE') {
      npcName = 'Key E';
      npcTitle = 'Tech Entrepreneur & Fitness Enthusiast';
      npcAvatar = '⌨️ E';
      npcColor = Colors.blue;
      minigameId = 'hurdles';

      introDialogues = [
        "Well hello there, candidate Spacebar! I'm Key E, founder and CEO of KeyMotors.",
        "While I'm known for my tech innovations, I also pride myself on my athletic abilities.",
        "Many don't know this, but I trained with Key A years ago before going into business.",
        "I still maintain a rigorous fitness routine - a healthy body leads to a healthy mind and business!",
        "As a prominent business leader, my endorsement could significantly help your campaign.",
      ];

      question = NPCQuestion(
        questionText: "What's your position on keyboard innovation and fitness programs?",
        options: ['Focus on innovation over physical training', 'Balance innovation with fitness incentives'],
        correctOptionIndex: 1,
        incorrectFeedback:
            "I believe in both innovation AND physical excellence. I'm disappointed by your one-sided stance.",
        correctFeedback:
            "A politician who understands the connection between mind and body! I appreciate your balanced approach.",
      );

      challengeText =
          "Tell you what - cars are impressive, but real speed comes from personal fitness! I challenge you to a hurdles race. If you can score at least 1000 points, I'll consider supporting your campaign publicly. Are you up for the challenge?";
    } else {
      npcName = 'Key A';
      npcTitle = 'Olympic Hurdler';
      npcAvatar = '⌨️ A';
      npcColor = Colors.green;
      minigameId = 'hurdles';

      introDialogues = [
        "My brother, I'm no simple key. I am a Three-time gold medalist in the Keyboard Olympics hurdles competition.",
        "When I'm not typing at the front of words, I'm training to stay the fastest key in the field.",
        "Physical fitness is incredibly important for all keys. We can't let ourselves get stuck or slow down.",
        "I've been watching your campaign with interest. Athletic keys like me need a president who values physical education.",
        "My endorsement carries significant weight in the sports community, which could be valuable for your campaign.",
      ];

      question = NPCQuestion(
        questionText: "What would your administration do for keyboard sports funding?",
        options: ['Focus on education over sports funding', 'Increase funding for keyboard athletics'],
        correctOptionIndex: 1,
        incorrectFeedback: "That's disappointing. The keyboard needs physical fitness as much as education.",
        correctFeedback: "That's what I like to hear! A healthy keyboard is a productive keyboard!",
      );

      challengeText =
          "Let's see if you can back up your words with action! I challenge you to a hurdles race. If you can score at least 1000 points, I'll support your campaign. What do you say?";
    }
    
    // Now that minigameId is initialized, check if this NPC's minigame is already completed
    final npcMinigameId = '${widget.npcId}_$minigameId';
    if (widget.game.gameState.completedMinigames.contains(npcMinigameId)) {
      print('This NPC\'s minigame is already completed: $npcMinigameId');
      // If already completed, return to HQ immediately
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.game.overlays.remove('NPCDialogueOverlay_${widget.npcId}');
        widget.game.overlays.add('HQOverlay');
      });
    }
  }

  void _selectAnswer(int idx) {
    final correct = question.correctOptionIndex == idx;
    final change = correct ? 25 : -20;

    // Play appropriate sound effect
    if (correct) {
      widget.game.playPositiveSound();
    } else {
      widget.game.playNegativeSound();
    }

    setState(() {
      // Show feedback text based on whether the answer was correct
      feedbackText = correct ? question.correctFeedback : question.incorrectFeedback;
      lastAnswerCorrect = correct;
      supportLikelihood = (supportLikelihood + change).clamp(0, 100);
    });

    // Delay moving to the challenge after feedback
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          feedbackText = null;
          showChallenge = true;
        });
      }
    });
  }

  void _advanceDialogue() {
    widget.game.playClickSound();
    setState(() {
      if (dialogueIndex < introDialogues.length - 1) {
        // Move to next dialogue line
        dialogueIndex++;
      } else {
        // After all intro dialogues, show the question
        showQuestion = true;
      }
    });
  }

  void _startMinigame() {
    widget.game.playClickSound();
    // Remove this overlay
    widget.game.overlays.remove('NPCDialogueOverlay_${widget.npcId}');

    // Start the corresponding minigame and pass the NPC ID
    widget.game.startMinigame(minigameId, npcId: widget.npcId);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      // Use a solid color as fallback in case of any rendering issues
      color: Colors.black,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade900.withAlpha(240), npcColor.withAlpha(150)],
          ),
        ),
        // Use a simple child instead of BackdropFilter
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // NPC info bar
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    color: npcColor.withAlpha(200),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 8, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    children: [
                      // NPC Avatar
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: npcColor, width: 3),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/${widget.npcId == "keyE" ? "e" : "a"}.png',
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Center(
                                  child: Text(
                                    npcAvatar,
                                    style: GoogleFonts.robotoMono(fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // NPC Name & Title
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            npcName,
                            style: GoogleFonts.montserrat(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            npcTitle,
                            style: GoogleFonts.raleway(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withAlpha(220),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Support meter
                      Column(
                        children: [
                          Text(
                            'Support Likelihood',
                            style: GoogleFonts.raleway(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 100,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Stack(
                              children: [
                                // Progress bar
                                FractionallySizedBox(
                                  widthFactor: supportLikelihood / 100,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.orange, Colors.yellow],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                // Percentage
                                Center(
                                  child: Text(
                                    '$supportLikelihood%',
                                    style: GoogleFonts.robotoMono(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),
                const Spacer(),

                // Dialogue content area
                if (!showQuestion && !showChallenge) _buildIntroDialogue(),
                if (showQuestion && feedbackText == null && !showChallenge) _buildQuestion(),
                if (feedbackText != null) _buildFeedback(),
                if (showChallenge) _buildChallenge(),
                SizedBox(height: 10),
                // Continue button/close button
                if (!showQuestion && !showChallenge) _buildContinueButton(),
                if (showChallenge) _buildAcceptChallengeButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroDialogue() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(230),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Large Key image in the center
          Container(
            width: 200,
            height: 200,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: npcColor, width: 4),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(70), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/${widget.npcId == "keyE" ? "e" : "a"}.png',
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Center(
                      child: Text(npcAvatar, style: GoogleFonts.robotoMono(fontSize: 72, fontWeight: FontWeight.bold)),
                    ),
              ),
            ),
          ),
          Text(
            introDialogues[dialogueIndex],
            style: GoogleFonts.raleway(fontSize: 18, height: 1.5, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${dialogueIndex + 1}/${introDialogues.length}',
                style: GoogleFonts.robotoMono(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(230),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          // Large Key image in the center
          Container(
            width: 180,
            height: 180,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: npcColor, width: 4),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(70), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/${widget.npcId == "keyE" ? "e" : "a"}.png',
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Center(
                      child: Text(npcAvatar, style: GoogleFonts.robotoMono(fontSize: 64, fontWeight: FontWeight.bold)),
                    ),
              ),
            ),
          ),
          Text(
            question.questionText,
            style: GoogleFonts.raleway(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Answer options
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: question.options.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _selectAnswer(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: npcColor.withAlpha(230),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 3,
                    ),
                    child: Text(
                      question.options[index],
                      style: GoogleFonts.raleway(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeedback() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lastAnswerCorrect == true ? Colors.green.shade700.withAlpha(230) : Colors.red.shade700.withAlpha(230),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(70), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Text(
            feedbackText!,
            style: GoogleFonts.raleway(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(lastAnswerCorrect == true ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                lastAnswerCorrect == true ? '+25% Support' : '-20% Support',
                style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChallenge() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: npcColor.withAlpha(50),
        border: Border.all(color: npcColor.withAlpha(150), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Large Key image in the center with challenge icon
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 180,
                height: 180,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: npcColor, width: 4),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(70), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/${widget.npcId == "keyE" ? "e" : "a"}.png',
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Center(
                          child: Text(
                            npcAvatar,
                            style: GoogleFonts.robotoMono(fontSize: 64, fontWeight: FontWeight.bold),
                          ),
                        ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Challenge text
          Text(
            challengeText,
            style: GoogleFonts.raleway(fontSize: 18, height: 1.5, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: _advanceDialogue,
      style: ElevatedButton.styleFrom(
        backgroundColor: npcColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Continue', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward),
        ],
      ),
    );
  }

  Widget _buildAcceptChallengeButton() {
    return ElevatedButton(
      onPressed: _startMinigame,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 5,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Accept Challenge', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Icon(widget.npcId == 'keyE' ? Icons.flag : Icons.flag),
        ],
      ),
    );
  }
}
