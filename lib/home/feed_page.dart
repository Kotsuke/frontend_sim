import 'package:flutter/material.dart';
import '../core/post_service.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List posts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  /// ================= LOAD FEED =================
  Future<void> _loadFeed() async {
    try {
      final data = await PostService.getPosts();
      setState(() {
        posts = data;
        loading = false;
      });
    } catch (e) {
      print('Error loading feed: $e'); // Debugging
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat feed: $e')));
      }
    }
  }

  /// ================= VERIFY POST (JWT) =================
  Future<void> _verify(int postId, String type) async {
    bool success = await PostService.verifyPost(
      postId: postId,
      type: type, // CONFIRM / FALSE
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verifikasi berhasil disimpan')),
        );
      }
      _loadFeed(); // refresh feed
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal verifikasi')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Smart Infra',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 2, offset: Offset(1, 1))],
                ),
              ),
            ),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.blue.shade200,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : RefreshIndicator(
              onRefresh: _loadFeed,
              color: Colors.blue,
              child: posts.isEmpty
                  ? const Center(
                      child: Text(
                        "Belum ada laporan",
                        style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 12),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return _postCard(post);
                      },
                    ),
            ),
    );
  }

  /// ================= POST CARD =================
  Widget _postCard(dynamic post) {
    final bool isSerious = post['severity'] == 'SERIUS';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== IMAGE =====
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                post['image_url'] ?? '',
                headers: const {'ngrok-skip-browser-warning': 'true'},
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 240,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== USER + SEVERITY =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        post['uploaded_by'] ?? 'User',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSerious ? Colors.red.shade600 : Colors.orange.shade600,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: Text(
                          post['severity'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // ===== ADDRESS =====
                  Text(
                    post['address'] ?? 'Lokasi tidak diketahui',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                  ),

                  const SizedBox(height: 12),

                  // ===== INFO =====
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        size: 20,
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${post['pothole_count']} lubang',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ===== VERIFICATION STATUS =====
                  if (post['verification']['valid'] > 0 ||
                      post['verification']['false'] > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            post['verification']['valid'] >=
                                post['verification']['false']
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: post['verification']['valid'] >=
                                  post['verification']['false']
                              ? Colors.green.shade300
                              : Colors.red.shade300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            post['verification']['valid'] >=
                                    post['verification']['false']
                                ? Icons.check_circle
                                : Icons.cancel,
                            size: 18,
                            color:
                                post['verification']['valid'] >=
                                    post['verification']['false']
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            post['verification']['valid'] >=
                                    post['verification']['false']
                                ? "Terverifikasi Komunitas"
                                : "Ditolak Warga",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color:
                                  post['verification']['valid'] >=
                                      post['verification']['false']
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // ===== CAPTION =====
                  Text(
                    post['caption'] ?? '',
                    style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
                  ),

                  const SizedBox(height: 14),
                  const Divider(color: Colors.grey, thickness: 0.5),

                  // ===== ACTION BUTTON =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _actionButton(
                        icon: Icons.thumb_up_alt,
                        label: post['verification']['valid'].toString(),
                        onTap: () => _verify(post['id'], 'CONFIRM'),
                      ),
                      _actionButton(
                        icon: Icons.thumb_down_alt,
                        label: post['verification']['false'].toString(),
                        onTap: () => _verify(post['id'], 'FALSE'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= ACTION BUTTON =================
  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(25),
      onTap: onTap,
      splashColor: Colors.blue.withOpacity(0.2),
      highlightColor: Colors.blue.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Colors.grey.shade700),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
