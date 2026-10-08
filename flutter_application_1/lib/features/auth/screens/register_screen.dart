import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/brand_footer.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/password_field.dart';
import '../data/auth_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    final phone = _phoneController.text.trim();
    final error = await AuthRepository.instance.registerFarmer(
      name: _nameController.text,
      phone: phone,
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = error;
    });
    if (error != null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account created. Please log in.')),
    );
    // Send the mobile number to Login so it is already filled in.
    context.go(AppRoutes.login, extra: phone);
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
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Cute Cow Mascot & Brand Header
                          Container(
                            height: 120,
                            width: 120,
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
                          const SizedBox(height: 14),
                          const Text(
                            'Join Farm2Factory',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'From farm to factory, every litre counted',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: _nameController,
                            label: 'Full name',
                            prefixIcon: Icons.person_outline,
                            textInputAction: TextInputAction.next,
                            validator: (v) =>
                                Validators.required(v, field: 'Name'),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _phoneController,
                            label: 'Mobile number',
                            hint: 'You will log in with this',
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            maxLength: 10,
                            validator: Validators.phone,
                          ),
                          const SizedBox(height: 16),
                          PasswordField(
                            controller: _passwordController,
                            label: 'Password',
                            textInputAction: TextInputAction.next,
                            validator: Validators.password,
                          ),
                          const SizedBox(height: 16),
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
                            Text(_error!,
                                style: TextStyle(color: scheme.error),
                                textAlign: TextAlign.center),
                          ],
                          const SizedBox(height: 24),
                          CustomButton(
                            label: 'Create account',
                            isLoading: _loading,
                            onPressed: _register,
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => context.pop(),
                            child: const Text('Already have an account? Login'),
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
