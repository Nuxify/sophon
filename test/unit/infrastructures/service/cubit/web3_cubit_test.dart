import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sophon/infrastructures/repository/secure_storage_repository.dart';
import 'package:sophon/infrastructures/service/cubit/web3_cubit.dart';
import 'package:sophon/internal/ethereum_credentials.dart';
import 'package:sophon/internal/web3_utils.dart';
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

class MockSecureStorageRepository extends Mock
    implements SecureStorageRepository {}

void main() {
  late MockDeployedContract mockDeployedContract;
  late MockWeb3Client mockWeb3Client;
  late MockWalletConnect mockWalletConnect;
  late MockSecureStorageRepository mockSecureStorageCubit;

  const int chainId = 1;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await dotenv.load();
    mockDeployedContract = MockDeployedContract();
    mockWeb3Client = MockWeb3Client();
    mockWalletConnect = MockWalletConnect();
    mockSecureStorageCubit = MockSecureStorageRepository();

    registerFallbackValue(MockWalletConnectEthereumCredentials());
    registerFallbackValue(MockTransaction());
    registerFallbackValue(MockDeployedContract());
    registerFallbackValue(MockContractFunction());
  });

  group('Web3 cubit', () {
    test(
        'On initializeMetaMaskProvider, emits InitializeMetaMaskProviderSuccess.',
        () {
      final Web3Cubit cubit = Web3Cubit(
        greeterContract: mockDeployedContract,
        web3Client: mockWeb3Client,
        storage: mockSecureStorageCubit,
      );
      cubit.initializeMetaMaskProvider(
        connector: mockWalletConnect,
        session: SessionStatus(
          accounts: MockWalletConnect.accounts,
          chainId: chainId,
        ),
      );

      cubit.stream.listen((Web3State state) {
        expect(state.runtimeType, InitializeMetaMaskProviderSuccess);
      });
    });

    group('Update greetings via metamask.', () {
      const String updateText = 'Hello world';

      test(
          'On success, it should trigger sendTransaction, and trigger getTransactionReceipt and emits UpdateGreetingSuccess.',
          () async {
        when(
          () => mockWeb3Client.sendTransaction(
            any(),
            any(),
            chainId: any(named: 'chainId'),
            fetchChainIdFromNetworkId: any(named: 'fetchChainIdFromNetworkId'),
          ),
        ).thenAnswer((_) async {
          return '';
        });
        when(() => mockWeb3Client.getTransactionReceipt(any()))
            .thenAnswer((_) async => null);

        when(
          () => mockWeb3Client.call(
            contract: any(named: 'contract'),
            function: any(named: 'function'),
            params: any(named: 'params'),
          ),
        ).thenAnswer((_) async {
          return <String>['result response'];
        });
        final Web3Cubit cubit = Web3Cubit(
          greeterContract: await _deployedContract,
          web3Client: mockWeb3Client,
          storage: mockSecureStorageCubit,
        );

        cubit.sessionStatus = SessionStatus(accounts: <String>[], chainId: 1);
        cubit.wcCredentials = MockWalletConnectEthereumCredentials();
        cubit.sender = MockDeployedContract.sampleHexString;

        cubit.updateGreeting(
          provider: WalletProvider.metaMask,
          text: updateText,
        );

        cubit.stream.listen((Web3State state) {
          expect(state.runtimeType, UpdateGreetingSuccess);
        });

        verify(
          () => mockWeb3Client.sendTransaction(
            any(),
            any(),
            chainId: any(named: 'chainId'),
            fetchChainIdFromNetworkId: any(named: 'fetchChainIdFromNetworkId'),
          ),
        ).called(1);
      });
    });

    group('Update greetings via google/web auth.', () {
      const String updateText = 'Hello world';

      test(
          'On success, it should trigger sendTransaction, and trigger getTransactionReceipt and emits UpdateGreetingSuccess.',
          () async {
        when(() => mockWeb3Client.getChainId())
            .thenAnswer((_) async => BigInt.from(1));

        when(
          () => mockWeb3Client.sendTransaction(
            any(),
            any(),
            chainId: any(named: 'chainId'),
            fetchChainIdFromNetworkId: any(named: 'fetchChainIdFromNetworkId'),
          ),
        ).thenAnswer((_) async {
          return '';
        });
        when(() => mockWeb3Client.getTransactionReceipt(any()))
            .thenAnswer((_) async => null);

        final Web3Cubit cubit = Web3Cubit(
          greeterContract: await _deployedContract,
          web3Client: mockWeb3Client,
          storage: mockSecureStorageCubit,
        );

        cubit.privCredentials = MockWalletConnectEthereumCredentials();
        cubit.sender = MockDeployedContract.sampleHexString;

        cubit.updateGreeting(
          provider: WalletProvider.web3Auth,
          text: updateText,
        );

        await Future<void>.delayed(const Duration(seconds: 1));

        cubit.stream.listen((Web3State state) {
          expect(state.runtimeType, UpdateGreetingSuccess);
        });

        verify(
          () => mockWeb3Client.sendTransaction(
            any(),
            any(),
            chainId: any(named: 'chainId'),
          ),
        ).called(1);
      });
    });

    test(
        'On fail, it should trigger sendTransaction but throws error then it will emits UpdateGreetingFailed.',
        () async {
      const String updateText = 'Hello world';

      when(
        () => mockWeb3Client.sendTransaction(
          any(),
          any(),
          chainId: any(named: 'chainId'),
          fetchChainIdFromNetworkId: any(named: 'fetchChainIdFromNetworkId'),
        ),
      ).thenThrow('Something went wrong');

      final Web3Cubit cubit = Web3Cubit(
        greeterContract: await _deployedContract,
        web3Client: mockWeb3Client,
        storage: mockSecureStorageCubit,
      );

      cubit.sessionStatus = SessionStatus(accounts: <String>[], chainId: 1);
      cubit.wcCredentials = MockWalletConnectEthereumCredentials();
      cubit.sender = MockDeployedContract.sampleHexString;

      cubit.updateGreeting(provider: WalletProvider.metaMask, text: updateText);

      cubit.stream.listen((Web3State state) {
        expect(state.runtimeType, UpdateGreetingFailed);
      });

      verify(
        () => mockWeb3Client.sendTransaction(
          any(),
          any(),
          chainId: any(named: 'chainId'),
          fetchChainIdFromNetworkId: any(named: 'fetchChainIdFromNetworkId'),
        ),
      ).called(1);
    });

    group('Fetch greetings.', () {
      test(
          'On success. It should trigger call function from web3client and emits FetchGreetingSuccess.',
          () async {
        when(
          () => mockWeb3Client.call(
            contract: any(named: 'contract'),
            function: any(named: 'function'),
            params: any(named: 'params'),
          ),
        ).thenAnswer((_) async {
          return <String>['result response'];
        });
        final Web3Cubit cubit = Web3Cubit(
          greeterContract: await _deployedContract,
          web3Client: mockWeb3Client,
          storage: mockSecureStorageCubit,
        );

        cubit.fetchGreeting();

        cubit.stream.listen((Web3State state) {
          expect(state.runtimeType, FetchGreetingSuccess);
        });
        verify(
          () => mockWeb3Client.call(
            contract: any(named: 'contract'),
            function: any(named: 'function'),
            params: any(named: 'params'),
          ),
        ).called(1);
      });

      test(
          'On fail. It should trigger call function from web3client and emits FetchGreetingFailed.',
          () async {
        when(
          () => mockWeb3Client.call(
            contract: any(named: 'contract'),
            function: any(named: 'function'),
            params: any(named: 'params'),
          ),
        ).thenThrow('Something went wrong.');

        final Web3Cubit cubit = Web3Cubit(
          greeterContract: await _deployedContract,
          web3Client: mockWeb3Client,
          storage: mockSecureStorageCubit,
        );

        cubit.fetchGreeting();

        cubit.stream.listen((Web3State state) {
          expect(state.runtimeType, FetchGreetingFailed);
        });
        verify(
          () => mockWeb3Client.call(
            contract: any(named: 'contract'),
            function: any(named: 'function'),
            params: any(named: 'params'),
          ),
        ).called(1);
      });
    });
  });
}

/// Load ABI to map setGreeting function params.
Future<DeployedContract> get _deployedContract async {
  const String abiDirectory = 'lib/contracts/staging/greeter.abi.json';

  final String contractAddress = dotenv.get('GREETER_CONTRACT_ADDRESS');

  final String contractABI = await rootBundle.loadString(abiDirectory);

  final DeployedContract contract = DeployedContract(
    ContractAbi.fromJson(contractABI, 'Greeter'),
    EthereumAddress.fromHex(contractAddress),
  );
  return contract;
}
