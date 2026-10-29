import 'package:flutter/material.dart';
import 'package:sitalang_menyapa/auth/login_page.dart';
import 'package:sitalang_menyapa/user/beranda_page.dart';
import 'package:sitalang_menyapa/user/aktivitas_page.dart';
import 'package:sitalang_menyapa/user/notifikasi_page.dart';
import 'package:sitalang_menyapa/user/profil_page.dart';
import 'package:sitalang_menyapa/database/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Database agar siap digunakan
  await DBHelper().database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sitalang Menyapa',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF1A365D),
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1A365D),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const LoginPage(), // Halaman awal aplikasi
    );
  }
}

// =================================================================
// KELAS MAIN PAGE (Penyatu 4 Halaman ke dalam Bottom Navigation)
// =================================================================
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // 4 Halaman Utama Warga
    _pages = [
      BerandaPage(
        onNavigateToProfile: () => _onItemTapped(3),
      ), // Lempar ke Profil jika avatar di klik
      const AktivitasPage(),
      const NotifikasiPage(),
      const ProfilPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF00CED1),
            unselectedItemColor: isDark ? Colors.grey[600] : Colors.grey[400],
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.home_rounded),
                ),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.history_rounded),
                ),
                label: 'Aktivitas',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.notifications_rounded),
                ),
                label: 'Notifikasi',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.person_rounded),
                ),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
