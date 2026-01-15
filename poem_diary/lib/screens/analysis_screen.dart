import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import '../core/providers.dart';
import '../models/daily_entry_model.dart';
import 'package:intl/intl.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MoodProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Data Preparation
    final entries = provider.journal.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date)); // Oldest first for charts

    final last7Days = entries.length > 7
        ? entries.sublist(entries.length - 7)
        : entries;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Analiz",
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. Mood Trend (Line Chart)
            _buildSection(
              context,
              "Duygu Değişimi (Son 7 Gün)",
              _buildMoodChart(last7Days, isDark),
              isDark,
            ),
            const SizedBox(height: 20),

            // 2. Sleep Analysis (Pie Chart)
            _buildSection(
              context,
              "Uyku Kalitesi",
              _buildSleepPieChart(entries, isDark),
              isDark,
            ),
            const SizedBox(height: 20),

            // 3. Top Activities (List/Bar)
            _buildSection(
              context,
              "En Sık Yapılan Aktiviteler",
              _buildActivityList(entries, isDark),
              isDark,
            ),
            // Bottom padding for nav bar
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    Widget content,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          content,
        ],
      ),
    );
  }

  // --- CHART 1: LINE CHART (MOOD) ---
  Widget _buildMoodChart(List<DailyEntry> data, bool isDark) {
    if (data.isEmpty) {
      return const Center(child: Text("Yeterli veri yok"));
    }

    return SizedBox(
      height: 220, // Slightly taller for emojis
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            // Left Titles: Emojis
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if ((value - 5).abs() < 0.1) {
                    return const Center(
                      child: Text('🤩', style: TextStyle(fontSize: 20)),
                    );
                  } else if ((value - 3).abs() < 0.1) {
                    return const Center(
                      child: Text('😐', style: TextStyle(fontSize: 20)),
                    );
                  } else if ((value - 1).abs() < 0.1) {
                    return const Center(
                      child: Text('😔', style: TextStyle(fontSize: 20)),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat(
                          'E',
                          'tr',
                        ).format(data[index].date), // Pzt, Sal
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minY: 0.5,
          maxY: 5.5,
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((e) {
                return FlSpot(
                  e.key.toDouble(),
                  _getMoodScore(e.value.moodCode),
                );
              }).toList(),
              isCurved: true,
              gradient: const LinearGradient(
                colors: [Colors.redAccent, Colors.amber, Colors.green],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              barWidth: 5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: _getColorForScore(spot.y),
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.redAccent.withValues(alpha: 0.1),
                    Colors.green.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMoodScore(String code) {
    switch (code) {
      case 'happy':
        return 5;
      case 'hopeful':
        return 5;

      case 'peaceful':
        return 4;
      case 'romantic':
        return 4;

      case 'nostalgic':
        return 3;
      case 'neutral':
        return 3;

      case 'tired':
        return 2;

      case 'sad':
        return 1;
      case 'angry':
        return 1;

      default:
        return 3;
    }
  }

  Color _getColorForScore(double score) {
    if (score >= 4.5) return Colors.green;
    if (score >= 3.5) return Colors.lightGreen;
    if (score >= 2.5) return Colors.amber;
    if (score >= 1.5) return Colors.orange;
    return Colors.red;
  }

  // --- CHART 2: PIE CHART (SLEEP) ---
  Widget _buildSleepPieChart(List<DailyEntry> data, bool isDark) {
    int good = 0, medium = 0, bad = 0;

    for (var e in data) {
      final sleep = e.activities['sleep'];
      if (sleep == 'good') {
        good++;
      } else if (sleep == 'medium') {
        medium++;
      } else if (sleep == 'bad') {
        bad++;
      }
    }

    final total = good + medium + bad;
    if (total == 0) return const Center(child: Text("Uyku verisi yok"));

    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  if (good > 0)
                    PieChartSectionData(
                      value: good.toDouble(),
                      color: Colors.orangeAccent,
                      title: '${((good / total) * 100).toInt()}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (medium > 0)
                    PieChartSectionData(
                      value: medium.toDouble(),
                      color: Colors.blueAccent,
                      title: '${((medium / total) * 100).toInt()}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (bad > 0)
                    PieChartSectionData(
                      value: bad.toDouble(),
                      color: Colors.indigoAccent,
                      title: '${((bad / total) * 100).toInt()}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegend(Colors.orangeAccent, "İyi Uyku"),
              const SizedBox(height: 8),
              _buildLegend(Colors.blueAccent, "Orta"),
              const SizedBox(height: 8),
              _buildLegend(Colors.indigoAccent, "Kötü"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // --- CHART 3: TOP ACTIVITIES (LIST) ---
  Widget _buildActivityList(List<DailyEntry> data, bool isDark) {
    // Count frequencies
    final Map<String, int> counts = {};

    for (var e in data) {
      e.activities.forEach((key, value) {
        if (key == 'sleep' || key == 'weather') return; // Skip these

        if (value == true) {
          counts[key] = (counts[key] ?? 0) + 1;
        } else if (value is List) {
          for (var item in value) {
            counts[item.toString()] = (counts[item.toString()] ?? 0) + 1;
          }
        }
      });
    }

    if (counts.isEmpty) return const Center(child: Text("Aktivite verisi yok"));

    // Sort descending
    final sortedKeys = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));

    final top5 = sortedKeys.take(5).toList();

    return Column(
      children: top5.map((key) {
        final count = counts[key]!;
        final max = counts[top5.first]!;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getHumanLabel(key),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "$count kez",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: count / max,
                  backgroundColor: isDark ? Colors.white12 : Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getColorForKey(key),
                  ),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getHumanLabel(String key) {
    // Basic mapping
    final map = {
      'no_smoking': 'Sigarasız',
      'sport': 'Spor',
      'water': 'Su',
      'reading': 'Okuma',
      'meditation': 'Meditasyon',
      'cleaning': 'Temizlik',
      'gaming': 'Oyun',
      'friends': 'Arkadaşlar',
      'cooking': 'Yemek',
      'family': 'Aile',
      'party': 'Parti',
      'partner': 'Partner',
      'movie': 'Film',
      'art': 'Sanat',
      'shopping': 'Alışveriş',
      'laundry': 'Çamaşır',
      'manicure': 'Manikür',
      'skincare': 'Cilt Bakımı',
      'hair': 'Saç',
      'social_media_detox': 'Detoks',
    };
    return map[key] ?? key;
  }

  Color _getColorForKey(String key) {
    // Simple deterministic color
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    return colors[key.length % colors.length];
  }
}
