import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sophon/module/home/service/cubit/greeting_cubit.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sophon/configs/themes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
    required this.session,
    required this.connector,
    required this.uri,
  }) : super(key: key);

  final dynamic session;
  final WalletConnect connector;
  final String uri;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String accountAddress = '';
  String networkName = '';
  TextEditingController greetingTextController = TextEditingController();

  ButtonStyle buttonStyle = ButtonStyle(
    backgroundColor: MaterialStateProperty.all(Colors.transparent),
    elevation: MaterialStateProperty.all(0),
    side: MaterialStateProperty.all(
      const BorderSide(color: Colors.white),
    ),
  );

  void updateGreeting() {
    launchUrlString(widget.uri, mode: LaunchMode.externalApplication);

    context.read<GreetingCubit>().updateGreeting(greetingTextController.text);
    greetingTextController.text = '';
  }

  @override
  void initState() {
    super.initState();
    context.read<GreetingCubit>().initializeProvider(
          session: widget.session,
          connector: widget.connector,
          context: context,
        );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return BlocListener<GreetingCubit, GreetingState>(
      listener: (context, state) {
        if (state is SessionTerminated) {
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pop(context);
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
        } else if (state is InitializeProviderSuccess) {
          setState(() {
            accountAddress = state.accountAddress;
            networkName = state.networkName;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          // ignore: use_decorated_box
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: flirtGradient),
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
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.1,
                    vertical: width * 0.05,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(10),
                    ),
                    gradient: const LinearGradient(colors: flirtGradient),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 13),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          children: [
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
                          children: [
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
                  children: [
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
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: flirtGradient),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(10),
                          top: Radius.circular(10),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(
                                0, 13), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
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
                            child: BlocBuilder<GreetingCubit, GreetingState>(
                              builder: (context, state) {
                                if (state is FetchGreetingSuccess) {
                                  return Text(
                                    '"${state.message}"',
                                    style: theme.textTheme.headline6?.copyWith(
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
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: flirtGradient),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(10),
                          top: Radius.circular(10),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(
                              0,
                              13,
                            ), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(children: [
                        TextField(
                          controller: greetingTextController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            hintText: 'What\'s in your head?',
                            fillColor: Colors.white.withAlpha(60),
                            filled: true,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: ElevatedButton.icon(
                            onPressed: updateGreeting,
                            icon: const Icon(Icons.edit),
                            label: const Text('Update Greeting'),
                            style: ButtonStyle(
                              elevation: MaterialStateProperty.all(0),
                              backgroundColor: MaterialStateProperty.all(
                                Colors.white.withAlpha(60),
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    gradient: const LinearGradient(colors: flirtGradient),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: width,
                        child: ElevatedButton.icon(
                          onPressed:
                              context.read<GreetingCubit>().closeConnection,
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
    );
  }
}
