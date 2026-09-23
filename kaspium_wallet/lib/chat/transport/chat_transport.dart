import 'dart:math';

import 'package:convert/convert.dart';

import '../../fee/fee_providers.dart';
import '../../kaspa/kaspa.dart';
import '../crypto/kasia_cipher.dart';
import '../identity/chat_identity.dart';
import '../models/chat_message.dart';
import '../protocol/message_protocol.dart';
import '../repository/chat_repository.dart';
import '../services/chat_handshake_service.dart';

class ChatTransport {
  const ChatTransport({
    required this.walletService,
    required this.apiService,
    required this.walletAddress,
    this.feeRate = kMinFeeRate,
    this.repository,
    this.senderIdentity,
  });

  final WalletService walletService;
  final ApiService apiService;
  final String walletAddress;
  final int feeRate;
  final ChatRepository? repository;
  final ChatIdentity? senderIdentity;

  Future<List<ChatMessage>> receive({
    required String address,
    int limit = 50,
    List<Transaction>? transactions,
    String? privateKeyHex,
    Future<String> Function(String address)? privateKeyResolver,
    ChatRepository? chatRepository,
  }) async {
    final repo = chatRepository ?? repository;
    final txs = transactions ?? await apiService.getTxsForAddress(
      address,
      pageSize: limit,
      maxPages: 1,
      shouldLoadMore: (_) => false,
    );

    final messages = <ChatMessage>[];
    for (final tx in txs) {
      if (tx.transactionId.isEmpty) {
        continue;
      }

      if (repo != null && repo.hasTransactionId(tx.transactionId)) {
        continue;
      }

      final payload = _extractPayload(tx.payload);
      if (payload == null) {
        continue;
      }

      final parsed = MessageProtocol.parse(payload);
      if (parsed == null) {
        continue;
      }

      final message = await _decodeIncomingMessage(
        tx: tx,
        address: address,
        payload: payload,
        parsed: parsed,
        privateKeyHex: privateKeyHex,
        privateKeyResolver: privateKeyResolver,
      );

      if (message == null) {
        continue;
      }

      if (repo != null) {
        await repo.saveMessage(message);
      }
      messages.add(message);
    }

    return messages;
  }

