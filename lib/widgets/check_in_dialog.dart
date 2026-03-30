import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme_colors.dart';
import '../providers/profile_provider.dart';

class CheckInDialog extends ConsumerStatefulWidget {
  const CheckInDialog({super.key});

  @override
  ConsumerState<CheckInDialog> createState() => _CheckInDialogState();
}

class _CheckInDialogState extends ConsumerState<CheckInDialog> {
  bool _claiming = false;
  bool _justClaimed = false;

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).valueOrNull;
    final c = WealthColors.of(context);
    final primary = Theme.of(context).primaryColor;

    final now = DateTime.now();
    final today = _dateStr(now);
    final alreadyClaimed = profile?.lastCheckIn == today;
    final coins = profile?.coins ?? 0;
    final streak = profile?.streak ?? 0;
    final checkInDates = profile?.checkInDates ?? [];

    // Build calendar grid for current month
    final firstDay = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    // weekday: 1=Mon ... 7=Sun, we want 0=Sun offset
    final startWeekday = firstDay.weekday % 7; // Sun=0, Mon=1 ...

    const gold = Color(0xFFFFC107);
    const dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Dialog(
      backgroundColor: c.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: gold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.monetization_on_rounded,
                      color: gold, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily Check-In',
                          style: GoogleFonts.manrope(
                              color: c.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w700)),
                      Text('$coins coins  •  $streak day streak',
                          style: GoogleFonts.manrope(
                              color: c.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close_rounded,
                      color: c.textSecondary, size: 20),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Month title
            Text(
              _monthLabel(now),
              style: GoogleFonts.manrope(
                  color: c.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 12),

            // Day-of-week headers
            Row(
              children: dayLabels
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(d,
                              style: TextStyle(
                                  color: c.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 8),

            // Calendar grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 4,
                childAspectRatio: 1,
              ),
              itemCount: startWeekday + daysInMonth,
              itemBuilder: (ctx, index) {
                if (index < startWeekday) return const SizedBox();
                final day = index - startWeekday + 1;
                final dateStr = _dateStr(DateTime(now.year, now.month, day));
                final isChecked = checkInDates.contains(dateStr);
                final isToday = day == now.day;
                final isPast = day < now.day;

                if (isChecked) {
                  // Gold coin day
                  return Container(
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: gold, width: 1.5),
                    ),
                    child: Center(
                      child: Icon(Icons.monetization_on_rounded,
                          color: gold, size: 16),
                    ),
                  );
                } else if (isToday) {
                  // Today — highlighted ring
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: alreadyClaimed ? gold : primary, width: 2),
                      color: (alreadyClaimed ? gold : primary)
                          .withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: Text('$day',
                          style: TextStyle(
                              color: alreadyClaimed ? gold : primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ),
                  );
                } else if (isPast) {
                  // Missed day — grey
                  return Center(
                    child: Text('$day',
                        style: TextStyle(
                            color: c.textSecondary.withValues(alpha: 0.4),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  );
                } else {
                  // Future day — faded
                  return Center(
                    child: Text('$day',
                        style: TextStyle(
                            color: c.textSecondary.withValues(alpha: 0.25),
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                  );
                }
              },
            ),

            const SizedBox(height: 20),

            // Collect button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (alreadyClaimed || _claiming)
                    ? null
                    : () async {
                        setState(() => _claiming = true);
                        final awarded =
                            await ref.read(profileProvider.notifier).checkIn();
                        if (mounted) {
                          setState(() {
                            _claiming = false;
                            if (awarded) _justClaimed = true;
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: alreadyClaimed ? c.border : gold,
                  foregroundColor:
                      alreadyClaimed ? c.textSecondary : Colors.black,
                  disabledBackgroundColor: c.border,
                  disabledForegroundColor: c.textSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _claiming
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.black))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            alreadyClaimed
                                ? Icons.check_circle_rounded
                                : Icons.monetization_on_rounded,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            alreadyClaimed
                                ? 'Already collected today'
                                : _justClaimed
                                    ? 'Coin collected! +1'
                                    : 'Collect today\'s coin',
                            style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthLabel(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}
