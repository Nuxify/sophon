import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sophon/infrastructures/repository/interfaces/secure_storage_repository.dart';
import 'package:sophon/internal/local_storage.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3auth_flutter/enums.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/output.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.storage, required this.connector})
      : super(const AuthState());
  final ISecureStorageRepository storage;
  final WalletConnect connector;
  // ignore: unused_field
  dynamic _session;
  String walletConnectURI = '';

  void initializeWalletConnectListeners() {
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

    connector.on('connect', (Object? session) async {
      emit(EstablishConnectionSuccess(
          session: session, connector: connector, uri: walletConnectURI));
    });
    connector.on('session_update', (Object? session) {
      _session = session;
    });
    connector.on('disconnect', (_) async {
      emit(SessionDisconnected());
    });
  }

  Future<void> initializeWeb3Auth() async {
    try {
      Uri redirectUrl;
      if (Platform.isAndroid) {
        redirectUrl = Uri.parse(
            '${dotenv.get('WEB3AUTH_APP_URL_SCHEME')}://${dotenv.get('WEB3AUTH_APP_BUNDLE_ID')}/auth');
      } else if (Platform.isIOS) {
        redirectUrl =
            Uri.parse('${dotenv.get('WEB3AUTH_APP_BUNDLE_ID')}://openlogin');
      } else {
        throw UnKnownException('Unknown platform');
      }
      await Web3AuthFlutter.init(
        Web3AuthOptions(
          clientId: dotenv.get('WEB3AUTH_CLIENT_ID'),
          network: Network.testnet,
          redirectUrl: redirectUrl,
        ),
      );
      emit(InitializeWeb3AuthSuccess());
    } catch (e) {
      emit(InitializeWeb3AuthFailed(errorCode: '', message: e.toString()));
    }
  }

  Future<void> loginWithMetamask() async {
    if (!connector.bridgeConnected) {
      connector.reconnect();
    }
    if (!connector.connected) {
      try {
        SessionStatus session =
            await connector.createSession(onDisplayUri: (String uri) async {
          walletConnectURI = uri;
          emit(LoginWithMetamaskSuccess(url: uri));
        });
        _session = session;
      } catch (e) {
        emit(LoginWithMetamaskFailed(errorCode: '', message: e.toString()));
      }
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      final Web3AuthResponse response = await Web3AuthFlutter.login(
        LoginParams(
          loginProvider: Provider.google,
          mfaLevel: MFALevel.OPTIONAL,
        ),
      );
      // store private key on device only
      storage.write(
        key: lsPrivateKey,
        value: response.privKey ?? '',
      );
      emit(LoginWithWeb3AuthSuccess());
    } catch (e) {
      emit(const LoginWithWeb3AuthFailed(message: '', errorCode: ''));
    }
  }
}
