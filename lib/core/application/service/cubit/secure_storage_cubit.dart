import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sophon/core/domain/repository/secure_storage_repository.dart';

class SecureStorageCubit extends Cubit<void> {
  SecureStorageCubit({required this.storage}) : super(null);
  final ISecureStorageRepository storage;

  Future<String?> read({required String key}) => storage.read(key: key);

  Future<void> write({required String key, required String value}) =>
      storage.write(key: key, value: value);

  Future<void> delete({required String key}) => storage.delete(key: key);

  Future<void> clear() => storage.clear();
}
