import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sophon/application/service/cubit/web3_cubit.dart';
import 'package:sophon/configs/web3_config.dart';
import 'package:sophon/internal/web3_contract.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late W3MService w3mService;
  bool serviceIsInitialized = false;

  Future<void> initialize() async {
    try {
      context.read<Web3Cubit>().updateGreeting(text: '2024');
      setState(() {
        serviceIsInitialized = true;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (serviceIsInitialized)
            Expanded(
              child: Center(
                child: W3MConnectWalletButton(service: w3mService),
              ),
            ),
        ],
      ),
    );
  }
}
