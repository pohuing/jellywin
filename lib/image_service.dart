import 'package:jellywin/api/jellyfin_openapi_stable.enums.swagger.dart';
import 'package:jellywin/jellyfin_service.dart';
import 'package:jellywin/repositories/image_repository.dart';
import 'package:jellywin/repositories/user_repository.dart';

class ImageService {
  final UserRepository userRepository;
  final ImageRepository imageRepository;

  ImageService({required this.userRepository, required this.imageRepository});

  Future<String?> getImage(String id, int width, int height,
      ItemsItemIdImagesImageTypeGetImageType type) async {
    final currentUser = userRepository.activeUser!;

    final image =
        await imageRepository.getImage(currentUser, id, width, height, type);

    return image;
  }
}
