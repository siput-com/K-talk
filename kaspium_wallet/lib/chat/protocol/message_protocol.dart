import 'dart:convert';
import 'dart:typed_data';

import '../crypto/kasia_cipher.dart';

class ParsedMessagePayload {
  const ParsedMessagePayload({
    required this.type,
    this.alias,
    required this.bytes,
  });

  final String type;
  final String? alias;
  final Uint8List bytes;
}

class MessageProtocol {
  static const String prefix = 'kchat';
  static const String legacyPrefix = 'ciph_msg';
  static const String version = '1';
  static const String commType = 'comm';
  static const String handshakeType = 'handshake';

  static Uint8List serializeCommPayload({
    required String alias,
    required EncryptedMessage encrypted,
  }) {
    final sanitizedAlias = alias.replaceAll(':', '_').trim();
    final safeAlias = sanitizedAlias.length > 32 ? sanitizedAlias.substring(0, 32) : sanitizedAlias;
    final encoded = base64Encode(encrypted.toBytes());
    return Uint8List.fromList(
      utf8.encode('$prefix:$version:$commType:$safeAlias:$encoded'),
    );
  }

  static Uint8List serializeHandshakePayload(EncryptedMessage encrypted) {
    final raw = encrypted.toBytes();
    final header = utf8.encode('$prefix:$version:$handshakeType:');
    return Uint8List.fromList([...header, ...raw]);
  }

  static Uint8List serializeLegacyHandshakePayload(EncryptedMessage encrypted) {
    final raw = encrypted.toBytes();
    final header = utf8.encode('$legacyPrefix:$version:$handshakeType:');
    return Uint8List.fromList([...header, ...raw]);
  }

  static bool isHandshakePayload(Uint8List payload) {
    final text = utf8.decode(payload, allowMalformed: true);
    return text.startsWith('$prefix:$version:$handshakeType:') ||
        text.startsWith('$legacyPrefix:$version:$handshakeType:');
  }

  static bool isCommPayload(Uint8List payload) {
    final text = utf8.decode(payload, allowMalformed: true);
    return text.startsWith('$prefix:$version:$commType:') ||
        text.startsWith('$legacyPrefix:$version:$commType:');
  }

  static ParsedMessagePayload? parse(Uint8List payload) {
    final text = utf8.decode(payload, allowMalformed: true);
    final segments = text.split(':');
    if (segments.length < 4) {
      return null;
    }

    final root = segments[0];
    final versionValue = segments[1];
    final typeValue = segments[2];

    if ((root != prefix && root != legacyPrefix) || versionValue != version) {
      return null;
    }

    if (typeValue == commType && segments.length >= 5) {
      final alias = segments[3];
      final encoded = segments.sublist(4).join(':');
      final decoded = base64Decode(encoded);
      return ParsedMessagePayload(type: typeValue, alias: alias, bytes: Uint8List.fromList(decoded));
    }

    if (typeValue == handshakeType) {
      final keyStart = '$root:$version:$handshakeType:'.length;
      final bytes = payload.sublist(keyStart);
      return ParsedMessagePayload(type: typeValue, bytes: bytes);
    }

    return null;
  }

  static ({String alias, EncryptedMessage message})? parseCommPayload(Uint8List payload) {
    final parsed = parse(payload);
    if (parsed == null || parsed.type != commType || parsed.alias == null) {
      return null;
    }
    try {
      final message = EncryptedMessage.fromBytes(parsed.bytes);
      return (alias: parsed.alias!, message: message);
    } on FormatException {
      return null;
    }
  }

  static EncryptedMessage? parseHandshakePayload(Uint8List payload) {
    final parsed = parse(payload);
    if (parsed == null || parsed.type != handshakeType) {
      return null;
    }
    try {
      return EncryptedMessage.fromBytes(parsed.bytes);
    } on FormatException {
      return null;
    }
  }

  static String normalizeAlias(String alias) => alias.replaceAll(':', '_').trim();
}
