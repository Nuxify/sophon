import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sophon/infrastructures/repository/interfaces/secure_storage_repository.dart';
import 'package:sophon/utils/wallet_status_storage.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.storage, required this.connector})
      : super(const AuthState());
  final ISecureStorageRepository storage;
  final WalletConnect connector;
  // ignore: unused_field
  dynamic _session;
  String walletConnectURI = '';
  String _provider = '';

  void initiateListeners() {
    if (connector.connected) {
      emit(
        EstablishConnectionSuccess(
          session: SessionStatus(
              accounts: connector.session.accounts,
              chainId: connector.session.chainId),
          connector: connector,
          uri: connector.session.toUri(),
        ),
      );
      return;
    }
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
