import 'package:flutter/material.dart';
import '../game/president_spacebar_game.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;

class DebateOverlay extends StatefulWidget {
  final PresidentSpacebarGame game;
  const DebateOverlay({super.key, required this.game});

  @override
  State<DebateOverlay> createState() => _DebateOverlayState();
}

class _DebateOverlayState extends State<DebateOverlay> {
  int questionIndex = 0;
  String? feedbackText;
  bool? lastAnswerCorrect;
  late List<(String, List<String>, int, String, String)> questions;

  // Questions for regular debates
  final List<(String, List<String>, int, String, String)> regularDebateQuestions = [
    (
      'Should we remove numpad exclusivity and allow other keys to occupy the numpad?',
      ['Yes, equality for all keys', 'No, preserve numpad tradition'],
      1,
      'The numbers are angry and think you\'re attacking a minority. You lost their confidence! (-5%)',
      'The numpad keys are very happy with your position and are more likely to vote for you! (+5%)',
    ),
    (
      'What is your position on the Caps Lock key\'s constant shouting?',
      ['Caps Lock should be silenced past 10pm', 'Let Caps Lock express itself freely'],
      0,
      'The quiet keys aren\'t happy with your stance on noise control in the keyboard! (-5%)',
      'The Caps Lock supporters think you\'re suppressing free speech, but still agree with your policy! (+5%)',
    ),
    (
      'Should Function keys have more functions or fewer responsibilities?',
      ['More functions, they\'re underutilized', 'Fewer functions, they\'re overworked'],
      1,
      'The Function keys union is planning a strike against your workaholic policies! (-5%)',
      'The Function keys are relieved by your compassionate approach to work-life balance! (+5%)',
    ),
    (
      'Do you support the Tab key\'s request for more spacing in documents?',
      ['No, spaces are sufficient', 'Yes, tabs deserve more room'],
      1,
      'The Tab key community feels marginalized by your position! (-5%)',
      'The Tab key and its supporters are celebrating your progressive stance! (+5%)',
    ),
  ];

  // Questions for the final debate with higher stakes
  final List<(String, List<String>, int, String, String)> finalDebateQuestions = [
    (
      'What is your stance on the great Delete vs Backspace controversy?',
      ['Delete is more efficient', 'Backspace has a better tradition'],
      1,
      'The forward-thinking Delete faction is outraged by your conservative view! (-10%)',
      'The traditional Backspace supporters strongly rally behind your respect for keyboard heritage! (+10%)',
    ),
    (
      'As president, would you prioritize mechanical keys or membrane keys?',
      ['Mechanical keys are superior', 'Membrane keys are the future'],
      0,
      'The mainstream membrane key demographic feels alienated by your elitist stance! (-10%)',
      'The influential mechanical key enthusiasts are thrilled with your commitment to quality! (+10%)',
    ),
    (
      'What is your plan for the underutilized Print Screen and Scroll Lock keys?',
      ['Repurpose them for modern functions', 'Preserve their historical significance'],
      0,
      'The keyboard preservationists accuse you of erasing history! (-10%)',
      'The progressive keys applaud your innovative approach to keyboard modernization! (+10%)',
    ),
    (
      'Will you support the controversial QWERTY to DVORAK transition program?',
      ['Yes, efficiency should prevail', 'No, QWERTY tradition must be respected'],
      1,
      'The efficiency-minded DVORAK supporters call you technologically backward! (-10%)',
      'The vast majority of QWERTY users are relieved by your commitment to stability! (+10%)',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Select the appropriate question set based on whether this is the final debate
    questions = widget.game.isFinalDebate ? finalDebateQuestions : regularDebateQuestions;
  }

  void _selectAnswer(int idx) {
    final correct = questions[questionIndex].$3 == idx;
    // Higher stakes for final debate (10% instead of 5%)
    final approvalChange = widget.game.isFinalDebate ? (correct ? 10.0 : -10.0) : (correct ? 5.0 : -5.0);
    widget.game.gameState.addApproval(approvalChange);
    
    // Play appropriate sound effect
    if (correct) {
      widget.game.playPositiveSound();
    } else {
      widget.game.playNegativeSound();
    }

    setState(() {
      // Show feedback text based on whether the answer was correct
      feedbackText = correct ? questions[questionIndex].$5 : questions[questionIndex].$4;
      lastAnswerCorrect = correct;
    });

    if (correct) {
      // play clap (placeholder)
    } else {
      // play boo (placeholder)
    }

    // Delay moving to the next question to allow user to read feedback
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          questionIndex++;
          feedbackText = null;
        });

        if (questionIndex >= questions.length) {
          widget.game.overlays.remove('DebateOverlay');
          widget.game.debateFinished(isFinal: widget.game.isFinalDebate);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (questionIndex >= questions.length) {
      return const SizedBox.shrink();
    }
    final q = questions[questionIndex];

    // Add a container with a background image and overlay
    return Material(
      child: Container(
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/debate.png'),
            fit: BoxFit.cover,
          ),
          // Add gradient overlay on top of the image
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: widget.game.isFinalDebate
                ? [Colors.purple.shade900.withAlpha(180), Colors.indigo.shade900.withAlpha(180)]
                : [Colors.blue.shade900.withAlpha(150), Colors.red.shade900.withAlpha(150)],
          ),
        ),
        // Add a blur effect for a more polished look
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Debate title - indicate if it's the final debate
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                      decoration: BoxDecoration(
                        color:
                            widget.game.isFinalDebate
                                ? Colors.purple.shade700.withAlpha(230)
                                : Colors.blue.shade700.withAlpha(200),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 8, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Text(
                        widget.game.isFinalDebate ? 'FINAL PRESIDENTIAL DEBATE' : 'Presidential Debate',
                        style: GoogleFonts.montserrat(
                          fontSize: widget.game.isFinalDebate ? 24 : 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: widget.game.isFinalDebate ? 1.5 : 1.0,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Question Card
                    Container(
                      width: 500, // Fixed width for better layout
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(230),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Display the question
                          Text(
                            q.$1,
                            style: GoogleFonts.raleway(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Only show answer buttons if no feedback is currently displayed
                          if (feedbackText == null) ...[
                            for (var i = 0; i < q.$2.length; i++)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _selectAnswer(i),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade700,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                      elevation: 3,
                                    ),
                                    child: Text(
                                      q.$2[i],
                                      style: GoogleFonts.raleway(fontSize: 18, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                          ] else ...[
                            // Display feedback text with appropriate styling
                            Container(
                              padding: const EdgeInsets.all(20.0),
                              margin: const EdgeInsets.symmetric(horizontal: 12.0),
                              decoration: BoxDecoration(
                                color:
                                    lastAnswerCorrect == true
                                        ? Colors.green.shade700.withAlpha(230)
                                        : Colors.red.shade700.withAlpha(230),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(70),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                feedbackText!,
                                style: GoogleFonts.raleway(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Approval Rating with nice styling
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(200),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withAlpha(70), blurRadius: 5, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.how_to_vote, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Approval: ${widget.game.gameState.approval.toStringAsFixed(0)}%',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
