import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/chatbot/presentation/chatbot_controller.dart';
import 'package:ai_teacher/ui/courses/widget/chatbot_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CourseWebScreen extends ConsumerStatefulWidget {
  const CourseWebScreen({super.key, required this.title, required this.url});

  final String title;
  final String url;

  @override
  ConsumerState<CourseWebScreen> createState() => _CourseWebScreenState();
}

class _CourseWebScreenState extends ConsumerState<CourseWebScreen> {
  InAppWebViewController? _controller;
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    // Keep the chatbot session alive for the entire duration of this screen.
    // autoDispose will clean it up when the user navigates away.
    ref.watch(chatbotControllerProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: const Color(0xFF0F172A),
            onPressed: () async {
              if (_controller != null && await _controller!.canGoBack()) {
                _controller!.goBack();
              } else if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            widget.title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close_rounded),
              color: const Color(0xFF0F172A),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(3),
            child: _progress < 1
                ? LinearProgressIndicator(
                    value: _progress,
                    minHeight: 3,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  )
                : const SizedBox(height: 3),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => ChatbotSheet.show(context),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          child: const Icon(Icons.auto_awesome_rounded),
        ),
        body: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(widget.url)),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            mediaPlaybackRequiresUserGesture: false,
            allowsInlineMediaPlayback: true,
          ),
          onWebViewCreated: (controller) => _controller = controller,
          onProgressChanged: (_, progress) {
            setState(() => _progress = progress / 100);
          },
        ),
      ),
    );
  }
}
