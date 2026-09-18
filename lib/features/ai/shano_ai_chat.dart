
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
  static const Color gold = Color(0xFFD6B36A);
  static const Color lightGold = Color(0xFFE8CC91);
  static const Color background = Color(0xFF080808);
  static const Color panel = Color(0xFF111111);
  static const Color inputBackground = Color(0xFF181818);
  static const Color border = Color(0xFF292929);

  final TextEditingController _controller =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  final List<_ChatMessage> _messages = [];

  bool _isOpen = false;
  bool _isLoading = false;

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

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openChat() {
    setState(() {
      _isOpen = true;
    });

    _scrollToBottom();
  }

  void _closeChat() {
    FocusScope.of(context).unfocus();

    setState(() {
      _isOpen = false;
    });
  }

  Future<void> _sendMessage(String value) async {
    final message = value.trim();

    if (message.isEmpty || _isLoading) {
      return;
    }

    _controller.clear();

    final history = _messages
        .map(
          (item) => <String, String>{
            'role': item.isUser ? 'user' : 'assistant',
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
      final result = await ShanoAiService.instance.chat(
        message: message,
        history: history,
      );

      if (!mounted) return;

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
    } catch (error) {
      if (!mounted) return;

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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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

  String _formatPrice(ShanoAiProduct product) {
    final price = product.price;

    if (price == price.roundToDouble()) {
      return '${product.currency} ${price.toStringAsFixed(0)}';
    }

    return '${product.currency} ${price.toStringAsFixed(2)}';
  }

  Future<void> _addToBag(ShanoAiProduct product) async {
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
      if (!mounted) return;

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
      if (!mounted) return;

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

  void _viewProduct(ShanoAiProduct product) {
    _closeChat();

    context.push(
      '/product/${Uri.encodeComponent(product.slug)}',
    );
  }

  Widget _buildFloatingButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openChat,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: gold.withOpacity(0.75),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                color: gold,
                size: 19,
              ),
              SizedBox(width: 9),
              Text(
                'ASK SHANO AI',
                style: TextStyle(
                  color: lightGold,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatPanel(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final bool isMobile = screenSize.width < 600;

    final double width = isMobile
        ? screenSize.width - 24
        : 420;

    final double height = isMobile
        ? screenSize.height - 110
        : 650;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: gold.withOpacity(0.30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.60),
              blurRadius: 35,
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
                  15,
                  17,
                  15,
                  10,
                ),
                itemCount:
                    _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
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
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        17,
        16,
        9,
        15,
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: gold.withOpacity(0.45),
              ),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: gold,
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SHANO AI',
                  style: TextStyle(
                    color: lightGold,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.7,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'YOUR FRAGRANCE ASSISTANT',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 9,
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
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(_ChatMessage message) {
    final bool isUser = message.isUser;

    return Align(
      alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 335,
        ),
        margin: const EdgeInsets.only(
          bottom: 13,
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: isUser ? gold : const Color(0xFF181818),
                borderRadius: BorderRadius.circular(15),
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
                      : Colors.white.withOpacity(0.90),
                  fontSize: 13,
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

  Widget _buildRecommendation(
    ShanoAiProduct product,
  ) {
    return Container(
      width: 320,
      margin: const EdgeInsets.only(
        top: 9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: gold.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImage(product),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              13,
              12,
              13,
              13,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    color: lightGold,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  product.category,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 9,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  _formatPrice(product),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _viewProduct(product);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: lightGold,
                          side: const BorderSide(
                            color: gold,
                          ),
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 11,
                          ),
                        ),
                        child: const Text(
                          'VIEW',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: product.stock > 0
                            ? () {
                                _addToBag(product);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gold,
                          foregroundColor: Colors.black,
                          disabledBackgroundColor:
                              Colors.white12,
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 11,
                          ),
                        ),
                        child: Text(
                          product.stock > 0
                              ? 'ADD TO BAG'
                              : 'SOLD OUT',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
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
  }

  Widget _buildProductImage(
    ShanoAiProduct product,
  ) {
    if (product.imageUrl.trim().isEmpty) {
      return _buildImageFallback();
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(13),
      ),
      child: Image.network(
        product.imageUrl,
        width: double.infinity,
        height: 150,
        fit: BoxFit.cover,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return _buildImageFallback();
        },
      ),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      width: double.infinity,
      height: 150,
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
          size: 38,
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 13,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF181818),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: border,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TypingDot(),
            SizedBox(width: 4),
            _TypingDot(),
            SizedBox(width: 4),
            _TypingDot(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    const suggestions = [
      'Best for daily wear',
      'Something for a wedding',
      'Fresh fragrance',
      'Strong fragrance',
      'Tell me about CHAMPIONS',
    ];

    return SizedBox(
      height: 47,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (_, __) {
          return const SizedBox(width: 7);
        },
        itemBuilder: (context, index) {
          return Center(
            child: InkWell(
              onTap: () {
                _sendMessage(
                  suggestions[index],
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.035),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: border,
                  ),
                ),
                child: Text(
                  suggestions[index],
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 9,
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

  Widget _buildInput() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          12,
          9,
          12,
          12,
        ),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: border,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: _sendMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText:
                      'Ask about our fragrances...',
                  hintStyle: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: inputBackground,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(13),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: _isLoading
                  ? null
                  : () {
                      _sendMessage(
                        _controller.text,
                      );
                    },
              borderRadius: BorderRadius.circular(13),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color:
                      _isLoading ? Colors.white12 : gold,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.arrow_upward,
                  color:
                      _isLoading ? Colors.white38 : Colors.black,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      bottom: 20,
      child: _isOpen
          ? _buildChatPanel(context)
          : _buildFloatingButton(),
    );
  }
}

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

class _TypingDot extends StatelessWidget {
  const _TypingDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: const BoxDecoration(
        color: Color(0xFFD6B36A),
        shape: BoxShape.circle,
      ),
    );
  }
}
