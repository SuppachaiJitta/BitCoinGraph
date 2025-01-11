import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GraphChart extends StatelessWidget {
  final RxList<dynamic> data;
  final double minY;
  final double maxY;
  final Function(FlTouchEvent, LineTouchResponse?)? touchCallback;

  const GraphChart({
    required this.data,
    required this.minY,
    required this.maxY,
    this.touchCallback,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(
              color: Colors.black,
            ),
            left: BorderSide(
              color: Colors.black,
            ),
          ),
        ),
        minX: 0,
        maxX: data.length.toDouble() - 1,
        minY: minY * 0.99,
        maxY: maxY * 1.01,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: const LineTouchTooltipData(
            tooltipBgColor: Colors.white,
          ),
          touchCallback: touchCallback,
        ),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.rate);
            }).toList(),
            color: Colors.green,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 2,
                color: Colors.green,
                strokeWidth: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
