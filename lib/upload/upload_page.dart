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
      appBar: AppBar(title: const Text('Upload Laporan'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// IMAGE PREVIEW
            GestureDetector(
              key: const Key('upload_image_area'),
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade300,
                ),
                child: image == null
                    ? const Center(child: Icon(Icons.camera_alt, size: 50))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            /// ADDRESS
            if (address != null)
              Row(
                children: [
                  const Icon(Icons.location_on, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(address!, style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),

            const Spacer(),

            /// UPLOAD BUTTON
            ElevatedButton.icon(
              key: const Key('upload_button'),
              onPressed: loading ? null : _upload,
              icon: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload),
              label: const Text('Upload'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
