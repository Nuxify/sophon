import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nuxify_widgetbook/input/filled_textfield.dart';
import 'package:nuxify_widgetbook/views/alert_dialog.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sophon/configs/themes.dart';
import 'package:sophon/core/application/service/cubit/web3_cubit.dart';
import 'package:sophon/core/module/auth/interfaces/screens/authentication_screen.dart';
import 'package:sophon/gen/fonts.gen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController greetingTextController = TextEditingController();

  late Timer timer;

  ReownAppKitModal? w3mService;

  void startContractReadInterval() {
    timer = Timer.periodic(const Duration(seconds: 5), (_) {
      context.read<Web3Cubit>().fetchGreeting();
    });
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback(
      (_) => context.read<Web3Cubit>().instantiate(context),
    );
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

    return BlocListener<Web3Cubit, Web3State>(
      listenWhen: (Web3State previous, Web3State current) =>
          current is InitializeWeb3MSuccess ||
          current is FetchHomeScreenActionButtonSuccess,
      listener: (BuildContext context, Web3State state) {
        if (state is InitializeWeb3MSuccess) {
          setState(() => w3mService = state.service);

          context.read<Web3Cubit>().fetchHomeScreenActionButton();
        } else if (state is FetchHomeScreenActionButtonSuccess &&
            state.action == HomeScreenActionButton.writeToContract) {
          setState(() {});
          context.read<Web3Cubit>().fetchGreeting();
          startContractReadInterval();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: kPink,
          elevation: 0,
          title: const Text('Sophon'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Visibility(
                visible: w3mService != null && w3mService!.isConnected,
                child: Container(
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
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kPink.withValues(alpha: 0.5)),
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
                            RichText(
                              text: TextSpan(
                                children: <InlineSpan>[
                                  const TextSpan(
                                    text: 'Greeter Smart Contract at:\n\n',
                                  ),
                                  TextSpan(
                                    text:
                                        dotenv.get('GREETER_CONTRACT_ADDRESS'),
                                    style: const TextStyle(
                                      color: kPink,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  const TextSpan(text: '\n\nCurrently says:\n'),
                                ],
                                style: const TextStyle(
                                  fontFamily: FontFamily.openSans,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '"${state.message}"',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 16,
                                ),
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
              ),
              Container(
                color: Colors.white10,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: width,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: FilledButton.icon(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(kPink),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          final String blockchainExplorer = await context
                              .read<Web3Cubit>()
                              .blockchainExplorer;
                          await launchUrl(Uri.parse(blockchainExplorer));
                        },
                        label: const Icon(
                          Icons.launch_rounded,
                          color: Colors.white,
                          size: 17,
                        ),
                        icon: const Text(
                          'Launch Block Explorer',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    BlocBuilder<Web3Cubit, Web3State>(
                      buildWhen: (Web3State previous, Web3State current) =>
                          current is FetchHomeScreenActionButtonSuccess,
                      builder: (BuildContext context, Web3State state) {
                        if (state is FetchHomeScreenActionButtonSuccess &&
                            state.action ==
                                HomeScreenActionButton.upgradeWallet) {
                          return SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () => launchUrl(
                                Uri.parse(
                                  'https://secure.walletconnect.com/dashboard',
                                ),
                              ),
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(kPink),
                                shape: WidgetStateProperty.all(
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
                          );
                        } else if (state
                                is FetchHomeScreenActionButtonSuccess &&
                            state.action ==
                                HomeScreenActionButton.connectWallet) {
                          return AppKitModalConnectButton(
                            context: context,
                            appKit: w3mService!,
                            custom: SizedBox(
                              width: width,
                              child: FilledButton.icon(
                                onPressed: () => w3mService!.openModalView(),
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all(kPink),
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                  ),
                                ),
                                icon: const Text(
                                  'Connect Wallet',
                                  style: TextStyle(color: Colors.white),
                                ),
                                label: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        } else if (state
                                is FetchHomeScreenActionButtonSuccess &&
                            state.action ==
                                HomeScreenActionButton.writeToContract) {
                          return Column(
                            children: <Widget>[
                              Container(
                                width: width,
                                padding:
                                    const EdgeInsets.only(bottom: 8, top: 4),
                                child: FilledButton.icon(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.all(kPink),
                                    shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(11),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    showDialog<void>(
                                      context: context,
                                      builder: (_) => AppAlertDialog(
                                        title: 'Disconnect Wallet',
                                        bodyText:
                                            'Are you sure you want to disconnect your wallet?',
                                        actionButton: FilledButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStateProperty.all(kPink),
                                          ),
                                          onPressed: () {
                                            context
                                                .read<Web3Cubit>()
                                                .endSession();
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute<dynamic>(
                                                builder: (_) =>
                                                    const AuthenticationScreen(),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            'Confirm',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  label: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 17,
                                  ),
                                  icon: const Text(
                                    'Disconnect Wallet',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: FilledTextField(
                                      borderRadius: 8,
                                      hintText: 'Update the contract...',
                                      hintStyle: const TextStyle(
                                        color: Colors.white30,
                                        fontSize: 13,
                                      ),
                                      controller: greetingTextController,
                                      fillColor:
                                          Colors.white.withValues(alpha: 0.05),
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
                                      backgroundColor:
                                          WidgetStateProperty.all(kPink),
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
                            ],
                          );
                        }
                        return const SizedBox(child: LinearProgressIndicator());
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
