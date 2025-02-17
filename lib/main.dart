import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:sophon/configs/themes.dart';
import 'package:sophon/core/application/service/cubit/secure_storage_cubit.dart';
import 'package:sophon/core/application/service/cubit/web3_cubit.dart';
import 'package:sophon/core/infrastructures/repository/secure_storage_repository.dart';
import 'package:sophon/core/module/auth/application/service/cubit/auth_cubit.dart';
import 'package:sophon/core/module/auth/interfaces/screens/authentication_screen.dart';

Future<void> main() async {
  /// Load env file
  await dotenv.load();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<Web3Cubit>(
          create: (BuildContext context) => Web3Cubit(),
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
      child: ReownAppKitModalTheme(
        isDarkMode: true,
        child: MaterialApp(
          title: 'Sophon',
          debugShowCheckedModeBanner: false,
          theme: defaultTheme,
          home: const MyHomePage(),
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthenticationScreen();
  }
}
