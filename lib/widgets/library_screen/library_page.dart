import 'dart:typed_data';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jellywin/api/jellyfin_openapi_stable.swagger.dart';
import 'package:jellywin/image_service.dart';
import 'package:jellywin/main.dart';
import 'package:jellywin/repositories/user_repository.dart';

import '../../jellyfin_service.dart';

class LibraryPage extends StatefulWidget {
  final String libraryId;

  const LibraryPage(this.libraryId, {super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  Future<List<BaseItemDto>?>? request;
  User? user;

  Map<String, String> images = {};

  @override
  void initState() {
    user = context.read<UserRepository>().activeUser;
    if (user != null) {
      request = JellyfinService.loadLibraryContents(user!, widget.libraryId);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: request,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            return Center(
              child: Column(
                children: [
                  Text(snapshot.connectionState.toString()),
                  ProgressRing(),
                ],
              ),
            );
          case ConnectionState.done:
        }

        final data = snapshot.data!;
        return ScaffoldPage(
          content: GridView.builder(
            primary: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: (MediaQuery.of(context).size.width / 400).toInt(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.66,
            ),
            itemCount: data.length,
            itemBuilder: (context, index) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return ItemCard(
                    item: data[index],
                    width: constraints.maxWidth.toInt(),
                    height: constraints.maxHeight.toInt(),
                    onTap: (item) => context.go('/library/${widget.libraryId}/${item.id!}'),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class ItemCard extends StatelessWidget {
  final BaseItemDto item;
  final int width;
  final int height;
  final void Function(BaseItemDto item)? onTap;

  const ItemCard({
    super.key,
    required this.item,
    required this.width,
    required this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<ImageService>().getImage(item.id!, width, height, ItemsItemIdImagesImageTypeGetImageType.primary),
      builder:(context, snapshot) => SizedBox(
        child: GestureDetector(
          onTap: onTap != null ? () => onTap?.call(item) : null,
          child: Card(
            child: Stack(
              children: [
                if (snapshot.data != null)
                  Image.memory(
                    height: height.toDouble(),
                    width: width.toDouble(),
                    fit: BoxFit.cover,
                    Uint8List.fromList(snapshot.data!.codeUnits),
                  ),
                Text(item.name!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
