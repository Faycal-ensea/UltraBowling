import 'dart:math';
import 'package:flutter/material.dart';

/* =========================
   LANGUE (simple, DartPad)
========================= */

enum Lang { fr, en }
Lang currentLang = Lang.fr;
String tr(String fr, String en) => currentLang == Lang.fr ? fr : en;

/* =========================
   MAIN
========================= */

void main() => runApp(const BowlingApp());

class BowlingApp extends StatefulWidget {
  const BowlingApp({super.key});

  @override
  State<BowlingApp> createState() => _BowlingAppState();
}

class _BowlingAppState extends State<BowlingApp> {
  void setLang(Lang l) => setState(() => currentLang = l);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UltraBowling',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: FirstPage(onLangChange: setLang),
    );
  }
}

/* =========================
   UI HELPERS (NEON)
========================= */

class NeonBackground extends StatefulWidget {
  final Widget child;
  const NeonBackground({super.key, required this.child});

  @override
  State<NeonBackground> createState() => _NeonBackgroundState();
}

class _NeonBackgroundState extends State<NeonBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = _c.value;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * t, -1),
              end: Alignment(1.0 - 2.0 * t, 1),
              colors: const [
                Color(0xFF0A0F2C),
                Color(0xFF1A0B3C),
                Color(0xFF021A2A),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.10,
                  child: CustomPaint(painter: _GridPainter(progress: t)),
                ),
              ),
              SafeArea(child: widget.child),
            ],
          ),
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  final double progress;
  _GridPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.25)
      ..strokeWidth = 1;

    final step = 28.0;
    final offset = (progress * step);

    for (double x = -step + offset; x < size.width + step; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = -step + offset; y < size.height + step; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

Widget neonCard({required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF0D1538).withOpacity(0.65),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.cyanAccent.withOpacity(0.35), width: 1.2),
      boxShadow: [
        BoxShadow(
          color: Colors.cyanAccent.withOpacity(0.18),
          blurRadius: 18,
          spreadRadius: 1,
        ),
      ],
    ),
    child: child,
  );
}

Widget neonButton({
  required String text,
  required VoidCallback? onPressed,
  Color glow = Colors.cyanAccent,
}) {
  return SizedBox(
    width: 280,
    height: 48,
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: glow.withOpacity(0.25),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF16204D),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: glow.withOpacity(0.55), width: 1),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}

/* =========================
   PAGE 1 : START + PARAMETRES LANGUE (UNIQUEMENT ICI)
========================= */

class FirstPage extends StatelessWidget {
  final Function(Lang) onLangChange;
  const FirstPage({super.key, required this.onLangChange});

