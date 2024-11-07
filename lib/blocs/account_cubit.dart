import 'dart:async';
import 'dart:io';

import 'package:chopper/chopper.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jellywin/api/jellyfin_openapi_stable.swagger.dart';
import 'package:jellywin/repositories/user_repository.dart';

class AccountCubit extends Cubit<AccountCubitState> {
  AccountCubit(super.initialState, this._repository) {
    _repository.addListener(() => onUserRepositoryUpdate(_repository.users));
  }

  void onUserRepositoryUpdate(List<User> data) {}

  final UserRepository _repository;
  JellyfinOpenapiStable? api;

  Future<void> signIn({
    required Uri url,
    required String username,
    required String password,
  }) async {
    final authHeaders = await buildAuthHeader();

    api = JellyfinOpenapiStable.create(
      baseUrl: url,
      interceptors: [
        HeadersInterceptor({'Authorization': authHeaders}),
      ],
    );

    final result = await api!.usersAuthenticateByNamePost(
      body: AuthenticateUserByName(username: username, pw: password),
    );

    if (result.isSuccessful) {
    } else {
      emit(AccountCubitState(lastMessage: result.error.toString()));
    }
  }

  Future<String> me() async {
    final me = await api!.usersMeGet();
    return me.bodyString;
  }

  Future<String> buildAuthHeader() async {
    var authHeader = 'MediaBrowser ';
    if (state.userId != null) {
      authHeader += 'UserId="${state.userId?.id}", ';
    }
    if (state.sessionToken != null) {
      authHeader += 'Token="${state.sessionToken}", ';
    }

    authHeader += 'Client="Jellywin", ';
    var deviceInfo = DeviceInfoPlugin();
    var windowsDeviceInfo = await deviceInfo.windowsInfo;
    var deviceName = (windowsDeviceInfo).computerName;
    var deviceId = (windowsDeviceInfo).deviceId;

    authHeader += 'Device="$deviceName", DeviceId="$deviceId", ';

    var version = 'dev';
    authHeader += 'Version="$version"';
    return authHeader;
  }
}

class AccountCubitState {
  final String lastMessage;
  final String? sessionToken;
  final UserDto? userId;

  AccountCubitState({String? lastMessage, this.userId, this.sessionToken})
      : lastMessage = lastMessage ?? '';
}

class AuthHeaderInterceptor extends HeadersInterceptor {
  const AuthHeaderInterceptor(super.headers);
}
