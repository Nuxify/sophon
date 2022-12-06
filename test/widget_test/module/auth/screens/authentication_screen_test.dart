import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sophon/infrastructures/service/cubit/secure_storage_cubit.dart';
import 'package:sophon/module/auth/interfaces/screens/authentication_screen.dart';
import 'package:sophon/module/auth/service/cubit/auth_cubit.dart';
import 'package:sophon/module/home/service/cubit/greeting_cubit.dart';
import 'package:sophon/test/main_test.dart';
import 'package:sophon/test/observer_tester.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockSecureStorageCubit extends MockCubit implements SecureStorageCubit {}

class MockWalletConnect extends Mock implements WalletConnect {
  @override
  bool get connected => true;
}

class MockGreetingCubit extends MockCubit<GreetingState>
    implements GreetingCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;
  late MockSecureStorageCubit mockSecureStorageCubit;
  late MockGreetingCubit mockGreetingCubit;

  final List<String> connectWalletOptions = <String>['Login with Metamask'];

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    mockSecureStorageCubit = MockSecureStorageCubit();
    mockGreetingCubit = MockGreetingCubit();
  });
  Future<void> pumpWidget(
    WidgetTester tester, {
    NavigatorObserver? observer,
  }) async =>
      tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>(
              create: (BuildContext context) => mockAuthCubit,
            ),
            BlocProvider<SecureStorageCubit>(
              create: (BuildContext context) => mockSecureStorageCubit,
            ),
            BlocProvider<GreetingCubit>(
              create: (BuildContext context) => mockGreetingCubit,
            ),
          ],
          child: universalPumper(
            const AuthenticationScreen(),
            observer: observer,
          ),
        ),
      );
  void listenStub() {
    when(() => mockAuthCubit.state).thenReturn(const AuthState());
    when(() => mockSecureStorageCubit.read(key: any(named: 'key')))
        .thenAnswer((_) async => '');
  }

  group('Authentication screen.', () {
    testWidgets(
        'If there is a previous connection it should navigate directly to home screen.',
        (WidgetTester tester) async {
      bool isNavigatedToHomeScreen = false;

      final TestObserver observer = TestObserver()
        ..onReplaced = (Route<dynamic>? route, Route<dynamic>? previousRoute) =>
            isNavigatedToHomeScreen = true;
      when(() => mockGreetingCubit.state).thenReturn(const GreetingState());

      whenListen(
        mockAuthCubit,
        Stream.fromIterable([
          EstablishConnectionSuccess(
            connector: MockWalletConnect(),
            session: SessionStatus(
              chainId: 1,
              accounts: [],
            ),
            uri: '',
          ),
        ]),
        initialState: const AuthState(),
      );

      await pumpWidget(
        tester,
        observer: observer,
      );
      await tester.pump();

      expect(isNavigatedToHomeScreen, isTrue);
    });

    testWidgets(
        'If there is no previous connection, there should be a login selection.',
        (WidgetTester tester) async {
      listenStub();

      await pumpWidget(tester);
      await tester.pumpAndSettle();

      for (String option in connectWalletOptions) {
        expect(find.text(option), findsOneWidget);
      }
    });
    testWidgets('Connect options should be clickable.',
        (WidgetTester tester) async {
      bool isTriggerLoginWithMetamask = false;
      listenStub();

      when(() => mockAuthCubit.loginWithMetamask())
          .thenAnswer((_) async => isTriggerLoginWithMetamask = true);

      await pumpWidget(tester);
      await tester.pumpAndSettle();

      for (String option in connectWalletOptions) {
        await tester.tap(find.text(option));
        await tester.pump();

        expect(isTriggerLoginWithMetamask, isTrue);
        verify(() => mockAuthCubit.loginWithMetamask()).called(1);
      }
    });
  });
}
