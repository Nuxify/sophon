part of 'greeting_cubit.dart';

class GreetingState {
  const GreetingState();
}

class FetchGreetingLoading extends GreetingState {
  FetchGreetingLoading();
}

class FetchGreetingSuccess extends GreetingState {
  const FetchGreetingSuccess({required this.message});
  final String message;
}

class FetchGreetingFailed extends GreetingState {
  const FetchGreetingFailed({
    required this.errorCode,
    required this.message,
  });

  final String errorCode;
  final String message;
}

class UpdateGreetingLoading extends GreetingState {
  UpdateGreetingLoading();
}

class UpdateGreetingSuccess extends GreetingState {
  const UpdateGreetingSuccess();
}

class UpdateGreetingFailed extends GreetingState {
  const UpdateGreetingFailed({
    required this.errorCode,
    required this.message,
  });

  final String errorCode;
  final String message;
}

class SessionTerminated extends GreetingState {
  SessionTerminated();
}

class InitializeProviderLoading extends GreetingState {
  InitializeProviderLoading();
}

class InitializeProviderSuccess extends GreetingState {
  const InitializeProviderSuccess({
    required this.accountAddress,
    required this.networkName,
  });

  final String accountAddress;
  final String networkName;
}

class InitializeProviderFailed extends GreetingState {
  const InitializeProviderFailed({
    required this.errorCode,
    required this.message,
  });

  final String errorCode;
  final String message;
}
