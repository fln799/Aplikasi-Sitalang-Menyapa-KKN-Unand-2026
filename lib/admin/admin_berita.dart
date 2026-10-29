import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sitalang_menyapa/database/db_helper.dart';

class KelolaBeritaPage extends StatefulWidget {
  final String table;
  final String title;
  const KelolaBeritaPage({super.key, required this.table, required this.title});

  @override
  State<KelolaBeritaPage> createState() => _KelolaBeritaPageState();
}

class _KelolaBeritaPageState extends State<KelolaBeritaPage> {
  List<Map<String, dynamic>> _dataList = [];
  final _ctrlJudul = TextEditingController();
  final _ctrlDeskripsi = TextEditingController();
  final _ctrlLink = TextEditingController();
  File? _selectedImage;

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _simpan(int? editId) async {
    if (_ctrlJudul.text.isEmpty || _ctrlDeskripsi.text.isEmpty) return;

    String imagePath = '';
    if (_selectedImage != null) {
      imagePath = await DBHelper().saveImagePermanently(_selectedImage!.path);
    } else if (editId != null) {
      // Pertahankan gambar lama jika tidak diganti saat mode edit
      final existingItem = _dataList.firstWhere(
        (element) => element['id'] == editId,
      );
      imagePath = existingItem['foto_path'] ?? '';
    }

    Map<String, dynamic> data = {};
    if (widget.table == 'berita') {
      data = {
        'judul': _ctrlJudul.text,
        'deskripsi': _ctrlDeskripsi.text,
        'tanggal': DateTime.now().toString().substring(0, 10),
        'foto_path': imagePath,
      };
    } else if (widget.table == 'wisata') {
      data = {
        'nama': _ctrlJudul.text,
        'deskripsi': _ctrlDeskripsi.text,
        'link_maps': _ctrlLink.text.isNotEmpty
            ? _ctrlLink.text
            : 'https://maps.google.com',
        'foto_path': imagePath,
      };
    }

    if (editId == null) {
      await DBHelper().insertData(widget.table, data);
    } else {
      await DBHelper().updateDataGlobal(widget.table, data, editId);
    }

    _ctrlJudul.clear();
    _ctrlDeskripsi.clear();
    _ctrlLink.clear();
    setState(() => _selectedImage = null);

    if (mounted) Navigator.pop(context);
    _loadData();
  }

  void _showAddDialog({Map<String, dynamic>? item}) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    String labelJudul = widget.table == 'berita'
        ? 'Judul Berita'
        : 'Nama Tempat Wisata';
    String labelDeskripsi = 'Deskripsi Lengkap';

    int? editId;
    if (item != null) {
      editId = item['id'];
      _ctrlJudul.text = widget.table == 'berita' ? item['judul'] : item['nama'];
      _ctrlDeskripsi.text = item['deskripsi'];
      if (widget.table == 'wisata') _ctrlLink.text = item['link_maps'] ?? '';

      // Mencegah error null saat meload gambar lama
      if (item['foto_path'] != null &&
          item['foto_path'].toString().isNotEmpty) {
        _selectedImage = File(item['foto_path']);
      } else {
        _selectedImage = null;
      }
    } else {
      _ctrlJudul.clear();
      _ctrlDeskripsi.clear();
      _ctrlLink.clear();
      _selectedImage = null;
    }

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
                    Text(
                      item == null ? 'Tambah Data Baru' : 'Edit Data',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    GestureDetector(
                      onTap: () async {
                        await _pickImage();
                        setModalState(() {});
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2A2A2A)
                              : const Color(0xFFF4F6F9),
                          borderRadius: BorderRadius.circular(16),
                          image: _selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(_selectedImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _selectedImage == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Tambahkan Foto',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _ctrlJudul,
                      decoration: InputDecoration(
                        labelText: labelJudul,
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
                      controller: _ctrlDeskripsi,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: labelDeskripsi,
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

                    if (widget.table == 'wisata')
                      TextField(
                        controller: _ctrlLink,
                        decoration: InputDecoration(
                          labelText: 'Link Google Maps',
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

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text('Kelola ${widget.title}'),
        backgroundColor: const Color(0xFF1A365D),
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
                String titleText = widget.table == 'berita'
                    ? item['judul']
                    : item['nama'];

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
                    contentPadding: const EdgeInsets.all(12),

                    // --- PERBAIKAN UTAMA ADA DI SINI (Penambahan Pengecekan != null) ---
                    leading:
                        (item['foto_path'] != null &&
                            item['foto_path'].toString().isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(item['foto_path']),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF1A365D,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Color(0xFF1A365D),
                            ),
                          ),

                    title: Text(
                      titleText,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      item['deskripsi'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(),
        backgroundColor: const Color(0xFF00CED1),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
