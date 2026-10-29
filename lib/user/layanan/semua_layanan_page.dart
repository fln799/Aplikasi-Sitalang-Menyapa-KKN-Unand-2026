import 'package:flutter/material.dart';

class KeamananRondaPage extends StatelessWidget {
  const KeamananRondaPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Jadwal Keamanan Ronda',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A365D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildRondaItem(
            'Senin Malam',
            'Pos Kamling Dusun 1',
            'Bpk. Ahmad, Bpk. Budi, Bpk. Yanto',
          ),
          _buildRondaItem(
            'Selasa Malam',
            'Pos Kamling Dusun 2',
            'Bpk. Surya, Bpk. Doni, Bpk. Iwan',
          ),
          _buildRondaItem(
            'Rabu Malam',
            'Pos Kamling Dusun 3',
            'Bpk. Hendra, Bpk. Joko, Bpk. Rizal',
          ),
        ],
      ),
    );
  }

  Widget _buildRondaItem(String hari, String pos, String petugas) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF1A365D),
          child: Icon(Icons.shield_rounded, color: Colors.white),
        ),
        title: Text(hari, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$pos\nPetugas: $petugas"),
        isThreeLine: true,
      ),
    );
  }
}

class HargaPasarPage extends StatelessWidget {
  const HargaPasarPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Harga Pangan Pasar Desa',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A365D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPasarItem('Beras Premium', 'Rp 16.000 / Kg', true),
          _buildPasarItem('Minyak Goreng', 'Rp 18.000 / Liter', false),
          _buildPasarItem('Telur Ayam', 'Rp 28.000 / Kg', true),
          _buildPasarItem('Cabai Merah', 'Rp 65.000 / Kg', true),
        ],
      ),
    );
  }

  Widget _buildPasarItem(String barang, String harga, bool naik) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          Icons.shopping_basket_rounded,
          color: Colors.green.shade700,
          size: 30,
        ),
        title: Text(
          barang,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              harga,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 8),
            Icon(
              naik ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: naik ? Colors.red : Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class SemuaLayananPage extends StatelessWidget {
  const SemuaLayananPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF121212)
          : const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          'Layanan Lainnya',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A365D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildCard(
            context,
            'Keamanan Ronda',
            Icons.security,
            const Color(0xFF1A365D),
            const KeamananRondaPage(),
          ),
          _buildCard(
            context,
            'Harga Pasar',
            Icons.price_change,
            Colors.green,
            const HargaPasarPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget targetPage,
  ) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetPage),
      ),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
