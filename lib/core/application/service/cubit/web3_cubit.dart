import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:sophon/configs/web3_config.dart';
import 'package:sophon/internal/enums.dart';
import 'package:sophon/internal/web3_contract.dart';

part 'web3_state.dart';

class Web3Cubit extends Cubit<Web3State> {
  Web3Cubit() : super(const Web3State());

  late ReownAppKitModal w3mService;

  bool get isLoggedInViaEmail =>
      w3mService.session?.connectedWalletName == 'Email Wallet';

  Future<String> get blockchainExplorer async {
    final String blockExplorer = w3mService.selectedChain?.explorerUrl ?? '';
    final String address = (await deployedGreeterContract).address.toString();

    return '$blockExplorer/address/$address';
  }

  Future<void> fetchGreeting() async {
    try {
      final List<dynamic> contractData = await w3mService.requestReadContract(
        topic: null,
        chainId: w3mService.selectedChain!.chainId,
        deployedContract: await deployedGreeterContract,
        functionName: greetFunction,
      );

      emit(FetchGreetingSuccess(message: contractData[0].toString()));
    } catch (e) {
      emit(
        const FetchGreetingFailed(
          errorCode: '',
          message: 'Unable to fetch contract data',
        ),
      );
    }
  }

  // void _addExtraChains() {
  //   for (final MapEntry<String, ReownAppKitModalNetworkInfo> entry
  //       in ReownAppKitModalNetworks.) {
  //     ReownAppKitModalNetworks.chains.putIfAbsent(entry.key, () => entry.value);
  //   }
  //   for (final MapEntry<String, ReownAppKitModalNetworkInfo> entry
  //       in ReownAppKitModalNetworks.testChains.entries) {
  //     ReownAppKitModalNetworks.chains.putIfAbsent(entry.key, () => entry.value);
  //   }
  // }

  Future<void> instantiate(BuildContext context) async {
    try {
      const String url = 'https://github.com/Nuxify/Sophon';
      w3mService = ReownAppKitModal(
        context: context,
        projectId: 'ca39991258c8cb8f99a5ff8eae88b6c5',
        metadata: const PairingMetadata(
          name: 'Sophon',
          description:
              'A Flutter template for building amazing decentralized applications.',
          url: url,
          icons: <String>[
            'https://files-nuximart.sgp1.cdn.digitaloceanspaces.com/nuxify-website/blog/images/Nuxify-logo.png',
          ],
          redirect: Redirect(universal: url, native: url),
        ),
        excludedWalletIds: <String>{
          'fd20dc426fb37566d803205b19bbc1d4096b248ac04548e3cfb6b3a38bd033aa',
          'a797aa35c0fadbfc1a53e7f675162ed5226968b44a19ee3d24385c64d1d3c393',
        },
        includedWalletIds: <String>{
          'c57ca95b47569778a828d19178114f4db188b89b763c899ba0be274e97267d96', // metamask
          '4622a2b2d6af1c9844944291e5e7351a6aa24cd7b23099efac1b2fd875da31a0', // trust
          'e9ff15be73584489ca4a66f64d32c4537711797e30b6660dbcb71ea72a42b1f4', // exodus
          'f2436c67184f158d1beda5df53298ee84abfc367581e4505134b5bcf5f46697d', // crypto.com
          'fd20dc426fb37566d803205b19bbc1d4096b248ac04548e3cfb6b3a38bd033aa', // coinbase
          '9414d5a85c8f4eabc1b5b15ebe0cd399e1a2a9d35643ab0ad22a6e4a32f596f0', // zengo
          '84b43e8ddfcd18e5fcb5d21e7277733f9cccef76f7d92c836d0e481db0c70c04', // blockchain.com
        },
      );
      await w3mService.init();
      await w3mService.selectChain(
        const ReownAppKitModalNetworkInfo(
          chainId: '11155111',
          name: 'Sepolia',
          currency: 'ETH',
          rpcUrl: 'https://1rpc.io/sepolia',
          explorerUrl: 'https://sepolia.etherscan.io/',
        ),
      );

      fetchHomeScreenActionButton();
      if (!w3mService.isConnected) {
        listenToWalletConnection();
      }
      emit(InitializeWeb3MSuccess(service: w3mService));
    } catch (e) {
      emit(InitializeWeb3MFailed());
    }
  }

  Future<void> listenToWalletConnection() async {
    try {
      w3mService.onModalConnect.subscribe((_) => fetchHomeScreenActionButton());
    } catch (e) {
      emit(
        const WalletConnectionFailed(
          errorCode: '',
          message: 'Wallet Connection Failed',
        ),
      );
    }
  }

  Future<void> updateGreeting({
    required String text,
  }) async {
    emit(UpdateGreetingLoading());

    try {
      final List<String> accounts =
          w3mService.session?.getAccounts() ?? <String>[];

      if (accounts.isNotEmpty) {
        final String sender = accounts.first.split(':').last;

        await w3mService.requestWriteContract(
          chainId: w3mService.selectedChain!.chainId,
          topic: w3mService.session?.topic ?? '',
          deployedContract: await deployedGreeterContract,
          functionName: setGreetingFunction,
          parameters: <String>[text],
          transaction: Transaction(
            from: EthereumAddress.fromHex(sender),
          ),
        );
      }
    } catch (e) {
      emit(UpdateGreetingFailed(errorCode: '', message: e.toString()));
    }
  }

  Future<void> endSession() async {
    await w3mService.disconnect();
  }

  Future<void> fetchHomeScreenActionButton() async {
    if (isLoggedInViaEmail) {
      emit(
        const FetchHomeScreenActionButtonSuccess(
          action: HomeScreenActionButton.upgradeWallet,
        ),
      );
    } else if (!w3mService.isConnected) {
      emit(
        const FetchHomeScreenActionButtonSuccess(
          action: HomeScreenActionButton.connectWallet,
        ),
      );
    } else if (w3mService.isConnected) {
      emit(
        const FetchHomeScreenActionButtonSuccess(
          action: HomeScreenActionButton.writeToContract,
        ),
      );
    }
  }
}
