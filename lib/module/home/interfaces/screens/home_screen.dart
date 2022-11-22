import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';

import 'package:sophon/configs/helpers/ethereum_credentials.dart';
import 'package:sophon/configs/themes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
    required this.session,
    required this.connector,
    required this.uri,
  }) : super(key: key);

  final dynamic session;
  final WalletConnect connector;
  final String uri;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String contractAddress = '0x093eb7ccAfa165D8D35c6666984de510Be58cBd2';
  final String abiDirectory = 'assets/abi/greeter.abi.json';

  late SessionStatus sessionStatus;
  late String sender;
  late EthereumWalletConnectProvider provider;
  late WalletConnectEthereumCredentials wcCreds;
  late String contractABI;
  late DeployedContract contract;
  late ContractFunction setGreetingFunction;

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

  /// Terminates metamask connection
  void closeConnection() {
    setState(() {
      widget.connector.killSession();
      widget.connector.close();
    });
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  /// Parses the specifics of the Smart Contract (contract and function), launches MetaMask, then sends the write transaction.
  Future<void> writeTransaction() async {
    launchUrlString(widget.uri, mode: LaunchMode.externalApplication);

    try {
      String hash = await web3Client.sendTransaction(
        wcCreds,
        Transaction.callContract(
          contract: contract,
          function: setGreetingFunction,
          from: EthereumAddress.fromHex(sender),
          parameters: ['flutter update #2.'],
          maxGas: 210000,
          gasPrice: EtherAmount.inWei(BigInt.one),
        ),
        chainId: 5,
      );

      print('Hash: $hash');
    } catch (e) {
      print('Error: $e');
    }
  }

  /// Initializes the provider, sessionStatus, sender, credentials, etc.
  Future<void> initializeProvider() async {
    sessionStatus = widget.session;
    sender = widget.connector.session.accounts[0];
    provider = EthereumWalletConnectProvider(widget.connector);
    wcCreds = WalletConnectEthereumCredentials(provider: provider);
    contractABI = await DefaultAssetBundle.of(context).loadString(abiDirectory);
    contract = DeployedContract(
      ContractAbi.fromJson(json.encode(contractABI), 'Greeter'),
      EthereumAddress.fromHex(contractAddress),
    );
    setGreetingFunction = contract.function('setGreeting');
  }

  @override
  void initState() {
    super.initState();
    initializeProvider();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: violetGradient,
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(
                vertical: height * 0.06,
                horizontal: width * 0.07,
              ),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFFA166FE),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      offset: Offset(1, 5),
                      color: Colors.black38,
                      blurRadius: 10,
                    ),
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Address: ',
                    style: theme.textTheme.headline6
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Row(
                    children: [
                      Container(
                        width: width * 0.6,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          '${widget.session.accounts[0]}',
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headline6?.copyWith(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.copy,
                          size: 18,
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Chain: ',
                        style: theme.textTheme.headline6
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${getNetworkName(widget.session.chainId)} [ ${widget.session.chainId} ]',
                        style: theme.textTheme.headline6?.copyWith(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: writeTransaction,
                    icon: const Icon(Icons.e_mobiledata),
                    label: const Text('Write'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      elevation: MaterialStateProperty.all(0),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: height * 0.05),
                  child: widget.connector.connected
                      ? ElevatedButton.icon(
                          onPressed: closeConnection,
                          icon: const Icon(Icons.close),
                          label: const Text('Close Connection'),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blue),
                            elevation: MaterialStateProperty.all(0),
                          ),
                        )
                      : const CircularProgressIndicator(color: kLightViolet),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
