import 'dart:typed_data';

import 'package:convert/convert.dart';

import '../crypto/kasia_cipher.dart';
import '../protocol/message_protocol.dart';

class ChatHandshake {
  const ChatHandshake({
    required this.senderAddress,
    required this.recipientAddress,
    required this.payload,
    required this.createdAtMs,
  });

  final String senderAddress;
  final String recipientAddress;
  final Uint8List payload;
  final int createdAtMs;

  Uint8List get serializedPayload => payload;

  String toHex() => hex.encode(payload);

  static ChatHandshake fromPayload({
    required String senderAddress,
    required String recipientAddress,
    required Uint8List payload,
  }) => ChatHandshake(
        senderAddress: senderAddress,
        recipientAddress: recipientAddress,
        payload: payload,
        createdAtMs: DateTime.now().millisecondsSinceEpoch,
      );
}

class ChatHandshakeService {
  ChatHandshakeService();

  ChatHandshake createHandshake({
    required String senderAddress,
    required String recipientAddress,
    required String senderPrivateKeyHex,
    required String recipientPublicKeyHex,
    String alias = 'kmail',
  }) {
    final encrypted = KasiaCipher.encrypt(
      'handshake:$senderAddress:$recipientAddress:$alias:${DateTime.now().millisecondsSinceEpoch}',
      recipientPublicKeyHex,
    );

    final payload = MessageProtocol.serializeHandshakePayload(encrypted);
    return ChatHandshake(
      senderAddress: senderAddress,
      recipientAddress: recipientAddress,
      payload: payload,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  bool validateHandshakePayload(Uint8List payload) {
    return MessageProtocol.parseHandshakePayload(payload) != null;
  }

  ChatHandshake parseHandshake({
    required String senderAddress,
    required String recipientAddress,
    required Uint8List payload,
  }) {
    if (!validateHandshakePayload(payload)) {
      throw FormatException('Invalid handshake payload');
    }

    return ChatHandshake(
      senderAddress: senderAddress,
      recipientAddress: recipientAddress,
      payload: payload,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
