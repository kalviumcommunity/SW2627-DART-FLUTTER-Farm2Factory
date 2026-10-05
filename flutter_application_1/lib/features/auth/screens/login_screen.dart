import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/brand_footer.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/password_field.dart';
import '../data/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  /// Filled in after registering, so the user only types the password.
  final String? initialPhone;

  const LoginScreen({super.key, this.initialPhone});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController;
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // validate() runs every field's validator and shows the red messages
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    final error = await AuthRepository.instance.login(
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = error;
    });

    if (error == null) {
      context.go(AppRoutes.dashboard); // go = replace, Back won't return to Login
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    // keeps the form a nice width on web and tablets
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const AppLogo(size: 96),
                          const SizedBox(height: 16),
                          const Text(
                            'Welcome back',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Log in with your mobile number',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          CustomTextField(
                            controller: _phoneController,
                            label: 'Mobile number',
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
                            // after registering, jump straight to the password
                            autofocus: widget.initialPhone != null,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _login(),
                            validator: (v) =>
                                Validators.required(v, field: 'Password'),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Text(_error!,
                                style: TextStyle(color: scheme.error),
                                textAlign: TextAlign.center),
                          ],
                          const SizedBox(height: 24),
                          CustomButton(
                            label: 'Login',
                            isLoading: _loading,
                            onPressed: _login,
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => context.push(AppRoutes.register),
                            child: const Text('New here? Register'),
                          ),
                          if (kDebugMode) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Demo login: 9999999999 / 123456',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
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
