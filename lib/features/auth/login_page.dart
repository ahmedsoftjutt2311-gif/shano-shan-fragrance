import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  bool _isRegisterMode = false;
  bool _loading = false;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _errorMessage;
  String? _successMessage;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFF080808);
  static const Color surface = Color(0xFF111111);

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // SWITCH LOGIN / REGISTER
  // ============================================================

  void _switchMode(bool register) {
    if (_loading) return;

    setState(() {
      _isRegisterMode = register;
      _errorMessage = null;
      _successMessage = null;

      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      _showError('Please enter your email address.');
      return;
    }

    if (!_isValidEmail(email)) {
      _showError('Please enter a valid email address.');
      return;
    }

    if (password.isEmpty) {
      _showError('Please enter your password.');
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await AuthService.instance.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      context.go('/account');
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            AuthService.instance.cleanError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ============================================================
  // REGISTER
  // ============================================================

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword =
        _confirmPasswordController.text;

    if (name.isEmpty) {
      _showError('Please enter your name.');
      return;
    }

    if (name.length < 2) {
      _showError('Please enter a valid name.');
      return;
    }

    if (email.isEmpty) {
      _showError('Please enter your email address.');
      return;
    }

    if (!_isValidEmail(email)) {
      _showError('Please enter a valid email address.');
      return;
    }

    if (password.isEmpty) {
      _showError('Please create a password.');
      return;
    }

    if (password.length < 6) {
      _showError(
        'Password must be at least 6 characters.',
      );
      return;
    }

    if (confirmPassword.isEmpty) {
      _showError(
        'Please confirm your password.',
      );
      return;
    }

    if (password != confirmPassword) {
      _showError(
        'Passwords do not match.',
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await AuthService.instance.register(
        name: name,
        email: email,
        password: password,
      );

      if (!mounted) return;

      setState(() {
        _isRegisterMode = false;

        _passwordController.clear();
        _confirmPasswordController.clear();

        _errorMessage = null;

        _successMessage =
            'Account created successfully. Please sign in.';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            AuthService.instance.cleanError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _successMessage = null;
    });
  }

  // ============================================================
  // EMAIL VALIDATION
  // ============================================================

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);
  }

  // ============================================================
  // INPUT FIELD
  // ============================================================

  Widget _input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    VoidCallback? onVisibilityTap,
  }) {
    return TextField(
      controller: controller,
      enabled: !_loading,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      cursorColor: gold,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white38,
          fontSize: 13,
        ),
        floatingLabelStyle: const TextStyle(
          color: gold,
          fontSize: 13,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.white38,
          size: 19,
        ),
        suffixIcon: onVisibilityTap == null
            ? null
            : IconButton(
                onPressed: onVisibilityTap,
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white38,
                  size: 19,
                ),
              ),
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            color: Color(0x1AFFFFFF),
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            color: Color(0x1AFFFFFF),
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            color: gold,
            width: 1,
          ),
        ),
        disabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            color: Color(0x0DFFFFFF),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  Widget _messageBox() {
    if (_errorMessage == null &&
        _successMessage == null) {
      return const SizedBox.shrink();
    }

    final bool success = _successMessage != null;

    final String message =
        success ? _successMessage! : _errorMessage!;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: success
            ? gold.withValues(alpha: 0.07)
            : Colors.red.withValues(alpha: 0.07),
        border: Border.all(
          color: success
              ? gold.withValues(alpha: 0.25)
              : Colors.red.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            success
                ? Icons.check_circle_outline
                : Icons.error_outline,
            color: success ? gold : Colors.redAccent,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: success
                    ? gold
                    : Colors.redAccent,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MODE TAB
  // ============================================================

  Widget _modeTab({
    required String title,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: _loading ? null : onTap,
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 180),
          height: 46,
          alignment: Alignment.center,
          color: active ? gold : Colors.transparent,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active
                  ? Colors.black
                  : Colors.white38,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool register = _isRegisterMode;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 36,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 430,
              ),
              child: Column(
                children: [
                  // ==================================================
                  // BACK BUTTON
                  // ==================================================

                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: _loading
                          ? null
                          : () => context.go('/'),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white54,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // BRAND
                  // ==================================================

                  GestureDetector(
                    onTap: _loading
                        ? null
                        : () => context.go('/'),
                    child: const Column(
                      children: [
                        Text(
                          'SHANO SHAN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: gold,
                            fontSize: 25,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 6,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'FRAGRANCE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 8,
                            letterSpacing: 5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ==================================================
                  // TITLE
                  // ==================================================

                  Text(
                    register
                        ? 'CREATE ACCOUNT'
                        : 'WELCOME BACK',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: 9),

                  Text(
                    register
                        ? 'Join the world of SHANO SHAN.'
                        : 'Sign in to continue your journey.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // LOGIN / REGISTER SWITCH
                  // ==================================================

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                    child: Row(
                      children: [
                        _modeTab(
                          title: 'SIGN IN',
                          active: !register,
                          onTap: () =>
                              _switchMode(false),
                        ),
                        _modeTab(
                          title: 'CREATE ACCOUNT',
                          active: register,
                          onTap: () =>
                              _switchMode(true),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // MESSAGE
                  // ==================================================

                  _messageBox(),

                  // ==================================================
                  // NAME
                  // ==================================================

                  if (register) ...[
                    _input(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      textInputAction:
                          TextInputAction.next,
                    ),
                    const SizedBox(height: 13),
                  ],

                  // ==================================================
                  // EMAIL
                  // ==================================================

                  _input(
                    controller: _emailController,
                    label: 'Email Address',
                    icon: Icons.mail_outline,
                    keyboardType:
                        TextInputType.emailAddress,
                    textInputAction:
                        TextInputAction.next,
                  ),

                  const SizedBox(height: 13),

                  // ==================================================
                  // PASSWORD
                  // ==================================================

                  _input(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    textInputAction: register
                        ? TextInputAction.next
                        : TextInputAction.done,
                    onVisibilityTap: () {
                      setState(() {
                        _obscurePassword =
                            !_obscurePassword;
                      });
                    },
                  ),

                  // ==================================================
                  // CONFIRM PASSWORD
                  // ==================================================

                  if (register) ...[
                    const SizedBox(height: 13),
                    _input(
                      controller:
                          _confirmPasswordController,
                      label: 'Confirm Password',
                      icon: Icons.lock_outline,
                      obscureText:
                          _obscureConfirmPassword,
                      textInputAction:
                          TextInputAction.done,
                      onVisibilityTap: () {
                        setState(() {
                          _obscureConfirmPassword =
                              !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ==================================================
                  // MAIN BUTTON
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading
                          ? null
                          : register
                              ? _register
                              : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gold,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor:
                            gold.withValues(alpha: 0.45),
                        elevation: 0,
                        shape:
                            const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.zero,
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<
                                        Color>(
                                  Colors.black,
                                ),
                              ),
                            )
                          : Text(
                              register
                                  ? 'CREATE ACCOUNT'
                                  : 'SIGN IN',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight:
                                    FontWeight.w600,
                                letterSpacing: 2,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ==================================================
                  // SWITCH LINK
                  // ==================================================

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        register
                            ? 'Already have an account?'
                            : 'New to SHANO SHAN?',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                      TextButton(
                        onPressed: _loading
                            ? null
                            : () => _switchMode(
                                  !register,
                                ),
                        style: TextButton.styleFrom(
                          foregroundColor: gold,
                          padding:
                              const EdgeInsets.only(
                            left: 5,
                          ),
                        ),
                        child: Text(
                          register
                              ? 'Sign In'
                              : 'Create Account',
                          style: const TextStyle(
                            color: gold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // BRAND LINE
                  // ==================================================

                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.white
                              .withValues(alpha: 0.08),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        child: Text(
                          'SHANO SHAN',
                          style: TextStyle(
                            color: Colors.white
                                .withValues(alpha: 0.18),
                            fontSize: 8,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.white
                              .withValues(alpha: 0.08),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'EVERY FRAGRANCE HAS A STORY.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white24,
                      fontSize: 8,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}