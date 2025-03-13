import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// Model to hold report count data per day.
class ReportData {
  final DateTime date;
  final double count;
  ReportData(this.date, this.count);
}

class DisasterAnalyticsPage extends StatefulWidget {
  const DisasterAnalyticsPage({Key? key}) : super(key: key);

  @override
  _DisasterAnalyticsPageState createState() => _DisasterAnalyticsPageState();
}

class _DisasterAnalyticsPageState extends State<DisasterAnalyticsPage> {
  // Time period filter options.
  String _selectedPeriod = '30 days';
  final List<String> _periodOptions = ['7 days', '30 days', 'All Time'];

  // Determine the starting date based on the selected period.
  DateTime get _startDate {
    final now = DateTime.now();
    if (_selectedPeriod == '7 days') return now.subtract(const Duration(days: 7));
    if (_selectedPeriod == '30 days') return now.subtract(const Duration(days: 30));
    return DateTime(2000); // For "All Time", include all data.
  }

  // Helper: parse Firestore date field.
  DateTime? parseDate(dynamic dateField) {
    if (dateField is Timestamp) return dateField.toDate();
    if (dateField is String) {
      try {
        return DateTime.parse(dateField);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  double? _findMinX(List<List<FlSpot>> spotsLists) {
    double? min;
    for (var spots in spotsLists) {
      if (spots.isNotEmpty) {
        double localMin = spots.first.x;
        for (var spot in spots) {
          if (spot.x < localMin) localMin = spot.x;
        }
        if (min == null || localMin < min) min = localMin;
      }
    }
    return min;
  }

  double? _findMaxX(List<List<FlSpot>> spotsLists) {
    double? max;
    for (var spots in spotsLists) {
      if (spots.isNotEmpty) {
        double localMax = spots.first.x;
        for (var spot in spots) {
          if (spot.x > localMax) localMax = spot.x;
        }
        if (max == null || localMax > max) max = localMax;
      }
    }
    return max;
  }

  // Build the pie chart using overall counts.
  Widget _buildPieChart(Map<String, int> counts) {
    // Calculate the total for percentage labels.
    int total = counts.values.fold(0, (sum, count) => sum + count);
    // Create pie chart sections.
    List<PieChartSectionData> sections = [];
    // For each category, create a section only if there is data.
    counts.forEach((category, count) {
      if (count > 0) {
        Color color;
        String title;
        switch (category) {
          case 'Fire':
            color = Colors.red;
            title = 'Fire';
            break;
          case 'Flood':
            color = Colors.blue;
            title = 'Flood';
            break;
          case 'Landslide':
            color = Colors.green;
            title = 'Landslide';
            break;
          case 'Drought':
            color = Colors.orange;
            title = 'Drought';
            break;
          default:
            color = Colors.grey;
            title = category;
        }
        double percentage = (count / total) * 100;
        sections.add(PieChartSectionData(
          color: color,
          value: count.toDouble(),
          title: "${percentage.toStringAsFixed(0)}%",
          radius: 50,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ));
      }
    });

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double oneDayMillis = 86400000.0; // One day in milliseconds

    return Scaffold(
      backgroundColor: const Color.fromARGB(238, 255, 255, 255),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 9, 60, 83),
                    Color.fromARGB(255, 0, 97, 142),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
            title: const Text(
              "Disaster Analytics",
              style: TextStyle(
                fontFamily: 'proxima',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            automaticallyImplyLeading: false,
          ),
        ),
      ),
      body: Column(
        children: [
          // Top row with time period dropdown and legend.
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _selectedPeriod,
                  items: _periodOptions.map((String period) {
                    return DropdownMenuItem<String>(
                      value: period,
                      child: Text(period, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedPeriod = newValue;
                      });
                    }
                  },
                ),
                // Legend showing disaster categories.
                Row(
                  children: [
                    Row(
                      children: [
                        Container(width: 12, height: 12, color: Colors.red),
                        const SizedBox(width: 4),
                        const Text("Fire", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Row(
                      children: [
                        Container(width: 12, height: 12, color: Colors.blue),
                        const SizedBox(width: 4),
                        const Text("Flood", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Row(
                      children: [
                        Container(width: 12, height: 12, color: Colors.green),
                        const SizedBox(width: 4),
                        const Text("Landslide", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Row(
                      children: [
                        Container(width: 12, height: 12, color: Colors.orange),
                        const SizedBox(width: 4),
                        const Text("Drought", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Display the overall reports in a pie chart.
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('reports').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              // Aggregate overall counts for each disaster category.
              Map<String, int> overallCounts = {
                'Fire': 0,
                'Flood': 0,
                'Landslide': 0,
                'Drought': 0,
              };
              for (var doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                if (data['date'] == null || data['category'] == null) continue;
                DateTime? fullDate = parseDate(data['date']);
                if (fullDate == null) continue;
                DateTime date = DateTime(fullDate.year, fullDate.month, fullDate.day);
                if (date.isBefore(_startDate)) continue;
                String category = data['category'].toString();
                if (category == 'Fire') {
                  overallCounts['Fire'] = overallCounts['Fire']! + 1;
                } else if (category.toLowerCase() == 'flood') {
                  overallCounts['Flood'] = overallCounts['Flood']! + 1;
                } else if (category == 'Landslide') {
                  overallCounts['Landslide'] = overallCounts['Landslide']! + 1;
                } else if (category.toLowerCase() == 'drought') {
                  overallCounts['Drought'] = overallCounts['Drought']! + 1;
                }
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Overall Reports: ${overallCounts.values.fold(0, (sum, val) => sum + val)}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: _buildPieChart(overallCounts),
                    ),
                  ],
                ),
              );
            },
          ),
          // Expanded chart area with horizontal scrolling (detailed line chart).
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('reports').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                // Group reports by normalized date for each disaster category.
                Map<DateTime, int> fireCounts = {};
                Map<DateTime, int> floodCounts = {};
                Map<DateTime, int> landslideCounts = {};
                Map<DateTime, int> droughtCounts = {};

                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (data['date'] == null || data['category'] == null) continue;
                  DateTime? fullDate = parseDate(data['date']);
                  if (fullDate == null) continue;
                  // Normalize date.
                  DateTime date = DateTime(fullDate.year, fullDate.month, fullDate.day);
                  if (date.isBefore(_startDate)) continue;
                  String category = data['category'];
                  if (category == 'Fire') {
                    fireCounts[date] = (fireCounts[date] ?? 0) + 1;
                  } else if (category.toLowerCase() == 'flood') {
                    floodCounts[date] = (floodCounts[date] ?? 0) + 1;
                  } else if (category == 'Landslide') {
                    landslideCounts[date] = (landslideCounts[date] ?? 0) + 1;
                  } else if (category.toLowerCase() == 'drought') {
                    droughtCounts[date] = (droughtCounts[date] ?? 0) + 1;
                  }
                }

                // Convert maps to sorted ReportData lists.
                List<ReportData> fireData = fireCounts.entries.map((e) => ReportData(e.key, e.value.toDouble())).toList();
                List<ReportData> floodData = floodCounts.entries.map((e) => ReportData(e.key, e.value.toDouble())).toList();
                List<ReportData> landslideData = landslideCounts.entries.map((e) => ReportData(e.key, e.value.toDouble())).toList();
                List<ReportData> droughtData = droughtCounts.entries.map((e) => ReportData(e.key, e.value.toDouble())).toList();

                fireData.sort((a, b) => a.date.compareTo(b.date));
                floodData.sort((a, b) => a.date.compareTo(b.date));
                landslideData.sort((a, b) => a.date.compareTo(b.date));
                droughtData.sort((a, b) => a.date.compareTo(b.date));

                // Convert ReportData lists to FlSpot lists.
                List<FlSpot> fireSpots = fireData.map((d) => FlSpot(d.date.millisecondsSinceEpoch.toDouble(), d.count)).toList();
                List<FlSpot> floodSpots = floodData.map((d) => FlSpot(d.date.millisecondsSinceEpoch.toDouble(), d.count)).toList();
                List<FlSpot> landslideSpots = landslideData.map((d) => FlSpot(d.date.millisecondsSinceEpoch.toDouble(), d.count)).toList();
                List<FlSpot> droughtSpots = droughtData.map((d) => FlSpot(d.date.millisecondsSinceEpoch.toDouble(), d.count)).toList();

                double? minX = _findMinX([fireSpots, floodSpots, landslideSpots, droughtSpots]);
                double? maxX = _findMaxX([fireSpots, floodSpots, landslideSpots, droughtSpots]);
                minX ??= DateTime.now().millisecondsSinceEpoch.toDouble();
                maxX ??= DateTime.now().millisecondsSinceEpoch.toDouble();

                // Calculate width based on days range.
                final diffDays = (maxX - minX) / oneDayMillis;
                final screenWidth = MediaQuery.of(context).size.width;
                final chartWidth = max(screenWidth, diffDays * 50);

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      width: chartWidth,
                      height: 300,
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: 30,
                          lineTouchData: LineTouchData(enabled: true),
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: oneDayMillis,
                                getTitlesWidget: (value, meta) {
                                  DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                                  String formattedDate = DateFormat('MM/dd').format(date);
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      formattedDate,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: const Border(
                              bottom: BorderSide(color: Colors.black),
                              left: BorderSide(color: Colors.black),
                              right: BorderSide(color: Colors.transparent),
                              top: BorderSide(color: Colors.transparent),
                            ),
                          ),
                          minX: minX,
                          maxX: maxX,
                          lineBarsData: [
                            if (fireSpots.isNotEmpty)
                              LineChartBarData(
                                spots: fireSpots,
                                isCurved: false,
                                barWidth: 2,
                                color: Colors.red,
                                dotData: FlDotData(show: true),
                              ),
                            if (floodSpots.isNotEmpty)
                              LineChartBarData(
                                spots: floodSpots,
                                isCurved: false,
                                barWidth: 2,
                                color: Colors.blue,
                                dotData: FlDotData(show: true),
                              ),
                            if (landslideSpots.isNotEmpty)
                              LineChartBarData(
                                spots: landslideSpots,
                                isCurved: false,
                                barWidth: 2,
                                color: Colors.green,
                                dotData: FlDotData(show: true),
                              ),
                            if (droughtSpots.isNotEmpty)
                              LineChartBarData(
                                spots: droughtSpots,
                                isCurved: false,
                                barWidth: 2,
                                color: Colors.orange,
                                dotData: FlDotData(show: true),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: DisasterAnalyticsPage(),
  ));
}
