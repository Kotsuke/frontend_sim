import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../core/post_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List markers = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    try {
      final posts = await PostService.getPosts();
      setState(() {
        markers = posts;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'MAP',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
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
          : Stack(
              children: [
                FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(-6.200000, 106.816666), // Jakarta
                    initialZoom: 11,
                  ),
                  children: [
                    /// TILE OSM (GRATIS)
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.smartinfra',
                    ),

                    /// MARKERS
                    MarkerLayer(
                      markers: markers.map((post) {
                        Color color = post['severity'] == 'SERIUS'
                            ? Colors.red.shade600
                            : Colors.orange.shade600;

                        return Marker(
                          point: LatLng(post['lat'], post['long']),
                          width: 50,
                          height: 50,
                          child: GestureDetector(
                            onTap: () {
                              _showPostDetail(post);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.location_on, size: 30, color: Colors.white),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                // // Optional: Tambahkan overlay untuk info tambahan, seperti legenda atau FAB
                // Positioned(
                //   bottom: 20,
                //   right: 20,
                //   child: FloatingActionButton(
                //     onPressed: () {
                //       // Tambahkan aksi, misalnya refresh atau zoom to current location
                //     },
                //     backgroundColor: Colors.blue.shade700,
                //     elevation: 6,
                //     child: const Icon(Icons.my_location, color: Colors.white),
                //   ),
                // ),
              ],
            ),
    );
  }

  /// POPUP DETAIL POST
  void _showPostDetail(dynamic post) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      elevation: 10,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade50],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post['uploaded_by'] ?? 'User',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                post['address'] ?? '-',
                style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  post['image_url'] ?? '',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                      ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: post['severity'] == 'SERIUS' ? Colors.red.shade600 : Colors.orange.shade600,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Text(
                      post['severity'],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      Icon(Icons.warning_amber, size: 20, color: Colors.amber.shade700),
                      const SizedBox(width: 6),
                      Text(
                        '${post['pothole_count']} lubang',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
