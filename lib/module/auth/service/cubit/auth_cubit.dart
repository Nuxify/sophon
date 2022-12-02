import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sophon/infrastructures/repository/interfaces/secure_storage_repository.dart';
import 'package:sophon/utils/wallet_status_storage.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.storage}) : super(const AuthState());
  final ISecureStorageRepository storage;
  // ignore: unused_field
  dynamic _session;
  String walletConnectURI = '';
  String _provider = '';

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
    connector.on('connect', (session) async {
      /// Save connected to reuse after closing the app.
      await storage.write(key: 'provider', value: _provider);
      await storage.write(key: 'status', value: connected);

      emit(EstablishConnectionSuccess(
          session: session, connector: connector, uri: walletConnectURI));
    });
    connector.on('session_update', (session) {
      _session = session;
    });
    connector.on('disconnect', (_) async {
      /// Clear provider and set the status to disconnect.
      await storage.write(key: 'provider', value: '');
      await storage.write(key: 'status', value: disconnected);

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
        _provider = metamask;
      } catch (e) {
        emit(LoginWithMetamaskFailed(errorCode: '', message: e.toString()));
      }
    }
  }
}
