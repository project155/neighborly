import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AnalyticsPage extends StatefulWidget {
  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  // Statistics holders
  int totalReports = 0;
  int last24HoursReports = 0;
  List<FloodReport> hourlyReports = [];

  @override
  void initState() {
    super.initState();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    // Get timestamp for 24 hours ago
    final DateTime now = DateTime.now();
    final DateTime yesterday = now.subtract(Duration(hours: 24));

    // Query Firestore
    final QuerySnapshot reportSnapshot = await FirebaseFirestore.instance
        .collection('flood_reports')
        .where('timestamp', isGreaterThan: yesterday)
        .orderBy('timestamp', descending: true)
        .get();

    // Process the data
    final List<FloodReport> reports = reportSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return FloodReport(
        timestamp: (data['timestamp'] as Timestamp).toDate(),
        severity: data['severity'] ?? 0,
        location: data['location'] ?? '',
      );
    }).toList();

    // Calculate statistics
    setState(() {
      totalReports = reports.length;
      last24HoursReports = reports.where((report) => 
        report.timestamp.isAfter(yesterday)
      ).length;
      hourlyReports = reports;
    });
  }

  List<BarChartGroupData> _generateHourlyData() {
    // Group reports by hour
    Map<int, int> hourlyCount = {};
    final now = DateTime.now();
    
    for (int i = 0; i < 24; i++) {
      hourlyCount[i] = 0;
    }

    for (var report in hourlyReports) {
      final hour = report.timestamp.hour;
      hourlyCount[hour] = (hourlyCount[hour] ?? 0) + 1;
    }

    // Create bar chart data
    return hourlyCount.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: Colors.blue,
            width: 16,
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchAnalytics,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: _StatisticCard(
                    title: 'Total Reports',
                    value: totalReports.toString(),
                    icon: Icons.assessment,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _StatisticCard(
                    title: 'Last 24 Hours',
                    value: last24HoursReports.toString(),
                    icon: Icons.timer,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            
            // Hourly Reports Chart
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hourly Flood Reports',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: hourlyReports.length.toDouble(),
                          barGroups: _generateHourlyData(),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value % 6 == 0) {
                                    return Text('${value.toInt()}:00');
                                  }
                                  return Text('');
                                },
                                reservedSize: 30,
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
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          gridData: FlGridData(show: true),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Statistic Card Widget
class _StatisticCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatisticCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.blue, size: 24),
            SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Model class for Flood Report
class FloodReport {
  final DateTime timestamp;
  final int severity;
  final String location;

  FloodReport({
    required this.timestamp,
    required this.severity,
    required this.location,
  });
}