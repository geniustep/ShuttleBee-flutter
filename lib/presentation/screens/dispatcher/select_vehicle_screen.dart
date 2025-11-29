import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuttlebee/core/theme/app_colors.dart';
import 'package:shuttlebee/core/theme/app_spacing.dart';
import 'package:shuttlebee/core/theme/app_text_styles.dart';
import 'package:shuttlebee/domain/entities/vehicle_entity.dart';
import 'package:shuttlebee/presentation/providers/vehicle/vehicle_management_notifier.dart';

/// Select Vehicle Screen - شاشة اختيار المركبة
class SelectVehicleScreen extends ConsumerStatefulWidget {
  final VehicleEntity? selectedVehicle;
  final Function(VehicleEntity) onVehicleSelected;

  const SelectVehicleScreen({
    super.key,
    this.selectedVehicle,
    required this.onVehicleSelected,
  });

  @override
  ConsumerState<SelectVehicleScreen> createState() =>
      _SelectVehicleScreenState();
}

class _SelectVehicleScreenState extends ConsumerState<SelectVehicleScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVehicles();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    await ref.read(vehicleManagementNotifierProvider.notifier).loadVehicles();
  }

  void _onSearchChanged(String query) {
    ref.read(vehicleManagementNotifierProvider.notifier).searchVehicles(query);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vehicleManagementNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('اختيار المركبة'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'بحث عن مركبة...',
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

          // Vehicle List
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.filteredVehicles.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadVehicles,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: state.filteredVehicles.length,
                          itemBuilder: (context, index) {
                            final vehicle = state.filteredVehicles[index];
                            final isSelected =
                                widget.selectedVehicle?.id == vehicle.id;
                            return _buildVehicleCard(vehicle, isSelected);
                          },
                        ),
                      ),
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
            Icons.directions_bus_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'لا توجد مركبات',
            style: AppTextStyles.heading3.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(VehicleEntity vehicle, bool isSelected) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      color: isSelected
          ? AppColors.primary.withOpacity(0.1)
          : AppColors.surface,
      child: InkWell(
        onTap: () {
          widget.onVehicleSelected(vehicle);
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  Icons.directions_bus,
                  color: isSelected ? Colors.white : AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.name,
                      style: AppTextStyles.heading4,
                    ),
                    if (vehicle.licensePlate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        vehicle.licensePlate!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.event_seat,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${vehicle.seatCapacity} مقعد',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
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

