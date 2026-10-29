import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sitalang_menyapa/database/db_helper.dart';
import 'package:sitalang_menyapa/auth/login_page.dart';
import 'package:sitalang_menyapa/admin/admin_berita.dart';
import 'package:sitalang_menyapa/admin/admin_warga.dart';
import 'package:sitalang_menyapa/admin/admin_crud_master.dart';
import 'package:sitalang_menyapa/admin/admin_edit_spesifik.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int totalWarga = 0;
  int totalLaporan = 0;
  int totalBerita = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    final warga = await DBHelper().getUsersOnly();
    final laporan = await DBHelper().getAllData('reports');
    final berita = await DBHelper().getAllData('berita');

    if (mounted) {
      setState(() {
        totalWarga = warga.length;
        totalLaporan = laporan.length;
        totalBerita = berita.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF121212)
            : const Color(0xFFF4F6F9),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220.0,
              floating: false,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: isDark
                  ? const Color(0xFF1E1E1E)
                  : const Color(0xFF1A365D),
              shape: const ContinuousRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              const Color(0xFF2A2A2A),
                              const Color(0xFF121212),
                            ] // Warna redup untuk Dark Mode
                          : [
                              const Color(0xFF1A365D),
                              const Color(0xFF0F2038),
                            ], // Biru Navy untuk Light Mode
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 60,
                      left: 24,
                      right: 24,
                      bottom: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color:
                                        (isDark
                                                ? Colors.blue.shade300
                                                : const Color(0xFF00CED1))
                                            .withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.admin_panel_settings_rounded,
                                    color: isDark
                                        ? Colors.blue.shade300
                                        : const Color(0xFF00CED1),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selamat Datang,',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      'Super Admin',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.logout_rounded,
                                color: Colors.white70,
                              ),
                              tooltip: 'Keluar',
                              onPressed: () => Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                                (route) => false,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          'Panel Kontrol Nagari Sitalang',
                          style: TextStyle(
                            color: isDark
                                ? Colors.blue.shade200
                                : const Color(0xFF00CED1),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Dashboard Admin',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildStatCard(
                          'Warga Aktif',
                          totalWarga.toString(),
                          Icons.people_alt_rounded,
                          isDark
                              ? Colors.blue.shade300
                              : const Color(0xFF1A365D),
                          isDark,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          'Laporan',
                          totalLaporan.toString(),
                          Icons.report_problem_rounded,
                          isDark
                              ? Colors.orange.shade300
                              : const Color(0xFFCB201E),
                          isDark,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          'Berita',
                          totalBerita.toString(),
                          Icons.article_rounded,
                          isDark
                              ? Colors.amber.shade300
                              : Colors.orange.shade700,
                          isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // --- KATEGORI 1: MANAJEMEN KONTEN PUBLIK ---
                    _buildSectionTitle(
                      'Manajemen Konten Publik',
                      Icons.public_rounded,
                      isDark,
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.15,
                      children: [
                        _buildMenuCard(
                          context,
                          'Berita & Agenda',
                          Icons.campaign_rounded,
                          isDark
                              ? Colors.blue.shade300
                              : const Color(0xFF1A365D),
                          isDark,
                          () => _openTarget(
                            context,
                            const KelolaBeritaPage(
                              table: 'berita',
                              title: 'Berita',
                            ),
                          ),
                        ),
                        _buildMenuCard(
                          context,
                          'Wisata Nagari',
                          Icons.tour_rounded,
                          isDark
                              ? Colors.teal.shade300
                              : const Color(0xFF008080),
                          isDark,
                          () => _openTarget(
                            context,
                            const KelolaBeritaPage(
                              table: 'wisata',
                              title: 'Wisata',
                            ),
                          ),
                        ),
                        _buildMenuCard(
                          context,
                          'Data UMKM',
                          Icons.storefront_rounded,
                          isDark
                              ? Colors.amber.shade300
                              : Colors.orange.shade700,
                          isDark,
                          () => _openCRUD(context, 'umkm'),
                        ),
                        _buildMenuCard(
                          context,
                          'Kajian Masjid',
                          Icons.mosque_rounded,
                          isDark
                              ? Colors.indigo.shade300
                              : const Color(0xFF483D8B),
                          isDark,
                          () => _openCRUD(context, 'kegiatan_masjid'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // --- KATEGORI 2: LAYANAN & PENDUDUK ---
                    _buildSectionTitle(
                      'Layanan & Penduduk',
                      Icons.manage_accounts_rounded,
                      isDark,
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.15,
                      children: [
                        _buildMenuCard(
                          context,
                          'Laporan Warga',
                          Icons.report_rounded,
                          isDark
                              ? Colors.orange.shade300
                              : const Color(0xFFCB201E),
                          isDark,
                          () => _openCRUD(context, 'reports'),
                        ),
                        _buildMenuCard(
                          context,
                          'Database Warga',
                          Icons.people_alt_rounded,
                          isDark
                              ? Colors.cyan.shade300
                              : const Color(0xFF00CED1),
                          isDark,
                          () => _openTarget(context, const KelolaWargaPage()),
                        ),
                        _buildMenuCard(
                          context,
                          'Edit Demografi',
                          Icons.analytics_rounded,
                          isDark
                              ? Colors.purple.shade300
                              : const Color(0xFF800080),
                          isDark,
                          () => _openTarget(
                            context,
                            const AdminEditSpesifikPage(tipeData: 'warga'),
                          ),
                        ),
                        _buildMenuCard(
                          context,
                          'Edit Sensus',
                          Icons.medical_information_rounded,
                          isDark
                              ? Colors.lightGreen.shade300
                              : const Color(0xFF556B2F),
                          isDark,
                          () => _openTarget(
                            context,
                            const AdminEditSpesifikPage(tipeData: 'kesehatan'),
                          ),
                        ),
                        _buildMenuCard(
                          context,
                          'Data Penyakit',
                          Icons.coronavirus_rounded,
                          isDark
                              ? Colors.pink.shade300
                              : const Color(0xFFC71585),
                          isDark,
                          () => _openCRUD(context, 'persebaran_penyakit'),
                        ),
                        _buildMenuCard(
                          context,
                          'Faskes & RS',
                          Icons.health_and_safety_rounded,
                          isDark
                              ? Colors.green.shade300
                              : const Color(0xFF2E8B57),
                          isDark,
                          () => _openCRUD(context, 'kesehatan'),
                        ),
                        _buildMenuCard(
                          context,
                          'Layanan Surat',
                          Icons.contact_page_rounded,
                          isDark
                              ? Colors.blueGrey.shade300
                              : const Color(0xFF4682B4),
                          isDark,
                          () => _openCRUD(context, 'surat'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A365D),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          color: isDark ? Colors.grey[400] : const Color(0xFF1A365D),
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.grey[300] : const Color(0xFF1A365D),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    bool isDark,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isDark ? Colors.white : const Color(0xFF1A365D),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCRUD(BuildContext context, String table) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CrudMasterPage(table: table)),
    ).then((_) => _loadDashboardStats());
  }

  void _openTarget(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    ).then((_) => _loadDashboardStats());
  }
}
