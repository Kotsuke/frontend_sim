import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:capstone_app/upload/upload_page.dart';

void main() {
  testWidgets('UploadPage smoke test', (WidgetTester tester) async {
    // 1. Build widget
    await tester.pumpWidget(const MaterialApp(
      home: UploadPage(),
    ));

    // 2. Cek apakah ada judul 'Upload Laporan'
    expect(find.text('Upload Laporan'), findsOneWidget);

    // 3. Cek apakah area upload gambar ada
    expect(find.byKey(const Key('upload_image_area')), findsOneWidget);

    // 4. Cek apakah tombol upload ada
    expect(find.byKey(const Key('upload_button')), findsOneWidget);

    // 5. Cek apakah icon camera ada (state awal)
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
  });
}
