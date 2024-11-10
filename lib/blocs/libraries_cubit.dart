import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jellywin/jellyfin_service.dart';
import 'package:jellywin/repositories/user_repository.dart';

import '../api/jellyfin_openapi_stable.swagger.dart';

typedef LibraryCubitState = List<BaseItemDto>;

class LibrariesCubit extends Cubit<LibraryCubitState> {
  LibrariesCubit(this.userRepository) : super([]) {
    userRepository.activeUserStream.listen(loadLibraries);
  }

  final UserRepository userRepository;

  Future<void> loadLibraries(User? user) async {
    if (user == null) {
      emit([]);
      return;
    }

    final libraries = await JellyfinService.loadAvailableLibraries(user);

    emit(
      libraries
              ?.map(
                (e) => e,
              )
              .toList() ??
          [],
    );
  }
}
