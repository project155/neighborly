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

class PublicIssuesAnalyticsPage extends StatefulWidget {
  const PublicIssuesAnalyticsPage({Key? key}) : super(key: key);

  @override
  _PublicIssuesAnalyticsPageState createState() => _PublicIssuesAnalyticsPageState();
}

class _PublicIssuesAnalyticsPageState extends State<PublicIssuesAnalyticsPage> {
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

  // Helper method to build a legend item.
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

  // Build the pie chart using overall counts.
  Widget _buildPieChart(Map<String, int> counts) {
    int total = counts.values.fold(0, (sum, count) => sum + count);
    List<PieChartSectionData> sections = [];
    counts.forEach((category, count) {
      if (count > 0) {
        Color color;
        switch (category) {
          case 'Road Incidents':
            color = Colors.deepOrange;
            break;
          case 'Eco Hazard':
            color = Colors.lightGreen;
            break;
          case 'Food Safety':
            color = Colors.deepPurple;
            break;
          case 'Hygiene Issues':
            color = Colors.blueGrey;
            break;
          case 'Infrastructure Issues':
            color = Colors.teal;
            break;
          case 'Transportation':
            color = Colors.indigo;
            break;
          default:
            color = Colors.black;
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
              "Public Issues Analytics",
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
          // Top section: time period dropdown and wrap-based legend.
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
                    _buildLegendItem(color: Colors.deepOrange, label: "Road Incidents"),
                    _buildLegendItem(color: Colors.lightGreen, label: "Eco Hazard"),
                    _buildLegendItem(color: Colors.deepPurple, label: "Food Safety"),
                    _buildLegendItem(color: Colors.blueGrey, label: "Hygiene Issues"),
                    _buildLegendItem(color: Colors.teal, label: "Infrastructure Issues"),
                    _buildLegendItem(color: Colors.indigo, label: "Transportation"),
                  ],
                ),
              ],
            ),
          ),
          // Overall reports displayed as a pie chart.
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('reports').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();

              // Aggregate overall counts for each public issue.
              Map<String, int> overallCounts = {
                'Road Incidents': 0,
                'Eco Hazard': 0,
                'Food Safety': 0,
                'Hygiene Issues': 0,
                'Infrastructure Issues': 0,
                'Transportation': 0,
              };

