import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sophon/internal/web3_utils.dart';
import 'package:sophon/module/auth/interfaces/screens/authentication_screen.dart';
import 'package:sophon/infrastructures/service/cubit/web3_cubit.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sophon/configs/themes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.loginType,
    this.session,
    this.uri,
    this.connector,
    Key? key,
  }) : super(key: key);

  final dynamic session;
  final WalletConnect? connector;
  final String? uri;
  final LoginType loginType;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String accountAddress = '';
  String networkName = '';
  TextEditingController greetingTextController = TextEditingController();

  ButtonStyle buttonStyle = ButtonStyle(
    elevation: MaterialStateProperty.all(0),
    backgroundColor: MaterialStateProperty.all(
      Colors.white.withAlpha(60),
    ),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    ),
  );

  void updateGreetingViaMetamask() {
    FocusScope.of(context).unfocus();
    launchUrlString(widget.uri!, mode: LaunchMode.externalApplication);
    context
        .read<Web3Cubit>()
        .updateGreetingViaMetaMask(greetingTextController.text);
    greetingTextController.text = '';
  }

  void updateGreetingViaGoogle() {
    FocusScope.of(context).unfocus();
    context
        .read<Web3Cubit>()
        .updateGreetingViaGoogle(greetingTextController.text);
    greetingTextController.text = '';
  }

  @override
  void initState() {
    super.initState();

    if (widget.loginType == LoginType.metaMask) {
      /// Execute after frame is rendered to get the emit state of InitializeMetaMaskProviderSuccess
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<Web3Cubit>().initializeMetaMaskProvider(
              connector: widget.connector!,
              session: widget.session,
            ),
      );
    } else if (widget.loginType == LoginType.google) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<Web3Cubit>().initializeGoogleProvider(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return BlocListener<Web3Cubit, Web3State>(
      listener: (BuildContext context, Web3State state) {
        if (state is SessionTerminated) {
          Future<void>.delayed(const Duration(seconds: 1), () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const AuthenticationScreen(),
              ),
            );
          });
        } else if (state is UpdateGreetingFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is FetchGreetingFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is InitializeMetaMaskProviderSuccess) {
          setState(() {
            accountAddress = state.accountAddress;
            networkName = state.networkName;
          });
        } else if (state is InitializeGoogleProviderSuccess) {
          setState(() {
            accountAddress = state.accountAddress;
            networkName = state.networkName;
          });
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: <Color>[kPink2, kPink2]),
              ),
            ),
            toolbarHeight: 0,
            automaticallyImplyLeading: false,
          ),
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: DecoratedBox(
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.1,
                      vertical: width * 0.05,
                    ),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(10),
                      ),
                      color: kPink2,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black12,
                          spreadRadius: 4,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(60),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: <Widget>[
                              Text(
                                'Account Address: ',
                                style: theme.textTheme.subtitle2,
                              ),
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  width: width * 0.6,
                                  child: Text(
                                    accountAddress,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.subtitle2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(60),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                          child: Row(
                            children: <Widget>[
                              Text(
                                'Chain: ',
                                style: theme.textTheme.subtitle2,
                              ),
                              Text(
                                networkName,
                                style: theme.textTheme.subtitle2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.07,
                          vertical: height * 0.03,
                        ),
                        margin: EdgeInsets.only(
                          left: width * 0.03,
                          right: width * 0.03,
                          bottom: height * 0.03,
                        ),
                        decoration: const BoxDecoration(
                          color: kPink2,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(10),
                            top: Radius.circular(10),
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black12,
                              spreadRadius: 4,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(60),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                              width: width,
                              child: BlocBuilder<Web3Cubit, Web3State>(
                                buildWhen:
                                    (Web3State previous, Web3State current) =>
                                        current is FetchGreetingSuccess ||
                                        current is UpdateGreetingLoading,
                                builder:
                                    (BuildContext context, Web3State state) {
                                  if (state is FetchGreetingSuccess) {
                                    return Text(
                                      '"${state.message}"',
                                      style:
                                          theme.textTheme.headline6?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    );
                                  }
                                  return LinearProgressIndicator(
                                    backgroundColor: Colors.transparent,
                                    color: Colors.white.withOpacity(0.5),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.07,
                          vertical: height * 0.03,
                        ),
                        margin: EdgeInsets.symmetric(horizontal: width * 0.03),
                        decoration: const BoxDecoration(
                          color: kPink2,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(10),
                            top: Radius.circular(10),
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black12,
                              spreadRadius: 4,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            TextField(
                              controller: greetingTextController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.white),
                                ),
                                hintText: 'What\'s in your head?',
                                fillColor: Colors.white.withAlpha(60),
                                filled: true,
                              ),
                            ),
                            SizedBox(
                              width: width,
                              child: BlocBuilder<Web3Cubit, Web3State>(
                                buildWhen:
                                    (Web3State previous, Web3State current) =>
                                        current is UpdateGreetingLoading ||
                                        current is UpdateGreetingSuccess ||
                                        current is UpdateGreetingFailed,
                                builder:
                                    (BuildContext context, Web3State state) {
                                  if (state is UpdateGreetingLoading) {
                                    return ElevatedButton.icon(
                                      onPressed: () {},
                                      style: buttonStyle,
                                      icon: SizedBox(
                                        height: height * 0.03,
                                        width: height * 0.03,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      label: const Text(''),
                                    );
                                  }
                                  return ElevatedButton.icon(
                                    onPressed:
                                        widget.loginType == LoginType.metaMask
                                            ? updateGreetingViaMetamask
                                            : updateGreetingViaGoogle,
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Update Greeting'),
                                    style: buttonStyle,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                      color: kPink2,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black12,
                          spreadRadius: 4,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: width,
                          child: ElevatedButton.icon(
                            onPressed: () => context
                                .read<Web3Cubit>()
                                .closeConnection(widget.loginType),
                            icon: const Icon(
                              Icons.power_settings_new,
                            ),
                            label: Text('Disconnect',
                                style: theme.textTheme.subtitle1),
                            style: ButtonStyle(
                              elevation: MaterialStateProperty.all(0),
                              backgroundColor: MaterialStateProperty.all(
                                Colors.white.withAlpha(60),
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
