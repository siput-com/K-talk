import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app_router.dart';
import '../../app_styles.dart';
import '../chat_providers.dart';
import '../models/chat_message.dart';
import '../repository/chat_repository.dart';

class ChatHomeScreen extends ConsumerStatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  ConsumerState<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends ConsumerState<ChatHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final repositoryAsync = ref.watch(chatRepositoryProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final secondarySurface = isDark ? const Color(0xFF121212) : const Color(0xFFF4F5F7);
    final secondaryText = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBody: true,
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => _showNewChatDialog(context, ref),
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
      body: repositoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('K-talk is unavailable: $error'),
          ),
        ),
        data: (repository) => SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              _buildChatTab(context, repository, ref, isDark, secondarySurface, secondaryText),
              _buildPlaceholderPage(
                icon: Icons.explore_outlined,
                title: 'Discover',
                subtitle: 'Explore and discover content.',
                isDark: isDark,
              ),
              _buildPlaceholderPage(
                icon: Icons.wallet_outlined,
                title: 'Wallet',
                subtitle: 'Managed by the wallet flow.',
                isDark: isDark,
              ),
              _buildPlaceholderPage(
                icon: Icons.person_outline,
                title: 'Profile',
                subtitle: 'Your account and settings.',
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? const Color(0xFF0D0D0D) : Colors.white,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: isDark ? Colors.white60 : Colors.black54,
          selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          showUnselectedLabels: true,
          showSelectedLabels: true,
          elevation: 0,
          onTap: (index) {
            if (index == 2) {
              setState(() => _selectedIndex = index);
              appRouter.openWallet(context);
              return;
            }
            setState(() => _selectedIndex = index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline, size: 24),
              activeIcon: Icon(Icons.chat_bubble_rounded, size: 24),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined, size: 24),
              activeIcon: Icon(Icons.explore_rounded, size: 24),
              label: 'Discover',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined, size: 24),
              activeIcon: Icon(Icons.account_balance_wallet_rounded, size: 24),
              label: 'Wallet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 24),
              activeIcon: Icon(Icons.person_rounded, size: 24),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTab(
    BuildContext context,
    ChatRepository repository,
    WidgetRef ref,
    bool isDark,
    Color secondarySurface,
    Color secondaryText,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final conversations = repository.getConversations();
    final backgroundColor = isDark ? Colors.black : Colors.white;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Row(
            children: [
              Text(
                'K-talk',
                style: TextStyle(
                  fontFamily: kDefaultFontFamily,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  color: colorScheme.primary,
                ),
              ),
              const Spacer(),
              _headerActionButton(
                icon: Icons.photo_camera_outlined,
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              _headerActionButton(
                icon: Icons.more_vert,
                onPressed: () {},
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: secondarySurface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(Icons.search, color: secondaryText.withAlpha(180), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Tanya atau cari',
                      hintStyle: TextStyle(
                        color: secondaryText.withAlpha(180),
                        fontSize: 16,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (conversations.isEmpty)
          Expanded(
            child: Container(
              color: backgroundColor,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No conversations yet',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () => _showNewChatDialog(context, ref),
                      icon: const Icon(Icons.add),
                      label: const Text('New Chat'),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Expanded(
            child: Container(
              color: backgroundColor,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 88),
                itemCount: conversations.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  final participantA = conversation['participantA'] as String? ?? '';
                  final participantB = conversation['participantB'] as String? ?? '';
                  final peerAddress = participantA == repository.currentIdentity.kaspaAddress
                      ? participantB
                      : participantA;

                  final messages = _messagesForConversation(repository, peerAddress);
                  final preview = messages.isEmpty
                      ? 'No messages yet'
                      : messages.last.plaintext.isNotEmpty
                          ? messages.last.plaintext
                          : 'Encrypted K-talk payload';
                  final time = messages.isEmpty
                      ? DateTime.now()
                      : DateTime.fromMillisecondsSinceEpoch(messages.last.timestampMs);
                  final lastMessage = messages.isNotEmpty ? messages.last : null;
                  final hasUnread = lastMessage != null &&
                      lastMessage.sender != repository.currentIdentity.kaspaAddress &&
                      lastMessage.status != ChatMessageStatus.failed &&
                      lastMessage.status != ChatMessageStatus.pending;

                  return Material(
                    color: isDark ? const Color(0xFF111111) : const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => appRouter.openChatConversation(context, peerAddress),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildAvatar(peerAddress),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          peerAddress.isEmpty ? 'Unknown contact' : peerAddress,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: isDark ? Colors.white : Colors.black,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        DateFormat('HH:mm').format(time),
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: hasUnread ? colorScheme.primary : Colors.grey.shade500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      if (lastMessage != null) ...[
                                        Icon(
                                          _statusIcon(lastMessage.status),
                                          size: 14,
                                          color: _statusColor(lastMessage.status, colorScheme),
                                        ),
                                        const SizedBox(width: 6),
                                      ],
                                      Expanded(
                                        child: Text(
                                          preview,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.grey.shade500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      if (hasUnread)
                                        Container(
                                          margin: const EdgeInsets.only(left: 8),
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: colorScheme.primary,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            '1',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholderPage({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryText = isDark ? Colors.white70 : Colors.black54;

    return Container(
      color: backgroundColor,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 52, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 24),
        ),
      ),
    );
  }

  Widget _buildAvatar(String peerAddress) {
    final initial = peerAddress.isNotEmpty ? peerAddress.trim()[0].toUpperCase() : '?';

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(20),
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).colorScheme.primary.withAlpha(40)),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  IconData _statusIcon(ChatMessageStatus status) {
    switch (status) {
      case ChatMessageStatus.pending:
        return Icons.schedule;
      case ChatMessageStatus.sent:
        return Icons.check;
      case ChatMessageStatus.received:
        return Icons.done_all;
      case ChatMessageStatus.delivered:
        return Icons.done_all;
      case ChatMessageStatus.failed:
        return Icons.error_outline;
    }
  }

  Color _statusColor(ChatMessageStatus status, ColorScheme colorScheme) {
    switch (status) {
      case ChatMessageStatus.pending:
        return Colors.orange.shade400;
      case ChatMessageStatus.sent:
        return Colors.grey.shade500;
      case ChatMessageStatus.received:
      case ChatMessageStatus.delivered:
        return colorScheme.primary;
      case ChatMessageStatus.failed:
        return Colors.red.shade400;
    }
  }

  Future<void> _showNewChatDialog(BuildContext context, WidgetRef ref) async {
    final addressController = TextEditingController();
    final keyController = TextEditingController();
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Chat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Recipient Kaspa address',
                hintText: 'kaspa:...',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'Recipient public key (optional)',
                hintText: 'Hex-encoded secp256k1 public key',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop({
              'address': addressController.text.trim(),
              'publicKey': keyController.text.trim(),
            }),
            child: const Text('Open'),
          ),
        ],
      ),
    );

    if (result == null) return;
    final address = result['address'] ?? '';
    if (address.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipient address is required.')),
        );
      }
      return;
    }

    if (context.mounted) {
      appRouter.openChatConversation(
        context,
        address,
        recipientPublicKeyHex: result['publicKey'],
      );
    }
  }

  List<ChatMessage> _messagesForConversation(
    ChatRepository repository,
    String peerAddress,
  ) {
    final currentAddress = repository.currentIdentity.kaspaAddress;
    final direct = repository.getMessages(currentAddress, peerAddress);
    if (direct.isNotEmpty) {
      final sorted = [...direct]..sort((a, b) => a.timestampMs.compareTo(b.timestampMs));
      return sorted;
    }
    final reverse = repository.getMessages(peerAddress, currentAddress);
    final sorted = [...reverse]..sort((a, b) => a.timestampMs.compareTo(b.timestampMs));
    return sorted;
  }
}
