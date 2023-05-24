import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sophon/configs/themes.dart';
import 'package:sophon/internal/wallet_external_configuration.dart';
import 'package:sophon/module/auth/service/cubit/auth_cubit.dart';
import 'package:sophon/module/home/interfaces/screens/home_screen.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({Key? key}) : super(key: key);

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  Future<void> _launchApp() async {
    final bool isInstalled = await LaunchApp.isAppInstalled(
      androidPackageName: metaMaskPackageName,
      iosUrlScheme: metamaskWalletScheme,
    );

    /// If there is an exisitng app, just launch the app.
    if (isInstalled) {
      if (!mounted) return;
      context.read<AuthCubit>().loginWithMetamask();
      return;
    }

    /// If there is no exisitng app, launch app store.
    await LaunchApp.openApp(
      androidPackageName: metaMaskPackageName,
      iosUrlScheme: metamaskWalletScheme,
      appStoreLink: metamaskAppsStoreLink,
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<AuthCubit>().initiateListeners());
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (AuthState previous, AuthState current) =>
          current is EstablishConnectionSuccess ||
          current is LoginWithMetamaskSuccess ||
          current is LoginWithMetamaskFailed ||
          current is InitializeWeb3AuthSuccess ||
          current is LoginWithGoogleSuccess,
      listener: (BuildContext context, AuthState state) {
        if (state is EstablishConnectionSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => HomeScreen(
                session: state.session,
                connector: state.connector,
                uri: state.uri,
              ),
            ),
          );
        } else if (state is LoginWithMetamaskSuccess) {
          launchUrlString(state.url, mode: LaunchMode.externalApplication);
        } else if (state is LoginWithMetamaskFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.errorColor,
            ),
          );
        } else if (state is LoginWithGoogleSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => HomeScreen(
                session: 'state.session',
                connector: WalletConnect(),
                uri: 'state.uri',
              ),
            ),
          );
        }
      },
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: flirtGradient,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: height * 0.4),
                  child: Text(
                    'Sophon',
                    style: theme.textTheme.headline3,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.2,
                    vertical: height * 0.05,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Connect your Ethereum Wallet',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ElevatedButton.icon(
                              onPressed: () => _launchApp(),
                              icon: Image.asset(
                                'assets/images/metamask-logo.png',
                                width: 16,
                              ),
                              label: Text('Login with Metamask',
                                  style: theme.textTheme.subtitle1),
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
                        ],
                      ),
                      BlocBuilder<AuthCubit, AuthState>(
                        buildWhen: (AuthState previous, AuthState current) =>
                            current is InitializeWeb3AuthSuccess,
                        builder: (BuildContext context, AuthState state) {
                          if (state is InitializeWeb3AuthSuccess) {
                            return ElevatedButton(
                              onPressed: () =>
                                  context.read<AuthCubit>().loginWithGoogle(),
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all(0),
                              ),
                              child: const Text('Login via Google'),
                            );
                          }
                          return const SizedBox.shrink();
                        },
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
