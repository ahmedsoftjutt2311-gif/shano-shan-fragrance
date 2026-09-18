import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import 'package:frontend/core/constants/app_assets.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage>
    with TickerProviderStateMixin {
  late final VideoPlayerController _videoController;

  // Final transition
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  bool _isInitialized = false;
  bool _hasError = false;
  bool _isNavigating = false;

  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    // ============================================================
    // FINAL FADE
    // ============================================================

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // ============================================================
    // VIDEO
    // ============================================================

    _videoController = VideoPlayerController.asset(
      AppAssets.introVideo,
    );

    _initializeVideo();
  }

  // ==============================================================
  // INITIALIZE VIDEO
  // ==============================================================

  Future<void> _initializeVideo() async {
    try {
      debugPrint('======================================');
      debugPrint('SHANO SHAN INTRO');
      debugPrint('Initializing video...');
      debugPrint('Asset: ${AppAssets.introVideo}');
      debugPrint('======================================');

      await _videoController.initialize();

      if (!mounted) return;

      debugPrint('Video initialized successfully.');

      debugPrint(
        'Video size: '
        '${_videoController.value.size.width} x '
        '${_videoController.value.size.height}',
      );

      debugPrint(
        'Video duration: '
        '${_videoController.value.duration}',
      );

      // ----------------------------------------------------------
      // Chrome autoplay support
      // ----------------------------------------------------------

      await _videoController.setVolume(0.0);

      await _videoController.seekTo(Duration.zero);

      _videoController.addListener(_videoListener);

      setState(() {
        _isInitialized = true;
      });

      debugPrint('Starting SHANO SHAN intro...');

      await _videoController.play();

      debugPrint('SHANO SHAN intro is playing.');
    } catch (e, stackTrace) {
      debugPrint('======================================');
      debugPrint('SHANO SHAN VIDEO ERROR');
      debugPrint('$e');
      debugPrint('$stackTrace');
      debugPrint('======================================');

      if (!mounted) return;

      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  // ==============================================================
  // VIDEO LISTENER
  // ==============================================================

  void _videoListener() {
    if (_isNavigating) return;

    final value = _videoController.value;

    if (!value.isInitialized) return;

    final duration = value.duration;
    final position = value.position;

    if (duration <= Duration.zero) return;

    final remaining = duration - position;

    if (remaining <= const Duration(milliseconds: 200) &&
        !value.isPlaying) {
      _videoFinished();
    }
  }

  // ==============================================================
  // VIDEO FINISHED
  // ==============================================================

  Future<void> _videoFinished() async {
    if (_isNavigating) return;

    debugPrint('SHANO SHAN: Intro video finished.');
    debugPrint('SHANO SHAN: Going to Home...');

    await _goToHome();
  }

  // ==============================================================
  // SKIP INTRO
  // ==============================================================

  Future<void> _skipIntro() async {
    if (_isNavigating) return;

    debugPrint('SHANO SHAN: Intro skipped.');

    await _goToHome();
  }

  // ==============================================================
  // GO TO HOME
  // ==============================================================

  Future<void> _goToHome() async {
    if (_isNavigating) return;

    _isNavigating = true;

    debugPrint('SHANO SHAN: Going to Home...');

    try {
      if (_videoController.value.isInitialized) {
        await _videoController.pause();
      }
    } catch (_) {}

    if (!mounted) return;

    // ------------------------------------------------------------
    // Fade smoothly to black.
    // ------------------------------------------------------------

    await _fadeController.forward();

    if (!mounted) return;

    context.go('/');
  }

  // ==============================================================
  // RETRY
  // ==============================================================

  Future<void> _retryVideo() async {
    if (!mounted) return;

    setState(() {
      _hasError = false;
      _isInitialized = false;
      _errorMessage = '';
    });

    try {
      await _videoController.seekTo(Duration.zero);

      await _videoController.setVolume(0.0);

      _videoController.removeListener(_videoListener);
      _videoController.addListener(_videoListener);

      setState(() {
        _isInitialized = true;
      });

      await _videoController.play();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(
            color: Colors.black,
          ),

          // ------------------------------------------------------
          // VIDEO
          // ------------------------------------------------------

          if (_isInitialized && !_hasError)
            _buildVideo(),

          // ------------------------------------------------------
          // LOADING
          // ------------------------------------------------------

          if (!_isInitialized && !_hasError)
            _buildLoading(),

          // ------------------------------------------------------
          // SKIP INTRO
          // ------------------------------------------------------

          if (_isInitialized && !_hasError)
            _buildSkipButton(),

          // ------------------------------------------------------
          // ERROR
          // ------------------------------------------------------

          if (_hasError)
            _buildError(),

          // ------------------------------------------------------
          // FINAL FADE
          // ------------------------------------------------------

          IgnorePointer(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return ColoredBox(
                  color: Colors.black.withValues(
                    alpha: _fadeAnimation.value,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // SKIP BUTTON
  // ==============================================================

  Widget _buildSkipButton() {
    return Positioned(
      top: 24,
      right: 24,
      child: SafeArea(
        child: TextButton(
          onPressed: _skipIntro,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'SKIP INTRO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w400,
              letterSpacing: 2.2,
            ),
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // VIDEO
  // ==============================================================

  Widget _buildVideo() {
    final videoSize = _videoController.value.size;

    if (videoSize.width <= 0 || videoSize.height <= 0) {
      return const SizedBox.expand(
        child: ColoredBox(
          color: Colors.black,
        ),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        alignment: Alignment.center,
        child: SizedBox(
          width: videoSize.width,
          height: videoSize.height,
          child: VideoPlayer(
            _videoController,
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // LOADING
  // ==============================================================

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'SHANO SHAN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              letterSpacing: 6,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // ERROR
  // ==============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SHANO SHAN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  letterSpacing: 7,
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'The intro video could not be played.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Chrome may not support the video codec.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 20),

              if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.06,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ),

              const SizedBox(height: 28),

              OutlinedButton(
                onPressed: _retryVideo,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(
                    color: Colors.white38,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                ),
                child: const Text(
                  'RETRY',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: _skipIntro,
                child: const Text(
                  'SKIP INTRO',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // DISPOSE
  // ==============================================================

  @override
  void dispose() {
    _videoController.removeListener(_videoListener);
    _videoController.dispose();

    _fadeController.dispose();

    super.dispose();
  }
}