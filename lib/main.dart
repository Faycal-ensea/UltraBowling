import 'dart:math'; // Pour les calculs aléatoires (Random) et géométriques (sin, pi)
import 'package:flutter/material.dart';

/* =========================
   GESTION DE LA LANGUE
========================= */

// Enumération simple pour définir les langues disponibles
enum Lang { fr, en }

// Variable globale stockant la langue actuelle (par défaut Français)
Lang currentLang = Lang.fr;

// Fonction utilitaire de traduction : renvoie la chaîne 'fr' ou 'en' selon la langue active
String tr(String fr, String en) => currentLang == Lang.fr ? fr : en;

/* =========================
   POINT D'ENTRÉE (MAIN)
========================= */

void main() => runApp(const BowlingApp());

class BowlingApp extends StatefulWidget {
  const BowlingApp({super.key});

  @override
  State<BowlingApp> createState() => _BowlingAppState();
}

class _BowlingAppState extends State<BowlingApp> {
  // Fonction pour changer la langue et rafraîchir toute l'app (setState)
  void setLang(Lang l) => setState(() => currentLang = l);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Cache le bandeau "Debug"
      title: 'UltraBowling',
      // Thème sombre global pour coller à l'esthétique Néon
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      // On passe la fonction de changement de langue à la première page
      home: FirstPage(onLangChange: setLang),
    );
  }
}

/* =========================
   UI HELPERS (STYLE NÉON)
========================= */

// Widget de fond animé avec une grille mouvante style "Synthwave"
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
    // Animation en boucle de 6 secondes pour l'effet de mouvement
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose(); // Toujours nettoyer les contrôleurs
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c, // Reconstruit le widget à chaque tick de l'animation
      builder: (_, __) {
        final t = _c.value; // Valeur de 0.0 à 1.0
        return Container(
          // Dégradé de fond sombre (bleu nuit / violet) qui change légèrement avec 't'
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * t, -1), // Le dégradé bouge
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
              // La grille dessinée par dessus le fond
              Positioned.fill(
                child: Opacity(
                  opacity: 0.10, // Très subtil
                  child: CustomPaint(painter: _GridPainter(progress: t)),
                ),
              ),
              // Le contenu réel de la page (boutons, jeu, etc.)
              SafeArea(child: widget.child),
            ],
          ),
        );
      },
    );
  }
}

// Peintre personnalisé pour dessiner la grille perspective
class _GridPainter extends CustomPainter {
  final double progress;
  _GridPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.25)
      ..strokeWidth = 1;

    final step = 28.0; // Espacement des lignes
    final offset = (progress * step); // Décalage pour créer le mouvement

    // Dessin des lignes verticales et horizontales
    for (double x = -step + offset; x < size.width + step; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = -step + offset; y < size.height + step; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.progress != progress; // Redessine si l'animation avance
}

