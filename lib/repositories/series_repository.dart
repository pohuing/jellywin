import 'dart:developer';

import 'package:jellywin/jellyfin_service.dart';
import 'package:jellywin/repositories/user_repository.dart';

import '../api/jellyfin_openapi_stable.swagger.dart';

class SeriesRepository {
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

  Future<BaseItemDtoQueryResult?> loadNextUp(String seriesId) async {
    final user = userRepository.activeUser;
    if (user == null) {
      log('Tried to load series without user');
      return null;
    }

    final nextUp = await JellyfinService.loadNextUp(user, seriesId);

    if (nextUp == null) {
      return null;
    }

    return nextUp;
  }

  String? generateStreamUrl(String videoId) {
    final user = userRepository.activeUser;
    if (user == null) {
      log('Tried to generate video url without user');
      return null;
    }

    return user.serverUri.replace(
      queryParameters: {
        'Static': 'true',
        'deviceId': deviceId,
        'api_key': user.token,
      },
      path: '/Videos/$videoId/stream.mp4',
    ).toString();
  }
}
