import 'dart:developer';

import 'package:jellywin/jellyfin_service.dart';
import 'package:jellywin/repositories/user_repository.dart';

import '../api/jellyfin_openapi_stable.swagger.dart';

class SeriesRepository{
  final UserRepository userRepository;

  SeriesRepository({required this.userRepository});

  Future<BaseItemDtoQueryResult?> loadInfo(String id) async {
    final user = userRepository.activeUser;
    if (user == null) {
      log('Tried to load series without user');
      return null;
    }

    final info = await JellyfinService.loadSeriesInfo(user, id);
    if (info == null) {
      return null;
    }

    return info;
  }
}