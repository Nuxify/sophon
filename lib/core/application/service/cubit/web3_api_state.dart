part of 'web3_api_cubit.dart';

class Web3APIState {
  const Web3APIState();
}

class FetchGreetingLoading extends Web3APIState {
  FetchGreetingLoading();
}

class FetchGreetingSuccess extends Web3APIState {
  const FetchGreetingSuccess({required this.message});
  final String message;
}

class FetchGreetingFailed extends Web3APIState {
  const FetchGreetingFailed({
    required this.errorCode,
    required this.message,
  });

  final String errorCode;
  final String message;
}

class UpdateGreetingLoading extends Web3APIState {
  UpdateGreetingLoading();
}

class UpdateGreetingFailed extends Web3APIState {
  const UpdateGreetingFailed({
    required this.errorCode,
    required this.message,
  });

  final String errorCode;
  final String message;
}

class InitializeWeb3MSuccess extends Web3APIState {
  const InitializeWeb3MSuccess({required this.service});

  final W3MService service;
}

class InitializeWeb3MFailed extends Web3APIState {}

class WalletConnectionLoading extends Web3APIState {
  WalletConnectionLoading();
}

class WalletConnectionSuccess extends Web3APIState {
  const WalletConnectionSuccess();
}

class WalletConnectionFailed extends Web3APIState {
  const WalletConnectionFailed({
    required this.errorCode,
    required this.message,
  });

  final String errorCode;
  final String message;
}

class FetchHomeScreenActionButtonSuccess extends Web3APIState {
  const FetchHomeScreenActionButtonSuccess({required this.action});

  final HomeScreenActionButton action;
}
