import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sophon/domain/repository/secure_storage_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this.storage,
  }) : super(const AuthState());
  final ISecureStorageRepository storage;
}
