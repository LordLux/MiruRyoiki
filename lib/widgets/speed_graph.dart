import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:flutter/material.dart' hide Card, Divider, Tooltip, ListTile, IconButton;

import '../manager.dart';
import '../services/downloads/speed_graph_service.dart';
import '../utils/units.dart';

class SpeedGraphWidget extends StatelessWidget {
  final SpeedGraphService service;
  final Set<String> enabledMetricNames;
  final bool expanded;
  final ValueChanged<bool> onExpandedChanged;

  const SpeedGraphWidget({
    super.key,
    required this.service,
    required this.enabledMetricNames,
    required this.expanded,
    required this.onExpandedChanged,
  });

  static const _metricColors = <SpeedMetric, Color>{
    SpeedMetric.totalDownload: Color(0xFF4CAF50),
    SpeedMetric.totalUpload: Color(0xFF2196F3),
    SpeedMetric.payloadDownload: Color(0xFF8BC34A),
    SpeedMetric.payloadUpload: Color(0xFF42A5F5),
    SpeedMetric.overheadDownload: Color(0xFFFF9800),
    SpeedMetric.overheadUpload: Color(0xFFFF7043),
    SpeedMetric.dhtDownload: Color(0xFF9C27B0),
    SpeedMetric.dhtUpload: Color(0xFFAB47BC),
    SpeedMetric.trackerDownload: Color(0xFF00BCD4),
    SpeedMetric.trackerUpload: Color(0xFF26C6DA),
  };

  Color _colorFor(SpeedMetric m) => _metricColors[m] ?? Colors.white;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final enabled = SpeedMetric.values.where((m) => enabledMetricNames.contains(m.name)).toList();
        final points = service.points;

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Transfer Speed', style: Manager.subtitleStyle),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    onPressed: () => onExpandedChanged(!expanded),
                  ),
                ],
              ),
              if (expanded) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 180,
                  child: _buildChart(enabled, points),
                ),
                const SizedBox(height: 8),
                _buildLegend(enabled, points),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildChart(List<SpeedMetric> enabled, List<SpeedDataPoint> points) {
    if (enabled.isEmpty) {
      return Center(
        child: Text(
          'No metrics selected',
          style: Manager.bodyStyle.copyWith(color: Colors.white.withValues(alpha: 0.4)),
        ),
      );
    }

    final now = DateTime.now();
    final timeframeSeconds = service.timeframeMinutes * 60.0;

    double peakY = 0;
    for (final p in points) {
      for (final m in enabled) {
        final v = (p.valueFor(m) ?? 0).toDouble();
        if (v > peakY) peakY = v;
      }
    }
    // When idle (all zeros) collapse to near-zero so only "0 B/s" shows.
    // Otherwise apply a 512 KB/s floor so the scale is readable.
    final double maxY = peakY == 0 ? 1.0 : math.max(peakY * 1.2, 512 * 1024.0);

    final bars = enabled.map((metric) {
      final List<FlSpot> spots;
      if (points.isEmpty) {
        spots = [FlSpot(-timeframeSeconds, 0), FlSpot(0, 0)];
      } else {
        spots = points.map((p) {
          final x = p.timestamp.difference(now).inMilliseconds / 1000.0;
          final y = (p.valueFor(metric) ?? 0).toDouble();
          return FlSpot(x, y);
        }).toList();
      }
      return LineChartBarData(
        spots: spots,
        color: _colorFor(metric),
        barWidth: 2,
        isCurved: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: _colorFor(metric).withValues(alpha: 0.07),
        ),
      );
    }).toList();

    final labelStyle = TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 10);
    final xInterval = math.max(60.0, timeframeSeconds / 5);

    return LineChart(
      LineChartData(
        minX: -timeframeSeconds,
        maxX: 0,
        minY: 0,
        maxY: maxY,
        lineBarsData: bars,
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 62,
              getTitlesWidget: (value, meta) {
                if (value == 0) return Text('0 B/s', style: labelStyle);
                if (maxY <= 1 || value >= meta.max * 0.95) return const SizedBox.shrink();
                return Text(fileTransferRate(value.toInt(), null, 0), style: labelStyle);
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: maxY <= 1 ? 1 : maxY / 4,
          verticalInterval: xInterval,
          getDrawingHorizontalLine: (_) => FlLine(color: Colors.white.withValues(alpha: 0.07), strokeWidth: 1),
          getDrawingVerticalLine: (_) => FlLine(color: Colors.white.withValues(alpha: 0.04), strokeWidth: 1),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF1E1E2E),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((s) {
                final metric = enabled[s.barIndex];
                return LineTooltipItem(
                  '${metric.label}\n${fileTransferRate(s.y.toInt())}',
                  TextStyle(color: _colorFor(metric), fontSize: 11, height: 1.5),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(List<SpeedMetric> enabled, List<SpeedDataPoint> points) {
    final lastPoint = points.isNotEmpty ? points.last : null;
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: enabled.map((metric) {
        final speed = lastPoint?.valueFor(metric) ?? 0;
        final color = _colorFor(metric);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(
              '${metric.label}: ${fileTransferRate(speed)}',
              style: Manager.miniBodyStyle.copyWith(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ],
        );
      }).toList(),
    );
  }
}
