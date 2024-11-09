import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jellywin/repositories/user_repository.dart';

class AccountCubit extends Cubit<AccountCubitState> {
  AccountCubit(super.initialState, this._repository) {
    _repository.usersStream.listen((event) {
      emit(
        AccountCubitState(
          user: _repository.activeUser,
          users: event,
        ),
      );
    });

    _repository.activeUserStream.listen(
      (event) => emit(
        AccountCubitState(
          user: _repository.activeUser,
          users: _repository.users,
        ),
      ),
    );
  }

  final UserRepository _repository;

  Future<void> signIn({
    required Uri url,
    required String username,
    required String password,
  }) async {
    final User? result = await _repository.signIn(url, username, password);

    if (_repository.activeUser == null && result != null) {
      _repository.setActiveUser(result.id);
    }
  }

  void switchAccount(String id) {
    _repository.setActiveUser(id);
  }
}

class AccountCubitState {
  final User? user;
  final List<User> users;

  AccountCubitState({this.user, List<User>? users}) : users = users ?? [];
}
