part of 'web3_cubit.dart';

class Web3State {
  const Web3State();
}

class FetchGreetingLoading extends Web3State {
  FetchGreetingLoading();
}

class FetchGreetingSuccess extends Web3State {
  const FetchGreetingSuccess({required this.message});
  final String message;
}

class FetchGreetingFailed extends Web3State {
  const FetchGreetingFailed({
    required this.errorCode,
    required this.message,
  });

  final String errorCode;
  final String message;
}

class UpdateGreetingLoading extends Web3State {
  UpdateGreetingLoading();
}

class UpdateGreetingFailed extends Web3State {
  const UpdateGreetingFailed({
    required this.errorCode,
    required this.message,
  });

  final String errorCode;
  final String message;
}

class InitializeWeb3MSuccess extends Web3State {
  const InitializeWeb3MSuccess({required this.service});

  final W3MService service;
}

class InitializeWeb3MFailed extends Web3State {}

class WalletConnectionLoading extends Web3State {
  WalletConnectionLoading();
}

class WalletConnectionSuccess extends Web3State {
  const WalletConnectionSuccess();
}

class WalletConnectionFailed extends Web3State {
  const WalletConnectionFailed({
    required this.errorCode,
    required this.message,
  });

  final String errorCode;
  final String message;
}

class FetchHomeScreenActionButtonSuccess extends Web3State {
  const FetchHomeScreenActionButtonSuccess({required this.action});

  final HomeScreenActionButton action;
}
