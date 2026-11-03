import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/theme_mode_button.dart';
import '../data/auth_repository.dart';

class Admin2FAScreen extends StatefulWidget {
  final String? targetRoute;

  const Admin2FAScreen({super.key, this.targetRoute});

  @override
  State<Admin2FAScreen> createState() => _Admin2FAScreenState();
}

class _Admin2FAScreenState extends State<Admin2FAScreen> {
  static const int _otpLength = 6;
  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  bool _loading = false;
  String? _error;
  int _secondsRemaining = 45;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 45);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _enteredOtp =>
      _controllers.map((c) => c.text.trim()).join();

  void _autoFillDemoCode() {
    final demoCode = AuthRepository.instance.current2FAOtp;
    for (int i = 0; i < _otpLength && i < demoCode.length; i++) {
      _controllers[i].text = demoCode[i];
    }
    setState(() => _error = null);
    if (_focusNodes.isNotEmpty) {
      _focusNodes.last.requestFocus();
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _enteredOtp;
    if (otp.length < _otpLength) {
      setState(() => _error = 'Please enter all 6 digits of the authentication code.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final success = AuthRepository.instance.verifyAdmin2FA(otp);

    if (!mounted) return;

    if (!success) {
      setState(() {
        _loading = false;
        _error = 'Invalid 2FA code. Please enter the code dispatched to your registered credentials.';
      });
      return;
    }

    setState(() => _loading = false);

    // Route to target admin screen or default admin dashboard
    final destination = (widget.targetRoute != null &&
            widget.targetRoute!.isNotEmpty &&
            widget.targetRoute != AppRoutes.admin2FA)
        ? widget.targetRoute!
        : AppRoutes.adminDashboard;

    context.go(destination);
  }

  void _resendCode() {
    if (_secondsRemaining > 0) return;
    AuthRepository.instance.resendAdmin2FAOtp();
    _startCountdown();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('A fresh 2FA code has been dispatched to your Admin Mobile and Email.'),
        backgroundColor: AppTheme.brandGreen,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // If pasted a multi-digit string
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < _otpLength && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      final nextFocus = digits.length < _otpLength ? digits.length : _otpLength - 1;
      _focusNodes[nextFocus].requestFocus();
      setState(() => _error = null);
      if (digits.length == _otpLength) {
        _verifyOtp();
      }
      return;
    }

    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyOtp();
      }
    }
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        final screenWidth = MediaQuery.of(context).size.width;
        final user = AuthRepository.instance.pending2FAUser ??
            AuthRepository.instance.currentUser;
        final registeredMobile = user?.phone.isNotEmpty == true
            ? user!.phone
            : '9999999999';
        final registeredEmail = user?.email.isNotEmpty == true
            ? user!.email
            : 'admin.controller@farm2factory.in';

        // Masked versions for security aesthetic
        final maskedMobile = registeredMobile.length >= 10
            ? '+91 ${registeredMobile.substring(0, 5)} •••••'
            : registeredMobile;
        final emailParts = registeredEmail.split('@');
        final maskedEmail = emailParts.length == 2 && emailParts[0].length >= 3
            ? '${emailParts[0].substring(0, 2)}***@${emailParts[1]}'
            : registeredEmail;

        return Scaffold(
          backgroundColor: AppTheme.scaffoldBg,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth < 400 ? 12 : 20,
                  vertical: 20,
                ),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth < 400 ? 16 : 28,
                    vertical: screenWidth < 400 ? 20 : 28,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.creamBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App Brand & Shield Icon & Theme Switcher
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const AppLogo(size: 32),
                          const SizedBox(width: 8),
                          Text(
                            'Farm2Factory',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.isDark ? AppTheme.brandGreenLight : AppTheme.brandGreenDark,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      const ThemeModeButton(),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Shield Icon container
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.isDark
                          ? const Color(0xFF1E3A8A).withOpacity(0.35)
                          : const Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.isDark
                            ? const Color(0xFF3B82F6).withOpacity(0.4)
                            : const Color(0xFF3B82F6).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.security,
                      size: 32,
                      color: AppTheme.isDark
                          ? const Color(0xFF60A5FA)
                          : const Color(0xFF1D4ED8),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title & Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.badgeAmberBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.badgeAmberBorder),
                    ),
                    child: Text(
                      'RESTRICTED ENTERPRISE PANEL',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.badgeAmberText,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Admin 2-Factor Authentication',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This panel contains financial payouts, multi-center analytics, audit reports, and fleet telemetry. Verify your identity to unlock.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Admin Credentials Verification Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardMint,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.brandGreen.withOpacity(0.18),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.verified_user,
                              size: 16,
                              color: AppTheme.isDark ? AppTheme.brandGreenLight : AppTheme.brandGreen,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Authorized Admin Credentials',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.isDark ? AppTheme.brandGreenLight : AppTheme.brandGreenDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildCredentialRow(
                          icon: Icons.phone_android,
                          label: 'Registered Mobile',
                          value: maskedMobile,
                        ),
                        const SizedBox(height: 6),
                        _buildCredentialRow(
                          icon: Icons.alternate_email,
                          label: 'Official Email',
                          value: maskedEmail,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // 6 Digit OTP Input Boxes (Fluid Responsive Layout)
                  Text(
                    'Enter 6-Digit Verification Code',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(_otpLength, (index) {
                      return Expanded(
                        child: Container(
                          height: 52,
                          margin: const EdgeInsets.symmetric(horizontal: 2.5),
                          child: RawKeyboardListener(
                            focusNode: FocusNode(),
                            onKey: (event) {
                              if (event is RawKeyDownEvent &&
                                  event.logicalKey ==
                                      LogicalKeyboardKey.backspace &&
                                  _controllers[index].text.isEmpty &&
                                  index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }
                            },
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                counterText: '',
                                contentPadding: EdgeInsets.zero,
                                filled: true,
                                fillColor: _focusNodes[index].hasFocus
                                    ? AppTheme.cardSurface
                                    : AppTheme.creamSurface,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: AppTheme.creamBorder,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: AppTheme.isDark ? AppTheme.brandGreenLight : AppTheme.brandGreen,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (val) => _onDigitChanged(index, val),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  // Error Display
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, size: 16, color: Color(0xFFDC2626)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFFDC2626),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),

                  // Demo Helper Code Tap (for rapid evaluation)
                  InkWell(
                    onTap: _autoFillDemoCode,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppTheme.creamSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.creamBorder),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.key, size: 15, color: AppTheme.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              'Demo 2FA Code: ${AuthRepository.instance.current2FAOtp}',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '(Tap to auto-fill)',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.isDark ? const Color(0xFF10B981) : const Color(0xFF0F5132),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.lock_open, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Verify & Unlock Admin Console',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Resend Code & Cancel Options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: TextButton.icon(
                          icon: const Icon(Icons.arrow_back, size: 15),
                          label: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('Back to Login'),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.textSecondary,
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                          onPressed: () {
                            AuthRepository.instance.logout();
                            context.go(AppRoutes.login);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: TextButton.icon(
                          icon: Icon(
                            Icons.refresh,
                            size: 15,
                            color: _secondsRemaining == 0
                                ? AppTheme.accentGreen
                                : AppTheme.textMuted,
                          ),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _secondsRemaining > 0
                                  ? 'Resend in ${_secondsRemaining}s'
                                  : 'Resend Code',
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: _secondsRemaining == 0
                                ? AppTheme.accentGreen
                                : AppTheme.textMuted,
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: _secondsRemaining == 0 ? _resendCode : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildCredentialRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: AppTheme.isDark ? AppTheme.brandGreenLight : AppTheme.brandGreenDark,
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 11.5,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11.5,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
