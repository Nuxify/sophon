import 'dart:async';
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
  late Timer fetchGreetingTimer;

  TextEditingController greetingTextController = TextEditingController();
  String latestGreeting = '';

  Web3Client web3Client = Web3Client(
    'https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161', // Goerli RPC URL
    http.Client(),
  );

  ButtonStyle buttonStyle = ButtonStyle(
    backgroundColor: MaterialStateProperty.all(Colors.transparent),
    elevation: MaterialStateProperty.all(0),
    side: MaterialStateProperty.all(
      const BorderSide(color: Colors.white),
    ),
  );

  /// Initializes the provider, sessionStatus, sender, credentials, etc.
  Future<void> initializeProvider() async {
    sessionStatus = widget.session;
    sender = widget.connector.session.accounts[0];
    provider = EthereumWalletConnectProvider(widget.connector);
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
  }

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
  Future<void> updateGreeting() async {
    launchUrlString(widget.uri, mode: LaunchMode.externalApplication);
    try {
      await web3Client.sendTransaction(
        wcCreds,
        Transaction.callContract(
          contract: contract,
          function: setGreetingFunction,
          from: EthereumAddress.fromHex(sender),
          parameters: [greetingTextController.text],
        ),
        chainId: 5,
      );
      greetingTextController.text = '';
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchGreeting() async {
    ContractFunction getGreetingFunction = contract.function('greet');
    try {
      List<dynamic> response = await web3Client
          .call(contract: contract, function: getGreetingFunction, params: []);
      setState(() => latestGreeting = response[0]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    initializeProvider();
  }

  @override
  void dispose() {
    super.dispose();
    fetchGreetingTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        // ignore: use_decorated_box
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: flirtGradient),
          ),
        ),
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.1,
                  vertical: width * 0.05,
                ),
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(10)),
                  gradient: const LinearGradient(colors: flirtGradient),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 13),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(60),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Text(
                            'Account Address: ',
                            style: theme.textTheme.subtitle2,
                          ),
                          Expanded(
                            flex: 1,
                            child: SizedBox(
                              width: width * 0.6,
                              child: Text(
                                '${widget.session.accounts[0]}',
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.subtitle2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(60),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Chain: ',
                            style: theme.textTheme.subtitle2,
                          ),
                          Text(
                            getNetworkName(widget.session.chainId),
                            style: theme.textTheme.subtitle2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.07,
                      vertical: height * 0.03,
                    ),
                    margin: EdgeInsets.only(
                      left: width * 0.03,
                      right: width * 0.03,
                      bottom: height * 0.03,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: flirtGradient),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(10),
                        top: Radius.circular(10),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset:
                              const Offset(0, 13), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(60),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                          width: width,
                          child: Text(
                            latestGreeting,
                            style: theme.textTheme.headline6?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.07,
                      vertical: height * 0.03,
                    ),
                    margin: EdgeInsets.symmetric(horizontal: width * 0.03),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: flirtGradient),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(10),
                        top: Radius.circular(10),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset:
                              const Offset(0, 13), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(children: [
                      TextField(
                        controller: greetingTextController,
                        autofocus: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          hintText: 'What\'s in your head?',
                          fillColor: Colors.white.withAlpha(60),
                          filled: true,
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: ElevatedButton.icon(
                          onPressed: updateGreeting,
                          icon: const Icon(Icons.edit),
                          label: const Text('Update Greeting'),
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(0),
                            backgroundColor: MaterialStateProperty.all(
                              Colors.white.withAlpha(60),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  gradient: const LinearGradient(colors: flirtGradient),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: width,
                      child: ElevatedButton.icon(
                        onPressed: closeConnection,
                        icon: const Icon(
                          Icons.power_settings_new,
                        ),
                        label: Text('Disconnect',
                            style: theme.textTheme.subtitle1),
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(0),
                          backgroundColor: MaterialStateProperty.all(
                            Colors.white.withAlpha(60),
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
