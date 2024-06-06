import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sophon/configs/web3_config.dart';
import 'package:sophon/internal/web3_contract.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

part 'web3_state.dart';

class Web3Cubit extends Cubit<Web3State> {
  Web3Cubit() : super(const Web3State());

  late W3MService w3mService;

  Future<void> fetchGreeting() async {
    try {
      await w3mService.requestReadContract(
        deployedContract: await deployedGreeterContract,
        functionName: greetFunction,
        rpcUrl: dotenv.get('ETHEREUM_RPC'),
      );
    } catch (e) {
      emit(Web3MFailed());
    }
  }

  Future<void> instantiate() async {
    try {
      w3mService = W3MService(
        projectId: '2684f2b98f5ae4051dce454b5862b9ff',
        metadata: const PairingMetadata(
          name: 'Sophon',
          description:
              'A Flutter template for building amazing decentralized applications.',
          url: 'https://github.com/Nuxify/Sophon',
          icons: <String>[
            'https://files-nuximart.sgp1.cdn.digitaloceanspaces.com/nuxify-website/blog/images/Nuxify-logo.png',
          ],
        ),
        excludedWalletIds: <String>{
          '4622a2b2d6af1c9844944291e5e7351a6aa24cd7b23099efac1b2fd875da31a0', // Trust
          'fd20dc426fb37566d803205b19bbc1d4096b248ac04548e3cfb6b3a38bd033aa', // Coinbase Wallet
        },
      );
      await w3mService.init();
      emit(Web3MInitialized(service: w3mService));
    } catch (e) {
      emit(Web3MFailed());
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

        w3mService.launchConnectedWallet();

        await w3mService.requestWriteContract(
          chainId: 'eip155:${dotenv.get('ETHEREUM_CHAIN_ID')}',
          topic: w3mService.session?.topic ?? '',
          rpcUrl: dotenv.get('ETHEREUM_RPC'),
          deployedContract: await deployedGreeterContract,
          functionName: setGreetingFunction,
          parameters: <String>['Sophon'],
          method: setGreetingFunction,
          transaction: Transaction(
            from: EthereumAddress.fromHex(sender),
          ),
        );
      }
    } catch (e) {
      emit(UpdateGreetingFailed(errorCode: '', message: e.toString()));
    }
  }
}
