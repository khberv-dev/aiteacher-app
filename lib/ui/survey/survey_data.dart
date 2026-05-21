import 'package:flutter/material.dart';

class SurveyOption {
  const SurveyOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeBackground,
  });

  final String id;
  final String title;
  final String subtitle;
  final String badgeText;
  final Color badgeColor;
  final Color badgeBackground;
}

class SurveyStep {
  const SurveyStep({
    required this.titleLines,
    required this.subtitle,
    required this.options,
    this.defaultOptionId,
  });

  final List<String> titleLines;
  final String subtitle;
  final List<SurveyOption> options;
  final String? defaultOptionId;
}

/// Survey selections forwarded from [SurveyScreen] through register/OTP
/// into the sign-up request body. All fields are optional; the API accepts
/// any subset.
class SurveyAnswers {
  const SurveyAnswers({this.goal, this.level, this.dailyTime});

  final String? goal;
  final String? level;
  final String? dailyTime;
}

const List<SurveyStep> kSurveySteps = [
  SurveyStep(
    titleLines: ['Maqsadingiz', 'nima? 🎯'],
    subtitle: "Sizga mos yo'l xaritasini tuzamiz",
    options: [
      SurveyOption(
        id: 'work',
        title: 'Ish uchun',
        subtitle: 'Intervyu, xorijiy hamkorlar',
        badgeText: '🏢',
        badgeColor: Color(0xFF000000),
        badgeBackground: Color(0xFFEFF6FF),
      ),
      SurveyOption(
        id: 'travel',
        title: 'Sayohat uchun',
        subtitle: 'Xorijda erkin gaplashish',
        badgeText: '✈️',
        badgeColor: Color(0xFF000000),
        badgeBackground: Color(0xFFF0FDF4),
      ),
      SurveyOption(
        id: 'study',
        title: "O'qish uchun",
        subtitle: 'CEFR, IELTS, akademik maqsadlar',
        badgeText: '🎓',
        badgeColor: Color(0xFF000000),
        badgeBackground: Color(0xFFFEF9C3),
      ),
      SurveyOption(
        id: 'personal',
        title: 'Shaxsiy rivojlanish',
        subtitle: 'Erkin muloqot, ishonch',
        badgeText: '💬',
        badgeColor: Color(0xFF000000),
        badgeBackground: Color(0xFFFDF4FF),
      ),
    ],
  ),
  SurveyStep(
    titleLines: ['Hozirgi', 'darajangiz? 📊'],
    subtitle: 'Rostini ayting — baholamaymiz 😊',
    options: [
      SurveyOption(
        id: 'a0',
        title: 'Hali boshlamaganman',
        subtitle: 'Ingliz tilini noldan boshlayman',
        badgeText: 'A0',
        badgeColor: Color(0xFFA21CAF),
        badgeBackground: Color(0xFFFDF4FF),
      ),
      SurveyOption(
        id: 'a1',
        title: "Boshlang'ich",
        subtitle: 'Salomlashishdan boshlayman',
        badgeText: 'A1',
        badgeColor: Color(0xFF64748B),
        badgeBackground: Color(0xFFF1F5F9),
      ),
      SurveyOption(
        id: 'b1',
        title: "O'rta daraja",
        subtitle: 'Gaplasha olaman, lekin qiyin',
        badgeText: 'B1',
        badgeColor: Color(0xFF2563EB),
        badgeBackground: Color(0xFFEFF6FF),
      ),
      SurveyOption(
        id: 'b2',
        title: 'Yuqori daraja',
        subtitle: 'Yaxshi gaplashaman, takomillashtiraman',
        badgeText: 'B2',
        badgeColor: Color(0xFF0D9488),
        badgeBackground: Color(0xFFF0FDFA),
      ),
      SurveyOption(
        id: 'c1',
        title: "Ilg'or",
        subtitle: 'Native kabi gaplashishni istayman',
        badgeText: 'C1',
        badgeColor: Color(0xFFD97706),
        badgeBackground: Color(0xFFFEF9C3),
      ),
    ],
  ),
  SurveyStep(
    titleLines: ['Kuniga qancha', 'vaqt? ⏱️'],
    subtitle: "Biroz ham bo'lsa yetarli!",
    options: [
      SurveyOption(
        id: 'short',
        title: '5–10 daqiqa',
        subtitle: 'Tez, lekin izchil',
        badgeText: '⚡',
        badgeColor: Color(0xFF000000),
        badgeBackground: Color(0xFFF0FDF4),
      ),
      SurveyOption(
        id: 'mid',
        title: '15–20 daqiqa',
        subtitle: 'Optimal — tavsiya etamiz',
        badgeText: '🎯',
        badgeColor: Color(0xFF000000),
        badgeBackground: Color(0xFFEFF6FF),
      ),
      SurveyOption(
        id: 'long',
        title: '30+ daqiqa',
        subtitle: "Intensiv o'rganish rejimi",
        badgeText: '🔥',
        badgeColor: Color(0xFF000000),
        badgeBackground: Color(0xFFFEF9C3),
      ),
    ],
  ),
];
