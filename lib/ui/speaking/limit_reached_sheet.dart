import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/ui/profile/subscription_details_sheet.dart';
import 'package:flutter/material.dart';

class LimitReachedSheet extends StatelessWidget {
  const LimitReachedSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      isDismissible: true,
      builder: (_) => const LimitReachedSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2DED7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _Hero(),
                      const SizedBox(height: 24),
                      const Text(
                        "Mashqni to'xtatmang ✨",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Bugungi bepul 2 daqiqa tugadi. "
                        "Pro paketga obuna bo'ling — "
                        "ingliz tilingiz pauza qilmasin.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 26),
                      const _BenefitTile(
                        emoji: '♾️',
                        title: 'Cheksiz AI suhbat',
                        subtitle: 'Bir kun, bir hafta — mashqlar to\'xtamasin.',
                      ),
                      const SizedBox(height: 10),
                      const _BenefitTile(
                        emoji: '📊',
                        title: 'Batafsil hisobotlar',
                        subtitle:
                            "Talaffuz, grammatika, lug'at — sizning kuchli va zaif tomonlaringiz.",
                      ),
                      const SizedBox(height: 10),
                      const _BenefitTile(
                        emoji: '👨‍🏫',
                        title: 'Tirik mentor bilan',
                        subtitle:
                            "Chatda savol bering, qo'ng'iroq qiling — real ustoz yonida.",
                      ),
                      const SizedBox(height: 10),
                      const _BenefitTile(
                        emoji: '🚀',
                        title: 'Tezroq natija',
                        subtitle:
                            "Bir oyda — yangi daraja. O'rganganlaringizni gapirib his qiling.",
                      ),
                      const SizedBox(height: 22),
                      _SocialProof(),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                  child: Column(
                    children: [
                      _PrimaryCta(
                        onTap: () async {
                          Navigator.of(context).pop();
                          await SubscriptionDetailsSheet.show(context);
                        },
                      ),
                      const SizedBox(height: 10),
                      _SecondaryAction(
                        onTap: () => Navigator.of(context).pop(),
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
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF5B700).withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Text('🚀', style: TextStyle(fontSize: 44)),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  final String emoji;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialProof extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFEF3C7), width: 1),
      ),
      child: Row(
        children: [
          const Text('⭐', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "Minglab o'quvchilar Pro orqali ingliz tilini sevib o'rganmoqda.",
              style: TextStyle(
                color: Color(0xFF8A6D3B),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryCta extends StatelessWidget {
  const _PrimaryCta({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Pro paketga obuna bo'lish",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
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

class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF6B7280),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
      child: const Text(
        'Keyinroq qaytaman',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }
}
