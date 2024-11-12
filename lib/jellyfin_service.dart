import 'dart:developer';

import 'package:chopper/chopper.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'api/jellyfin_openapi_stable.swagger.dart';
import 'repositories/user_repository.dart';

late final String deviceId;
late final String deviceName;

class JellyfinService {
  static final clients = <JellyfinOpenapiStable>[];

  static Future<User?> signInByNamePassword(
    Uri url,
    String username,
    String password,
  ) async {
    final header = await _buildBaseHeader();

    final client = JellyfinOpenapiStable.create(
      baseUrl: url,
      interceptors: [
        HeadersInterceptor({'Authorization': header}),
      ],
    );

    final result = await client.usersAuthenticateByNamePost(
        body: AuthenticateUserByName(username: username, pw: password));

    if (result.isSuccessful) {
      return User(
          serverUri: url,
          name: username,
          token: result.bodyOrThrow.accessToken!,
          id: result.bodyOrThrow.serverId!);
    }

    return null;
  }

  static Future<List<BaseItemDto>?> loadAvailableLibraries(User user) async {
    final client = buildApiClient(user);

    final result = await client.libraryMediaFoldersGet();
    if (!result.isSuccessful) {
      log('Failed getting libraries');
      return null;
    }

    final body = result.bodyOrThrow;

    return body.items;
  }

  static Future<List<BaseItemDto>?> loadLibraryContents(
    User user,
    String libraryId,
  ) async {
    var request = await buildApiClient(user).itemsGet(
        parentId: libraryId,
        sortOrder: [SortOrder.ascending],
        sortBy: [ItemSortBy.name]);

    if (!request.isSuccessful) {
      log('Failed to get library contents');
    }

    return request.body?.items;
  }

  static Future<String?> loadLibraryImage(
    User user,
    String libraryId,
    int? maxWith,
    int? maxHeight, {
    ItemsItemIdImagesImageTypeGetImageType? type,
  }) async {
    final api = buildApiClient(user);
    type ??= ItemsItemIdImagesImageTypeGetImageType.primary;

    var result = await api.itemsItemIdImagesImageTypeGet(
      itemId: libraryId,
      imageType: type,
      maxWidth: maxWith,
      maxHeight: maxHeight,
    );

    if (!result.isSuccessful) {
      log('Failed to load image for library $libraryId');
    }

    return result.body;
  }

  static JellyfinOpenapiStable buildApiClient(User user) {
    var existingClient = clients
        .where(
          (element) =>
              element.client.baseUrl == user.serverUri &&
              ((element.client.interceptors.first as HeadersInterceptor)
                      .headers['Authorization']
                      ?.contains(user.id) ??
                  false),
        )
        .firstOrNull;

    if (existingClient != null) {
      return existingClient;
    }

    log('Creating new client for ${user.name}');

    var client = JellyfinOpenapiStable.create(
      baseUrl: user.serverUri,
      interceptors: [
        HeadersInterceptor({'Authorization': _buildAuthenticatedHeader(user)}),
      ],
    );

    clients.add(client);
    return client;
  }

  static Future<BaseItemDtoQueryResult?> loadSeriesInfo(User user, String id) async {
    final api = buildApiClient(user);

    final result = await api.itemsGet(ids: [id]);
    if (!result.isSuccessful) {
      log('Failed getting loadSeriesInfo ${result.error}');
      return null;
    }

    final body = result.bodyOrThrow;

    return body;
  }



  static String _buildBaseHeader() {
    var authHeader = 'MediaBrowser ';

    authHeader += 'Client="Jellywin", ';

    authHeader += 'Device="$deviceName", DeviceId="$deviceId", ';

    var version = 'dev';
    authHeader += 'Version="$version"';
    return authHeader;
  }

  static String _buildAuthenticatedHeader(User user) {
    var authHeader = 'MediaBrowser ';
    authHeader += 'UserId="${user.id}", ';
    authHeader += 'Token="${user.token}", ';

    authHeader += 'Client="Jellywin", ';

    authHeader += 'Device="$deviceName", DeviceId="$deviceId", ';

    var version = 'dev';
    authHeader += 'Version="$version"';
    return authHeader;
  }

}

Future<void> initDeviceConstants() async {
  var deviceInfo = DeviceInfoPlugin();
  var windowsDeviceInfo = await deviceInfo.windowsInfo;
  deviceName = (windowsDeviceInfo).computerName;
  deviceId = (windowsDeviceInfo).deviceId;
}
