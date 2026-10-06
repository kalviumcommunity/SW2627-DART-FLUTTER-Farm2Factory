import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
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

  String? _center;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    try {
      final farmer = await FarmerRepository.instance.add(
        name: _nameController.text,
        phone: _phoneController.text,
        village: _villageController.text,
        center: _center!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${farmer.name} added as ${farmer.id}'),
        ),
      );

      // Replace this screen with the details page.
      context.pushReplacement(
        AppRoutes.farmerDetails(farmer.id),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add farmer: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Farmer'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: _nameController,
                  label: 'Name',
                  prefixIcon: Icons.person_outline,
                  validator: (v) =>
                      Validators.required(v, field: 'Name'),
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  validator: Validators.phone,
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  controller: _villageController,
                  label: 'Village',
                  prefixIcon: Icons.location_on_outlined,
                  validator: (v) =>
                      Validators.required(v, field: 'Village'),
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Collection Center',
                    prefixIcon: Icon(Icons.store_outlined),
                  ),
                  items: FarmerRepository.centers
                      .map(
                        (center) => DropdownMenuItem(
                          value: center,
                          child: Text(center),
                        ),
                      )
                      .toList(),
                  onChanged: _saving
                      ? null
                      : (value) {
                          setState(() {
                            _center = value;
                          });
                        },
                  validator: (value) => Validators.required(
                    value,
                    field: 'Collection center',
                  ),
                ),

                const SizedBox(height: 24),

                CustomButton(
                  label: _saving ? 'Saving...' : 'Save Farmer',
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}