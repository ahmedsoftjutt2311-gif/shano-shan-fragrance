import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/cart_service.dart';
import '../../services/shano_ai_service.dart';

class ShanoAiChat extends StatefulWidget {
  const ShanoAiChat({super.key});

  @override
  State<ShanoAiChat> createState() => _ShanoAiChatState();
}

class _ShanoAiChatState extends State<ShanoAiChat> {
  // ==========================================================================
  // COLORS
  // ==========================================================================

  static const Color gold = Color(0xFFD6B36A);
  static const Color lightGold = Color(0xFFE8CC91);
  static const Color background = Color(0xFF080808);
  static const Color panel = Color(0xFF111111);
  static const Color inputBackground = Color(0xFF181818);
  static const Color border = Color(0xFF292929);

  // ==========================================================================
  // CONTROLLERS
  // ==========================================================================

  final TextEditingController _controller =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  // ==========================================================================
  // STATE
  // ==========================================================================

  final List<_ChatMessage> _messages = [];

  bool _isOpen = false;
  bool _isLoading = false;

  double _left = 20.0;
  double _top = 0.0;

  bool _positionInitialized = false;

  Size? _lastViewportSize;
  bool _viewportClampScheduled = false;

  // ==========================================================================
  // INIT
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _messages.add(
      const _ChatMessage(
        text:
            'Welcome to SHANO AI. Tell me what kind of fragrance you are looking for and I will help you explore our collection.',
        isUser: false,
      ),
    );
  }

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // SAFE DOUBLE CLAMP
  // ==========================================================================

  double _safeClamp(
    double value,
    double minimum,
    double maximum,
  ) {
    // If the widget is larger than the available viewport,
    // keep it at the minimum safe position instead of creating
    // an invalid clamp range.
    if (maximum < minimum) {
      return minimum;
    }

    if (value < minimum) {
      return minimum;
    }

    if (value > maximum) {
      return maximum;
    }

    return value;
  }

  // ==========================================================================
  // RESPONSIVE POSITION
  // ==========================================================================

  void _initializePosition(Size size) {
    if (_positionInitialized) {
      return;
    }

    const double buttonHeight = 50.0;

    _left = 20.0;
    _top = size.height - buttonHeight - 24.0;

    _positionInitialized = true;

    _keepInsideViewport(
      size,
      widgetWidth: 210.0,
      widgetHeight: buttonHeight,
    );
  }

  void _keepInsideViewport(
    Size size, {
    required double widgetWidth,
    required double widgetHeight,
  }) {
    final double maximumLeft =
        size.width - widgetWidth - 12.0;

    final double maximumTop =
        size.height - widgetHeight - 12.0;

    _left = _safeClamp(
      _left,
      12.0,
      maximumLeft,
    );

    _top = _safeClamp(
      _top,
      12.0,
      maximumTop,
    );
  }

  // ==========================================================================
  // MOVE WIDGET
  // ==========================================================================

  void _moveBy(
    Offset delta,
    Size size, {
    required double width,
    required double height,
  }) {
    if (!mounted) {
      return;
    }

    setState(() {
      _left += delta.dx;
      _top += delta.dy;

      _keepInsideViewport(
        size,
        widgetWidth: width,
        widgetHeight: height,
      );
    });
  }

  // ==========================================================================
  // VIEWPORT RESIZE HANDLING
  // ==========================================================================

  void _scheduleViewportClamp(Size screenSize) {
    if (_viewportClampScheduled) {
      return;
    }

    final Size? previous = _lastViewportSize;

    if (previous != null &&
        previous.width == screenSize.width &&
        previous.height == screenSize.height) {
      return;
    }

    _lastViewportSize = screenSize;
    _viewportClampScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewportClampScheduled = false;

      if (!mounted) {
        return;
      }

      final bool mobile = screenSize.width < 600.0;

      final double widgetWidth;

      final double widgetHeight;

      if (_isOpen) {
        widgetWidth = mobile
            ? (screenSize.width - 24.0)
            : 420.0;

        widgetHeight = mobile
            ? (screenSize.height - 110.0)
            : 650.0;
      } else {
        widgetWidth = mobile ? 184.0 : 210.0;
        widgetHeight = mobile ? 46.0 : 52.0;
      }

      final double oldLeft = _left;
      final double oldTop = _top;

      _keepInsideViewport(
        screenSize,
        widgetWidth: widgetWidth,
        widgetHeight: widgetHeight,
      );

      if (oldLeft != _left || oldTop != _top) {
        setState(() {});
      }
    });
  }

  // ==========================================================================
  // OPEN CHAT
  // ==========================================================================

  void _openChat() {
    final Size size = MediaQuery.sizeOf(context);

    final bool mobile = size.width < 600.0;

    final double panelWidth = mobile
        ? (size.width - 24.0)
        : 420.0;

    final double panelHeight = mobile
        ? (size.height - 110.0)
        : 650.0;

    setState(() {
      _isOpen = true;

      _keepInsideViewport(
        size,
        widgetWidth: panelWidth,
        widgetHeight: panelHeight,
      );
    });

    _scrollToBottom();
  }

  // ==========================================================================
  // CLOSE CHAT
  // ==========================================================================

  void _closeChat() {
    FocusScope.of(context).unfocus();

    setState(() {
      _isOpen = false;
    });
  }

  // ==========================================================================
  // SEND MESSAGE
  // ==========================================================================

  Future<void> _sendMessage(String value) async {
    final String message = value.trim();

    if (message.isEmpty || _isLoading) {
      return;
    }

    _controller.clear();

    final List<Map<String, String>> history =
        _messages
            .map(
              (item) => <String, String>{
                'role': item.isUser
                    ? 'user'
                    : 'assistant',
                'content': item.text,
              },
            )
            .toList();

    setState(() {
      _messages.add(
        _ChatMessage(
          text: message,
          isUser: true,
        ),
      );

      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final result =
          await ShanoAiService.instance.chat(
        message: message,
        history: history,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add(
          _ChatMessage(
            text: result.reply,
            isUser: false,
            recommendations: result.recommendations,
          ),
        );

        _isLoading = false;
      });

      _scrollToBottom();
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add(
          const _ChatMessage(
            text:
                'I’m sorry, SHANO AI is temporarily unavailable. Please try again in a moment.',
            isUser: false,
          ),
        );

        _isLoading = false;
      });

      _scrollToBottom();
    }
  }

  // ==========================================================================
  // SCROLL
  // ==========================================================================

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // ==========================================================================
  // PRICE
  // ==========================================================================

  String _formatPrice(
    ShanoAiProduct product,
  ) {
    final num price = product.price;

    if (price == price.roundToDouble()) {
      return '${product.currency} ${price.toStringAsFixed(0)}';
    }

    return '${product.currency} ${price.toStringAsFixed(2)}';
  }

  // ==========================================================================
  // ADD TO BAG
  // ==========================================================================

  Future<void> _addToBag(
    ShanoAiProduct product,
  ) async {
    if (product.stock <= 0) {
      return;
    }

    try {
      await CartService.instance.addItem(
        id: product.id,
        slug: product.slug,
        name: product.name,
        category: product.category,
        description: product.description,
        price: product.price.round(),
        currency: product.currency,
        imageUrl: product.imageUrl,
        stock: product.stock,
        quantity: 1,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${product.name} added to your bag.',
          ),
          backgroundColor: const Color(0xFF1A1A1A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to add this fragrance to your bag.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ==========================================================================
  // VIEW PRODUCT
  // ==========================================================================

  void _viewProduct(
    ShanoAiProduct product,
  ) {
    _closeChat();

    context.push(
      '/product/${Uri.encodeComponent(product.slug)}',
    );
  }

  // ==========================================================================
  // FLOATING BUTTON
  // ==========================================================================

  Widget _buildFloatingButton(
    Size screenSize,
  ) {
    final bool mobile = screenSize.width < 600.0;

    final double width = mobile ? 184.0 : 210.0;
    final double height = mobile ? 46.0 : 52.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      onPanUpdate: (details) {
        _moveBy(
          details.delta,
          screenSize,
          width: width,
          height: height,
        );
      },

      onTap: _openChat,

      child: Material(
        color: Colors.transparent,
        child: Container(
          width: width,
          height: height,
          padding: EdgeInsets.symmetric(
            horizontal: mobile ? 12.0 : 16.0,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(
              mobile ? 25.0 : 30.0,
            ),
            border: Border.all(
              color: gold.withValues(alpha: 0.75),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.45,
                ),
                blurRadius: mobile ? 15.0 : 20.0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                color: gold,
                size: mobile ? 16.0 : 19.0,
              ),
              SizedBox(
                width: mobile ? 7.0 : 9.0,
              ),
              Flexible(
                child: Text(
                  'ASK SHANO AI',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: lightGold,
                    fontSize: mobile ? 10.0 : 12.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing:
                        mobile ? 1.1 : 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // CHAT PANEL
  // ==========================================================================

  Widget _buildChatPanel(
    BuildContext context,
  ) {
    final Size screenSize = MediaQuery.sizeOf(context);

    final bool isMobile = screenSize.width < 600.0;

    final double width = isMobile
        ? (screenSize.width - 24.0)
        : 420.0;

    final double height = isMobile
        ? (screenSize.height - 110.0)
        : 650.0;

    return GestureDetector(
      onPanUpdate: (details) {
        _moveBy(
          details.delta,
          screenSize,
          width: width,
          height: height,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: gold.withValues(alpha: 0.30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.60,
                ),
                blurRadius: 35.0,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(),

              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    15.0,
                    17.0,
                    15.0,
                    10.0,
                  ),
                  itemCount:
                      _messages.length +
                      (_isLoading ? 1 : 0),
                  itemBuilder: (
                    BuildContext context,
                    int index,
                  ) {
                    if (_isLoading &&
                        index == _messages.length) {
                      return _buildTypingIndicator();
                    }

                    return _buildMessage(
                      _messages[index],
                    );
                  },
                ),
              ),

              _buildSuggestions(),
              _buildInput(),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // HEADER
  // ==========================================================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        17.0,
        16.0,
        9.0,
        15.0,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: border,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42.0,
            height: 42.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: gold.withValues(alpha: 0.45),
              ),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: gold,
              size: 20.0,
            ),
          ),

          const SizedBox(width: 11.0),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'SHANO AI',
                  style: TextStyle(
                    color: lightGold,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.7,
                  ),
                ),
                SizedBox(height: 3.0),
                Text(
                  'YOUR FRAGRANCE ASSISTANT',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 9.0,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: _closeChat,
            tooltip: 'Close',
            icon: const Icon(
              Icons.close,
              color: Colors.white70,
              size: 20.0,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // MESSAGE
  // ==========================================================================

  Widget _buildMessage(
    _ChatMessage message,
  ) {
    final bool isUser = message.isUser;

    return Align(
      alignment: isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 335.0,
        ),
        margin: const EdgeInsets.only(
          bottom: 13.0,
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 11.0,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? gold
                    : const Color(0xFF181818),
                borderRadius:
                    BorderRadius.circular(15.0),
                border: isUser
                    ? null
                    : Border.all(
                        color: border,
                      ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser
                      ? Colors.black
                      : Colors.white.withValues(
                          alpha: 0.90,
                        ),
                  fontSize: 13.0,
                  height: 1.5,
                ),
              ),
            ),

            if (!isUser &&
                message.recommendations.isNotEmpty)
              ...message.recommendations.map(
                _buildRecommendation,
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // PRODUCT RECOMMENDATION
  // ==========================================================================

  Widget _buildRecommendation(
    ShanoAiProduct product,
  ) {
    return LayoutBuilder(
      builder: (
        BuildContext context,
        BoxConstraints constraints,
      ) {
        final double availableWidth =
            constraints.maxWidth;

        final double cardWidth =
            availableWidth < 320.0
                ? availableWidth
                : 320.0;

        return Container(
          width: cardWidth,
          margin: const EdgeInsets.only(
            top: 9.0,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            borderRadius:
                BorderRadius.circular(14.0),
            border: Border.all(
              color: gold.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildProductImage(product),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  13.0,
                  12.0,
                  13.0,
                  13.0,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: lightGold,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.7,
                      ),
                    ),

                    const SizedBox(height: 5.0),

                    Text(
                      product.category,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 9.0,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 9.0),

                    Text(
                      _formatPrice(product),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 13.0),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                _viewProduct(product),
                            style:
                                OutlinedButton.styleFrom(
                              foregroundColor:
                                  lightGold,
                              side:
                                  const BorderSide(
                                color: gold,
                              ),
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                vertical: 11.0,
                              ),
                            ),
                            child: const Text(
                              'VIEW',
                              style: TextStyle(
                                fontSize: 10.0,
                                fontWeight:
                                    FontWeight.w700,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8.0),

                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                product.stock > 0
                                    ? () => _addToBag(
                                          product,
                                        )
                                    : null,
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor: gold,
                              foregroundColor:
                                  Colors.black,
                              disabledBackgroundColor:
                                  Colors.white12,
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                vertical: 11.0,
                              ),
                            ),
                            child: Text(
                              product.stock > 0
                                  ? 'ADD TO BAG'
                                  : 'SOLD OUT',
                              style:
                                  const TextStyle(
                                fontSize: 9.0,
                                fontWeight:
                                    FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================================
  // PRODUCT IMAGE
  // ==========================================================================

  Widget _buildProductImage(
    ShanoAiProduct product,
  ) {
    if (product.imageUrl.trim().isEmpty) {
      return _buildImageFallback();
    }

    return ClipRRect(
      borderRadius:
          const BorderRadius.vertical(
        top: Radius.circular(13.0),
      ),
      child: Image.network(
        product.imageUrl,
        width: double.infinity,
        height: 150.0,
        fit: BoxFit.cover,
        errorBuilder: (
          BuildContext context,
          Object error,
          StackTrace? stackTrace,
        ) {
          return _buildImageFallback();
        },
      ),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      width: double.infinity,
      height: 150.0,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF202020),
            Color(0xFF080808),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.local_florist_outlined,
          color: gold,
          size: 38.0,
        ),
      ),
    );
  }

  // ==========================================================================
  // TYPING INDICATOR
  // ==========================================================================

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 13.0,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 13.0,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF181818),
          borderRadius:
              BorderRadius.circular(15.0),
          border: Border.all(
            color: border,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TypingDot(),
            SizedBox(width: 4.0),
            _TypingDot(),
            SizedBox(width: 4.0),
            _TypingDot(),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // SUGGESTIONS
  // ==========================================================================

  Widget _buildSuggestions() {
    const List<String> suggestions = [
      'Best for daily wear',
      'Something for a wedding',
      'Fresh fragrance',
      'Strong fragrance',
      'Tell me about CHAMPIONS',
    ];

    return SizedBox(
      height: 47.0,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 13.0,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (
          BuildContext context,
          int index,
        ) {
          return const SizedBox(width: 7.0);
        },
        itemBuilder: (
          BuildContext context,
          int index,
        ) {
          return Center(
            child: InkWell(
              onTap: () {
                _sendMessage(
                  suggestions[index],
                );
              },
              borderRadius:
                  BorderRadius.circular(20.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.035,
                  ),
                  borderRadius:
                      BorderRadius.circular(20.0),
                  border: Border.all(
                    color: border,
                  ),
                ),
                child: Text(
                  suggestions[index],
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 9.0,
                    letterSpacing: 0.25,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================================================
  // INPUT
  // ==========================================================================

  Widget _buildInput() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          12.0,
          9.0,
          12.0,
          12.0,
        ),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: border,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                textInputAction:
                    TextInputAction.send,
                onSubmitted: _sendMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.0,
                ),
                decoration: InputDecoration(
                  hintText:
                      'Ask about our fragrances...',
                  hintStyle: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12.0,
                  ),
                  filled: true,
                  fillColor: inputBackground,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(13.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 12.0,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8.0),

            InkWell(
              onTap: _isLoading
                  ? null
                  : () {
                      _sendMessage(
                        _controller.text,
                      );
                    },
              borderRadius:
                  BorderRadius.circular(13.0),
              child: Container(
                width: 46.0,
                height: 46.0,
                decoration: BoxDecoration(
                  color: _isLoading
                      ? Colors.white12
                      : gold,
                  borderRadius:
                      BorderRadius.circular(13.0),
                ),
                child: Icon(
                  Icons.arrow_upward,
                  color: _isLoading
                      ? Colors.white38
                      : Colors.black,
                  size: 20.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final Size screenSize =
        MediaQuery.sizeOf(context);

    _initializePosition(screenSize);
    _scheduleViewportClamp(screenSize);

    return Positioned(
      left: _left,
      top: _top,
      child: _isOpen
          ? _buildChatPanel(context)
          : _buildFloatingButton(screenSize),
    );
  }
}

// =============================================================================
// CHAT MESSAGE
// =============================================================================

class _ChatMessage {
  final String text;
  final bool isUser;
  final List<ShanoAiProduct> recommendations;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.recommendations = const [],
  });
}

// =============================================================================
// TYPING DOT
// =============================================================================

class _TypingDot extends StatelessWidget {
  const _TypingDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5.0,
      height: 5.0,
      decoration: const BoxDecoration(
        color: Color(0xFFD6B36A),
        shape: BoxShape.circle,
      ),
    );
  }
}