import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

class _Notification {
  final String id;
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String time;
  bool read;

  _Notification({
    required this.id,
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
    this.read = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_Notification> _notifications = [
    _Notification(
      id: '1',
      icon: Icons.trending_down_rounded,
      color: AppColors.primary,
      title: 'Asset Depreciated',
      body: 'Your MacBook Pro has lost 10% of its value.',
      time: '2 hours ago',
    ),
    _Notification(
      id: '2',
      icon: Icons.credit_card_rounded,
      color: AppColors.danger,
      title: 'Monthly Payment Due',
      body: 'Car loan payment of \$350 is due this week.',
      time: '5 hours ago',
    ),
    _Notification(
      id: '3',
      icon: Icons.emoji_events_rounded,
      color: const Color(0xFFFFB340),
      title: 'Net Worth Milestone',
      body: 'You\'ve crossed \$10,000 net worth!',
      time: '1 day ago',
    ),
    _Notification(
      id: '4',
      icon: Icons.info_rounded,
      color: AppColors.primary,
      title: 'Welcome to WealthTrack',
      body: 'Start by adding your assets and liabilities.',
      time: '2 days ago',
      read: true,
    ),
  ];

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n.read = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final unreadCount = _notifications.where((n) => !n.read).length;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Notifications'),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                'Mark all read',
                style: TextStyle(color: primary, fontSize: 13),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications_none_rounded,
                      color: AppColors.greyText, size: 56),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (_, i) {
                final n = _notifications[i];
                return GestureDetector(
                  onTap: () => setState(() => n.read = true),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: n.read
                          ? AppColors.cardDark
                          : AppColors.surfaceHighlight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: n.read
                            ? AppColors.surfaceHighlight
                            : primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: n.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(n.icon, color: n.color, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      n.title,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: n.read
                                            ? FontWeight.w500
                                            : FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  if (!n.read)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                n.body,
                                style: const TextStyle(
                                    color: AppColors.greyText, fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                n.time,
                                style: const TextStyle(
                                    color: AppColors.greyText, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
