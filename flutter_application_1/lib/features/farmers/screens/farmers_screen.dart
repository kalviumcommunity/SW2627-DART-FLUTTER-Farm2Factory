import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../models/farmer.dart';
import '../../../services/farmer_service.dart';
import '../widgets/farmer_card.dart';

class FarmersScreen extends StatefulWidget {
  const FarmersScreen({super.key});

  @override
  State<FarmersScreen> createState() => _FarmersScreenState();
}

class _FarmersScreenState extends State<FarmersScreen> {
  final FarmerService _farmerService = FarmerService();
  final _searchController = TextEditingController();
  String _query = '';
  bool _loading = true;
  List<Farmer> _allFarmers = [];

  @override
  void initState() {
    super.initState();
    _loadFarmers();
  }

  Future<void> _loadFarmers() async {
    try {
      final farmers = await _farmerService.getFarmers();
      if (mounted) {
        setState(() {
          _allFarmers = farmers;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farmers')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addFarmer),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Farmer'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomTextField(
              controller: _searchController,
              label: 'Search farmer',
              hint: 'Name, ID or village',
              prefixIcon: Icons.search,
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: _loading
                ? const LoadingWidget(message: 'Loading farmers...')
                : Builder(
                    builder: (context) {
                      final results = _allFarmers.where((f) {
                        final q = _query.toLowerCase();
                        return f.name.toLowerCase().contains(q) ||
                            f.id.toLowerCase().contains(q) ||
                            f.village.toLowerCase().contains(q);
                      }).toList();

                      if (results.isEmpty) {
                        return const Center(child: Text('No farmers found'));
                      }
                      
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final farmer = results[index];
                          return FarmerCard(
                            farmer: farmer,
                            onTap: () => context
                                .push(AppRoutes.farmerDetails(farmer.id)),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

