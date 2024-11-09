import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:jellywin/jellyfin_service.dart';

class UserRepository {
  List<User> users = [];
  String? activeUserId;
  User? activeUser;

  final _usersStreamController = StreamController<List<User>>.broadcast();
  final _activeUsersStreamController = StreamController<User?>.broadcast();

  Stream<List<User>> get usersStream => _usersStreamController.stream;
  Stream<User?> get activeUserStream => _activeUsersStreamController.stream;

  void addUser(User user) {
    users.add(user);
    _usersStreamController.add(users);
  }

  void removeUser(User user) {
    users.remove(user);
    _usersStreamController.add(users);
  }

  void setActiveUser(String id){
    final user = users.where((element) => element.id == id).firstOrNull;
    if (user == null) {
      log('Failed to set active user, id $id was not found');
    }

    activeUserId = id;
    activeUser = user;
    _activeUsersStreamController.add(user);
  }

  Future<User?> signIn(Uri url, String username, String password) async {
    final user = await JellyfinService.signInByNamePassword(url, username, password);

    if (user != null) {
      addUser(user);
    }

    return user;
  }
}

@immutable
class User extends Equatable {
  final Uri serverUri;
  final String name;
  final String token;
  final String id;

  const User( {required this.serverUri,required this.name, required this.token, required this.id});

  @override
  List<Object?> get props => [serverUri, name, token, id];
}
