import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_providers.dart';
import 'identity/chat_identity.dart';
import 'repository/chat_repository.dart';
import 'storage/chat_storage.dart';
import 'transport/chat_transport.dart';

final chatStorageProvider = FutureProvider.autoDispose<ChatStorage>((ref) async {
  return ChatStorage.open();
});

final chatRepositoryProvider = FutureProvider.autoDispose<ChatRepository>((ref) async {
  final storage = await ref.watch(chatStorageProvider.future);
  final addressNotifier = ref.watch(addressNotifierProvider);
  final wallet = ref.watch(walletProvider);
  final network = ref.watch(networkProvider);

  final currentAddress = addressNotifier.receiveAddress.encoded;

  return ChatRepository(
    storage: storage,
    walletAdapter: KMailWalletAdapter(
      address: currentAddress,
      network: network.name,
      publicKeyHex: wallet.mainnetPublicKey,
    ),
  );
});

final chatTransportProvider = Provider.autoDispose<ChatTransport>((ref) {
  final repo = ref.watch(chatRepositoryProvider).asData?.value;
  final walletService = ref.watch(walletServiceProvider);
  final apiService = ref.watch(kaspaApiServiceProvider);
  final addressNotifier = ref.watch(addressNotifierProvider);
  final wallet = ref.watch(walletProvider);

  final address = addressNotifier.receiveAddress.encoded;
  final network = ref.watch(networkProvider);

  return ChatTransport(
    walletService: walletService,
    apiService: apiService,
    walletAddress: address,
    repository: repo,
    senderIdentity: ChatIdentity.fromWalletAdapter(
      KMailWalletAdapter(
        address: address,
        network: network.name,
        publicKeyHex: wallet.mainnetPublicKey,
      ),
    ),
  );
});
