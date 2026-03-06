import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme_colors.dart';
import '../models/milestone.dart';
import '../providers/profile_provider.dart';

void showMilestoneDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => const _MilestoneDialog(),
  );
}

class _MilestoneDialog extends ConsumerWidget {
  const _MilestoneDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = WealthColors.of(context);
    final primary = Theme.of(context).primaryColor;
    final profile = ref.watch(profileProvider).valueOrNull;
    final earned = profile?.earnedMilestones ?? [];

    // Group milestones by category
    final categories = ['Net Worth', 'Streak', 'Tracking', 'Special'];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: c.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB340).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.military_tech_rounded,
                        color: Color(0xFFFFB340), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Milestones',
                            style: GoogleFonts.manrope(
                                color: c.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w800)),
                        Text(
                          '${earned.length} / ${kMilestones.length} earned',
                          style: GoogleFonts.manrope(
                              color: c.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: c.textSecondary, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: kMilestones.isEmpty
                      ? 0
                      : earned.length / kMilestones.length,
                  backgroundColor: c.border,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFFFFB340)),
                  minHeight: 6,
                ),
              ),
            ),

            const SizedBox(height: 16),
            Divider(color: c.border, height: 1),

            // Scrollable stamp grid
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categories.map((cat) {
                    final stamps = kMilestones.where((m) => m.category == cat).toList();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category label
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(cat,
                                  style: GoogleFonts.manrope(
                                      color: c.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        // Stamps grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.82,
                          ),
                          itemCount: stamps.length,
                          itemBuilder: (_, i) {
                            final m = stamps[i];
                            final isEarned = earned.contains(m.id);
                            return _StampCard(
                                milestone: m, isEarned: isEarned, c: c, primary: primary);
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StampCard extends StatelessWidget {
  final MilestoneDefinition milestone;
  final bool isEarned;
  final WealthColors c;
  final Color primary;

  const _StampCard({
    required this.milestone,
    required this.isEarned,
    required this.c,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEarned ? 1.0 : 0.35,
      child: CustomPaint(
        painter: _StampBorderPainter(
          color: isEarned ? const Color(0xFFFFB340) : c.border,
          earned: isEarned,
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isEarned
                ? const Color(0xFFFFB340).withValues(alpha: 0.08)
                : c.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              // Content
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(milestone.emoji,
                        style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 4),
                    Text(
                      milestone.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        color: c.textPrimary,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.monetization_on_rounded,
                            size: 9,
                            color: isEarned
                                ? const Color(0xFFFFB340)
                                : c.textSecondary),
                        const SizedBox(width: 2),
                        Text(
                          '${milestone.coinReward}',
                          style: TextStyle(
                              color: isEarned
                                  ? const Color(0xFFFFB340)
                                  : c.textSecondary,
                              fontSize: 9,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Earned stamp overlay
              if (isEarned)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 10),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws a postage-stamp style perforated border around the widget.
class _StampBorderPainter extends CustomPainter {
  final Color color;
  final bool earned;

  _StampBorderPainter({required this.color, required this.earned});

  @override
  void paint(Canvas canvas, Size size) {
    const r = 12.0; // corner radius
    const dotR = 4.0; // perforation circle radius
    const gap = 10.0; // spacing between perforations

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(dotR, dotR, size.width - dotR * 2, size.height - dotR * 2);

    // Draw filled rounded rect background border (thin)
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(r)), borderPaint);

    // Draw perforations along each edge
    void drawDots(Offset start, Offset end) {
      final dx = end.dx - start.dx;
      final dy = end.dy - start.dy;
      final len = (end - start).distance;
      final count = (len / gap).floor();
      for (int i = 0; i <= count; i++) {
        final t = i / count;
        final cx = start.dx + dx * t;
        final cy = start.dy + dy * t;
        // Punch out by drawing a filled circle matching background
        canvas.drawCircle(Offset(cx, cy), dotR, paint);
      }
    }

    final l = dotR, t = dotR, rr = size.width - dotR, b = size.height - dotR;
    drawDots(Offset(l + r, t), Offset(rr - r, t)); // top
    drawDots(Offset(l + r, b), Offset(rr - r, b)); // bottom
    drawDots(Offset(l, t + r), Offset(l, b - r)); // left
    drawDots(Offset(rr, t + r), Offset(rr, b - r)); // right
  }

  @override
  bool shouldRepaint(_StampBorderPainter old) =>
      old.color != color || old.earned != earned;
}
