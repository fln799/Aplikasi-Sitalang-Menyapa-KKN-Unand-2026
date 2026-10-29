import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sitalang_menyapa/database/db_helper.dart';

class KesehatanPage extends StatelessWidget {
  const KesehatanPage({super.key});

  // FUNGSI UNTUK MENGONVERSI TEKS WARNA ADMIN MENJADI WARNA ASLI FLUTTER
  Color _getColorFromString(String? colorName) {
    switch (colorName) {
      case 'Merah':
        return const Color(0xFFCB201E);
      case 'Oranye':
        return Colors.orange;
      case 'Kuning':
        return Colors.amber.shade700;
      case 'Hijau':
        return Colors.green;
      case 'Biru':
        return Colors.blue;
      case 'Ungu':
        return Colors.purple;
      case 'Teal':
        return Colors.teal;
      case 'Hitam':
        return Colors.black87;
      default:
        return const Color(0xFF1A365D); // Default Biru Navy
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kesehatan & Sensus',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A365D),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DBHelper().getAllData('data_kesehatan_utama'),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00CED1)),
            );
          if (snapshot.data!.isEmpty)
            return const Center(
              child: Text('Data Kesehatan belum diisi oleh Admin.'),
            );

          final data = snapshot.data!.first;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSectionTitle(
                'Sensus Penduduk Menetap',
                Icons.people_alt_rounded,
                const Color(0xFF1A365D),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A365D), Color(0xFF00CED1)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Penduduk Domisili',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${data['total_domisili']} Jiwa',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.home_work_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // PERSEBARAN PENYAKIT (MEMBACA WARNA DARI DATABASE)
              _buildSectionTitle(
                'Persebaran Penyakit',
                Icons.medical_information_rounded,
                const Color(0xFFCB201E),
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: DBHelper().getAllData('persebaran_penyakit'),
                builder: (context, snapPenyakit) {
                  if (!snapPenyakit.hasData)
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFCB201E),
                      ),
                    );
                  if (snapPenyakit.data!.isEmpty)
                    return const Text(
                      'Belum ada data penyakit.',
                      style: TextStyle(color: Colors.grey),
                    );

                  return Column(
                    children: snapPenyakit.data!.map((p) {
                      // Mengubah teks dari DB menjadi warna
                      Color cardColor = _getColorFromString(p['warna']);
                      return _buildPenyakitCard(
                        p['nama_penyakit'],
                        p['deskripsi'],
                        int.tryParse(p['jumlah'].toString()) ?? 0,
                        cardColor,
                        isDark,
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),

              _buildSectionTitle(
                'Pemantauan Kesehatan',
                Icons.health_and_safety_rounded,
                Colors.green,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.child_care, color: Colors.blue),
                      title: const Text('Balita (Posyandu Aktif)'),
                      trailing: Text(
                        "L: ${data['balita_l']} | P: ${data['balita_p']}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.boy_rounded,
                        color: Colors.green,
                      ),
                      title: const Text('Remaja (Bebas Stunting)'),
                      trailing: Text(
                        "L: ${data['remaja_l']} | P: ${data['remaja_p']}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.elderly_rounded,
                        color: Colors.orange,
                      ),
                      title: const Text('Lansia (Cek Rutin Bulanan)'),
                      trailing: Text(
                        "L: ${data['lansia_l']} | P: ${data['lansia_p']}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _buildSectionTitle(
                'Fasilitas Kesehatan Terdekat',
                Icons.local_hospital_rounded,
                const Color(0xFF00CED1),
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: DBHelper().getAllData('kesehatan'),
                builder: (context, faskesSnap) {
                  if (!faskesSnap.hasData)
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00CED1),
                      ),
                    );
                  if (faskesSnap.data!.isEmpty)
                    return const Text(
                      'Belum ada data Fasilitas Kesehatan.',
                      style: TextStyle(color: Colors.grey),
                    );
                  return Column(
                    children: faskesSnap.data!
                        .map(
                          (f) => Card(
                            color: isDark
                                ? const Color(0xFF1E1E1E)
                                : Colors.white,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: const Color(
                                  0xFF00CED1,
                                ).withValues(alpha: 0.3),
                              ),
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF00CED1,
                                  ).withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.medical_services,
                                  color: Color(0xFF00CED1),
                                ),
                              ),
                              title: Text(
                                f['nama_faskes'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "Detail / Jadwal:\n${f['jadwal']}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.call,
                                  color: Colors.green,
                                ),
                                onPressed: () => launchUrl(
                                  Uri.parse("tel://${f['kontak']}"),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildPenyakitCard(
    String penyakit,
    String deskripsi,
    int jumlah,
    Color color,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.coronavirus_rounded, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  penyakit,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  deskripsi,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$jumlah Kasus',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
