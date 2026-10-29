import 'package:flutter/material.dart';
import 'package:sitalang_menyapa/database/db_helper.dart';

class AktivitasPage extends StatefulWidget {
  const AktivitasPage({super.key});

  @override
  State<AktivitasPage> createState() => _AktivitasPageState();
}

class _AktivitasPageState extends State<AktivitasPage> {
  List<Map<String, dynamic>> _riwayatLaporan = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    final session = await DBHelper().getActiveSession();
    if (session != null) {
      final allReports = await DBHelper().getAllData('reports');
      final myReports = allReports
          .where((report) => report['pengirim'] == session['nama'])
          .toList();

      if (mounted)
        setState(() {
          _riwayatLaporan = myReports;
          _isLoading = false;
        });
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ==== LOGIKA WARNA STATUS BARU ====
  Color _getStatusColor(String status, bool isDark) {
    String statLow = status.toLowerCase();
    if (statLow.contains('selesai'))
      return isDark ? Colors.green.shade400 : Colors.green;
    if (statLow.contains('proses'))
      return isDark ? Colors.blue.shade300 : Colors.blue;
    if (statLow.contains('tolak') || statLow.contains('tidak valid'))
      return isDark ? Colors.red.shade400 : const Color(0xFFCB201E);
    return isDark
        ? Colors.orange.shade300
        : Colors.orange; // Default: Menunggu Verifikasi
  }

  IconData _getStatusIcon(String status) {
    String statLow = status.toLowerCase();
    if (statLow.contains('selesai')) return Icons.verified_rounded;
    if (statLow.contains('proses')) return Icons.sync_rounded;
    if (statLow.contains('tolak')) return Icons.cancel_rounded;
    return Icons.pending_actions_rounded;
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
          'Riwayat Laporan Saya',
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
          : _riwayatLaporan.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 80,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada laporan.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const Text(
                    'Riwayat Lapor Wali Anda akan muncul di sini.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _riwayatLaporan.length,
              itemBuilder: (context, index) {
                final item = _riwayatLaporan[index];
                String status = item['status'] ?? 'Menunggu Verifikasi';
                Color statusColor = _getStatusColor(status, isDark);
                IconData statusIcon = _getStatusIcon(status);

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF00CED1,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item['kategori'] ?? 'Laporan',
                                style: const TextStyle(
                                  color: Color(0xFF00CED1),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              item['tanggal'] ?? '',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item['deskripsi'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A365D),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item['lokasi'] ?? '-',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        Row(
                          children: [
                            const Text(
                              'Status Laporan:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    statusIcon,
                                    size: 12,
                                    color: statusColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
