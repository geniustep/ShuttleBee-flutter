import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shuttlebee/core/theme/app_colors.dart';
import 'package:shuttlebee/core/theme/app_spacing.dart';
import 'package:shuttlebee/core/theme/app_text_styles.dart';

/// Bar Chart Widget - رسم بياني بالأعمدة
class BarChartWidget extends StatelessWidget {
  const BarChartWidget({
    required this.data,
    required this.labels,
    this.title,
    this.color = AppColors.primary,
    this.showGrid = true,
    this.height = 200,
    super.key,
  });

  final List<double> data;
  final List<String> labels;
  final String? title;
  final Color color;
  final bool showGrid;
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
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY + (maxY * 0.2),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.black87,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${labels[group.x.toInt()]}\n',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: rod.toY.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.yellow,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
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
                gridData: FlGridData(
                  show: showGrid,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 0 ? maxY / 5 : 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey[300]!),
                ),
                barGroups: data
                    .asMap()
                    .entries
                    .map(
                      (e) => BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: e.value,
                            color: color,
                            width: 16,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

