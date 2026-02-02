import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';

class ActivitiesChart extends StatefulWidget {
  final List<Activity> activities;

  const ActivitiesChart({super.key, required this.activities});

  @override
  State<ActivitiesChart> createState() => _ActivitiesChartState();
}

class _ActivitiesChartState extends State<ActivitiesChart> {
  List<_WeeklyStats> _weeklyData = [];

  int _selectedIndex = 11;

  @override
  void initState() {
    super.initState();
    _processData();
  }

  @override
  void didUpdateWidget(covariant ActivitiesChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activities != widget.activities) {
      _processData();
    }
  }

  void _processData() {
    final now = DateTime.now();
    final currentWeekStart = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - 1),
    );

    List<_WeeklyStats> tempStats = [];

    for (int i = 11; i >= 0; i--) {
      final weekStart = currentWeekStart.subtract(Duration(days: i * 7));
      final weekEnd = weekStart.add(
        const Duration(days: 6, hours: 23, minutes: 59),
      );

      final activitiesInWeek = widget.activities.where((act) {
        return act.startTime.isAfter(weekStart) &&
            act.startTime.isBefore(weekEnd);
      });

      double dist = 0;
      int time = 0;
      double elev = 0;

      for (var act in activitiesInWeek) {
        dist += act.distanceMeters;
        time += act.movingTime.inSeconds;
        elev += act.elevationGain;
      }

      tempStats.add(
        _WeeklyStats(
          start: weekStart,
          end: weekEnd,
          totalDistance: dist,
          totalSeconds: time,
          elevation: elev,
        ),
      );
    }

    setState(() {
      _weeklyData = tempStats;
      _selectedIndex = 11;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_weeklyData.isEmpty) return const SizedBox();

    final selectedWeek = _weeklyData[_selectedIndex];

    return Column(
      children: [
        _buildHeader(selectedWeek),

        const SizedBox(height: 20),

        SizedBox(
          height: 220,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: LineChart(
              _buildChartData(),
              duration: const Duration(milliseconds: 250),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(_WeeklyStats stats) {
    final dateFormatter = DateFormat('d MMM', 'fr_FR');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "${dateFormatter.format(stats.start)} - ${dateFormatter.format(stats.end)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                "Distance",
                "${(stats.totalDistance / 1000).toStringAsFixed(2)} km",
                true,
              ),
              _buildStatItem(
                "Temps",
                _formatDuration(stats.totalSeconds),
                false,
              ),
              _buildStatItem("Dénivelé", "${stats.elevation.toInt()} m", false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isMain) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  LineChartData _buildChartData() {
    double maxDist = 0;
    for (var w in _weeklyData) {
      if (w.totalDistance > maxDist) maxDist = w.totalDistance;
    }
    double maxY = (maxDist / 1000) * 1.2;
    if (maxY == 0) maxY = 10;

    return LineChartData(
      lineTouchData: LineTouchData(
        touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
          if (!event.isInterestedForInteractions ||
              touchResponse == null ||
              touchResponse.lineBarSpots == null) {
            return;
          }
          final index = touchResponse.lineBarSpots!.first.x.toInt();
          if (index != _selectedIndex && index >= 0 && index < 12) {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (spots) => spots.map((e) => null).toList(),
        ),
      ),

      gridData: FlGridData(
        show: true,
        drawHorizontalLine: false,
        drawVerticalLine: true,
        verticalInterval: 1,
        getDrawingVerticalLine: (value) =>
            const FlLine(color: Colors.black12, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            maxIncluded: false,
            interval: maxY / 2,
            getTitlesWidget: (value, meta) {
              if (value == 0) return const Text("");
              return Text(
                "${value.toInt()} km",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < _weeklyData.length) {
                final date = _weeklyData[index].start;
                bool showMonth = index == 0 || date.day <= 7;

                if (showMonth) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      DateFormat.MMM('fr_FR').format(date).toUpperCase(),
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  );
                }
              }
              return const Text("");
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),

      extraLinesData: ExtraLinesData(
        verticalLines: [
          VerticalLine(
            x: _selectedIndex.toDouble(),
            color: Colors.black87,
            strokeWidth: 2,
            dashArray: null,
          ),
        ],
      ),

      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: _weeklyData.asMap().entries.map((e) {
            return FlSpot(e.key.toDouble(), e.value.totalDistance / 1000);
          }).toList(),
          isCurved: false,
          color: Colors.deepOrange,
          barWidth: 2,
          isStrokeCapRound: true,

          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: Colors.deepOrange,
              );
            },
          ),

          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.deepOrange.withOpacity(0.5),
                Colors.deepOrange.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) return "$h h $m min";
    return "$m min ${seconds % 60} s";
  }
}

class _WeeklyStats {
  final DateTime start;
  final DateTime end;
  final double totalDistance;
  final int totalSeconds;
  final double elevation;

  _WeeklyStats({
    required this.start,
    required this.end,
    required this.totalDistance,
    required this.totalSeconds,
    required this.elevation,
  });
}
