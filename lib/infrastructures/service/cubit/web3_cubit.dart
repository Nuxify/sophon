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
  final DeployedContract greeterContract;
  final ISecureStorageRepository storage;
  late String sender;
  late SessionStatus? sessionStatus;
  late EthereumWalletConnectProvider provider;
  late WalletConnect? walletConnector;
  late WalletConnectEthereumCredentials wcCredentials;
  late Credentials? privCredentials;

  // contract-specific declarations
  late Timer fetchGreetingTimer;

  /// Terminates metamask, provider, contract connections
  void closeConnection(LoginType loginType) {
    fetchGreetingTimer.cancel();
    if (loginType == LoginType.metaMask) {
      walletConnector?.killSession();
      walletConnector?.close();
    } else if (loginType == LoginType.web3Auth) {
      web3Client.dispose();
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

    /// periodically fetch greeting from chain
    fetchGreetingTimer =
        Timer.periodic(const Duration(seconds: 5), (_) => fetchGreeting());

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

    /// periodically fetch greeting from chain
    fetchGreetingTimer =
        Timer.periodic(const Duration(seconds: 5), (_) => fetchGreeting());

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
  /// [type] the authentication type currently used
  Future<void> updateGreeting({
    required LoginType type,
    required String text,
  }) async {
    emit(UpdateGreetingLoading());
    try {
      switch (type) {
        case LoginType.metaMask:
          sendTransaction(
            credentials: wcCredentials,
            text: text,
            chainId: sessionStatus!.chainId,
          );
          break;
        case LoginType.web3Auth:
          final BigInt cId = await web3Client.getChainId();
          final int chainId = cId.toInt();
          sendTransaction(
            credentials: privCredentials!,
            text: text,
            chainId: chainId,
          );
          break;
      }
    } catch (e) {
      emit(UpdateGreetingFailed(errorCode: '', message: e.toString()));
    }
  }

  Future<void> sendTransaction({
    required Credentials credentials,
    required String text,
    required int chainId,
  }) async {
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
    late Timer txnTimer;
    txnTimer = Timer.periodic(Duration(milliseconds: getBlockTime(chainId)),
        (_) async {
      TransactionReceipt? t = await web3Client.getTransactionReceipt(txnHash);
      if (t != null) {
        emit(const UpdateGreetingSuccess());
        fetchGreeting();
        txnTimer.cancel();
      }
    });
  }

  /// TODO: <another> contract
  /// You can add and specify more contracts here
}
