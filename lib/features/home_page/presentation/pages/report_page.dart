import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../record_view_home/domain/entities/food_record_entity.dart';

// --- MAIN PAGE ---
class ReportPage extends StatelessWidget {
  final DateTime selectedDate;
  final List<FoodRecordEntity> allRecords;

  const ReportPage({super.key, required this.selectedDate, required this.allRecords});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50], // Màu nền sáng nhẹ
        appBar: AppBar(
          title: const Text('Thống kê dinh dưỡng', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          bottom: TabBar(
            labelColor: Colors.blue[700],
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue[700],
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Tuần này'),
              Tab(text: 'Tháng này'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _WeeklyReport(selectedDate: selectedDate, allRecords: allRecords),
            _MonthlyReport(selectedDate: selectedDate, allRecords: allRecords),
          ],
        ),
      ),
    );
  }
}

// --- DATA LOGIC (Giữ nguyên logic tính toán của bạn) ---
class _Totals {
  double calories;
  double protein;
  double carbs;
  double fat;

  _Totals({this.calories = 0, this.protein = 0, this.carbs = 0, this.fat = 0});

  _Totals operator +(_Totals other) => _Totals(
    calories: calories + other.calories,
    protein: protein + other.protein,
    carbs: carbs + other.carbs,
    fat: fat + other.fat,
  );
}

// --- REPORT WRAPPERS ---
class _WeeklyReport extends StatelessWidget {
  final DateTime selectedDate;
  final List<FoodRecordEntity> allRecords;

  const _WeeklyReport({required this.selectedDate, required this.allRecords});

  @override
  Widget build(BuildContext context) {
    // Logic tính ngày trong tuần
    final start = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    final days = List<DateTime>.generate(7, (i) => start.add(Duration(days: i)));
    
    // Tính toán dữ liệu (như code cũ)
    final byDay = <DateTime, _Totals>{for (final d in days) DateTime(d.year, d.month, d.day): _Totals()};
    for (final r in allRecords) {
      final d = DateTime(r.date.year, r.date.month, r.date.day);
      if (byDay.containsKey(d)) {
        final t = byDay[d]!;
        t.calories += r.calories;
        t.protein += r.protein ?? 0;
        t.carbs += r.carbs ?? 0;
        t.fat += r.fat ?? 0;
      }
    }
    final total = byDay.values.fold<_Totals>(_Totals(), (acc, v) => acc + v);

    return _ReportView(
      days: days, 
      byDay: byDay, 
      total: total, 
      header: 'Tổng kết tuần',
      isMonthly: false,
    );
  }
}

class _MonthlyReport extends StatelessWidget {
  final DateTime selectedDate;
  final List<FoodRecordEntity> allRecords;

  const _MonthlyReport({required this.selectedDate, required this.allRecords});

  @override
  Widget build(BuildContext context) {
    final first = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDay = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final days = List<DateTime>.generate(lastDay.day, (i) => DateTime(first.year, first.month, i + 1));

    final byDay = <DateTime, _Totals>{for (final d in days) DateTime(d.year, d.month, d.day): _Totals()};
    for (final r in allRecords) {
      final d = DateTime(r.date.year, r.date.month, r.date.day);
      if (byDay.containsKey(d)) {
        final t = byDay[d]!;
        t.calories += r.calories;
        t.protein += r.protein ?? 0;
        t.carbs += r.carbs ?? 0;
        t.fat += r.fat ?? 0;
      }
    }
    final total = byDay.values.fold<_Totals>(_Totals(), (acc, v) => acc + v);

    return _ReportView(
      days: days, 
      byDay: byDay, 
      total: total, 
      header: 'Tổng kết tháng ${DateFormat('MM/yyyy').format(selectedDate)}',
      isMonthly: true,
    );
  }
}

// --- IMPROVED UI VIEW ---
class _ReportView extends StatelessWidget {
  final List<DateTime> days;
  final Map<DateTime, _Totals> byDay;
  final _Totals total;
  final String header;
  final bool isMonthly;

