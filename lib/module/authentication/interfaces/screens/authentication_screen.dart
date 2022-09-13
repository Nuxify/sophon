import 'package:flutter/material.dart';
import 'package:sophon/configs/themes.dart';
import 'package:sophon/module/home/interfaces/screens/home_screen.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({Key? key}) : super(key: key);

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  dynamic _session;
  String _uri = '';

  WalletConnect connector = WalletConnect(
    bridge: 'https://bridge.walletconnect.org',
    clientMeta: const PeerMeta(
      name: 'My App',
      description: 'An app for converting pictures to NFT',
      url: 'https://opensea.io/',
      icons: [
        'https://ca.slack-edge.com/T01446UKF89-U015K3WTFGC-5de06fff3b26-512'
      ],
    ),
  );

  Future<void> loginUsingMetamask(BuildContext context) async {
    if (!connector.connected) {
      try {
        SessionStatus session =
            await connector.createSession(onDisplayUri: (uri) async {
          _uri = uri;
          await launchUrlString(uri, mode: LaunchMode.externalApplication);
        });
        setState(() => _session = session);
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  String getNetworkName(chainId) {
    switch (chainId) {
      case 1:
        return 'Ethereum Mainnet';
      case 3:
        return 'Ropsten Testnet';
      case 4:
        return 'Rinkeby Testnet';
      case 5:
        return 'Goerli Testnet';
      case 42:
        return 'Kovan Testnet';
      case 137:
        return 'Polygon Mainnet';
      default:
        return 'Unknown Chain';
    }
  }

  String truncateString(String text, int front, int end) {
    int size = front + end;
    if (text.length > size) {
      String finalString =
          "${text.substring(0, front)}...${text.substring(text.length - end)}";
      return finalString;
    }

    return text;
  }

  void initiateListeners() {
    connector.on('connect', (session) {
      // setState(() => _session = _session);
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              HomeScreen(session: session, connector: connector)));
    });
    connector.on('session_update', (payload) {
      setState(() => _session = payload);
    });
    connector.on('disconnect', (payload) {
      setState(() => _session = null);
    });
  }

  @override
  void initState() {
    super.initState();
    initiateListeners();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: violetGradient,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: width * 0.7,
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.08,
                  vertical: height * 0.05,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white24,
                  border: Border.all(color: kLightViolet),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Connect your Ethereum Wallet to',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      'Sophon',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ElevatedButton.icon(
                        onPressed: () => loginUsingMetamask(context),
                        icon: Image.asset(
                          'assets/images/metamask-logo.png',
                          width: 16,
                        ),
                        label: const Text('Connect to MetaMask'),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(kViolet),
                          elevation: MaterialStateProperty.all(0),
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
    );
  }
}
