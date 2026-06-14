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

  void _onAppLink(String screen) {
    _resolveAppLink(ref, screen);
    if (mounted) context.pop();
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
              child: _PromoWebView(
                url: widget.promo.url,
                onProgressChanged: (p) => setState(() => _progress = p),
                onAppLink: _onAppLink,
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
              child: _CloseButton(onTap: () => context.pop()),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class PromoSheet extends ConsumerStatefulWidget {
  const PromoSheet({super.key, required this.promo});

  final PromoEvent promo;

  static Future<void> show(BuildContext context, PromoEvent promo) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => PromoSheet(promo: promo),
    );
  }

  @override
  ConsumerState<PromoSheet> createState() => _PromoSheetState();
}

class _PromoSheetState extends ConsumerState<PromoSheet> {
  double _progress = 0;

  void _onAppLink(String screen) {
    _resolveAppLink(ref, screen);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Stack(
          children: [
            Positioned.fill(
              child: _PromoWebView(
                url: widget.promo.url,
                onProgressChanged: (p) => setState(() => _progress = p),
                onAppLink: _onAppLink,
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
              top: 12,
              right: 12,
              child: _CloseButton(onTap: () => Navigator.of(context).pop()),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class PromoModal extends ConsumerStatefulWidget {
  const PromoModal({super.key, required this.promo});

  final PromoEvent promo;

  static Future<void> show(BuildContext context, PromoEvent promo) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => PromoModal(promo: promo),
    );
  }

  @override
  ConsumerState<PromoModal> createState() => _PromoModalState();
}

class _PromoModalState extends ConsumerState<PromoModal> {
  double _progress = 0;

  void _onAppLink(String screen) {
    _resolveAppLink(ref, screen);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.72;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(
              child: _PromoWebView(
                url: widget.promo.url,
                onProgressChanged: (p) => setState(() => _progress = p),
                onAppLink: _onAppLink,
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
              top: 10,
              right: 10,
              child: _CloseButton(onTap: () => Navigator.of(context).pop()),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared WebView with app:// link interception

class _PromoWebView extends StatelessWidget {
  const _PromoWebView({
    required this.url,
    required this.onProgressChanged,
    required this.onAppLink,
  });

  final String url;
  final void Function(double) onProgressChanged;
  final void Function(String screen) onAppLink;

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(url)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
      ),
      onProgressChanged: (_, progress) => onProgressChanged(progress / 100),
      onLoadStart: (controller, uri) {
        if (uri != null && uri.scheme == 'app') {
          controller.stopLoading();
          onAppLink(uri.host);
        }
      },
      shouldOverrideUrlLoading: (_, action) async {
        final uri = action.request.url;
        if (uri != null && uri.scheme == 'app') {
          onAppLink(uri.host);
          return NavigationActionPolicy.CANCEL;
        }
        return NavigationActionPolicy.ALLOW;
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Resolves an app:// screen name to pending navigation providers

void _resolveAppLink(WidgetRef ref, String screen) {
  switch (screen) {
    case 'chat':
      ref.read(pendingNavigationProvider.notifier).state = AppRoute.chat.path;
    case 'notifications':
      ref.read(pendingNavigationProvider.notifier).state =
          AppRoute.notifications.path;
    case 'speaking':
      ref.read(pendingNavigationProvider.notifier).state =
          AppRoute.speaking.path;
    case 'speaking_history':
      ref.read(pendingNavigationProvider.notifier).state =
          AppRoute.speakingHistory.path;
    case 'vocabulary':
      ref.read(pendingNavigationProvider.notifier).state =
          AppRoute.vocabularyTraining.path;
    case 'word_battle':
      ref.read(pendingNavigationProvider.notifier).state =
          AppRoute.wordBattle.path;
    case 'writing_task':
      ref.read(pendingNavigationProvider.notifier).state =
          AppRoute.writingTask.path;
    case 'support':
      ref.read(pendingNavigationProvider.notifier).state =
          AppRoute.support.path;
    case 'home':
      ref.read(pendingMainTabProvider.notifier).state = MainScreen.homeTab;
    case 'courses':
      ref.read(pendingMainTabProvider.notifier).state = MainScreen.coursesTab;
    case 'profile':
      ref.read(pendingMainTabProvider.notifier).state = MainScreen.profileTab;
  }
}

// ---------------------------------------------------------------------------

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
