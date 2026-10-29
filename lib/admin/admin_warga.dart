import 'package:flutter/material.dart';
import 'package:sitalang_menyapa/database/db_helper.dart';

class KelolaWargaPage extends StatefulWidget {
  const KelolaWargaPage({super.key});
  @override
  State<KelolaWargaPage> createState() => _KelolaWargaPageState();
}

class _KelolaWargaPageState extends State<KelolaWargaPage> {
  List<Map<String, dynamic>> _usersList = [];
  final Map<int, bool> _showPassword = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final data = await DBHelper().getUsersOnly();
    setState(() => _usersList = data);
  }

  Future<void> _hapusUser(int id, String nama) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Warga?'),
        content: Text('Hapus "$nama"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCB201E),
            ),
            onPressed: () async {
              await DBHelper().deleteData('users', id);
              if (mounted) Navigator.pop(ctx);
              _loadUsers();
            },
            child: const Text(
              'Ya, Hapus',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
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
        title: const Text(
          'Database Warga Terdaftar',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A365D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _usersList.isEmpty
          ? const Center(
              child: Text(
                'Belum ada warga.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _usersList.length,
              itemBuilder: (context, index) {
                final user = _usersList[index];
                final int userId = user['id'];
                final bool isPassVisible = _showPassword[userId] ?? false;
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF00CED1).withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(
                                0xFF00CED1,
                              ).withValues(alpha: 0.2),
                              child: Text(
                                user['nama'][0].toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00CED1),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                user['nama'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1A365D),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.person_remove_rounded,
                                color: Color(0xFFCB201E),
                              ),
                              onPressed: () => _hapusUser(userId, user['nama']),
                            ),
                          ],
                        ),
                        Divider(
                          color: Colors.grey.withValues(alpha: 0.2),
                          height: 24,
                          thickness: 1,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.alternate_email_rounded,
                              color: Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Username',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  user['username'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.lock_outline_rounded,
                              color: Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Sandi',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    isPassVisible
                                        ? user['password']
                                        : '••••••••',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isPassVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _showPassword[userId] = !isPassVisible,
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
