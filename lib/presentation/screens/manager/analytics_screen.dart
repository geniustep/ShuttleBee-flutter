import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shuttlebee/core/theme/app_colors.dart';
import 'package:shuttlebee/core/theme/app_spacing.dart';
import 'package:shuttlebee/core/theme/app_text_styles.dart';
import 'package:shuttlebee/presentation/providers/manager/manager_analytics_notifier.dart';
import 'package:shuttlebee/presentation/providers/manager/manager_analytics_state.dart';

/// Analytics Screen - شاشة التحليلات المتقدمة
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    // تأجيل تحميل التحليلات حتى ينتهي بناء الـ widget tree
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalytics();
    });
  }

  Future<void> _loadAnalytics() async {
    await ref.read(managerAnalyticsNotifierProvider.notifier).loadAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(managerAnalyticsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('التحليلات المتقدمة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _buildErrorState(state.error!)
              : RefreshIndicator(
                  onRefresh: _loadAnalytics,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Trend Chart (Last 7 Days)
                        Text(
                          'اتجاه الرحلات - آخر 7 أيام',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildTrendChart(state.dailyStats),

                        const SizedBox(height: AppSpacing.lg),

                        // Performance Indicators
                        Text(
                          'مؤشرات الأداء الرئيسية (KPIs)',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildKPICards(state),

                        const SizedBox(height: AppSpacing.lg),

                        // Efficiency Metrics
                        Text(
                          'مقاييس الكفاءة',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildEfficiencyMetrics(state),

                        const SizedBox(height: AppSpacing.lg),

                        // Cost Analysis
                        Text(
                          'تحليل التكاليف',
                          style: AppTextStyles.heading3,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildCostAnalysis(state),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text(error,
              style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: _loadAnalytics,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart(List<DailyTripStat> dailyStats) {
    if (dailyStats.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: Text(
              'لا توجد بيانات كافية',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    // Simple bar chart visualization
    final maxTrips = dailyStats.fold<int>(
      0,
      (max, stat) => stat.totalTrips > max ? stat.totalTrips : max,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // Chart
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: dailyStats.map((stat) {
                  final heightPercentage =
                      maxTrips > 0 ? stat.totalTrips / maxTrips : 0.0;

                  return Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Value
                          Text(
                            '${stat.totalTrips}',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Bar
                          Container(
                            height: heightPercentage * 150,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary.withOpacity(0.5),
                                ],
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(AppSpacing.radiusSm),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          // Day label
                          Text(
                            DateFormat('E', 'ar').format(stat.date),
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(AppColors.success, 'منتهية'),
                const SizedBox(width: AppSpacing.md),
                _buildLegendItem(AppColors.error, 'ملغاة'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildKPICards(state) {
    return Column(
      children: [
        _buildKPICard(
          title: 'معدل الإنجاز',
          value: '${state.completionRate.toStringAsFixed(1)}%',
          target: '95%',
          progress: state.completionRate / 100,
          color: state.completionRate >= 90
              ? AppColors.success
              : AppColors.warning,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildKPICard(
          title: 'الالتزام بالموعد',
          value: '${state.onTimePercentage.toStringAsFixed(1)}%',
          target: '85%',
          progress: state.onTimePercentage / 100,
          color: state.onTimePercentage >= 80
              ? AppColors.success
              : AppColors.warning,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildKPICard(
          title: 'معدل الإشغال',
          value: '${state.averageOccupancyRate.toStringAsFixed(1)}%',
          target: '80%',
          progress: state.averageOccupancyRate / 100,
          color: state.averageOccupancyRate >= 75
              ? AppColors.success
              : AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required String target,
    required double progress,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppTextStyles.heading4),
                Text(
                  value,
                  style: AppTextStyles.heading3.copyWith(color: color),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              color: color,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'الهدف: $target',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEfficiencyMetrics(state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _buildMetricRow(
              'متوسط التأخير',
              '${state.averageDelayMinutes.toStringAsFixed(0)} دقيقة',
              Icons.timer_off,
              state.averageDelayMinutes <= 5
                  ? AppColors.success
                  : AppColors.error,
            ),
            const Divider(height: AppSpacing.lg),
            _buildMetricRow(
              'متوسط المسافة لكل رحلة',
              '${state.averageDistancePerTrip.toStringAsFixed(1)} كم',
              Icons.straighten,
              AppColors.primary,
            ),
            const Divider(height: AppSpacing.lg),
            _buildMetricRow(
              'إجمالي الركاب',
              '${state.totalPassengersTransported}',
              Icons.people,
              AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(label, style: AppTextStyles.bodyMedium),
        ),
        Text(
          value,
          style: AppTextStyles.heading4.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _buildCostAnalysis(state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المسافة الكلية',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.totalDistanceKm.toStringAsFixed(0)} كم',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: const Icon(
                    Icons.map,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تكلفة الوقود المقدرة',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.estimatedFuelCost.toStringAsFixed(0)} ريال',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: const Icon(
                    Icons.local_gas_station,
                    color: AppColors.warning,
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'التكلفة المقدرة بناءً على 0.5 ريال لكل كيلومتر',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
