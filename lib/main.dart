import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sophon/configs/themes.dart';
import 'package:sophon/infrastructures/repository/secure_storage_repository.dart';
import 'package:sophon/infrastructures/service/cubit/secure_storage_cubit.dart';
import 'package:sophon/internal/wc_session_storage.dart';
import 'package:sophon/module/auth/interfaces/screens/authentication_screen.dart';
import 'package:sophon/module/auth/service/cubit/auth_cubit.dart';
import 'package:sophon/module/home/service/cubit/greeting_cubit.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

Future<void> main() async {
  /// Load env file
  await dotenv.load();

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
  runApp(
    MyApp(
      walletConnect: walletConnect,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    required this.walletConnect,
    super.key,
  });
  final WalletConnect walletConnect;
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final DeployedContract _contract;
  late final Web3Client _web3client;

  Future<DeployedContract> get _deployedContract async {
    const String abiDirectory = 'lib/contracts/staging/greeter.abi.json';

    final String contractAddress = dotenv.get('GREETER_CONTRACT_ADDRESS');

    String contractABI = await rootBundle.loadString(abiDirectory);

    final DeployedContract contract = DeployedContract(
      ContractAbi.fromJson(contractABI, 'Greeter'),
      EthereumAddress.fromHex(contractAddress),
    );
    return contract;
  }

  Future<void> loadContract() async {
    _contract = await _deployedContract;
    _web3client = Web3Client(
      dotenv.get('ETHEREUM_RPC'), // Goerli RPC URL
      http.Client(),
    );
  }

  @override
  void initState() {
    super.initState();
    loadContract();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<GreetingCubit>(
          create: (BuildContext context) => GreetingCubit(
            contract: _contract,
            web3Client: _web3client,
          ),
        ),
        BlocProvider<AuthCubit>(
          create: (BuildContext context) => AuthCubit(
            storage: SecureStorageRepository(),
            connector: widget.walletConnect,
          ),
        ),
        BlocProvider<SecureStorageCubit>(
          create: (BuildContext context) => SecureStorageCubit(
            storage: SecureStorageRepository(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: buildDefaultTheme(context),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    /// Lock app to portrait mode
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return const AuthenticationScreen();
  }
}
