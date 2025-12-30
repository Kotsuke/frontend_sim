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
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Gagal memuat feed: $e')),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal verifikasi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Infra'), centerTitle: true),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFeed,
              child: posts.isEmpty 
                  ? const Center(child: Text("Belum ada laporan")) 
                  : ListView.builder(
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
    Color severityColor = post['severity'] == 'SERIUS'
        ? Colors.red
        : Colors.orange;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                /// IMAGE
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Builder(
                    builder: (context) {
                       print('DEBUG IMAGE URL: ${post['image_url']}');
                       return Image.network(
                        post['image_url'] ?? '',
                        headers: const {'ngrok-skip-browser-warning': 'true'},
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                              height: 220,
                               color: Colors.grey[300],
                               child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                            ),
                      );
                    }
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// USERNAME
                      Text(
                        post['uploaded_by'] ?? 'User',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      
                      const SizedBox(height: 4),

                      /// ADDRESS
                      Text(
                        post['address'] ?? 'Lokasi tidak diketahui',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),

                const SizedBox(height: 8),

                /// INFO
                Row(
                  children: [
                    Chip(
                      label: Text(
                        post['severity'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: severityColor,
                    ),
                    const SizedBox(width: 8),
                    Text('🕳 ${post['pothole_count']} lubang'),
                  ],
                ),

                const SizedBox(height: 8),

                /// POLLING STATUS
                if (post['verification']['valid'] > 0 || post['verification']['false'] > 0)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: post['verification']['valid'] >= post['verification']['false']
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: post['verification']['valid'] >= post['verification']['false']
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    child: Text(
                      post['verification']['valid'] >= post['verification']['false']
                          ? "✓ Terverifikasi Komunitas"
                          : "✕ Laporan Ditolak Warga",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: post['verification']['valid'] >= post['verification']['false']
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                /// CAPTION
                Text(post['caption'] ?? ''),

                const Divider(),

                /// ACTION BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _actionButton(
                      icon: Icons.thumb_up,
                      label: post['verification']['valid'].toString(),
                      onTap: () => _verify(post['id'], 'CONFIRM'),
                    ),
                    _actionButton(
                      icon: Icons.thumb_down,
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
    );
  }

  /// ================= ACTION BUTTON =================
  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [Icon(icon, size: 20), const SizedBox(width: 6), Text(label)],
      ),
    );
  }
}
