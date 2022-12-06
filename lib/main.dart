import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';

import 'package:sophon/configs/themes.dart';
import 'package:sophon/configs/web3_config.dart';
import 'package:sophon/infrastructures/repository/secure_storage_repository.dart';
import 'package:sophon/infrastructures/service/cubit/secure_storage_cubit.dart';
import 'package:sophon/module/auth/interfaces/screens/authentication_screen.dart';
import 'package:sophon/module/auth/service/cubit/auth_cubit.dart';
import 'package:sophon/module/home/service/cubit/greeting_cubit.dart';

Future<void> main() async {
  /// Load env file
  await dotenv.load();

  runApp(
    MyApp(
      walletConnect: await walletConnect,
      contract: await deployedContract,
      web3client: web3Client,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    required this.walletConnect,
    required this.contract,
    required this.web3client,
    Key? key,
  }) : super(key: key);
  final WalletConnect walletConnect;
  final DeployedContract contract;
  final Web3Client web3client;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<GreetingCubit>(
          create: (BuildContext context) => GreetingCubit(
            contract: contract,
            web3Client: web3client,
          ),
        ),
        BlocProvider<AuthCubit>(
          create: (BuildContext context) => AuthCubit(
            storage: SecureStorageRepository(),
            connector: walletConnect,
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
