import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shuttlebee/core/theme/app_colors.dart';
import 'package:shuttlebee/core/theme/app_spacing.dart';
import 'package:shuttlebee/core/theme/app_text_styles.dart';

/// Line Chart Widget - رسم بياني خطي
class LineChartWidget extends StatelessWidget {
  const LineChartWidget({
    required this.data,
    required this.labels,
    this.title,
    this.color = AppColors.primary,
    this.showGrid = true,
    this.showDots = true,
    this.height = 200,
    super.key,
  });

  final List<double> data;
  final List<String> labels;
  final String? title;
  final Color color;
  final bool showGrid;
  final bool showDots;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(
          child: Text('لا توجد بيانات'),
        ),
      );
    }

    final maxY = data.reduce((a, b) => a > b ? a : b);
    final minY = data.reduce((a, b) => a < b ? a : b);

    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: showGrid,
                  drawVerticalLine: true,
                  horizontalInterval: maxY > 0 ? maxY / 5 : 1,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= labels.length) {
                          return const Text('');
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            labels[index],
                            style: AppTextStyles.caption,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxY > 0 ? maxY / 5 : 1,
                      reservedSize: 42,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toInt().toString(),
                          style: AppTextStyles.caption,
                          textAlign: TextAlign.left,
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey[300]!),
                ),
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: minY > 0 ? 0 : minY - (minY * 0.1),
                maxY: maxY + (maxY * 0.1),
                lineBarsData: [
                  LineChartBarData(
                    spots: data
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: showDots),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

