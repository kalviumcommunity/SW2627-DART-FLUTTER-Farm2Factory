import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../data/farmer_repository.dart';
import '../models/farmer.dart';

class FarmersScreen extends StatefulWidget {
  const FarmersScreen({super.key});

  @override
  State<FarmersScreen> createState() => _FarmersScreenState();
}

class _FarmersScreenState extends State<FarmersScreen> {
  final _repo = FarmerRepository.instance;
  final _searchController = TextEditingController();
  String _query = '';
  String _selectedCenter = 'All';
  bool _sortAscending = true;

  final List<Color> _avatarColors = const [
    Color(0xFF0288D1), // Blue
    Color(0xFFE53935), // Red
    Color(0xFF2E7D32), // Green
    Color(0xFF3949AB), // Indigo
    Color(0xFFFB8C00), // Orange
    Color(0xFF8E24AA), // Purple
    Color(0xFFFDD835), // Yellow
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getAvatarColor(int index) {
    return _avatarColors[index % _avatarColors.length];
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
          'Farmers',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        actions: [
          // Circular green "+" button in AppBar matching reference UI
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: InkWell(
              onTap: () => context.push(AppRoutes.addFarmer),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  gradient: AppTheme.greenGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _repo,
        builder: (context, _) {
          var results = _repo.filterAndSearch(
            query: _query,
            selectedCenter: _selectedCenter,
          );

          if (_sortAscending) {
            results.sort((a, b) => a.name.compareTo(b.name));
          } else {
            results.sort((a, b) => b.name.compareTo(a.name));
          }

          return Column(
            children: [
              // Search Bar & Filter Button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.creamBorder),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _query = val),
                          decoration: InputDecoration(
                            hintText: 'Search farmer by name or ID',
                            hintStyle: TextStyle(
                                fontSize: 13, color: Colors.grey.shade400),
                            prefixIcon: Icon(Icons.search,
                                color: Colors.grey.shade500, size: 20),
                            suffixIcon: _query.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 16),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _query = '');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.creamBorder),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.tune,
                            size: 20, color: Color(0xFF475569)),
                        onPressed: () {
                          // Toggle filter or reset
                          setState(() {
                            _selectedCenter = 'All';
                            _query = '';
                            _searchController.clear();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: FarmerRepository.centerTabs.map((center) {
                    final isSelected = _selectedCenter == center;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(center),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCenter = center);
                          }
                        },
                        selectedColor: AppTheme.brandGreen,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF475569),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.brandGreen
                                : Colors.grey.shade200,
                          ),
                        ),
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Subheader: Total Farmers & Name Sort
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Farmers: ${results.length}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    InkWell(
                      onTap: () =>
                          setState(() => _sortAscending = !_sortAscending),
                      child: Row(
                        children: [
                          Text(
                            'Name',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            _sortAscending
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            size: 13,
                            color: AppTheme.brandGreen,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Farmer Cards List
              Expanded(
                child: results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 8),
                            Text(
                              'No farmers found',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final farmer = results[index];
                          final avatarColor = _getAvatarColor(index);
                          return _FarmerItemCard(
                            farmer: farmer,
                            avatarColor: avatarColor,
                            onTap: () => context
                                .push(AppRoutes.farmerDetails(farmer.id)),
                            onCall: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Calling ${farmer.name} (${farmer.phone})'),
                                  backgroundColor: AppTheme.brandGreen,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
              // Bottom Pastoral Meadow & Cow Illustration matching Reference UI
              SizedBox(
                width: double.infinity,
                height: 64,
                child: Image.asset(
                  'assets/images/cow_footer.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FarmerItemCard extends StatelessWidget {
  final Farmer farmer;
  final Color avatarColor;
  final VoidCallback onTap;
  final VoidCallback onCall;

  const _FarmerItemCard({
    required this.farmer,
    required this.avatarColor,
    required this.onTap,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.creamBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Circular Initial Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: avatarColor.withOpacity(0.12),
                  child: Text(
                    farmer.name.isNotEmpty
                        ? farmer.name[0].toUpperCase()
                        : 'F',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: avatarColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Farmer Name & Location Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farmer.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${farmer.id} • ${farmer.village}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Phone Call Quick Action
                IconButton(
                  tooltip: 'Call farmer',
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.cardMint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.phone,
                        size: 15, color: AppTheme.brandGreen),
                  ),
                  onPressed: onCall,
                ),

                // Chevron to Details
                Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
