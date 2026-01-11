import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Login page menampilkan input dan tombol', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: const [
              Text('Login'),
              TextField(),
              TextField(),
              ElevatedButton(onPressed: null, child: Text('Masuk')),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
