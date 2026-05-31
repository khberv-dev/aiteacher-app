import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/chatbot/presentation/chatbot_controller.dart';
import 'package:ai_teacher/core/student_activity/data/student_activity_socket.dart';
import 'package:ai_teacher/ui/courses/course_video_screen.dart';
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
  late final StudentActivitySocket _activitySocket;

  @override
  void initState() {
    super.initState();
    _activitySocket = ref.read(studentActivitySocketProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _activitySocket.emitCourseStart();
    });
  }


  static const _observerScript = '''
(function() {
  if (window._appVideoObserver) {
    window._appVideoObserver.disconnect();
    window._appVideoObserver = null;
  }

  function replaceVideo(video) {
    if (video.hasAttribute("data-app-replaced")) return;
    var src = video.src || video.currentSrc;
    if (!src) {
      var s = video.querySelector("source");
      if (s) src = s.src;
    }
    if (!src || src.length === 0) return;

    video.setAttribute("data-app-replaced", "");
    video.hidden = true;

    var h = video.offsetHeight || 180;

    var wrap = document.createElement("div");
    wrap.style.cssText =
      "display:flex;align-items:center;justify-content:center;" +
      "width:100%;height:" + h + "px;" +
      "background:#4f6ef7;cursor:pointer;box-sizing:border-box;";

    wrap.innerHTML =
      "<div style=\\"width:64px;height:64px;border-radius:50%;" +
      "background:rgba(255,255,255,0.2);display:flex;" +
      "align-items:center;justify-content:center;\\">" +
      "<svg width=\\"28\\" height=\\"28\\" viewBox=\\"0 0 24 24\\" fill=\\"white\\">" +
      "<path d=\\"M8 5v14l11-7z\\"/></svg></div>";

    (function(videoSrc) {
      wrap.onclick = function() {
        window.flutter_inappwebview.callHandler("playVideo", videoSrc);
      };
    })(src);

    video.parentNode.insertBefore(wrap, video);
    debugPrint("[CourseWebScreen] Replaced video: " + src);
  }

  document.querySelectorAll("video:not([data-app-replaced])").forEach(replaceVideo);

  window._appVideoObserver = new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {
      mutation.addedNodes.forEach(function(node) {
        if (node.nodeType !== 1) return;
        if (node.tagName === "VIDEO") {
          replaceVideo(node);
        } else if (node.querySelectorAll) {
          node.querySelectorAll("video:not([data-app-replaced])").forEach(replaceVideo);
        }
      });
    });
  });

  window._appVideoObserver.observe(document.body, { childList: true, subtree: true });
})()
''';

  void _injectObserver() {
    _controller?.evaluateJavascript(source: _observerScript);
  }

  @override
  Widget build(BuildContext context) {
    // Keep the chatbot session alive for the entire duration of this screen.
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
              onPressed: () {
                _activitySocket.emitCourseEnd();
                Navigator.of(context).pop();
              },
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
        body: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(widget.url)),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            mediaPlaybackRequiresUserGesture: false,
            allowsInlineMediaPlayback: true,
          ),
          onWebViewCreated: (controller) {
            _controller = controller;
            controller.addJavaScriptHandler(
              handlerName: 'playVideo',
              callback: (args) {
                if (args.isNotEmpty && mounted) {
                  debugPrint('[CourseWebScreen] Opening video: ${args[0]}');
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          CourseVideoScreen(videoUrl: args[0].toString()),
                    ),
                  );
                }
              },
            );
          },
          onProgressChanged: (_, progress) {
            setState(() => _progress = progress / 100);
          },
          onLoadStop: (controller, url) => _injectObserver(),
          onUpdateVisitedHistory: (controller, url, isReload) =>
              _injectObserver(),
        ),
      ),
    );
  }
}
