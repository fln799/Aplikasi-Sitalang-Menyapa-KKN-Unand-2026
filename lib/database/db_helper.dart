import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  factory DBHelper() => _instance;
  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // MENGUBAH KE v7 AGAR DATABASE LAMA DIHAPUS & DIGANTI DENGAN STRUKTUR BARU YANG ADA KOLOM 'WARNA'
  Future<Database> _initDB() async {
    String p = join(await getDatabasesPath(), 'sitalang_v7.db');
    return await openDatabase(p, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT UNIQUE, nama TEXT, whatsapp TEXT UNIQUE, password TEXT, role TEXT, foto_profil TEXT)',
    );
    await db.execute(
      "INSERT INTO users (username, nama, whatsapp, password, role, foto_profil) VALUES ('admin', 'Super Admin', '081234567890', 'admin123', 'admin', '')",
    );
    await db.execute(
      'CREATE TABLE session (id INTEGER PRIMARY KEY, user_id INTEGER, nama TEXT, username TEXT, whatsapp TEXT, foto_profil TEXT, role TEXT)',
    );

    // TABEL BERITA DENGAN DATA CONTOH
    await db.execute(
      'CREATE TABLE berita (id INTEGER PRIMARY KEY AUTOINCREMENT, judul TEXT, deskripsi TEXT, tanggal TEXT, foto_path TEXT)',
    );
    await db.execute(
      "INSERT INTO berita (judul, deskripsi, tanggal) VALUES ('Gotong Royong Bersihkan Irigasi', 'Warga Dusun 1 mengadakan gotong royong massal membersihkan saluran irigasi menjelang musim tanam.', '2026-07-28'), ('Penyaluran BLT Dana Desa', 'Pemerintah Nagari Sitalang sukses menyalurkan Bantuan Langsung Tunai (BLT) tahap ke-3.', '2026-07-30')",
    );

    // TABEL UMKM DENGAN DATA CONTOH
    await db.execute(
      'CREATE TABLE umkm (id INTEGER PRIMARY KEY AUTOINCREMENT, nama TEXT, pemilik TEXT, harga TEXT, kontak TEXT)',
    );
    await db.execute(
      "INSERT INTO umkm (nama, pemilik, harga, kontak) VALUES ('Kripik Balado Mak Etek', 'Ibu Rahma', 'Rp 15.000 - 35.000', '0812xxxx'), ('Kopi Robusta Sitalang', 'Bpk. Hendra', 'Rp 25.000 / Pcs', '0823xxxx'), ('Kerajinan Anyaman Bambu', 'Sari', 'Mulai Rp 50.000', '0813xxxx')",
    );

    // TABEL SURAT DENGAN DATA CONTOH
    await db.execute(
      'CREATE TABLE surat (id INTEGER PRIMARY KEY AUTOINCREMENT, nama_surat TEXT, syarat TEXT)',
    );
    await db.execute(
      "INSERT INTO surat (nama_surat, syarat) VALUES ('Surat Keterangan Domisili', '- Fotokopi KTP\n- Fotokopi KK\n- Pengantar RT/RW'), ('Surat Pengantar Nikah', '- KTP Calon Suami & Istri\n- Fotokopi KK\n- Pas Foto 3x4 (2 Lembar)'), ('Surat Keterangan Tidak Mampu (SKTM)', '- Surat Pengantar RT\n- Fotokopi KTP & KK\n- Foto Rumah Tampak Depan')",
    );

    // TABEL WISATA DENGAN DATA CONTOH
    await db.execute(
      'CREATE TABLE wisata (id INTEGER PRIMARY KEY AUTOINCREMENT, nama TEXT, deskripsi TEXT, link_maps TEXT, foto_path TEXT)',
    );
    await db.execute(
      "INSERT INTO wisata (nama, deskripsi, link_maps) VALUES ('Air Terjun Bukit Barisan', 'Nikmati kesejukan air terjun alami dengan pemandangan hutan tropis yang asri. Cocok untuk liburan keluarga.', 'https://maps.google.com'), ('Puncak Paralayang', 'Spot terbaik untuk melihat keindahan Nagari Sitalang dari ketinggian saat matahari terbenam.', 'https://maps.google.com')",
    );

    // TABEL KESEHATAN (FASKES) DENGAN DATA CONTOH
    await db.execute(
      'CREATE TABLE kesehatan (id INTEGER PRIMARY KEY AUTOINCREMENT, nama_faskes TEXT, jadwal TEXT, kontak TEXT)',
    );
    await db.execute(
      "INSERT INTO kesehatan (nama_faskes, jadwal, kontak) VALUES ('Puskesmas Pembantu (Pustu)', 'Senin - Jumat: 08.00 - 14.00 WIB\nSabtu: 08.00 - 12.00 WIB', '0811xxxx'), ('Klinik Bidan Desa', 'Setiap Hari (Standby 24 Jam untuk Persalinan)', '0852xxxx')",
    );

    // TABEL KEGIATAN MASJID DENGAN DATA CONTOH
    await db.execute(
      'CREATE TABLE kegiatan_masjid (id INTEGER PRIMARY KEY AUTOINCREMENT, nama_kegiatan TEXT, jadwal TEXT, ustadz TEXT)',
    );
    await db.execute(
      "INSERT INTO kegiatan_masjid (nama_kegiatan, jadwal, ustadz) VALUES ('Kajian Tafsir Al-Quran', 'Setiap Ba''da Maghrib (Rabu)', 'Ustadz H. Abdul Somad'), ('Didikan Subuh Anak TPA', 'Minggu Pagi (05.30 WIB)', 'Ustadz Ilham')",
    );

    // TABEL PENYAKIT (KINI PASTI ADA KOLOM 'WARNA')
    await db.execute(
      'CREATE TABLE persebaran_penyakit (id INTEGER PRIMARY KEY AUTOINCREMENT, nama_penyakit TEXT, deskripsi TEXT, jumlah TEXT, warna TEXT)',
    );
    await db.execute(
      "INSERT INTO persebaran_penyakit (nama_penyakit, deskripsi, jumlah, warna) VALUES ('Hipertensi', 'Terdeteksi pada Lansia & Dewasa', '185', 'Oranye'), ('Diabetes', 'Dominan pada usia 40+ Tahun', '92', 'Ungu'), ('ISPA', 'Sering terjadi saat pergantian musim', '45', 'Merah'), ('Asam Urat', 'Sering dikeluhkan warga lansia', '120', 'Teal')",
    );

    await db.execute(
      'CREATE TABLE reports (id INTEGER PRIMARY KEY AUTOINCREMENT, pengirim TEXT, kategori TEXT, lokasi TEXT, deskripsi TEXT, status TEXT, tanggal TEXT, foto_path TEXT)',
    );
    await db.execute(
      'CREATE TABLE statistik_warga (id INTEGER PRIMARY KEY AUTOINCREMENT, kategori TEXT, jumlah TEXT)',
    );

    await db.execute(
      'CREATE TABLE data_warga_utama (id INTEGER PRIMARY KEY, total INTEGER, balita_l INTEGER, balita_p INTEGER, anak_l INTEGER, anak_p INTEGER, remaja_l INTEGER, remaja_p INTEGER, dewasa_l INTEGER, dewasa_p INTEGER, lansia_l INTEGER, lansia_p INTEGER, thn_1 INTEGER, thn_2 INTEGER, thn_3 INTEGER, thn_4 INTEGER, thn_5 INTEGER, label_thn_1 TEXT, label_thn_2 TEXT, label_thn_3 TEXT, label_thn_4 TEXT, label_thn_5 TEXT)',
    );
    await db.execute(
      "INSERT INTO data_warga_utama (id, total, balita_l, balita_p, anak_l, anak_p, remaja_l, remaja_p, dewasa_l, dewasa_p, lansia_l, lansia_p, thn_1, thn_2, thn_3, thn_4, thn_5, label_thn_1, label_thn_2, label_thn_3, label_thn_4, label_thn_5) VALUES (1, 2540, 110, 105, 150, 145, 210, 230, 620, 650, 130, 185, 2350, 2400, 2480, 2510, 2540, '2022', '2023', '2024', '2025', '2026')",
    );

    await db.execute(
      'CREATE TABLE data_kesehatan_utama (id INTEGER PRIMARY KEY, total_domisili INTEGER, hipertensi INTEGER, diabetes INTEGER, ispa INTEGER, balita_l TEXT, balita_p TEXT, remaja_l TEXT, remaja_p TEXT, lansia_l TEXT, lansia_p TEXT)',
    );
    await db.execute(
      "INSERT INTO data_kesehatan_utama (id, total_domisili, hipertensi, diabetes, ispa, balita_l, balita_p, remaja_l, remaja_p, lansia_l, lansia_p) VALUES (1, 2540, 185, 92, 45, '90%', '92%', '98%', '99%', '75%', '82%')",
    );
  }

  Future<void> updateDataUtama(String table, Map<String, dynamic> data) async {
    Database db = await database;
    await db.update(table, data, where: 'id = ?', whereArgs: [1]);
  }

  Future<String> saveImagePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = basename(imagePath);
    final image = File(imagePath);
    final savedImage = await image.copy('${directory.path}/$name');
    return savedImage.path;
  }

  Future<int> insertData(String table, Map<String, dynamic> data) async {
    Database db = await database;
    try {
      return await db.insert(table, data);
    } catch (e) {
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getAllData(String table) async {
    Database db = await database;
    return await db.query(table, orderBy: 'id DESC');
  }

  Future<int> deleteData(String table, int id) async {
    Database db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateDataGlobal(
    String table,
    Map<String, dynamic> data,
    int id,
  ) async {
    Database db = await database;
    return await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> loginUser(
    String identifier,
    String pass,
  ) async {
    Database db = await database;
    List<Map<String, dynamic>> res = await db.query(
      'users',
      where: '(username = ? OR whatsapp = ?) AND password = ?',
      whereArgs: [identifier, identifier, pass],
    );
    if (res.isNotEmpty) {
      await db.delete('session');
      await db.insert('session', {
        'user_id': res.first['id'],
        'nama': res.first['nama'],
        'username': res.first['username'],
        'whatsapp': res.first['whatsapp'],
        'foto_profil': res.first['foto_profil'] ?? '',
        'role': res.first['role'],
      });
      return res.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getActiveSession() async {
    Database db = await database;
    var res = await db.query('session');
    if (res.isNotEmpty) {
      var userRes = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [res.first['user_id']],
      );
      if (userRes.isNotEmpty) {
        return {
          'user_id': userRes.first['id'],
          'id': userRes.first['id'],
          'nama': userRes.first['nama'],
          'username': userRes.first['username'],
          'whatsapp': userRes.first['whatsapp'],
          'foto_profil': userRes.first['foto_profil'] ?? '',
          'role': userRes.first['role'],
        };
      }
      return res.first;
    }
    return null;
  }

  Future<void> logout() async {
    Database db = await database;
    await db.delete('session');
  }

  Future<void> updateProfilePic(int userId, String path) async {
    Database db = await database;
    await db.update(
      'users',
      {'foto_profil': path},
      where: 'id = ?',
      whereArgs: [userId],
    );
    await db.update(
      'session',
      {'foto_profil': path},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> updateProfil(int userId, String nama, String whatsapp) async {
    Database db = await database;
    await db.update(
      'users',
      {'nama': nama, 'whatsapp': whatsapp},
      where: 'id = ?',
      whereArgs: [userId],
    );
    await db.update(
      'session',
      {'nama': nama, 'whatsapp': whatsapp},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<bool> ubahSandi(int userId, String sandiLama, String sandiBaru) async {
    Database db = await database;
    var res = await db.query(
      'users',
      where: 'id = ? AND password = ?',
      whereArgs: [userId, sandiLama],
    );
    if (res.isNotEmpty) {
      await db.update(
        'users',
        {'password': sandiBaru},
        where: 'id = ?',
        whereArgs: [userId],
      );
      return true;
    }
    return false;
  }

  Future<List<Map<String, dynamic>>> getUsersOnly() async {
    Database db = await database;
    return await db.query(
      'users',
      where: 'role = ?',
      whereArgs: ['warga'],
      orderBy: 'id DESC',
    );
  }

  // =========================================================================
  // FUNGSI BARU UNTUK SIGNUP PAGE (Hanya bagian ini yang diubah/ditambahkan)
  // =========================================================================
  Future<bool> registerUser(
    String nama,
    String username,
    String whatsapp,
    String password,
  ) async {
    Database db = await database;
    try {
      await db.insert('users', {
        'nama': nama,
        'username': username,
        'whatsapp': whatsapp,
        'password': password,
        'role': 'warga',
        'foto_profil': '',
      });
      return true; // Berhasil daftar
    } catch (e) {
      return false; // Gagal (Misal: Username/WA sudah pernah didaftarkan)
    }
  }
}
