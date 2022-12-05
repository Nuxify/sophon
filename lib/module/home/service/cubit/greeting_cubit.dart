import 'dart:async';
import 'package:sophon/internal/ethereum_credentials.dart';
import 'package:sophon/utils/web3_utils.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

part 'greeting_state.dart';

class GreetingCubit extends Cubit<GreetingState> {
  GreetingCubit({required this.contract, required this.web3Client})
      : super(const GreetingState());
  final DeployedContract contract;
  final Web3Client web3Client;

  late SessionStatus sessionStatus;
  late String sender;
  late EthereumWalletConnectProvider provider;
  late WalletConnectEthereumCredentials wcCreds;
  late String contractABI;
  late ContractFunction setGreetingFunction;
  late Timer fetchGreetingTimer;
  late WalletConnect walletConnector;

  String latestGreeting = '';

  /// Initializes the provider, sessionStatus, sender, credentials, etc.
  void initializeProvider({
    required SessionStatus session,
    required WalletConnect connector,
  }) {
    walletConnector = connector;
    sessionStatus = session;
    sender = connector.session.accounts[0];
    provider = EthereumWalletConnectProvider(connector);
    wcCreds = WalletConnectEthereumCredentials(provider: provider);
    setGreetingFunction = contract.function('setGreeting');

    /// Periodically fetch greeting from chain
    fetchGreetingTimer =
        Timer.periodic(const Duration(seconds: 5), (_) => fetchGreeting());

    emit(InitializeProviderSuccess(
        accountAddress: sender, networkName: getNetworkName(session.chainId)));
  }

  /// Terminates metamask connection
  void closeConnection() {
    fetchGreetingTimer.cancel();
    walletConnector.killSession();
    walletConnector.close();
    emit(SessionTerminated());
  }

  /// Parses the specifics of the Smart Contract (contract and function), launches MetaMask, then sends the write transaction.
  Future<void> updateGreeting(String text) async {
    try {
      await web3Client.sendTransaction(
        wcCreds,
        Transaction.callContract(
          contract: contract,
          function: setGreetingFunction,
          from: EthereumAddress.fromHex(sender),
          parameters: [text],
        ),
        chainId: 5,
      );
      emit(const UpdateGreetingSuccess());
    } catch (e) {
      emit(UpdateGreetingFailed(errorCode: '', message: e.toString()));
    }
  }

  Future<void> fetchGreeting() async {
    ContractFunction getGreetingFunction = contract.function('greet');
    try {
      List<dynamic> response = await web3Client
          .call(contract: contract, function: getGreetingFunction, params: []);
      emit(FetchGreetingSuccess(message: response[0]));
    } catch (e) {
      emit(FetchGreetingFailed(errorCode: '', message: e.toString()));
    }
  }
}
