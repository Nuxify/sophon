import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sophon/configs/web3_config.dart';
import 'package:sophon/domain/repository/secure_storage_repository.dart';
import 'package:sophon/internal/ethereum_credentials.dart';
import 'package:sophon/internal/local_storage.dart';
import 'package:sophon/internal/web3_contract.dart';
import 'package:sophon/internal/web3_utils.dart';
// import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

part 'web3_state.dart';

class Web3Cubit extends Cubit<Web3State> {
  Web3Cubit({
    required this.web3Client,
    required this.greeterContract,
    required this.storage,
  }) : super(const Web3State());

  // core declarations
  final Web3Client web3Client;
  final ISecureStorageRepository storage;
  // late SessionStatus? sessionStatus;
  // late EthereumWalletConnectProvider provider;
  // late WalletConnect? walletConnector;
  late WalletConnectEthereumCredentials wcCredentials;
  late Credentials? privCredentials;
  late String sender;

  // contract-related
  final DeployedContract greeterContract;

  /// Terminates metamask, provider, contract connections
  Future<void> closeConnection(WalletProvider provider) async {
    if (provider == WalletProvider.metaMask) {
      // walletConnector?.killSession();
      // walletConnector?.close();
    } else if (provider == WalletProvider.web3Auth) {
      web3Client.dispose();
      await storage.delete(key: lsPrivateKey); // delete private key from device
    }

    emit(SessionTerminated());
  }

  /// Initialize MetaMask provider provided by [session] and [connector]
  void initializeMetaMaskProvider(
      //   {
      //   required WalletConnect connector,
      //   required SessionStatus session,
      // }
      ) {
    // walletConnector = connector;
    // sessionStatus = session;
    // sender = connector.session.accounts[0];
    // provider = EthereumWalletConnectProvider(connector);
    // wcCredentials = WalletConnectEthereumCredentials(provider: provider);

    // emit(
    //   InitializeMetaMaskProviderSuccess(
    //     accountAddress: sender,
    //     networkName: getNetworkName(session.chainId),
    //   ),
    // );
  }

  /// Initialize Web3Auth provider
  Future<void> initializeWeb3AuthProvider() async {
    final String privateKey = await storage.read(key: lsPrivateKey) ?? '';
    final BigInt cId = await web3Client.getChainId();
    final EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);
    final EthereumAddress address = credentials.address;

    privCredentials = credentials;
    sender = address.hex;

    emit(
      InitializeWeb3AuthProviderSuccess(
        accountAddress: sender,
        networkName: getNetworkName(cId.toInt()),
      ),
    );
  }

  /// Greeter contract

  /// Get greeting from
  Future<void> fetchGreeting() async {
    try {
      final List<dynamic> response = await web3Client.call(
        contract: greeterContract,
        function: greeterContract.function(greetFunction),
        params: <dynamic>[],
      );
      emit(FetchGreetingSuccess(message: response[0].toString()));
    } catch (e) {
      emit(FetchGreetingFailed(errorCode: '', message: e.toString()));
    }
  }

  /// Update greeter contract with provided [text]
  /// [provider] the authentication type currently used
  Future<void> updateGreeting({
    required String text,
  }) async {
    emit(UpdateGreetingLoading());

    try {
      final W3MService w3mService = W3MService(
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
      );

      await w3mService.init();
      w3mService
          .requestWriteContract(
        chainId: '12',
        topic: '',
        rpcUrl: '',
        deployedContract: await deployedGreeterContract,
        functionName: setGreetingFunction,
        transaction: Transaction.callContract(
          contract: greeterContract,
          function: greeterContract.function(setGreetingFunction),
          from: EthereumAddress.fromHex(sender),
          parameters: <String>[text],
        ),
      )
          .then(
        (value) {
          print("It's Done!!");
          print(value);
        },
      );

      // send transaction
    } catch (e) {
      fetchGreeting();
      emit(UpdateGreetingFailed(errorCode: '', message: e.toString()));
    }
  }
}
