import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import 'package:go_router/go_router.dart';

class _FAQ {
  final String question;
  final String answer;
  bool expanded = false;

  _FAQ({required this.question, required this.answer});
}

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  final List<_FAQ> _faqs = [
    _FAQ(
      question: 'How is depreciation calculated?',
      answer:
          'Depreciation is calculated as: Price / (Lifespan in years × 365). This gives you a daily depreciation amount that is subtracted from the original price based on days since purchase.',
    ),
    _FAQ(
      question: 'What is net worth?',
      answer:
          'Net worth is Total Assets (current depreciated value) minus Total Liabilities (outstanding balances). It represents your true financial position.',
    ),
    _FAQ(
      question: 'Can I export my data?',
      answer:
          'Yes! Go to Profile → Data Export to export your assets and liabilities as CSV files.',
    ),
    _FAQ(
      question: 'Is my data secure?',
      answer:
          'Your data is stored in a Supabase database with row-level security. Only you can access your data. We never share your financial information.',
    ),
    _FAQ(
      question: 'How do I set a PIN?',
      answer:
          'During onboarding you can enable a PIN. To change it later, go to Profile → Security (coming soon).',
    ),
    _FAQ(
      question: 'What currencies are supported?',
      answer:
          'WealthTrack supports 20+ currencies. Go to Profile → Currency to change yours. All values will update immediately.',
    ),
    _FAQ(
      question: 'Can I edit or delete entries?',
      answer:
          'Yes! Tap any asset or liability card to expand it. You\'ll see Edit and Delete buttons. The Delete action requires confirmation.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    final filtered = _query.isEmpty
        ? _faqs
        : _faqs
            .where((f) =>
                f.question.toLowerCase().contains(_query.toLowerCase()) ||
                f.answer.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Custom header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Help & Support',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: Colors.white),
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Search FAQs...',
                  prefixIcon: Icon(Icons.search_rounded,
                      color: AppColors.greyText, size: 20),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Frequently Asked Questions',
                    style: GoogleFonts.manrope(
                      color: AppColors.greyText,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...filtered.map((faq) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: faq.expanded
                                ? primary.withValues(alpha: 0.4)
                                : AppColors.surfaceHighlight),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            final wasExpanded = faq.expanded;
                            for (var f in _faqs) {
                              f.expanded = false;
                            }
                            faq.expanded = !wasExpanded;
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      faq.question,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: faq.expanded
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: faq.expanded
                                          ? primary.withValues(alpha: 0.15)
                                          : AppColors.surfaceHighlight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      faq.expanded
                                          ? Icons.keyboard_arrow_up_rounded
                                          : Icons.keyboard_arrow_down_rounded,
                                      color: faq.expanded
                                          ? primary
                                          : AppColors.greyText,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                              if (faq.expanded) ...[
                                const SizedBox(height: 12),
                                const Divider(
                                    height: 1,
                                    color: AppColors.surfaceHighlight),
                                const SizedBox(height: 12),
                                Text(
                                  faq.answer,
                                  style: const TextStyle(
                                      color: AppColors.greyText,
                                      fontSize: 13,
                                      height: 1.5),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Contact Us card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceHighlight),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.mail_rounded,
                              color: primary, size: 26),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Need more help?',
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Our team is happy to assist you',
                          style: GoogleFonts.manrope(
                            color: AppColors.greyText,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () async {
                              final uri =
                                  Uri.parse('mailto:support@wealthtrack.app');
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text('Open Email'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
