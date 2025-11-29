import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuttlebee/core/theme/app_colors.dart';
import 'package:shuttlebee/core/theme/app_spacing.dart';
import 'package:shuttlebee/core/theme/app_text_styles.dart';
import 'package:shuttlebee/domain/entities/vehicle_entity.dart';
import 'package:shuttlebee/presentation/providers/vehicle/vehicle_management_notifier.dart';
import 'package:shuttlebee/presentation/screens/dispatcher/create_edit_vehicle_screen.dart';

/// Vehicle Management Screen - شاشة إدارة المركبات
class VehicleManagementScreen extends ConsumerStatefulWidget {
  const VehicleManagementScreen({super.key});

  @override
  ConsumerState<VehicleManagementScreen> createState() =>
      _VehicleManagementScreenState();
}

class _VehicleManagementScreenState
    extends ConsumerState<VehicleManagementScreen> {
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

  Future<void> _handleDelete(VehicleEntity vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المركبة'),
        content: Text('هل أنت متأكد من حذف المركبة "${vehicle.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('تراجع'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await ref
        .read(vehicleManagementNotifierProvider.notifier)
        .deleteVehicle(vehicle.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حذف المركبة بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      final state = ref.read(vehicleManagementNotifierProvider);
      if (state.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vehicleManagementNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('إدارة المركبات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVehicles,
            tooltip: 'تحديث',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateEditVehicleScreen(),
            ),
          ).then((_) => _loadVehicles());
        },
        icon: const Icon(Icons.add),
        label: const Text('مركبة جديدة'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _buildErrorState(state.error!)
              : Column(
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
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),

                    // Vehicle List
                    Expanded(
                      child: state.filteredVehicles.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _loadVehicles,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                itemCount: state.filteredVehicles.length,
                                itemBuilder: (context, index) {
                                  final vehicle = state.filteredVehicles[index];
                                  return _buildVehicleCard(vehicle);
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
            onPressed: _loadVehicles,
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
          const SizedBox(height: AppSpacing.sm),
          Text(
            'اضغط على زر "مركبة جديدة" لإضافة مركبة',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(VehicleEntity vehicle) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: const Icon(
                    Icons.directions_bus,
                    color: AppColors.primary,
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
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateEditVehicleScreen(
                          vehicle: vehicle,
                        ),
                      ),
                    ).then((_) => _loadVehicles());
                  },
                  tooltip: 'تعديل',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  onPressed: () => _handleDelete(vehicle),
                  tooltip: 'حذف',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.event_seat,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'السعة: ${vehicle.seatCapacity} مقعد',
                  style: AppTextStyles.bodySmall,
                ),
                if (vehicle.hasDriver) ...[
                  const SizedBox(width: AppSpacing.md),
                  Icon(
                    Icons.person,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    vehicle.driverName ?? 'سائق',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
