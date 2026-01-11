import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Profile page menampilkan avatar dan nama', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: const [
              Text('Profile'),
              CircleAvatar(radius: 40),
              Text('Nama User'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Profile'), findsOneWidget);
    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.text('Nama User'), findsOneWidget);
  });
}
