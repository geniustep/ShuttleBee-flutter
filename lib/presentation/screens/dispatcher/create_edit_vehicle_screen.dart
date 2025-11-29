import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shuttlebee/core/theme/app_colors.dart';
import 'package:shuttlebee/core/theme/app_spacing.dart';
import 'package:shuttlebee/domain/entities/vehicle_entity.dart';
import 'package:shuttlebee/presentation/providers/vehicle/vehicle_management_notifier.dart';
import 'package:shuttlebee/routes/app_router.dart';

/// Create/Edit Vehicle Screen - شاشة إنشاء/تعديل مركبة
class CreateEditVehicleScreen extends ConsumerStatefulWidget {
  final VehicleEntity? vehicle;

  const CreateEditVehicleScreen({
    super.key,
    this.vehicle,
  });

  @override
  ConsumerState<CreateEditVehicleScreen> createState() =>
      _CreateEditVehicleScreenState();
}

class _CreateEditVehicleScreenState
    extends ConsumerState<CreateEditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _licensePlateController;
  late final TextEditingController _seatCapacityController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.vehicle?.name ?? '');
    _licensePlateController =
        TextEditingController(text: widget.vehicle?.licensePlate ?? '');
    _seatCapacityController = TextEditingController(
      text: widget.vehicle?.seatCapacity.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _licensePlateController.dispose();
    _seatCapacityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final seatCapacity = int.tryParse(_seatCapacityController.text);
    if (seatCapacity == null || seatCapacity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال سعة صحيحة أكبر من صفر'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = widget.vehicle == null
        ? await ref.read(vehicleManagementNotifierProvider.notifier).createVehicle(
              name: _nameController.text,
              seatCapacity: seatCapacity,
              licensePlate: _licensePlateController.text.isEmpty
                  ? null
                  : _licensePlateController.text,
            )
        : await ref.read(vehicleManagementNotifierProvider.notifier).updateVehicle(
              id: widget.vehicle!.id,
              name: _nameController.text,
              seatCapacity: seatCapacity,
              licensePlate: _licensePlateController.text.isEmpty
                  ? null
                  : _licensePlateController.text,
            );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.vehicle == null
              ? 'تم إنشاء المركبة بنجاح'
              : 'تم تحديث المركبة بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('${AppRoutes.dispatcherHome}/vehicles');
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
    final isEdit = widget.vehicle != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'تعديل المركبة' : 'إنشاء مركبة جديدة'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المركبة *',
                  hintText: 'أدخل اسم المركبة',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_bus),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم المركبة';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // License Plate
              TextFormField(
                controller: _licensePlateController,
                decoration: const InputDecoration(
                  labelText: 'رقم اللوحة (اختياري)',
                  hintText: 'أدخل رقم اللوحة',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.confirmation_number),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Seat Capacity
              TextFormField(
                controller: _seatCapacityController,
                decoration: const InputDecoration(
                  labelText: 'سعة المقاعد *',
                  hintText: 'أدخل عدد المقاعد',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.event_seat),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال سعة المقاعد';
                  }
                  final capacity = int.tryParse(value);
                  if (capacity == null || capacity <= 0) {
                    return 'يرجى إدخال عدد صحيح أكبر من صفر';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (state.isCreating || state.isUpdating)
                      ? null
                      : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    backgroundColor: AppColors.primary,
                  ),
                  child: (state.isCreating || state.isUpdating)
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          isEdit ? 'حفظ التغييرات' : 'إنشاء المركبة',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

