import 'package:flutter/material.dart';
import 'package:sitalang_menyapa/database/db_helper.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  List<Map<String, dynamic>> _notifData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifikasi();
  }

  Future<void> _loadNotifikasi() async {
    final session = await DBHelper().getActiveSession();
    if (session == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // Ambil laporan yang BUKAN menunggu verifikasi (Artinya sudah direspons admin)
    final allReports = await DBHelper().getAllData('reports');
    final myRespondedReports = allReports
        .where(
          (r) =>
              r['pengirim'] == session['nama'] &&
              r['status'] != 'Menunggu Verifikasi',
        )
        .toList();

    List<Map<String, dynamic>> builtNotifs = [];

    // Notifikasi Bawaan Sistem
    builtNotifs.add({
      'title': 'Selamat Datang di Sitalang Menyapa!',
      'desc': 'Terima kasih telah bergabung. Mari bangun Nagari kita bersama.',
      'time': 'Sistem',
      'icon': Icons.waving_hand_rounded,
      'color': Colors.orange,
      'isNew': false,
    });

    // Notifikasi Dinamis dari Perubahan Status Laporan
    for (var report in myRespondedReports) {
      bool isSelesai = report['status'].toString().toLowerCase().contains(
        'selesai',
      );
      builtNotifs.insert(0, {
        'title': isSelesai
            ? 'Laporan Anda Telah Selesai'
            : 'Laporan Diverifikasi Admin',
        'desc':
            'Laporan mengenai "${report['kategori']}" di ${report['lokasi']} ${isSelesai ? 'telah diselesaikan' : 'sedang ditindaklanjuti'}.',
        'time': report['tanggal'],
        'icon': isSelesai ? Icons.check_circle_rounded : Icons.info_rounded,
        'color': isSelesai ? Colors.green : Colors.blue,
        'isNew': true, // Menandakan warna highlight notif baru
      });
    }

    if (mounted)
      setState(() {
        _notifData = builtNotifs;
        _isLoading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          'Pemberitahuan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: isDark
            ? const Color(0xFF1E1E1E)
            : const Color(0xFF1A365D),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00CED1)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _notifData.length,
              itemBuilder: (context, index) {
                final item = _notifData[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? (item['isNew']
                              ? const Color(0xFF1E2A3B)
                              : const Color(0xFF1E1E1E))
                        : (item['isNew']
                              ? const Color(0xFFE3F2FD)
                              : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: item['color'].withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item['icon'],
                            color: item['color'],
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['title'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1A365D),
                                      ),
                                    ),
                                  ),
                                  if (item['isNew'])
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFCB201E),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item['desc'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[700],
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['time'],
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
