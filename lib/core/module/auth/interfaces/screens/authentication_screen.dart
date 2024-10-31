import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sophon/core/application/service/cubit/web3_api_cubit.dart';
import 'package:sophon/core/module/home/interfaces/screens/home_screen.dart';
import 'package:sophon/gen/assets.gen.dart';
import 'package:sophon/internal/utils.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  @override
  void initState() {
    super.initState();
    context.read<Web3APICubit>().instantiate();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return BlocListener<Web3APICubit, Web3APIState>(
      listenWhen: (Web3APIState previous, Web3APIState current) =>
          current is InitializeWeb3MSuccess ||
          current is WalletConnectionFailed,
      listener: (BuildContext context, Web3APIState state) {
        if (state is InitializeWeb3MSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute<dynamic>(
              builder: (_) => HomeScreen(w3mService: state.service),
            ),
          );
        } else if (state is WalletConnectionFailed) {
          showSnackbar(context, isSuccessful: false, message: state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 20,
              left: 25,
              right: 25,
              bottom: 30,
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Assets.images.space.image(width: width * 0.8),
                      const Text(
                        'Sophon',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    'Interact with a Smart Contract by connecting your wallet',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
