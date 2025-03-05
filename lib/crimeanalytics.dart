import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// Extension to add a 'capitalize' method to String.
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}

// Model to hold report count data per day.
class ReportData {
  final DateTime date;
  final double count;
  ReportData(this.date, this.count);
}

class CrimeAnalyticsPage extends StatefulWidget {
  const CrimeAnalyticsPage({Key? key}) : super(key: key);

  @override
  _CrimeAnalyticsPageState createState() => _CrimeAnalyticsPageState();
}

class _CrimeAnalyticsPageState extends State<CrimeAnalyticsPage> {
  // Time period filter options.
  String _selectedPeriod = '7 days';
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

  // Helper to build a legend item.
  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // Build the pie chart that displays overall counts.
  Widget _buildPieChart(Map<String, int> counts) {
    int total = counts.values.fold(0, (sum, count) => sum + count);
    List<PieChartSectionData> sections = [];
    counts.forEach((category, count) {
      if (count > 0) {
        Color color;
        String title;
        switch (category) {
          case 'Sexual Abuse':
            color = Colors.purple;
            title = 'Sexual Abuse';
            break;
          case 'Narcotics':
            color = Colors.indigo;
            title = 'Narcotics';
            break;
          case 'Alcohol':
            color = Colors.amber;
            title = 'Alcohol';
            break;
          case 'Animal Abuse':
            color = Colors.teal;
            title = 'Animal Abuse';
            break;
          case 'Bribery':
            color = Colors.cyan;
            title = 'Bribery';
            break;
          case 'Theft':
            color = Colors.grey;
            title = 'Theft';
            break;
          case 'Child Abuse':
            color = Colors.pink;
            title = 'Child Abuse';
            break;
          default:
            color = Colors.black;
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
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: const Text(
          "Crime Analytics",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
      ),
      body: Column(
        children: [
          // Top section: time period dropdown and legend.
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    _buildLegendItem(color: Colors.purple, label: "Sexual Abuse"),
                    _buildLegendItem(color: Colors.indigo, label: "Narcotics"),
                    _buildLegendItem(color: Colors.amber, label: "Alcohol"),
                    _buildLegendItem(color: Colors.teal, label: "Animal Abuse"),
                    _buildLegendItem(color: Colors.cyan, label: "Bribery"),
                    _buildLegendItem(color: Colors.grey, label: "Theft"),
                    _buildLegendItem(color: Colors.pink, label: "Child Abuse"),
                  ],
                ),
              ],
            ),
          ),
          // Overall reports pie chart.
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('reports').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();

              // Aggregate overall counts for each crime category.
              Map<String, int> overallCounts = {
                'Sexual Abuse': 0,
                'Narcotics': 0,
                'Alcohol': 0,
                'Animal Abuse': 0,
                'Bribery': 0,
                'Theft': 0,
                'Child Abuse': 0,
              };

              for (var doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                if (data['date'] == null || data['category'] == null) continue;
                DateTime? fullDate = parseDate(data['date']);
                if (fullDate == null) continue;
                DateTime date = DateTime(fullDate.year, fullDate.month, fullDate.day);
                if (date.isBefore(_startDate)) continue;
                String category = data['category'].toString();
                // Use the extension to capitalize for consistency.
                String formattedCategory = category.toLowerCase().capitalize();
                if (overallCounts.containsKey(formattedCategory)) {
                  overallCounts[formattedCategory] = overallCounts[formattedCategory]! + 1;
                }
              }
              int totalOverall = overallCounts.values.fold(0, (sum, val) => sum + val);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Overall Reports: $totalOverall",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: _buildPieChart(overallCounts),
                    ),
                  ],
                ),
              );
            },
          ),
          // Detailed line chart.
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('reports').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                // Group reports by normalized date for each crime category.
                Map<DateTime, int> sexualAbuseCounts = {};
                Map<DateTime, int> narcoticsCounts = {};
                Map<DateTime, int> alcoholCounts = {};
                Map<DateTime, int> animalAbuseCounts = {};
                Map<DateTime, int> briberyCounts = {};
                Map<DateTime, int> theftCounts = {};
                Map<DateTime, int> childAbuseCounts = {};

                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (data['date'] == null || data['category'] == null) continue;
                  DateTime? fullDate = parseDate(data['date']);
                  if (fullDate == null) continue;
                  DateTime date = DateTime(fullDate.year, fullDate.month, fullDate.day);
                  if (date.isBefore(_startDate)) continue;
                  String category = data['category'].toString().toLowerCase();
                  if (category == "sexual abuse") {
                    sexualAbuseCounts[date] = (sexualAbuseCounts[date] ?? 0) + 1;
                  } else if (category == "narcotics") {
                    narcoticsCounts[date] = (narcoticsCounts[date] ?? 0) + 1;
                  } else if (category == "alcohol") {
                    alcoholCounts[date] = (alcoholCounts[date] ?? 0) + 1;
                  } else if (category == "animal abuse") {
                    animalAbuseCounts[date] = (animalAbuseCounts[date] ?? 0) + 1;
                  } else if (category == "bribery") {
                    briberyCounts[date] = (briberyCounts[date] ?? 0) + 1;
                  } else if (category == "theft") {
                    theftCounts[date] = (theftCounts[date] ?? 0) + 1;
                  } else if (category == "child abuse") {
                    childAbuseCounts[date] = (childAbuseCounts[date] ?? 0) + 1;
                  }
                }

                // Convert maps into sorted lists of ReportData.
                List<ReportData> sexualAbuseData = sexualAbuseCounts.entries.map((e) => ReportData(e.key, e.value.toDouble())).toList();
                List<ReportData> narcoticsData = narcoticsCounts.entries.map((e) => ReportData(e.key, e.value.toDouble())).toList();
                List<ReportData> alcoholData = alcoholCounts.entries.map((e) => ReportData(e.key, e.value.toDouble())).toList();
                List<ReportData> animalAbuseData = animalAbuseCounts.entries.map((e) => ReportData(e.key, e.value.toDouble())).toList();
                List<ReportData> briberyData = briberyCounts.entries.map((e) => ReportData(e.key, e.value.toDouble())).toList();
                List<ReportData> theftData = theftCounts.entries.map((e) => ReportData(e.key, e.value.toDouble())).toList();
                List<ReportData> childAbuseData = childAbuseCounts.entries.map((e) => ReportData(e.key, e.value.toDouble())).toList();

                sexualAbuseData.sort((a, b) => a.date.compareTo(b.date));
                narcoticsData.sort((a, b) => a.date.compareTo(b.date));
                alcoholData.sort((a, b) => a.date.compareTo(b.date));
                animalAbuseData.sort((a, b) => a.date.compareTo(b.date));
                briberyData.sort((a, b) => a.date.compareTo(b.date));
                theftData.sort((a, b) => a.date.compareTo(b.date));
                childAbuseData.sort((a, b) => a.date.compareTo(b.date));

                // Convert ReportData lists to FlSpot lists.
                List<FlSpot> sexualAbuseSpots = sexualAbuseData.map((d) => FlSpot(d.date.millisecondsSinceEpoch.toDouble(), d.count)).toList();
                List<FlSpot> narcoticsSpots = narcoticsData.map((d) => FlSpot(d.date.millisecondsSinceEpoch.toDouble(), d.count)).toList();
                List<FlSpot> alcoholSpots = alcoholData.map((d) => FlSpot(d.date.millisecondsSinceEpoch.toDouble(), d.count)).toList();
                List<FlSpot> animalAbuseSpots = animalAbuseData.map((d) => FlSpot(d.date.millisecondsSinceEpoch.toDouble(), d.count)).toList();
                List<FlSpot> briberySpots = briberyData.map((d) => FlSpot(d.date.millisecondsSinceEpoch.toDouble(), d.count)).toList();
                List<FlSpot> theftSpots = theftData.map((d) => FlSpot(d.date.millisecondsSinceEpoch.toDouble(), d.count)).toList();
                List<FlSpot> childAbuseSpots = childAbuseData.map((d) => FlSpot(d.date.millisecondsSinceEpoch.toDouble(), d.count)).toList();

                double? minX = _findMinX([
                  sexualAbuseSpots,
                  narcoticsSpots,
                  alcoholSpots,
                  animalAbuseSpots,
                  briberySpots,
                  theftSpots,
                  childAbuseSpots,
                ]);
                double? maxX = _findMaxX([
                  sexualAbuseSpots,
                  narcoticsSpots,
                  alcoholSpots,
                  animalAbuseSpots,
                  briberySpots,
                  theftSpots,
                  childAbuseSpots,
                ]);
                minX ??= DateTime.now().millisecondsSinceEpoch.toDouble();
                maxX ??= DateTime.now().millisecondsSinceEpoch.toDouble();

                // Calculate chart width based on days range.
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
                          maxY: 10,
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
                            if (sexualAbuseSpots.isNotEmpty)
                              LineChartBarData(
                                spots: sexualAbuseSpots,
                                isCurved: false,
                                barWidth: 2,
                                color: Colors.purple,
                                dotData: FlDotData(show: true),
                              ),
                            if (narcoticsSpots.isNotEmpty)
                              LineChartBarData(
                                spots: narcoticsSpots,
                                isCurved: false,
                                barWidth: 2,
                                color: Colors.indigo,
                                dotData: FlDotData(show: true),
                              ),
                            if (alcoholSpots.isNotEmpty)
                              LineChartBarData(
                                spots: alcoholSpots,
                                isCurved: false,
                                barWidth: 2,
                                color: Colors.amber,
                                dotData: FlDotData(show: true),
                              ),
                            if (animalAbuseSpots.isNotEmpty)
                              LineChartBarData(
                                spots: animalAbuseSpots,
                                isCurved: false,
                                barWidth: 2,
                                color: Colors.teal,
                                dotData: FlDotData(show: true),
                              ),
                            if (briberySpots.isNotEmpty)
                              LineChartBarData(
                                spots: briberySpots,
                                isCurved: false,
                                barWidth: 2,
                                color: Colors.cyan,
                                dotData: FlDotData(show: true),
                              ),
                            if (theftSpots.isNotEmpty)
                              LineChartBarData(
                                spots: theftSpots,
                                isCurved: false,
                                barWidth: 2,
                                color: Colors.grey,
                                dotData: FlDotData(show: true),
                              ),
                            if (childAbuseSpots.isNotEmpty)
                              LineChartBarData(
                                spots: childAbuseSpots,
                                isCurved: false,
                                barWidth: 2,
                                color: Colors.pink,
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
    home: CrimeAnalyticsPage(),
  ));
}
