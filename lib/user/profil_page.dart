import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sitalang_menyapa/database/db_helper.dart';
import 'package:sitalang_menyapa/auth/login_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  Map<String, dynamic>? _userData;
  File? _imageFile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final session = await DBHelper().getActiveSession();
      if (mounted) {
        setState(() {
          _userData = session;
          if (session != null &&
              session['foto_profil'] != null &&
              session['foto_profil'].toString().isNotEmpty) {
            final file = File(session['foto_profil']);
            if (file.existsSync()) {
              _imageFile = file;
            } else {
              _imageFile = null;
            }
          } else {
            _imageFile = null;
          }
        });
      }
    } catch (e) {
      debugPrint("Error load profile: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _gantiFotoProfil() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null && _userData != null) {
      // Ambil ID pengguna dengan aman dari session ('user_id' atau 'id')
      int userId = _userData!['user_id'] ?? _userData!['id'];

      String savedPath = await DBHelper().saveImagePermanently(pickedFile.path);
      await DBHelper().updateProfilePic(userId, savedPath);

      await _loadProfileData(); // Muat ulang data terbaru

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil diubah dan disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _showEditProfilModal() {
    if (_userData == null) return;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    final namaCtrl = TextEditingController(text: _userData!['nama']);
    final waCtrl = TextEditingController(text: _userData!['whatsapp']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                const Text(
                  'Edit Informasi Profil',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: namaCtrl,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: const Icon(
                      Icons.person_rounded,
                      color: Colors.grey,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: waCtrl,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Nomor WhatsApp',
                    prefixIcon: const Icon(
                      Icons.phone_rounded,
                      color: Colors.grey,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A365D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      if (namaCtrl.text.isEmpty || waCtrl.text.isEmpty) return;
                      int userId = _userData!['user_id'] ?? _userData!['id'];
                      await DBHelper().updateProfil(
                        userId,
                        namaCtrl.text,
                        waCtrl.text,
                      );

                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profil berhasil diperbarui!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      _loadProfileData();
                    },
                    child: const Text(
                      'SIMPAN PERUBAHAN',
                      style: TextStyle(
                        color: Colors.white,
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
      ),
    );
  }

  void _showUbahSandiModal() {
    if (_userData == null) return;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    final sandiLamaCtrl = TextEditingController();
    final sandiBaruCtrl = TextEditingController();
    final konfirmasiCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
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
                    const Text(
                      'Ubah Kata Sandi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildPasswordInput(
                      'Kata Sandi Lama',
                      sandiLamaCtrl,
                      isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordInput(
                      'Kata Sandi Baru',
                      sandiBaruCtrl,
                      isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordInput(
                      'Konfirmasi Sandi Baru',
                      konfirmasiCtrl,
                      isDark,
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCB201E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          if (sandiLamaCtrl.text.isEmpty ||
                              sandiBaruCtrl.text.isEmpty ||
                              konfirmasiCtrl.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Semua kolom wajib diisi!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          if (sandiBaruCtrl.text != konfirmasiCtrl.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Sandi baru dan konfirmasi tidak cocok!',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          int userId =
                              _userData!['user_id'] ?? _userData!['id'];
                          bool success = await DBHelper().ubahSandi(
                            userId,
                            sandiLamaCtrl.text,
                            sandiBaruCtrl.text,
                          );

                          if (!context.mounted) return;

                          if (success) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Kata sandi berhasil diubah!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Kata sandi lama salah!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'PERBARUI SANDI',
                          style: TextStyle(
                            color: Colors.white,
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
        },
      ),
    );
  }

  Widget _buildPasswordInput(
    String hint,
    TextEditingController controller,
    bool isDark,
  ) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: hint,
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.grey),
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _showTentangAplikasi() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00CED1).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF00CED1),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sitalang Menyapa',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Versi 1.0.0\nLayanan Terpadu Masyarakat Nagari',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aplikasi ini didesain khusus untuk memudahkan warga Nagari Sitalang dalam mengakses informasi, layanan administrasi, dan pelaporan langsung kepada Wali Nagari.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A365D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Tutup',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00CED1)),
      );
    }

    bool isDark = Theme.of(context).brightness == Brightness.dark;
    String nama = _userData?['nama'] ?? 'Pengguna';
    String whatsapp = _userData?['whatsapp'] ?? 'Nomor tidak tersedia';
    String role = _userData?['role'] ?? 'Warga';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfileData,
        color: const Color(0xFF00CED1),
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(
                      0xFF00CED1,
                    ).withValues(alpha: 0.2),
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : null,
                    child: _imageFile == null
                        ? Text(
                            nama.isNotEmpty ? nama[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00CED1),
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _gantiFotoProfil,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1A365D),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    nama,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$whatsapp  |  ${role.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            _buildMenuOption(
              context,
              icon: Icons.person_outline,
              title: 'Edit Informasi Profil',
              subtitle: 'Ubah nama dan nomor telepon',
              onTap: _showEditProfilModal,
            ),
            _buildMenuOption(
              context,
              icon: Icons.lock_outline,
              title: 'Ubah Kata Sandi',
              subtitle: 'Perbarui keamanan akun Anda',
              onTap: _showUbahSandiModal,
            ),
            _buildMenuOption(
              context,
              icon: Icons.info_outline,
              title: 'Tentang Aplikasi',
              subtitle: 'Versi, info developer & rilis',
              onTap: _showTentangAplikasi,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(),
            ),
            _buildMenuOption(
              context,
              icon: Icons.logout_rounded,
              title: 'Keluar Akun',
              subtitle: 'Akhiri sesi Anda saat ini',
              color: const Color(0xFFCB201E),
              onTap: () async {
                await DBHelper().logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color defaultColor = isDark ? Colors.white : const Color(0xFF1A365D);
    Color finalColor = color ?? defaultColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: finalColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: finalColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: finalColor,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDark ? Colors.grey[700] : Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }
}
