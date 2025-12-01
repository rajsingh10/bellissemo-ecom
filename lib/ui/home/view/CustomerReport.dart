// Flutter UI: Customer Reporting
// File: customer_reporting_page.dart
// Dependencies (pubspec.yaml):
//   flutter:
//     sdk: flutter
//   intl: ^0.18.1
//   fl_chart: ^0.60.0

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

enum PeriodType { monthly, quarterly, yearly }

class CustomerReportingPage extends StatefulWidget {
  const CustomerReportingPage({Key? key}) : super(key: key);

  @override
  State<CustomerReportingPage> createState() => _CustomerReportingPageState();
}

class _CustomerReportingPageState extends State<CustomerReportingPage> {
  DateTimeRange? _range;
  PeriodType _period = PeriodType.monthly;
  bool _compareMode = false;

  // Example mock data: customer -> list of dated sales
  final Map<String, List<DatedSale>> _mockSales = _createMockData();

  Map<String, double> _aggregated = {};
  Map<String, List<AggregatePoint>> _series = {};

  final DateFormat _labelFmt = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    // default: last 90 days
    final now = DateTime.now();
    _range = DateTimeRange(start: now.subtract(const Duration(days: 90)), end: now);
    _applyFilter();
  }

  void _applyFilter() {
    final r = _range;
    if (r == null) return;
    final agg = <String, double>{};
    final series = <String, List<AggregatePoint>>{};

    for (final entry in _mockSales.entries) {
      final name = entry.key;
      final filtered = entry.value.where((s) => !(s.date.isBefore(r.start) || s.date.isAfter(r.end))).toList();
      final points = _aggregateByPeriod(filtered, _period);
      final total = points.fold<double>(0.0, (p, e) => p + e.amount);
      agg[name] = total;
      series[name] = points;
    }

    setState(() {
      _aggregated = agg;
      _series = series;
    });
  }

  static Map<String, List<AggregatePoint>> _mockAggregateForDemo(Map<String, List<DatedSale>> data, PeriodType period) {
    final map = <String, List<AggregatePoint>>{};
    for (final e in data.entries) {
      map[e.key] = _aggregateByPeriod(e.value, period);
    }
    return map;
  }

  static List<AggregatePoint> _aggregateByPeriod(List<DatedSale> sales, PeriodType period) {
    if (sales.isEmpty) return [];

    // Group by key string based on period
    final grouped = <String, double>{};
    final parseKeyToDate = <String, DateTime>{};

    for (final s in sales) {
      final key = _periodKey(s.date, period);
      grouped[key] = (grouped[key] ?? 0.0) + s.amount;
      parseKeyToDate[key] = _periodKeyToDate(s.date, period);
    }

    final points = grouped.entries.map((e) => AggregatePoint(date: parseKeyToDate[e.key]!, amount: e.value)).toList();
    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }

  static String _periodKey(DateTime d, PeriodType p) {
    switch (p) {
      case PeriodType.monthly:
        return '${d.year}-${d.month.toString().padLeft(2, '0')}';
      case PeriodType.quarterly:
        final q = ((d.month - 1) ~/ 3) + 1;
        return '${d.year}-Q$q';
      case PeriodType.yearly:
        return '${d.year}';
    }
  }

  static DateTime _periodKeyToDate(DateTime d, PeriodType p) {
    switch (p) {
      case PeriodType.monthly:
        return DateTime(d.year, d.month, 1);
      case PeriodType.quarterly:
        final q = ((d.month - 1) ~/ 3) + 1;
        return DateTime(d.year, (q - 1) * 3 + 1, 1);
      case PeriodType.yearly:
        return DateTime(d.year, 1, 1);
    }
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final initial = _range ?? DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 1),
      initialDateRange: initial,
    );
    if (picked != null) {
      setState(() => _range = picked);
      _applyFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedCustomers = _aggregated.keys.toList()
      ..sort((a, b) => _aggregated[b]!.compareTo(_aggregated[a]!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Reporting'),
        actions: [
          IconButton(
            tooltip: 'Export CSV',
            icon: const Icon(Icons.download),
            onPressed: () {
              // Hook: export functionality
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export not implemented in demo')));
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildControls(),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: sortedCustomers.length,
                itemBuilder: (context, idx) {
                  final name = sortedCustomers[idx];
                  final total = _aggregated[name] ?? 0.0;
                  final points = _series[name] ?? [];
                  return _CustomerCard(name: name, total: total, points: points);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickRange,
                    child: InputDecorator(
                      decoration: const InputDecoration(label: Text('Date range'), border: OutlineInputBorder()),
                      child: Text(_range == null ? 'Select range' : '${_labelFmt.format(_range!.start)} — ${_labelFmt.format(_range!.end)}'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<PeriodType>(
                  value: _period,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _period = v);
                    _applyFilter();
                  },
                  items: const [
                    DropdownMenuItem(value: PeriodType.monthly, child: Text('Monthly')),
                    DropdownMenuItem(value: PeriodType.quarterly, child: Text('Quarterly')),
                    DropdownMenuItem(value: PeriodType.yearly, child: Text('Yearly')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(value: _compareMode, onChanged: (v) { setState(() => _compareMode = v ?? false); }),
                const Text('Compare mode (enable to show side-by-side later)')
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final String name;
  final double total;
  final List<AggregatePoint> points;

  const _CustomerCard({Key? key, required this.name, required this.total, required this.points}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text('Total: ' + NumberFormat.currency(symbol: '₹').format(total)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 160,
              height: 70,
              child: _MiniLineChart(points: points),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniLineChart extends StatelessWidget {
  final List<AggregatePoint> points;
  const _MiniLineChart({Key? key, required this.points}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Center(child: Text('No data', style: Theme.of(context).textTheme.bodySmall));
    }

    final minY = points.map((e) => e.amount).reduce((a, b) => a < b ? a : b);
    final maxY = points.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

    final spots = <FlSpot>[];
    for (var i = 0; i < points.length; i++) {
      spots.add(FlSpot(i.toDouble(), points[i].amount));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 2,
            dotData: FlDotData(show: false),
          )
        ],
        minY: minY * 0.9,
        maxY: maxY * 1.1,
      ),
    );
  }
}

// ----- Data models -----
class DatedSale {
  final DateTime date;
  final double amount;
  DatedSale({required this.date, required this.amount});
}

class AggregatePoint {
  final DateTime date;
  final double amount;
  AggregatePoint({required this.date, required this.amount});
}

// ----- Mock data generator -----
Map<String, List<DatedSale>> _createMockData() {
  final now = DateTime.now();
  final rng = List.generate(120, (i) => now.subtract(Duration(days: i)));

  final customers = ['Gruubb', 'Asha Enterprises', 'Rohan Traders', 'Maya Cafe', 'Digital Mart'];
  final map = <String, List<DatedSale>>{};
  for (final c in customers) {
    final list = <DatedSale>[];
    for (var i = 0; i < rng.length; i++) {
      // random-ish amounts
      final amount = ((i % (3 + c.length)) * 20 + (c.length * 5)) % 900 + (c.length * 10);
      // create some zero days to simulate sparse customers
      if (amount % 7 == 0) continue;
      list.add(DatedSale(date: rng[i], amount: amount.toDouble()));
    }
    map[c] = list;
  }
  return map;
}

// For static access in class
Map<String, List<DatedSale>> _createMockDataStatic() => _createMockData();

// helper: accessible from static scope
List<AggregatePoint> _aggregateByPeriod(List<DatedSale> sales, PeriodType period) => _CustomerReportingStateHelper.aggregateByPeriod(sales, period);

class _CustomerReportingStateHelper {
  static List<AggregatePoint> aggregateByPeriod(List<DatedSale> sales, PeriodType period) {
    if (sales.isEmpty) return [];
    final grouped = <String, double>{};
    final parseKeyToDate = <String, DateTime>{};
    for (final s in sales) {
      final key = _periodKey(s.date, period);
      grouped[key] = (grouped[key] ?? 0.0) + s.amount;
      parseKeyToDate[key] = _periodKeyToDate(s.date, period);
    }
    final points = grouped.entries.map((e) => AggregatePoint(date: parseKeyToDate[e.key]!, amount: e.value)).toList();
    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }

  static String _periodKey(DateTime d, PeriodType p) {
    switch (p) {
      case PeriodType.monthly:
        return '${d.year}-${d.month.toString().padLeft(2, '0')}';
      case PeriodType.quarterly:
        final q = ((d.month - 1) ~/ 3) + 1;
        return '${d.year}-Q$q';
      case PeriodType.yearly:
        return '${d.year}';
    }
  }

  static DateTime _periodKeyToDate(DateTime d, PeriodType p) {
    switch (p) {
      case PeriodType.monthly:
        return DateTime(d.year, d.month, 1);
      case PeriodType.quarterly:
        final q = ((d.month - 1) ~/ 3) + 1;
        return DateTime(d.year, (q - 1) * 3 + 1, 1);
      case PeriodType.yearly:
        return DateTime(d.year, 1, 1);
    }
  }
}
