import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class AnnouncementBar extends StatefulWidget {
  const AnnouncementBar({
    super.key,
  });

  @override
  State<AnnouncementBar> createState() => _AnnouncementBarState();
}

class _AnnouncementBarState extends State<AnnouncementBar> {
  // ============================================================
  // LIVE SHANO SHAN WORKER
  // ============================================================

  static const String apiBaseUrl =
      'https://shano-shan-api.hareem-pay-ahmed.workers.dev';

  // ============================================================

  final ScrollController _scrollController = ScrollController();

  Timer? _timer;

  double _scrollPosition = 0;

  bool _loading = true;
  bool _enabled = true;
  bool _showButton = true;

  String _message =
      'WELCOME TO SHANO SHAN • DISCOVER OUR SIGNATURE FRAGRANCES';

  String _buttonText = 'SHOP NOW';
  String _buttonUrl = '/shop';

  @override
  void initState() {
    super.initState();

    _loadSettings();
  }

  // ============================================================
  // LOAD LIVE SITE SETTINGS
  // ============================================================

  Future<void> _loadSettings() async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/settings/site'),
      );

      if (response.statusCode != 200) {
        _finishLoading();
        return;
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        _finishLoading();
        return;
      }

      final settings = decoded['settings'];

      if (settings is! Map) {
        _finishLoading();
        return;
      }

      final enabledValue =
          settings['announcement_enabled']?.toString().toLowerCase();

      final messageValue =
          settings['announcement_text']?.toString().trim();

      final buttonTextValue =
          settings['announcement_button_text']?.toString().trim();

      final buttonUrlValue =
          settings['announcement_button_url']?.toString().trim();

      if (!mounted) {
        return;
      }

      setState(() {
        _enabled = enabledValue != 'false';

        if (messageValue != null && messageValue.isNotEmpty) {
          _message = messageValue;
        }

        if (buttonTextValue != null && buttonTextValue.isNotEmpty) {
          _buttonText = buttonTextValue;
        }

        if (buttonUrlValue != null && buttonUrlValue.isNotEmpty) {
          _buttonUrl = buttonUrlValue;
        }

        _showButton =
            _buttonText.isNotEmpty && _buttonUrl.isNotEmpty;

        _loading = false;
      });

      if (_enabled) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _startAnimation();
        });
      }
    } catch (e) {
      debugPrint('Announcement settings error: $e');

      _finishLoading();
    }
  }

  void _finishLoading() {
    if (!mounted) {
      return;
    }

    setState(() {
      _loading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimation();
    });
  }

  // ============================================================
  // MARQUEE ANIMATION
  // ============================================================

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

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // While loading, don't show the old hardcoded announcement.
    if (_loading) {
      return const SizedBox.shrink();
    }

    if (!_enabled) {
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
              if (_showButton) ...[
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

  // ============================================================
  // MARQUEE
  // ============================================================

  Widget _buildMarquee(bool mobile) {
    final text = mobile
        ? '$_message     ✦     $_message'
        : '$_message     ✦     $_message     ✦     $_message';

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

  // ============================================================
  // BUTTON
  // ============================================================

  Widget _buildButton() {
    return InkWell(
      onTap: () {
        _openButton();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
        ),
        child: Center(
          child: Text(
            _buttonText,
            style: const TextStyle(
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

  // ============================================================
  // BUTTON ROUTING
  // ============================================================

  void _openButton() {
    final url = _buttonUrl.trim();

    if (url.isEmpty) {
      return;
    }

    // Internal Flutter route
    if (url.startsWith('/')) {
      context.go(url);
      return;
    }

    // If Admin enters an external URL, open it through the browser.
    // We intentionally don't add another dependency just for this.
    debugPrint('Announcement external URL: $url');
  }
}