import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../core/upload_service.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? image;
  String? address;
  double? latitude;
  double? longitude;
  bool loading = false;

  /// ================= PICK IMAGE =================
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (picked == null) return;

    setState(() {
      image = File(picked.path);
    });

    await _getLocation();
  }

  /// ================= GET LOCATION + ADDRESS =================
  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('GPS tidak aktif')));
      return;
    }

    // Cek Permission sederhana (asumsi sudah di-handle di main, tapi buat safety)
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10), // Timeout 10 detik
      );

      latitude = position.latitude;
      longitude = position.longitude;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude!,
        longitude!,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          address =
              "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}";
        });
      }
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengambil lokasi')));
    }
  }

  /// ================= UPLOAD (JWT) =================
  Future<void> _upload() async {
    if (image == null ||
        latitude == null ||
        longitude == null ||
        address == null) {
      return;
    }

    setState(() => loading = true);

    try {
      bool success = await UploadService.uploadPost(
        image: image!,
        latitude: latitude!,
        longitude: longitude!,
        address: address!,
      );

      setState(() => loading = false);

      if (success) {
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan berhasil diupload')),
        );
        setState(() {
          image = null;
          address = null;
          latitude = null;
          longitude = null;
        });
      } else {
        if(!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Upload gagal')));
      }
    } catch (e) {
      setState(() => loading = false);
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Upload Laporan',
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// IMAGE PREVIEW
            GestureDetector(
              key: const Key('upload_image_area'),
              onTap: _pickImage,
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade200,
                  border: Border.all(color: Colors.grey.shade400, width: 2),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                  gradient: LinearGradient(
                    colors: [Colors.grey.shade100, Colors.grey.shade300],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: image == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 60, color: Colors.grey.shade600),
                          const SizedBox(height: 8),
                          Text(
                            'Tap untuk pilih gambar',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            /// ADDRESS
            if (address != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200, width: 1),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 20, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        address!,
                        style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

            const Spacer(),

            /// UPLOAD BUTTON
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: loading ? [Colors.grey.shade400, Colors.grey.shade600] : [Colors.blue.shade600, Colors.blue.shade800],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: loading ? [] : [BoxShadow(color: Colors.blue.shade300, blurRadius: 8, offset: Offset(0, 4))],
              ),
              child: ElevatedButton.icon(
                key: const Key('upload_button'),
                onPressed: loading ? null : _upload,
                icon: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.cloud_upload, color: Colors.white),
                label: Text(
                  loading ? 'Mengupload...' : 'Upload Laporan',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
