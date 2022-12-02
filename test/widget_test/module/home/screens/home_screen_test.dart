import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sophon/module/home/interfaces/screens/home_screen.dart';
import 'package:sophon/module/home/service/cubit/greeting_cubit.dart';
import 'package:sophon/utils/web3_utils.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

class MockGreetingCubit extends MockCubit<GreetingState>
    implements GreetingCubit {}

class MockWalletConnect extends Mock implements WalletConnect {}

void main() {
  late MockGreetingCubit mockGreetingCubit;
  late MockWalletConnect mockWalletConnect;

  setUp(() {
    mockGreetingCubit = MockGreetingCubit();
    mockWalletConnect = MockWalletConnect();
  });

  Future<void> pumpWidget(WidgetTester tester) async => tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<GreetingCubit>(
            create: (BuildContext context) => mockGreetingCubit,
            child: HomeScreen(
              connector: mockWalletConnect,
              session: SessionStatus(
                accounts: [],
                chainId: 1,
              ),
              uri: '',
            ),
          ),
        ),
      );
  group('Home Screen.', () {
    group('Header Content.', () {
      const String accountAddress = 'xxxxxxxxxx';
      const int chainId = 5;
      testWidgets('Account address should be visible.',
          (WidgetTester tester) async {
        when(() => mockGreetingCubit.state).thenReturn(const GreetingState());
        whenListen(
          mockGreetingCubit,
          Stream<GreetingState>.fromIterable(
            <GreetingState>[
              InitializeProviderSuccess(
                accountAddress: accountAddress,
                networkName: getNetworkName(chainId),
              )
            ],
          ),
        );
        await pumpWidget(tester);
        await tester.pump();

        expect(find.textContaining('Account Address'), findsOneWidget);
        expect(find.textContaining(accountAddress), findsOneWidget);
      });
      testWidgets('Network name of chain ID should be visible.',
          (WidgetTester tester) async {
        when(() => mockGreetingCubit.state).thenReturn(const GreetingState());
        final String networkName = getNetworkName(chainId);
        whenListen(
          mockGreetingCubit,
          Stream<GreetingState>.fromIterable(
            <GreetingState>[
              InitializeProviderSuccess(
                accountAddress: accountAddress,
                networkName: networkName,
              )
            ],
          ),
        );
        await pumpWidget(tester);
        await tester.pump();

        expect(find.textContaining('Chain'), findsOneWidget);
        expect(find.textContaining(networkName), findsOneWidget);
      });
    });
    group('Body Content.', () {
      testWidgets(
          'Greetings Content on loading should show linear progress indicator.',
          (WidgetTester tester) async {
        when(() => mockGreetingCubit.state).thenReturn(const GreetingState());

        whenListen(
          mockGreetingCubit,
          Stream<GreetingState>.fromIterable(
            <GreetingState>[
              FetchGreetingLoading(),
            ],
          ),
        );
        await pumpWidget(tester);
        await tester.pump();

        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      });
      testWidgets(
          'Greetings Content on success should show the greetings message.',
          (WidgetTester tester) async {
        const String message = 'Hello this is the updated greetings';

        when(() => mockGreetingCubit.state).thenReturn(const GreetingState());

        whenListen(
          mockGreetingCubit,
          Stream<GreetingState>.fromIterable(
            <GreetingState>[
              const FetchGreetingSuccess(message: message),
            ],
          ),
        );
        await pumpWidget(tester);
        await tester.pump();

        expect(find.textContaining(message), findsOneWidget);
      });

      group('Update section.', () {
        testWidgets(
            'Update text field should be visible and also the button update greetings',
            (WidgetTester tester) async {
          when(() => mockGreetingCubit.state).thenReturn(const GreetingState());

          await pumpWidget(tester);
          await tester.pump();

          expect(find.byType(TextField), findsOneWidget);

          /// Update button find using by icon
          expect(find.byIcon(Icons.edit), findsOneWidget);
        });
        testWidgets(
            'On click edit button should trigger updateGreeting function inside cubit.',
            (WidgetTester tester) async {
          when(() => mockGreetingCubit.state).thenReturn(const GreetingState());
          when(() => mockGreetingCubit.updateGreeting(any()))
              .thenAnswer((_) async {});

          await pumpWidget(tester);
          await tester.pump();

          /// Update button find using by icon
          final Finder updateBtn = find.byIcon(Icons.edit);
          expect(updateBtn, findsOneWidget);

          await tester.tap(updateBtn);
          await tester.pump();

          verify(
            () => mockGreetingCubit.updateGreeting(any()),
          ).called(1);
        });

        testWidgets('On fail update it should show snackbar and related error.',
            (WidgetTester tester) async {
          when(() => mockGreetingCubit.state).thenReturn(const GreetingState());
          when(() => mockGreetingCubit.updateGreeting(any()))
              .thenAnswer((_) async {});
          const String errorCode = '404';
          const String errorMessage = 'Something went wrong';
          whenListen(
            mockGreetingCubit,
            Stream<GreetingState>.fromIterable(
              <GreetingState>[
                const FetchGreetingFailed(
                    errorCode: errorCode, message: errorMessage),
              ],
            ),
          );

          await pumpWidget(tester);
          await tester.pump();

          expect(
            find.ancestor(
                matching: find.byType(SnackBar), of: find.text(errorMessage)),
            findsOneWidget,
          );
        });
      });

      testWidgets(
          'On click disconnect button should trigger closeConnection function.',
          (WidgetTester tester) async {
        when(() => mockGreetingCubit.state).thenReturn(const GreetingState());
        when(() => mockGreetingCubit.closeConnection())
            .thenAnswer((_) async {});

        await pumpWidget(tester);
        await tester.pump();

        /// Update button find using by icon
        final Finder disconnectBtn = find.byIcon(Icons.power_settings_new);
        expect(disconnectBtn, findsOneWidget);

        await tester.tap(disconnectBtn);
        await tester.pump();

        verify(
          () => mockGreetingCubit.closeConnection(),
        ).called(1);
      });
    });
  });
}