  void _openSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tr("Paramètres", "Settings")),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Français"),
              onTap: () {
                onLangChange(Lang.fr);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("English"),
              onTap: () {
                onLangChange(Lang.en);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NeonBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('UltraBowling'),
          actions: [
            IconButton(
              onPressed: () => _openSettings(context),
              icon: const Icon(Icons.settings),
              tooltip: tr("Paramètres", "Settings"),
            ),
          ],
        ),
        body: Center(
          child: neonCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "UltraBowling",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  tr("Mini bowling interactif", "Interactive mini bowling"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.82),
                  ),
                ),
                const SizedBox(height: 22),
                Center(
                  child: neonButton(
                    text: tr("Start", "Start"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ModePage()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: neonButton(
                    text: tr("Paramètres (langue)", "Settings (language)"),
                    glow: Colors.pinkAccent,
                    onPressed: () => _openSettings(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* =========================
   CHOIX MODE : NORMAL / TEST
========================= */

class ModePage extends StatelessWidget {
  const ModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return NeonBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(tr("Mode", "Mode")),
        ),
        body: Center(
          child: neonCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr("Choisissez le mode", "Choose mode"),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Center(
                  child: neonButton(
                    text: tr("Mode normal", "Normal mode"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GameTypePage(isTestMode: false),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: neonButton(
                    text: tr("Mode test (lancers manuels)",
                        "Test mode (manual rolls)"),
                    glow: Colors.orangeAccent,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GameTypePage(isTestMode: true),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* =========================
   CHOIX TYPE : SOLO / MULTI + NB JOUEURS
========================= */

class GameTypePage extends StatelessWidget {
  final bool isTestMode;
  const GameTypePage({super.key, required this.isTestMode});

  @override
  Widget build(BuildContext context) {
    return NeonBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(tr("Type de jeu", "Game type")),
        ),
        body: Center(
          child: neonCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr("Choisissez", "Choose"),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Center(
                  child: neonButton(
                    text: tr("Solo", "Solo"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BowlingGamePage(
                            nbPlayers: 1,
                            isTestMode: isTestMode,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: neonButton(
                    text: tr("Multijoueur", "Multiplayer"),
                    glow: Colors.purpleAccent,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlayersPage(isTestMode: isTestMode),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PlayersPage extends StatelessWidget {
  final bool isTestMode;
  const PlayersPage({super.key, required this.isTestMode});

  @override
  Widget build(BuildContext context) {
    return NeonBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(tr("Joueurs", "Players")),
        ),
        body: Center(
          child: neonCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr("Nombre de joueurs", "Number of players"),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                for (int i = 2; i <= 4; i++) ...[
                  Center(
                    child: neonButton(
                      text: "$i",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BowlingGamePage(
                              nbPlayers: i,
                              isTestMode: isTestMode,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* =========================
   SCORING BOWLING RÉEL (10 frames)
========================= */

int scoreFromRolls(List<int> rolls) {
  int score = 0;
  int rollIndex = 0;

  for (int frame = 0; frame < 10; frame++) {
    if (rollIndex >= rolls.length) break;

    final int first = rolls[rollIndex];

    if (first == 10) {
      final int b1 = (rollIndex + 1 < rolls.length) ? rolls[rollIndex + 1] : 0;
      final int b2 = (rollIndex + 2 < rolls.length) ? rolls[rollIndex + 2] : 0;
      score += 10 + b1 + b2;
      rollIndex += 1;
    } else {
      final int second =
          (rollIndex + 1 < rolls.length) ? rolls[rollIndex + 1] : 0;
      final int frameSum = first + second;

      if (frameSum == 10) {
        final int b = (rollIndex + 2 < rolls.length) ? rolls[rollIndex + 2] : 0;
        score += 10 + b;
      } else {
        score += frameSum;
      }
      rollIndex += 2;
    }
  }

  return score;
}

/* =========================
   JEU (NORMAL + TEST)
   - disposition triangle
   - animation de boule avant chute
   - pas de freeze
========================= */

class BowlingGamePage extends StatefulWidget {
  final int nbPlayers;
  final bool isTestMode;

  const BowlingGamePage({
    super.key,
    required this.nbPlayers,
    required this.isTestMode,
  });

  @override
  State<BowlingGamePage> createState() => _BowlingGamePageState();
}

class _BowlingGamePageState extends State<BowlingGamePage>
    with SingleTickerProviderStateMixin {
  static const int totalPins = 10;
  final Random rnd = Random();

  late List<bool> pins;
  int pinsStanding = totalPins;

  int frame = 0; // 0..9
  int currentPlayer = 0;
  int throwInFrame = 1;

  int firstRollIn10th = -1;
  int secondRollIn10th = -1;

  late List<List<int>> rollsByPlayer;

  String overlay = "";
  double overlayOpacity = 0.0;

  bool locked = false;

  double testSlider = 0;

  // Animation boule
  late AnimationController ballC;
  bool ballVisible = false;
  Offset ballStart = Offset.zero;
  Offset ballEnd = Offset.zero;
  double ballCurve = 0.0;

  @override
  void initState() {
    super.initState();
    pins = List.generate(totalPins, (_) => true);
    rollsByPlayer = List.generate(widget.nbPlayers, (_) => <int>[]);

    ballC = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          // On coupe l’affichage de la boule à la fin (sans bloquer l’UI)
          if (!mounted) return;
          setState(() => ballVisible = false);
        }
      });
  }

  @override
  void dispose() {
    ballC.dispose();
    super.dispose();
  }

  void _resetPinsFull() {
    pins = List.generate(totalPins, (_) => true);
    pinsStanding = totalPins;
  }

  void _showOverlay(String msg) {
    setState(() {
      overlay = msg;
      overlayOpacity = 1.0;
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => overlayOpacity = 0.0);
    });
  }

  Future<void> _lockTransition({int ms = 520}) async {
    try {
      await Future.delayed(Duration(milliseconds: ms));
    } finally {
      if (!mounted) return;
      setState(() => locked = false);
    }
  }

  bool get _isGameOver => frame >= 10;
  int _totalScore(int player) => scoreFromRolls(rollsByPlayer[player]);

  void _newGame() {
    setState(() {
      frame = 0;
      currentPlayer = 0;
      throwInFrame = 1;
      firstRollIn10th = -1;
      secondRollIn10th = -1;
      rollsByPlayer = List.generate(widget.nbPlayers, (_) => <int>[]);
      overlay = "";
      overlayOpacity = 0.0;
      locked = false;
      testSlider = 0;
      _resetPinsFull();
      ballVisible = false;
      ballC.reset();
    });
  }

  void _advanceTurn() {
    currentPlayer++;
    if (currentPlayer >= widget.nbPlayers) {
      currentPlayer = 0;
      frame++;
    }

    throwInFrame = 1;
    firstRollIn10th = -1;
    secondRollIn10th = -1;
    testSlider = 0;
    _resetPinsFull();
  }

  // Fait tomber "knocked" quilles debout (sélection aléatoire réaliste)
  void _applyKnockdown(int knocked) {
    final standingIdx = <int>[];
    for (int i = 0; i < pins.length; i++) {
      if (pins[i]) standingIdx.add(i);
    }
    standingIdx.shuffle(rnd);

    for (int k = 0; k < knocked && k < standingIdx.length; k++) {
      pins[standingIdx[k]] = false;
    }
    pinsStanding = pins.where((p) => p).length;
  }

  int _getKnocked() {
    if (widget.isTestMode) {
      return testSlider.round().clamp(0, pinsStanding);
    }
    return rnd.nextInt(pinsStanding + 1);
  }

  int _winnerIndex() {
    int best = 0;
    int bestScore = -999999;
    for (int i = 0; i < widget.nbPlayers; i++) {
      final s = _totalScore(i);
      if (s > bestScore) {
        bestScore = s;
        best = i;
      }
    }
    return best;
  }

  // Déclenche animation boule, puis applique chute, puis avance logique bowling
  Future<void> _roll(Size pinAreaSize) async {
    if (locked || _isGameOver) return;
    if (pinsStanding <= 0) return;

    setState(() => locked = true);

    final int knocked = _getKnocked();

    // Prépare trajectoire de la boule : bas -> triangle (centre)
    // On varie légèrement la courbure en normal mode, stable en test mode
    final double w = pinAreaSize.width;
    final double h = pinAreaSize.height;

    ballStart = Offset(w * 0.50, h * 0.96);
    ballEnd = Offset(w * 0.50, h * 0.36);

    ballCurve = widget.isTestMode ? 0.0 : (rnd.nextDouble() * 2 - 1) * 0.25;

    setState(() {
      ballVisible = true;
      ballC.reset();
      ballC.forward();
    });

    // On attend la fin de l’animation avant de faire tomber
    await Future.delayed(ballC.duration ?? const Duration(milliseconds: 520));
    if (!mounted) return;

    setState(() {
      _applyKnockdown(knocked);
      rollsByPlayer[currentPlayer].add(knocked);
      testSlider = 0;
    });

    final bool allDown = pinsStanding == 0;

    // Frames 1..9
    if (frame < 9) {
      if (throwInFrame == 1 && knocked == 10) {
        _showOverlay(tr("STRIKE", "STRIKE"));
        await _lockTransition(ms: 520);
        if (!mounted) return;
        setState(() => _advanceTurn());
        return;
      }

      if (throwInFrame == 1) {
        setState(() => throwInFrame = 2);
        setState(() => locked = false);
        return;
      }

      if (allDown) _showOverlay(tr("SPARE", "SPARE"));
      await _lockTransition(ms: 520);
      if (!mounted) return;
      setState(() => _advanceTurn());
      return;
    }

    // Frame 10
    if (throwInFrame == 1) {
      firstRollIn10th = knocked;

      if (knocked == 10) {
        _showOverlay(tr("STRIKE", "STRIKE"));
        await _lockTransition(ms: 520);
        if (!mounted) return;
        setState(() {
          _resetPinsFull();
          throwInFrame = 2;
        });
        return;
      } else {
        setState(() {
          throwInFrame = 2;
          locked = false;
        });
        return;
      }
    }

    if (throwInFrame == 2) {
      secondRollIn10th = knocked;

      final bool strikeFirst = firstRollIn10th == 10;
      final bool spare = !strikeFirst && (firstRollIn10th + secondRollIn10th == 10);

      if (strikeFirst) {
        if (knocked == 10) _showOverlay(tr("STRIKE", "STRIKE"));
        await _lockTransition(ms: 520);
        if (!mounted) return;
        setState(() {
          _resetPinsFull();
          throwInFrame = 3;
          locked = false;
        });
        return;
      }

      if (spare) {
        _showOverlay(tr("SPARE", "SPARE"));
        await _lockTransition(ms: 520);
        if (!mounted) return;
        setState(() {
          _resetPinsFull();
          throwInFrame = 3;
          locked = false;
        });
        return;
      }

      await _lockTransition(ms: 520);
      if (!mounted) return;
      setState(() => _advanceTurn());
      return;
    }

    // throw 3
    await _lockTransition(ms: 520);
    if (!mounted) return;
    setState(() => _advanceTurn());
  }

  // Positions triangle (10 quilles): 4-3-2-1
  // Index: on les place visuellement en triangle, l’ordre des pins[] n’a pas d’importance.
  List<Offset> _triangleNormalized() {
    // Coordonnées normalisées dans un rectangle [0..1]
    // y vers le haut (0 top, 1 bottom)
    // Rangées : 4 en bas, puis 3, puis 2, puis 1 en haut
    // On centre chaque rangée.
    return [
      // Row 1 (top) : 1
      const Offset(0.50, 0.22),

      // Row 2 : 2
      const Offset(0.44, 0.34),
      const Offset(0.56, 0.34),

      // Row 3 : 3
      const Offset(0.38, 0.48),
      const Offset(0.50, 0.48),
      const Offset(0.62, 0.48),

      // Row 4 (bottom) : 4
      const Offset(0.32, 0.64),
      const Offset(0.44, 0.64),
      const Offset(0.56, 0.64),
      const Offset(0.68, 0.64),
    ];
  }

  Widget _pinWidget(bool up) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 220),
      scale: up ? 1.0 : 0.82,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: up ? 1.0 : 0.18,
        child: Container(
          width: 22,
          height: 62,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: up
                  ? const [Color(0xFFFF4D7D), Color(0xFFFF1F5A)]
                  : const [Color(0xFF3A3A3A), Color(0xFF1F1F1F)],
            ),
            boxShadow: [
              BoxShadow(
                color: up
                    ? Colors.pinkAccent.withOpacity(0.25)
                    : Colors.black.withOpacity(0.25),
                blurRadius: 14,
                spreadRadius: 1,
              ),
            ],
            border: Border.all(
              color: up ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.06),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ballPainter(Size size) {
    return AnimatedBuilder(
      animation: ballC,
      builder: (_, __) {
        if (!ballVisible) return const SizedBox.shrink();

        final t = Curves.easeInOut.transform(ballC.value);

        // Trajectoire courbe simple : interpolation + courbe latérale
        final x = ballStart.dx + (ballEnd.dx - ballStart.dx) * t + sin(t * pi) * (size.width * ballCurve);
        final y = ballStart.dy + (ballEnd.dy - ballStart.dy) * t;

        final r = 10.0 + 4.0 * (1 - t); // légère variation de taille
        return Positioned(
          left: x - r,
          top: y - r,
          child: Container(
            width: r * 2,
            height: r * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7CFFEA),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.55),
                  blurRadius: 22,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.12),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isOver = _isGameOver;

    final String header = isOver
        ? tr("Partie terminée", "Game over")
        : "${tr("Manche", "Frame")} ${frame + 1}/10 · ${tr("Joueur", "Player")} ${currentPlayer + 1} · ${tr("Lancer", "Throw")} $throwInFrame";

    final int standing = pinsStanding.clamp(0, totalPins);

    final double maxSlider = standing.toDouble();
    final double safeSlider = testSlider.clamp(0.0, maxSlider);

    final triangle = _triangleNormalized();

    return NeonBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text("UltraBowling"),
          actions: [
            IconButton(
              onPressed: _newGame,
              icon: const Icon(Icons.refresh),
              tooltip: tr("Nouvelle partie", "New game"),
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      neonCard(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              header,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Scores (cumul bowling réel)
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 12,
                              runSpacing: 8,
                              children: List.generate(widget.nbPlayers, (i) {
                                final s = _totalScore(i);
                                final bool active = (!isOver && i == currentPlayer);
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: active
                                        ? Colors.cyanAccent.withOpacity(0.16)
                                        : Colors.white.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: active
                                          ? Colors.cyanAccent.withOpacity(0.6)
                                          : Colors.white.withOpacity(0.15),
                                    ),
                                  ),
                                  child: Text(
                                    "${tr("Joueur", "Player")} ${i + 1}: $s",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight:
                                          active ? FontWeight.w900 : FontWeight.w700,
                                      color: active
                                          ? Colors.cyanAccent
                                          : Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                );
                              }),
                            ),

                            const SizedBox(height: 14),

                            if (isOver)
                              Column(
                                children: [
                                  Text(
                                    "${tr("Gagnant", "Winner")}: ${tr("Joueur", "Player")} ${_winnerIndex() + 1}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Center(
                                    child: neonButton(
                                      text: tr("Rejouer", "Play again"),
                                      onPressed: _newGame,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  if (widget.isTestMode) ...[
                                    Text(
                                      "${tr("Quilles à faire tomber", "Pins to knock")}: ${safeSlider.round()} / $standing",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Slider(
                                      value: safeSlider,
                                      min: 0,
                                      max: maxSlider == 0 ? 1 : maxSlider,
                                      divisions: (standing <= 0) ? 1 : standing,
                                      onChanged: locked
                                          ? null
                                          : (v) => setState(() => testSlider = v),
                                    ),
                                  ],

                                  const SizedBox(height: 6),

                                 

                                  

                                  // Zone quilles + boule (triangle + animation)
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final areaW = min(constraints.maxWidth, 520.0);
                                      final areaH = 260.0;
                                      final double pinsYOffset = 40; // ajuste 30–60 selon ton goût


                                      return Center(
                                        child: SizedBox(
                                          width: areaW,
                                          height: areaH,
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              // Piste
                                              Positioned.fill(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(18),
                                                    border: Border.all(
                                                      color: Colors.cyanAccent.withOpacity(0.25),
                                                      width: 1.2,
                                                    ),
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter,
                                                      colors: [
                                                        Colors.white.withOpacity(0.05),
                                                        Colors.white.withOpacity(0.02),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // Quilles en triangle
                                              for (int i = 0; i < totalPins; i++)
                                                Positioned(
                                                  left: areaW * triangle[i].dx - 11,
                                                  top: areaH * triangle[i].dy - 31 + pinsYOffset,
                                                  child: _pinWidget(pins[i]),
                                                ),

                                              // Boule animée (dessinée)
                                              _ballPainter(Size(areaW, areaH)),

                                              // Bouton par-dessus, mais sans bloquer la boule
                                              Positioned(
                                                left: 0,
                                                right: 0,
                                                top: -6,
                                                child: Center(
                                                  child: neonButton(
                                                    text: locked
                                                        ? tr("Animation...", "Animation...")
                                                        : tr("Lancer la boule", "Roll"),
                                                    glow: locked
                                                        ? Colors.grey
                                                        : Colors.cyanAccent,
                                                    onPressed: locked
                                                        ? null
                                                        : () => _roll(Size(areaW, areaH)),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Overlay STRIKE / SPARE (ne bloque pas les clics)
                  IgnorePointer(
                    ignoring: true,
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: overlayOpacity,
                        duration: const Duration(milliseconds: 220),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.92, end: 1.0),
                          duration: const Duration(milliseconds: 220),
                          builder: (_, s, child) =>
                              Transform.scale(scale: s, child: child),
                          child: Text(
                            overlay,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 54,
                              fontWeight: FontWeight.w900,
                              color: Colors.orangeAccent,
                              shadows: [
                                Shadow(
                                  blurRadius: 22,
                                  color: Colors.orangeAccent.withOpacity(0.55),
                                ),
                                const Shadow(
                                  blurRadius: 18,
                                  color: Colors.black87,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