  const _ReportView({
    required this.days,
    required this.byDay,
    required this.total,
    required this.header,
    required this.isMonthly,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. SECTION: SUMMARY CARDS
            Text(header, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildSummaryCards(total),

            const SizedBox(height: 24),

            // 2. SECTION: CHART
            Text("Biểu đồ Calo", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 250,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: _buildBarChart(context),
            ),

            const SizedBox(height: 24),

            // 3. SECTION: DETAILED LIST
            Text("Chi tiết theo ngày", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(), // Để scroll theo cha
              shrinkWrap: true,
              itemCount: days.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                // Đảo ngược danh sách để ngày mới nhất lên đầu (cho UX tốt hơn)
                final d = days[days.length - 1 - index];
                final t = byDay[DateTime(d.year, d.month, d.day)] ?? _Totals();
                return _buildDailyItem(context, d, t);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(_Totals t) {
    return Row(
      children: [
        Expanded(child: _infoCard("Calories", "${t.calories.toStringAsFixed(0)}", "kcal", Colors.blue)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            children: [
              _miniInfoCard("Protein", "${t.protein.toStringAsFixed(0)}g", Colors.purple),
              const SizedBox(height: 8),
              _miniInfoCard("Carbs", "${t.carbs.toStringAsFixed(0)}g", Colors.orange),
              const SizedBox(height: 8),
              _miniInfoCard("Fat", "${t.fat.toStringAsFixed(0)}g", Colors.teal),
            ],
          ),
        )
      ],
    );
  }

  Widget _infoCard(String label, String value, String unit, Color color) {
    return Container(
      height: 140, // Chiều cao bằng tổng cột bên phải
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.local_fire_department_rounded, color: color, size: 32),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          Text("$unit • $label", style: TextStyle(color: color.withOpacity(0.8), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _miniInfoCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 4, backgroundColor: color),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildDailyItem(BuildContext context, DateTime d, _Totals t) {
    final isToday = d.year == DateTime.now().year && d.month == DateTime.now().month && d.day == DateTime.now().day;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isToday ? Border.all(color: Colors.blue.withOpacity(0.5), width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          // Date Column
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isToday ? Colors.blue : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(DateFormat('EEE', 'vi').format(d).toUpperCase(),
                    style: TextStyle(fontSize: 10, color: isToday ? Colors.white : Colors.grey)),
                Text(DateFormat('dd').format(d),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isToday ? Colors.white : Colors.black)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Info Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${t.calories.toStringAsFixed(0)} kcal", 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _nutrientText("P", t.protein, Colors.purple),
                    const SizedBox(width: 12),
                    _nutrientText("C", t.carbs, Colors.orange),
                    const SizedBox(width: 12),
                    _nutrientText("F", t.fat, Colors.teal),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nutrientText(String label, double value, Color color) {
    return Text("$label ${value.toStringAsFixed(0)}", 
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600));
  }

  Widget _buildBarChart(BuildContext context) {
    // Tìm giá trị max để scale biểu đồ
    double maxY = 0;
    for(var t in byDay.values) {
      if(t.calories > maxY) maxY = t.calories;
    }
    if (maxY == 0) maxY = 2000; // Default

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.2, // Chừa khoảng trống phía trên
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            // tooltipBgColor: Colors.blueAccent, // Cũ
            getTooltipColor: (_) => Colors.blueAccent, // Mới (Fl_chart 0.68+)
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.round()}\nkcal',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                   // Nếu là Monthly thì chỉ hiện các ngày chẵn hoặc 5 ngày 1 lần để đỡ rối
                   if (isMonthly && value.toInt() % 5 != 0) return const SizedBox.shrink();
                   
                   final d = days[value.toInt()];
                   return Padding(
                     padding: const EdgeInsets.only(top: 8.0),
                     child: Text(
                       DateFormat('dd').format(d),
                       style: const TextStyle(color: Colors.grey, fontSize: 10),
                     ),
                   );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // Ẩn trục Y cho thoáng
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: days.asMap().entries.map((entry) {
          final index = entry.key;
          final d = entry.value;
          final t = byDay[DateTime(d.year, d.month, d.day)] ?? _Totals();
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: t.calories,
                color: t.calories == 0 ? Colors.grey.withOpacity(0.2) : Colors.blue,
                width: isMonthly ? 6 : 12, // Tháng thì cột nhỏ lại
                borderRadius: BorderRadius.circular(4),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY * 1.2,
                  color: Colors.grey.withOpacity(0.05),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}