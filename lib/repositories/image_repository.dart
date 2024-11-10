import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:jellywin/jellyfin_service.dart';
import 'package:meta/meta.dart';

import '../api/jellyfin_openapi_stable.enums.swagger.dart';
import 'user_repository.dart';

class ImageRepository {
  Map<String, _CachedImage> _images = {};

  _CachedImage? _loadFromCache(String id, int maxWidth, int maxHeight) {
    final imageSet = _images[id];

    //var sortedBy = imageSet.sorted((a, b) => a.area.compareTo(b.area));

    return imageSet;
  }

  _CachedImage? _cacheImage(
    int maxHeight,
    int maxWidth,
    String id,
    String? content,
    ItemsItemIdImagesImageTypeGetImageType type,
  ) {
    if (content == null) return null;

    _images[id] = _CachedImage(
      type: type,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      id: id,
      content: content,
    );

    return _images[id];
  }

  Future<String?> getImage(
    User user,
    String id,
    int maxWidth,
    int maxHeight,
    ItemsItemIdImagesImageTypeGetImageType imageType,
  ) async {
    var cached = _loadFromCache(id, maxWidth, maxHeight);

    if (cached == null) {
      final request = await JellyfinService.loadLibraryImage(
        user,
        id,
        maxWidth,
        maxHeight,
        type: imageType,
      );

      return _cacheImage(maxHeight, maxWidth, id, request, imageType)?.content;
    }

    return cached.content;
  }
}

@immutable
class _CachedImage extends Equatable {
  final int maxHeight;
  final int maxWidth;
  final String id;
  final String content;
  final ItemsItemIdImagesImageTypeGetImageType type;

  final int area;

  const _CachedImage(
      {required this.type,
      required this.maxHeight,
      required this.maxWidth,
      required this.id,
      required this.content})
      : area = maxHeight * maxWidth;

  @override
  List<Object?> get props => [id, type, maxHeight, maxWidth];
}
