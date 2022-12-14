import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sophon/internal/ethereum_credentials.dart';
import 'package:sophon/module/home/service/cubit/greeting_cubit.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';

class MockDeployedContract extends Mock implements DeployedContract {
  static String sampleHexString = '0x34fcc3f5423ee26d0fc23224337ba228142fa4fd';
  @override
  final EthereumAddress address = EthereumAddress.fromHex(sampleHexString);
}

class MockWeb3Client extends Mock implements Web3Client {}

class MockWalletConnect extends Mock implements WalletConnect {
  static List<String> accounts = <String>[MockDeployedContract.sampleHexString];

  @override
  final WalletConnectSession session = WalletConnectSession(accounts: accounts);
}

class MockWalletConnectEthereumCredentials extends Mock
    implements WalletConnectEthereumCredentials {}

class MockTransaction extends Mock implements Transaction {}

class MockContractFunction extends Mock implements ContractFunction {}

void main() {
  late MockDeployedContract mockDeployedContract;
  late MockWeb3Client mockWeb3Client;
  late MockWalletConnect mockWalletConnect;

  const int chainId = 1;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await dotenv.load();
    mockDeployedContract = MockDeployedContract();
    mockWeb3Client = MockWeb3Client();
    mockWalletConnect = MockWalletConnect();

    registerFallbackValue(MockWalletConnectEthereumCredentials());
    registerFallbackValue(MockTransaction());
    registerFallbackValue(MockDeployedContract());
    registerFallbackValue(MockContractFunction());
  });
  group('Greetings cubit.', () {
    test(
        'On initializeProvider, it should trigger deployed contract function once and emits InitializeProviderSuccess.',
        () {
      when(() => mockDeployedContract.function(any()))
          .thenReturn(const ContractFunction(
        '',
        <FunctionParameter<dynamic>>[],
      ));

      final GreetingCubit cubit = GreetingCubit(
        contract: mockDeployedContract,
        web3Client: mockWeb3Client,
      );
      cubit.initializeProvider(
        session: SessionStatus(
            accounts: MockWalletConnect.accounts, chainId: chainId),
        connector: mockWalletConnect,
      );

      cubit.stream.listen((GreetingState state) {
        expect(state.runtimeType, InitializeProviderSuccess);
      });

      verify(() => mockDeployedContract.function(any())).called(1);
    });

    group('Update greetings.', () {
      const String updateText = 'Hello world';

      test(
          'On success, it should trigqger sendTransaction and emits UpdateGreetingSuccess.',
          () async {
        /// Use local abi to map the parametrs of
        final DeployedContract contract = await _deployedContract;

        when(() => mockWeb3Client.sendTransaction(any(), any(),
            chainId: any(named: 'chainId'),
            fetchChainIdFromNetworkId:
                any(named: 'fetchChainIdFromNetworkId'))).thenAnswer((_) async {
          return '';
        });

        final GreetingCubit cubit = GreetingCubit(
          contract: mockDeployedContract,
          web3Client: mockWeb3Client,
        );

        cubit.wcCreds = MockWalletConnectEthereumCredentials();
        cubit.setGreetingFunction = contract.function('setGreeting');

        cubit.sender = MockDeployedContract.sampleHexString;

        cubit.updateGreeting(updateText);

        cubit.stream.listen((GreetingState state) {
          expect(state.runtimeType, UpdateGreetingSuccess);
        });

        verify(() => mockWeb3Client.sendTransaction(any(), any(),
            chainId: any(named: 'chainId'),
            fetchChainIdFromNetworkId:
                any(named: 'fetchChainIdFromNetworkId'))).called(1);
      });
    });

    test(
        'On fail, it should trigger sendTransaction but throws error then it will emits UpdateGreetingFailed.',
        () async {
      /// Use local abi to map the parametrs of
      final DeployedContract contract = await _deployedContract;

      const String updateText = 'Hello world';

      when(() => mockWeb3Client.sendTransaction(any(), any(),
              chainId: any(named: 'chainId'),
              fetchChainIdFromNetworkId:
                  any(named: 'fetchChainIdFromNetworkId')))
          .thenThrow('Something went wrong');

      final GreetingCubit cubit = GreetingCubit(
        contract: mockDeployedContract,
        web3Client: mockWeb3Client,
      );

      cubit.wcCreds = MockWalletConnectEthereumCredentials();
      cubit.setGreetingFunction = contract.function('setGreeting');

      cubit.sender = MockDeployedContract.sampleHexString;

      cubit.updateGreeting(updateText);

      cubit.stream.listen((GreetingState state) {
        expect(state.runtimeType, UpdateGreetingFailed);
      });

      verify(() => mockWeb3Client.sendTransaction(any(), any(),
          chainId: any(named: 'chainId'),
          fetchChainIdFromNetworkId:
              any(named: 'fetchChainIdFromNetworkId'))).called(1);
    });

    group('Fetch greetings.', () {
      test(
          'On success. It should trigger call function from web3client and emits FetchGreetingSuccess.',
          () async {
        when(() => mockWeb3Client.call(
            contract: any(named: 'contract'),
            function: any(named: 'function'),
            params: any(named: 'params'))).thenAnswer((_) async {
          return <String>['result response'];
        });
        final GreetingCubit cubit = GreetingCubit(
          contract: await _deployedContract,
          web3Client: mockWeb3Client,
        );

        cubit.fetchGreeting();

        cubit.stream.listen((GreetingState state) {
          expect(state.runtimeType, FetchGreetingSuccess);
        });
        verify(() => mockWeb3Client.call(
            contract: any(named: 'contract'),
            function: any(named: 'function'),
            params: any(named: 'params'))).called(1);
      });

      test(
          'On fail. It should trigger call function from web3client and emits FetchGreetingFailed.',
          () async {
        when(() => mockWeb3Client.call(
            contract: any(named: 'contract'),
            function: any(named: 'function'),
            params: any(named: 'params'))).thenThrow('Something went wrong.');

        final GreetingCubit cubit = GreetingCubit(
          contract: await _deployedContract,
          web3Client: mockWeb3Client,
        );

        cubit.fetchGreeting();

        cubit.stream.listen((GreetingState state) {
          expect(state.runtimeType, FetchGreetingFailed);
        });
        verify(() => mockWeb3Client.call(
            contract: any(named: 'contract'),
            function: any(named: 'function'),
            params: any(named: 'params'))).called(1);
      });
    });
  });
}

/// Load ABI to map setGreeting function params.
Future<DeployedContract> get _deployedContract async {
  const String abiDirectory = 'lib/contracts/staging/greeter.abi.json';

  final String contractAddress = dotenv.get('GREETER_CONTRACT_ADDRESS');

  String contractABI = await rootBundle.loadString(abiDirectory);

  final DeployedContract contract = DeployedContract(
    ContractAbi.fromJson(contractABI, 'Greeter'),
    EthereumAddress.fromHex(contractAddress),
  );
  return contract;
}
