import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sophon/infrastructures/service/cubit/secure_storage_cubit.dart';
import 'package:sophon/module/auth/interfaces/screens/authentication_screen.dart';
import 'package:sophon/module/auth/service/cubit/auth_cubit.dart';
import 'package:sophon/test/main_test.dart';
import 'package:sophon/utils/wallet_status_storage.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockSecureStorageCubit extends MockCubit implements SecureStorageCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;
  late MockSecureStorageCubit mockSecureStorageCubit;

  final List<String> connectWalletOptions = <String>['Login with Metamask'];

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    mockSecureStorageCubit = MockSecureStorageCubit();
  });
  Future<void> pumpWidget(WidgetTester tester) async => tester.pumpWidget(
        universalPumper(MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>(
              create: (BuildContext context) => mockAuthCubit,
            ),
            BlocProvider<SecureStorageCubit>(
              create: (BuildContext context) => mockSecureStorageCubit,
            ),
          ],
          child: const Scaffold(
            body: AuthenticationScreen(),
          ),
        )),
      );
  void listenStub() {
    when(() => mockAuthCubit.state).thenReturn(const AuthState());
    when(() => mockSecureStorageCubit.read(key: any(named: 'key')))
        .thenAnswer((_) async => '');
  }

  group('Authentication screen.', () {
    testWidgets(
        'On openning screen, there should be CircularProgressIndicator to check if there was a previous connection store in secure storage.',
        (WidgetTester tester) async {
      listenStub();

      await pumpWidget(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    group('If there is a previous connection', () {
      const String provider1 = 'metamask';
      testWidgets(
          'and the provider is Metamask, trigger function loginWithMetamask directly and verify if it is called once.',
          (WidgetTester tester) async {
        bool isTriggerLoginWithMetamask = false;

        when(() => mockAuthCubit.state).thenReturn(const AuthState());

        when(() => mockSecureStorageCubit.read(key: providerKey))
            .thenAnswer((_) async => provider1);

        when(() => mockSecureStorageCubit.read(key: statusKey))
            .thenAnswer((_) async => connected);

        when(() => mockAuthCubit.loginWithMetamask())
            .thenAnswer((_) async => isTriggerLoginWithMetamask = true);

        await pumpWidget(tester);
        await tester.pump();

        expect(isTriggerLoginWithMetamask, isTrue);

        verify(() => mockAuthCubit.loginWithMetamask()).called(1);
      });
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
