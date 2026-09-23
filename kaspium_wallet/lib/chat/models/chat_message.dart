enum ChatMessageType {
  text,
  handshake,
  handshakeResponse,
  image,
  voice,
  file,
}

enum ChatMessageStatus {
  pending,
  sent,
  received,
  delivered,
  failed,
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.timestampMs,
    required this.messageType,
    required this.encryptedPayload,
    this.transactionId,
    this.status = ChatMessageStatus.pending,
    this.replyTo,
    this.metadata = const {},
    this.plaintext = '',
  });

  final String id;
  final String sender;
  final String receiver;
  final int timestampMs;
  final ChatMessageType messageType;
  final String encryptedPayload;
  final String? transactionId;
  final ChatMessageStatus status;
  final String? replyTo;
  final Map<String, dynamic> metadata;
  final String plaintext;

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender': sender,
        'receiver': receiver,
        'timestampMs': timestampMs,
        'messageType': messageType.name,
        'encryptedPayload': encryptedPayload,
        'transactionId': transactionId,
        'status': status.name,
        'replyTo': replyTo,
        'plaintext': plaintext,
        'metadata': metadata,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String? ?? '',
        sender: json['sender'] as String? ?? '',
        receiver: json['receiver'] as String? ?? '',
        timestampMs: json['timestampMs'] as int? ?? 0,
        messageType: _messageTypeFromString(json['messageType'] as String? ?? 'text'),
        encryptedPayload: json['encryptedPayload'] as String? ?? '',
        transactionId: json['transactionId'] as String?,
        status: _statusFromString(json['status'] as String? ?? 'pending'),
        replyTo: json['replyTo'] as String?,
        metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? const {}),
        plaintext: json['plaintext'] as String? ?? '',
      );

  String get payloadHex => encryptedPayload;

  static ChatMessageType _messageTypeFromString(String value) {
    switch (value.toLowerCase()) {
      case 'handshake':
        return ChatMessageType.handshake;
      case 'handshake_response':
      case 'handshakeresponse':
        return ChatMessageType.handshakeResponse;
      case 'image':
        return ChatMessageType.image;
      case 'voice':
        return ChatMessageType.voice;
      case 'file':
        return ChatMessageType.file;
      case 'text':
      default:
        return ChatMessageType.text;
    }
  }

  static ChatMessageStatus _statusFromString(String value) {
    switch (value.toLowerCase()) {
      case 'sent':
        return ChatMessageStatus.sent;
      case 'received':
        return ChatMessageStatus.received;
      case 'delivered':
        return ChatMessageStatus.delivered;
      case 'failed':
        return ChatMessageStatus.failed;
      case 'pending':
      default:
        return ChatMessageStatus.pending;
    }
  }

  String toBlockchainPayload() => encryptedPayload;

  factory ChatMessage.fromBlockchainPayload({
    required String id,
    required String sender,
    required String receiver,
    required String payload,
    required int timestampMs,
    required ChatMessageType messageType,
    String? transactionId,
    ChatMessageStatus status = ChatMessageStatus.pending,
    String? replyTo,
    Map<String, dynamic> metadata = const {},
  }) => ChatMessage(
        id: id,
        sender: sender,
        receiver: receiver,
        timestampMs: timestampMs,
        messageType: messageType,
        encryptedPayload: payload,
        transactionId: transactionId,
        status: status,
        replyTo: replyTo,
        metadata: metadata,
      );

  @override
  String toString() => 'ChatMessage(id: $id, sender: $sender, receiver: $receiver, type: ${messageType.name})';
}
