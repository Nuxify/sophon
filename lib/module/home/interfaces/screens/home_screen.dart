import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nuxify_widgetbook/input/filled_textfield.dart';
import 'package:nuxify_widgetbook/views/alert_dialog.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sophon/application/service/cubit/web3_cubit.dart';
import 'package:sophon/configs/themes.dart';
import 'package:sophon/module/auth/interfaces/screens/authentication_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController greetingTextController = TextEditingController();
  late Timer timer;

  void startContractReadInterval() {
    timer = Timer.periodic(const Duration(seconds: 5), (_) {
      context.read<Web3Cubit>().fetchGreeting();
    });
  }

  @override
  void initState() {
    super.initState();
    context.read<Web3Cubit>().fetchGreeting();
    startContractReadInterval();
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final bool isLoginWithWalletConnect =
        context.read<Web3Cubit>().isLoginWithWalletConnect;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white10,
        elevation: 0,
        title: const Text('Sophon'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (_) => AppAlertDialog(
                title: 'Disconnect Wallet',
                bodyText: 'Are you sure you want to disconnect your wallet?',
                actionButton: FilledButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(kPink),
                  ),
                  onPressed: () {
                    context.read<Web3Cubit>().endSession();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute<dynamic>(
                        builder: (_) => const AuthenticationScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Confirm',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          },
          icon: const Icon(Icons.close_rounded),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: width,
              margin: const EdgeInsets.only(
                top: 20,
                left: 25,
                right: 25,
                bottom: 30,
              ),
              padding: EdgeInsets.symmetric(
                vertical: height * 0.03,
                horizontal: width * 0.05,
              ),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kPink.withOpacity(0.5)),
              ),
              child: BlocBuilder<Web3Cubit, Web3State>(
                buildWhen: (Web3State previous, Web3State current) =>
                    current is FetchGreetingSuccess ||
                    current is FetchGreetingFailed ||
                    current is FetchGreetingLoading,
                builder: (BuildContext context, Web3State state) {
                  if (state is FetchGreetingSuccess) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'THE CONTRACT CURRENTLY READS:',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '"${state.message}"',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    );
                  }
                  return Shimmer.fromColors(
                    baseColor: shimmerBase,
                    highlightColor: shimmerGlow,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        color: Colors.white,
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: 45,
                    ),
                  );
                },
              ),
            ),
            Container(
              color: Colors.white10,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: isLoginWithWalletConnect
                  ? SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => launchUrl(
                          Uri.parse(
                            'https://secure.walletconnect.com/dashboard',
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(kPink),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Upgrade Wallet',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Row(
                      children: <Widget>[
                        Expanded(
                          child: FilledTextField(
                            hintText: 'Update the contract...',
                            hintStyle: const TextStyle(
                              color: Colors.white30,
                              fontSize: 13,
                            ),
                            controller: greetingTextController,
                            fillColor: Colors.white.withOpacity(0.05),
                            isDense: true,
                          ),
                        ),
                        IconButton.filled(
                          color: kPink,
                          focusColor: kPink,
                          highlightColor: kPink,
                          hoverColor: kPink,
                          splashColor: kPink,
                          disabledColor: kPink,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(kPink),
                          ),
                          onPressed: () {
                            context.read<Web3Cubit>().updateGreeting(
                                  text: greetingTextController.text,
                                );
                            greetingTextController.text = '';
                          },
                          icon: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
