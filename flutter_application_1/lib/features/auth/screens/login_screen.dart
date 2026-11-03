import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/theme_mode_button.dart';
import '../data/auth_repository.dart';

enum LoginRole { farmer, collector, manager, admin }

class LoginScreen extends StatefulWidget {
  final String? initialPhone;
  final LoginRole? initialRole;

  const LoginScreen({super.key, this.initialPhone, this.initialRole});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _identifierController;
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  String? _error;
  LoginRole _selectedRole = LoginRole.farmer;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole ?? LoginRole.farmer;
    if (widget.initialPhone != null) {
      _identifierController = TextEditingController(text: widget.initialPhone);
      _passwordController.text = '';
    } else {
      switch (_selectedRole) {
        case LoginRole.farmer:
          _identifierController = TextEditingController(text: '9876543210');
          _passwordController.text = '123456';
          break;
        case LoginRole.collector:
          _identifierController = TextEditingController(text: '123456');
          _passwordController.text = '123456';
          break;
        case LoginRole.manager:
          _identifierController = TextEditingController(text: 'centermanager');
          _passwordController.text = '123456';
          break;
        case LoginRole.admin:
          _identifierController = TextEditingController(text: 'dairyadmin');
          _passwordController.text = 'admin123';
          break;
      }
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _selectRole(LoginRole role) {
    setState(() {
      _selectedRole = role;
      _error = null;
      switch (role) {
        case LoginRole.farmer:
          _identifierController.text = '9876543210';
          _passwordController.text = '123456';
          break;
        case LoginRole.collector:
          _identifierController.text = '123456';
          _passwordController.text = '123456';
          break;
        case LoginRole.manager:
          _identifierController.text = 'centermanager';
          _passwordController.text = '123456';
          break;
        case LoginRole.admin:
          _identifierController.text = 'dairyadmin';
          _passwordController.text = 'admin123';
          break;
      }
    });
  }

  String get _subtitleText {
    switch (_selectedRole) {
      case LoginRole.farmer:
        return 'Log in to track your milk records, rates & payments';
      case LoginRole.collector:
        return 'Log in to collect milk, record entries & view farmers';
      case LoginRole.manager:
        return 'Log in to manage your center collection, dispatches & quality';
      case LoginRole.admin:
        return 'Log in to manage enterprise financials, graphs & fleet';
    }
  }

  String get _identifierLabel {
    switch (_selectedRole) {
      case LoginRole.farmer:
        return 'Farmer Mobile Number';
      case LoginRole.collector:
        return 'Collector ID / Mobile';
      case LoginRole.manager:
        return 'Center Manager Username / Phone';
      case LoginRole.admin:
        return 'Admin Username / Mobile';
    }
  }

  String get _identifierHint {
    switch (_selectedRole) {
      case LoginRole.farmer:
        return '10-digit mobile (e.g. 9876543210)';
      case LoginRole.collector:
        return 'ID or mobile (e.g. 123456)';
      case LoginRole.manager:
        return 'Username (centermanager) or phone';
      case LoginRole.admin:
        return 'Username (dairyadmin) or mobile';
    }
  }

  IconData get _identifierIcon {
    switch (_selectedRole) {
      case LoginRole.farmer:
        return Icons.phone_android_outlined;
      case LoginRole.collector:
        return Icons.badge_outlined;
      case LoginRole.manager:
        return Icons.storefront_outlined;
      case LoginRole.admin:
        return Icons.admin_panel_settings_outlined;
    }
  }

  String get _loginButtonText {
    switch (_selectedRole) {
      case LoginRole.farmer:
        return 'Login as Farmer';
      case LoginRole.collector:
        return 'Login as Collector';
      case LoginRole.manager:
        return 'Login as Center Manager';
      case LoginRole.admin:
        return 'Login as Enterprise Admin';
    }
  }

  Gradient get _buttonGradient {
    switch (_selectedRole) {
      case LoginRole.farmer:
        return AppTheme.greenGradient;
      case LoginRole.collector:
        return const LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case LoginRole.manager:
        return const LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case LoginRole.admin:
        return const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color get _buttonShadowColor {
    switch (_selectedRole) {
      case LoginRole.farmer:
        return AppTheme.brandGreen;
      case LoginRole.collector:
        return const Color(0xFF0284C7);
      case LoginRole.manager:
        return const Color(0xFF0D9488);
      case LoginRole.admin:
        return const Color(0xFF1E293B);
    }
  }

  Widget _buildRoleTab(LoginRole role, String title, IconData icon) {
    final isSelected = _selectedRole == role;
    final primaryColor = role == LoginRole.farmer
        ? AppTheme.brandGreen
        : role == LoginRole.collector
            ? const Color(0xFF0284C7)
            : role == LoginRole.manager
                ? const Color(0xFF0D9488)
                : const Color(0xFF1E293B);

    return Expanded(
      child: GestureDetector(
        onTap: () => _selectRole(role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.cardSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? primaryColor : AppTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? primaryColor : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final error = await AuthRepository.instance.login(
      identifier: _identifierController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _loading = false;
        _error = error;
      });
      return;
    }

    // 2FA Security Gate: Admin credentials trigger 2FA verification screen
    final pending2FA = AuthRepository.instance.pending2FAUser;
    if (pending2FA != null) {
      if (_selectedRole != LoginRole.admin) {
        AuthRepository.instance.logout();
        setState(() {
          _loading = false;
          _error = 'This account is an Enterprise Admin account. Please select the Admin role tab.';
        });
        return;
      }
      setState(() {
        _loading = false;
        _error = null;
      });
      context.go(AppRoutes.admin2FA);
      return;
    }

    final user = AuthRepository.instance.currentUser;
    if (user == null) {
      setState(() {
        _loading = false;
        _error = 'Unable to log in. Please try again.';
      });
      return;
    }

    // Role safety check: ensure chosen tab matches the account role
    if (_selectedRole == LoginRole.farmer && user.role != UserRole.farmer) {
      AuthRepository.instance.logout();
      setState(() {
        _loading = false;
        _error = 'This account is not a Farmer account. Please select the matching role tab.';
      });
      return;
    } else if (_selectedRole == LoginRole.collector && user.role != UserRole.collector) {
      AuthRepository.instance.logout();
      setState(() {
        _loading = false;
        _error = 'This account is not a Collector account. Please select the matching role tab.';
      });
      return;
    } else if (_selectedRole == LoginRole.manager && user.role != UserRole.manager && user.role != UserRole.admin) {
      AuthRepository.instance.logout();
      setState(() {
        _loading = false;
        _error = 'This account is not a Center Manager account. Please select the matching role tab.';
      });
      return;
    } else if (_selectedRole == LoginRole.admin && user.role != UserRole.admin) {
      AuthRepository.instance.logout();
      setState(() {
        _loading = false;
        _error = 'This account is not an Enterprise Admin account. Please select the matching role tab.';
      });
      return;
    }

    setState(() {
      _loading = false;
      _error = null;
    });

    if (user.role == UserRole.admin) {
      if (!AuthRepository.instance.isAdmin2FAVerified) {
        AuthRepository.instance.prepareAdmin2FA(user);
        context.go(AppRoutes.admin2FA);
      } else {
        context.go(AppRoutes.adminDashboard);
      }
    } else if (user.role == UserRole.manager) {
      context.go(AppRoutes.managerDashboard);
    } else if (user.role == UserRole.collector) {
      context.go(AppRoutes.collectorDashboard);
    } else {
      context.go(AppRoutes.farmerDashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              // Top Bar with Theme Toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.topRight,
                  child: const ThemeModeButton(showLabel: true),
                ),
              ),
              const SizedBox(height: 4),
              // Logo & Brand Header
              const Center(child: AppLogo(size: 64)),
              const SizedBox(height: 6),
              Text(
                'Farm2Factory',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.isDark ? AppTheme.brandGreenLight : AppTheme.brandGreenDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'From farm to factory, every litre counted',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),

              // Cute Cartoon Cow Mascot Hero Illustration
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF267332).withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/cow_mascot.png',
                    height: 135,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // "Welcome Back" Header
              Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _subtitleText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // 4-Role Segment Switcher: Farmer, Collector, Manager, Admin
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.creamSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.creamBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildRoleTab(LoginRole.farmer, 'Farmer', Icons.agriculture),
                      const SizedBox(width: 3),
                      _buildRoleTab(LoginRole.collector, 'Collector', Icons.badge_outlined),
                      const SizedBox(width: 3),
                      _buildRoleTab(LoginRole.manager, 'Manager', Icons.storefront_outlined),
                      const SizedBox(width: 3),
                      _buildRoleTab(LoginRole.admin, 'Admin', Icons.admin_panel_settings_outlined),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Form Fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Identifier Field (dynamic based on role)
                      TextFormField(
                        controller: _identifierController,
                        keyboardType: _selectedRole == LoginRole.admin
                            ? TextInputType.text
                            : TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: _identifierLabel,
                          hintText: _identifierHint,
                          prefixIcon: Icon(
                            _identifierIcon,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? '$_identifierLabel is required'
                            : null,
                      ),
                      const SizedBox(height: 14),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter password',
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey.shade500,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() =>
                                  _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),
                        validator: (v) =>
                            Validators.required(v, field: 'Password'),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 20),

                      // Login Gradient Action Button with Circular Icon
                      Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: _buttonGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _buttonShadowColor.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _loading ? null : _login,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                              child: Row(
                                children: [
                                  const SizedBox(width: 32),
                                  Expanded(
                                    child: Center(
                                      child: _loading
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                _loginButtonText,
                                                maxLines: 1,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Register link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'New here? ',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                context.push(AppRoutes.register),
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                color: AppTheme.brandGreen,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // "OR" Divider
                      Row(
                        children: [
                          Expanded(
                              child: Divider(color: Colors.grey.shade300)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                              child: Divider(color: Colors.grey.shade300)),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Demo Login Pills for the 3 distinct roles
                      Text(
                        'Demo Login',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _DemoPill(
                              icon: Icons.agriculture,
                              color: AppTheme.brandGreen,
                              title: '9876543210',
                              subtitle: '( Farmer )',
                              onTap: () => _selectRole(LoginRole.farmer),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _DemoPill(
                              icon: Icons.local_shipping_outlined,
                              color: const Color(0xFF0284C7),
                              title: '123456',
                              subtitle: '( Collector )',
                              onTap: () => _selectRole(LoginRole.collector),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _DemoPill(
                              icon: Icons.business_outlined,
                              color: const Color(0xFF0F766E),
                              title: 'dairyadmin',
                              subtitle: '( Admin )',
                              onTap: () => _selectRole(LoginRole.admin),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

                  const SizedBox(height: 24),

                  // Bottom Illustration: Cow & Milk Can
                  SizedBox(
                    width: double.infinity,
                    height: 100,
                    child: Image.asset(
                      'assets/images/cow_footer.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}

class _DemoPill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DemoPill({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          border: Border.all(color: AppTheme.creamBorder),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 3),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 8.5,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
