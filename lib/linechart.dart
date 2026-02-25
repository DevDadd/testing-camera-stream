import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LineChartDemo extends StatelessWidget {
  LineChartDemo({super.key});

  final List<ChartData> data = [
    ChartData('T1', -250),
    ChartData('T2', -100),
    ChartData('T3', 50),
    ChartData('T4', 200),
    ChartData('T5', 300),
  ];

  final String unitStr = "tr";

  NumericAxis buildYAxis() {
    return NumericAxis(
      minimum: -400,
      maximum: 400,
      interval: 250,
      axisLabelFormatter: (AxisLabelRenderDetails details) {
        final axis = details.axis;
        final value = details.value;
        String labelText = details.text;

        const epsilon = 1e-6;

        final min = axis.visibleRange!.minimum;
        final max = axis.visibleRange!.maximum;

        final hasZeroTick =
            ((0 - min) / axis.visibleInterval).abs() % 1 < epsilon;;

        final firstTick = min;

        if (hasZeroTick) {
          if (value.abs() < epsilon) {
            labelText += " $unitStr";
          }
        } else {
          if ((value - firstTick).abs() < epsilon) {
            labelText += " $unitStr";
          }
        }

        return ChartAxisLabel(
          labelText,
          const TextStyle(fontSize: 12),
        );
      },
    );
  }

  LineSeries<ChartData, String> buildSeries() {
    return LineSeries<ChartData, String>(
      dataSource: data,
      xValueMapper: (ChartData data, _) => data.x,
      yValueMapper: (ChartData data, _) => data.y,
      markerSettings: const MarkerSettings(isVisible: true),
    );
  }

  Widget buildChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      primaryYAxis: buildYAxis(),
      series: <LineSeries<ChartData, String>>[
        buildSeries(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(child: buildChart()),
              const SizedBox(height: 24),
              Expanded(child: buildChart()), // 🔥 Chart thứ 2
            ],
          ),
        ),
      ),
    );
  }
}

class ChartData {
  final String x;
  final double y;

  ChartData(this.x, this.y);
}