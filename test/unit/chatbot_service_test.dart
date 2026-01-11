import 'package:flutter_test/flutter_test.dart';

String chatbotReply(String message) {
  if (message.toLowerCase().contains('halo')) {
    return 'Halo, ada yang bisa saya bantu?';
  }
  if (message.toLowerCase().contains('jalan')) {
    return 'Silakan laporkan jalan rusak melalui menu upload.';
  }
  return 'Maaf, saya belum mengerti.';
}

void main() {
  group('Chatbot Service Test', () {
    test('Chatbot membalas salam', () {
      final response = chatbotReply('halo');
      expect(response, contains('Halo'));
    });

    test('Chatbot memberi instruksi pelaporan', () {
      final response = chatbotReply('lapor jalan');
      expect(response, contains('laporkan'));
    });

    test('Chatbot default response', () {
      final response = chatbotReply('abc');
      expect(response, contains('belum mengerti'));
    });
  });
}
