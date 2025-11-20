import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shuttlebee/core/theme/app_colors.dart';
import 'package:shuttlebee/core/theme/app_spacing.dart';
import 'package:shuttlebee/core/theme/app_text_styles.dart';

/// Reports Screen - شاشة التقارير
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('التقارير'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date Range Selector
            _buildDateRangeSelector(),

            const SizedBox(height: AppSpacing.lg),

            // Report Types
            Text(
              'أنواع التقارير',
              style: AppTextStyles.heading3,
            ),

            const SizedBox(height: AppSpacing.md),

            _buildReportCard(
              icon: Icons.analytics,
              title: 'تقرير الأداء الشامل',
              description: 'تحليل شامل لجميع الرحلات والأداء',
              color: AppColors.primary,
              onGenerate: () => _generateReport('performance'),
            ),

            _buildReportCard(
              icon: Icons.directions_bus,
              title: 'تقرير المركبات',
              description: 'استخدام المركبات والصيانة والكفاءة',
              color: AppColors.success,
              onGenerate: () => _generateReport('vehicles'),
            ),

            _buildReportCard(
              icon: Icons.person,
              title: 'تقرير السائقين',
              description: 'أداء السائقين والالتزام بالمواعيد',
              color: AppColors.warning,
              onGenerate: () => _generateReport('drivers'),
            ),

            _buildReportCard(
              icon: Icons.attach_money,
              title: 'التقرير المالي',
              description: 'تكاليف التشغيل والوقود والنفقات',
              color: AppColors.error,
              onGenerate: () => _generateReport('financial'),
            ),

            _buildReportCard(
              icon: Icons.people,
              title: 'تقرير الركاب',
              description: 'إحصائيات الركاب والحضور والغياب',
              color: Colors.purple,
              onGenerate: () => _generateReport('passengers'),
            ),

            _buildReportCard(
              icon: Icons.schedule,
              title: 'تقرير الالتزام بالمواعيد',
              description: 'التأخيرات والالتزام بالجداول الزمنية',
              color: Colors.orange,
              onGenerate: () => _generateReport('punctuality'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'نطاق التاريخ',
              style: AppTextStyles.heading4,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectStartDate(context),
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      _startDate != null
                          ? DateFormat('yyyy-MM-dd').format(_startDate!)
                          : 'تاريخ البداية',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text('إلى'),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectEndDate(context),
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      _endDate != null
                          ? DateFormat('yyyy-MM-dd').format(_endDate!)
                          : 'تاريخ النهاية',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                _buildQuickDateButton('اليوم', () => _setTodayRange()),
                _buildQuickDateButton('هذا الأسبوع', () => _setThisWeekRange()),
                _buildQuickDateButton('هذا الشهر', () => _setThisMonthRange()),
                _buildQuickDateButton('آخر 30 يوم', () => _setLast30DaysRange()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDateButton(String label, VoidCallback onPressed) {
    return ActionChip(
      label: Text(label, style: AppTextStyles.caption),
      onPressed: onPressed,
      backgroundColor: AppColors.primary.withOpacity(0.1),
    );
  }

  Widget _buildReportCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onGenerate,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.heading4,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onGenerate,
              icon: const Icon(Icons.download),
              tooltip: 'تحميل التقرير',
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _setTodayRange() {
    final now = DateTime.now();
    setState(() {
      _startDate = DateTime(now.year, now.month, now.day);
      _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    });
  }

  void _setThisWeekRange() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    setState(() {
      _startDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
      _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    });
  }

  void _setThisMonthRange() {
    final now = DateTime.now();
    setState(() {
      _startDate = DateTime(now.year, now.month, 1);
      _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    });
  }

  void _setLast30DaysRange() {
    final now = DateTime.now();
    setState(() {
      _startDate = now.subtract(const Duration(days: 30));
      _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    });
  }

  void _generateReport(String reportType) {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تحديد نطاق التاريخ أولاً'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.md),
            Text(
              'جاري إنشاء التقرير...',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );

    // Simulate report generation
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إنشاء تقرير $reportType بنجاح'),
          backgroundColor: AppColors.success,
          action: SnackBarAction(
            label: 'عرض',
            textColor: Colors.white,
            onPressed: () {
              // TODO: Open report
            },
          ),
        ),
      );
    });
  }
}
