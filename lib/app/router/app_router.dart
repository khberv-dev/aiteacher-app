import 'package:ai_teacher/app/data/cache_service.dart';
import 'package:ai_teacher/core/auth/data/auth_dtos.dart';
import 'package:ai_teacher/core/speaking/data/assessment.dart';
import 'package:ai_teacher/ui/auth/login_screen.dart';
import 'package:ai_teacher/ui/auth/otp_screen.dart';
import 'package:ai_teacher/ui/auth/register_screen.dart';
import 'package:ai_teacher/ui/call/call_screen.dart';
import 'package:ai_teacher/ui/chat/chat_list_data.dart';
import 'package:ai_teacher/ui/chat/chat_screen.dart';
import 'package:ai_teacher/ui/main/main_screen.dart';
import 'package:ai_teacher/ui/onboarding/onboarding_screen.dart';
import 'package:ai_teacher/ui/speaking/assessment_history_screen.dart';
import 'package:ai_teacher/ui/speaking/speaking_partner_screen.dart';
import 'package:ai_teacher/ui/speaking/speaking_report_screen.dart';
import 'package:ai_teacher/ui/survey/survey_data.dart';
import 'package:ai_teacher/ui/survey/survey_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final hasAccessToken =
      (ref.read(cacheServiceProvider).accessToken ?? '').isNotEmpty;
  return GoRouter(
    initialLocation: hasAccessToken
        ? AppRoute.main.path
        : AppRoute.onboarding.path,
    routes: [
      GoRoute(
        path: AppRoute.onboarding.path,
        name: AppRoute.onboarding.name,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoute.survey.path,
        name: AppRoute.survey.name,
        builder: (context, state) => const SurveyScreen(),
      ),
      GoRoute(
        path: AppRoute.register.path,
        name: AppRoute.register.name,
        builder: (context, state) {
          final extra = state.extra;
          return RegisterScreen(
            surveyAnswers: extra is SurveyAnswers ? extra : null,
          );
        },
      ),
      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.name,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoute.otp.path,
        name: AppRoute.otp.name,
        builder: (context, state) {
          if (state.extra is! RegistrationDraft) {
            return const RegisterScreen();
          }
          return OtpScreen(draft: state.extra as RegistrationDraft);
        },
      ),
      GoRoute(
        path: AppRoute.main.path,
        name: AppRoute.main.name,
        builder: (context, state) {
          final tab = state.extra is int
              ? state.extra as int
              : MainScreen.homeTab;
          return MainScreen(initialTab: tab);
        },
      ),
      GoRoute(
        path: AppRoute.speaking.path,
        name: AppRoute.speaking.name,
        builder: (context, state) => const SpeakingPartnerScreen(),
      ),
      GoRoute(
        path: AppRoute.speakingReport.path,
        name: AppRoute.speakingReport.name,
        builder: (context, state) {
          final assessment = state.extra is Assessment
              ? state.extra as Assessment
              : kSampleAssessment;
          return SpeakingReportScreen(assessment: assessment);
        },
      ),
      GoRoute(
        path: AppRoute.chat.path,
        name: AppRoute.chat.name,
        builder: (context, state) {
          if (state.extra is! ChatListItem) {
            return const MainScreen(initialTab: MainScreen.chatTab);
          }
          return ChatScreen(chat: state.extra as ChatListItem);
        },
      ),
      GoRoute(
        path: AppRoute.call.path,
        name: AppRoute.call.name,
        builder: (context, state) => const CallScreen(),
      ),
      GoRoute(
        path: AppRoute.speakingHistory.path,
        name: AppRoute.speakingHistory.name,
        builder: (context, state) => const AssessmentHistoryScreen(),
      ),
    ],
  );
});

enum AppRoute {
  onboarding('/'),
  survey('/survey'),
  register('/register'),
  login('/login'),
  otp('/otp'),
  main('/main'),
  speaking('/speaking'),
  speakingReport('/speaking-report'),
  speakingHistory('/speaking-history'),
  chat('/chat'),
  call('/call');

  const AppRoute(this.path);

  final String path;
}
