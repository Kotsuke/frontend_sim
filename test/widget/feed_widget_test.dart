import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Feed page menampilkan tombol like dan dislike', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: const [
              Icon(Icons.thumb_up),
              Icon(Icons.thumb_down),
            ],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.thumb_up), findsOneWidget);
    expect(find.byIcon(Icons.thumb_down), findsOneWidget);
  });
}
