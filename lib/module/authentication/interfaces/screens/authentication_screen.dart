import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sophon/configs/themes.dart';
import 'package:sophon/infrastructures/service/cubit/secure_storage_cubit.dart';
import 'package:sophon/module/authentication/service/cubit/auth_cubit.dart';
import 'package:sophon/module/home/interfaces/screens/home_screen.dart';
import 'package:sophon/utils/wallet_status_storage.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({Key? key}) : super(key: key);

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  /// Add loader to fetch initial status.
  bool isLoading = true;

  Future<void> isStatusConnected() async {
    String? provider =
        await context.read<SecureStorageCubit>().read(key: providerKey);

    if (!mounted) return;
    String? status =
        await context.read<SecureStorageCubit>().read(key: statusKey);

    /// If there is a previous session that is not disconnected, reconnect to it.
    if ((provider != null && provider.isNotEmpty) &&
        (status != null && status != disconnected)) {
      switch (provider) {
        case metamask:
          if (!mounted) return;
          context.read<AuthCubit>().loginWithMetamask();
          return;
      }
    }

    /// Load all the selection of wallets.
    Future.delayed(const Duration(milliseconds: 800),
        () => setState(() => isLoading = false));
  }

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().initiateListeners();

    /// Check if there is a previous connection.
    isStatusConnected();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is EstablishConnectionSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomeScreen(
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
              children: [
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
                    children: [
                      Text(
                        'Connect your Ethereum Wallet',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      if (isLoading)
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Column(
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8.0),
                                child: SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              Text(
                                'Fetching initial data.',
                                style: theme.textTheme.caption,
                              )
                            ],
                          ),
                        )
                      else
                        Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: ElevatedButton.icon(
                                onPressed: () => context
                                    .read<AuthCubit>()
                                    .loginWithMetamask(),
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
