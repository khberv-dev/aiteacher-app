import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VocabularyIntroSheet extends StatelessWidget {
  const VocabularyIntroSheet._({required this.onStart});

  final VoidCallback onStart;

  static Future<void> show(BuildContext context) {
    final router = GoRouter.of(context);
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => VocabularyIntroSheet._(
        onStart: () => router.goNamed(AppRoute.vocabularyTraining.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.menu_book_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Lug'at mashqi",
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "So'zlarni ovoz bilan o'rganing",
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const _SectionTitle("Qanday ishlaydi?"),
                    const SizedBox(height: 14),
                    const _StepCard(
                      icon: '📖',
                      title: "So'z ko'rsatiladi",
                      body:
                          "Ekranda inglizcha so'z va uning CEFR darajasi ko'rsatiladi.",
                    ),
                    const SizedBox(height: 10),
                    const _StepCard(
                      icon: '🎙️',
                      title: "Tugmani ushlab gapiring",
                      body:
                          "Yumaloq mikrofon tugmasini bosib ushlab turing va so'zni gapirib yuboring. Qo'yib yuborganingizda audio serverga yuboriladi.",
                    ),
                    const SizedBox(height: 10),
                    const _StepCard(
                      icon: '🤖',
                      title: "AI baholaydi",
                      body:
                          "Talaffuzingiz, mazmuniy to'g'riligi va gapda ishlatilishini sun'iy intellekt tekshiradi va fikr bildiradi.",
                    ),
                    const SizedBox(height: 10),
                    const _StepCard(
                      icon: '✅',
                      title: "To'g'ri bo'lsa o'chadi",
                      body:
                          "Agar to'g'ri talaffuz qilsangiz, so'z lug'atdan olib tashlanadi — uni o'zlashtirdingiz!",
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle("Qo'shimcha tugmalar"),
                    const SizedBox(height: 14),
                    const _ButtonInfoCard(
                      emoji: '👍',
                      color: Color(0xFF16A34A),
                      bg: Color(0xFFF0FDF4),
                      borderColor: Color(0xFFBBF7D0),
                      title: "Yashil tugma — o'tkazib yuborish",
                      body:
                          "So'zni allaqachon bilsangiz yoki keyingisiga o'tmoqchi bo'lsangiz bosing.",
                    ),
                    const SizedBox(height: 10),
                    const _ButtonInfoCard(
                      emoji: '🤷',
                      color: Color(0xFFB91C1C),
                      bg: Color(0xFFFEF2F2),
                      borderColor: Color(0xFFFECACA),
                      title: "Qizil tugma — ta'rif ko'rish",
                      body:
                          "So'z ma'nosini bilmoqchi bo'lsangiz bosing — ta'rif va misol gapni ko'rasiz.",
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onStart();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Boshlash",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 15,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final String icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFF475569),
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

class _ButtonInfoCard extends StatelessWidget {
  const _ButtonInfoCard({
    required this.emoji,
    required this.color,
    required this.bg,
    required this.borderColor,
    required this.title,
    required this.body,
  });

  final String emoji;
  final Color color;
  final Color bg;
  final Color borderColor;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFF475569),
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
