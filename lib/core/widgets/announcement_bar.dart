import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AnnouncementBar extends StatefulWidget {
  const AnnouncementBar({
    super.key,
  });

  @override
  State<AnnouncementBar> createState() => _AnnouncementBarState();
}

class _AnnouncementBarState extends State<AnnouncementBar> {
  // ============================================================
  // TEMPORARY ANNOUNCEMENT
  //
  // Later these values can come from your Admin Panel / Worker.
  // ============================================================

  static const bool enabled = true;

  static const String message =
      'WELCOME TO SHANO SHAN  •  DISCOVER OUR SIGNATURE FRAGRANCES';

  static const String buttonText = 'SHOP NOW';

  static const String buttonRoute = '/shop';

  static const bool showButton = true;

  // ============================================================

  final ScrollController _scrollController = ScrollController();

  Timer? _timer;

  double _scrollPosition = 0;

  @override
  void initState() {
    super.initState();

    if (enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startAnimation();
      });
    }
  }

  void _startAnimation() {
    if (!mounted || !_scrollController.hasClients) {
      return;
    }

    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(milliseconds: 35),
      (_) {
        if (!mounted || !_scrollController.hasClients) {
          return;
        }

        final max = _scrollController.position.maxScrollExtent;

        if (max <= 0) {
          return;
        }

        _scrollPosition += 0.55;

        if (_scrollPosition >= max) {
          _scrollPosition = 0;
        }

        _scrollController.jumpTo(_scrollPosition);
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: 38,
      decoration: const BoxDecoration(
        color: Color(0xFFC9A45C),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mobile = constraints.maxWidth < 650;

          return Row(
            children: [
              Expanded(
                child: ClipRect(
                  child: _buildMarquee(mobile),
                ),
              ),

              if (showButton) ...[
                Container(
                  width: 1,
                  height: 20,
                  color: Colors.black.withValues(alpha: 0.20),
                ),
                _buildButton(),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildMarquee(bool mobile) {
    final text = mobile
        ? '$message     ✦     $message'
        : '$message     ✦     $message     ✦     $message';

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 35),
            Text(
              text,
              maxLines: 1,
              style: TextStyle(
                color: Colors.black,
                fontSize: mobile ? 9.5 : 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
              ),
            ),
            const SizedBox(width: 35),
          ],
        ),
      ),
    );
  }

  Widget _buildButton() {
    return InkWell(
      onTap: () {
        context.go(buttonRoute);
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 18,
        ),
        child: Center(
          child: Text(
            buttonText,
            style: TextStyle(
              color: Colors.black,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
