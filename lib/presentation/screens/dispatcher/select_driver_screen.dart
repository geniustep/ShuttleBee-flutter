import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuttlebee/core/di/injection.dart';
import 'package:shuttlebee/core/theme/app_colors.dart';
import 'package:shuttlebee/core/theme/app_spacing.dart';
import 'package:shuttlebee/core/theme/app_text_styles.dart';
import 'package:shuttlebee/domain/entities/partner_entity.dart';

/// Select Driver Screen - شاشة اختيار السائق
class SelectDriverScreen extends ConsumerStatefulWidget {
  final PartnerEntity? selectedDriver;
  final Function(PartnerEntity) onDriverSelected;

  const SelectDriverScreen({
    super.key,
    this.selectedDriver,
    required this.onDriverSelected,
  });

  @override
  ConsumerState<SelectDriverScreen> createState() =>
      _SelectDriverScreenState();
}

class _SelectDriverScreenState extends ConsumerState<SelectDriverScreen> {
  final _searchController = TextEditingController();
  List<PartnerEntity> _drivers = [];
  List<PartnerEntity> _filteredDrivers = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDrivers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDrivers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final repository = ref.read(partnerRepositoryProvider);
    final result = await repository.getDrivers();

    result.fold(
      (failure) {
        setState(() {
          _error = failure.message;
          _isLoading = false;
        });
      },
      (drivers) {
        setState(() {
          _drivers = drivers;
          _filteredDrivers = drivers;
          _isLoading = false;
        });
      },
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDrivers = _drivers;
      } else {
        _filteredDrivers = _drivers
            .where((driver) =>
                driver.name.toLowerCase().contains(query.toLowerCase()) ||
                (driver.mobile?.toLowerCase().contains(query.toLowerCase()) ??
                    false) ||
                (driver.phone?.toLowerCase().contains(query.toLowerCase()) ??
                    false))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('اختيار السائق'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'بحث عن سائق...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Driver List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorState(_error!)
                    : _filteredDrivers.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadDrivers,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              itemCount: _filteredDrivers.length,
                              itemBuilder: (context, index) {
                                final driver = _filteredDrivers[index];
                                final isSelected =
                                    widget.selectedDriver?.id == driver.id;
                                return _buildDriverCard(driver, isSelected);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            error,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: _loadDrivers,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'لا توجد سائقين',
            style: AppTextStyles.heading3.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(PartnerEntity driver, bool isSelected) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      color: isSelected
          ? AppColors.primary.withOpacity(0.1)
          : AppColors.surface,
      child: InkWell(
        onTap: () {
          widget.onDriverSelected(driver);
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.1),
                child: Text(
                  driver.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name,
                      style: AppTextStyles.heading4,
                    ),
                    if (driver.preferredPhone != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        driver.preferredPhone!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

