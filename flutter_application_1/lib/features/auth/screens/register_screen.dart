import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/brand_footer.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/password_field.dart';
import '../data/auth_repository.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _centerController = TextEditingController();
  final _locationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  UserRole _selectedRole = UserRole.farmer;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _centerController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _selectRole(UserRole role) {
    setState(() {
      _selectedRole = role;
      _error = null;
      // Provide helpful contextual default placeholders
      switch (role) {
        case UserRole.farmer:
          _centerController.text = 'Central Valley';
          break;
        case UserRole.collector:
          _centerController.text = 'Central Valley Collection Center';
          break;
        case UserRole.admin:
          _centerController.text = 'Jaipur Cooperative Dairy Plant';
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _centerController.text = 'Central Valley';
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final phoneOrId = _phoneController.text.trim();
    String? error;
    LoginRole matchingLoginRole;

    switch (_selectedRole) {
      case UserRole.farmer:
        matchingLoginRole = LoginRole.farmer;
        error = await AuthRepository.instance.registerFarmer(
          name: _nameController.text.trim(),
          phone: phoneOrId,
          password: _passwordController.text,
        );
        break;

      case UserRole.collector:
        matchingLoginRole = LoginRole.collector;
        error = await AuthRepository.instance.registerCollector(
          name: _nameController.text.trim(),
          phone: phoneOrId,
          password: _passwordController.text,
          center: _centerController.text.trim().isNotEmpty
              ? _centerController.text.trim()
              : 'Central Valley Collection Center',
          location: _locationController.text.trim().isNotEmpty
              ? _locationController.text.trim()
              : null,
        );
        break;

      case UserRole.admin:
        matchingLoginRole = LoginRole.admin;
        error = await AuthRepository.instance.registerAdmin(
          name: _nameController.text.trim(),
          identifier: phoneOrId,
          password: _passwordController.text,
          plantName: _centerController.text.trim().isNotEmpty
              ? _centerController.text.trim()
              : 'Jaipur Cooperative Dairy Plant',
          phone: phoneOrId.length == 10 ? phoneOrId : null,
        );
        break;
    }

    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = error;
    });
    if (error != null) return;

    final roleLabel = _selectedRole == UserRole.farmer
        ? 'Farmer'
        : _selectedRole == UserRole.collector
            ? 'Collector'
            : 'Dairy Admin';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$roleLabel account created successfully! Please log in.'),
        backgroundColor: _selectedRole == UserRole.farmer
            ? AppTheme.brandGreen
            : _selectedRole == UserRole.collector
                ? const Color(0xFF0284C7)
                : const Color(0xFF0F766E),
      ),
    );

    // Redirect to login with the registered phone/id and role pre-selected
    context.go(
      AppRoutes.login,
      extra: {
        'phone': phoneOrId,
        'role': matchingLoginRole,
      },
    );
  }

  Color get _primaryRoleColor {
    switch (_selectedRole) {
      case UserRole.farmer:
        return AppTheme.brandGreen;
      case UserRole.collector:
        return const Color(0xFF0284C7);
      case UserRole.admin:
        return const Color(0xFF0F766E);
    }
  }

  Gradient get _buttonGradient {
    switch (_selectedRole) {
      case UserRole.farmer:
        return AppTheme.greenGradient;
      case UserRole.collector:
        return const LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case UserRole.admin:
        return const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF115E59)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color get _shadowColor {
    switch (_selectedRole) {
      case UserRole.farmer:
        return AppTheme.brandGreen;
      case UserRole.collector:
        return const Color(0xFF0284C7);
      case UserRole.admin:
        return const Color(0xFF0F766E);
    }
  }

  String get _buttonText {
    switch (_selectedRole) {
      case UserRole.farmer:
        return 'Create Farmer Account';
      case UserRole.collector:
        return 'Create Collector Account';
      case UserRole.admin:
        return 'Create Dairy Admin Account';
    }
  }

  String get _roleSubtitle {
    switch (_selectedRole) {
      case UserRole.farmer:
        return 'Track your milk records, daily rates & instant payments';
      case UserRole.collector:
        return 'Record daily milk collections, manage routes & farmers';
      case UserRole.admin:
        return 'Oversee dairy processing operations, dispatches & analytics';
    }
  }

  Widget _buildRoleTab(UserRole role, String title, IconData icon) {
    final isSelected = _selectedRole == role;
    final primaryColor = role == UserRole.farmer
        ? AppTheme.brandGreen
        : role == UserRole.collector
            ? const Color(0xFF0284C7)
            : const Color(0xFF0F766E);

    return Expanded(
      child: GestureDetector(
        onTap: () => _selectRole(role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
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
                color: isSelected ? primaryColor : Colors.grey.shade600,
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
                      color: isSelected ? primaryColor : Colors.grey.shade600,
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        title: const Text('Create account'),
        backgroundColor: AppTheme.scaffoldBg,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Cute Cow Mascot & Brand Header
                          Container(
                            height: 110,
                            width: 110,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: AppTheme.creamBorder, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/cow_mascot.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Join Farm2Factory',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _roleSubtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // 3-Role Segment Tab Switcher: Farmer, Collector, Dairy Admin
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.grey.shade300.withOpacity(0.6),
                              ),
                            ),
                            child: Row(
                              children: [
                                _buildRoleTab(
                                    UserRole.farmer, 'Farmer', Icons.agriculture),
                                const SizedBox(width: 4),
                                _buildRoleTab(UserRole.collector, 'Collector',
                                    Icons.local_shipping_outlined),
                                const SizedBox(width: 4),
                                _buildRoleTab(UserRole.admin, 'Dairy Admin',
                                    Icons.business_outlined),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Full Name Field
                          CustomTextField(
                            controller: _nameController,
                            label: _selectedRole == UserRole.admin
                                ? 'Administrator full name'
                                : _selectedRole == UserRole.collector
                                    ? 'Collector full name'
                                    : 'Full name',
                            hint: _selectedRole == UserRole.admin
                                ? 'e.g. Dr. Rajesh Sharma'
                                : _selectedRole == UserRole.collector
                                    ? 'e.g. Ramesh Kumar'
                                    : 'e.g. Ram Singh',
                            prefixIcon: _selectedRole == UserRole.admin
                                ? Icons.admin_panel_settings_outlined
                                : Icons.person_outline,
                            textInputAction: TextInputAction.next,
                            validator: (v) =>
                                Validators.required(v, field: 'Name'),
                          ),
                          const SizedBox(height: 14),

                          // Phone / Username Field
                          CustomTextField(
                            controller: _phoneController,
                            label: _selectedRole == UserRole.admin
                                ? 'Admin username or mobile'
                                : 'Mobile number',
                            hint: _selectedRole == UserRole.admin
                                ? 'e.g. dairyadmin or 10-digit mobile'
                                : '10-digit number (used for login)',
                            prefixIcon: _selectedRole == UserRole.admin
                                ? Icons.badge_outlined
                                : Icons.phone_outlined,
                            keyboardType: _selectedRole == UserRole.admin
                                ? TextInputType.text
                                : TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            maxLength: _selectedRole == UserRole.admin ? null : 10,
                            validator: _selectedRole == UserRole.admin
                                ? (v) => (v == null || v.trim().isEmpty)
                                    ? 'Admin username or mobile is required'
                                    : null
                                : Validators.phone,
                          ),
                          const SizedBox(height: 14),

                          // Dynamic Role-Specific Field: Center / Plant Name
                          CustomTextField(
                            controller: _centerController,
                            label: _selectedRole == UserRole.admin
                                ? 'Dairy Plant / Processing Unit Name'
                                : _selectedRole == UserRole.collector
                                    ? 'Collection Center Name'
                                    : 'Village / Region (Optional)',
                            hint: _selectedRole == UserRole.admin
                                ? 'e.g. Jaipur Cooperative Dairy Plant'
                                : _selectedRole == UserRole.collector
                                    ? 'e.g. Behror Collection Center'
                                    : 'e.g. Central Valley / Behror',
                            prefixIcon: _selectedRole == UserRole.admin
                                ? Icons.factory_outlined
                                : _selectedRole == UserRole.collector
                                    ? Icons.storefront_outlined
                                    : Icons.location_on_outlined,
                            textInputAction: TextInputAction.next,
                            validator: _selectedRole == UserRole.farmer
                                ? null
                                : (v) => (v == null || v.trim().isEmpty)
                                    ? (_selectedRole == UserRole.admin
                                        ? 'Dairy plant name is required'
                                        : 'Collection center is required')
                                    : null,
                          ),

                          // Extra optional location field for Collector
                          if (_selectedRole == UserRole.collector) ...[
                            const SizedBox(height: 14),
                            CustomTextField(
                              controller: _locationController,
                              label: 'Center Location / Tehsil (Optional)',
                              hint: 'e.g. Behror, Alwar Highway',
                              prefixIcon: Icons.map_outlined,
                              textInputAction: TextInputAction.next,
                            ),
                          ],

                          const SizedBox(height: 14),
                          PasswordField(
                            controller: _passwordController,
                            label: 'Password',
                            textInputAction: TextInputAction.next,
                            validator: Validators.password,
                          ),
                          const SizedBox(height: 14),
                          PasswordField(
                            controller: _confirmController,
                            label: 'Confirm password',
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _register(),
                            validator: (v) => Validators.confirmPassword(
                                v, _passwordController.text),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _error!,
                              style: TextStyle(
                                color: scheme.error,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 22),

                          // Styled Gradient Submit Button
                          Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: _buttonGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: _shadowColor.withOpacity(0.32),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: _loading ? null : _register,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                                    _buttonText,
                                                    maxLines: 1,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 0.3,
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
                          TextButton(
                            onPressed: () => context.canPop()
                                ? context.pop()
                                : context.go(AppRoutes.login),
                            child: Text(
                              'Already have an account? Login',
                              style: TextStyle(
                                color: _primaryRoleColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const BrandFooter(),
          ],
        ),
      ),
    );
  }
}
