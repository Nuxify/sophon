import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web3dart/web3dart.dart';

/// Get deployed greeter contract
Future<DeployedContract> get deployedGreeterContract async {
  const String abiDirectory =
      'lib/core/infrastructures/contracts/staging/greeter.abi.json';
  final String contractAddress = dotenv.get('GREETER_CONTRACT_ADDRESS');
  final String contractABI = await rootBundle.loadString(abiDirectory);

  final DeployedContract contract = DeployedContract(
    ContractAbi.fromJson(contractABI, 'Greeter'),
    EthereumAddress.fromHex(contractAddress),
  );

  return contract;
}
