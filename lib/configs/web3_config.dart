import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sophon/internal/walletconnect_session_storage.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

/// Return a wallet connect object with a session storage, to persist the wallet session.
Future<WalletConnect> get walletConnect async {
  final WalletConnectSecureStorage sessionStorage =
      WalletConnectSecureStorage();
  WalletConnectSession? session = await sessionStorage.getSession();

  final WalletConnect walletConnect = WalletConnect(
    session: session,
    sessionStorage: sessionStorage,
    bridge: 'https://bridge.walletconnect.org',
    clientMeta: const PeerMeta(
      name: 'Sophon',
      description:
          'A Flutter template for building amazing decentralized applications.',
      url: 'https://github.com/Nuxify/Sophon',
      icons: <String>[
        'https://files-nuximart.sgp1.cdn.digitaloceanspaces.com/nuxify-website/blog/images/Nuxify-logo.png'
      ],
    ),
  );

  return walletConnect;
}

/// Get deployed greeter contract
Future<DeployedContract> get deployedGreeterContract async {
  const String abiDirectory = 'lib/contracts/staging/greeter.abi.json';
  final String contractAddress = dotenv.get('GREETER_CONTRACT_ADDRESS');
  String contractABI = await rootBundle.loadString(abiDirectory);

  final DeployedContract contract = DeployedContract(
    ContractAbi.fromJson(contractABI, 'Greeter'),
    EthereumAddress.fromHex(contractAddress),
  );

  return contract;
}

/// Return web3client object.
Web3Client get web3Client {
  return Web3Client(
    dotenv.get('ETHEREUM_RPC'),
    http.Client(),
  );
}
