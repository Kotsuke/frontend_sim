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
      appBar: AppBar(title: const Text('Map'), centerTitle: true),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
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
                        ? Colors.red
                        : Colors.orange;

                    return Marker(
                      point: LatLng(post['lat'], post['long']),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          _showPostDetail(post);
                        },
                        child: Icon(Icons.location_on, size: 40, color: color),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }

  /// POPUP DETAIL POST
  void _showPostDetail(dynamic post) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post['uploaded_by'] ?? 'User',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(post['address'] ?? '-', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post['image_url'] ?? '',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.broken_image)),
                      ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Chip(
                    label: Text(
                      post['severity'],
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: post['severity'] == 'SERIUS'
                        ? Colors.red
                        : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text('🕳 ${post['pothole_count']} lubang'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
