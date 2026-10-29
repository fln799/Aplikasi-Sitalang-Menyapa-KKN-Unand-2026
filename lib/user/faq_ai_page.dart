import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart'; // Package AI Pintar

class FaqAiPage extends StatefulWidget {
  const FaqAiPage({super.key});

  @override
  State<FaqAiPage> createState() => _FaqAiPageState();
}

class _FaqAiPageState extends State<FaqAiPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;

  // GANTI TEKS INI DENGAN API KEY DARI GOOGLE AI STUDIO
  final String apiKey = 'MASUKKAN_API_KEY_ANDA_DISINI';

  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  bool _isLoading = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text':
          'Halo Warga! Saya SITA (Sistem Informasi & Tanya-jawab Andal) 🤖.\nSaya adalah AI cerdas. Tanyakan apa saja tentang layanan Nagari Sitalang!',
      'isActionable': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // MENDIDIK AI: Memberikan instruksi kepribadian kepada Gemini
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(
        'Kamu adalah SITA, Asisten AI resmi untuk aplikasi Nagari Sitalang. '
        'Kamu ramah, sopan, membantu, dan menggunakan bahasa Indonesia yang baik. '
        'Tugasmu adalah menjawab pertanyaan warga mengenai layanan desa seperti: pembuatan KTP/KK/Surat Pengantar, informasi UMKM lokal, kabar nagari, layanan kesehatan, dan wisata. '
        'Jika ada warga yang melaporkan masalah (jalan rusak, bencana, fasilitas rusak) ATAU jika kamu tidak tahu jawabannya, sarankan mereka untuk menghubungi Admin Nagari Sitalang atau gunakan fitur "Lapor Wali". '
        'Jawablah dengan singkat, padat, dan langsung pada intinya.',
      ),
    );
    // Memulai sesi chat agar AI ingat percakapan sebelumnya
    _chatSession = _model.startChat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // =================================================================
  // LOGIKA CHAT DENGAN GEMINI AI ASLI
  // =================================================================
  Future<void> _sendMessage() async {
    final userText = _chatController.text.trim();
    if (userText.isEmpty) return;

    setState(() {
      _messages.add({'isUser': true, 'text': userText, 'isActionable': false});
      _isLoading = true; // Munculkan indikator AI sedang mengetik
    });

    _chatController.clear();
    _scrollToBottom();

    try {
      // Mengirim pesan ke server Google Gemini
      final response = await _chatSession.sendMessage(Content.text(userText));
      final aiText =
          response.text ?? 'Maaf, SITA sedang mengalami gangguan koneksi.';

      // Cek otomatis: Apakah balasan AI mengandung saran untuk menghubungi admin?
      bool needsAdmin =
          aiText.toLowerCase().contains('admin') ||
          aiText.toLowerCase().contains('lapor wali');

      setState(() {
        _messages.add({
          'isUser': false,
          'text': aiText,
          'isActionable': needsAdmin,
        });
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.add({
          'isUser': false,
          'text':
              'Aduh, SITA tidak bisa terhubung ke server. Pastikan API Key sudah dimasukkan dengan benar dan internet aktif ya!',
          'isActionable': false,
        });
      });
      _scrollToBottom();
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
        backgroundColor: const Color(0xFF1A365D),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.1).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeInOut,
                ),
              ),
              child: const CircleAvatar(
                backgroundColor: Color(0xFF00CED1),
                radius: 18,
                child: Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SITA AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Online - Didukung oleh Gemini',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildChatBubble(
                  _messages[index]['text'],
                  _messages[index]['isUser'],
                  _messages[index]['isActionable'],
                  isDark,
                );
              },
            ),
          ),

          // Indikator AI Sedang Mengetik
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'SITA sedang berpikir...',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

          _buildInputArea(isDark),
        ],
      ),
    );
  }

  Widget _buildChatBubble(
    String text,
    bool isUser,
    bool isActionable,
    bool isDark,
  ) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFF00CED1)
              : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isUser
                    ? Colors.white
                    : (isDark ? Colors.white : const Color(0xFF494A4E)),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            if (isActionable) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCB201E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Menyambungkan Anda ke Admin Nagari...'),
                      backgroundColor: Color(0xFF1A365D),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.support_agent_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                label: const Text(
                  'Hubungi Admin',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _chatController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Tanya apa saja ke SITA...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFF4F6F9),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (value) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A365D),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
