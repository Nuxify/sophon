import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sophon/application/service/cubit/web3_cubit.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  Future<void> initialize() async {
    context.read<Web3Cubit>().instantiate();
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
        children: <Widget>[
          Expanded(
            child: BlocBuilder<Web3Cubit, Web3State>(
              buildWhen: (Web3State previous, Web3State current) =>
                  current is Web3MInitialized,
              builder: (BuildContext context, Web3State state) {
                if (state is Web3MInitialized) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        W3MConnectWalletButton(service: state.service),
                        FilledButton(
                          onPressed: () {
                            context
                                .read<Web3Cubit>()
                                .updateGreeting(text: '2024');
                          },
                          child: const Text('Write'),
                        ),
                        FilledButton(
                          onPressed: () {
                            context.read<Web3Cubit>().fetchGreeting();
                          },
                          child: const Text('Read'),
                        ),
                      ],
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
