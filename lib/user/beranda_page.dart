import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sitalang_menyapa/auth/login_page.dart';
import 'package:sitalang_menyapa/user/camera_page.dart';
import 'package:sitalang_menyapa/database/db_helper.dart';

import 'package:sitalang_menyapa/user/layanan/layanan_utama.dart';
import 'package:sitalang_menyapa/user/layanan/data_warga_page.dart';
import 'package:sitalang_menyapa/user/layanan/kesehatan_page.dart';
import 'package:sitalang_menyapa/user/layanan/semua_layanan_page.dart';

class BerandaPage extends StatefulWidget {
  final VoidCallback onNavigateToProfile;
  const BerandaPage({super.key, required this.onNavigateToProfile});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  String _currentAddress = "Mencari lokasi...";
  bool _isLoadingLocation = true;
  List<Map<String, dynamic>> _beritaTerbaru = [];
  Map<String, dynamic>? _userData;
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentNewsIndex = 0;
  Timer? _sliderTimer;

  final List<Map<String, dynamic>> menuServices = const [
    {
      'icon': Icons.campaign_rounded,
      'title': 'Lapor\nWali',
      'color': Color(0xFFCB201E),
    },
    {
      'icon': Icons.mosque_rounded,
      'title': 'Kajian\nMasjid',
      'color': Color(0xFF1A365D),
    },
    {
      'icon': Icons.health_and_safety_rounded,
      'title': 'Kesehatan',
      'color': Color(0xFF00CED1),
    },
    {
      'icon': Icons.storefront_rounded,
      'title': 'UMKM\nLokal',
      'color': Colors.orange,
    },
    {
      'icon': Icons.contact_page_rounded,
      'title': 'Layanan\nSurat',
      'color': Color(0xFF21375B),
    },
    {
      'icon': Icons.analytics_rounded,
      'title': 'Data\nWarga',
      'color': Colors.teal,
    },
    {'icon': Icons.tour_rounded, 'title': 'Wisata', 'color': Colors.lightBlue},
    {
      'icon': Icons.grid_view_rounded,
      'title': 'Semua\nLayanan',
      'color': Color(0xFF494A4E),
    },
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadBeritaAdmin();
    _loadUserData();
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final session = await DBHelper().getActiveSession();
      if (mounted) setState(() => _userData = session);
    } catch (e) {
      debugPrint("Error load user: $e");
    }
  }

  Future<void> _loadBeritaAdmin() async {
    final data = await DBHelper().getAllData('berita');
    if (mounted) {
      setState(() => _beritaTerbaru = data);
      _startSliderTimer();
    }
  }

  void _startSliderTimer() {
    _sliderTimer?.cancel();
    if (_beritaTerbaru.length > 1) {
      _sliderTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (_pageController.hasClients) {
          int nextIndex = (_currentNewsIndex + 1) % _beritaTerbaru.length;
          _pageController.animateToPage(
            nextIndex,
            duration: const Duration(milliseconds: 800),
            curve: Curves.fastOutSlowIn,
          );
        }
      });
    }
  }

  // FUNGSI LOKASI YANG LEBIH TANGGUH (ANTI-ERROR)
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted)
          setState(() {
            _currentAddress = "GPS Mati";
            _isLoadingLocation = false;
          });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted)
            setState(() {
              _currentAddress = "Izin Ditolak";
              _isLoadingLocation = false;
            });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 8));

      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=14',
      );
      final request = await HttpClient().getUrl(url);
      request.headers.set(
        'User-Agent',
        'SitalangMenyapaApp/1.0 (sitalang@example.com)',
      );
      request.headers.set('Accept-Language', 'id-ID');

      final response = await request.close().timeout(
        const Duration(seconds: 8),
      );

      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final address = jsonDecode(stringData)['address'] ?? {};

        String kecamatan =
            address['county'] ??
            address['city_district'] ??
            address['city'] ??
            address['state_district'] ??
            address['suburb'] ??
            address['village'] ??
            'Area Nagari';
        kecamatan = kecamatan
            .replaceAll('Kecamatan ', '')
            .replaceAll('Kabupaten ', '');

        if (mounted)
          setState(() {
            _currentAddress = kecamatan;
            _isLoadingLocation = false;
          });
      } else {
        throw Exception('Server Peta Gagal');
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _currentAddress = "Area Nagari";
          _isLoadingLocation = false;
        });
    }
  }

  String _getSapaanWaktu() {
    var hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi,';
    if (hour < 15) return 'Selamat Siang,';
    if (hour < 18) return 'Selamat Sore,';
    return 'Selamat Malam,';
  }

  Widget _buildAnimatedComponent(Widget child, int delay) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAnimatedComponent(_buildHeader(context, isDark), 0),
              _buildAnimatedComponent(_buildBanner(), 100),
              _buildAnimatedComponent(_buildServiceGrid(context, isDark), 200),
              _buildAnimatedComponent(
                _buildEmergencySection(context, isDark),
                300,
              ),
              const SizedBox(height: 24),
              _buildAnimatedComponent(_buildSpotlightBerita(isDark), 400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    String namaUser = 'Warga Sitalang';
    if (_userData != null && _userData!['nama'] != null) {
      namaUser = _userData!['nama'];
    }

    String encodedName = Uri.encodeComponent(namaUser);
    ImageProvider avatarImage = NetworkImage(
      'https://ui-avatars.com/api/?name=$encodedName&background=1A365D&color=fff&size=128',
    );

    if (_userData != null &&
        _userData!['foto_profil'] != null &&
        _userData!['foto_profil'].toString().isNotEmpty) {
      File fileFoto = File(_userData!['foto_profil']);
      if (fileFoto.existsSync()) avatarImage = FileImage(fileFoto);
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: widget.onNavigateToProfile,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: avatarImage,
                    backgroundColor: isDark
                        ? const Color(0xFF1E2A3B)
                        : const Color(0xFFE3F2FD),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getSapaanWaktu(),
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.grey[400]
                                : const Color(0xFF494A4E),
                          ),
                        ),
                        Text(
                          namaUser,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A365D),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 130),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isLoadingLocation
                          ? Icons.location_searching
                          : Icons.location_on,
                      color: const Color(0xFFCB201E),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _currentAddress,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF494A4E),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFCB201E).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFCB201E),
                    size: 20,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Keluar Aplikasi'),
                        content: const Text('Apakah Anda yakin ingin keluar?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFCB201E),
                            ),
                            onPressed: () async {
                              await DBHelper().logout();
                              if (context.mounted)
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                  (route) => false,
                                );
                            },
                            child: const Text(
                              'Keluar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: double.infinity,
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
              color: const Color(0xFF00CED1).withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'INFO NAGARI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Sitalang Menyapa:\nLayanan Terpadu Digital',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Akses informasi dan layanan masyarakat lebih mudah.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceGrid(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Layanan Sitalang',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A365D),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: menuServices.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 20,
              crossAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              Color iconColor = menuServices[index]['color'];
              if (isDark && iconColor == const Color(0xFF1A365D))
                iconColor = Colors.white;
              return _buildAnimatedComponent(
                GestureDetector(
                  onTap: () {
                    Widget targetPage;
                    switch (index) {
                      case 0:
                        targetPage = const CameraPage();
                        break;
                      case 1:
                        targetPage = const KegiatanMasjidPage();
                        break;
                      case 2:
                        targetPage = const KesehatanPage();
                        break;
                      case 3:
                        targetPage = const UmkmPage();
                        break;
                      case 4:
                        targetPage = const LayananSuratPage();
                        break;
                      case 5:
                        targetPage = const DataWargaPage();
                        break;
                      case 6:
                        targetPage = const WisataPage();
                        break;
                      case 7:
                        targetPage = const SemuaLayananPage();
                        break;
                      default:
                        targetPage = BerandaPage(onNavigateToProfile: () {});
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => targetPage),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 54,
                        width: 54,
                        decoration: BoxDecoration(
                          color: iconColor.withValues(
                            alpha: isDark ? 0.2 : 0.1,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          menuServices[index]['icon'],
                          color: iconColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        menuServices[index]['title'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.grey[300]
                              : const Color(0xFF494A4E),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                index * 50,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencySection(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sitalang Siaga (Darurat)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A365D),
                ),
              ),
              const Icon(
                Icons.warning_rounded,
                color: Color(0xFFCB201E),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildEmergencyCard(
                  context,
                  'Darurat Umum',
                  '112',
                  Icons.shield_rounded,
                  const Color(0xFF1A365D),
                  isDark,
                ),
                _buildEmergencyCard(
                  context,
                  'Polisi',
                  '110',
                  Icons.local_police_rounded,
                  const Color(0xFF1A365D),
                  isDark,
                ),
                _buildEmergencyCard(
                  context,
                  'Pemadam',
                  '113',
                  Icons.fire_truck_rounded,
                  const Color(0xFFCB201E),
                  isDark,
                ),
                _buildEmergencyCard(
                  context,
                  'Ambulans',
                  '118 dan 119',
                  Icons.medical_services_rounded,
                  Colors.green,
                  isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard(
    BuildContext context,
    String title,
    String number,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Memanggil $title ($number)...'),
          backgroundColor: color,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                Text(
                  number,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpotlightBerita(bool isDark) {
    if (_beritaTerbaru.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Spotlight Nagari',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF1A365D),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentNewsIndex = index),
            itemCount: _beritaTerbaru.length,
            itemBuilder: (context, index) {
              final berita = _beritaTerbaru[index];
              double scale = _currentNewsIndex == index ? 1.0 : 0.9;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutQuint,
                transform: Matrix4.identity()..scale(scale, scale),
                margin: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      if (berita['foto_path'] != null &&
                          berita['foto_path'] != '')
                        Image.file(
                          File(berita['foto_path']),
                          height: 260,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      else
                        Container(
                          color: const Color(0xFF1A365D),
                          child: const Center(
                            child: Icon(
                              Icons.campaign_rounded,
                              color: Colors.white30,
                              size: 80,
                            ),
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00CED1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'INFO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              berita['judul'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              berita['deskripsi'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _beritaTerbaru.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentNewsIndex == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentNewsIndex == index
                    ? const Color(0xFF00CED1)
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
