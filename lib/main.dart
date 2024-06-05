import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sophon/application/service/cubit/secure_storage_cubit.dart';
import 'package:sophon/application/service/cubit/web3_cubit.dart';
import 'package:sophon/configs/themes.dart';
import 'package:sophon/configs/web3_config.dart';
import 'package:sophon/infrastructures/repository/secure_storage_repository.dart';
import 'package:sophon/module/auth/application/service/cubit/auth_cubit.dart';
import 'package:sophon/module/auth/interfaces/screens/authentication_screen.dart';
import 'package:sophon/module/home/interfaces/screens/test.dart';
// import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';

Future<void> main() async {
  /// Load env file
  await dotenv.load();

  runApp(
    MyApp(
      // walletConnect: await walletConnect,
      greeterContract: await deployedGreeterContract,
      web3client: web3Client,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    // required this.walletConnect,
    required this.greeterContract,
    required this.web3client,
    super.key,
  });
  // final WalletConnect walletConnect;
  final DeployedContract greeterContract;
  final Web3Client web3client;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<Web3Cubit>(
          create: (BuildContext context) => Web3Cubit(
            web3Client: web3client,
            greeterContract: greeterContract,
            storage: SecureStorageRepository(),
          ),
        ),
        BlocProvider<AuthCubit>(
          create: (BuildContext context) => AuthCubit(
            storage: SecureStorageRepository(),
            // connector: walletConnect,
          ),
        ),
        BlocProvider<SecureStorageCubit>(
          create: (BuildContext context) => SecureStorageCubit(
            storage: SecureStorageRepository(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Sophon',
        debugShowCheckedModeBanner: false,
        theme: defaultTheme,
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const TestScreen();
  }
}
