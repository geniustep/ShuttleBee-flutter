import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shuttlebee/core/enums/enums.dart';
import 'package:shuttlebee/core/theme/app_colors.dart';
import 'package:shuttlebee/core/theme/app_spacing.dart';
import 'package:shuttlebee/core/theme/app_text_styles.dart';
import 'package:shuttlebee/domain/entities/partner_entity.dart';
import 'package:shuttlebee/domain/entities/trip_entity.dart';
import 'package:shuttlebee/domain/entities/vehicle_entity.dart';
import 'package:shuttlebee/presentation/providers/dispatcher/trip_management_notifier.dart';
import 'package:shuttlebee/presentation/screens/dispatcher/select_driver_screen.dart';
import 'package:shuttlebee/presentation/screens/dispatcher/select_vehicle_screen.dart';
import 'package:shuttlebee/routes/app_router.dart';

/// Edit Trip Screen - شاشة تعديل رحلة
class EditTripScreen extends ConsumerStatefulWidget {
  final int tripId;

  const EditTripScreen({
    super.key,
    required this.tripId,
  });

  @override
  ConsumerState<EditTripScreen> createState() => _EditTripScreenState();
}

class _EditTripScreenState extends ConsumerState<EditTripScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  DateTime? _selectedDate;
  TripType? _selectedTripType;
  VehicleEntity? _selectedVehicle;
  PartnerEntity? _selectedDriver;
  TimeOfDay? _plannedStartTime;
  TimeOfDay? _plannedArrivalTime;
  TripEntity? _trip;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadTrip();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadTrip() async {
    final state = ref.read(tripManagementNotifierProvider);
    final trip = state.selectedTrip ?? state.trips.firstWhere(
      (t) => t.id == widget.tripId,
      orElse: () => throw Exception('Trip not found'),
    );

    setState(() {
      _trip = trip;
      _nameController.text = trip.name;
      _selectedDate = trip.date;
      _selectedTripType = trip.tripType;
      if (trip.plannedStartTime != null) {
        _plannedStartTime = TimeOfDay.fromDateTime(trip.plannedStartTime!);
      }
      if (trip.plannedArrivalTime != null) {
        _plannedArrivalTime = TimeOfDay.fromDateTime(trip.plannedArrivalTime!);
      }
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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

    final success = await ref.read(tripManagementNotifierProvider.notifier).updateTrip(
          tripId: widget.tripId,
          name: _nameController.text,
          date: _selectedDate,
          tripType: _selectedTripType,
          vehicleId: _selectedVehicle?.id,
          driverId: _selectedDriver?.id,
          plannedStartTime: plannedStartDateTime,
          plannedArrivalTime: plannedArrivalDateTime,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث الرحلة بنجاح'),
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

    if (_trip == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('تعديل الرحلة'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip State Info
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: _trip!.state.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: _trip!.state.color.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: _trip!.state.color,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'حالة الرحلة: ${_trip!.state.arabicLabel}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: _trip!.state.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

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
                    _selectedVehicle?.name ?? _trip!.vehicleName ?? 'اختر المركبة',
                    style: (_selectedVehicle != null || _trip!.vehicleName != null)
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
                    _selectedDriver?.name ?? _trip!.driverName ?? 'اختر السائق',
                    style: (_selectedDriver != null || _trip!.driverName != null)
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
                  onPressed: state.isUpdating ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    backgroundColor: AppColors.primary,
                  ),
                  child: state.isUpdating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'حفظ التغييرات',
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

