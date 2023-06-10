import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sophon/infrastructures/repository/interfaces/secure_storage_repository.dart';
import 'package:sophon/internal/ethereum_credentials.dart';
import 'package:sophon/internal/local_storage.dart';
import 'package:sophon/internal/web3_contract.dart';
import 'package:sophon/internal/web3_utils.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';

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
  late SessionStatus? sessionStatus;
  late EthereumWalletConnectProvider provider;
  late WalletConnect? walletConnector;
  late WalletConnectEthereumCredentials wcCredentials;
  late Credentials? privCredentials;
  late String sender;

  // contract-related
  final DeployedContract greeterContract;

  /// Terminates metamask, provider, contract connections
  Future<void> closeConnection(WalletProvider provider) async {
    if (provider == WalletProvider.metaMask) {
      walletConnector?.killSession();
      walletConnector?.close();
    } else if (provider == WalletProvider.web3Auth) {
      web3Client.dispose();
      await storage.delete(key: lsPrivateKey); // delete private key from device
    }

    emit(SessionTerminated());
  }

  /// Initialize MetaMask provider provided by [session] and [connector]
  void initializeMetaMaskProvider({
    required WalletConnect connector,
    required SessionStatus session,
  }) {
    walletConnector = connector;
    sessionStatus = session;
    sender = connector.session.accounts[0];
    provider = EthereumWalletConnectProvider(connector);
    wcCredentials = WalletConnectEthereumCredentials(provider: provider);

    emit(InitializeMetaMaskProviderSuccess(
        accountAddress: sender, networkName: getNetworkName(session.chainId)));
  }

  /// Initialize Web3Auth provider
  Future<void> initializeWeb3AuthProvider() async {
    final String privateKey = await storage.read(key: lsPrivateKey) ?? '';
    final BigInt cId = await web3Client.getChainId();
    final EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);
    final EthereumAddress address = credentials.address;

    privCredentials = credentials;
    sender = address.hex;

    emit(InitializeWeb3AuthProviderSuccess(
        accountAddress: sender, networkName: getNetworkName(cId.toInt())));
  }

  /// Greeter contract

  /// Get greeting from
  Future<void> fetchGreeting() async {
    try {
      List<dynamic> response = await web3Client.call(
        contract: greeterContract,
        function: greeterContract.function(greetFunction),
        params: <dynamic>[],
      );
      emit(FetchGreetingSuccess(message: response[0]));
    } catch (e) {
      emit(FetchGreetingFailed(errorCode: '', message: e.toString()));
    }
  }

  /// Update greeter contract with provided [text]
  /// [provider] the authentication type currently used
  Future<void> updateGreeting({
    required WalletProvider provider,
    required String text,
  }) async {
    emit(UpdateGreetingLoading());

    try {
      Credentials credentials;
      int chainId;

      switch (provider) {
        case WalletProvider.metaMask:
          credentials = wcCredentials;
          chainId = sessionStatus!.chainId;
          break;
        case WalletProvider.web3Auth:
          final BigInt cId = await web3Client.getChainId();
          chainId = cId.toInt();
          credentials = privCredentials!;
          break;
      }

      // send transaction
      String txnHash = await web3Client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: greeterContract,
          function: greeterContract.function(setGreetingFunction),
          from: EthereumAddress.fromHex(sender),
          parameters: <String>[text],
        ),
        chainId: chainId,
      );

      // wait for confirmation and block to be mined
      late Timer txnTimer;
      txnTimer = Timer.periodic(Duration(milliseconds: getBlockTime(chainId)),
          (_) async {
        TransactionReceipt? t = await web3Client.getTransactionReceipt(txnHash);
        if (t != null) {
          txnTimer.cancel();
          fetchGreeting();
          emit(const UpdateGreetingSuccess());
        }
      });
    } catch (e) {
      fetchGreeting();
      emit(UpdateGreetingFailed(errorCode: '', message: e.toString()));
    }
  }

  /// TODO: <another> contract
  /// You can add and specify more contracts here
}
