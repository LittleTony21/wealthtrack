import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/milestone.dart';
import '../providers/milestone_queue_provider.dart';

// ─── Public layer widget ────────────────────────────────────────────────────

class MilestoneCelebrationLayer extends ConsumerStatefulWidget {
  const MilestoneCelebrationLayer({super.key});

  @override
  ConsumerState<MilestoneCelebrationLayer> createState() =>
      _MilestoneCelebrationLayerState();
}

class _MilestoneCelebrationLayerState
    extends ConsumerState<MilestoneCelebrationLayer>
    with TickerProviderStateMixin {
  late final AnimationController _confettiCtrl;
  late final AnimationController _cardCtrl;
  late final Animation<double> _cardScale;
  late final Animation<double> _cardOpacity;

  MilestoneDefinition? _showing;
  bool _isShowing = false;
  late List<_Particle> _particles;

  static const _particleCount = 90;
  static const _celebrationColors = [
    Color(0xFFFFB340),
    Color(0xFF05C293),
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFFE66D),
    Color(0xFFA855F7),
    Color(0xFFFF9A9E),
    Color(0xFF74B9FF),
    Color(0xFFFFD700),
    Color(0xFF00E5FF),
  ];

  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _cardScale = _cardCtrl
        .drive(CurveTween(curve: Curves.elasticOut))
        .drive(Tween(begin: 0.4, end: 1.0));
    _cardOpacity = _cardCtrl
        .drive(CurveTween(curve: Curves.easeOut))
        .drive(Tween(begin: 0.0, end: 1.0));
    _particles = _makeParticles();
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  List<_Particle> _makeParticles() => List.generate(_particleCount, (_) {
        return _Particle(
          angle: _rng.nextDouble() * 2 * pi,
          speed: 0.25 + _rng.nextDouble() * 0.55,
          color: _celebrationColors[_rng.nextInt(_celebrationColors.length)],
          size: 4.0 + _rng.nextDouble() * 7.0,
          isRect: _rng.nextBool(),
          rotationSpeed: (_rng.nextDouble() - 0.5) * 12,
        );
      });

  void _show(MilestoneDefinition m) {
    if (_isShowing) return;
    _particles = _makeParticles();
    setState(() {
      _showing = m;
      _isShowing = true;
    });
    _confettiCtrl.forward(from: 0);
    _cardCtrl.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 3000), _dismiss);
  }

  void _dismiss() {
    if (!mounted || !_isShowing) return;
    _cardCtrl.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _isShowing = false;
        _showing = null;
      });
      ref.read(milestoneQueueProvider.notifier).dequeue();
    });
  }

  @override
  Widget build(BuildContext context) {
    final queue = ref.watch(milestoneQueueProvider);

    if (queue.isNotEmpty && !_isShowing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final q = ref.read(milestoneQueueProvider);
        if (q.isNotEmpty && !_isShowing) _show(q.first);
      });
    }

    if (!_isShowing || _showing == null) return const SizedBox.shrink();

    final screenSize = MediaQuery.of(context).size;
    final m = _showing!;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _dismiss,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withValues(alpha: 0.65),
          child: Stack(
            children: [
              // Fireworks particles
              AnimatedBuilder(
                animation: _confettiCtrl,
                builder: (_, __) => CustomPaint(
                  size: screenSize,
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: _confettiCtrl.value,
                    center: Offset(
                        screenSize.width / 2, screenSize.height * 0.42),
                  ),
                ),
              ),

              // Celebration card
              Center(
                child: AnimatedBuilder(
                  animation: _cardCtrl,
                  builder: (_, child) => Opacity(
                    opacity: _cardOpacity.value,
                    child: Transform.scale(
                      scale: _cardScale.value,
                      child: child,
                    ),
                  ),
                  child: _CelebrationCard(milestone: m, onTap: _dismiss),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Card UI ────────────────────────────────────────────────────────────────

class _CelebrationCard extends StatelessWidget {
  final MilestoneDefinition milestone;
  final VoidCallback onTap;

  const _CelebrationCard({required this.milestone, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final m = milestone;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 36),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
      decoration: BoxDecoration(
        color: const Color(0xFF12122A),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFFFB340).withValues(alpha: 0.55),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB340).withValues(alpha: 0.25),
            blurRadius: 40,
            spreadRadius: 6,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB340).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFFFFB340).withValues(alpha: 0.45)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.military_tech_rounded,
                    color: Color(0xFFFFB340), size: 14),
                const SizedBox(width: 6),
                Text(
                  'Milestone Unlocked!',
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFFFB340),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Emoji
          Text(m.emoji, style: const TextStyle(fontSize: 68)),

          const SizedBox(height: 14),

          // Name
          Text(
            m.name,
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 6),

          // Description
          Text(
            m.description,
            style: GoogleFonts.manrope(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 18),

          // Coin reward
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB340).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: const Color(0xFFFFB340).withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on_rounded,
                    color: Color(0xFFFFB340), size: 18),
                const SizedBox(width: 7),
                Text(
                  '+${m.coinReward} coin${m.coinReward == 1 ? '' : 's'} earned',
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFFFB340),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Tap anywhere to continue',
            style: GoogleFonts.manrope(
              color: Colors.white.withValues(alpha: 0.28),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Particle model ──────────────────────────────────────────────────────────

class _Particle {
  final double angle;
  final double speed;
  final Color color;
  final double size;
  final bool isRect;
  final double rotationSpeed;

  const _Particle({
    required this.angle,
    required this.speed,
    required this.color,
    required this.size,
    required this.isRect,
    required this.rotationSpeed,
  });
}

// ─── Painter ─────────────────────────────────────────────────────────────────

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Offset center;

  const _ConfettiPainter({
    required this.particles,
    required this.progress,
    required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Ease-out explosion curve
    final t = Curves.easeOut.transform(progress.clamp(0.0, 1.0));

    for (final p in particles) {
      final x = center.dx + cos(p.angle) * p.speed * size.width * 0.72 * t;
      final y = center.dy +
          sin(p.angle) * p.speed * size.height * 0.48 * t +
          320 * progress * progress; // gravity

      // Fade out in last 35% of animation
      final opacity =
          progress < 0.65 ? 1.0 : (1.0 - (progress - 0.65) / 0.35);

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * p.rotationSpeed);

      if (p.isRect) {
        canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: p.size, height: p.size * 0.45),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
