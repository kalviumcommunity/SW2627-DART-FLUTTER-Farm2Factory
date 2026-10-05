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

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final farmer = FarmerRepository.instance.add(
      name: _nameController.text,
      phone: _phoneController.text,
      village: _villageController.text,
      center: _center!,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${farmer.name} added as ${farmer.id}')),
    );
    // Replace this screen with the details page. Back then returns to the list.
    context.pushReplacement(AppRoutes.farmerDetails(farmer.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Farmer')),
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
                  validator: (v) => Validators.required(v, field: 'Name'),
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
                  validator: (v) => Validators.required(v, field: 'Village'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Collection Center',
                    prefixIcon: Icon(Icons.store_outlined),
                  ),
                  items: FarmerRepository.centers
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) => _center = value,
                  validator: (v) =>
                      Validators.required(v, field: 'Collection center'),
                ),
                const SizedBox(height: 24),
                CustomButton(label: 'Save Farmer', onPressed: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
