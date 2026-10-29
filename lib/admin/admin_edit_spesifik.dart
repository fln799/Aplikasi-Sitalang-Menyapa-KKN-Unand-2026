import 'package:flutter/material.dart';
import 'package:sitalang_menyapa/database/db_helper.dart';

class AdminEditSpesifikPage extends StatefulWidget {
  final String tipeData; // 'warga' atau 'kesehatan'
  const AdminEditSpesifikPage({super.key, required this.tipeData});

  @override
  State<AdminEditSpesifikPage> createState() => _AdminEditSpesifikPageState();
}

class _AdminEditSpesifikPageState extends State<AdminEditSpesifikPage> {
  final Map<String, TextEditingController> _controllers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    String table = widget.tipeData == 'warga'
        ? 'data_warga_utama'
        : 'data_kesehatan_utama';
    final dataList = await DBHelper().getAllData(table);

    if (dataList.isNotEmpty) {
      final data = dataList.first;
      data.forEach((key, value) {
        if (key != 'id')
          _controllers[key] = TextEditingController(text: value.toString());
      });
    }
    setState(() => _isLoading = false);
  }

  TextEditingController _getCtrl(String key) {
    if (!_controllers.containsKey(key))
      _controllers[key] = TextEditingController(text: "0");
    return _controllers[key]!;
  }

  Future<void> _simpanData() async {
    Map<String, dynamic> updatedData = {};
    _controllers.forEach((key, ctrl) {
      if (key.startsWith('label_') ||
          key.endsWith('_l') ||
          key.endsWith('_p') && widget.tipeData == 'kesehatan') {
        updatedData[key] = ctrl.text;
      } else {
        var parsed = int.tryParse(ctrl.text);
        updatedData[key] = parsed ?? ctrl.text;
      }
    });

    String table = widget.tipeData == 'warga'
        ? 'data_warga_utama'
        : 'data_kesehatan_utama';
    await DBHelper().updateDataUtama(table, updatedData);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Data berhasil diperbarui! Tampilan User akan langsung berubah.',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    String title = widget.tipeData == 'warga'
        ? 'Edit Angka Demografi'
        : 'Edit Sensus Penyakit';

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A365D),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00CED1)),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00CED1).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF00CED1).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF00CED1),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Ubah angka di bawah ini. Perubahan akan langsung tampil secara real-time di aplikasi warga.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF1A365D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (widget.tipeData == 'warga') ...[
                  _buildCardSection(
                    title: 'Total Keseluruhan',
                    icon: Icons.groups_rounded,
                    isDark: isDark,
                    children: [
                      _buildTextField(
                        'total',
                        'Total Penduduk Nagari',
                        Icons.pin_rounded,
                        isDark,
                      ),
                    ],
                  ),
                  _buildCardSection(
                    title: 'Pertumbuhan 5 Tahun Terakhir',
                    icon: Icons.bar_chart_rounded,
                    isDark: isDark,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Ubah nama tahun di kiri, dan jumlah penduduk di kanan.',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                      _buildYearEditableRow('label_thn_1', 'thn_1', isDark),
                      _buildYearEditableRow('label_thn_2', 'thn_2', isDark),
                      _buildYearEditableRow('label_thn_3', 'thn_3', isDark),
                      _buildYearEditableRow('label_thn_4', 'thn_4', isDark),
                      _buildYearEditableRow('label_thn_5', 'thn_5', isDark),
                    ],
                  ),
                  _buildCardSection(
                    title: 'Demografi Laki-laki & Perempuan',
                    icon: Icons.wc_rounded,
                    isDark: isDark,
                    children: [
                      _buildRowFields(
                        'balita_l',
                        'Balita (Laki-laki)',
                        'balita_p',
                        'Balita (Perempuan)',
                        Icons.child_friendly_rounded,
                        isDark,
                      ),
                      _buildRowFields(
                        'anak_l',
                        'Anak (Laki-laki)',
                        'anak_p',
                        'Anak (Perempuan)',
                        Icons.child_care_rounded,
                        isDark,
                      ),
                      _buildRowFields(
                        'remaja_l',
                        'Remaja (Laki-laki)',
                        'remaja_p',
                        'Remaja (Perempuan)',
                        Icons.boy_rounded,
                        isDark,
                      ),
                      _buildRowFields(
                        'dewasa_l',
                        'Dewasa (Laki-laki)',
                        'dewasa_p',
                        'Dewasa (Perempuan)',
                        Icons.man_rounded,
                        isDark,
                      ),
                      _buildRowFields(
                        'lansia_l',
                        'Lansia (Laki-laki)',
                        'lansia_p',
                        'Lansia (Perempuan)',
                        Icons.elderly_rounded,
                        isDark,
                      ),
                    ],
                  ),
                ],

                if (widget.tipeData == 'kesehatan') ...[
                  _buildCardSection(
                    title: 'Penduduk Menetap',
                    icon: Icons.home_work_rounded,
                    isDark: isDark,
                    children: [
                      _buildTextField(
                        'total_domisili',
                        'Total Domisili',
                        Icons.pin_rounded,
                        isDark,
                      ),
                    ],
                  ),
                  _buildCardSection(
                    title: 'Persentase Pemantauan (%)',
                    icon: Icons.health_and_safety_rounded,
                    isDark: isDark,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Tambahkan simbol % di belakang angka (Cth: 90%)',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                      _buildRowFields(
                        'balita_l',
                        'Balita (L)',
                        'balita_p',
                        'Balita (P)',
                        Icons.child_friendly_rounded,
                        isDark,
                        isNumber: false,
                      ),
                      _buildRowFields(
                        'remaja_l',
                        'Remaja (L)',
                        'remaja_p',
                        'Remaja (P)',
                        Icons.boy_rounded,
                        isDark,
                        isNumber: false,
                      ),
                      _buildRowFields(
                        'lansia_l',
                        'Lansia (L)',
                        'lansia_p',
                        'Lansia (P)',
                        Icons.elderly_rounded,
                        isDark,
                        isNumber: false,
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A365D),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    onPressed: _simpanData,
                    icon: const Icon(Icons.save_rounded, color: Colors.white),
                    label: const Text(
                      'SIMPAN PERUBAHAN',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildCardSection({
    required String title,
    required IconData icon,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A365D).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF1A365D), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(
    String key,
    String label,
    IconData icon,
    bool isDark, {
    bool isNumber = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: _getCtrl(key),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.normal,
          ),
          prefixIcon: Icon(icon, color: Colors.grey),
          filled: true,
          fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00CED1), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildYearEditableRow(String labelKey, String valueKey, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _getCtrl(labelKey),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                labelText: 'Tahun',
                labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                prefixIcon: const Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.blue,
                  size: 18,
                ),
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: TextField(
              controller: _getCtrl(valueKey),
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                labelText: 'Jumlah Penduduk',
                labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                prefixIcon: const Icon(
                  Icons.people_alt_rounded,
                  color: Colors.teal,
                  size: 18,
                ),
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.teal, width: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowFields(
    String key1,
    String label1,
    String key2,
    String label2,
    IconData icon,
    bool isDark, {
    bool isNumber = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _getCtrl(key1),
              keyboardType: isNumber
                  ? TextInputType.number
                  : TextInputType.text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                labelText: label1,
                labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                prefixIcon: Icon(icon, color: Colors.blue, size: 18),
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _getCtrl(key2),
              keyboardType: isNumber
                  ? TextInputType.number
                  : TextInputType.text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                labelText: label2,
                labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                prefixIcon: Icon(icon, color: Colors.pink, size: 18),
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.pink, width: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
