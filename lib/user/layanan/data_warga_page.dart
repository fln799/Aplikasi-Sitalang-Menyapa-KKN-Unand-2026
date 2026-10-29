import 'package:flutter/material.dart';
import 'package:sitalang_menyapa/database/db_helper.dart';

class DataWargaPage extends StatelessWidget {
  const DataWargaPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Data Warga',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A365D),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DBHelper().getAllData('data_warga_utama'),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.isEmpty)
            return const Center(
              child: Text('Data Warga belum diinisialisasi Admin.'),
            );

          final data = snapshot.data!.first;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildTotalPendudukCard(data['total'].toString()),
              const SizedBox(height: 24),
              const Text(
                'Pertumbuhan Penduduk (5 Tahun)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildYearlyChart(data, isDark),
              const SizedBox(height: 28),
              const Text(
                'Demografi Berdasarkan Usia',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildDataCard(
                context,
                'Bayi & Balita (< 5 Tahun)',
                data['balita_l'],
                data['balita_p'],
                isDark,
              ),
              _buildDataCard(
                context,
                'Anak-anak (5 - 9 Tahun)',
                data['anak_l'],
                data['anak_p'],
                isDark,
              ),
              _buildDataCard(
                context,
                'Remaja (10 - 18 Tahun)',
                data['remaja_l'],
                data['remaja_p'],
                isDark,
              ),
              _buildDataCard(
                context,
                'Dewasa (18 - 59 Tahun)',
                data['dewasa_l'],
                data['dewasa_p'],
                isDark,
              ),
              _buildDataCard(
                context,
                'Lansia (60+ Tahun)',
                data['lansia_l'],
                data['lansia_p'],
                isDark,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTotalPendudukCard(String total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A365D), Color(0xFF00CED1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00CED1).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Penduduk Sitalang',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$total Jiwa',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Icon(Icons.groups_rounded, color: Colors.white, size: 48),
        ],
      ),
    );
  }

  Widget _buildYearlyChart(Map<String, dynamic> dbData, bool isDark) {
    final List<Map<String, dynamic>> yearlyData = [
      {'year': dbData['label_thn_1'] ?? '2022', 'pop': dbData['thn_1'] ?? 0},
      {'year': dbData['label_thn_2'] ?? '2023', 'pop': dbData['thn_2'] ?? 0},
      {'year': dbData['label_thn_3'] ?? '2024', 'pop': dbData['thn_3'] ?? 0},
      {'year': dbData['label_thn_4'] ?? '2025', 'pop': dbData['thn_4'] ?? 0},
      {'year': dbData['label_thn_5'] ?? '2026', 'pop': dbData['thn_5'] ?? 0},
    ];

    double highestPop = 0;
    for (var data in yearlyData) {
      double currentPop = (data['pop'] as num).toDouble();
      if (currentPop > highestPop) highestPop = currentPop;
    }

    double maxScale = highestPop == 0 ? 100.0 : highestPop * 1.2;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      height: 220,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: yearlyData.map((data) {
          double popValue = (data['pop'] as num).toDouble();
          double heightRatio = popValue / maxScale;
          if (heightRatio > 1.0) heightRatio = 1.0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${data['pop']}',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 32,
                height: 100 * heightRatio,
                decoration: const BoxDecoration(
                  color: Color(0xFF00CED1),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data['year'].toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A365D),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDataCard(
    BuildContext context,
    String title,
    int male,
    int female,
    bool isDark,
  ) {
    int total = male + female;
    double highestPop = (male > female) ? male.toDouble() : female.toDouble();
    double maxBar = highestPop == 0 ? 100.0 : highestPop * 1.2;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.male, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (male / maxBar).clamp(0.0, 1.0),
                    minHeight: 12,
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$male Jiwa',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.female, color: Colors.pink, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (female / maxBar).clamp(0.0, 1.0),
                    minHeight: 12,
                    backgroundColor: Colors.pink.withValues(alpha: 0.1),
                    color: Colors.pink,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$female Jiwa',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(),
          ),
          Text(
            'Total: $total Jiwa',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
