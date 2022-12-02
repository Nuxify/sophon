import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sophon/configs/themes.dart';
import 'package:sophon/infrastructures/repository/secure_storage_repository.dart';
import 'package:sophon/infrastructures/service/cubit/secure_storage_cubit.dart';
import 'package:sophon/module/auth/interfaces/screens/authentication_screen.dart';
import 'package:sophon/module/auth/service/cubit/auth_cubit.dart';
import 'package:sophon/module/home/service/cubit/greeting_cubit.dart';
import 'package:web3dart/contracts.dart';
import 'package:web3dart/credentials.dart';

Future<void> main() async {
  /// Load env file
  await dotenv.load();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final DeployedContract _contract;

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
          ),
        ),
        BlocProvider<AuthCubit>(
          create: (BuildContext context) => AuthCubit(
            storage: SecureStorageRepository(),
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
