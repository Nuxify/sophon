import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sophon/internal/wc_session_storage.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

/// This will return a wallet connect object with a session storage, to persist the wallet session.
Future<WalletConnect> get walletConnect async {
  final WalletConnectSecureStorage sessionStorage =
      WalletConnectSecureStorage();
  WalletConnectSession? session = await sessionStorage.getSession();

  final WalletConnect walletConnect = WalletConnect(
    session: session,
    sessionStorage: sessionStorage,
    bridge: 'https://bridge.walletconnect.org',
    clientMeta: const PeerMeta(
      name: 'Nuxify Greeter Client',
      description: 'An app for converting pictures to NFT',
      url: 'https://github.com/Nuxify/Sophon',
      icons: [
        'https://files-nuximart.sgp1.cdn.digitaloceanspaces.com/nuxify-website/blog/images/Nuxify-logo.png'
      ],
    ),
  );
  return walletConnect;
}

/// This will return DeployedContract deployed contract.
Future<DeployedContract> get deployedContract async {
  const String abiDirectory = 'lib/contracts/staging/greeter.abi.json';

  final String contractAddress = dotenv.get('GREETER_CONTRACT_ADDRESS');

  String contractABI = await rootBundle.loadString(abiDirectory);

  final DeployedContract contract = DeployedContract(
    ContractAbi.fromJson(contractABI, 'Greeter'),
    EthereumAddress.fromHex(contractAddress),
  );
  return contract;
}

/// This will return web3client object.
Web3Client get web3Client {
  return Web3Client(
    dotenv.get('ETHEREUM_RPC'), // Goerli RPC URL
    http.Client(),
  );
}
