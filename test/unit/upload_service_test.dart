import 'package:flutter_test/flutter_test.dart';

class UploadService {
  bool uploadImage(String? filePath) {
    if (filePath == null) return false;
    if (filePath.isEmpty) return false;
    return true;
  }
}

void main() {
  group('Upload Service Test', () {
    test('Upload berhasil jika path ada', () {
      final service = UploadService();
      expect(service.uploadImage('image.jpg'), true);
    });

    test('Upload gagal jika path kosong', () {
      final service = UploadService();
      expect(service.uploadImage(''), false);
    });

    test('Upload gagal jika path null', () {
      final service = UploadService();
      expect(service.uploadImage(null), false);
    });
  });
}
