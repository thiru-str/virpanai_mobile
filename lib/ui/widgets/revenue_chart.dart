import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/dashboard_response.dart';

class TodayRevenueChart extends StatelessWidget {
  final List<GraphDatum> data;
  final String heading;
  final double? yMax;

  const TodayRevenueChart({
    super.key,
    required this.data,
    this.heading = 'Today Revenue',
    this.yMax,
  });

  @override
  Widget build(BuildContext context) {
    final values = data.map((e) => (e.value ?? 0).toDouble()).toList();
    final maxVal = values.isEmpty ? 0.0 : values.reduce((a, b) => a > b ? a : b);
    final computedMax =
    (maxVal <= 0) ? 1000.0 : (((maxVal + 1) / 500).ceil() * 500).toDouble();

    return SfCartesianChart(
      title: ChartTitle(text: heading),
      primaryXAxis: CategoryAxis(majorGridLines: const MajorGridLines(width: 0)),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: yMax ?? computedMax,
        interval: 1000,
        numberFormat: NumberFormat.compactCurrency(locale: 'en_IN', symbol: '₹ '),
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        canShowMarker: true,
        // fallback to formatted value if label is null
        // (Syncfusion uses this format string when no builder is given)
        format: 'point.x : ₹ point.y',
      ),
      // If you want to show the API's `label` exactly, uncomment this:
      // onTooltipRender: (TooltipArgs args) {
      //   final i = args.pointIndex ?? 0;
      //   final p = data[i];
      //   args.text = '${p.title ?? ''}\n${p.label ?? '₹ ${(p.value ?? 0).toStringAsFixed(0)}'}';
      // },

      series: <CartesianSeries>[
        SplineAreaSeries<GraphDatum, String>(
          dataSource: data,
          xValueMapper: (p, _) => p.title ?? '',
          yValueMapper: (p, _) => (p.value ?? 0).toDouble(),
          markerSettings: const MarkerSettings(isVisible: true, width: 8, height: 8),
          borderWidth: 2,
          borderColor: Color(0xFF0B8F79),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B8F79), Color(0x330B8F79)],
          ),
        ),
      ],
    );
  }
}
