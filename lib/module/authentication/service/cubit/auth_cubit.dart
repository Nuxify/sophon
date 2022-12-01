import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState());

  // ignore: unused_field
  dynamic _session;
  String walletConnectURI = '';

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

  void initiateListeners() {
    connector.on('connect', (session) {
      emit(EstablishConnectionSuccess(
          session: session, connector: connector, uri: walletConnectURI));
    });
    connector.on('session_update', (session) {
      _session = session;
    });
    connector.on('disconnect', (_) {
      emit(SessionDisconnected());
    });
  }

  Future<void> loginWithMetamask() async {
    if (!connector.bridgeConnected) {
      connector.reconnect();
    }
    if (!connector.connected) {
      try {
        SessionStatus session =
            await connector.createSession(onDisplayUri: (uri) async {
          walletConnectURI = uri;
          emit(LoginWithMetamaskSuccess(url: uri));
        });
        _session = session;
      } catch (e) {
        emit(LoginWithMetamaskFailed(errorCode: '', message: e.toString()));
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
}
