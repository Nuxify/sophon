import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sophon/core/domain/repository/secure_storage_repository.dart';

class SecureStorageRepository implements ISecureStorageRepository {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  Future<void> write({required String key, required String? value}) async =>
      _storage.write(
        key: key,
        value: value,
      );

  @override
  Future<String?> read({required String key}) async => _storage.read(key: key);

  @override
  Future<void> delete({required String key}) async => _storage.delete(key: key);

  @override
  Future<void> clear() async => _storage.deleteAll();
}
