import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';

import 'package:sophon/configs/helpers/ethereum_credentials.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'greeting_state.dart';

class GreetingCubit extends Cubit<GreetingState> {
  GreetingCubit() : super(const GreetingState());

  final String contractAddress = '0x093eb7ccAfa165D8D35c6666984de510Be58cBd2';
  final String abiDirectory = 'assets/abi/greeter.abi.json';

  late SessionStatus sessionStatus;
  late String sender;
  late EthereumWalletConnectProvider provider;
  late WalletConnectEthereumCredentials wcCreds;
  late String contractABI;
  late DeployedContract contract;
  late ContractFunction setGreetingFunction;
  late Timer fetchGreetingTimer;
  late WalletConnect walletConnector;

  String latestGreeting = '';

  Web3Client web3Client = Web3Client(
    'https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161', // Goerli RPC URL
    http.Client(),
  );

  String getNetworkName(chainId) {
    switch (chainId) {
      case 1:
        return 'Ethereum Mainnet';
      case 3:
        return 'Ropsten Testnet';
      case 4:
        return 'Rinkeby Testnet';
      case 5:
        return 'Goerli Testnet';
      case 42:
        return 'Kovan Testnet';
      case 137:
        return 'Polygon Mainnet';
      default:
        return 'Unknown Chain';
    }
  }

  /// Initializes the provider, sessionStatus, sender, credentials, etc.
  Future<void> initializeProvider({
    required SessionStatus session,
    required WalletConnect connector,
    required BuildContext context,
  }) async {
    walletConnector = connector;
    sessionStatus = session;
    sender = connector.session.accounts[0];
    provider = EthereumWalletConnectProvider(connector);
    wcCreds = WalletConnectEthereumCredentials(provider: provider);
    contractABI = await DefaultAssetBundle.of(context).loadString(abiDirectory);
    var abiJSON = jsonDecode(contractABI);
    contract = DeployedContract(
      ContractAbi.fromJson(json.encode(abiJSON), 'Greeter'),
      EthereumAddress.fromHex(contractAddress),
    );
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
