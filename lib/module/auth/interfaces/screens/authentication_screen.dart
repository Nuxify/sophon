import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sophon/configs/themes.dart';
import 'package:sophon/configs/metamask_config.dart';
import 'package:sophon/internal/web3_utils.dart';
import 'package:sophon/module/auth/service/cubit/auth_cubit.dart';
import 'package:sophon/module/home/interfaces/screens/home_screen.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({Key? key}) : super(key: key);

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final ButtonStyle buttonStyle = ButtonStyle(
    alignment: Alignment.centerLeft,
    side: MaterialStateProperty.all(const BorderSide(color: kPink)),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  );
  Future<void> _launchApp() async {
    final bool isInstalled = await LaunchApp.isAppInstalled(
      androidPackageName: metaMaskPackageName,
      iosUrlScheme: metaMaskWalletScheme,
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
      iosUrlScheme: metaMaskWalletScheme,
      appStoreLink: metaMaskAppsStoreLink,
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().initializeWalletConnectListeners();
      context.read<AuthCubit>().initializeWeb3Auth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double width = MediaQuery.of(context).size.width;

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (AuthState previous, AuthState current) =>
          current is EstablishConnectionSuccess ||
          current is LoginWithMetamaskSuccess ||
          current is LoginWithMetamaskFailed ||
          current is InitializeWeb3AuthSuccess ||
          current is LoginWithWeb3AuthSuccess,
      listener: (BuildContext context, AuthState state) {
        if (state is EstablishConnectionSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => HomeScreen(
                session: state.session,
                connector: state.connector,
                uri: state.uri,
                provider: WalletProvider.metaMask,
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
        } else if (state is LoginWithWeb3AuthSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (BuildContext context) =>
                  const HomeScreen(provider: WalletProvider.web3Auth),
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: flirtGradient,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(30),
            width: width * 0.75,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Colors.black12,
                  spreadRadius: 4,
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Sophon',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: kPink,
                      fontWeight: FontWeight.w500,
                      fontSize: 30,
                    ),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: OutlinedButton.icon(
                    onPressed: () => _launchApp(),
                    label: const Text('Login with MetaMask'),
                    style: buttonStyle,
                    icon: Image.asset(
                      'assets/images/metamask-logo.png',
                      width: 16,
                    ),
                  ),
                ),
                BlocBuilder<AuthCubit, AuthState>(
                  buildWhen: (AuthState previous, AuthState current) =>
                      current is InitializeWeb3AuthSuccess,
                  builder: (BuildContext context, AuthState state) {
                    if (state is InitializeWeb3AuthSuccess) {
                      return SizedBox(
                        width: width,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              context.read<AuthCubit>().loginWithGoogle(),
                          label: const Text('Login with Google'),
                          style: buttonStyle,
                          icon: Image.asset(
                            'assets/images/google-logo.png',
                            width: 16,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
