import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shuttlebee/core/enums/enums.dart';
import 'package:shuttlebee/core/theme/app_colors.dart';
import 'package:shuttlebee/core/theme/app_spacing.dart';
import 'package:shuttlebee/core/theme/app_text_styles.dart';
import 'package:shuttlebee/domain/entities/partner_entity.dart';
import 'package:shuttlebee/domain/entities/vehicle_entity.dart';
import 'package:shuttlebee/presentation/providers/dispatcher/trip_management_notifier.dart';
import 'package:shuttlebee/presentation/screens/dispatcher/select_driver_screen.dart';
import 'package:shuttlebee/presentation/screens/dispatcher/select_vehicle_screen.dart';
import 'package:shuttlebee/routes/app_router.dart';

/// Create Trip Screen - شاشة إنشاء رحلة جديدة
class CreateTripScreen extends ConsumerStatefulWidget {
  const CreateTripScreen({super.key});

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _groupIdController = TextEditingController();
  DateTime? _selectedDate;
  TripType? _selectedTripType;
  VehicleEntity? _selectedVehicle;
  PartnerEntity? _selectedDriver;
  TimeOfDay? _plannedStartTime;
  TimeOfDay? _plannedArrivalTime;

  @override
  void dispose() {
    _nameController.dispose();
    _groupIdController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _plannedStartTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _plannedStartTime = picked);
    }
  }

  Future<void> _selectArrivalTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _plannedArrivalTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _plannedArrivalTime = picked);
    }
  }

  Future<void> _selectVehicle() async {
    final selected = await Navigator.push<VehicleEntity>(
      context,
      MaterialPageRoute(
        builder: (context) => SelectVehicleScreen(
          selectedVehicle: _selectedVehicle,
          onVehicleSelected: (vehicle) {
            setState(() => _selectedVehicle = vehicle);
          },
        ),
      ),
    );
    if (selected != null) {
      setState(() => _selectedVehicle = selected);
    }
  }

  Future<void> _selectDriver() async {
    final selected = await Navigator.push<PartnerEntity>(
      context,
      MaterialPageRoute(
        builder: (context) => SelectDriverScreen(
          selectedDriver: _selectedDriver,
          onDriverSelected: (driver) {
            setState(() => _selectedDriver = driver);
          },
        ),
      ),
    );
    if (selected != null) {
      setState(() => _selectedDriver = selected);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار تاريخ الرحلة'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedTripType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار نوع الرحلة'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final groupId = int.tryParse(_groupIdController.text);
    if (groupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال رقم مجموعة الركاب صحيح'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    DateTime? plannedStartDateTime;
    if (_selectedDate != null && _plannedStartTime != null) {
      plannedStartDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _plannedStartTime!.hour,
        _plannedStartTime!.minute,
      );
    }

    DateTime? plannedArrivalDateTime;
    if (_selectedDate != null && _plannedArrivalTime != null) {
      plannedArrivalDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _plannedArrivalTime!.hour,
        _plannedArrivalTime!.minute,
      );
    }

    final success = await ref.read(tripManagementNotifierProvider.notifier).createTrip(
          name: _nameController.text,
          date: _selectedDate!,
          tripType: _selectedTripType!,
          groupId: groupId,
          vehicleId: _selectedVehicle?.id,
          driverId: _selectedDriver?.id,
          plannedStartTime: plannedStartDateTime,
          plannedArrivalTime: plannedArrivalDateTime,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء الرحلة بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go(AppRoutes.dispatcherTrips);
    } else {
      final state = ref.read(tripManagementNotifierProvider);
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
    final state = ref.watch(tripManagementNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('إنشاء رحلة جديدة'),
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
                  labelText: 'اسم الرحلة *',
                  hintText: 'أدخل اسم الرحلة',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم الرحلة';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // Date
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'تاريخ الرحلة *',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('yyyy-MM-dd', 'ar').format(_selectedDate!)
                        : 'اختر التاريخ',
                    style: _selectedDate != null
                        ? AppTextStyles.bodyMedium
                        : AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Trip Type
              Text(
                'نوع الرحلة *',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('استقبال'),
                      selected: _selectedTripType == TripType.pickup,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedTripType = TripType.pickup);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('توصيل'),
                      selected: _selectedTripType == TripType.dropoff,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedTripType = TripType.dropoff);
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Group ID
              TextFormField(
                controller: _groupIdController,
                decoration: const InputDecoration(
                  labelText: 'رقم مجموعة الركاب *',
                  hintText: 'أدخل رقم المجموعة',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال رقم المجموعة';
                  }
                  if (int.tryParse(value) == null) {
                    return 'يرجى إدخال رقم صحيح';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // Vehicle Selection
              InkWell(
                onTap: _selectVehicle,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'المركبة (اختياري)',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.directions_bus),
                  ),
                  child: Text(
                    _selectedVehicle?.name ?? 'اختر المركبة',
                    style: _selectedVehicle != null
                        ? AppTextStyles.bodyMedium
                        : AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Driver Selection
              InkWell(
                onTap: _selectDriver,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'السائق (اختياري)',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.person),
                  ),
                  child: Text(
                    _selectedDriver?.name ?? 'اختر السائق',
                    style: _selectedDriver != null
                        ? AppTextStyles.bodyMedium
                        : AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Planned Start Time
              InkWell(
                onTap: _selectStartTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'وقت البدء المخطط (اختياري)',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(
                    _plannedStartTime != null
                        ? _plannedStartTime!.format(context)
                        : 'اختر وقت البدء',
                    style: _plannedStartTime != null
                        ? AppTextStyles.bodyMedium
                        : AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Planned Arrival Time
              InkWell(
                onTap: _selectArrivalTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'وقت الوصول المخطط (اختياري)',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(
                    _plannedArrivalTime != null
                        ? _plannedArrivalTime!.format(context)
                        : 'اختر وقت الوصول',
                    style: _plannedArrivalTime != null
                        ? AppTextStyles.bodyMedium
                        : AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isCreating ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    backgroundColor: AppColors.primary,
                  ),
                  child: state.isCreating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'إنشاء الرحلة',
                          style: TextStyle(fontSize: 16),
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