// Widget pour encadrer le contenu (Effet verre + bordure néon)
Widget neonCard({required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF0D1538).withOpacity(0.65), // Fond semi-transparent
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.cyanAccent.withOpacity(0.35), width: 1.2),
      boxShadow: [
        // Lueur externe (Glow effect)
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

// Bouton stylisé avec effet de lueur
Widget neonButton({
  required String text,
  required VoidCallback? onPressed,
  Color glow = Colors.cyanAccent, // Couleur de la lueur paramétrable
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
   SCORING BOWLING RÉEL
========================= */

int scoreFromRolls(List<int> rolls) {
  int score = 0;
  int rollIndex = 0; // Pointeur pour parcourir la liste des lancers

  // Une partie standard a 10 frames (manches)
  for (int frame = 0; frame < 10; frame++) {
    if (rollIndex >= rolls.length) break; // Arrêt si pas assez de lancers joués

    final int first = rolls[rollIndex];

    // CAS 1: STRIKE (10 quilles au 1er lancer)
    if (first == 10) {
      // Le score est 10 + les 2 prochains lancers (bonus)
      final int b1 = (rollIndex + 1 < rolls.length) ? rolls[rollIndex + 1] : 0;
      final int b2 = (rollIndex + 2 < rolls.length) ? rolls[rollIndex + 2] : 0;
      score += 10 + b1 + b2;
      rollIndex += 1; // On avance d'un seul index car le strike termine la frame
    } 
    // CAS 2: Pas Strike
    else {
      final int second = (rollIndex + 1 < rolls.length) ? rolls[rollIndex + 1] : 0;
      final int frameSum = first + second;

      // CAS 2A: SPARE (Total = 10)
      if (frameSum == 10) {
        // Le score est 10 + le prochain lancer (bonus)
        final int b = (rollIndex + 2 < rolls.length) ? rolls[rollIndex + 2] : 0;
        score += 10 + b;
      } 
      // CAS 2B: FRAME OUVERTE (Total < 10)
      else {
        score += frameSum;
      }
      rollIndex += 2; // On avance de deux index (2 lancers par frame)
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
  
  // -- CONSTANTES & OUTILS --
  static const int totalPins = 10;
  final Random rnd = Random();

  // -- ÉTAT DES QUILLES --
  late List<bool> pins; // true = debout, false = tombée
  int pinsStanding = totalPins;

  // -- ÉTAT DU JEU --
  int frame = 0; // 0..9 (pour 1..10)
  int currentPlayer = 0;
  int throwInFrame = 1; // Lancer 1, 2 (ou 3 à la fin)

  // Variables spéciales pour la 10ème frame
  int firstRollIn10th = -1;
  int secondRollIn10th = -1;

  // Historique des lancers pour le calcul des scores
  late List<List<int>> rollsByPlayer;

  // -- INTERFACE --
  String overlay = ""; // Texte "STRIKE" ou "SPARE"
  double overlayOpacity = 0.0;
  bool locked = false; // Bloque les boutons pendant l'animation
  double testSlider = 0; // Slider pour le mode test

  // -- ANIMATION BOULE --
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

    // Configuration de l'animation de la boule (520ms)
    ballC = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          // Cache la boule quand l'animation est finie
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

  // Remet toutes les quilles debout
  void _resetPinsFull() {
    pins = List.generate(totalPins, (_) => true);
    pinsStanding = totalPins;
  }

  // Affiche un texte géant (STRIKE/SPARE) temporairement
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

  // Petit délai pour éviter les clics frénétiques
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

  // Réinitialise tout pour une nouvelle partie
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

  // Passe au joueur suivant
  void _advanceTurn() {
    currentPlayer++;
    if (currentPlayer >= widget.nbPlayers) {
      currentPlayer = 0;
      frame++; // Nouvelle manche si tous les joueurs ont joué
    }

    throwInFrame = 1;
    firstRollIn10th = -1;
    secondRollIn10th = -1;
    testSlider = 0;
    _resetPinsFull();
  }

  // Simule la physique : fait tomber 'knocked' quilles parmi celles debout
  void _applyKnockdown(int knocked) {
    final standingIdx = <int>[];
    for (int i = 0; i < pins.length; i++) {
      if (pins[i]) standingIdx.add(i);
    }
    standingIdx.shuffle(rnd); // Aléatoire pour ne pas toujours faire tomber les mêmes

    for (int k = 0; k < knocked && k < standingIdx.length; k++) {
      pins[standingIdx[k]] = false;
    }
    pinsStanding = pins.where((p) => p).length;
  }

  // Décide combien de quilles tombent (Aléatoire ou Slider)
  int _getKnocked() {
    if (widget.isTestMode) {
      return testSlider.round().clamp(0, pinsStanding);
    }
    return rnd.nextInt(pinsStanding + 1);
  }

  // Trouve qui a le meilleur score
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

  /// =========================================================
  /// CŒUR DU JEU : Action de lancer la boule
  /// =========================================================
  Future<void> _roll(Size pinAreaSize) async {
    if (locked || _isGameOver) return;
    if (pinsStanding <= 0) return;

    setState(() => locked = true); // Verrouillage UI

    final int knocked = _getKnocked();

    // Calcul de la trajectoire (bas vers le centre des quilles)
    final double w = pinAreaSize.width;
    final double h = pinAreaSize.height;

    ballStart = Offset(w * 0.50, h * 0.96);
    ballEnd = Offset(w * 0.50, h * 0.36);

    // Courbe aléatoire légère pour le réalisme
    ballCurve = widget.isTestMode ? 0.0 : (rnd.nextDouble() * 2 - 1) * 0.25;

    // Début animation
    setState(() {
      ballVisible = true;
      ballC.reset();
      ballC.forward();
    });

    // On attend que la boule arrive au bout (520ms)
    await Future.delayed(ballC.duration ?? const Duration(milliseconds: 520));
    if (!mounted) return;

    // Application du résultat (chute des quilles)
    setState(() {
      _applyKnockdown(knocked);
      rollsByPlayer[currentPlayer].add(knocked);
      testSlider = 0;
    });

    final bool allDown = pinsStanding == 0;

    // --- GESTION FRAMES 1 à 9 ---
    if (frame < 9) {
      // Strike
      if (throwInFrame == 1 && knocked == 10) {
        _showOverlay(tr("STRIKE", "STRIKE"));
        await _lockTransition(ms: 520);
        if (!mounted) return;
        setState(() => _advanceTurn());
        return;
      }

      // 1er lancer simple
      if (throwInFrame == 1) {
        setState(() => throwInFrame = 2);
        setState(() => locked = false);
        return;
      }

      // 2ème lancer (Spare ou trou)
      if (allDown) _showOverlay(tr("SPARE", "SPARE"));
      await _lockTransition(ms: 520);
      if (!mounted) return;
      setState(() => _advanceTurn());
      return;
    }

    // --- GESTION FRAME 10 (Règles spéciales) ---
    if (throwInFrame == 1) {
      firstRollIn10th = knocked;
      if (knocked == 10) { // Strike au 1er coup
        _showOverlay(tr("STRIKE", "STRIKE"));
        await _lockTransition(ms: 520);
        if (!mounted) return;
        setState(() {
          _resetPinsFull(); // On remet les quilles pour le bonus
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
          _resetPinsFull(); // On remet les quilles si strike
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
          _resetPinsFull(); // Bonus shot pour spare
          throwInFrame = 3;
          locked = false;
        });
        return;
      }

      // Fin de partie si pas de bonus
      await _lockTransition(ms: 520);
      if (!mounted) return;
      setState(() => _advanceTurn());
      return;
    }

    // 3ème lancer (bonus frame 10)
    await _lockTransition(ms: 520);
    if (!mounted) return;
    setState(() => _advanceTurn());
  }

  /// Coordonnées normalisées pour placer les quilles en triangle
  List<Offset> _triangleNormalized() {
    return [
      // Rangée 1 (Haut)
      const Offset(0.50, 0.22),
      // Rangée 2
      const Offset(0.44, 0.34), const Offset(0.56, 0.34),
      // Rangée 3
      const Offset(0.38, 0.48), const Offset(0.50, 0.48), const Offset(0.62, 0.48),
      // Rangée 4 (Bas)
      const Offset(0.32, 0.64), const Offset(0.44, 0.64), const Offset(0.56, 0.64), const Offset(0.68, 0.64),
    ];
  }

  /// Widget pour une quille individuelle
  Widget _pinWidget(bool up) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 220),
      scale: up ? 1.0 : 0.82, // Rétrécit si tombée
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: up ? 1.0 : 0.18, // Devient transparente si tombée
        child: Container(
          width: 22,
          height: 62,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            // Dégradé rouge/rose si debout, sombre si couchée
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

  /// Widget qui dessine la boule (via AnimationController)
  Widget _ballPainter(Size size) {
    return AnimatedBuilder(
      animation: ballC,
      builder: (_, __) {
        if (!ballVisible) return const SizedBox.shrink();

        final t = Curves.easeInOut.transform(ballC.value);

        // Interpolation de la position + Courbe sinusoïdale
        final x = ballStart.dx + (ballEnd.dx - ballStart.dx) * t + sin(t * pi) * (size.width * ballCurve);
        final y = ballStart.dy + (ballEnd.dy - ballStart.dy) * t;

        final r = 10.0 + 4.0 * (1 - t); // La boule rétrécit légèrement avec la perspective
        return Positioned(
          left: x - r,
          top: y - r,
          child: Container(
            width: r * 2,
            height: r * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7CFFEA), // Couleur Cyan
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

    // Texte d'en-tête (Status)
    final String header = isOver
        ? tr("Partie terminée", "Game over")
        : "${tr("Manche", "Frame")} ${frame + 1}/10 · ${tr("Joueur", "Player")} ${currentPlayer + 1} · ${tr("Lancer", "Throw")} $throwInFrame";

    final int standing = pinsStanding.clamp(0, totalPins);

    // Valeurs pour le slider (Mode Test)
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
                            // 1. En-tête Statut
                            Text(
                              header,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 2. Tableau des scores
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

                            // 3. Zone Centrale (Fin de jeu ou Jeu actif)
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
                                  // Mode Test : Slider pour tricher/tester
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

                                  // Zone PISTE + QUILLES + BOULE
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final areaW = min(constraints.maxWidth, 520.0);
                                      final areaH = 260.0;
                                      final double pinsYOffset = 40;

                                      return Center(
                                        child: SizedBox(
                                          width: areaW,
                                          height: areaH,
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              // A. Fond de la piste
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

                                              // B. Les Quilles (boucle)
                                              for (int i = 0; i < totalPins; i++)
                                                Positioned(
                                                  left: areaW * triangle[i].dx - 11,
                                                  top: areaH * triangle[i].dy - 31 + pinsYOffset,
                                                  child: _pinWidget(pins[i]),
                                                ),

                                              // C. La Boule animée
                                              _ballPainter(Size(areaW, areaH)),

                                              // D. Bouton d'action (Lancer)
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

                  // 4. Overlay STRIKE / SPARE (Texte flottant)
                  IgnorePointer(
                    ignoring: true, // Permet de cliquer à travers
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
