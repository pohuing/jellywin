import 'dart:typed_data';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jellywin/api/jellyfin_openapi_stable.swagger.dart';
import 'package:jellywin/blocs/account_cubit.dart';

class LibraryPage extends StatefulWidget {
  final String libraryId;

  const LibraryPage(this.libraryId, {Key? key}) : super(key: key);

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  Future<BaseItemDtoQueryResult>? request;

  @override
  void initState() {
    request = context
        .read<AccountCubit>()
        .api!
        .itemsGet(parentId: widget.libraryId, sortOrder: [SortOrder.ascending], sortBy: [ItemSortBy.name])
        .then((value) => value.bodyOrThrow);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final api = context.read<AccountCubit>().api!;

    return FutureBuilder(
      future: request,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: ProgressRing(),
          );
        }

        final data = snapshot.data!;
        return ScaffoldPage(
          content: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.66),
            itemCount: data.items?.length ?? 0,
            itemBuilder: (context, index) {
              return LayoutBuilder(
                builder: (context, constraints) => FutureBuilder(
                  future: api
                      .itemsItemIdImagesImageTypeGet(
                        itemId: data.items![index].id,
                        imageType: ItemsItemIdImagesImageTypeGetImageType.primary,
                    maxWidth:  constraints.maxWidth.toInt(),
                    maxHeight: constraints.maxHeight.toInt(),
                      )
                      .then((value) => value.bodyOrThrow),
                  builder: (context, snapshot) =>
                      ItemCard(item: data.items![index], image: snapshot.data),
                ),
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
            Text(item.name!),
          ],
        ),
      ),
    );
  }
}
