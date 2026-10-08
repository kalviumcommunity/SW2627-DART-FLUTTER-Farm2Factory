import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../data/farmer_repository.dart';

class AddFarmerScreen extends StatefulWidget {
  const AddFarmerScreen({super.key});

  @override
  State<AddFarmerScreen> createState() => _AddFarmerScreenState();
}

class _AddFarmerScreenState extends State<AddFarmerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _villageController = TextEditingController();
  final _aadhaarController = TextEditingController();

  String? _center = 'Jaipur Center';
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _villageController.dispose();
    _aadhaarController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final farmer = await FarmerRepository.instance.add(
        name: _nameController.text,
        phone: _phoneController.text,
        village: _villageController.text,
        center: _center!,
        aadhaarNumber:
            _aadhaarController.text.isNotEmpty ? _aadhaarController.text : null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Farmer ${farmer.name} registered as ${farmer.id}!'),
          backgroundColor: AppTheme.brandGreen,
        ),
      );

      context.pushReplacement(AppRoutes.farmerDetails(farmer.id));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add farmer: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Add Farmer',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 125,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEAF5EB), Color(0xFFD7ECD9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: AppTheme.brandGreen.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Register\nNew Farmer',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1B3821),
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Add farmer details to your\ncollection center',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.grey.shade700,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 6,
                        top: 4,
                        bottom: 4,
                        child: Image.asset(
                          'assets/images/cow_mascot.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter farmer full name',
                    prefixIcon: Icon(Icons.person_outline,
                        color: Colors.grey.shade600, size: 20),
                  ),
                  validator: (v) => Validators.required(v, field: 'Full name'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '10-digit mobile number',
                    prefixIcon: Icon(Icons.phone_outlined,
                        color: Colors.grey.shade600, size: 20),
                    counterText: '',
                  ),
                  validator: Validators.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _villageController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Village',
                    hintText: 'Village or locality name',
                    prefixIcon: Icon(Icons.location_on_outlined,
                        color: Colors.grey.shade600, size: 20),
                  ),
                  validator: (v) => Validators.required(v, field: 'Village'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _center,
                  decoration: InputDecoration(
                    labelText: 'Collection Center',
                    prefixIcon: Icon(Icons.store_outlined,
                        color: Colors.grey.shade600, size: 20),
                  ),
                  items: FarmerRepository.centers
                      .map(
                        (center) => DropdownMenuItem(
                          value: center,
                          child: Text(center),
                        ),
                      )
                      .toList(),
                  onChanged: _saving ? null : (val) => setState(() => _center = val),
                  validator: (v) =>
                      Validators.required(v, field: 'Collection Center'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _aadhaarController,
                  keyboardType: TextInputType.number,
                  maxLength: 12,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Aadhaar Number (Optional)',
                    hintText: '12-digit Aadhaar number',
                    prefixIcon: Icon(Icons.badge_outlined,
                        color: Colors.grey.shade600, size: 20),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: AppTheme.orangeGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF8C00).withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _saving ? null : _save,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 32),
                            _saving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Save Farmer',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
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
                const SizedBox(height: 20),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/milk_can_banner.png',
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
