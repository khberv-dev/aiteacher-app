import 'dart:async';

import 'package:ai_teacher/app/theme/app_colors.dart';
import 'package:ai_teacher/core/chatbot/presentation/chatbot_controller.dart';
import 'package:ai_teacher/ui/courses/widget/chatbot_view.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

class CourseVideoScreen extends ConsumerStatefulWidget {
  const CourseVideoScreen({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  ConsumerState<CourseVideoScreen> createState() => _CourseVideoScreenState();
}

class _CourseVideoScreenState extends ConsumerState<CourseVideoScreen> {
  late final VideoPlayerController _videoCtrl;
  ChewieController? _chewieCtrl;
  bool _videoError = false;
  bool _inputFocused = false;
  bool _closeVisible = true;
  Timer? _hideCloseTimer;

  @override
  void initState() {
    super.initState();
    _initVideo();
    _scheduleHideClose();
  }

  Future<void> _initVideo() async {
    _videoCtrl = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    try {
      await _videoCtrl.initialize();
      if (!mounted) return;
      setState(() {
        _chewieCtrl = ChewieController(
          videoPlayerController: _videoCtrl,
          autoPlay: true,
          looping: false,
          allowFullScreen: true,
          allowMuting: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: AppColors.primary,
            handleColor: AppColors.primary,
            bufferedColor: AppColors.primary.withValues(alpha: 0.3),
            backgroundColor: const Color(0xFFE2E8F0),
          ),
        );
      });
    } catch (_) {
      if (mounted) setState(() => _videoError = true);
    }
  }

  void _onVideoPointerDown() {
    setState(() => _closeVisible = true);
    _scheduleHideClose();
  }

  void _scheduleHideClose() {
    _hideCloseTimer?.cancel();
    _hideCloseTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _closeVisible = false);
    });
  }

  @override
  void dispose() {
    _hideCloseTimer?.cancel();
    _chewieCtrl?.dispose();
    _videoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(chatbotControllerProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              Stack(
                children: [
                  ClipRect(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: _inputFocused
                          ? 0.0
                          : MediaQuery.of(context).size.height * 0.3,
                      child: _buildVideoPlayer(),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: _closeVisible ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: _inputFocused ? 0.0 : 12.0,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: ChatbotView(
                  onInputFocusChanged: (focused) {
                    setState(() => _inputFocused = focused);
                    if (focused) {
                      _chewieCtrl?.pause();
                    } else {
                      _chewieCtrl?.play();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_videoError) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 40, color: Color(0xFF94A3B8)),
            SizedBox(height: 8),
            Text(
              'Video yuklanmadi',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
          ],
        ),
      );
    }
    if (_chewieCtrl == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _onVideoPointerDown(),
      child: Container(
        color: Colors.black,
        child: Chewie(controller: _chewieCtrl!),
      ),
    );
  }
}
