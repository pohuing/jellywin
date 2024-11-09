import 'dart:typed_data';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jellywin/api/jellyfin_openapi_stable.swagger.dart';
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
                  ProgressRing()
                ],
              ),
            );
          case ConnectionState.done:
        }

        final data = snapshot.data!;
        return ScaffoldPage(
          content: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.66),
            itemCount: data.length,
            itemBuilder: (context, index) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  String imageIdentifier = data[index].id! + constraints.maxHeight.toString() + constraints.maxWidth.toString();

                  var future;
                  if (images.containsKey(imageIdentifier)) {
                    Future.value(images[imageIdentifier]);
                  } else {
                    future = JellyfinService.loadLibraryImage(
                      user!,
                      data[index].id!,
                      constraints.maxWidth.toInt(),
                      constraints.maxHeight.toInt(),
                    ).then((value) {
                      if (value != null && data[index].id != null) {
                          images.putIfAbsent(imageIdentifier, () => value);
                          return value;
                      }
                    });
                  }

                  return FutureBuilder(
                    future: future,
                    builder: (context, snapshot) => ItemCard(
                        item: data[index], image: images[imageIdentifier]),
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
  final String? image;

  const ItemCard({super.key, required this.item, this.image});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: 100,
      child: Card(
        child: Stack(
          children: [
            if (image != null)
              Image.memory(Uint8List.fromList(image!.codeUnits)),
            if (image == null) ProgressRing(),
            Text(item.name!),
          ],
        ),
      ),
    );
  }
}
