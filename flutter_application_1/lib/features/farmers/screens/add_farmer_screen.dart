import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../models/farmer.dart';
import '../../../services/farmer_service.dart';

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
  final FarmerService _farmerService = FarmerService();
  String? _center;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Generate an ID for the farmer
    final newId = 'FMR-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final farmer = Farmer(
      farmerId: newId,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      village: _villageController.text.trim(),
      centerId: _center!,
      status: 'active',
    );

    try {
      await _farmerService.createFarmer(farmer);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${farmer.name} added as ${farmer.farmerId}')),
      );
      // Replace this screen with the details page. Back then returns to the list.
      context.pushReplacement(AppRoutes.farmerDetails(farmer.farmerId));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding farmer: $e')),
      );
    }
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
                  items: ['CENTER001', 'CENTER002', 'CENTER003']
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
