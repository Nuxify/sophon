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

class Web3MInitialized extends Web3State {
  const Web3MInitialized({required this.service});

  final W3MService service;
}

class Web3MFailed extends Web3State {}
