import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/loading_widget.dart';
import '../data/farmer_repository.dart';
import '../widgets/farmer_card.dart';

class FarmersScreen extends StatefulWidget {
  const FarmersScreen({super.key});

  @override
  State<FarmersScreen> createState() => _FarmersScreenState();
}

class _FarmersScreenState extends State<FarmersScreen> {
  final _repo = FarmerRepository.instance;
  final _searchController = TextEditingController();

  String _query = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFarmers();
  }

  Future<void> _loadFarmers() async {
    try {
      await _repo.getFarmers();

      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Failed to load farmers';
      });
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
      appBar: AppBar(
        title: const Text('Farmers'),
      ),

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
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),
          ),

          Expanded(
            child: _loading
                ? const LoadingWidget(
                    message: 'Loading farmers...',
                  )
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _loading = true;
                                });

                                _loadFarmers();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : ListenableBuilder(
                        listenable: _repo,
                        builder: (context, _) {
                          final results = _repo.search(_query);

                          if (results.isEmpty) {
                            return const Center(
                              child: Text('No farmers found'),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.only(
                              bottom: 88,
                            ),
                            itemCount: results.length,
                            itemBuilder: (context, index) {
                              final farmer = results[index];

                              return FarmerCard(
                                farmer: farmer,
                                onTap: () => context.push(
                                  AppRoutes.farmerDetails(
                                    farmer.id,
                                  ),
                                ),
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