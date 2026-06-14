import 'package:ai_teacher/app/router/app_router.dart';
import 'package:ai_teacher/core/promo/data/promo_dtos.dart';
import 'package:ai_teacher/ui/main/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PromoScreen extends ConsumerStatefulWidget {
  const PromoScreen({super.key, required this.promo});

  final PromoEvent promo;

  @override
  ConsumerState<PromoScreen> createState() => _PromoScreenState();
}

class _PromoScreenState extends ConsumerState<PromoScreen> {
  double _progress = 0;

  void _handleAppLink(String screen) {
    context.pop();
    switch (screen) {
      case 'chat':
        context.push(AppRoute.chat.path);
      case 'notifications':
        context.push(AppRoute.notifications.path);
      case 'speaking':
        context.push(AppRoute.speaking.path);
      case 'speaking_history':
        context.push(AppRoute.speakingHistory.path);
      case 'vocabulary':
        context.push(AppRoute.vocabularyTraining.path);
      case 'word_battle':
        context.push(AppRoute.wordBattle.path);
      case 'writing_task':
        context.push(AppRoute.writingTask.path);
      case 'support':
        context.push(AppRoute.support.path);
      case 'home':
        ref.read(pendingMainTabProvider.notifier).state = MainScreen.homeTab;
      case 'courses':
        ref.read(pendingMainTabProvider.notifier).state = MainScreen.coursesTab;
      case 'profile':
        ref.read(pendingMainTabProvider.notifier).state = MainScreen.profileTab;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(widget.promo.url)),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  mediaPlaybackRequiresUserGesture: false,
                  allowsInlineMediaPlayback: true,
                ),
                onProgressChanged: (_, progress) {
                  setState(() => _progress = progress / 100);
                },
                shouldOverrideUrlLoading: (_, action) async {
                  final uri = action.request.url;
                  if (uri != null && uri.scheme == 'app') {
                    if (mounted) _handleAppLink(uri.host);
                    return NavigationActionPolicy.CANCEL;
                  }
                  return NavigationActionPolicy.ALLOW;
                },
                onLoadStart: (controller, url) async {
                  if (url != null && url.scheme == 'app') {
                    await controller.stopLoading();
                    if (mounted) _handleAppLink(url.host);
                  }
                },
              ),
            ),
            if (_progress < 1)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 3,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation(Colors.white54),
                ),
              ),
            Positioned(
              top: topPadding + 8,
              right: 12,
              child: _CloseButton(onTap: () => Navigator.of(context).pop()),
            ),
          ],
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black45,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(Icons.close_rounded, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
