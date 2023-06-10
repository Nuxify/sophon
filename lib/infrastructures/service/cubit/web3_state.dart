part of 'web3_cubit.dart';

class Web3State {
  const Web3State();
}

/// Event classes

class InitializeMetaMaskProviderLoading extends Web3State {
  InitializeMetaMaskProviderLoading();
}

class InitializeMetaMaskProviderSuccess extends Web3State {
  const InitializeMetaMaskProviderSuccess({
    required this.accountAddress,
    required this.networkName,
  });

  final String accountAddress;
  final String networkName;
}

class InitializeMetaMaskProviderFailed extends Web3State {
  const InitializeMetaMaskProviderFailed({
    required this.errorCode,
    required this.message,
  });

  final String errorCode;
  final String message;
}

class SessionTerminated extends Web3State {
  SessionTerminated();
}

class InitializeWeb3AuthProviderLoading extends Web3State {}

class InitializeWeb3AuthProviderSuccess extends Web3State {
  const InitializeWeb3AuthProviderSuccess({
    required this.accountAddress,
    required this.networkName,
  });

  final String accountAddress;
  final String networkName;
}

class InitializeWeb3AuthProviderFailed extends Web3State {
  const InitializeWeb3AuthProviderFailed({
    required this.errorCode,
    required this.message,
  });

  final String errorCode;
  final String message;
}

/// Greeter contract
/// Contains Greeter contract related events

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

class UpdateGreetingSuccess extends Web3State {
  const UpdateGreetingSuccess();
}

class UpdateGreetingFailed extends Web3State {
  const UpdateGreetingFailed({
    required this.errorCode,
    required this.message,
  });

  final String errorCode;
  final String message;
}

/// TODO: <another> contract
/// You can add and specify more contracts here