  Future<ChatMessage> sendMessage(
    Object recipient,
    String plaintext, {
    String? senderAddress,
    ChatIdentity? sender,
    ChatIdentity? recipientIdentity,
    String? recipientPublicKeyHex,
    String? alias,
    ChatRepository? chatRepository,
    String? note,
  }) async {
    final resolvedSenderAddress = sender?.kaspaAddress ??
        senderAddress ??
        senderIdentity?.kaspaAddress ??
        walletAddress;
    final resolvedRecipientAddress = switch (recipient) {
      ChatIdentity() => recipient.kaspaAddress,
      KMailWalletAdapter() => recipient.address,
      _ => recipient.toString(),
    };
    final resolvedRecipientIdentity = recipientIdentity ??
        (recipient is ChatIdentity ? recipient : null) ??
        (recipient is KMailWalletAdapter ? ChatIdentity.fromWalletAdapter(recipient) : null);

    final sanitizedSenderAddress = _validateAddress(resolvedSenderAddress, 'sender');
    final sanitizedRecipientAddress = _validateAddress(resolvedRecipientAddress, 'recipient');

    final resolvedRecipientPublicKey = (recipientPublicKeyHex ?? resolvedRecipientIdentity?.publicKeyHex)
        ?.trim();
    if (resolvedRecipientPublicKey == null || resolvedRecipientPublicKey.isEmpty) {
      throw StateError('Recipient public key is required before sending a K-Mail message');
    }

    final encrypted = KasiaCipher.encrypt(plaintext, resolvedRecipientPublicKey);
    final wirePayload = MessageProtocol.serializeCommPayload(
      alias: alias ?? 'kmail',
      encrypted: encrypted,
    );

    final txId = await send(
      toAddress: sanitizedRecipientAddress,
      payload: wirePayload,
      note: note ?? 'kmail-chat',
    );

    final message = ChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1 << 20).toRadixString(16)}',
      sender: sanitizedSenderAddress,
      receiver: sanitizedRecipientAddress,
      timestampMs: DateTime.now().millisecondsSinceEpoch,
      messageType: ChatMessageType.text,
      encryptedPayload: hex.encode(wirePayload),
      transactionId: txId,
      status: ChatMessageStatus.sent,
      metadata: {
        'alias': alias ?? 'kmail',
        'encryptedFromPublicKey': resolvedRecipientPublicKey,
      },
    );

    final repositoryToUse = chatRepository ?? repository;
    if (repositoryToUse != null) {
      await repositoryToUse.saveMessage(message);
    }

    return message;
  }

  Future<ChatMessage> sendTextMessage({
    required Object recipient,
    required String plaintext,
    String? senderAddress,
    ChatIdentity? sender,
    ChatIdentity? recipientIdentity,
    String? recipientPublicKeyHex,
    String? alias,
    ChatRepository? chatRepository,
    String? note,
  }) async {
    return sendMessage(
      recipient,
      plaintext,
      senderAddress: senderAddress,
      sender: sender,
      recipientIdentity: recipientIdentity,
      recipientPublicKeyHex: recipientPublicKeyHex,
      alias: alias,
      chatRepository: chatRepository,
      note: note,
    );
  }

  Future<String> send({
    required String toAddress,
    required Uint8List payload,
    String? note,
  }) async {
    final sender = Address.decodeAddress(walletAddress);
    final recipient = Address.decodeAddress(toAddress);
    final spendableUtxos = (await walletService.rpc.getUtxosByAddresses([walletAddress])).toList();

    if (spendableUtxos.isEmpty) {
      throw StateError('No spendable UTXOs available for chat payload transport');
    }

    final sendTx = walletService.createSendTx(
      toAddress: recipient,
      amount: Amount.zero,
      spendableUtxos: spendableUtxos,
      feeRate: feeRate,
      changeAddress: sender,
      payload: payload,
      note: note ?? 'kmail-chat',
    );

    return walletService.sendTransaction(sendTx.tx);
  }

  Future<List<Uint8List>> receivePayloads({
    required String address,
    int limit = 50,
    List<Transaction>? transactions,
  }) async {
    final txs = transactions ?? await apiService.getTxsForAddress(
      address,
      pageSize: limit,
      maxPages: 1,
      shouldLoadMore: (_) => false,
    );

    final payloads = <Uint8List>[];

    for (final tx in txs) {
      final payload = _extractPayload(tx.payload);
      if (payload != null) {
        payloads.add(payload);
      }
    }

    return payloads;
  }

  static String _validateAddress(String value, String role) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw StateError('Missing $role address for K-Mail transport');
    }

    try {
      Address.decodeAddress(normalized);
      return normalized;
    } on Exception {
      throw FormatException('Invalid $role address: $normalized');
    }
  }

  static Uint8List? _extractPayload(String rawPayload) {
    final trimmed = rawPayload.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    try {
      return Uint8List.fromList(hex.decode(trimmed));
    } on FormatException {
      return null;
    }
  }

  Future<ChatMessage?> _decodeIncomingMessage({
    required Transaction tx,
    required String address,
    required Uint8List payload,
    required ParsedMessagePayload parsed,
    String? privateKeyHex,
    Future<String> Function(String address)? privateKeyResolver,
  }) async {
    var resolvedPrivateKey = privateKeyHex;
    if (resolvedPrivateKey == null && privateKeyResolver != null) {
      resolvedPrivateKey = await privateKeyResolver(address);
    }

    if (resolvedPrivateKey == null || resolvedPrivateKey.trim().isEmpty) {
      throw StateError('Missing wallet private key to decrypt incoming K-Mail message');
    }

    final comm = parsed.type == MessageProtocol.commType
        ? MessageProtocol.parseCommPayload(payload)
        : null;

    if (comm != null) {
      final plaintext = KasiaCipher.decrypt(comm.message, resolvedPrivateKey);
      final msgId = tx.transactionId.isEmpty ? 'kmail-${DateTime.now().millisecondsSinceEpoch}' : tx.transactionId;
      final message = ChatMessage(
        id: msgId,
        sender: comm.alias,
        receiver: address,
        timestampMs: tx.blockTime * 1000,
        messageType: ChatMessageType.text,
        encryptedPayload: hex.encode(payload),
        transactionId: tx.transactionId,
        status: ChatMessageStatus.received,
        metadata: {
          'senderAlias': comm.alias,
          'plaintext': plaintext,
          'blockTime': tx.blockTime,
          'isKMail': true,
        },
        plaintext: plaintext,
      );
      return message;
    }

    final handshake = MessageProtocol.parseHandshakePayload(payload);
    if (handshake != null) {
      final handshakePayload = ChatHandshakeService().parseHandshake(
        senderAddress: 'unknown',
        recipientAddress: address,
        payload: payload,
      );
      final decrypted = KasiaCipher.decrypt(handshake, resolvedPrivateKey);
      return ChatMessage(
        id: tx.transactionId.isEmpty ? 'handshake-${DateTime.now().millisecondsSinceEpoch}' : tx.transactionId,
        sender: handshakePayload.senderAddress,
        receiver: handshakePayload.recipientAddress,
        timestampMs: tx.blockTime * 1000,
        messageType: ChatMessageType.handshake,
        encryptedPayload: hex.encode(payload),
        transactionId: tx.transactionId,
        status: ChatMessageStatus.received,
        metadata: {
          'plaintext': decrypted,
          'blockTime': tx.blockTime,
          'isHandshake': true,
        },
        plaintext: decrypted,
      );
    }

    return null;
  }
}
