import 'package:equatable/equatable.dart';
import 'package:fluent_ui/fluent_ui.dart';

class UserRepository extends ChangeNotifier {
  List<User> users = [];

  void addUser(User user) {
    users = users.toList()..add(user);

    notifyListeners();
  }

  void removeUser(User user) {
    users = users.toList()..remove(user);

    notifyListeners();
  }
}

@immutable
class User extends Equatable {
  final String name;
  final String token;
  final String id;

  User({required this.name, required this.token, required this.id});

  @override
  List<Object?> get props => [name, token, id];
}
