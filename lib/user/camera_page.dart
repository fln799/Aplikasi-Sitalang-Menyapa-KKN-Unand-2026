import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sitalang_menyapa/database/db_helper.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final _kategoriCtrl = TextEditingController();
  final _lokasiCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 1000,
    );
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  void _kirimLaporan() async {
    if (_kategoriCtrl.text.isEmpty || _deskripsiCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kategori dan Deskripsi wajib diisi!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    String permanentPath = '';
    if (_imageFile != null) {
      permanentPath = await DBHelper().saveImagePermanently(_imageFile!.path);
    }

    // Ambil data user yang sedang login agar laporan masuk ke riwayatnya
    final session = await DBHelper().getActiveSession();
    String namaPengirim = session != null ? session['nama'] : 'Warga Anonim';

    await DBHelper().insertData('reports', {
      'pengirim': namaPengirim,
      'kategori': _kategoriCtrl.text,
      'lokasi': _lokasiCtrl.text,
      'deskripsi': _deskripsiCtrl.text,
      'status': 'Menunggu Verifikasi', // Status awal laporan
      'tanggal':
          "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
      'foto_path': permanentPath,
    });

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan sukses dikirim ke Admin Nagari!'),
          backgroundColor: Colors.green,
        ),
      );
      if (Navigator.canPop(context)) Navigator.pop(context);
    }
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
          'Lapor Wali',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: isDark
            ? const Color(0xFF1E1E1E)
            : const Color(0xFF1A365D), // Penyesuaian warna gelap
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sampaikan Keluhan Anda',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A365D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Foto kejadian dan berikan deskripsi agar tim Nagari bisa segera menindaklanjuti.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
            const SizedBox(height: 24),

            GestureDetector(
              onTap: _pickImage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFCB201E).withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFCB201E,
                              ).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 40,
                              color: Color(0xFFCB201E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Ketuk untuk Ambil Foto',
                            style: TextStyle(
                              color: Color(0xFFCB201E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            _buildInput(
              'Kategori Laporan (Cth: Jalan Rusak)',
              Icons.category_rounded,
              _kategoriCtrl,
              isDark,
            ),
            const SizedBox(height: 16),
            _buildInput(
              'Titik Lokasi Kejadian',
              Icons.location_on_rounded,
              _lokasiCtrl,
              isDark,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _deskripsiCtrl,
              maxLines: 4,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: 'Jelaskan detail kejadian...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00CED1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isLoading ? null : _kirimLaporan,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white),
                label: Text(
                  _isLoading ? 'MENGIRIM...' : 'KIRIM LAPORAN',
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
    );
  }

  Widget _buildInput(
    String hint,
    IconData icon,
    TextEditingController ctrl,
    bool isDark,
  ) {
    return TextField(
      controller: ctrl,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        prefixIcon: Icon(icon, color: Colors.grey.shade500),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