              for (var doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                if (data['date'] == null || data['category'] == null) continue;
                DateTime? fullDate = parseDate(data['date']);
                if (fullDate == null) continue;
                DateTime date = DateTime(fullDate.year, fullDate.month, fullDate.day);
                if (date.isBefore(_startDate)) continue;
                String category = data['category'].toString().toLowerCase();
                if (category == "road incidents") {
                  overallCounts['Road Incidents'] = overallCounts['Road Incidents']! + 1;
                } else if (category == "eco hazard") {
                  overallCounts['Eco Hazard'] = overallCounts['Eco Hazard']! + 1;
                } else if (category == "food safety") {
                  overallCounts['Food Safety'] = overallCounts['Food Safety']! + 1;
                } else if (category == "hygiene issues") {
                  overallCounts['Hygiene Issues'] = overallCounts['Hygiene Issues']! + 1;
                } else if (category == "infrastructure issues") {
                  overallCounts['Infrastructure Issues'] = overallCounts['Infrastructure Issues']! + 1;
                } else if (category == "transportation") {
                  overallCounts['Transportation'] = overallCounts['Transportation']! + 1;
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
          // Expanded chart area with horizontal scrolling (detailed line chart).
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('reports').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                // Create maps for each public issue category.
                Map<DateTime, int> roadIncidentsCounts = {};
                Map<DateTime, int> ecoHazardCounts = {};
                Map<DateTime, int> foodSafetyCounts = {};
                Map<DateTime, int> hygieneIssuesCounts = {};
                Map<DateTime, int> infrastructureIssuesCounts = {};
                Map<DateTime, int> transportationCounts = {};

                // Loop through each document.
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (data['date'] == null || data['category'] == null) continue;
                  DateTime? fullDate = parseDate(data['date']);
                  if (fullDate == null) continue;
                  DateTime date = DateTime(fullDate.year, fullDate.month, fullDate.day);
                  if (date.isBefore(_startDate)) continue;
                  String category = data['category'].toString().toLowerCase();
                  if (category == "road incidents") {
                    roadIncidentsCounts[date] = (roadIncidentsCounts[date] ?? 0) + 1;
                  } else if (category == "eco hazard") {
                    ecoHazardCounts[date] = (ecoHazardCounts[date] ?? 0) + 1;
                  } else if (category == "food safety") {
                    foodSafetyCounts[date] = (foodSafetyCounts[date] ?? 0) + 1;
                  } else if (category == "hygiene issues") {
                    hygieneIssuesCounts[date] = (hygieneIssuesCounts[date] ?? 0) + 1;
                  } else if (category == "infrastructure issues") {
                    infrastructureIssuesCounts[date] = (infrastructureIssuesCounts[date] ?? 0) + 1;
                  } else if (category == "transportation") {
                    transportationCounts[date] = (transportationCounts[date] ?? 0) + 1;
                  }
                }

                // Convert maps into sorted lists of ReportData.
                List<ReportData> roadIncidentsData = roadIncidentsCounts.entries.map((e) => ReportData(e.key, e.value.toDouble())).toList();
                List<ReportData> ecoHazardData = ecoHazardCounts.entries.map((e) => ReportData(e.key, e.value.toDouble())).toList();
                List<ReportData> foodSafetyData = foodSafetyCounts.entries.map((e) => ReportData(e.key, e.value.toDouble())).toList();
                List<ReportData> hygieneIssuesData = hygieneIssuesCounts.entries.map((e) => ReportData(e.key, e.value.toDouble())).toList();
                List<ReportData> infrastructureIssuesData = infrastructureIssuesCounts.entries.map((e) => ReportData(e.key, e.value.toDouble())).toList();
                List<ReportData> transportationData = transportationCounts.entries.map((e) => ReportData(e.key, e.value.toDouble())).toList();

                roadIncidentsData.sort((a, b) => a.date.compareTo(b.date));
                ecoHazardData.sort((a, b) => a.date.compareTo(b.date));
                foodSafetyData.sort((a, b) => a.date.compareTo(b.date));
                hygieneIssuesData.sort((a, b) => a.date.compareTo(b.date));
                infrastructureIssuesData.sort((a, b) => a.date.compareTo(b.date));
                transportationData.sort((a, b) => a.date.compareTo(b.date));

                // Convert ReportData to FlSpot (x: epoch ms, y: count).
                List<FlSpot> roadIncidentsSpots = roadIncidentsData.map((d) => FlSpot(d.date.millisecondsSinceEpoch.toDouble(), d.count)).toList();
                List<FlSpot> ecoHazardSpots = ecoHazardData.map((d) => FlSpot(d.date.millisecondsSinceEpoch.toDouble(), d.count)).toList();
                List<FlSpot> foodSafetySpots = foodSafetyData.map((d) => FlSpot(d.date.millisecondsSinceEpoch.toDouble(), d.count)).toList();
                List<FlSpot> hygieneIssuesSpots = hygieneIssuesData.map((d) => FlSpot(d.date.millisecondsSinceEpoch.toDouble(), d.count)).toList();
                List<FlSpot> infrastructureIssuesSpots = infrastructureIssuesData.map((d) => FlSpot(d.date.millisecondsSinceEpoch.toDouble(), d.count)).toList();
                List<FlSpot> transportationSpots = transportationData.map((d) => FlSpot(d.date.millisecondsSinceEpoch.toDouble(), d.count)).toList();

                double? minX = _findMinX([
                  roadIncidentsSpots,
                  ecoHazardSpots,
                  foodSafetySpots,
                  hygieneIssuesSpots,
                  infrastructureIssuesSpots,
                  transportationSpots,
                ]);
                double? maxX = _findMaxX([
                  roadIncidentsSpots,
                  ecoHazardSpots,
                  foodSafetySpots,
                  hygieneIssuesSpots,
                  infrastructureIssuesSpots,
                  transportationSpots,
                ]);
                minX ??= DateTime.now().millisecondsSinceEpoch.toDouble();
                maxX ??= DateTime.now().millisecondsSinceEpoch.toDouble();

                // Calculate chart width based on the date range.
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
                            if (roadIncidentsSpots.isNotEmpty)
                              LineChartBarData(
                                spots: roadIncidentsSpots,
                                isCurved: false,
                                barWidth: 2,
                                color: Colors.deepOrange,
                                dotData: FlDotData(show: true),
                              ),
                            if (ecoHazardSpots.isNotEmpty)
                              LineChartBarData(
                                spots: ecoHazardSpots,
                                isCurved: false,
                                barWidth: 2,
                                color: Colors.lightGreen,
                                dotData: FlDotData(show: true),
                              ),
                            if (foodSafetySpots.isNotEmpty)
                              LineChartBarData(
                                spots: foodSafetySpots,
                                isCurved: false,
                                barWidth: 2,
                                color: Colors.deepPurple,
                                dotData: FlDotData(show: true),
                              ),
                            if (hygieneIssuesSpots.isNotEmpty)
                              LineChartBarData(
                                spots: hygieneIssuesSpots,
                                isCurved: false,
                                barWidth: 2,
                                color: Colors.blueGrey,
                                dotData: FlDotData(show: true),
                              ),
                            if (infrastructureIssuesSpots.isNotEmpty)
                              LineChartBarData(
                                spots: infrastructureIssuesSpots,
                                isCurved: false,
                                barWidth: 2,
                                color: Colors.teal,
                                dotData: FlDotData(show: true),
                              ),
                            if (transportationSpots.isNotEmpty)
                              LineChartBarData(
                                spots: transportationSpots,
                                isCurved: false,
                                barWidth: 2,
                                color: Colors.indigo,
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
    home: PublicIssuesAnalyticsPage(),
  ));
}
