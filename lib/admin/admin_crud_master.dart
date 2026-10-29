import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sitalang_menyapa/database/db_helper.dart';

class CrudMasterPage extends StatefulWidget {
  final String table;
  const CrudMasterPage({super.key, required this.table});
  @override
  State<CrudMasterPage> createState() => _CrudMasterPageState();
}

class _CrudMasterPageState extends State<CrudMasterPage> {
  List<Map<String, dynamic>> _dataList = [];
  final _ctrl1 = TextEditingController();
  final _ctrl2 = TextEditingController();
  final _ctrl3 = TextEditingController();
  String _selectedColor = 'Merah';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await DBHelper().getAllData(widget.table);
    setState(() => _dataList = data);
  }

  Future<void> _hapus(int id) async {
    await DBHelper().deleteData(widget.table, id);
    _loadData();
  }

  // ==== FUNGSI KHUSUS UNTUK MENGUBAH STATUS LAPORAN ====
  Future<void> _verifikasiLaporan(int id, String statusBaru) async {
    await DBHelper().updateDataGlobal(widget.table, {'status': statusBaru}, id);
    if (mounted) Navigator.pop(context);
    _loadData();
  }

  // ==== MODAL DETAIL KHUSUS LAPOR WALI (ANTI-OVERFLOW) ====
  void _showReportDetail(Map<String, dynamic> item) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    String status = item['status'] ?? 'Menunggu Verifikasi';
    String statLow = status
        .toLowerCase(); // Membaca status dengan huruf kecil semua

    // Menentukan warna label status dengan kata kunci agar kebal dari error
    Color statusColor;
    if (statLow.contains('menunggu'))
      statusColor = Colors.orange;
    else if (statLow.contains('proses') || statLow.contains('diverifikasi'))
      statusColor = Colors.blue;
    else if (statLow.contains('selesai'))
      statusColor = Colors.green;
    else
      statusColor = Colors.red; // Ditolak

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Detail Laporan Warga',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

              // Menampilkan Foto
              if (item['foto_path'] != null &&
                  item['foto_path'].toString().isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(item['foto_path']),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey,
                      ),
                      Text(
                        'Tidak ada lampiran foto',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),
              Text(
                'Kategori: ${item['kategori']}',
                style: TextStyle(
                  color: isDark ? Colors.blue.shade300 : Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item['lokasi'] ?? '-',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const Divider(height: 30),

              const Text(
                'Deskripsi Kejadian:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2A2A2A)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item['deskripsi'] ?? '-',
                  style: const TextStyle(height: 1.5),
                ),
              ),

              const SizedBox(height: 24),

              // === PERBAIKAN OVERFLOW PIXEL ===
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      'Status Saat Ini:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey[300] : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // === TOMBOL LOGIKA ALUR (KEBAL ERROR) ===
              if (statLow.contains('menunggu'))
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _verifikasiLaporan(
                          item['id'],
                          'Ditolak (Tidak Valid)',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCB201E),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          'TOLAK',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _verifikasiLaporan(item['id'], 'Sedang Diproses'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A365D),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          'VERIFIKASI & PROSES',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else if (statLow.contains('proses') ||
                  statLow.contains('diverifikasi'))
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _verifikasiLaporan(item['id'], 'Selesai Ditangani'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(
                      Icons.done_all_rounded,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'TANDAI SELESAI',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Laporan ini telah ditutup.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _simpan(int? editId) async {
    if (_ctrl1.text.isEmpty || _ctrl2.text.isEmpty) return;
    Map<String, dynamic> data = {};
    if (widget.table == 'umkm')
      data = {
        'nama': _ctrl1.text,
        'pemilik': _ctrl2.text,
        'harga': _ctrl3.text,
        'kontak': '08xx',
      };
    if (widget.table == 'kesehatan')
      data = {
        'nama_faskes': _ctrl1.text,
        'jadwal': _ctrl2.text,
        'kontak': _ctrl3.text,
      };
    if (widget.table == 'surat')
      data = {'nama_surat': _ctrl1.text, 'syarat': _ctrl2.text};
    if (widget.table == 'kegiatan_masjid')
      data = {
        'nama_kegiatan': _ctrl1.text,
        'jadwal': _ctrl2.text,
        'ustadz': _ctrl3.text,
      };
    if (widget.table == 'persebaran_penyakit')
      data = {
        'nama_penyakit': _ctrl1.text,
        'deskripsi': _ctrl2.text,
        'jumlah': _ctrl3.text,
        'warna': _selectedColor,
      };

    if (editId == null) {
      await DBHelper().insertData(widget.table, data);
    } else {
      await DBHelper().updateDataGlobal(widget.table, data, editId);
    }
    _ctrl1.clear();
    _ctrl2.clear();
    _ctrl3.clear();
    if (mounted) Navigator.of(context).pop();
    _loadData();
  }

  void _showAddDialog({Map<String, dynamic>? item}) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    String label1 = 'Input Utama', label2 = 'Deskripsi', label3 = 'Info Lanjut';

    if (widget.table == 'umkm') {
      label1 = 'Nama Usaha UMKM';
      label2 = 'Nama Pemilik';
      label3 = 'Rentang Harga';
    }
    if (widget.table == 'kesehatan') {
      label1 = 'Nama Faskes';
      label2 = 'Jadwal Buka';
      label3 = 'Nomor Kontak';
    }
    if (widget.table == 'surat') {
      label1 = 'Nama Jenis Surat';
      label2 = 'Persyaratan Berkas';
    }
    if (widget.table == 'kegiatan_masjid') {
      label1 = 'Nama Kegiatan';
      label2 = 'Jadwal';
      label3 = 'Ustadz';
    }
    if (widget.table == 'persebaran_penyakit') {
      label1 = 'Nama Penyakit';
      label2 = 'Keterangan';
      label3 = 'Jumlah Kasus';
    }

    int? editId;
    if (item != null) {
      editId = item['id'];
      if (widget.table == 'umkm') {
        _ctrl1.text = item['nama'];
        _ctrl2.text = item['pemilik'];
        _ctrl3.text = item['harga'];
      }
      if (widget.table == 'kesehatan') {
        _ctrl1.text = item['nama_faskes'];
        _ctrl2.text = item['jadwal'];
        _ctrl3.text = item['kontak'];
      }
      if (widget.table == 'surat') {
        _ctrl1.text = item['nama_surat'];
        _ctrl2.text = item['syarat'];
      }
      if (widget.table == 'kegiatan_masjid') {
        _ctrl1.text = item['nama_kegiatan'];
        _ctrl2.text = item['jadwal'];
        _ctrl3.text = item['ustadz'];
      }
      if (widget.table == 'persebaran_penyakit') {
        _ctrl1.text = item['nama_penyakit'];
        _ctrl2.text = item['deskripsi'];
        _ctrl3.text = item['jumlah'];
        _selectedColor = item['warna'] ?? 'Merah';
      }
    } else {
      _ctrl1.clear();
      _ctrl2.clear();
      _ctrl3.clear();
      _selectedColor = 'Merah';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    item == null ? 'Tambah Data' : 'Edit Data',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _ctrl1,
                    decoration: InputDecoration(
                      labelText: label1,
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFF4F6F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _ctrl2,
                    maxLines: widget.table == 'surat' ? 3 : 1,
                    decoration: InputDecoration(
                      labelText: label2,
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFF4F6F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (widget.table != 'surat')
                    TextField(
                      controller: _ctrl3,
                      keyboardType: widget.table == 'persebaran_penyakit'
                          ? TextInputType.number
                          : TextInputType.text,
                      decoration: InputDecoration(
                        labelText: label3,
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF2A2A2A)
                            : const Color(0xFFF4F6F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                  if (widget.table == 'persebaran_penyakit') ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedColor,
                      decoration: InputDecoration(
                        labelText: 'Pilih Label Warna Lencana',
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF2A2A2A)
                            : const Color(0xFFF4F6F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items:
                          [
                            'Merah',
                            'Oranye',
                            'Kuning',
                            'Hijau',
                            'Biru',
                            'Ungu',
                            'Teal',
                            'Hitam',
                          ].map((String val) {
                            return DropdownMenuItem<String>(
                              value: val,
                              child: Text(val),
                            );
                          }).toList(),
                      onChanged: (newValue) {
                        setModalState(() {
                          _selectedColor = newValue!;
                        });
                      },
                    ),
                  ],

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => _simpan(editId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A365D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        item == null ? 'SIMPAN DATA' : 'PERBARUI DATA',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    bool isReports = widget.table == 'reports';

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text(
          isReports
              ? 'Verifikasi Lapor Wali'
              : 'Database: ${widget.table.toUpperCase()}',
        ),
        backgroundColor: isDark
            ? const Color(0xFF1E1E1E)
            : const Color(0xFF1A365D),
        foregroundColor: Colors.white,
      ),
      body: _dataList.isEmpty
          ? const Center(
              child: Text(
                'Data masih kosong.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _dataList.length,
              itemBuilder: (context, index) {
                final item = _dataList[index];

                String title = isReports
                    ? item['kategori']
                    : (item['nama_faskes'] ??
                          item['nama_surat'] ??
                          item['nama_kegiatan'] ??
                          item['nama'] ??
                          item['nama_penyakit'] ??
                          'Data');
                String sub = isReports
                    ? item['lokasi']
                    : (item['pemilik'] ??
                          item['jadwal'] ??
                          item['syarat'] ??
                          item['jumlah'] ??
                          item['deskripsi'] ??
                          '');

                String status = item['status'] ?? '';
                String statLow = status.toLowerCase();

                Color statusColor = Colors.orange;
                if (statLow.contains('proses') ||
                    statLow.contains('diverifikasi'))
                  statusColor = Colors.blue;
                else if (statLow.contains('selesai'))
                  statusColor = Colors.green;
                else if (statLow.contains('tolak'))
                  statusColor = Colors.red;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    onTap: isReports ? () => _showReportDetail(item) : null,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isReports
                            ? statusColor.withValues(alpha: 0.15)
                            : const Color(0xFF00CED1).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isReports
                            ? Icons.report_rounded
                            : Icons.dataset_rounded,
                        color: isReports
                            ? statusColor
                            : const Color(0xFF00CED1),
                      ),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis),
                        if (isReports) ...[
                          const SizedBox(height: 4),
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 10,
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isReports)
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Colors.blue,
                            ),
                            onPressed: () => _showAddDialog(item: item),
                          ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Color(0xFFCB201E),
                          ),
                          onPressed: () => _hapus(item['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: isReports
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showAddDialog(),
              backgroundColor: const Color(0xFF00CED1),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Tambah Data',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}
